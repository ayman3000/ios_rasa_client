//
//  SettingsView.swift
//  ios_rasa_client
//
//  Created by ayman moustafa on 02/05/2023.
//
import SwiftUI
struct SettingsView: View {
    @Binding var isPresented: Bool
    @StateObject var viewModel: RasaChatViewModel
    @State private var socketioAddress: String = ""
    @FocusState private var isFocused: Bool

    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("SocketIO Address")) {
                    VStack {
                        TextField("SocketIO Address", text: $socketioAddress)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .keyboardType(.URL)
                            .autocapitalization(.none)
                            .padding()
                            .focused($isFocused)
                        
                        Button(action: {
                            viewModel.socketioAddress = socketioAddress
                            isPresented = false
                        }) {
                            Text("Save")
                                .foregroundColor(.white)
                                .padding(.horizontal, 20)
                                .padding(.vertical, 10)
                                .background(Color.blue)
                                .cornerRadius(8)
                                .font(.headline)
                        }
                    }
                    .onAppear {
                        socketioAddress = viewModel.socketioAddress
                        isFocused = true
                    }
                }
            }
            .navigationBarTitle("Settings")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        isPresented = false
                    }) {
                        Image(systemName: "xmark")
                    }
                }
            }
        }
    }
}

