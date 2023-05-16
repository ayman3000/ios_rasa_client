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
import Combine

// This class handles communication with a Rasa chatbot using SocketIO
class RasaChatViewModel:  ObservableObject {
    // Published properties that indicate the chat messages and the connection status
    @Published var messages: [ChatMessage] = []
    @Published var isConnected = false
    @Published var isTTSEnabled: Bool = true
    @Published var socketioAddress: String = "http://172.20.10.7:5005" // <-- declare the socketioAddress here
    private var cancellables: Set<AnyCancellable> = []

    // Properties used to manage the SocketIO connection
    private var manager: SocketManager!
    private var socket: SocketIOClient!
    
    // An instance of the `Speaker` class for text-to-speech functionality
    let speaker = Speaker()
    
    init() {
        if let savedAddress = UserDefaults.standard.string(forKey: "socketioAddress") {
            socketioAddress = savedAddress
        }
        
        setupSocket(address: socketioAddress)
        connect()
        sendMessage(text: "hi", sender: .bot)
        subscribeToSocketioAddress()
    }


    func subscribeToSocketioAddress() {
        $socketioAddress
            .sink { [weak self] address in
                UserDefaults.standard.setValue(address, forKey: "socketioAddress")
                self?.setupSocket(address: address)
            }
            .store(in: &cancellables)

        if let savedAddress = UserDefaults.standard.string(forKey: "socketioAddress") {
            socketioAddress = savedAddress
        }
    }


    // Set up the SocketIO client
    func setupSocket(address: String) {
        if let socket = self.socket {
            if socket.status == .connected {
                socket.disconnect()
            }
        }
        manager = SocketManager(socketURL: URL(string: address)!, config: [.log(false), .compress])
        socket = manager.defaultSocket
    }


    // Connect to the SocketIO server and handle connection and disconnection events
    func connect() {
        socket.on(clientEvent: .connect) { _, _ in
            self.isConnected = true
            print("Connected....")
        }

        socket.on(clientEvent: .disconnect) { _, _ in
            self.isConnected = false
            print("Disconnected....")
        }

        // Handle "bot_uttered" events
        socket.on("bot_uttered") { [weak self] dataArray, _ in
            guard let self = self else { return }
            guard !dataArray.isEmpty else { return }
            
            print("Received data: \(dataArray)")
            
            // Decode the RasaResponse from the received data
            do {
                let data = try JSONSerialization.data(withJSONObject: dataArray[0], options: [])
                let response = try JSONDecoder().decode(RasaResponse.self, from: data)
                self.handleResponse(response, sender: .bot)
            } catch {
                print("Error decoding RasaResponse: \(error)")
            }
        }

        // Connect to the SocketIO server
        socket.connect()
    }

    // Handle a bot response
    private func handleResponse(_ response: RasaResponse, sender: Sender ) {
        let text = response.text
        let messageButtons = response.quick_replies?.map { ChatMessage.MessageButton(title: $0.title, payload: $0.payload) }
        
        // Create a ChatMessage from the response and append it to the messages array
        let chatMessage = ChatMessage(sender: sender, text: text,  buttons: messageButtons)
        DispatchQueue.main.async {
            self.messages.append(chatMessage)
        }
        
        // Use text-to-speech to speak the bot response, if enabled
        guard self.isTTSEnabled else { return }
        self.speaker.speak(text, language: "en-US")
    }

    // Disconnect from the SocketIO server
    func disconnect() {
        socket.disconnect()
    }

    // Send a message to the chatbot
    func sendMessage(text: String, sender: Sender = .user,  buttonPayload: String? = nil, buttonTitle: String? = nil) {
        if let payload = buttonPayload, let title = buttonTitle {
            messages.append(ChatMessage(sender: sender, text: title, buttons: nil))
            socket.emit("user_uttered", ["message": payload])
        } else {
            messages.append(ChatMessage(sender: sender, text: text, buttons: nil))
            socket.emit("user_uttered", ["message": text])
        }
    }

}
