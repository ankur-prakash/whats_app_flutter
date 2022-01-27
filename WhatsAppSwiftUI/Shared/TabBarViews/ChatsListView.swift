//
//  ChatsListView.swift
//  WhatsAppSwiftUI
//
//  Created by Ankur Prakash on 14/01/22.
//

import SwiftUI

struct ChatsListView: View {
    
    @State private var searchText = ""
    //when you want view to redraw
    //V Imp: Property wrapper cannot be applied to a computed property
    
    @State private var isEmpty = false
    var filteredChats: [Chat] {
        let allChats = Array(0...20).compactMap { _ in Chat.dummyChat() }
        guard !searchText.isEmpty else {
            //Modifying state during view update, this will cause undefined behavior.
            //isEmpty = allChats.isEmpty
            return allChats
        }
        return allChats.filter { $0.name.contains(searchText) }
    }
    
    var body: some View {
        
        //List needed identifiable
        ZStack {
            if  filteredChats.isEmpty {
                NoDataView(image:  Image(systemName: "person.badge.plus"), message: "Not Chats Found")
            } else {
                VStack {
                    HStack {
                        Button(HomeScreen.boardcastButtonTitle) {
                            print("sss")
                        }
                        Spacer()
                        Button(HomeScreen.newGroupButtonTitle) {
                            print("ssssss")
                        }
                    }.padding(.horizontal)
                    
                    List {
                        ForEach(filteredChats){ chat in
                            ChatListRow(chat: chat)
                        }
                    }
                    //            .background(NoDataView(image:  Image(systemName: "person.badge.plus"), message: "Not Chats Found", isEmpty: isEmpty))
                    .listStyle(PlainListStyle())
                }
            }
        }
        .toolbar(content: {
            HStack {
                Button {
                    
                } label: {
                    Image(systemName: "square.and.pencil")
                    //                            .renderingMode(.original)
                }
                
                Spacer()
                Button(HomeScreen.editButtonTitle) {
                    
                }
            }
        })
        .navigationTitle(TabBarItemTitle.Chats)
        .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always))
    }
}


struct ChatsListView_Previews: PreviewProvider {
    static var previews: some View {
        ChatsListView()
    }
}
