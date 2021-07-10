//
//  PoolInfo.swift
//  Fencing
//
//  Created by Ben K on 7/7/21.
//

import SwiftUI
import CoreData

struct PoolInfo: View {
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.managedObjectContext) private var moc
    
    @ObservedObject var pool: Pool
    
    @State private var name: String = ""
    @State private var fencers: [Fencer] = []
    @State private var trackedName: String = ""
    @State private var bouts: [Bout] = []
    
    var body: some View {
        
        NavigationView {
            
            
            VStack {
                nameField(pool: pool, name: $name)
                
                HStack {
                    trackedNameButton(pool: pool, trackedName: $trackedName, fencers: fencers)
                    Spacer()
                    editFencersButton(pool: pool, fencers: $fencers)
                }
                .padding([.horizontal, .bottom])
                
                Spacer().frame(height: 10)
                editBouts(pool: pool, bouts: $bouts)
                
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(leading: Button(action: {
                presentationMode.wrappedValue.dismiss()
            }) {
                Text("Cancel")
            }, trailing: Button(action: {
                setValues()
                presentationMode.wrappedValue.dismiss()
            }) {
                Text("Done")
            })
            .onAppear(perform: setDefaults)
            
            
        }
    }
    
    func setValues() {
        pool.name = name
        pool.trackName = trackedName
        if fencers != pool.uFencers {
            pool.fencers = NSOrderedSet(array: fencers)
        }
        if bouts != pool.uBouts {
            pool.bouts = NSOrderedSet(array: bouts)
        }
    }
    
    func setDefaults() {
        if !pool.isNameDefault() {
            name = pool.uName
        }
        fencers = pool.uFencers
        trackedName = pool.uTrackName
        bouts = pool.uBouts
    }
    
    struct nameField: View {
        @ObservedObject var pool: Pool
        @Binding var name: String
        
        var body: some View {
            HStack {
                TextField("Pool Name", text: $name)
                    .foregroundColor(Color.primary)
                    .padding(.vertical, 10)
                    .overlay(Rectangle().frame(height: 2).padding(.top, 35).padding(.trailing,10))
                    .foregroundColor(Color.blue)
                //.padding(20)
                Spacer()
                Button("Reset") { name = pool.uDefaultName }
            }
            .padding(20)
        }
    }
    
    struct trackedNameButton: View {
        @ObservedObject var pool: Pool
        
        @Binding var trackedName: String
        let fencers: [Fencer]
        
        @State private var showingSheet = false
        
        var body: some View {
            Menu {
                Text("Tracked Name")
                
                Section {
                    ForEach(fencers) { fencer in
                        Button(action: {
                            trackedName = fencer.uName
                        }) {
                            if trackedName != fencer.uName {
                                Text(fencer.uName)
                            } else {
                                Label(fencer.uName, systemImage: "checkmark")
                            }
                        }
                    }
                }
            } label: {
                Text(trackedName)
                    .fixedSize(horizontal: true, vertical: false)
            }
            .foregroundColor(Color.teal)
        }
        
        func getNameSheet() -> ActionSheet {
            var buttons: [Alert.Button] = []
            for fencer in fencers {
                if fencer.uName != trackedName {
                    buttons.append(.default(Text(fencer.uName)) { trackedName = fencer.uName })
                } else {
                    buttons.append(.default(Text("\(Image(systemName: "checkmark")) \(fencer.uName)")) { trackedName = fencer.uName })
                }
            }
            buttons.append(.cancel())
            
            return ActionSheet(title: Text("Select your name"), buttons: buttons)
        }
    }
    
    struct editFencersButton: View {
        @ObservedObject var pool: Pool
        @Binding var fencers: [Fencer]
        
        var body: some View {
            NavigationLink(destination: editFencers(pool: pool, fencers: $fencers)) {
                Text("Fencers \(Image(systemName: "chevron.right"))")
            }
        }
    }
    
    struct editFencers: View {
        @ObservedObject var pool: Pool
        @Binding var fencers: [Fencer]
        
        var body: some View {
            List {
                ForEach(fencers) { fencer in
                    HStack {
                        Text("\(fencer.uNumber+1)")
                            .foregroundColor(.secondary)
                        Text(fencer.uName)
                            .font(.caption)
                            .lineLimit(1)
                    }
                }
                .onDelete(perform: delete)
                .onMove(perform: move)
            }
            .listStyle(InsetGroupedListStyle())
            .navigationBarItems(trailing: EditButton())
        }
        
        func delete(at offsets: IndexSet) {
            fencers.remove(atOffsets: offsets)
        }
        
        func move(from source: IndexSet, to destination: Int) {
            fencers.move(fromOffsets: source, toOffset: destination)
        }
    }
    
    struct editBouts: View {
        @ObservedObject var pool: Pool
        
        @Binding var bouts: [Bout]
        
        var body: some View {
            VStack {
                
                HStack {
                    Spacer()
                    Text("Bouts")
                        .bold()
                    Spacer()
                    EditButton()
                    
                    /*Button(action: {
                        print("Plus button pressed")
                    }) {
                        Image(systemName: "plus")
                    }*/
                }
                .padding()
                .background(Color.secondarySystemBackground)
                
                List {
                    ForEach(bouts) { bout in
                        HStack {
                            Text("\(bout.uLeft.uNumber+1)")
                                .foregroundColor(.secondary)
                            Text(bout.uLeft.uName)
                                .font(.caption)
                                .frame(width: 85, alignment: .leading)
                                .lineLimit(1)
                            Spacer()
                            Text(bout.uRight.uName)
                                .font(.caption)
                                .frame(width: 85, alignment: .trailing)
                                .lineLimit(1)
                            Text("\(bout.uRight.uNumber+1)")
                                .foregroundColor(.secondary)
                            
                        }
                        .id(bout)
                    }
                    .onDelete(perform: delete)
                    .onMove(perform: move)
                }
                .listStyle(InsetGroupedListStyle())
            }
        }
        
        func delete(at offsets: IndexSet) {
            bouts.remove(atOffsets: offsets)
        }
        
        func move(from source: IndexSet, to destination: Int) {
            bouts.move(fromOffsets: source, toOffset: destination)
        }
    }
}

struct PoolInfo_Previews: PreviewProvider {
    static let moc = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
    
    static var previews: some View {
        let pool = Pool(name: "Test", context: moc)
        
        PoolInfo(pool: pool)
    }
}
