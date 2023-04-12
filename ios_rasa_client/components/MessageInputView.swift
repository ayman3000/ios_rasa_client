//
//  MessageInputView.swift
//  ios_rasa_client
//
//  Created by ayman moustafa on 07/04/2023.
//

import SwiftUI

struct MessageInputView: View {
    @Binding var recognizedText: String
    @Binding var inputText: String
    @ObservedObject var rasaChatViewModel: RasaChatViewModel
    
    var body: some View {
        HStack {
            SpeechRecognitionButton(recognizedText: $recognizedText)
            
            TextField("Type your message...", text: $inputText)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)
            
            Button(action: {
                print("Send button tapped")
                if !inputText.isEmpty {
                       rasaChatViewModel.sendMessage(text: inputText)
                       inputText = ""
                   }
                // Implement your send action here
            }) {
                Text("Send")
                    .bold()
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color.blue)
                    .cornerRadius(8)
            }
        }
        .padding()
    }
}



