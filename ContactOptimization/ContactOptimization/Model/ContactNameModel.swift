//
//  ContactNameModel.swift
//  ContactOptimization
//
//  Created by Ankur Prakash on 06/02/22.
//

import Foundation

public struct ContactNameModel {
    public let firstName: String
    /* as of now this attribute will contain Phonetic*/
    public let middleName: String
    public let lastName: String
    public let phoneticFullName: String

    public let phoneticFirstName: String
    public let phoneticMiddleName: String
    public let phoneticLastName: String

    public var displayName: String {
       return [firstName, middleName, lastName].getNameByLocale
    }

    public init(firstName: String, middleName: String,
                lastName: String, phoneticFullName: String) {
        self.firstName = firstName
        self.middleName = middleName
        self.lastName = lastName
        self.phoneticFullName = phoneticFullName
        self.phoneticFirstName = ""
        self.phoneticMiddleName = ""
        self.phoneticLastName = ""
    }

    public init(firstName: String, middleName: String, lastName: String,
                phoneticFullName: String,
                phoneticFirstName: String, phoneticMiddleName: String,
                phoneticLastName: String) {
        self.firstName = firstName
        self.middleName = middleName
        self.lastName = lastName
        self.phoneticFullName = phoneticFullName
        self.phoneticFirstName = phoneticFirstName
        self.phoneticMiddleName = phoneticMiddleName
        self.phoneticLastName = phoneticLastName
    }
}


public extension ContactNameModel {
    static func empty() -> ContactNameModel {
        return ContactNameModel(firstName: "", middleName: "", lastName: "",
                                phoneticFullName: "", phoneticFirstName: "",
                                phoneticMiddleName: "", phoneticLastName: "")
    }
}

public struct ContactShareModel {
    public let name: ContactNameModel
    public let lines: [NewLine]
    public let profilePicPath: String?

    public init(name: ContactNameModel, lines: [NewLine], profilePicPath: String?) {
        self.name = name
        self.lines = lines
        self.profilePicPath = profilePicPath
    }
}


public extension ContactNameModel {
    init(abModel: ABModel) {
        self.firstName = abModel.nameModel.firstName
        self.middleName = abModel.nameModel.middleName
        self.lastName = abModel.nameModel.lastName
        self.phoneticFullName = abModel.nameModel.phoneticFullName
        self.phoneticFirstName = ""
        self.phoneticMiddleName = ""
        self.phoneticLastName = ""
    }
}

public extension ContactNameModel {
    // on iOS name is send as lastname;firstname but android don't have concept
    // of semicolon(;)
    var nameForAndroid: String {
        return [firstName, middleName, lastName].getNameByLocale
    }
}

public extension ContactNameModel {
    typealias splitOutput = (String,String,String)

    static func split(name: String) -> splitOutput {
         let singleSpace = " "
         let twoSpace =  singleSpace + singleSpace
         let empty = String()
        guard !name.isEmpty else { return (empty, empty, empty)}
         // to avoid more than one space and space before first and after last
        let nameString = name.replacingOccurrences(of: twoSpace, with: singleSpace).trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)

         var components = nameString.components(separatedBy: singleSpace)
         var firstName = empty
         var lastName = empty

         if components.first != nil {
             firstName = components.removeFirst()
         }
         if components.last != nil {
              lastName = components.removeLast()
         }
         let middleName = components.joined(separator: singleSpace)
         return (firstName,middleName,lastName)
    }
}

public extension Locale {
    static func isJapaneseLocale() -> Bool {
        return Locale.current.languageCode == "ja"
    }
}
