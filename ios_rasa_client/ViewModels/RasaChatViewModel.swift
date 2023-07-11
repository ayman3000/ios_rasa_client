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

enum InterfaceType: String, Codable {
    case socketIO = "SocketIO"
    case restAPI = "REST API"
}
// This class handles communication with a Rasa chatbot using SocketIO
class RasaChatViewModel:  ObservableObject {

// Published properties that indicate the chat messages and the connection status
// `@Published` is a property wrapper that provides a way to configure properties of objects that can be published for use in SwiftUI.

@Published var messages: [ChatMessage] = [] // The array of chat messages.
@Published var isConnected = false // Indicates whether the client is currently connected to the server.
@Published var isTTSEnabled: Bool = true // Indicates whether the text-to-speech functionality is enabled.
@Published var socketioAddress: String = "http://172.20.10.7:5005" // The address of the Socket.IO server.
@Published var restAPIAddress: String = "http://172.20.10.7:5005/webhooks/rest/webhook" // The address of the REST API server.
@Published var errorMessage: String? // Contains an error message if any errors occur.
@Published var connectionFailed = false // Indicates whether the connection attempt to the server has failed.
  
private var cancellables: Set<AnyCancellable> = [] // Used for Combine, to keep track of any network requests or subscriptions.

// Properties used to manage the SocketIO connection
private var manager: SocketManager! // The Socket.IO manager instance.
private var socket: SocketIOClient! // The Socket.IO client instance.
  
// An instance of the `Speaker` class for text-to-speech functionality
let speaker = Speaker()

// REST API session
private let restAPISession = URLSession(configuration: .default)

// The selected interface type
@Published var interfaceType: InterfaceType = .restAPI {
    didSet {
        switch interfaceType {
        case .socketIO:
            subscribeToSocketioAddress() // Sets up a Socket.IO connection when the interface type is set to Socket.IO.
        case .restAPI:
            subscribeToRestAPIAddress() // Sets up a REST API connection when the interface type is set to REST API.
        }
        UserDefaults.standard.setValue(interfaceType.rawValue, forKey: "interfaceType")
    }
}

    
    init() {
     
           if let savedAddress = UserDefaults.standard.string(forKey: "socketioAddress"){
               socketioAddress = savedAddress
               
           }
           if let savedRestAPIAddress = UserDefaults.standard.string(forKey: "restAPIAddress") {
               restAPIAddress = savedRestAPIAddress
               
           }
        if let savedInterfaceType = UserDefaults.standard.string(forKey: "interfaceType") {
            interfaceType = InterfaceType(rawValue: savedInterfaceType) ?? .restAPI
        }
        $restAPIAddress
            .sink { address in
                UserDefaults.standard.setValue(address, forKey: "restAPIAddress")
            }
            .store(in: &cancellables)
        $socketioAddress
            .sink {  address in
                UserDefaults.standard.setValue(address, forKey: "socketioAddress")
                
            }
            .store(in: &cancellables)
       }
    // Subscribe methods
        func subscribeToSocketioAddress() {

            if interfaceType == .socketIO {
                self.setupSocket(address: socketioAddress)
      

     
            }
        }
        
        func subscribeToRestAPIAddress() {
            
            if interfaceType == .restAPI {
                if let socket = self.socket {
                    socket.disconnect()
                }
            
               }
        }


    // Set up the SocketIO client
    func setupSocket(address: String) {
        if let socket = self.socket {
            if socket.status == .connected {
                socket.disconnect()
            }
            if socket.status == .notConnected {
                print("colud not connect to address \(address)")
            }
        }
        guard let url = URL(string: address) else {
            print("Invalid address: \(address)")
            return
        }
        manager = SocketManager(socketURL: url, config: [.log(false), .compress])
        socket = manager.defaultSocket
        self.connect()
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
        socket.on(clientEvent:.error){  _, _ in
            self.isConnected = false
            self.errorMessage = "Error connecting to the server."
            self.connectionFailed = true
            print("Error connecting ....")
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
            sendPayload(payload)
        } else {
            messages.append(ChatMessage(sender: sender, text: text, buttons: nil))
            sendPayload(text)
        }
    }

    private func sendPayload(_ payload: String) {
        switch interfaceType {
        case .socketIO:
            socket.emit("user_uttered", ["message": payload])
        case .restAPI:
            sendRESTMessage(text: payload)
        }
    }
    
    // sendRESTMessage
    func sendRESTMessage(text: String) {
        guard let url = URL(string: restAPIAddress) else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        let messageData = ["sender": "user", "message": text]
        request.httpBody = try? JSONSerialization.data(withJSONObject: messageData, options: [])

        let task = restAPISession.dataTask(with: request) { [weak self] data, response, error in
            guard let this = self, let data = data else { return }
            do {
                let responseObject = try JSONSerialization.jsonObject(with: data, options: []) as? [[String: Any]]
                guard let firstResponse = responseObject?.first else {
                    print("Failed to parse JSON response: Empty response.")
                    return
                }
                
                let data = try JSONSerialization.data(withJSONObject: firstResponse, options: [])
                let response = try JSONDecoder().decode(RasaResponse.self, from: data)
                DispatchQueue.main.async {
                    self?.handleResponse(response, sender: .bot)
                }
                
            } catch {
                print("Failed to parse JSON response: \(error)")
            }
        }
        task.resume()
    }
    
    func disconnectSocket() {
        self.socket?.disconnect()
    }


}
