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
    @State private var socketIOAddress: String = ""
    @State private var restAPIAddress: String = ""

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Interface Type")) {
                    Picker("Interface Type", selection: $viewModel.interfaceType) {
                        Text("SocketIO").tag(InterfaceType.socketIO)
                        Text("REST API").tag(InterfaceType.restAPI)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding()
                }
                
                if viewModel.interfaceType == .socketIO {
                    Section(header: Text("SocketIO Address")) {
                        TextField("SocketIO Address", text: $socketIOAddress)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .keyboardType(.URL)
                            .autocapitalization(.none)
                            .padding()
                    }
                } else {
                    Section(header: Text("REST API Address")) {
                        TextField("REST API Address", text: $restAPIAddress)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .keyboardType(.URL)
                            .autocapitalization(.none)
                            .padding()
                    }
                }
                
                Section {
                    Button(action: {
                        viewModel.socketioAddress = socketIOAddress
                        viewModel.restAPIAddress = restAPIAddress
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
                    .padding()
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
        .onAppear {
            socketIOAddress = viewModel.socketioAddress
            restAPIAddress = viewModel.restAPIAddress
        }
    }
}
