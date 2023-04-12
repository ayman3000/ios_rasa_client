//
//  SpeechRecognizer.swift
//  ios_rasa_client
//
//  Created by ayman moustafa on 06/04/2023.
//

import Speech
class SpeechRecognizer: NSObject, ObservableObject, SFSpeechRecognizerDelegate {
    @Published var isRecording = false
    @Published var recognizedText = ""

    private let speechRecognizer = SFSpeechRecognizer()
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()

    func startRecording() {
        // Check and request authorization
        SFSpeechRecognizer.requestAuthorization { authStatus in
            OperationQueue.main.addOperation {
                switch authStatus {
                case .authorized:
                    // Authorization granted, proceed with recording
                    self.beginRecording()
                case .denied, .restricted, .notDetermined:
                    print("Speech recognition authorization denied")
                @unknown default:
                    print("Unknown authorization status")
                }
            }
        }
    }

    private func beginRecording() {
        if audioEngine.isRunning {
            stopRecording()
//            audioEngine.stop()
            recognitionRequest?.endAudio()
        } else {
            do {
                try startRecordingSession()
                isRecording = true
            } catch {
                print("Error starting recording session: \(error)")
            }
        }
    }

    private func startRecordingSession() throws {
        // Setup audio session
        let audioSession = AVAudioSession.sharedInstance()
        try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
        try audioSession.setActive(true, options: .notifyOthersOnDeactivation)

        // Setup recognition request
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        guard let recognitionRequest = recognitionRequest else { fatalError("Unable to create a SFSpeechAudioBufferRecognitionRequest object") }

        recognitionRequest.shouldReportPartialResults = true

        // Setup audio input
        let inputNode = audioEngine.inputNode
        let recordingFormat = inputNode.outputFormat(forBus: 0)

        // Begin recognition task
        recognitionTask = speechRecognizer?.recognitionTask(with: recognitionRequest) { result, error in
            if let result = result {
                self.recognizedText = result.bestTranscription.formattedString
                if result.isFinal {
                    self.audioEngine.stop()
                    self.isRecording = false
                    inputNode.removeTap(onBus: 0)
                }
            } else if let error = error {
                print("Recognition error: \(error)")
                self.stopRecording()
            }
        }

        // Setup input node tap
        inputNode.installTap(onBus: 0, bufferSize: 4096, format: recordingFormat) { (buffer, _) in
            self.recognitionRequest?.append(buffer)
        }

        // Prepare and start the audio engine
        audioEngine.prepare()
        try audioEngine.start()
    }

    func stopRecording() {
        if audioEngine.isRunning {
            audioEngine.stop()
            
            recognitionRequest?.endAudio()
            isRecording = false
            audioEngine.inputNode.removeTap(onBus: 0)
            audioEngine.reset()
        }
    }

}


