//
//  TextField.swift
//  PhoneNumberKit
//
//  Created by Roy Marmelstein on 07/11/2015.
//  Copyright © 2015 Roy Marmelstein. All rights reserved.
//

import Foundation
import UIKit
import LocaleKit

/// Custom text field that formats phone numbers
open class PhoneNumberTextField: UITextField {
    
    lazy var phoneDelegate: PhoneNumberFieldDelegate = PhoneNumberFieldDelegate()

    /// Override setText so number will be automatically formatted when setting text by code
    override open var text: String? {
        set {
            let formattedNumber: String? = self.isPartialFormatterEnabled && newValue != nil ? self.phoneDelegate.partialFormatter.formatPartial(newValue!) : nil
            super.text = formattedNumber
        }
        get { return super.text }
    }
    
    /// allows text to be set without formatting
    open func setTextUnformatted(newValue:String?) {
        super.text = newValue
    }
    
    /// Override region to set a custom region. Automatically uses the default region code.
    public var defaultRegion: String {
        get { return self.phoneDelegate.defaultRegion }
        set { self.phoneDelegate.defaultRegion = newValue }
    }

    public var witPrefix: Bool {
        get { return self.phoneDelegate.withPrefix }
        set {
            self.phoneDelegate.withPrefix = newValue
            self.keyboardType = newValue ? UIKeyboardType.phonePad : UIKeyboardType.numberPad
        }
    }
    
    public var isPartialFormatterEnabled: Bool {
        get { return self.phoneDelegate.isPartialFormatterEnabled }
        set { self.phoneDelegate.isPartialFormatterEnabled = newValue }
    }
    
    public var maxDigits: Int? {
        get { return self.phoneDelegate.maxDigits }
        set { self.phoneDelegate.maxDigits = newValue }
    }
    
    public var partialFormatter: PartialFormatter {
        get { return self.phoneDelegate.partialFormatter }
    }
    
    weak private var _delegate: UITextFieldDelegate?
    
    override open var delegate: UITextFieldDelegate? {
        get { return self.phoneDelegate.subDelegate }
        set { self.phoneDelegate.subDelegate = newValue }
    }
    
    //MARK: Status
    
    public var currentRegion: String {
        get { return self.phoneDelegate.currentRegion }
    }
    
    public var nationalNumber: String {
        get { return self.phoneDelegate.nationalNumber }
    }
    
    public var isValidNumber: Bool {
        get { return self.phoneDelegate.isValidNumber }
    }
    
    //MARK: Lifecycle
    
    /**
     Init with frame
     
     - parameter frame: UITextfield F
     
     - returns: UITextfield
     */
    override public init(frame:CGRect)
    {
        super.init(frame:frame)
        self.setup()
    }
    
    /**
     Init with coder
     
     - parameter aDecoder: decoder
     
     - returns: UITextfield
     */
    required public init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        self.setup()
    }
    
    func setup(){
        self.autocorrectionType = .no
        self.keyboardType = UIKeyboardType.phonePad
        super.delegate = self.phoneDelegate
    }
    
}
