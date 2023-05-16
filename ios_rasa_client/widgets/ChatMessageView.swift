//
//  ChatMessageView.swift
//  ios_rasa_client
//
//  Created by ayman moustafa on 07/04/2023.
//

import SwiftUI

// This view displays a chat message with an optional button
// This view displays a chat message with an optional button
struct ChatMessageView: View {
    let message: ChatMessage
    // The view model used to send messages when the button is tapped
    @ObservedObject var viewModel: RasaChatViewModel
    
    var body: some View {
        HStack {
            if message.sender == .user {
                // Display the user's message on the right side
                Spacer()
                Text(message.text)
                    .font(.system(size: 18))
                    .padding(6)
                    .background(Color(UIColor.white))
                    .foregroundColor(.black)
                    .cornerRadius(10)
                    
                Image(systemName: "person.fill")
                    .resizable()
                       .aspectRatio(contentMode: .fit)
                       .frame(width: 20, height: 20)
                       .foregroundColor(.green)
                       .background(Color.white)
                       .clipShape(Circle())
                       .padding(6)
                       .overlay(
                           Circle()
                               .stroke(Color.green, lineWidth: 2)
                       )
            } else {
                // Display the bot's message on the left side
                Image(systemName: "bolt.fill")
                    .resizable()
                       .aspectRatio(contentMode: .fit)
                       .frame(width: 40, height: 40)
                       .foregroundColor(.blue)
                       .background(Color.white)
                       .clipShape(Circle())
                       .padding(2)
//                       .overlay(
//                           Circle()
//                               .stroke(Color.green, lineWidth: 2)
//                       )

                VStack(alignment: .leading, spacing: 10) {
                    if let attributedString = message.text.htmlToAttributedString() {
                        let links = attributedString.string.htmlLinks()
                        if links.count > 0 {
                            // Display the text as a clickable link
                            ForEach(links, id: \.url) { link in
                                Link(destination: URL(string: link.url)!, label: {
                                    Text(link.text)
                                        .padding(10)
                                        .background(Color.gray.opacity(0.7))
                                        .cornerRadius(10)
                                        .foregroundColor(.white)
                                })
                                .padding(.bottom, 4)
                            }
                        } else {
                            // Display the text as a regular message
                            Text(message.text)
                                .font(.system(size: 18))
                                .padding(10)
                                .background(Color.gray.opacity(0.7))
                                .cornerRadius(10)
                                .foregroundColor(.white)
                        }
                    } else {
                        // Display the text as a regular message
                        Text(message.text)
                            .padding(10)
                            .background(Color.gray.opacity(0.7))
                            .cornerRadius(10)
                            .foregroundColor(.white)
                    }

                    // Display a button for each quick reply (if any)
                    if let buttons = message.buttons, !buttons.isEmpty {
                        VStack(alignment: .leading, spacing: 10) {
                            ForEach(buttons, id: \.self) { button in
                                Button(action: {
                                    viewModel.sendMessage(text: button.title, buttonPayload: button.payload, buttonTitle: button.title)
                                })
                                {
                                    Text(button.title)
                                        .font(.system(size: 18, weight: .semibold))
                                        .foregroundColor(Color.white)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 6)
                                        .frame(maxWidth: UIScreen.main.bounds.width * 0.55)
                                }
                                .padding(.vertical, 10)
                                .background(Color.blue)
                                .cornerRadius(10)
                            }
                        }
                    }
                }
                Spacer()
            }
        }
        // Add padding based on the sender (user or bot)
        .padding(.horizontal, message.sender == .user ? 8 : 16)
        .padding(.horizontal, message.sender == .bot ? 8 : 16)
    }
}


// Preview the ChatMessageView
struct ChatMessageView_Previews: PreviewProvider {
    static var previews: some View {
        ChatMessageView(message: ChatMessage(sender: .user, text: "hi", buttons: nil), viewModel: RasaChatViewModel())
    }
}



// Add an extension to the String class to extract links from HTML
extension String {
    func htmlToAttributedString() -> NSAttributedString? {
        guard let data = self.data(using: .utf8) else { return nil }
        do {
            let options: [NSAttributedString.DocumentReadingOptionKey: Any] = [.documentType: NSAttributedString.DocumentType.html, .characterEncoding: String.Encoding.utf8.rawValue]
            let attributedString = try NSAttributedString(data: data, options: options, documentAttributes: nil)
            let mutableAttributedString = NSMutableAttributedString(attributedString: attributedString)

            mutableAttributedString.enumerateAttribute(NSAttributedString.Key.link, in: NSRange(location: 0, length: mutableAttributedString.length), options: []) { value, range, _ in
                guard let url = value as? URL else { return }

                mutableAttributedString.addAttribute(.foregroundColor, value: UIColor.systemBlue, range: range)
                mutableAttributedString.addAttribute(.link, value: url, range: range)
            }

            return mutableAttributedString
        } catch {
            print("Error: \(error)")
            return nil
        }
    }

    func htmlLinks() -> [(text: String, url: String)] {
        let regexPattern =  "<a>(.*)</a>"
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


