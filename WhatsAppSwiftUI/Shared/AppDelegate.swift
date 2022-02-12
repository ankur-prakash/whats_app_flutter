//
//  AppDelegate.swift
//  WhatsAppSwiftUI
//
//  Created by Ankur Prakash on 28/01/22.
//

import Foundation
import UIKit
import RakutenOneAuthCore
import Swinject
import SwiftUI

// no changes in your AppDelegate class
class AppDelegate: NSObject, UIApplicationDelegate {
  
    public static let container = Container()
    public static let resolver: Resolver = container.synchronize()
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        registerDependencies()
        return true
    }
}

extension AppDelegate {
    
    static var idSDKSession: IDSDKSessionManager
    {
        resolver.resolve(IDSDKSessionManager.self)!
    }

    static var tokenProvider: IDTokenProvider
    {
        resolver.resolve(IDTokenProvider.self)!
    }
}

extension AppDelegate {
    
    func registerDependencies() {
        
        AppDelegate.container.register(IDSDKSessionManager.self)
        {
            _ in

            return IDSDKSessionManager()
        }.inObjectScope(.container)

        AppDelegate.container.register(IDTokenProvider.self)
        {
            _ in

            return IDSDKAccessTokenProvider()
        }.inObjectScope(.container)
    }
}
