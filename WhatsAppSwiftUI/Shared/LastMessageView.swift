//
//  LastMessageView.swift
//  WhatsAppSwiftUI
//
//  Created by Ankur Prakash on 14/01/22.
//

import SwiftUI

struct LastMessageView: View {
   
    let message: Message
    var body: some View {
        HStack(spacing: 2.0) {
            if message.isSeen {
                Image(systemName: "arrow.up.left.square")
            }
            Text(message.sender.name)
            Text(":")
            Text(message.text)
        }
    }
}

struct LastMessageView_Previews: PreviewProvider {
    static var previews: some View {
        LastMessageView(message: Message(text: "How are you?", isSeen: true, sender: User()))
    }
}
