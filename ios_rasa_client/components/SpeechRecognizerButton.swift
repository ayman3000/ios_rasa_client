//
//  SpeechRecognizerButton.swift
//  ios_rasa_client
//
//  Created by ayman moustafa on 06/04/2023.
//

import SwiftUI

struct SpeechRecognitionButton: View {
    @StateObject private var speechRecognizer = SpeechRecognizer()
    @Binding var recognizedText: String
    
    var body: some View {
        VStack {
            Button(action: {
                if speechRecognizer.isRecording {
                    speechRecognizer.stopRecording()
                } else {
                    speechRecognizer.startRecording()
                }
            }) {
                Image(systemName: speechRecognizer.isRecording ? "stop.fill" : "mic.fill")
                    .font(.system(size: 10))
                    .foregroundColor(speechRecognizer.isRecording ? .red : .primary)
                    .padding()
                    .background(Color.white)
                    .clipShape(Circle())
                    .shadow(radius: 10)
            }
            
            Text(speechRecognizer.recognizedText)
                .padding()
                .onChange(of: speechRecognizer.recognizedText){ newValue in
                    recognizedText = newValue
                }
        }
    }
}
