//
//  RegexManager.swift
//  PhoneNumberKit
//
//  Created by Roy Marmelstein on 04/10/2015.
//  Copyright © 2015 Roy Marmelstein. All rights reserved.
//

import Foundation

final class RegexManager {
    
    // MARK: Regular expression pool

    var regularExpresionPool: [String : NSRegularExpression] = [:]

    lazy var spaceCharacterSet: CharacterSet = {
        let characterSet = NSMutableCharacterSet(charactersIn: "\u{00a0}")
        characterSet.formUnion(with: CharacterSet.whitespacesAndNewlines)
        return characterSet as CharacterSet
    }()
    
    deinit {
        regularExpresionPool.removeAll()
    }

    // MARK: Regular expression
    
    func regexWithPattern(_ pattern: String) throws -> NSRegularExpression {
        
        guard let regex = regularExpresionPool[pattern] else {
            guard let regularExpression: NSRegularExpression = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive) else { throw PhoneNumberError.generalError }
            regularExpresionPool[pattern] = regularExpression
            return regularExpression
        }
        
        return regex
    }
    
    func regexMatches(_ pattern: String, string: String) throws -> [NSTextCheckingResult] {
        guard
            let currentPattern: NSRegularExpression = try? self.regexWithPattern(pattern)
            else { throw PhoneNumberError.generalError }
        return currentPattern.matches(in: String(string))
    }
    
    func phoneDataDetectorMatch(_ string: String) throws -> NSTextCheckingResult {
        guard
            let fallBackMatches = try? regexMatches(PhoneNumberPatterns.validPhoneNumberPattern, string: string),
            let firstMatch: NSTextCheckingResult = fallBackMatches.first
            else { throw PhoneNumberError.notANumber }
        return firstMatch
    }

    // MARK: Match helpers
    
    func matchesAtStart(_ pattern: String, string: String) -> Bool {
        let matches: [NSTextCheckingResult]? = try? regexMatches(pattern, string: string)
        return ( matches?.filter { $0.range.location == 0}.count ?? 0) == 0 ? false : true
    }
    
    func stringPositionByRegex(_ pattern: String, string: String) -> Int {
        let matches: [NSTextCheckingResult]? = try? regexMatches(pattern, string: string)
        return matches?.first?.range.location ?? -1
    }
    
    func matchesExist(_ pattern: String?, string: String) -> Bool {
        guard
            let pattern: String = pattern,
            let matches: [NSTextCheckingResult] = try? regexMatches(pattern, string: string)
            else { return false }
        
        return matches.count > 0
    }

    
    func matchesEntirely(_ pattern: String?, string: String) -> Bool {
        return pattern == nil ? false : matchesExist("^(\(pattern!))$", string: string)
    }
    
    func matchedStringByRegex(_ pattern: String, string: String) throws -> [String] {
        guard let matches: [NSTextCheckingResult] = try? regexMatches(pattern, string: string) else { return [] }
        return matches.map { string.substring(with: $0.range) }
    }
    
    // MARK: String and replace
    
    func replaceStringByRegex(_ pattern: String, string: String, template: String = "") -> String {
        guard let regex: NSRegularExpression = try? regexWithPattern(pattern) else { return string }
        let matches: [NSTextCheckingResult] = regex.matches(in: string)
        if ( matches.count == 1 ) {
            let range: Range<String.Index>? = regex.rangeOfFirstMatch(in: string)
            return range == nil ? string : regex.stringByReplacingMatches(in: string, options: [], range: range, withTemplate: template)
        } else if ( matches.count > 1 ) {
            return regex.stringByReplacingMatches(in: string, withTemplate: template)
        }
        return string
    }
    
    func replaceFirstStringByRegex(_ pattern: String, string: String, templateString: String) -> String {
        guard let regex: NSRegularExpression = try? regexWithPattern(pattern) else { return "" }
        guard let range: Range<String.Index> = regex.rangeOfFirstMatch(in: string) else { return string }
        return regex.stringByReplacingMatches(in: string, options: [], range: range, withTemplate: templateString)
    }
    
    func stringByReplacingOccurrences(_ string: String, map: [String:String]) -> String {
        
        var targetString: String = ""
        string.map { String($0).uppercased() }.forEach {
            if let mappedValue = map[$0] { targetString.append(mappedValue) }
        }
        return targetString
    }
    
    // MARK: Validations
    
    func hasValue(_ value: String?) -> Bool {
        guard
            let valueString: String = value,
            valueString.trimmingCharacters(in: spaceCharacterSet).count != 0
            else { return false }
        return true
    }
    
    func testStringLengthAgainstPattern(_ pattern: String, string: String) -> Bool {
        return matchesEntirely(pattern, string: string) ? true : false
    }
    
}



// MARK: Extensions

extension String {
    
    func substring(from: Int) -> String {
        let start = index(startIndex, offsetBy: from)
        return String(self[start ..< endIndex])
    }
    
    func substring(to: Int) -> String {
        let end = index(startIndex, offsetBy: to)
        return String(self[startIndex ..< end])
    }

    func substring(with range: NSRange) -> String {
        return (self as NSString).substring(with: range)
    }
}



