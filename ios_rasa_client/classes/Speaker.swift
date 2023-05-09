//
//  Speaker.swift
//  ios_rasa_client
//
//  Created by ayman moustafa on 12/04/2023.
//

import AVFoundation
import Foundation

// This class handles text-to-speech functionality
class Speaker: NSObject {
    // Initialize the speech synthesizer and set the delegate
    let synthesizer = AVSpeechSynthesizer()
    override init() {
        super.init()
        synthesizer.delegate = self
    }
    
    // Speak the specified text using the specified language
    func speak(_ text: String, language: String) {
        do {
            // Create an AVSpeechUtterance from the text
            let utterance = AVSpeechUtterance(string: text)
            
            // Set the voice for the utterance
            if let voice = AVSpeechSynthesisVoice(identifier: "com.apple.ttsbundle.siri_male_en-US_compact") {
                utterance.voice = voice
            }
            else {
                utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
            }
            
            // Set the audio session category and activate it
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
            
            // Speak the utterance using the speech synthesizer
            self.synthesizer.speak(utterance)
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    // Speak a test message
    func test(msg: String){
        self.speak("test", language: "en-US")
    }
}

// This extension implements the AVSpeechSynthesizerDelegate protocol
extension Speaker: AVSpeechSynthesizerDelegate {
    // Deactivate the audio session when speech synthesis is finished
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        try? AVAudioSession.sharedInstance().setActive(false, options: .notifyOthersOnDeactivation)
        
        print("all done")
    }
}
