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
    @Published var isTTSEnabled: Bool = true

    private var manager: SocketManager!
    private var socket: SocketIOClient!
    let speaker = Speaker()
    init() {
        setupSocket()
        connect()
    }

    func setupSocket() {
        manager = SocketManager(socketURL: URL(string: "http://172.19.178.29:5005")!, config: [.log(false), .compress])
        socket = manager.defaultSocket
    }

    func connect() {
        // Handle connection and disconnection events
        socket.on(clientEvent: .connect) { _, _ in
            self.isConnected = true
            print("connected....")
        }
        socket.on(clientEvent: .disconnect) { _, _ in
            self.isConnected = false
            print("disconnected....")
        }
        
        socket.on("bot_uttered") { [weak self] dataArray, _ in
            guard let self = self else {return}
            
            print("Received data: \(dataArray)")
            
            do {
                let data =  try JSONSerialization.data(withJSONObject: dataArray[0], options: [])
                let response = try JSONDecoder().decode(RasaResponse.self, from: data)
                self.handleResponse(response, sender: .bot)
                
            } catch {
                print(" Error decodeing RasaResponse: \(error)")
            }
        }

        socket.connect()
    }
    
    private func handleResponse(_ response: RasaResponse, sender: Sender ) {
        let text = response.text
        let messageButtons = response.quick_replies?.map { ChatMessage.MessageButton(title: $0.title, payload: $0.payload) }
        
                let chatMessage = ChatMessage(sender: sender, text: text,  buttons: messageButtons)
                DispatchQueue.main.async {
                    self.messages.append(chatMessage)
                }
                guard self.isTTSEnabled else { return }
                self.speaker.speak(text, language: "en-US")
    }

    func disconnect() {
        socket.disconnect()
    }

    func sendMessage(text: String) {
        let message = ChatMessage(sender: .user, text: text, buttons: nil)
        messages.append(message)

        socket.emit("user_uttered", ["message": text])
    }

}
