//
//  TextFieldDelegate.swift
//  PhoneNumberKit
//
//  Created by Oskari Rauta on 17/05/2018.
//  Copyright © 2018 Roy Marmelstein. All rights reserved.
//

import Foundation
import UIKit

internal struct CursorPosition {
    let numberAfterCursor: String
    let repetitionCountFromEnd: Int
}

public protocol PhoneNumberFieldDelegateProtocol: UITextFieldDelegate {

    var phoneNumberKit: PhoneNumberKit { get set }
    var partialFormatter: PartialFormatter { get set }
    var subDelegate: UITextFieldDelegate? { get set }
}

open class PhoneNumberFieldDelegate: NSObject, PhoneNumberFieldDelegateProtocol {
    
    open var phoneNumberKit: PhoneNumberKit = PhoneNumberKit()
    open lazy var partialFormatter: PartialFormatter = PartialFormatter(phoneNumberKit: phoneNumberKit, defaultRegion: defaultRegion, withPrefix: withPrefix)
    open weak var subDelegate: UITextFieldDelegate? = nil

    private var textInput: UITextInput!
    
    public var defaultRegion = Locale.appLocale.regionCode ?? PhoneNumberKit.defaultRegionCode() {
        didSet {
            partialFormatter.defaultRegion = defaultRegion
        }
    }

    open var withPrefix: Bool = true {
        didSet { partialFormatter.withPrefix = withPrefix }
    }
    
    open var isPartialFormatterEnabled = true
    
    open var maxDigits: Int? {
        didSet { partialFormatter.maxDigits = maxDigits }
    }
    
    public var currentRegion: String {
        get {
            return partialFormatter.currentRegion
        }
    }
    
    internal var text: String? {
        get {
            if let textField: UITextField = self.textInput as? UITextField { return textField.text }
            else if let textView: UITextView = self.textInput as? UITextView { return textView.text }
            return nil
        }
    }
    
    public var nationalNumber: String {
        get {
            let rawNumber = self.text ?? String()
            return partialFormatter.nationalNumber(from: rawNumber)
        }
    }
    
    public var isValidNumber: Bool {
        get {
            let rawNumber = self.text ?? String()
            do {
                let _ = try phoneNumberKit.parse(rawNumber, withRegion: currentRegion)
                return true
            } catch {
                return false
            }
        }
    }
    
    lazy var nonNumericSet: NSCharacterSet = {
        var mutableSet = NSMutableCharacterSet.decimalDigit().inverted
        mutableSet.remove(charactersIn: PhoneNumberConstants.plusChars)
        return mutableSet as NSCharacterSet
    }()
    
    public init(_ textInput: UITextInput) {
        super.init()
        self.textInput = textInput
        
        if let textField: UITextField = textInput as? UITextField {
            textField.autocorrectionType = .no
        } else if let textView: UITextView = textInput as? UITextView {
            textView.autocorrectionType = .no
        }
        
    }
    
    internal func extractCursorPosition() -> CursorPosition? {
        var repetitionCountFromEnd = 0
        // Check that there is text in the UITextField
        guard let text = text, let selectedTextRange = self.textInput.selectedTextRange else {
            return nil
        }
        let textAsNSString = text as NSString
        let cursorEnd = self.textInput.offset(from: self.textInput.beginningOfDocument, to: selectedTextRange.end)
        // Look for the next valid number after the cursor, when found return a CursorPosition struct
        for i in cursorEnd ..< textAsNSString.length  {
            let cursorRange = NSMakeRange(i, 1)
            let candidateNumberAfterCursor: NSString = textAsNSString.substring(with: cursorRange) as NSString
            if (candidateNumberAfterCursor.rangeOfCharacter(from: nonNumericSet as CharacterSet).location == NSNotFound) {
                for j in cursorRange.location ..< textAsNSString.length  {
                    let candidateCharacter = textAsNSString.substring(with: NSMakeRange(j, 1))
                    if candidateCharacter == candidateNumberAfterCursor as String {
                        repetitionCountFromEnd += 1
                    }
                }
                return CursorPosition(numberAfterCursor: candidateNumberAfterCursor as String, repetitionCountFromEnd: repetitionCountFromEnd)
            }
        }
        return nil
    }

    // Finds position of previous cursor in new formatted text
    internal func selectionRangeForNumberReplacement(textField: UITextField, formattedText: String) -> NSRange? {
        let textAsNSString = formattedText as NSString
        var countFromEnd = 0
        guard let cursorPosition = extractCursorPosition() else {
            return nil
        }
        
        for i in stride(from: (textAsNSString.length - 1), through: 0, by: -1) {
            let candidateRange = NSMakeRange(i, 1)
            let candidateCharacter = textAsNSString.substring(with: candidateRange)
            if candidateCharacter == cursorPosition.numberAfterCursor {
                countFromEnd += 1
                if countFromEnd == cursorPosition.repetitionCountFromEnd {
                    return candidateRange
                }
            }
        }
        
        return nil
    }
    
    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        print("Should change chars..")
        
        // This allows for the case when a user autocompletes a phone number:
        if range == NSRange(location: 0, length: 0) && string == " " {
            return true
        }
        
        guard let text = text else {
            return false
        }
        
        // allow delegate to intervene
        guard subDelegate?.textField?(textField, shouldChangeCharactersIn: range, replacementString: string) ?? true else {
            return false
        }
        
        let textAsNSString = text as NSString
        let changedRange = textAsNSString.substring(with: range) as NSString
        let modifiedTextField = textAsNSString.replacingCharacters(in: range, with: string)
        
        let filteredCharacters = modifiedTextField.filter {
            return  String($0).rangeOfCharacter(from: self.nonNumericSet as CharacterSet) == nil
        }
        let rawNumberString = String(filteredCharacters)
        
        let formattedNationalNumber = partialFormatter.formatPartial(rawNumberString as String)
        var selectedTextRange: NSRange?
        
        let nonNumericRange = (changedRange.rangeOfCharacter(from: nonNumericSet as CharacterSet).location != NSNotFound)
        if (range.length == 1 && string.isEmpty && nonNumericRange)
        {
            selectedTextRange = selectionRangeForNumberReplacement(textField: textField, formattedText: modifiedTextField)
            textField.text = modifiedTextField
        }
        else {
            selectedTextRange = selectionRangeForNumberReplacement(textField: textField, formattedText: formattedNationalNumber)
            textField.text = formattedNationalNumber
        }
        
        if let textField: UITextField = self.textInput as? UITextField {
            textField.sendActions(for: .editingChanged)
        }
        
        if let selectedTextRange: NSRange = selectedTextRange, let selectionRangePosition = textField.position(from: textField.beginningOfDocument, offset: selectedTextRange.location) {
            let selectionRange = textField.textRange(from: selectionRangePosition, to: selectionRangePosition)
            textField.selectedTextRange = selectionRange
        }
        
        return false
    }
    
    //MARK: UITextfield Delegate
    
    public func textFieldDidEndEditing(_ textField: UITextField, reason: UITextFieldDidEndEditingReason) {
        subDelegate?.textFieldDidEndEditing?(textField, reason: reason)
    }
    
    public func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        print("should begin")
        return subDelegate?.textFieldShouldBeginEditing?(textField) ?? true
    }
    
    public func textFieldDidBeginEditing(_ textField: UITextField) {
        print("did begin..")
        subDelegate?.textFieldDidBeginEditing?(textField)
    }
    
    public func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        print("should end")
        return subDelegate?.textFieldShouldEndEditing?(textField) ?? true
    }
    
    public func textFieldDidEndEditing(_ textField: UITextField) {
        print("did end..")
        subDelegate?.textFieldDidEndEditing?(textField)
    }
    
    public func textFieldShouldClear(_ textField: UITextField) -> Bool {
        return subDelegate?.textFieldShouldClear?(textField) ?? true
    }
    
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return subDelegate?.textFieldShouldReturn?(textField) ?? true
    }


}
