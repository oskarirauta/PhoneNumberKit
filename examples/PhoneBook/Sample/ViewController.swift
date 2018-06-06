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

class ViewController: UIViewController, CNContactPickerDelegate {

    lazy var numberTitle: UILabel = {
        var _numberTitle: UILabel = UILabel(frame: .zero)
        _numberTitle.translatesAutoresizingMaskIntoConstraints = false
        _numberTitle.font = UIFont.systemFont(ofSize: 25.0)
        _numberTitle.textColor = UIColor.black
        _numberTitle.textAlignment = .center
        _numberTitle.text = "Parsed number"
        return _numberTitle
    }()

    lazy var numberLabel: UILabel = {
        var _numberLabel: UILabel = UILabel(frame: .zero)
        _numberLabel.translatesAutoresizingMaskIntoConstraints = false
        _numberLabel.font = UIFont.systemFont(ofSize: 32.0, weight: .thin)
        _numberLabel.textColor = UIColor.black
        _numberLabel.textAlignment = .center
        _numberLabel.text = self.notAvailable
        return _numberLabel
    }()

    lazy var countryCodeTitle: UILabel = {
        var _countryCodeTitle: UILabel = UILabel(frame: .zero)
        _countryCodeTitle.translatesAutoresizingMaskIntoConstraints = false
        _countryCodeTitle.font = UIFont.systemFont(ofSize: 25.0)
        _countryCodeTitle.textColor = UIColor.black
        _countryCodeTitle.textAlignment = .center
        _countryCodeTitle.text = "Country Code"
        return _countryCodeTitle
    }()
    
    lazy var countryCodeLabel: UILabel = {
        var _countryCodeLabel: UILabel = UILabel(frame: .zero)
        _countryCodeLabel.translatesAutoresizingMaskIntoConstraints = false
        _countryCodeLabel.font = UIFont.systemFont(ofSize: 32.0, weight: .thin)
        _countryCodeLabel.textColor = UIColor.black
        _countryCodeLabel.textAlignment = .center
        _countryCodeLabel.text = self.notAvailable
        return _countryCodeLabel
    }()

    lazy var countryTitle: UILabel = {
        var _countryTitle: UILabel = UILabel(frame: .zero)
        _countryTitle.translatesAutoresizingMaskIntoConstraints = false
        _countryTitle.font = UIFont.systemFont(ofSize: 25.0)
        _countryTitle.textColor = UIColor.black
        _countryTitle.textAlignment = .center
        _countryTitle.text = "Main country"
        return _countryTitle
    }()
    
    lazy var countryLabel: UILabel = {
        var _countryLabel: UILabel = UILabel(frame: .zero)
        _countryLabel.translatesAutoresizingMaskIntoConstraints = false
        _countryLabel.font = UIFont.systemFont(ofSize: 32.0, weight: .thin)
        _countryLabel.textColor = UIColor.black
        _countryLabel.textAlignment = .center
        _countryLabel.text = self.notAvailable
        return _countryLabel
    }()

    lazy var stackView: UIStackView = {
        var _stackView: UIStackView = UIStackView(arrangedSubviews: [
            self.numberTitle, self.numberLabel,
            self.countryCodeTitle, self.countryCodeLabel,
            self.countryTitle, self.countryLabel
            ])
        _stackView.axis = .vertical
        _stackView.alignment = .center
        _stackView.distribution = .fillProportionally
        _stackView.spacing = 6.0
        _stackView.translatesAutoresizingMaskIntoConstraints = false
        return _stackView
    }()
    
    lazy var selectButton: UIButton = {
        var _selectButton: UIButton = UIButton(type: .system)
        _selectButton.translatesAutoresizingMaskIntoConstraints = false
        _selectButton.titleLabel?.font = UIFont.systemFont(ofSize: 19.0)
        _selectButton.setTitle("Select from Contacts", for: UIControlState())
        _selectButton.addTarget(self, action: #selector(self.selectFromContacts(_:)), for: .touchUpInside)
        return _selectButton
    }()
    
    lazy var phoneNumberKit: PhoneNumberKit = PhoneNumberKit()
    let notAvailable = "NA"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.addSubview(self.stackView)
        self.view.addSubview(self.selectButton)
        
        self.stackView.centerYAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.centerYAnchor, constant: -50.0).isActive = true
        self.stackView.centerXAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.centerXAnchor).isActive = true

        self.selectButton.topAnchor.constraint(equalTo: self.stackView.bottomAnchor, constant: 30.0).isActive = true
        self.selectButton.centerXAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.centerXAnchor).isActive = true
        
        self.clearResults()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func selectFromContacts(_ sender: AnyObject) {
        let controller = CNContactPickerViewController()
        controller.delegate = self
        self.present(controller,
            animated: true, completion: nil)
    }
    
    func contactPicker(_ picker: CNContactPickerViewController, didSelect contact: CNContact) {
        guard let firstPhoneNumber = contact.phoneNumbers.first else {
            self.clearResults()
            return;
        }
        let phoneNumber = firstPhoneNumber.value
        parseNumber(phoneNumber.stringValue)
    }

    func parseNumber(_ number: String) {
        do {
            let phoneNumber = try phoneNumberKit.parse(number)
            self.numberLabel.text = phoneNumberKit.format(phoneNumber, toType: .international)
            self.countryCodeLabel.text = String(phoneNumber.countryCode)
            if let regionCode = phoneNumberKit.mainCountry(forCode: phoneNumber.countryCode) {
                let country = Locale.current.localizedString(forRegionCode: regionCode)
                self.countryLabel.text = country
            }
        }
        catch {
            self.clearResults()
            print("Something went wrong")
        }
    }
    
    func clearResults() {
        self.numberLabel.text = self.notAvailable
        self.countryCodeLabel.text = self.notAvailable
        self.countryLabel.text = self.notAvailable
    }

}
