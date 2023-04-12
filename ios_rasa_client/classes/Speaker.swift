//
//  Speaker.swift
//  ios_rasa_client
//
//  Created by ayman moustafa on 12/04/2023.
//

import AVFoundation
import Foundation
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
                try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
                try AVAudioSession.sharedInstance().setActive(true)
                self.synthesizer.speak(utterance)
            } catch let error {
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

