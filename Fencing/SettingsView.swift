//
//  SettingsView.swift
//  Fencing
//
//  Created by Ben K on 7/4/21.
//

import SwiftUI

struct SettingsView: View {
    
    var body: some View {
        Form {
            NameSection()
            
            ToolbarSection()
            
        }
        .navigationTitle("Settings")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct NameSection: View {
    @AppStorage("defaultName") var defaultName = ""
    @AppStorage("trackedColor") var trackedColor = Color.teal
    
    var body: some View {
        Section(header: Text("Tracked Name"), footer: Text("Will use this name as a default when creating pools. Use your exact USA Fencing name.")) {
            
            TextField("Default name", text: $defaultName)
        }
        
        Section(footer: Text("Will highlight your name in this color\n")) {
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
    }
}

struct ToolbarSection: View {
    @AppStorage("toolbarItemCount") var toolbarItemCount = defaultToolbarSize
    @AppStorage("toolbarItems") var toolbarItems: [ToolbarItemType] = defaultToolbar
    
    var body: some View {
        Section(header: Text("Toolbar")) {
            ToolbarCounter(toolbarItemCount: $toolbarItemCount, toolbarItems: $toolbarItems)
                .padding(3)
            
            ToolbarItemList(toolbarItems: $toolbarItems, itemCount: toolbarItemCount)
        }
    }
    
    struct ToolbarCounter: View {
        @Binding var toolbarItemCount: Int
        @Binding var toolbarItems: [ToolbarItemType]
        
        var body: some View {
            HStack {
                Stepper("Items in toolbar", value: $toolbarItemCount, in: 2...8)
                    .labelsHidden()
                Spacer()
                Button("Reset") {
                    toolbarItemCount = defaultToolbarSize
                    toolbarItems = defaultToolbar
                }
                .buttonStyle(PlainButtonStyle())
                .foregroundColor(.blue)
            }
        }
    }
    
    struct ToolbarItemList: View {
        @Binding var toolbarItems: [ToolbarItemType]
        let itemCount: Int
        
        var body: some View {
            HStack {
                Spacer()
                
                ForEach(0..<itemCount, id: \.self) { index in
                    Menu {
                        ForEach(ToolbarItemType.allCases) { type in
                            if type == .blank {
                                Section {
                                    type.button { toolbarItems[index] = type }
                                }
                            } else {
                                type.button { toolbarItems[index] = type }
                            }
                        }
                    } label: {
                        Image(systemName: toolbarItems[index].info.image)
                            .padding(1)
                    }
                    
                    Spacer()
                }
            }
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
