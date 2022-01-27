//
//  ChatListRow.swift
//  WhatsAppSwiftUI
//
//  Created by Ankur Prakash on 14/01/22.
//

import SwiftUI

struct ChatListRow: View {
    
    let chat: Chat
    var body: some View {
        HStack {
            //Sets the mode by which SwiftUI resizes an image to fit its space.
            ProfileIcon(image: chat.profileIcon)
            VStack(alignment: .leading, spacing: 4.0) {
                Text(chat.name)
                    .font(.title2)
                    .bold()
                if let message = chat.lastMessage {
                    LastMessageView(message: message)
                        .font(.subheadline) //for enviroment
                }
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 4.0) {
                Text("14/04/2022")
                HStack {
                    Image(systemName: "pin")
                        .rotationEffect(Angle(degrees: 45))
                    Image(systemName: "speaker.slash")
                }
            }
        }
      //  .padding(.horizontal)
        .frame(height: 100.0)
    }
}

struct ChatListRow_Previews: PreviewProvider {
    static var previews: some View {
        ChatListRow(chat: Chat.dummyChat())
    }
}
