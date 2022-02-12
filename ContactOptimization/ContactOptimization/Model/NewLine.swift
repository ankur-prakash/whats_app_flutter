//
//  NewLine.swift
//  ContactOptimization
//
//  Created by Ankur Prakash on 06/02/22.
//

import Foundation

public struct NewLine {
    public enum DeviceLineModelType : String {
        case home
        case work
        case mobile
        case other
    }

    public enum OnlineStatus: Int {
        case logout = 0
        case active = 1
    }

    public struct LineModel {
        public let line: String
        public let lineType: DeviceLineModelType

        public init(line: String, lineType: DeviceLineModelType) {
            self.line = line
            self.lineType = lineType
        }
    }

    public let id: String
    public let lineComparer: Line

    public var lineModel: LineModel
    public var parentABModelId: String
    public var displayName: String
    public var picRemoteURL: String
    public var picLocalURL: String
    public var prxUpdateTimeStamp: String
    public var presence: PresenceStatus
    public var download: DownloadStatus
    public var isRCSUser: Bool
    public var status: OnlineStatus
    public var deleteStatus: DeletionStatus

    public init(id: String,
                displayName: String,
                lineModel: LineModel,
                picRemoteURL: String,
                picLocalURL: String,
                prxUpdateTimeStamp: String,
                presence: PresenceStatus,
                download: DownloadStatus,
                isRCSUser: Bool,
                status: OnlineStatus,
                parentABModelId: String,
                deleteStatus: DeletionStatus) {
        self.id = id
        // self.parentType = parentType
        self.lineModel = lineModel
        self.picLocalURL = picLocalURL
        self.picRemoteURL = picRemoteURL
        self.isRCSUser = isRCSUser
        self.download = download
        self.presence = presence
        self.displayName = displayName
        self.prxUpdateTimeStamp = prxUpdateTimeStamp
        self.status = status
        //This makes o(n2)
        self.lineComparer = UniqueMsisdn._(lineModel.line)
        self.parentABModelId = parentABModelId
        self.deleteStatus = deleteStatus
    }
}


public extension NewLine {
    mutating func updateParentModelId(_ modelId: String) {
        self.parentABModelId = modelId
    }

    init?(parentABModelId: String,
          displayName: String,
          lineModel: LineModel, isRCS: Bool,
          presence: PresenceStatus = .completed) {
        guard !lineModel.line.isEmpty else { return nil}

        let newId = UUID().uuidString
        self = NewLine(id: newId, displayName: displayName, lineModel: lineModel,
                       picRemoteURL: "", picLocalURL: "", prxUpdateTimeStamp: "", presence: presence,
                       download: .completed, isRCSUser: isRCS, status: .active,
                       parentABModelId: parentABModelId, deleteStatus: .exist)
    }

    // Unknown contact will always be RCS and id will be UniqueMSISDN._(line)
    static func asUnknownLine(displayName: String,
                              lineModel: LineModel,
                              isRcs: Bool = false) -> NewLine {
        let unknownLineModel = LineModel.init(line: lineModel.line.countryCodeFormattedForAddContact(), lineType: .mobile)
        let newId = UniqueMsisdn._(lineModel.line)

        let newLine = NewLine.init(id: newId, displayName: displayName, lineModel: unknownLineModel,
                                   picRemoteURL: "", picLocalURL: "", prxUpdateTimeStamp: "",
                                   presence: .pending, download: .completed,
                                   isRCSUser: isRcs, status: .active, parentABModelId: newId,
                                   deleteStatus: .exist)

        return newLine
    }

    static func create(with id: String, lineModel: LineModel) -> NewLine {
        let newLine = NewLine.init(id: UUID().uuidString, displayName: "",
                                   lineModel: lineModel, picRemoteURL: "", picLocalURL: "", prxUpdateTimeStamp: "",
                                   presence: .completed, download: .completed, isRCSUser: false,  status: .active, parentABModelId: "", deleteStatus: .exist)

        return newLine
    }
}

// MARK:- Helpers
public extension NewLine {
    var line: String {
        return lineModel.line
    }

    var lineType: DeviceLineModelType {
        return lineModel.lineType
    }
}

public extension NewLine {
    func updateOnlineStatus(_ newStatus: OnlineStatus) -> NewLine {
        return NewLine(id: id, displayName: displayName, lineModel: lineModel,
                       picRemoteURL: picRemoteURL, picLocalURL: picLocalURL, prxUpdateTimeStamp: prxUpdateTimeStamp,
                       presence: presence, download: download, isRCSUser: isRCSUser, status: newStatus, parentABModelId: parentABModelId, deleteStatus: deleteStatus)
    }

    func updateRcsStatus(_ isRcs: Bool) -> NewLine {
        return NewLine(id: id, displayName: displayName,
                       lineModel: lineModel, picRemoteURL: picRemoteURL,
                       picLocalURL: picLocalURL, prxUpdateTimeStamp: prxUpdateTimeStamp,
                       presence: presence, download: download, isRCSUser: isRcs, status: status, parentABModelId: parentABModelId, deleteStatus: deleteStatus)
    }

    func withPresenceStatus(_ newPresence: PresenceStatus) -> NewLine {
        return NewLine(id: id, displayName: displayName,
                       lineModel: lineModel, picRemoteURL: picRemoteURL,
                       picLocalURL: picLocalURL, prxUpdateTimeStamp: prxUpdateTimeStamp,
                       presence: newPresence, download: download, isRCSUser: isRCSUser, status: status, parentABModelId: parentABModelId, deleteStatus: deleteStatus)
    }

    func downloadStatusChanged(_ newDownload: DownloadStatus) -> NewLine {
        return NewLine(id: id, displayName: displayName,
                       lineModel: lineModel, picRemoteURL: picRemoteURL,
                       picLocalURL: picLocalURL, prxUpdateTimeStamp: prxUpdateTimeStamp,
                       presence: presence, download: newDownload, isRCSUser: isRCSUser, status: status, parentABModelId: parentABModelId, deleteStatus: deleteStatus)
    }

    func withRCSStatus(_ rcsStatus: Bool) -> NewLine {
        return NewLine(id: id, displayName: displayName,
                       lineModel: lineModel, picRemoteURL: picRemoteURL,
                       picLocalURL: picLocalURL, prxUpdateTimeStamp: prxUpdateTimeStamp,
                       presence: presence, download: download, isRCSUser: rcsStatus, status: status, parentABModelId: parentABModelId, deleteStatus: deleteStatus)
    }

    func withExistenceAttributes(_ presenceStatus: PresenceStatus, downloadStatus: DownloadStatus,
                                 picRemoteURL: String, picLocalURL: String, timeStamp: String) -> NewLine {
        return NewLine(id: id, displayName: displayName,
                       lineModel: lineModel, picRemoteURL: picRemoteURL,
                       picLocalURL: picLocalURL, prxUpdateTimeStamp: timeStamp,
                       presence: presenceStatus, download: downloadStatus, isRCSUser: isRCSUser, status: status,  parentABModelId: parentABModelId, deleteStatus: deleteStatus)
    }

    func updateWithABModelType(_ type: ABModel.ContactType, modelId: String) -> NewLine {
        return NewLine(id: id, displayName: displayName,
                       lineModel: lineModel, picRemoteURL: picRemoteURL,
                       picLocalURL: picLocalURL, prxUpdateTimeStamp: prxUpdateTimeStamp,
                       presence: presence, download: download, isRCSUser: isRCSUser, status: status, parentABModelId: modelId, deleteStatus: deleteStatus)
    }


    func updateLineModel(_ newLineModel: LineModel) -> NewLine {
        return NewLine(id: id, displayName: displayName,
                       lineModel: newLineModel, picRemoteURL: picRemoteURL,
                       picLocalURL: picLocalURL, prxUpdateTimeStamp: prxUpdateTimeStamp,
                       presence: presence, download: download, isRCSUser: isRCSUser, status: status, parentABModelId: parentABModelId, deleteStatus: deleteStatus)
    }

    func updateLineId(_ newId: String) -> NewLine {
        return NewLine(id: newId, displayName: displayName,
                       lineModel: lineModel, picRemoteURL: picRemoteURL,
                       picLocalURL: picLocalURL, prxUpdateTimeStamp: prxUpdateTimeStamp,
                       presence: presence, download: download, isRCSUser: isRCSUser, status: status, parentABModelId: parentABModelId, deleteStatus: deleteStatus)
    }

    func updateDisplayName(_ newDisplayName: String) -> NewLine {
        return NewLine(id: id, displayName: newDisplayName,
                       lineModel: lineModel, picRemoteURL: picRemoteURL,
                       picLocalURL: picLocalURL, prxUpdateTimeStamp: prxUpdateTimeStamp,
                       presence: presence, download: download, isRCSUser: isRCSUser, status: status, parentABModelId: parentABModelId, deleteStatus: deleteStatus)
    }

    func updateLocalProfileUrl(_ profileUrl: String) -> NewLine {
        return NewLine(id: id, displayName: displayName,
                       lineModel: lineModel, picRemoteURL: picRemoteURL,
                       picLocalURL: profileUrl, prxUpdateTimeStamp: prxUpdateTimeStamp,
                       presence: presence, download: download, isRCSUser: isRCSUser, status: status, parentABModelId: parentABModelId, deleteStatus: deleteStatus)
    }

    func updateLocalRemoteUrl(_ remoteURL: String) -> NewLine {
        return NewLine(id: id, displayName: displayName,
                       lineModel: lineModel, picRemoteURL: remoteURL,
                       picLocalURL: picLocalURL, prxUpdateTimeStamp: prxUpdateTimeStamp,
                       presence: presence, download: download, isRCSUser: isRCSUser, status: status, parentABModelId: parentABModelId, deleteStatus: deleteStatus)
    }

    func updatePrxTimeStamp(_ newTimeStamp: String) -> NewLine {
        return NewLine(id: id, displayName: displayName,
                       lineModel: lineModel, picRemoteURL: picRemoteURL,
                       picLocalURL: picLocalURL, prxUpdateTimeStamp: newTimeStamp,
                       presence: presence, download: download, isRCSUser: isRCSUser, status: status, parentABModelId: parentABModelId, deleteStatus: deleteStatus)
    }
}

extension NewLine: Identifiable {
    public var identity: String {
        return id
    }
}


extension NewLine: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(UniqueMsisdn._(lineModel.line))
        hasher.combine(isRCSUser)
        hasher.combine(picLocalURL)
        hasher.combine(lineModel.lineType)
        hasher.combine(displayName)
        hasher.combine(prxUpdateTimeStamp)
        hasher.combine(status)
    }

    public static func == (lhs: NewLine, rhs: NewLine) -> Bool {
        return lhs.id == rhs.id
            && lhs.isRCSUser == rhs.isRCSUser
            && lhs.picLocalURL == rhs.picLocalURL
            && lhs.lineModel.lineType == rhs.lineModel.lineType
            && lhs.status == rhs.status
            && lhs.displayName == rhs.displayName
            && lhs.prxUpdateTimeStamp == rhs.prxUpdateTimeStamp &&
            lhs.parentABModelId == rhs.parentABModelId
    }
}


public extension NewLine {
    func extractDetails(fromUnknownLine unknownLine: NewLine) -> NewLine {
        return NewLine.init(id: id,
                            displayName: unknownLine.displayName,
                            lineModel: lineModel,
                            picRemoteURL: unknownLine.picRemoteURL,
                            picLocalURL: unknownLine.picLocalURL,
                            prxUpdateTimeStamp: unknownLine.prxUpdateTimeStamp,
                            presence: unknownLine.presence,
                            download: unknownLine.download,
                            isRCSUser: unknownLine.isRCSUser,
                            status: unknownLine.status, parentABModelId: parentABModelId,
                            deleteStatus: deleteStatus)
    }
}


public extension NewLine {
    var isBehavingRCS: Bool {
        return isRCSUser && (status == .active)
    }

    var isUnknown: Bool {
        return id == UniqueMsisdn._(line)
    }
}
