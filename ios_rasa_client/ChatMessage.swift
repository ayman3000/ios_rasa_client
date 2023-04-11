//
//  ChatMessage.swift
//  ios_rasa_client
//
//  Created by ayman moustafa on 07/04/2023.
//

import Foundation

struct ChatMessage: Identifiable, Equatable {
    let id = UUID()
    let sender: Sender
    let text: String
    let buttons: [MessageButton]?
    struct MessageButton: Hashable {
           let title: String
           let payload: String
       }
}

enum Sender {
    case user
    case bot
}

