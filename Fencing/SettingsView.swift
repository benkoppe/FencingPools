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
    @AppStorage("trackedColor") var trackedColor = Color.teal
    
    var body: some View {
        Form {
            Section(header: Color.clear.frame(width: 0, height: 0), footer: Text("Will use this name as a default when creating pools. Use your exact USA Fencing name.")) {
                
                TextField("Default name", text: $defaultName)
            }
            
            Section(footer: Text("Will highlight your name in this color")) {
                HStack {
                    Text("Name Color")
                    Spacer()
                    Button("Reset") { trackedColor = Color.teal }
                        .buttonStyle(PlainButtonStyle())
                        .foregroundColor(.blue)
                    Spacer().frame(width: 20)
                    ColorPicker("Name Color", selection: $trackedColor)
                        .labelsHidden()
                }
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
