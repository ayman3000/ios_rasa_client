//
//  ChatMessageView.swift
//  ios_rasa_client
//
//  Created by ayman moustafa on 07/04/2023.
//

import SwiftUI

struct ChatMessageView: View {
    let message: ChatMessage
    
    var body: some View {
        HStack {
            if message.sender == .user {
                Spacer()
                Text(message.text)
                    .padding(12)
                    .background(Color(UIColor.white))
                    .foregroundColor(.black)
                    .cornerRadius(10)
                Image(systemName: "person.fill")
                    .font(.system(size: 18))
                    .foregroundColor(.green)
                    .padding(.leading, 6)
            } else {
                Image(systemName: "bolt.fill")
                    .font(.system(size: 18))
                    .foregroundColor(.blue)
                    .padding(.trailing, 6)
                Text(message.text)
                    .padding(12)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                Spacer()
            }
        }
        .padding(.horizontal, message.sender == .user ? 8 : 16)
        .padding(.horizontal, message.sender == .bot ? 8 : 16)
    }
}

struct ChatMessageView_Previews: PreviewProvider {
    static var previews: some View {
        ChatMessageView(message: ChatMessage(sender: .user, text: "hi"))
    }
}
