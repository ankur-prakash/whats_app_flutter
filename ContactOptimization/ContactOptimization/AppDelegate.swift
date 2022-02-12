//
//  AppDelegate.swift
//  ContactOptimization
//
//  Created by Ankur Prakash on 06/02/22.
//

import UIKit
import PhoneNumberKit


struct ABC {
    var name: String
    var surname: String
    var scholl: String
}

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    private let internalQueue = DispatchQueue(label: "RealmDBInternalQueue")

    func getNewLines() -> [NewLine] {
        
        [NewLine(id: UUID().uuidString, displayName: "Test", lineModel: NewLine.LineModel(line: "+818912882282", lineType: .home), picRemoteURL: "", picLocalURL: "", prxUpdateTimeStamp: "", presence: .completed, download: .completed, isRCSUser: true, status: .active, parentABModelId: UUID().uuidString, deleteStatus: .progress), NewLine(id: UUID().uuidString, displayName: "Test", lineModel: NewLine.LineModel(line: "+818912882283", lineType: .home), picRemoteURL: "", picLocalURL: "", prxUpdateTimeStamp: "", presence: .completed, download: .completed, isRCSUser: true, status: .active, parentABModelId: UUID().uuidString, deleteStatus: .progress), NewLine(id: UUID().uuidString, displayName: "Test", lineModel: NewLine.LineModel(line: "+818912882284", lineType: .home), picRemoteURL: "", picLocalURL: "", prxUpdateTimeStamp: "", presence: .completed, download: .completed, isRCSUser: true, status: .active, parentABModelId: UUID().uuidString, deleteStatus: .progress)]
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        NSLog("Start")
        for i in 0...5500 {
            _ = getNewLines()
            _ = ABModel(id: UUID().uuidString, nameModel: ContactNameModel(firstName: "A\(i)", middleName: "B\(i)", lastName: "C\(i)", phoneticFullName: "sss"), type: .device(UUID().uuidString), lines: getNewLines(), isFavourite: false, state: .update(.updated), hashTag: "", imageData: nil, isEnterprise: false, nativeContactPicName: "", groupContactIDs: [""], contactDetails: ContactDetailModel(detailsInfo: [:]), prxNameIfExist: false)
        }
        NSLog("End")

        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


}
