//
//  ContentView.swift
//  Shared
//
//  Created by Ankur Prakash on 14/01/22.
//

import SwiftUI

struct ContentView: View {
    // state is needed because tabbar needed bindings
    @State var tabSelectionValue: Tab = .status

    enum Tab {
        case status
        case calls
        case camera
        case chat
        case settings
    }
    var body: some View {
        //Empty TabBar will crash
        TabView(selection: $tabSelectionValue) {
            NavigationView {
                ChatsListView()
            }
            .tabItem {
               Image(systemName: "text.bubble")
                   .renderingMode(.original)
               Text(TabBarItemTitle.Chats)
           }
           .tag(Tab.chat)
            
            NavigationView {
                SettingsView()
            } .tabItem {
                Label(TabBarItemTitle.Settings, systemImage: "gear.circle")
            }.tag(Tab.chat)
            
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .previewDevice(PreviewDevice(rawValue: "iPhone 13 Pro Max"))
    }
}
