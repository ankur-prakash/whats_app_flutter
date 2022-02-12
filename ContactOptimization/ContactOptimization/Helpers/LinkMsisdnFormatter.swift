//
//  File.swift
//  ContactOptimization
//
//  Created by Ankur Prakash on 06/02/22.
//

import Foundation

public typealias UniqueMsisdn = LinkMsisdnFormatter

public final class LinkMsisdnFormatter {
    // Currently app is considering 10 digit numbers Only for operation.
    private static let msidnNumberOfDigits = 9
    // helper
    public static func `_` (_ number: String) -> String {
        LinkMsisdnFormatter.compareValue(of: number)
    }

    public static func compareValue(of number: String) -> String {
        let phoneNumber = number.removeUnwantedCharacters()
        guard phoneNumber.count > msidnNumberOfDigits else {
            if phoneNumber.hasPrefix("+") {
                guard !Restricted186_184.is186_184Prefix(phoneNumber) else {
                                    return phoneNumber
                                }
                return String(phoneNumber.dropFirst())}
            if phoneNumber.hasPrefix("0") { return String(phoneNumber.dropFirst())}
            return number
        }

        if let prefix = ["0", "+81", "81"].first(where: phoneNumber.hasPrefix) {
            let value = String(phoneNumber.deletingNumberPrefix(prefix))
            if value.count == 10 || value.count == 9 {
                return value
            }
        }

        if phoneNumber.hasPrefix("+") {
            guard !Restricted186_184.is186_184Prefix(phoneNumber) else {
                                return phoneNumber
                            }
            return String(phoneNumber.dropFirst()) }
        if phoneNumber.hasPrefix("0") { return String(phoneNumber.dropFirst())}

        return phoneNumber
    }
}

fileprivate extension String {
    func removeUnwantedCharacters() -> String {
        return self.replacingOccurrences(of: "uid:", with: "")
            .replacingOccurrences(of: "sip:", with: "")
            .replacingOccurrences(of: "tel:", with: "")
            .replacingOccurrences(of: " ", with: "")
            .replacingOccurrences(of: "-", with: "")
    }
}

private extension String {
    func deletingPrefix(_ prefix: String) -> String {
        guard self.hasPrefix(prefix) else { return self }
        return String(self.dropFirst(prefix.count))
    }
}

private struct Restricted186_184 {
    static func is186_184Prefix(_ phoneNumber: String) -> Bool {
        let prefixSet = Set(["+186", "+184"])
        return prefixSet.first(where: { phoneNumber.hasPrefix($0) }) != nil
    }
}

public extension String {
    
    func stripedNonNumneric(exclude: String) -> String {
        let allowedCharset = CharacterSet.decimalDigits.union(CharacterSet(charactersIn: exclude))
        return String(self.unicodeScalars.filter(allowedCharset.contains))
    }
    
    func removeAnyTel() -> String {
        return self.replacingOccurrences(of: "tel:", with: "")
    }
    
    func countryCodeFormattedForAddContact() -> String {
        var countryCode = "+81"
        let countryName = UserDefaults.standard.string(forKey: "SelectedCountry")
        if countryName?.lowercased() == "india" {
            countryCode = "+91"
        }

        if !hasPrefix("0") && count == 9 {
            return self.hasPrefix(countryCode) ?  "\(self)"  : "\(countryCode)\(self)"
        } else if hasPrefix("0") && count == 10 {
            let formatString = "\(deletingNumberPrefix("0"))"
            return "\(countryCode)\(formatString)"
        } else if hasPrefix("810") && count == 12 {
            let formatString = "\(deletingNumberPrefix("810"))"
            return "\(countryCode)\(formatString)"
        } else if hasPrefix("+810") && count == 13 {
            let formatString = "\(deletingNumberPrefix("+810"))"
            return "\(countryCode)\(formatString)"
        } else if hasPrefix("81") && count == 11 {
            return "\("+")\(self)"
        } else if hasPrefix("81") && count == 12 {
            return "\("+")\(self)"
        } else if hasPrefix("91") && count == 12 {
            return "\("+")\(self)"
        } else if hasPrefix("0") &&  count == 11 {
            return "\(countryCode)\(self.deletingNumberPrefix("0"))"
        } else if count == 10 && !hasPrefix("+") {
            return "\(countryCode)\(self)"
        } else if hasPrefix("+81") || hasPrefix("+91") {
            return "\(self)"
        } else {
            return self.removeAnyTel()
        }
    }
    
    func deletingNumberPrefix(_ prefix: String) -> String {
        guard self.hasPrefix(prefix) else { return self }
        return String(self.dropFirst(prefix.count))
    }
}
