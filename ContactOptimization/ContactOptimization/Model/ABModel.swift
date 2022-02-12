//
//  ABModel.swift
//  ContactOptimization
//
//  Created by Ankur Prakash on 06/02/22.
//

import Foundation

public typealias Line = String
public extension ABModel {
    enum ContactType: Equatable {
         case mapped(_ prxId: String, _ deviceId: String)
         case device(_ deviceId: String)
         case prx(_ prxId: String)
         case unknown
         case addedWhenSyncOff

        public static func == (lhs: ContactType, rhs: ContactType) -> Bool {
            switch (lhs, rhs) {
            case (.prx, .prx):
                return true
            case (.device, .device):
                return true
            case (.unknown, .unknown):
                return true
            case (let .mapped(p1,d1), let .mapped(p2, d2)):
                guard p1 == p2, d1 == d2 else {
                    return false
                }
                return true
            case (.addedWhenSyncOff, .addedWhenSyncOff):
                return true
            default:
                return false
            }
        }
    }

    enum ModelState {
        case update( UpdationStatus)
        case delete( DeletionStatus)
    }
}

public extension ABModel.ContactType {
    var extractPrxAndDeviceId: (prxId: String, deviceId: String) {
        let empty = ""
        switch self {
            case let .prx(prxId):
                return (prxId: prxId, deviceId: empty)
            case let .device(deviceId):
                return (prxId: empty, deviceId: deviceId)
            case let .mapped(args):
                return (prxId: args.0, deviceId: args.1)
            case .unknown, .addedWhenSyncOff:
                return (prxId: empty, deviceId: empty)
        }
    }

    static func getType(prxId: String, deviceId: String) -> ABModel.ContactType {
        let type: ABModel.ContactType

        if !prxId.isEmpty && !deviceId.isEmpty {
            type = .mapped(prxId, deviceId)
        }
        else if !deviceId.isEmpty {
            type = .device(deviceId)
        }else if !prxId.isEmpty {
            type = .prx(prxId)
        } else {
            type = .unknown
        }
        return type
    }
}

public struct ABModel {
    public let id: String
    public var nameModel: ContactNameModel
    public var type: ContactType
    public var lines: [NewLine]
    public var state: ModelState
    public var isEnterprise: Bool
    public var isFavourite: Bool
    public var imageData: Data?
    public var hashTag: String = ""
    public var nativeContactPicName: String = ""
    public var nonRcsImagePath: String?

    public var isRCSContact = false
    public var isModelBehaveAsRcs = false
    public var rcsLines = [NewLine]()
    public var nonRcsLines = [NewLine]()
    public var modelDisplayName: String = ""
    public var profilePicUrl: String?
    public let groupContactIDs: [String]
    public var contactDetails : ContactDetailModel
    public var prxNameIfExist : Bool


    public init(id: String,
                nameModel: ContactNameModel,
                type: ContactType,
                lines: [NewLine],
                isFavourite: Bool,
                state: ModelState,
                hashTag: String,
                imageData: Data?,
                isEnterprise: Bool,
                nativeContactPicName: String,
                groupContactIDs: [String],
                contactDetails: ContactDetailModel,
                prxNameIfExist: Bool) {
        self.id = id
        self.nameModel = nameModel
        self.type = type
        self.lines = lines
        self.isFavourite = isFavourite
        self.state = state
        self.hashTag = hashTag
        self.imageData = imageData
        self.isEnterprise = isEnterprise
        self.groupContactIDs = groupContactIDs
        self.contactDetails = contactDetails
        self.nativeContactPicName = nativeContactPicName
        self.prxNameIfExist = false
        self.nonRcsImagePath = getNONRCSContactImagePath()
        var profilePicURLString: String?
        var firstBehavingRcsImageSet = false

        var firstRcsBehavingNonRcs: NewLine?
        lines.forEach {
            if $0.isBehavingRCS || $0.isRCSUser {
                if !$0.displayName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    self.prxNameIfExist = true
                }
            }

            if $0.isBehavingRCS {
                self.isModelBehaveAsRcs = true
                self.isRCSContact = true
                self.rcsLines.append($0)
                if !$0.picLocalURL.isEmpty && !firstBehavingRcsImageSet {
                    profilePicURLString = $0.picLocalURL
                    firstBehavingRcsImageSet = true
                }
            }
            else if $0.isRCSUser {
                if firstRcsBehavingNonRcs == nil {
                    firstRcsBehavingNonRcs = $0
                }
                 self.nonRcsLines.append($0) // the lines which are not behaving RCS will be nonrcs
                 self.isRCSContact = true
                if !$0.picLocalURL.isEmpty && profilePicURLString == nil {
                    profilePicURLString = $0.picLocalURL
                }
            } else {
                if !$0.picRemoteURL.isEmpty && !$0.picLocalURL.isEmpty && profilePicURLString == nil {
                    profilePicURLString = $0.picLocalURL
                }
                self.nonRcsLines.append($0)
            }
        }

        var contactDisplayName = nameModel.displayName
        var lineDisplayName = rcsLines.first?.displayName ?? ""
        let firstRcsBehavingAsNonRcsName = firstRcsBehavingNonRcs?.displayName ?? ""
        if contactDisplayName.isEmpty {
            if lineDisplayName.isEmpty {
                lineDisplayName = firstRcsBehavingAsNonRcsName.isEmpty ?  NumberKit.formattedLineForUI(lines.first?.line ?? "") : firstRcsBehavingAsNonRcsName
            }
            contactDisplayName = lineDisplayName
        }
        self.modelDisplayName = contactDisplayName.trimmingCharacters(in: .whitespacesAndNewlines)
        self.profilePicUrl = profilePicURLString != nil ? profilePicURLString : nonRcsImagePath
    }
}

extension ABModel: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(identity)
    }

    /* MSISDN_ISSUE_11: Added hashtag in Equitable*/
    public static func == (lhs: ABModel, rhs: ABModel) -> Bool {
        return lhs.id == rhs.id &&
            lhs.hashTag == rhs.hashTag &&
            lhs.isFavourite == rhs.isFavourite &&
            rhs.type == lhs.type   && // identity
            lhs.lines == rhs.lines &&
            lhs.nativeContactPicName == rhs.nativeContactPicName &&
            lhs.contactDetails ==  rhs.contactDetails
    }
}

public extension ABModel {
    func duplicate(withId newId: String) -> ABModel {
        return ABModel.init(id: newId, nameModel: nameModel, type: type, lines: lines, isFavourite: isFavourite, state: state, hashTag: hashTag, imageData: imageData, isEnterprise: isEnterprise, nativeContactPicName: nativeContactPicName, groupContactIDs: groupContactIDs, contactDetails: contactDetails, prxNameIfExist: prxNameIfExist)
    }
}

public extension ABModel {
    func updateNameModel(_ nameModel: ContactNameModel) -> ABModel {
        return ABModel.init(id: id, nameModel: nameModel, type: type, lines: lines, isFavourite: isFavourite, state: state, hashTag: hashTag, imageData: imageData, isEnterprise: isEnterprise, nativeContactPicName: nativeContactPicName, groupContactIDs: groupContactIDs, contactDetails: contactDetails, prxNameIfExist: prxNameIfExist)
    }

    func updateLines(lines newLines:[NewLine]) -> ABModel {
        return ABModel.init(id: id, nameModel: nameModel, type: type, lines: newLines, isFavourite: isFavourite, state: state, hashTag: hashTag, imageData: imageData, isEnterprise: isEnterprise, nativeContactPicName: nativeContactPicName, groupContactIDs: groupContactIDs, contactDetails: contactDetails, prxNameIfExist: prxNameIfExist)
    }

    func updateContactType(_ newtype: ContactType) -> ABModel {
        return  ABModel.init(id: id, nameModel: nameModel, type: newtype, lines: lines, isFavourite: isFavourite, state: state, hashTag: hashTag, imageData: imageData, isEnterprise: isEnterprise, nativeContactPicName: nativeContactPicName, groupContactIDs: groupContactIDs, contactDetails: contactDetails, prxNameIfExist: prxNameIfExist)
    }

    func withFavoriteStatus(_ modifiedFavorite: Bool) -> ABModel {
        return  ABModel.init(id: id, nameModel: nameModel, type: type, lines: lines, isFavourite: modifiedFavorite, state: state, hashTag: hashTag, imageData: imageData, isEnterprise: isEnterprise, nativeContactPicName: nativeContactPicName, groupContactIDs: groupContactIDs, contactDetails: contactDetails, prxNameIfExist: prxNameIfExist)
    }

    func updateModelState(_ newState: ModelState) -> ABModel {
        return ABModel.init(id: id, nameModel: nameModel, type: type, lines: lines, isFavourite: isFavourite,
                            state: newState, hashTag: hashTag, imageData: imageData,
                            isEnterprise: isEnterprise, nativeContactPicName: nativeContactPicName, groupContactIDs: groupContactIDs, contactDetails: contactDetails, prxNameIfExist: prxNameIfExist)
    }

    func updateHashTag() -> ABModel {
        return  ABModel.init(id: id, nameModel: nameModel, type: type, lines: lines,
                             isFavourite: isFavourite, state: state, hashTag: getHashTag,
                             imageData: imageData, isEnterprise: isEnterprise,
                             nativeContactPicName: nativeContactPicName, groupContactIDs: groupContactIDs, contactDetails: contactDetails, prxNameIfExist: prxNameIfExist)
    }

    func updateWithImageData(_ newImgData: Data) -> ABModel {
        return  ABModel.init(id: id, nameModel: nameModel, type: type, lines: lines, isFavourite: isFavourite,
                             state: state, hashTag: getHashTag, imageData: newImgData,
                             isEnterprise: isEnterprise, nativeContactPicName: nativeContactPicName, groupContactIDs: groupContactIDs, contactDetails: contactDetails, prxNameIfExist: prxNameIfExist)
    }
}

public extension ABModel {
     func mergeLines(dbModel: ABModel) -> [NewLine] {
        var dbLineDict = [Line: NewLine]()
        dbModel.lines.forEach {dbLineDict[$0.lineComparer] = $0}

        var updatedLine: NewLine!
        var updatedLines = [NewLine]()

        lines.forEach {
            if let dBNewLine = dbLineDict[$0.lineComparer] {
                let newLineModel = NewLine.LineModel(line: $0.line, lineType: $0.lineType)
                updatedLine = NewLine.create(with: $0.id, lineModel: newLineModel)
                updatedLine = updatedLine.extractDetails(fromUnknownLine: dBNewLine)
                if !$0.displayName.isEmpty {
                    updatedLine.displayName = $0.displayName
                }
            } else {
                updatedLine = $0
            }
            updatedLines.append(updatedLine)
        }
        return updatedLines
    }
}


public extension ABModel {
    static func create(with line: Line) -> ABModel {
        let newLine = NewLine.create(with: UUID().uuidString,
                                     lineModel: NewLine.LineModel(line: line, lineType: .mobile))
        let nameModel = ContactNameModel.empty()
        return ABModel(id: UUID().uuidString, nameModel: nameModel, type: .unknown, lines: line.isEmpty ? []:[newLine], isFavourite: false, state: .update(.unsync), hashTag: "", imageData: nil, isEnterprise: false, nativeContactPicName: "", groupContactIDs: [],contactDetails: ContactDetailModel.empty(), prxNameIfExist: false)
    }

    static func asUnknown(id: String, lines: [NewLine]) -> ABModel {
        var abModel =  ABModel(id: id, nameModel: ContactNameModel.empty(), type:  .unknown, lines: lines, isFavourite: false, state: .update(.updated), hashTag: "", imageData: nil, isEnterprise: false, nativeContactPicName: "", groupContactIDs: [], contactDetails: ContactDetailModel.empty(), prxNameIfExist: false)
        abModel.hashTag = abModel.getHashTag
        return abModel
    }
}

// MARK:- Helpers
public extension ABModel {
    var rcsLinesCount: Int {
        return rcsLines.count
    }

    var firstRcsNewLine : NewLine? {
        return rcsLines.first
    }

    // this method will provide firstRcsLine timestamp saved in DB
    var lastTimeStamp: String {
        return firstRcsNewLine?.prxUpdateTimeStamp ?? ""
    }

    private func getNONRCSContactImagePath() -> String? {
        let deviceContactID = self.getPrxAndDeviceID.deviceId
        let imageId = deviceContactID.isEmpty ? id: deviceContactID
        let path: String? = ""
        guard let folderPath = path, !imageId.isEmpty else { return nil }
        return "\(folderPath)/\(getUniqueNonRCSImageFileName())"
    }
}


extension ABModel: Identifiable {
    public var identity: String {
        switch self.type {
            case let .mapped(prxId, deviceId):
                return "\(prxId)_\(deviceId)"
            case let .prx(prxId):
                return "\(prxId)_"
            case let .device(deviceId):
                return "_\(deviceId)"
            case .unknown, .addedWhenSyncOff:
                return id
        }
    }
}

// MARK:-  Helper for User Model
// FIX_ME: Consider to be removed later
public extension ABModel {
    var getPrxAndDeviceID: (prxId: String, deviceId: String) {
        return type.extractPrxAndDeviceId
    }
}

// QWorst code possible
public extension ABModel {
    func updateNativeContactPicName( _ picName: String) -> ABModel {
        return  ABModel.init(id: id, nameModel: nameModel, type: type, lines: lines,
                             isFavourite: isFavourite, state: state,
                             hashTag: getHashTag, imageData: imageData, isEnterprise: isEnterprise,
                             nativeContactPicName: picName, groupContactIDs: groupContactIDs, contactDetails: contactDetails, prxNameIfExist: prxNameIfExist)
    }
}


public extension ABModel {
    func getUniqueNonRCSImageFileName() -> String {
        let combinedId = getPrxAndDeviceID
        if let contactId = combinedId.deviceId.components(separatedBy: ":").first,
            !contactId.isEmpty {
            return "\(contactId).jpeg"
        }
        // SYNC_CONTACT FIX:
        let name = combinedId.deviceId.isEmpty ? id : combinedId.deviceId
        // print("ABMOdel image name = \(name)")
        return "\(name).jpeg"
    }
}

public extension ABModel {
    var isUnknown: Bool {
        return (lines.count == 1) && id == UniqueMsisdn._(lines.first?.line ?? "")
    }
}


public extension ABModel {
    var prxIdentification: String {
        let combined =  type.extractPrxAndDeviceId
        let nonPrxModelIdentification = !combined.deviceId.isEmpty ? combined.deviceId : id
        return !combined.prxId.isEmpty ? combined.prxId : nonPrxModelIdentification
    }
}


public extension Array where Element == String {
    func getStringIgnoringEmpty(with seperator: String) -> String {
        var fullName = ""
        self.forEach {
            if !$0.isEmpty {
                if !fullName.isEmpty { fullName.append(seperator) }
                fullName.append($0)}
            }
        return fullName
    }

     var getName: String {
        // String("\u{0020}")
        let singleSpace = " "
        return getStringIgnoringEmpty(with: singleSpace)
    }

     func getName(for local: String) -> String {
        if local == "ja" {
            let reverseList = self.reversed()
            return  Array(reverseList).getName
        }
        return getName
    }

    var getNameByLocale: String {
        let locale = Locale.current.languageCode ?? "en"
        if locale == "ja" {
            let reverseList = self.reversed()
            return  Array(reverseList).getName
        }
        return getName
    }
}
