//
//  ChatListTopbar.swift
//  WhatsAppSwiftUI
//
//  Created by Ankur Prakash on 14/01/22.
//

import SwiftUI

struct ChatListTopbar: View {
    
    @Environment(\.editMode) var editMode
   
    var body: some View {
        HStack {
            EditButton()
            Spacer()
            if editMode?.wrappedValue == .active {
                Button(HomeScreen.cancelButtonTitle) {
                    editMode?.wrappedValue = .inactive
                }
            }
        }
        .padding(.horizontal)
       // .background(Color("Element"))
    }
}

struct ChatListTopbar_Previews: PreviewProvider {
    static var previews: some View {
        ChatListTopbar()
            .previewLayout(.sizeThatFits)
    }
}
