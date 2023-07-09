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
    @Published var messages: [ChatMessage] = []
    @Published var isConnected = false
    @Published var isTTSEnabled: Bool = true
    @Published var socketioAddress: String = "http://172.20.10.7:5005" // <-- declare the socketioAddress here
    @Published var restAPIAddress: String = "http://172.20.10.7:5005/webhooks/rest/webhook" // <-- declare the restAPIAddress here

    @Published var errorMessage: String?
    @Published var connectionFailed = false
    
    private var cancellables: Set<AnyCancellable> = []

    // Properties used to manage the SocketIO connection
    private var manager: SocketManager!
    private var socket: SocketIOClient!
    
    // An instance of the `Speaker` class for text-to-speech functionality
    let speaker = Speaker()
    // REST API session
    private let restAPISession = URLSession(configuration: .default)
    
    @Published var interfaceType: InterfaceType = .socketIO {
          didSet {
              switch interfaceType {
              case .socketIO:
                  subscribeToSocketioAddress()
              case .restAPI:
                  subscribeToRestAPIAddress()
              }
              UserDefaults.standard.setValue(interfaceType.rawValue, forKey: "interfaceType")

          }
      }
    
    init() {
           if let savedInterfaceType = UserDefaults.standard.string(forKey: "interfaceType") {
               interfaceType = InterfaceType(rawValue: savedInterfaceType) ?? .socketIO
           }
           if let savedAddress = UserDefaults.standard.string(forKey: "socketioAddress"), interfaceType == .socketIO {
               socketioAddress = savedAddress
               subscribeToSocketioAddress()
           }
           if let savedRestAPIAddress = UserDefaults.standard.string(forKey: "restAPIAddress"), interfaceType == .restAPI {
               restAPIAddress = savedRestAPIAddress
               subscribeToRestAPIAddress()
           }
       }
    // Subscribe methods
        func subscribeToSocketioAddress() {
            if interfaceType == .socketIO {
                $socketioAddress
                    .sink { [weak self] address in
                        UserDefaults.standard.setValue(address, forKey: "socketioAddress")
                        self?.setupSocket(address: address)
                    }
                    .store(in: &cancellables)

                if let savedAddress = UserDefaults.standard.string(forKey: "socketioAddress") {
                    socketioAddress = savedAddress
                    self.setupSocket(address: socketioAddress)
                }
            }
        }
        
        func subscribeToRestAPIAddress() {
            if interfaceType == .restAPI {
                   $restAPIAddress
                       .sink { [weak self] address in
                           UserDefaults.standard.setValue(address, forKey: "restAPIAddress")
                           // Disconnect from the Socket.IO server
                           if let socket = self?.socket {
                               socket.disconnect()
                           }

                       }
                       .store(in: &cancellables)

                   if let savedRestAPIAddress = UserDefaults.standard.string(forKey: "restAPIAddress") {
                       restAPIAddress = savedRestAPIAddress
                       // Disconnect from the Socket.IO server
                       if let socket = self.socket {
                           socket.disconnect()
                       }
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


}
