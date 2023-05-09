//
//  SpeechRecognizerButton.swift
//  ios_rasa_client
//
//  Created by ayman moustafa on 06/04/2023.
//

import SwiftUI

// This view provides a button to start and stop recording audio for speech recognition using the SpeechRecognizer class
struct SpeechRecognitionButton: View {
    // Create an instance of the SpeechRecognizer class
    @StateObject private var speechRecognizer = SpeechRecognizer()
    
    // A closure to handle recognized text
    let onRecognizedText: (String) -> Void

    var body: some View {
        VStack {
            // The button starts and stops recording audio for speech recognition
            Button(action: {
                if speechRecognizer.isRecording {
                    speechRecognizer.stopRecording() { recognizedText in
                    onRecognizedText(recognizedText)
                    }
                } else {
                    speechRecognizer.startRecording()
                }
            }) {
                Image(systemName: speechRecognizer.isRecording ? "stop.fill" : "mic.fill")
                    .font(.system(size: 20))
                    .foregroundColor(speechRecognizer.isRecording ? .red : .primary)
                    .padding(.horizontal, 5)
//                    .background(Color.white)
                    .clipShape(Circle())
                    .shadow(radius: 10)
            }
        }
    }
}
