//
//  SpeechRecognizer.swift
//  ios_rasa_client
//
//  Created by ayman moustafa on 06/04/2023.
//

import Foundation
import SwiftUI
import Speech

class SpeechRecognizer: NSObject, ObservableObject, SFSpeechRecognizerDelegate {
    @Published var isRecording = false
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))!
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()
    private var result: SFSpeechRecognitionResult?

    override init() {
        super.init()
        self.speechRecognizer.delegate = self
    }

    func startRecording() {
        if !isRecording {
            beginRecording()
            isRecording = true
        }
    }

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

    private func beginRecording() {
        if recognitionTask != nil {
            recognitionTask?.cancel()
            recognitionTask = nil
        }

        let audioSession = AVAudioSession.sharedInstance()
        try? audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
        try? audioSession.setActive(true, options: .notifyOthersOnDeactivation)

        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        guard let recognitionRequest = recognitionRequest else { return }

        let inputNode = audioEngine.inputNode
        recognitionRequest.shouldReportPartialResults = true

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

        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer, _) in
            self.recognitionRequest?.append(buffer)
        }

        if !audioEngine.isRunning {
            do {
                try startAudioEngine()
            } catch {
                print("Error starting the audio engine: \(error.localizedDescription)")
            }
        }
    }

    private func startAudioEngine() throws {
        audioEngine.prepare()
        try audioEngine.start()
    }
}
