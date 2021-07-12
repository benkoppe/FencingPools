//
//  ContentView.swift
//  Fencing
//
//  Created by Ben K on 7/2/21.
//

import SwiftUI
import CoreData
import WebKit
import PopupView

struct ContentView: View {
    @Environment(\.managedObjectContext) private var moc
    @FetchRequest(entity: Pool.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \Pool.id, ascending: true)]) private var pools: FetchedResults<Pool>
    
    @AppStorage("slowMode") var slowMode = false
    @AppStorage("defaultName") var defaultName = ""
    
    let webView = WKWebView()
    @State private var isLoading = false
    @State private var showingAddNew = false
    @State private var bouts: [String] = []
    @State private var fencers: [String] = []
    @State private var name = ""
    @State private var date = ""
    @State private var url = ""
    
    @State private var useDefaultName = false
    
    @State private var showingNameSelect = false
    
    @State private var isDeleting = false
    @State private var showingWarning = false
    @State private var deleteItem: Pool?
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Pools")) {
                    if !pools.isEmpty {
                        ForEach(pools) { pool in
                            PoolListItem(pool: pool)
                        }
                        .onDelete(perform: delete)
                    } else {
                        EmptyPool()
                    }
                }
                .alert(isPresented: $showingWarning) {
                    Alert(title: Text("Delete \(deleteItem?.uName ?? "")"), message: Text("Are you sure?"), primaryButton: .destructive(Text("Delete")) {
                        try? moc.save()
                        self.isDeleting = false
                    }, secondaryButton: .cancel() {
                        if let pool = deleteItem {
                            self.readdPool(pool: pool)
                        }
                        self.isDeleting = false
                    })
                }
                
                Section {
                    Button("New Pool") {
                        withAnimation { showingAddNew.toggle(); useDefaultName = false }
                    }
                    
                    if showingAddNew {
                        Group {
                            if !defaultName.isEmpty {
                                Toggle("Use default name", isOn: $useDefaultName)
                            }
                            
                            HStack {
                                TextField("Pool URL ", text: $url)
                                Button(action: {
                                    fetchNewData(url: url)
                                    showingAddNew = false
                                    url = ""
                                }) {
                                    Image(systemName: "plus")
                                }
                                .buttonStyle(PlainButtonStyle())
                                .foregroundColor(url.isEmpty ? .gray: .blue)
                                .disabled(url.isEmpty)
                            }
                        }
                    }
                }
                .actionSheet(isPresented: $showingNameSelect) {
                    getNameSheet()
                }
                
                
            }
            .popup(isPresented: $isLoading, position: .top) {
                Text("Loading...")
                    .foregroundColor(.black)
                    .frame(width: 200, height: 60)
                    .background(Color(.lightGray))
                    .cornerRadius(30.0)
            }
            .navigationTitle("Fencing")
            .disabled(isLoading)
            .navigationBarItems(
                leading: NavigationLink(destination: AllBracketsView()) {
                    Text("DE Bracket")
                },
                trailing: NavigationLink(destination: SettingsView()) {
                    Image(systemName: "gear")
                })
            .onReceive(NotificationCenter.default.publisher(for: .didSelectDeleteItem)) { _ in
                DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                    for pool in pools {
                        if pool.deleteItem {
                            moc.delete(pool)
                            try? moc.save()
                        }
                    }
                }
            }
        }
    }
    
    struct PoolListItem: View {
        @Environment(\.managedObjectContext) private var moc
        @ObservedObject var pool: Pool
        
        var body: some View {
            NavigationLink(destination: PoolView(pool: pool).environment(\.managedObjectContext, self.moc)) {
                VStack(alignment: .leading) {
                    Text(pool.uName)
                    Text(pool.uDate)
                        .foregroundColor(.secondary)
                        .font(.caption)
                }
                .padding(10)
            }
        }
    }
    
    struct EmptyPool: View {
        var body: some View {
            VStack(alignment: .leading) {
                Text("No pools yet")
                    .font(.headline)
                Text("Add one to get started!")
                    .font(.caption)
                    .italic()
            }
            .padding(4)
        }
    }
    
    func delete(at offsets: IndexSet) {
        self.isDeleting = true
        for offset in offsets {
            deleteItem = pools[offset]
            moc.delete(pools[offset])
            showingWarning = true
        }
    }
    
    func readdPool(pool: Pool) {
        moc.insert(pool)
        try? moc.save()
    }
    
    func getNameSheet() -> ActionSheet {
        var buttons: [Alert.Button] = []
        for fencer in fencers {
            buttons.append(.default(Text(fencer)) { finishFetch(trackName: fencer) })
        }
        buttons.append(.cancel())
        
        return ActionSheet(title: Text("Select your name"), buttons: buttons)
    }
    
    func fetchNewData(url: String) {
        loadPage(url: url)
        isLoading = true
        DispatchQueue.main.asyncAfter(deadline: .now() + (!slowMode ? 5 : 30)) {
            getData()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                isLoading = false
                if !useDefaultName {
                    showingNameSelect = true
                } else {
                    finishFetch(trackName: defaultName)
                }
            }
        }
    }
    
    func finishFetch(trackName: String) {
        var number = 0
        if !pools.isEmpty {
            number = Int(pools.last!.id) + 1
        }
        if !bouts.isEmpty {
            let newPool = Pool(fencers: self.fencers, bouts: self.bouts, name: self.name, date: self.date, number: number, context: self.moc)
            if !trackName.isEmpty {
                newPool.trackName = trackName
            }
            try? moc.save()
        }
    }
    
    func loadPage(url: String) {
        if let url = URL(string: url) {
            let request = URLRequest(url: url)
            webView.load(request)
        }
    }
    
    func getData() {
        let js = """
            function runit() {
                a = []
                x = document.getElementsByClassName("text-center")
                for (s of x) {
                    a.push(s.innerText)
                }
                return a
            }
            runit()
        """
        webView.evaluateJavaScript(js) { (result, error) in
            if let result = result {
                bouts = result as! [String]
            }
        }
        webView.evaluateJavaScript("document.getElementsByClassName(\"desktop eventName\")[0].innerText") { (result, error) in
            if let result = result {
                name = (result as! String).trimmingCharacters(in: .whitespacesAndNewlines).condenseWhitespace()
            }
        }
        webView.evaluateJavaScript("document.getElementsByClassName(\"desktop eventTime\")[0].innerText") { (result, error) in
            if let result = result {
                date = (result as! String).trimmingCharacters(in: .whitespacesAndNewlines).condenseWhitespace()
            }
        }
        let namejs = """
            function runit() {
                a = []
                x = document.getElementsByClassName("poolCompName")
                for (s of x) {
                    a.push(s.innerText)
                }
                return a
            }
            runit()
        """
        webView.evaluateJavaScript(namejs) { (result, error) in
            if let result = result {
                let res = result as! [String]
                var fin: [String] = []
                for r in res {
                    if !fin.contains(r) {
                        fin.append(r)
                    } else {
                        break
                    }
                }
                fencers = fin
            }
        }
    }
        
        
}

extension String {
    func condenseWhitespace() -> String {
        let components = self.components(separatedBy: NSCharacterSet.whitespacesAndNewlines)
        return components.filter { !$0.isEmpty }.joined(separator: " ")
    }
}




struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()//.environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
