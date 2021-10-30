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
    @FetchRequest(entity: Pool.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \Pool.dDate, ascending: false)]) private var pools: FetchedResults<Pool>
    
    @AppStorage("defaultName") var defaultName = ""
    
    let webView = WKWebView()
    
    @State private var stillLoading = false
    @State private var showingAddNew = false
    @State private var bouts: [String] = []
    @State private var fencers: [String] = []
    @State private var name = ""
    @State private var date = ""
    @State private var strip = ""
    @State private var url = ""
    
    @State private var useDefaultName = false
    
    @State private var showingNameSelect = false
    
    @State private var isDeleting = false
    @State private var showingWarning = false
    @State private var deletePool: Pool?
    
    @State private var showURLError = false
    @State private var showErrorAlert = false
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Pools")) {
                    if !pools.isEmpty || isDeleting {
                        ForEach(pools) { pool in
                            PoolListItem(pool: pool)
                                .id(pool.self)
                        }
                        //.onDelete(perform: delete)
                    } else {
                        EmptyPool()
                    }
                }
                .alert(isPresented: $showingWarning) {
                    Alert(title: Text("Delete \(deletePool?.uName ?? "")"), message: Text("Are you sure?"), primaryButton: .destructive(Text("Delete")) {
                       confirmDelete()
                    }, secondaryButton: .cancel() {
                        if let pool = deletePool {
                            self.readdPool(pool: pool)
                        }
                        self.isDeleting = false
                    })
                }
                
                Section {
                    Button("New Pool") {
                        withAnimation { showingAddNew.toggle(); useDefaultName = false }
                        url = ""
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
                .alert(isPresented: $showErrorAlert) {
                    Alert(title: Text("Error"), message: Text("Sorry, there was an issue loading your data. Please try again."), dismissButton: .cancel(Text("OK")) { stillLoading = false })
                }
                .alert(isPresented: $showURLError) {
                    Alert(title: Text("URL Error"), message: Text("It looks like you weren't using the correct URL. Please use the URL from an individual pool's 'Detail' page."), dismissButton: .cancel(Text("OK")) { url = "" } )
                }
                
            }
            .popup(isPresented: $stillLoading, position: .top) {
                Text("Loading...")
                    .foregroundColor(.black)
                    .frame(width: 200, height: 60)
                    .background(Color(.lightGray))
                    .cornerRadius(30.0)
            }
            .navigationTitle("Fencing")
            .disabled(stillLoading)
            .navigationBarItems(
                /*leading: NavigationLink(destination: AllBracketsView()) {
                    Text("DE Bracket")
                },*/
                trailing: NavigationLink(destination: SettingsView()) {
                    Image(systemName: "gear")
                })
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
            .isDetailLink(false)
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
            deletePool = pools[offset]
            moc.delete(pools[offset])
            showingWarning = true
        }
    }
    
    func confirmDelete() {
        if let bouts = deletePool?.uBouts {
            for bout in bouts {
                moc.delete(bout)
            }
        }
        if let fencers = deletePool?.uFencers {
            for fencer in fencers {
                moc.delete(fencer)
            }
        }
        try? moc.save()
        self.isDeleting = false
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
        if url.contains("https://www.fencingtimelive.com/pools/details/") || url.contains("https://fencingtimelive.com/pools/details/") {
            loadPage(url: url)
            stillLoading = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                waitForLoad()
            }
        } else {
            showURLError = true
        }
    }
    
    func waitForLoad() {
        if webView.isLoading {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                waitForLoad()
            }
        } else {
            getData()
        }
    }
    
    func finishFetch(trackName: String) {
        var number = 0
        if !pools.isEmpty {
            number = Int(pools.last!.id) + 1
        }
        if !bouts.isEmpty {
            let newPool = Pool(fencers: self.fencers, bouts: self.bouts, name: self.name, date: self.date, number: number, strip: strip, url: url, context: self.moc)
            if !trackName.isEmpty {
                newPool.trackName = trackName
            }
            try? moc.save()
        }
        url = ""
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
        webView.evaluateJavaScript("document.getElementsByClassName(\"poolStripTime\")[0].innerText") { (result, error) in
            if let result = result {
                strip = "Strip " + (result as! String).trimmingCharacters(in: .whitespacesAndNewlines).condenseWhitespace()[9..<11]
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
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            if !fencers.isEmpty {
                stillLoading = false
                if !useDefaultName {
                    showingNameSelect = true
                } else {
                    finishFetch(trackName: defaultName)
                }
            } else {
                showErrorAlert = true
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
