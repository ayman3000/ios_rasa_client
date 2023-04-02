//
//  ios_rasa_clientApp.swift
//  ios_rasa_client
//
//  Created by ayman moustafa on 02/04/2023.
//

import SwiftUI

@main
struct ios_rasa_clientApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ChatView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
