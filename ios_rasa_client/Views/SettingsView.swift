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
            HStack {
                Text("Rasa url: ")
                TextField("SocketIO Address", text: $socketioAddress)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            }
            
            HStack(alignment: .center) {
                Button("Save") {
                    rasaChatViewModel.socketioAddress = socketioAddress
                }
                .padding(.horizontal, 10)
            }
            .padding(.horizontal)
        }
        .padding(.horizontal,10)
        .onAppear {
            // Set the initial value of the socketioAddress
            socketioAddress = rasaChatViewModel.socketioAddress
        }
        
    }
}
