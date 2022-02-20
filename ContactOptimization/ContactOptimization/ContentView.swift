//
//  ContentView.swift
//  ContactOptimization
//
//  Created by Ankur Prakash on 06/02/22.
//

import SwiftUI
//NavigationView is just a container.. title needs to be set in inner view
struct ContentView: View {
    var body: some View {
        NavigationView {
            List(DBInteractor.shared.testUsers) {
                Text("Hello = \($0.name)")
            }
            .listStyle(.plain)
            .navigationBarTitleDisplayMode(.large)
            .navigationTitle(Text("Realm"))
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
