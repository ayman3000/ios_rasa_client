//
//  SpeechRecognizer.swift
//  ios_rasa_client
//
//  Created by ayman moustafa on 06/04/2023.
//

import Foundation
import SwiftUI
import Speech

// This class handles speech recognition functionality
class SpeechRecognizer: NSObject, ObservableObject, SFSpeechRecognizerDelegate {
    // This published property indicates whether the recorder is currently recording or not
    @Published var isRecording = false
    
    // This property is used to recognize speech
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))!
    
    // These properties are used to manage the recognition process
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    
    // This property is used to manage audio input and output
    private let audioEngine = AVAudioEngine()
    
    // This property stores the result of speech recognition
    private var result: SFSpeechRecognitionResult?
    
    // Initialize the class and set the speech recognizer delegate
    override init() {
        super.init()
        self.speechRecognizer.delegate = self
    }
    // Start recording speech
    func startRecording() {
        if !isRecording {
            beginRecording()
            isRecording = true
        }
    }
    // Stop recording speech and return the recognized text to the completion handler
    func stopRecording(completion: @escaping (String) -> Void) {
        if audioEngine.isRunning {
            audioEngine.stop()
            recognitionRequest?.endAudio()
            self.recognitionTask?.finish()
            self.recognitionTask = nil
            self.recognitionRequest = nil
            self.audioEngine.inputNode.removeTap(onBus: 0)

            if let recognizedText = result?.bestTranscription.formattedString {
                completion(recognizedText)
            }
        }
        isRecording = false
    }
    // Begin the speech recognition process
    private func beginRecording() {
        if recognitionTask != nil {
            recognitionTask?.cancel()
            recognitionTask = nil
        }
        // Set up the audio session
        let audioSession = AVAudioSession.sharedInstance()
        try? audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
        try? audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        // Create the recognition request
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        guard let recognitionRequest = recognitionRequest else { return }

        let inputNode = audioEngine.inputNode
        recognitionRequest.shouldReportPartialResults = true
        // Start the recognition task
        recognitionTask = speechRecognizer.recognitionTask(with: recognitionRequest) { [weak self] result, error in
            var isFinal = false

            if let result = result {
                self?.result = result
                isFinal = result.isFinal
            }

            if error != nil || isFinal {
                self?.audioEngine.stop()
                inputNode.removeTap(onBus: 0)
                self?.recognitionRequest = nil
                self?.recognitionTask = nil
            }
        }
        // Install an audio tap on the input node to capture speech input

        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer, _) in
            self.recognitionRequest?.append(buffer)
        }
        // Start the audio engine
        if !audioEngine.isRunning {
            do {
                try startAudioEngine()
            } catch {
                print("Error starting the audio engine: \(error.localizedDescription)")
            }
        }
    }
    // Start the audio engine
    private func startAudioEngine() throws {
        audioEngine.prepare()
        try audioEngine.start()
    }
}
