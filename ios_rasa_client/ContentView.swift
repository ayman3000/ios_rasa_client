//
//  ContentView.swift
//  chatbot
//
//  Created by ayman moustafa on 29/03/2023.
//

import AVFoundation
import SwiftUI
import SocketIO
// support speech recognition
import Speech

struct ChatView: View {
    @State private var userInput: String = ""
    @State private var botResponse: String = ""
    @State private var sid: String = UUID().uuidString
    let manager = SocketManager(socketURL: URL(string: "ws://192.168.1.5:5005")!, config: [.log(true), .compress])
    var socket: SocketIOClient {
        return manager.defaultSocket
    }

    var body: some View {
        VStack {
            Text(botResponse)
                .padding().bold()

            // TextField("Type something...", text: $userInput, onCommit: {
            //     sendMessage(userInput)
            // })
            //     .textFieldStyle(RoundedBorderTextFieldStyle())
            //     .padding()
            // add a texh field to support speech recognition
            TextField("Type something...", text: $userInput)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            // add a button to support speech recognition
            Button(action: {
                // add a button to support speech recognition
                let audioSession = AVAudioSession.sharedInstance()
                do {
                    try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
                    try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
                } catch {
                    print("audioSession properties weren't set because of an error.")
                }
                // add a button to support speech recognition
                let recognizer = SFSpeechRecognizer(locale: Locale.init(identifier: "en-US"))!
                let request = SFSpeechAudioBufferRecognitionRequest()
                var recognitionTask: SFSpeechRecognitionTask?
                let audioEngine = AVAudioEngine()
                let node = audioEngine.inputNode
                let recordingFormat = node.outputFormat(forBus: 0)
                node.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
                    request.append(buffer)
                }
                audioEngine.prepare()
                do {
                    try audioEngine.start()
                } catch {
                    print("audioEngine couldn't start because of an error.")
                }
                recognitionTask = recognizer.recognitionTask(with: request, resultHandler: { result, error in
                    if let result = result {
                        // This is where you will handle the final transcript!
                        let bestString = result.bestTranscription.formattedString
                        print(bestString)
                        self.userInput = bestString
                        sendMessage(bestString)
                    } else if let error = error {
                        print(error)
                    }
                })
            }) {
                Text("Speak")
            }

            Button(action: {
                sendMessage(userInput)
            }) {
                Text("Send")
            }
        }
        .onAppear {
            socket.on(clientEvent: .connect) {data, ack in
                print("socket connected")
            }

            socket.on("bot_uttered") {data, ack in
                if let response = data[0] as? String {
                    botResponse = response
                }
            }

            socket.connect()
        }
        .onDisappear {
            socket.disconnect()
        }
    }

    private func sendMessage(_ message: String) {
        let payload = ["message": message, "sender":"user", "session_id": "uyff"]
        print(payload)
        socket.emit("user_uttered", payload)
        userInput = ""
    }
}



struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ChatView()
    }
}
