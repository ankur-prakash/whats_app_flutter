//
//  Chat.swift
//  WhatsAppSwiftUI
//
//  Created by Ankur Prakash on 14/01/22.
//

import Foundation
import SwiftUI

/*
 ObjectIdentifier:
 /// A unique identifier for a class instance or metatype.
 ///
 /// This unique identifier is only valid for comparisons during the lifetime
 /// of the instance.
 ///
 /// In Swift, only class instances and metatypes have unique identities. There
 /// is no notion of identity for structs, enums, functions, or tuples.
 */
public struct Chat {
    
    let chatId: String
    let name: String
    let lastMessageReceivedDate: Date?
    var isPin = false
    var profileIcon: Image = Image(systemName: "person.crop.circle")
    let lastMessage: Message?
    let lastMessageSender: User?
}

extension Chat: Identifiable {
    public var id: String {
        chatId
    }
}

public extension Chat {
    
    static func dummyChat() -> Chat {
        Chat(chatId: UUID().uuidString, name: "G 1205 Great \(Int.random(in: 0..<1000))", lastMessageReceivedDate: Date(), isPin: true, profileIcon: Image("turtlerock"), lastMessage: Message(text: "How are you?", isSeen: true, sender: User()), lastMessageSender: nil)
    }
}
