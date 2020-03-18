//
//  Bundle.swift
//  PhoneNumberKit
//
//  Created by Oskari Rauta on 18.03.20.
//  Copyright © 2020 Roy Marmelstein. All rights reserved.
//

import Foundation

extension Bundle {
    
    public private(set) static var PhoneNumberKit: Bundle = Bundle(for: PhoneNumberTextField.self)
}
