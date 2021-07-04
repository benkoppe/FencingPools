//
//  FencingApp.swift
//  Fencing
//
//  Created by Ben K on 7/2/21.
//

import SwiftUI

@main
struct FencingApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
