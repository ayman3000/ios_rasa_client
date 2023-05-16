//
//  SettingsViewModel.swift
//  ios_rasa_client
//
//  Created by ayman moustafa on 09/05/2023.
//

import Combine
import Foundation

class SettingsViewModel: ObservableObject {
    @Published var socketioAddress: String = ""
    private var cancellables: Set<AnyCancellable> = []

    init() {
        self.socketioAddress = "http://localhost:5005"
        loadSettings()
    }

    func loadSettings() {
        // Load the settings from storage
        // ...

        // Set the initial value for socketioAddress
       

        // Subscribe to the socketioAddress publisher and save changes to storage
        $socketioAddress
            .debounce(for: 0.5, scheduler: RunLoop.main)
            .sink {
                [weak self] newValue in
                // Save the updated socketioAddress to storage
                // ...
                

                // Print the updated socketioAddress to the console
                print("Updated socketioAddress: \(newValue)")

            }
            .store(in: &cancellables)
    }
}

