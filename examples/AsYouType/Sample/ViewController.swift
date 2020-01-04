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

    lazy var textField: PhoneNumberTextField = PhoneNumberTextField.create {
        $0.font = UIFont.systemFont(ofSize: 28.0, weight: .light)
        $0.textColor = UIColor.label
        $0.clearButtonMode = .never
        $0.minimumFontSize = 17.0
        $0.placeholder = "Enter phone number"
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.keyboardType = .phonePad
        $0.inputAccessoryView = DoneBar()
        $0.inputView = NumPad(type: .phone)
    }
    
    lazy var del: PhoneNumberFieldDelegate = PhoneNumberFieldDelegate(delegate: self.textField.delegate)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.addSubview(self.textField)
        self.textField.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 16.0).isActive = true
        self.textField.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor, constant: 16.0).isActive = true
        self.textField.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor, constant: -16.0).isActive = true
        self.textField.heightAnchor.constraint(equalToConstant: 70.0).isActive = true

        self.textField.delegate = self.del
        
        self.textField.becomeFirstResponder()
        self.textField.addTarget(self, action: #selector(self.phoneNo(_:)), for: .allEvents)
    }

    @objc func phoneNo(_ sender: Any) {
//        print(self.textField.nationalNumber)
    }
    
}

