//
//  SettingsView.swift
//  Fencing
//
//  Created by Ben K on 7/4/21.
//

import SwiftUI

struct SettingsView: View {
    @AppStorage("slowMode") var slowMode = false
    @AppStorage("defaultName") var defaultName = ""
    
    var body: some View {
        Form {
            Section(header: Color.clear.frame(width: 0, height: 0), footer: Text("Will use this name as a default when creating pools. Use your exact USA Fencing name.")) {
                
                TextField("Default name", text: $defaultName)
            }
            
            Section(footer: Text("Turn this toggle on if you are currently using slow wifi. Will take significantly longer to load.")) {
                Toggle("Slow WiFi Mode", isOn: $slowMode)
            }
        }
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
