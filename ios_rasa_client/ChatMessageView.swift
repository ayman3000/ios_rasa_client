//
//  ChatMessageView.swift
//  ios_rasa_client
//
//  Created by ayman moustafa on 07/04/2023.
//

import SwiftUI

struct ChatMessageView: View {
    let message: ChatMessage
    @ObservedObject var viewModel: RasaChatViewModel
    
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
//                Text(message.text)
//                    .padding(12)
//                    .background(Color.blue)
//                    .foregroundColor(.white)
//                    .cornerRadius(10)
                VStack(alignment: .leading, spacing: 4) {
                    Text(message.text)
                    .padding(12)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
     
                         if let buttons = message.buttons {
                             HStack {
                                 ForEach(buttons, id: \.self) { buttonTitle in
                                     Button(action: {
                                         viewModel.sendMessage(buttonTitle)
                                     }) {
                                         Text(buttonTitle)
                                             .padding(.horizontal, 12)
                                             .padding(.vertical, 8)
                                             .background(Color.blue)
                                             .foregroundColor(.white)
                                             .cornerRadius(4)
                                     }
                                 }
                             }
                         }
                     }
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

extension String {
    func htmlLinks() -> [(text: String, url: String)] {
        let regexPattern = "<a href=\"([^\"]+)\">([^<]+)<\\/a>"
        guard let regex = try? NSRegularExpression(pattern: regexPattern, options: []) else {
            return []
        }

        let nsString = self as NSString
        let matches = regex.matches(in: self, options: [], range: NSRange(location: 0, length: nsString.length))

        return matches.map { match in
            let url = nsString.substring(with: match.range(at: 1))
            let text = nsString.substring(with: match.range(at: 2))
            return (text: text, url: url)
        }
    }
}

