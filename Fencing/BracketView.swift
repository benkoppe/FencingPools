//
//  BracketView.swift
//  Fencing
//
//  Created by Ben K on 7/5/21.
//


import SwiftUI
import WebKit

struct BracketView: View {
    @Environment(\.managedObjectContext) private var moc
    
    @AppStorage("slowMode") var slowMode = false
    
    let webView = WKWebView()
    @State private var fencers: [Fencer?] = []
    
    @State private var enteredText = ""
    
    var otherNum: Int {
        if let num = Int(enteredText) {
            return 256 - num + 1
        } else {
            return -1
        }
    }
    
    var body: some View {
        Form {
            TextField("Number", text: $enteredText)
            Text("\(otherNum)")
        }.frame(height: 200)
        
        Button("Fetch Data") {
            fetchNewData(url: "https://fencingtimelive.com/pools/results/2BD1BD71C7A845C2945D7C2810B80A99/2F64D87659474E55A793CAB12B857ABF")
        }
        Button("Sort Data") {
            sortFencers()
        }
        .onAppear() { print(order256.count )}
    }
    
    func sortFencers() {
        fillByes()
        
        
    }
    
    func fillByes() {
        let count = fencers.count
        var tableSize = 16
        
        while true {
            if count <= tableSize {
                break
            }
            tableSize *= 2
        }
        
        for _ in count..<tableSize {
            fencers.append(nil)
        }
    }
    
    func fetchNewData(url: String) {
        loadPage(url: url)
        DispatchQueue.main.asyncAfter(deadline: .now() + (!slowMode ? 5 : 30)) {
            getData()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                print(fencers.count)
                //Finish Fetch
            }
        }
    }
    
    func loadPage(url: String) {
        if let url = URL(string: url) {
            let request = URLRequest(url: url)
            webView.load(request)
        }
    }
    
    func getData() {
        let namejs = """
            function runit() {
                a = []
                x = document.getElementsByTagName("tbody")
                i = 0
                for (s of x) {
                    a.push(s.innerText.split("\t"))
                }
                return a
            }
            runit()
        """
        webView.evaluateJavaScript(namejs) { (result, error) in
            if let result = result {
                let res = (result as! [[String]])[0]
                let r = res.joined(separator: "$").split(separator: "\n")
                
                var fin: [[Substring]] = []
                for i in r {
                    fin.append(i.split(separator: "$"))
                }
                
                var fencers: [Fencer] = []
                for f in fin {
                    if String(f[8]) == "Advanced" {
                        fencers.append(Fencer(name: String(f[1]), placement: String(f[0]), context: moc))
                    }
                }
                
                self.fencers = fencers
            }
        }
    }
}

struct BracketView_Previews: PreviewProvider {
    static var previews: some View {
        BracketView()
    }
}

