//
//  RasaChatViewModel.swift
//  ios_rasa_client
//
//  Created by ayman moustafa on 07/04/2023.
//

import Foundation
import SocketIO
import SwiftUI
import AVFoundation

class RasaChatViewModel:  ObservableObject {
    @Published var messages: [ChatMessage] = []
    @Published var isConnected = false

    private var manager: SocketManager!
    private var socket: SocketIOClient!
//    private let speechSynthesizer = AVSpeechSynthesizer()
    let speaker = Speaker()

    init() {
        
//        let audioSession = AVAudioSession.sharedInstance()
//        do {
////            try audioSession.setCategory(.playback, mode: .default)
////            try audioSession.setCategory(.playAndRecord, mode: .spokenAudio, options: [.defaultToSpeaker, .allowBluetooth, .allowAirPlay])
//            try audioSession.setActive(true)
//        } catch {
//            print(" Failed to set up audio session: \(error)")
//        }
        
        self.speaker.test(msg: "test")
    
          
        setupSocket()
        connect()
    }

    func setupSocket() {
        // Replace `http://localhost:5005` with your Rasa server URL
        manager = SocketManager(socketURL: URL(string: "http://172.19.178.48:5005")!, config: [.log(false), .compress])
        socket = manager.defaultSocket
    }

    func connect() {
        // Handle connection and disconnection events
        socket.on(clientEvent: .connect) { _, _ in
            self.isConnected = true
        }
        socket.on(clientEvent: .disconnect) { _, _ in
            self.isConnected = false
        }

        // Handle the "bot_uttered" event
        socket.on("bot_uttered") { data, _ in
            if let response = data.first as? [String: Any], let message = response["text"] as? String {
                DispatchQueue.main.async {
                    self.messages.append(ChatMessage(sender: .bot, text: message))
//                    self.speak(text: message)
                    
                    
                }
                self.speaker.speak(message, language: "en-US")
            }
        }

        socket.connect()
    }

    func disconnect() {
        socket.disconnect()
    }

    func sendMessage(text: String) {
        let message = ChatMessage(sender: .user, text: text)
        messages.append(message)

        socket.emit("user_uttered", ["message": text])
    }
//    private func speak(text: String) {
//        let speechUtterance = AVSpeechUtterance(string: text)
//        speechUtterance.volume = 2
////        if let voice = AVSpeechSynthesisVoice(identifier: "com.apple.ttsbundle.Samantha-compact") {
////            speechUtterance.voice = voice
////        }
////        else {
////            speechUtterance.voice = AVSpeechSynthesisVoice(language: "en-US")
////
////        }
//        speechUtterance.voice = AVSpeechSynthesisVoice(language: "en-US")
//
//        speaker.speak(msg: speechUtterance)
////        DispatchQueue.main.async {
////            self.speechSynthesizer.speak(speechUtterance)
////               }
//
//    }

}


class Speaker: NSObject {
    let synthesizer = AVSpeechSynthesizer()
    override init() {
        super.init()
       synthesizer.delegate = self
    }

    func speak(_ text: String, language: String) {
            do {
                let utterance = AVSpeechUtterance(string: text)
                
                if let voice = AVSpeechSynthesisVoice(identifier: "com.apple.ttsbundle.siri_male_en-US_compact") {
                    utterance.voice = voice
                     }
                     else {
                         utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
             
                     }
                   
//                utterance.voice = voice
                
                try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
                try AVAudioSession.sharedInstance().setActive(true)
                self.synthesizer.speak(utterance)
            } catch let error {
//                self.errorDescription = error.localizedDescription
//                isShowingSpeakingErrorAlert.toggle()
                
                print( error.localizedDescription)
            }
        }
    
    func test(msg: String){
        self.speak("test", language: "en-US")
    }
}
extension Speaker: AVSpeechSynthesizerDelegate {
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)

        print("all done")
    }
}






