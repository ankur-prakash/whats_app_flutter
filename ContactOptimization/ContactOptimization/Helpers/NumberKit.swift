//
//  NumberKit.swift
//  ContactOptimization
//
//  Created by Ankur Prakash on 07/02/22.
//

import Foundation
import PhoneNumberKit

public class NumberKit {
    public static let sharedInstance = PhoneNumberKit()
    init() {
    }
}

public extension PhoneNumberKit {
    func isValidNumberWithCountryCode(_ number: String) -> Bool {
        if number.count > 10 {
            return true
        } else { return false }
    }

    func returnFormattedNumber(number: String) -> String {
        if (self.isValidNumberWithCountryCode(number) == false) {
            do {
                if number.contains("*") || number.contains("#") {   // *123# any # or *
                    return number
                } else {
                    let phoneNumber = try NumberKit.sharedInstance.parse(number)  // 9463952542 || 09463952542 -> phonenumber kit if error -> as it is ELSE format ->  +91 9463 952542
                   // print(phoneNumber,"isValidNumberWithCountryCode  not phonenumber NumberKit.sharedInstance.parse")
                    let numberKitFormat = NumberKit.sharedInstance.format(phoneNumber, toType: .international)   // +1 946352542 -> phonenumber kit - > +1 946-395-2542
                   // print(numberKitFormat,"isValidNumberWithCountryCode not phonenumber NumberKit.sharedInstance.format")
                    if !numberKitFormat.hasSuffix(UniqueMsisdn._(number)) {
                        return number
                    } else {
                        return numberKitFormat
                    }
                }
            }
            catch { return number }
        } else {
            do {
                let phoneNumber = try NumberKit.sharedInstance.parse(number)
                // print(phoneNumber,"isValidNumberWithCountryCode phonenumber NumberKit.sharedInstance.parse")
                if phoneNumber.countryCode == 81 {                    // +819463952542 ||  819463952542 -> phonenumber kit -> 094-6395-2542
                    return removeCountryCode(number: phoneNumber)
                } else {
                    let numberKitFormat = NumberKit.sharedInstance.format(phoneNumber, toType: .international)   // +1 946352542 -> phonenumber kit - > +1 946-395-2542
                  //  print(numberKitFormat,"isValidNumberWithCountryCode not phonenumber NumberKit.sharedInstance.format")
                    if !numberKitFormat.hasSuffix(UniqueMsisdn._(number)) {
                        return number
                    } else {
                        return numberKitFormat
                    }
//                    return NumberKit.sharedInstance.format(phoneNumber, toType: .international)   // +1 946352542 -> phonenumber kit - > +1 946-395-2542
                }
            }
            catch { return number }
        }
    }

    func removeCountryCode(number: PhoneNumber) -> String {
        let getLocalNumber = NumberKit.sharedInstance.format(number, toType: .international)
        if getLocalNumber.range(of: "NA") != nil {
            return number.numberString
        }
        return getLocalNumber.replacingOccurrences(of: "+\(number.countryCode) ", with: "0")
    }

    func getFormattedNumber(number: String) -> String {
        do {
            let phoneNumber = try NumberKit.sharedInstance.parse(number)
            let numberDisplayed = NumberKit.sharedInstance.format(phoneNumber, toType: .international)
            return numberDisplayed.cleanNumberExceptSpecialCharacters()
        }
        catch {
            return number
        }
    }

    func formatNumberManually(phoneNumber: String) -> String {
        return String(format: "%@-%@-%@",
                      String(phoneNumber[phoneNumber.index(phoneNumber.startIndex, offsetBy: 0)..<phoneNumber.index(phoneNumber.startIndex, offsetBy: 3)]),
                      String(phoneNumber[phoneNumber.index(phoneNumber.startIndex, offsetBy: 3) ..< phoneNumber.index(phoneNumber.startIndex, offsetBy: 7)]),
                      String(phoneNumber[phoneNumber.index(phoneNumber.startIndex, offsetBy: 7) ..< phoneNumber.index(phoneNumber.startIndex, offsetBy: 11)]))
    }
}
public extension NumberKit {
    static func formattedLineForUI(_ line: String) -> String {
        let phonenumber = line.removeAnyTel()
        let phoneNumberformatted = phonenumber.countryCodeFormattedForAddContact()
        let numberKitFormat = NumberKit.sharedInstance.returnFormattedNumber(number: phoneNumberformatted).removeCountryCode()
        return numberKitFormat
    }
}

public extension String {
    
    func removeCountryCode() -> String {
        if self.hasPrefix("+81") {
            return String(self.dropFirst(3))
        }else if(self.hasPrefix("81")),self.count == 12 {
            return String(self.dropFirst(2))
        }
        return self
    }
    
    func cleanNumberExceptSpecialCharacters() -> String {
        return self.replacingOccurrences(of: "[^0-9+*#]",
                                         with: "",
                                         options: .regularExpression)
    }
}
