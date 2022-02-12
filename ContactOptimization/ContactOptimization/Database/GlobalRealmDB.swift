//
//  GlobalRealmDB.swift
//  ContactOptimization
//
//  Created by Ankur Prakash on 09/02/22.
//

import Foundation
import RealmSwift

public class GlobalRealmDB {
    
    private var realm: Realm? {
        guard let config = realmConfiguration else {
            NSLog("Configuration not found")
            return nil
        }
        return try? Realm(configuration: config)
    }
    
    private static let appGroupId = "group.com.ankurprakash.test"
    private var realmConfiguration: Realm.Configuration?
    private static let schemaVersion = 1
    private static let migrationBlock: MigrationBlock = { migration, oldVersion in }
    private static var realmDBFilePath: (String) -> URL? = { name in
        guard
            var appGroupUrl = FileManager.default
                .containerURL(forSecurityApplicationGroupIdentifier: GlobalRealmDB.appGroupId) else {
            return nil
        }
        appGroupUrl.appendPathComponent(name)
        print("PATH = \(appGroupUrl)")
        return appGroupUrl
    }
    
    private static let compactOnLaunchBlock: (Int, Int) -> Bool = { totalBytes, usedBytes in
        // totalBytes refers to the size of the file on disk in bytes (data   free space)
        // usedBytes refers to the number of bytes used by data in the file
        // Compact if the file is over 100MB in size and less than 50% 'used'
        let oneHundredMB = 100 * 1024 * 1024
        NSLog("totalbytes \(totalBytes)")
        NSLog("usedbytes \(usedBytes)")
        if (totalBytes > oneHundredMB) && (Double(usedBytes) / Double(totalBytes)) < 0.4{
            NSLog("will compact realm")
        }
        return (totalBytes > oneHundredMB) && (Double(usedBytes) / Double(totalBytes)) < 0.4
    }
    
    public init(name: String, inMemory: Bool = false) {
        self.realmConfiguration = inMemory ? Realm.Configuration.init(inMemoryIdentifier: name) :
            Realm.Configuration.init(fileURL: GlobalRealmDB.realmDBFilePath(name),
                                                               schemaVersion: UInt64(GlobalRealmDB.schemaVersion),
                                                               migrationBlock: GlobalRealmDB.migrationBlock,
                                                               deleteRealmIfMigrationNeeded: false,
                                                          shouldCompactOnLaunch: GlobalRealmDB.compactOnLaunchBlock,
                                     objectTypes: [RealmUser.self])
    }
}

/*
 *** Terminating app due to uncaught exception 'RLMException', reason: 'Can only add, remove, or create objects in a Realm in a write transaction - call beginWriteTransaction on an RLMRealm instance first.'
 */

public extension GlobalRealmDB {
    
    func addUser(_ user: User) {
        try? realm?.write { [realm] in
            realm?.add(RealmUser(user: user), update: .all)
        }
    }
    
    func allUsers() -> [User] {
        return realm?.objects(RealmUser.self).map(User.init) ?? []
    }
}
