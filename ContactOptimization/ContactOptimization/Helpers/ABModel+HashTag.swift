//
//  ABModel+HashTag.swift
//  ModulesUtils
//
//  Created by Ankur Prakash on 03/06/20.
//  Copyright © 2020 Mavenir Systems. All rights reserved.
//

import Foundation
import Contacts

private enum NameHashKey: String {
    case givenName = "GN"
    case middleName = "MN"
    case familyName = "FN"
    case phoneticName = "PN"
    case dateOfBirth = "dob"
}

public extension CNContact {
    var lines: [String] {
        if isKeyAvailable(CNContactPhoneNumbersKey) {
            return phoneNumbers.compactMap {
                let value = $0.value.stringValue.stripedNonNumneric(exclude: "+*#")
                guard !value.isEmpty else {return nil}
                return value
            }
        }

        return []
    }

    var getHashTag: String {
        var attributeDict  = [String: String]()
        var contactAddressList = [[String:String]]()
        var contactDob  = ""
        if isKeyAvailable(CNContactFamilyNameKey) {
            attributeDict[NameHashKey.familyName.rawValue] = familyName
        }
        if isKeyAvailable(CNContactGivenNameKey) {
            attributeDict[NameHashKey.givenName.rawValue] = givenName
        }
        if isKeyAvailable(CNContactMiddleNameKey) {
            attributeDict[NameHashKey.middleName.rawValue] = middleName
        }

        if isKeyAvailable(CNContactPhoneticGivenNameKey) {
            attributeDict["pFirst"] = phoneticGivenName
        }
        if isKeyAvailable(CNContactPhoneticMiddleNameKey) {
            attributeDict["pMiddle"] = phoneticMiddleName
        }
        if isKeyAvailable(CNContactPhoneticFamilyNameKey) {
            attributeDict["pLast"] = phoneticFamilyName
        }

        let phoneticName =  ["pLast", "pMiddle", "pFirst"]
            .compactMap {attributeDict[$0]}.getName

        attributeDict[NameHashKey.givenName.rawValue] = givenName
        attributeDict[NameHashKey.middleName.rawValue] = middleName
        attributeDict[NameHashKey.familyName.rawValue] = familyName
        attributeDict[NameHashKey.phoneticName.rawValue] = phoneticName

        var homeList = [String]()
        var workList = [String]()
        var othersList = [String]()
        var mobileList = [String]()

        if isKeyAvailable(CNContactPhoneNumbersKey) {
            phoneNumbers.forEach { (phoneNumber) in
                var value = phoneNumber.value.stringValue.stripedNonNumneric(exclude: "+*#")
                guard !value.isEmpty else {return}
                value = UniqueMsisdn._(value)
                let label = phoneNumber.label ?? "mobile"

                switch label {
                case CNLabelHome: homeList.append(value)
                case CNLabelWork: workList.append(value)
                case CNLabelOther: othersList.append(value)
                case CNLabelPhoneNumberMobile: mobileList.append(value)
                default:
                    mobileList.append(value)
                }

                if isKeyAvailable(CNContactEmailAddressesKey) {
                    emailAddresses.forEach { (email) in
                        let value = email.value as String
                        guard !value.isEmpty else {return}
                        let label = email.label ?? "other"
                        switch label {
                        case CNLabelHome: homeList.append(value)
                        case CNLabelWork: workList.append(value)
                        case CNLabelOther: othersList.append(value)
                        default:
                            othersList.append(value)
                        }
                    }
                }

                if isKeyAvailable(CNContactPostalAddressesKey) {
                    contactAddressList = self.postalAddresses
                        .compactMap {CNContact.parsecontactDetailsForPostalAddress($0)}
                    for contactDict in contactAddressList {
                        if let label  =  contactDict[ContactDetailModel.AddressKey.type.rawValue]{
                            if label == "home" {
                                homeList.append(contactDict[ContactDetailModel.AddressKey.address.rawValue] ?? "")
                            }else if label == "work" {
                                workList.append(contactDict[ContactDetailModel.AddressKey.address.rawValue] ?? "")
                            }
                            else{
                                othersList.append(contactDict[ContactDetailModel.AddressKey.address.rawValue] ?? "")
                            }
                        }
                    }
                }

                if isKeyAvailable(CNContactBirthdayKey) {
                    let formatter = DateFormatter()
                    if let dobValue = self.birthday?.date, let year = self.birthday?.year {
                        formatter.dateFormat = "yyyy-MM-dd"
                        let stringDate = formatter.string(from: dobValue)
                        contactDob = stringDate
                    }else if let dobValue = self.birthday?.date{
                        formatter.dateFormat = "--MM-dd"
                        let stringDate = formatter.string(from: dobValue)
                        contactDob = stringDate
                    }
                }

                let lineTypes: [NewLine.DeviceLineModelType] = [.home, .work, .mobile, .other]

                lineTypes.forEach {
                    let list: [String]
                    switch $0 {
                    case .home:
                        list = homeList
                    case .work:
                        list = workList
                    case .mobile:
                        list = mobileList
                    case .other:
                        list = othersList
                    }
                    attributeDict[String($0.rawValue.prefix(1))] = list.sorted().joined(separator: ":")
                }
            }
        }
        if !contactDob.isEmpty {
            attributeDict[NameHashKey.dateOfBirth.rawValue] = contactDob
        }
        return attributeDict.generateHashTag(with: ":")
    }
}


public extension ABModel {
    var getHashTag: String {
        var attributeDict  = [String: String]()
        if !nameModel.firstName.isEmpty {
            attributeDict[NameHashKey.givenName.rawValue] = nameModel.firstName
        }
        if !nameModel.middleName.isEmpty {
            attributeDict[NameHashKey.middleName.rawValue] = nameModel.middleName
        }
        if !nameModel.lastName.isEmpty {
            attributeDict[NameHashKey.familyName.rawValue] = nameModel.lastName
        }
        if !nameModel.phoneticFullName.isEmpty {
            attributeDict[NameHashKey.phoneticName.rawValue] = nameModel.phoneticFullName
        }

        var homeList = [String]()
        var workList = [String]()
        var othersList = [String]()
        var mobileList = [String]()

        lines.forEach {
            let formattedNumber = UniqueMsisdn._($0.line)
            switch $0.lineType {
            case .home: homeList.append(formattedNumber)
            case .work: workList.append(formattedNumber)
            case .mobile: mobileList.append(formattedNumber)
            case .other: othersList.append(formattedNumber)
            }
        }
       let result = ContactDetailModel.getContactDetailInfo(contactDetailModelInfo: self.contactDetails)
        if result.0.count > 0 {
            for model in result.0{
                if model.emailType == ContactDetailModel.LabelType.home.rawValue {
                    homeList.append(model.emailValue)
                }
                else if model.emailType == ContactDetailModel.LabelType.work.rawValue {
                    workList.append(model.emailValue)
                }
                else {
                    othersList.append(model.emailValue)
                }
            }
        }

        if result.1.count > 0 {
            for model in result.1 {
                if model.addressType == ContactDetailModel.LabelType.home.rawValue {
                    homeList.append(model.addressValue)
                }
                else if model.addressValue == ContactDetailModel.LabelType.work.rawValue {
                    workList.append(model.addressValue)
                }
                else {
                    othersList.append(model.addressValue)
                }
            }
        }


        let lineTypes: [NewLine.DeviceLineModelType] = [.home, .work, .mobile, .other]

        lineTypes.forEach {
            let list: [String]
            switch $0 {
            case .home:
                list = homeList
            case .work:
                list = workList
            case .mobile:
                list = mobileList
            case .other:
                list = othersList
            }
            attributeDict[String($0.rawValue.prefix(1))] = list.sorted().joined(separator: ":")
        }

        if let dobModel = result.2 {
            attributeDict[NameHashKey.dateOfBirth.rawValue] = dobModel.birthDayValue
        }
        return attributeDict.generateHashTag(with: ":")
    }
}

fileprivate extension Dictionary where Key == String, Value == String {
    func generateHashTag(with seperator: String) -> String {
        let sortedKeys = keys.sorted()
        return sortedKeys.reduce("") { (result, key) -> String in
            guard let value = self[key], !value.isEmpty else { return result }
            let nextValue = "\(key + seperator + value)"
            guard !result.isEmpty else { return nextValue }
            return result + seperator + nextValue
        }.lowercased()
    }
}

public extension CNContact {
    static func parsecontactDetailsForPostalAddress(_ address: CNLabeledValue<CNPostalAddress>) -> [String:String] {
        var modelType = NewLine.DeviceLineModelType.other
        switch address.label {
        case CNLabelHome: modelType = .home
        case CNLabelWork: modelType = .work
        case CNLabelPhoneNumberMobile: modelType = .mobile
        default:
            modelType = .other
        }
        var street = ""
        var city = ""
        var state = ""
        var postalCode = ""
        var country = ""
        var attributeDict  = [String: String]()
        if let address = address.value as? CNPostalAddress {
            street = address.street
            city = address.city
            state = address.state
            postalCode = address.postalCode
            country = address.country
        }
        var postalAddress = ""
        if !street.isEmpty {
            postalAddress = street
        }
        if !city.isEmpty {
            postalAddress = "\(postalAddress),\(city)"
        }
        if !state.isEmpty {
            postalAddress = "\(postalAddress),\(state)"
        }
        if !country.isEmpty {
            postalAddress = "\(postalAddress),\(country)"
        }
        if !postalCode.isEmpty {
            postalAddress = "\(postalAddress),\(postalCode)"
        }
        if postalAddress.hasPrefix(","){
            postalAddress = String(postalAddress.dropFirst())
        }
        attributeDict[ContactDetailModel.AddressKey.type.rawValue] = modelType.rawValue
        attributeDict[ContactDetailModel.AddressKey.address.rawValue] =  postalAddress
        return attributeDict
    }
}
