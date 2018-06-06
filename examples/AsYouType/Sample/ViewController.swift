//
//  ViewController.swift
//  Sample
//
//  Created by Roy Marmelstein on 27/09/2015.
//  Copyright © 2015 Roy Marmelstein. All rights reserved.
//

import UIKit
import Foundation
import ContactsUI
import PhoneNumberKit
import CommonKit

class ViewController: UIViewController, CNContactPickerDelegate {
    
    lazy var textField: PhoneNumberTextField = {
        var _textField: PhoneNumberTextField = PhoneNumberTextField(frame: .zero)
        _textField.font = UIFont.systemFont(ofSize: 28.0, weight: .light)
        _textField.textColor = UIColor.black
        _textField.clearButtonMode = .never
        _textField.minimumFontSize = 17.0
        _textField.placeholder = "Enter phone number"
        _textField.translatesAutoresizingMaskIntoConstraints = false
        return _textField
    }()
    
    lazy var del: PhoneNumberFieldDelegate = PhoneNumberFieldDelegate(delegate: self.textField.delegate)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.addSubview(self.textField)
        self.textField.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 16.0).isActive = true
        self.textField.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor, constant: 16.0).isActive = true
        self.textField.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor, constant: -16.0).isActive = true
        self.textField.heightAnchor.constraint(equalToConstant: 70.0).isActive = true
        
        textField.becomeFirstResponder()
        textField.addTarget(self, action: #selector(self.phoneNo(_:)), for: .allEvents)
        textField.delegate = self.del
        textField.inputAccessoryView = DoneBar()
        textField.inputView = NumPad(type: .phone)
        textField.keyboardType = .phonePad
    }

    @objc func phoneNo(_ sender: Any) {
//        print(self.textField.nationalNumber)
    }
    
}

