//
//  BracketOfSixteen.swift
//  Fencing
//
//  Created by Ben K on 7/10/21.
//

import SwiftUI

struct BracketOfSixteen: View {
    let names = [["Benjamin Koppe", "Alexander Koppe"], ["Matthew Dao", "Connor Jeong"], ["Nicholas Candela", "Thomas Chung"], ["Nolan Yumaico", "Jake Maeng"], ["Benjamin Koppe", "Alexander Koppe"], ["Matthew Dao", "Connor Jeong"], ["Nicholas Candela", "Thomas Chung"], ["Nolan Yumaico", "Jake Maeng"]]
    
    @State private var columns: [GridItem] = []
    @State private var currentItem = 0
    
    var body: some View {
        
        GeometryReader { geo in
            LazyVGrid(columns: columns, spacing: 0) {
                ForEach(0 ..< names.count * 4) { i in
                    makeColumn1(currentRow: i, name1: names[i/4][0], name2: names[i/4][1])
                    makeColumn2(currentRow: i, name1: "", name2: "")
                    makeColumn3(currentRow: i, name1: "", name2: "")
                    makeColumn4(currentRow: i, name1: "", name2: "")
                }
            }
            .onAppear() { setColumns(geo: geo) }
        }
        .padding(40)
    }
    
    func setColumns(geo: GeometryProxy) {
        let firstSize = geo.size.width / 1.5
        let size = (geo.size.width - firstSize) / 3
        
        var final: [GridItem] = [GridItem(.fixed(firstSize), spacing: 0, alignment: .trailing)]
        for _ in 1...3 {
            final.append(GridItem(.fixed(size), spacing: 0, alignment: .trailing))
        }
        columns = final
    }
    
    struct makeColumn1: View {
        
        let currentRow: Int
        let name1: String
        let name2: String
        
        let aRows = 4
        var aCurrentRow: Int {
            currentRow % aRows
        }
        
        var body: some View {
            ZStack {
                switch aCurrentRow {
                
                case 0:
                    HStack {
                        Text(name1)
                            .lineLimit(1)
                        Spacer()
                    }
                    .padding(1)
                    .padding(.trailing, 5)
                    .singleBorder(.bottom)
                case 1:
                    Color.clear
                        .singleBorder(.trailing)
                case 2:
                    HStack {
                        Text(name2)
                            .lineLimit(1)
                        Spacer()
                    }
                    .padding(1)
                    .padding(.trailing, 5)
                    .singleBorder(.trailing)
                    .singleBorder(.bottom)
                case 3:
                    Color.clear
                        .frame(height: 40)
                default:
                    EmptyView()
                }
            }
        }
    }
    
    struct makeColumn2: View {
        
        let currentRow: Int
        let name1: String
        let name2: String
        
        let aRows = 8
        var aCurrentRow: Int {
            currentRow % aRows
        }
        
        var body: some View {
            ZStack {
                switch aCurrentRow {
                
                case 1:
                    HStack {
                        Text(name1)
                            .lineLimit(1)
                        Spacer()
                    }
                    .padding(1)
                    .padding(.trailing, 5)
                    .singleBorder(.bottom)
                case 2...4:
                    Color.clear
                        .singleBorder(.trailing)
                case 5:
                    HStack {
                        Text(name2)
                            .lineLimit(1)
                        Spacer()
                    }
                    .padding(1)
                    .padding(.trailing, 5)
                    .singleBorder(.trailing)
                    .singleBorder(.bottom)
                case 7:
                    Color.clear
                        .frame(height: 40)
                default:
                    EmptyView()
                }
            }
        }
    }
    
    struct makeColumn3: View {
        
        let currentRow: Int
        let name1: String
        let name2: String
        
        let aRows = 16
        var aCurrentRow: Int {
            currentRow % aRows
        }
        
        var body: some View {
            ZStack {
                switch aCurrentRow {
                
                case 3:
                    VStack {
                        Spacer()
                        HStack {
                            Text(name1)
                                .lineLimit(1)
                            Spacer()
                        }
                        .padding(1)
                        .padding(.trailing, 5)
                        .singleBorder(.bottom)
                    }
                case 4...10:
                    Color.clear
                        .singleBorder(.trailing)
                case 11:
                    VStack {
                        Spacer()
                        HStack {
                            Text(name2)
                                .lineLimit(1)
                            Spacer()
                        }
                        .padding(1)
                        .padding(.trailing, 5)
                    }
                    .singleBorder(.trailing)
                    .singleBorder(.bottom)
                case 15:
                    Color.clear
                        .frame(height: 40)
                default:
                    EmptyView()
                }
            }
        }
    }
    
    struct makeColumn4: View {
        
        let currentRow: Int
        let name1: String
        let name2: String
        
        let aRows = 32
        var aCurrentRow: Int {
            currentRow % aRows
        }
        
        var body: some View {
            ZStack {
                switch aCurrentRow {
                
                case 7:
                    VStack {
                        Spacer()
                        HStack {
                            Text(name1)
                                .lineLimit(1)
                            Spacer()
                        }
                        .padding(1)
                        .padding(.trailing, 5)
                        .singleBorder(.bottom)
                    }
                case 8...22:
                    Color.clear
                        .singleBorder(.trailing)
                case 23:
                    VStack {
                        Spacer()
                        HStack {
                            Text(name2)
                                .lineLimit(1)
                            Spacer()
                        }
                        .padding(1)
                        .padding(.trailing, 5)
                    }
                    .singleBorder(.trailing)
                    .singleBorder(.bottom)
                case 31:
                    Color.clear
                        .frame(height: 40)
                default:
                    EmptyView()
                }
            }
        }
    }
}

struct BracketOfSixteen_Previews: PreviewProvider {
    static var previews: some View {
        BracketOfSixteen()
    }
}
