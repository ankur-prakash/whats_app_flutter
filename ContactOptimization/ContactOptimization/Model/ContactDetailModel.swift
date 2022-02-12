//
//  ContactDetailModel.swift
//  ContactOptimization
//
//  Created by Ankur Prakash on 06/02/22.
//

import Foundation

public struct ContactDetailModel {
    public var detailsInfo  =  [String: Any]()
    public typealias getContactDetailInfoOutput = ([EmailModel], [AddressModel], BirthDayModel?)
    public init (detailsInfo : [String: Any] ){
        self.detailsInfo = detailsInfo
    }
    public static func == (lhs: ContactDetailModel, rhs: ContactDetailModel) -> Bool {
        return lhs.detailsInfo["details"] as? [String:[[String: String]]] == rhs.detailsInfo["details"] as? [String: [[String:String]]]
    }

    public  static func empty() -> ContactDetailModel {
        let detailsInfo  =  [String: Any]()
        return ContactDetailModel.init(detailsInfo: detailsInfo)
    }

    public static func getContactDetailInfo(contactDetailModelInfo:ContactDetailModel)
        -> getContactDetailInfoOutput {
            var contactDetailAddressList = [AddressModel]()
            var contactDetailEmailList = [EmailModel]()
            var birthDayModel : BirthDayModel?
            if let contactDetails = contactDetailModelInfo.detailsInfo["details"] as? [String: [[String:String]]] {
                if let emailList = contactDetails[Category.email.rawValue] {
                    for emailModel in emailList {
                        let emailDetailModel = EmailModel.init(emailType: emailModel[EmailKey.type.rawValue] ?? "", emailValue: emailModel[EmailKey.mailId.rawValue] ?? "")
                        contactDetailEmailList.append(emailDetailModel)
                    }
                }

                if let addressList = contactDetails[Category.postalAddress.rawValue] {
                    for addressModel in addressList {
                        let addressDetailModel = AddressModel.init(addressType: addressModel[AddressKey.type.rawValue] ?? "", addressValue: addressModel[AddressKey.address.rawValue] ?? "")
                        contactDetailAddressList.append(addressDetailModel)
                    }
                }
                if let dobModel  = contactDetails[Category.dateOfBirth.rawValue]?.first,
                    let type = dobModel["type"], let value = dobModel["value"], !value.isEmpty {
                    birthDayModel = BirthDayModel.init(birthDayKey: type,
                                                       birthDayValue: value)
                }
            }
            return (contactDetailEmailList, contactDetailAddressList, birthDayModel)
        }
}

public extension ContactDetailModel {
    enum Category: String {
        case dateOfBirth = "date-of-birth"
        case email = "email"
        case postalAddress = "postal-address"
    }

    enum LabelType: String {
        case home
        case work
        case other
    }

    enum AddressKey: String {
        case type
        case address
    }

    enum EmailKey: String {
        case type = "type"
        case mailId = "mail-id"
    }
}

public extension ContactDetailModel {
    struct EmailModel {
        public var emailType : String
        public var emailValue : String

        init(emailType: String, emailValue: String) {
            self.emailType = emailType
            self.emailValue = emailValue
        }
    }

    struct BirthDayModel {
        public var birthDayKey : String
        public var birthDayValue : String

        init(birthDayKey:String, birthDayValue: String) {
            self.birthDayKey = birthDayKey
            self.birthDayValue = birthDayValue
        }
    }


    struct AddressModel {
        public var addressType : String
        public var addressValue : String

        init(addressType: String, addressValue: String) {
            self.addressType = addressType
            self.addressValue = addressValue
        }
    }
}


public extension ContactDetailModel  {
    static func convertContactDetailToJson(detailInfo : [String: Any]) -> String? {
        print("detailInfo \(detailInfo)")
        if let jsonData = try? JSONSerialization.data(withJSONObject: detailInfo, options: .prettyPrinted) {
            if let jsonString = String(data: jsonData, encoding: .utf8) {
                // print("JSON string \(jsonString)")
                return jsonString
            }
        }
        // print("return nil")
        return nil
    }

    static func  convertToDictionary(text: String) -> [String: Any]? {
        if let data = text.data(using: .utf8) {
            do {
                let result = try JSONSerialization.jsonObject(with: data, options: [])
                    as? [String: Any]
                // print("result \(String(describing: result))")
                return result
            } catch {
                print(error.localizedDescription)
            }
        }
        // print("return nil")
        return nil
    }
}
