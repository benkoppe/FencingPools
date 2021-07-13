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
    @AppStorage("colorScheme") var colorScheme: colorScheme = .dark

    var body: some Scene {
        WindowGroup {
            ContentView()
                .preferredColorScheme(colorScheme.getActualScheme())
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                
        }
    }
}
