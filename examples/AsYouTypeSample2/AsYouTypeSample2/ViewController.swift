//
//  ViewController.swift
//  AsYouTypeSample2
//
//  Created by Oskari Rauta on 04.01.20.
//  Copyright © 2020 Oskari Rauta. All rights reserved.
//

import UIKit
import CommonKit
import PhoneNumberKit

class ViewController: UIViewController, UITextFieldDelegate {

    lazy var phone_del: PhoneNumberFieldDelegate  = PhoneNumberFieldDelegate.create {
            $0.subDelegate = self
    }

    lazy var textField: UITextField = UITextField.create {
        $0.font = UIFont.systemFont(ofSize: 28.0, weight: .light)
        $0.textColor = UIColor.label
        $0.clearButtonMode = .never
        $0.minimumFontSize = 17.0
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.delegate = self.phone_del
        $0.placeholder = "Enter phone number"
        $0.inputView = NumPad(type: .phone)
        $0.inputAccessoryView = DoneBar()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
            
        self.view.addSubview(self.textField)
        self.textField.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor, constant: 16.0).isActive = true
        self.textField.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor, constant: 16.0).isActive = true
        self.textField.trailingAnchor.constraint(equalTo:self.view.safeAreaLayoutGuide.trailingAnchor, constant: -16.0).isActive = true
        self.textField.heightAnchor.constraint(equalToConstant: 70.0).isActive = true

        self.textField.addTarget(self, action: #selector(self.phoneNo(_:)), for: .allEvents)
        }

        @objc func phoneNo(_ sender: Any) {
    //        print(self.textField.nationalNumber)
        }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.textField.becomeFirstResponder()
    }
    
}

