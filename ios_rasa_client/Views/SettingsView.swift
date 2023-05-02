//
//  SettingsView.swift
//  ios_rasa_client
//
//  Created by ayman moustafa on 02/05/2023.
//
import SwiftUI
struct SettingsView: View {
    @ObservedObject var rasaChatViewModel: RasaChatViewModel
    @State private var socketioAddress: String = ""

    var body: some View {
        VStack {
            TextField("SocketIO Address", text: $socketioAddress)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            
            Button("Save") {
                rasaChatViewModel.socketioAddress = socketioAddress
            }
            .padding()
        }
        .onAppear {
            // Set the initial value of the socketioAddress
            socketioAddress = rasaChatViewModel.socketioAddress
        }
    }
}
