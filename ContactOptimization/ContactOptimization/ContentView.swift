//
//  ContentView.swift
//  ContactOptimization
//
//  Created by Ankur Prakash on 06/02/22.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        List(DBInteractor.shared.testUsers) {
            Text("Hello = \($0.name)")
        }.listStyle(.plain)
        
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
