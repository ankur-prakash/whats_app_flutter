//
//  RealmDB.swift
//  ContactOptimization
//
//  Created by Ankur Prakash on 07/02/22.
//

import Foundation
import RxSwift
import RealmSwift

enum Errors: Error {
    case logout
}

public class RealmDB {
    
    public typealias RealmProducerClosure = (SchedulerType) -> Observable<Realm?>
    private static let schemaVersion: UInt64 = 18
    private static let appGroupId = "group.com.mavenir.connect"
    private static let migrationBlock: MigrationBlock = { migration, oldSchemaVersion in }
    private static var realmDBFilePath: (String) -> URL? = { name in
        guard
            var appGroupUrl = FileManager.default
                .containerURL(forSecurityApplicationGroupIdentifier: RealmDB.appGroupId) else {
            return nil
        }
        appGroupUrl.appendPathComponent(name)
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
    
    private let realmProducer: (SchedulerType) -> Observable<Realm?>
    private let internalQueue: DispatchQueue
    private let internalScheduler: SerialDispatchQueueScheduler
    /// This was named internalQueueRealm but it is Observable<Realm>
    private let realmObservable: Observable<Realm>
    
    public init(name:Observable<String?>, inMemory: Bool = false) {
        realmProducer = RealmDB.realmProducer(from: RealmDB.configuration(for: name, inMemory: inMemory).share(replay: 1))
        internalQueue = DispatchQueue(label: "RealmDBInternalQueue")
        internalScheduler = SerialDispatchQueueScheduler(queue: internalQueue, internalSerialQueueName: internalQueue.label)
        realmObservable = realmProducer(internalScheduler)
            .flatMapLatest{ realm -> Observable<Realm> in
                guard let realm = realm else { return .error(Errors.logout) }
                return Observable.just(realm)
            }
    }
    
    private static func initializeConfig(name: String) -> Realm.Configuration {
        return Realm.Configuration(fileURL: RealmDB.realmDBFilePath(name),
                                   inMemoryIdentifier: name,
                                   schemaVersion: RealmDB.schemaVersion,
                                   migrationBlock: RealmDB.migrationBlock,
                                   deleteRealmIfMigrationNeeded: false,
                                   shouldCompactOnLaunch: RealmDB.compactOnLaunchBlock,
                                   objectTypes: [RealmUser.self])
    }
    
    private static func configuration(for name:Observable<String?>, inMemory: Bool) -> Observable<Realm.Configuration?> {
        name
            .flatMapLatest { name -> Observable<Realm.Configuration?> in
                guard let name = name else { return Observable.just(nil) }
                return Observable.just(inMemory ? Realm.Configuration.init(inMemoryIdentifier:name): RealmDB.initializeConfig(name: name))
            }
    }
    
    private static func realmProducer(from configuration: Observable<Realm.Configuration?>) -> RealmProducerClosure {
        { scheduler in
            configuration
                .observe(on: scheduler)
                .flatMapLatest { config -> Observable<Realm?> in
                    guard let config = config else { return Observable.just(nil) }
                    return Observable.create { observer in
                        do {
                            observer.onNext(try Realm(configuration: config))
                            observer.onCompleted()
                        } catch let error {
                            observer.onError(error)
                        }
                        return Disposables.create()
                    }
                }
        }
    }
}
