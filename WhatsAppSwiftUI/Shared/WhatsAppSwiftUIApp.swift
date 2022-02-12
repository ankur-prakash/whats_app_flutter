//
//  WhatsAppSwiftUIApp.swift
//  Shared
//
//  Created by Ankur Prakash on 14/01/22.
//

import SwiftUI

@main
struct WhatsAppSwiftUIApp: App {

    // inject into SwiftUI life-cycle via adaptor !!!
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
