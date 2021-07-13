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
        Section(header: Text("Tracked Name"), footer: Text("This name will be used as a default when creating pools. Use your exact USA Fencing name.")) {
            
            HStack {
                TextField("Default name", text: $defaultName)
                
                Spacer()
                
                if !defaultName.isEmpty {
                    Button(action: {
                        defaultName = ""
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.secondaryLabel)
                            .font(.callout)
                            .padding(.leading)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
        }
        
        Section(footer: Text("\n")) {
            HStack {
                Text("Highlight Color")
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
        Section(header: Text("Toolbar"), footer:
                    Text("""
                        \(Image(systemName: ToolbarItemType.blank.info.image))\t\(ToolbarItemType.blank.info.extendedDescription)
                        \(Image(systemName: ToolbarItemType.leftArrow.info.image))\t\(ToolbarItemType.leftArrow.info.extendedDescription)
                        \(Image(systemName: ToolbarItemType.rightArrow.info.image))\t\(ToolbarItemType.rightArrow.info.extendedDescription)
                        \(Image(systemName: ToolbarItemType.scrollToItem.info.image))\t\(ToolbarItemType.scrollToItem.info.extendedDescription)
                        \(Image(systemName: ToolbarItemType.editScore.info.image))\t\(ToolbarItemType.editScore.info.extendedDescription)
                        """).padding(.top, 3)
        ) {
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
