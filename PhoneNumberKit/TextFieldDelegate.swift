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

protocol PhoneNumberFieldDelegateProtocol: UITextFieldDelegate {

    var phoneNumberKit: PhoneNumberKit { get set }
    var partialFormatter: PartialFormatter { get set }
    var subDelegate: UITextFieldDelegate? { get set }
}

open class PhoneNumberFieldDelegate: NSObject, PhoneNumberFieldDelegateProtocol {
    
    open var phoneNumberKit: PhoneNumberKit = PhoneNumberKit()
    open lazy var partialFormatter: PartialFormatter = PartialFormatter(phoneNumberKit: self.phoneNumberKit, defaultRegion: self.defaultRegion, withPrefix: self.withPrefix)
    open weak var subDelegate: UITextFieldDelegate? = nil

    private(set) weak var textInput: UITextInput?
    
    open var defaultRegion: String = Locale.appLocale.regionCode ?? PhoneNumberKit.defaultRegionCode() {
        didSet { self.partialFormatter.defaultRegion = defaultRegion }
    }

    open var withPrefix: Bool = true {
        didSet { self.partialFormatter.withPrefix = withPrefix }
    }
    
    open var isPartialFormatterEnabled: Bool = true
    
    open var autoValidateNumber: Bool = true
    
    open var maxDigits: Int? {
        didSet { self.partialFormatter.maxDigits = maxDigits }
    }
    
    public var currentRegion: String {
        get { return self.partialFormatter.currentRegion }
    }
    
    internal var text: String? {
        get {
            if let textField: UITextField = self.textInput as? UITextField { return textField.text }
            else if let textView: UITextView = self.textInput as? UITextView { return textView.text }
            return nil
        }
    }
    
    open var nationalNumber: String {
        get { return self.partialFormatter.nationalNumber(from: self.text ?? String()) }
    }
    
    open var isValidNumber: Bool {
        get { return ( try? self.phoneNumberKit.parse(self.text ?? String(), withRegion: self.currentRegion)) == nil ? false : true
        }
    }
    
    lazy internal var nonNumericSet: CharacterSet = {
        var mutableSet = NSMutableCharacterSet.decimalDigit().inverted
        mutableSet.remove(charactersIn: PhoneNumberConstants.plusChars)
        return mutableSet as CharacterSet
    }()
    
    public override init() {
        super.init()
        self.textInput = nil
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.setupTextInput(_:)), name: NSNotification.Name.UITextFieldTextDidBeginEditing, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.setupTextInput(_:)), name: NSNotification.Name.UITextViewTextDidEndEditing, object: nil)        
    }

    public convenience init(delegate: UITextFieldDelegate?) {
        self.init()
        self.subDelegate = delegate
    }
    
    @objc internal func setupTextInput(_ notification: Notification) {

        guard
            let textInput: UITextInput = notification.object as? UITextInput,
            textInput is UITextField,
            self == (textInput as! UITextField).delegate as? PhoneNumberFieldDelegate
            else { return }

        (textInput as! UITextField).autocorrectionType = .no
        self.textInput = textInput
        
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UITextFieldTextDidBeginEditing, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UITextViewTextDidBeginEditing, object: nil)
    }

    
    internal var selectedTextRange: UITextRange? {
        get { return self.textInput?.selectedTextRange }
    }
    
    internal func extractCursorPosition() -> CursorPosition? {
        var repetitionCountFromEnd = 0
        // Check that there is text in the UITextField
        guard
            let text: String = self.text,
            let selectedTextRange: UITextRange = self.selectedTextRange,
            let beginningOfDocument: UITextPosition = self.textInput?.beginningOfDocument,
            let cursorEnd: Int = self.textInput?.offset(from: beginningOfDocument, to: selectedTextRange.end)
            else { return nil }
        
        // Look for the next valid number after the cursor, when found return a CursorPosition struct
        for i in cursorEnd ..< text.count  {
            let candidateNumberAfterCursor: String = text.substring(with: NSRange(location: i, length: 1))
            if ( candidateNumberAfterCursor.rangeOfCharacter(from: self.nonNumericSet) == nil ) {
                for j in i..<text.count {
                    if ( text.substring(with: NSRange(location: j, length: 1)) == candidateNumberAfterCursor ) {
                        repetitionCountFromEnd += 1
                    }
                }
                return CursorPosition(numberAfterCursor: candidateNumberAfterCursor, repetitionCountFromEnd: repetitionCountFromEnd)
            }
        }
        return nil
    }

    // Finds position of previous cursor in new formatted text
    internal func selectionRangeForNumberReplacement(textField: UITextField, formattedText: String) -> NSRange? {
        
        guard let cursorPosition: CursorPosition = self.extractCursorPosition() else {
            return nil
        }

        var countFromEnd = 0
        for i in stride(from: formattedText.count - 1, through: 0, by: -1) {
            if ( formattedText.substring(with: NSRange(location: i, length: 1)) == cursorPosition.numberAfterCursor ) {
                countFromEnd += 1
                if ( countFromEnd == cursorPosition.repetitionCountFromEnd ) {
                    return NSRange(location: i, length: 1)
                }
            }
        }
        
        return nil
    }
    
    open func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        // This allows for the case when a user autocompletes a phone number:
        if (( range == NSRange(location: 0, length: 0)) && ( string == " " )) {
            return true
        }
        
        guard
            let text = self.text,
            self.subDelegate?.textField?(textField, shouldChangeCharactersIn: range, replacementString: string) ?? true
            else {
            return false
        }

        guard self.isPartialFormatterEnabled else { return true }
        
        let changedRange: String = text.substring(with: range)
        var modifiedText: String = text.replacingCharacters(in: text.range(from: range)!, with: string)
        
        // Handle backspace after whitespace
        if (( !modifiedText.isEmpty ) && ( modifiedText.count <  ( textField.text?.count ?? 0 ))) {
            modifiedText = self.partialFormatter.formatPartial(modifiedText)
        }
        
        let rawNumberString: String = modifiedText.filter {
            String($0).rangeOfCharacter(from: self.nonNumericSet) == nil
        }
        
        let formattedNationalNumber: String = self.partialFormatter.formatPartial(rawNumberString)
        var selectedTextRange: NSRange?
        
        let nonNumericRange: Bool = changedRange.rangeOfCharacter(from: self.nonNumericSet) != nil ? true : false
        
        if (( range.length == 1 ) && ( string.isEmpty ) && ( nonNumericRange )) {
            selectedTextRange = self.selectionRangeForNumberReplacement(textField: textField, formattedText: modifiedText)
            textField.text = modifiedText
        } else {
            selectedTextRange = self.selectionRangeForNumberReplacement(textField: textField, formattedText: formattedNationalNumber)
            textField.text = formattedNationalNumber
        }
        
        textField.sendActions(for: .editingChanged)
        
        if selectedTextRange != nil,
            let selectionRangePosition = textField.position(from: textField.beginningOfDocument, offset: selectedTextRange!.location) {
            textField.selectedTextRange = textField.textRange(from: selectionRangePosition, to: selectionRangePosition)
        }
        
        if let selectedTextRange: NSRange = selectedTextRange, let selectionRangePosition = textField.position(from: textField.beginningOfDocument, offset: selectedTextRange.location) {
            let selectionRange = textField.textRange(from: selectionRangePosition, to: selectionRangePosition)
            textField.selectedTextRange = selectionRange
        }
        
        return false
    }
    
    //MARK: UITextfield Delegate
    
    open func textFieldDidEndEditing(_ textField: UITextField, reason: UITextFieldDidEndEditingReason) {
        self.subDelegate?.textFieldDidEndEditing?(textField, reason: reason)
    }
    
    open func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        return self.subDelegate?.textFieldShouldBeginEditing?(textField) ?? true
    }
    
    open func textFieldDidBeginEditing(_ textField: UITextField) {
        self.subDelegate?.textFieldDidBeginEditing?(textField)
    }
    
    open func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        return self.subDelegate?.textFieldShouldEndEditing?(textField) ?? true
    }
    
    open func textFieldDidEndEditing(_ textField: UITextField) {
        
        if (( self.isPartialFormatterEnabled ) && ( textField.text != nil )) {
            textField.text = self.partialFormatter.formatPartial(textField.text!)
        }

        if (( self.isPartialFormatterEnabled ) && ( self.autoValidateNumber ) && ( textField.text != nil )) {
            textField.text = self.partialFormatter.isValidRawNumber(textField.text!) ? textField.text : nil
        }
        
        self.subDelegate?.textFieldDidEndEditing?(textField)
    }
    
    open func textFieldShouldClear(_ textField: UITextField) -> Bool {
        return self.subDelegate?.textFieldShouldClear?(textField) ?? true
    }
    
    open func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return self.subDelegate?.textFieldShouldReturn?(textField) ?? true
    }

}
