//
//  SettingsView.swift
//  Fencing
//
//  Created by Ben K on 7/4/21.
//

import SwiftUI

struct SettingsView: View {
    @AppStorage("defaultName") var defaultName = ""
    @AppStorage("trackedColor") var trackedColor = Color.teal
    
    var body: some View {
        Form {
            Section(header: Text("Tracked Name"), footer: Text("Will use this name as a default when creating pools. Use your exact USA Fencing name.")) {
                
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
            
            Section(header: Text("Toolbar")) {
                HStack {
                    Group {
                        Spacer()
                        Image(systemName: "square.dashed")
                        Spacer()
                        Image(systemName: "square.dashed")
                        Spacer()
                    }
                    Image(systemName: "square.dashed")
                    Spacer()
                    Image(systemName: "square.dashed")
                    Spacer()
                    Image(systemName: "square.dashed")
                    Spacer()
                }
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
