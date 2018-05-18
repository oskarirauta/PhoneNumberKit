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
import NumPad

class ViewController: UIViewController, CNContactPickerDelegate {
    
    @IBOutlet var textField: UITextField!
    
    lazy var del: PhoneNumberFieldDelegate = PhoneNumberFieldDelegate(self.textField)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        textField.becomeFirstResponder()
        textField.addTarget(self, action: #selector(self.phoneNo(_:)), for: .allEvents)
        textField.delegate = self.del
        textField.inputAccessoryView = DoneBar(delegate: self.textField)
        textField.inputView = NumPad(delegate: self.textField, type: .phone)
        textField.keyboardType = .phonePad
    }

    @objc func phoneNo(_ sender: Any) {
//        print(self.textField.nationalNumber)
    }
    
}

