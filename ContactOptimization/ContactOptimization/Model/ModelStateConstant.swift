//
//  ModelStateConstant.swift
//  ContactOptimization
//
//  Created by Ankur Prakash on 06/02/22.
//

import Foundation

// Deletion and Updation can go in single column
/*
 KEY MUST MATCH DYNAMIC FOLDER. PLEASE DON'T CHANGE KEY NAMES BECAUSE
 THAT WILL CREATE PROBLEM WHILE UPDATE
 */

public enum SyncState {
    case update(_ state: UpdationStatus)
    case delete( _ state: DeletionStatus)

    public static func defaultState() -> String {
        return UpdationStatus.updated.rawValue
    }

    public var rawValue: String {
        switch self {
            case .update(let updateStatus):
                return updateStatus.rawValue
            case .delete(let deleteStatus):
                return deleteStatus.rawValue
        }
    }

    public init?(_ rawValue: String) {
        if let status = UpdationStatus(rawValue: rawValue) {
            self = .update(status)
        } else if let status = DeletionStatus(rawValue: rawValue) {
            self = .delete(status)
        } else {
            return nil
        }
    }
}

extension SyncState: Equatable {
    public static func == (lhs: SyncState, rhs: SyncState) -> Bool {
        switch (lhs, rhs) {
        case let (.update(status1), .update(status2)):
            return (status1 == status2)
        case let (.delete(status1), .delete(status2)):
            return (status1 == status2)
        default:
            return false
        }
    }
}


public enum UpdationStatus: String {
    case unsync = "updateUnsync"
    case progress = "updateProgress"
    case updated = "updated"
}


public enum DeletionStatus: String {
    case unsync = "deleteUnsync"
    case progress = "deleteProgress"
    case deletedComparisionProgress = "deletedComparisionProgress"
    case exist = "Exist"
    case deleted = "deleted"
    case deleteUnsyncDuringComparison = "deletedInDevice" // These records should not send any request to delete again from device. This category will be used when app detect records are auto delete during sync
}

public enum PresenceStatus: String {
    case pending = "presence_pending"
    case progress = "presence_progress"
    case completed = "presence_completed"
}

public enum DownloadStatus: String {
    case pending = "download_pending"
    case progress = "download_progress"
    case completed = "download_completed"
}

public enum RequestStatus: String {
    case pending
    case progress
    case completed
}

public enum FolderUpdateAction: String {
    case mute
    case unmute
}

public enum BulkUpdateFlag: String {
    case ADD_FLAG
    case REMOVE_FLAG
}
