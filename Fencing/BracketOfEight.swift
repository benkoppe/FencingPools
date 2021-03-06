//
//  OneBracket.swift
//  Fencing
//
//  Created by Ben K on 7/9/21.
//

import SwiftUI

struct BracketOfEight: View {
    
    init(items: [[BracketItem]]) {
        self.items = items
    }
    
    var items: [[BracketItem]] = []
    
    @State private var columns: [GridItem] = []
    @State private var currentItem = 0
    
    var body: some View {
        
        GeometryReader { geo in
            LazyVGrid(columns: columns, spacing: 0) {
                ForEach(0 ..< items.count * 4) { i in
                    makeColumn1(currentRow: i, item1: items[i/4][0], item2: items[i/4][1])
                    makeColumn2(currentRow: i, name1: "", name2: "")
                    makeColumn3(currentRow: i, name1: "", name2: "")
                }
            }
            .onAppear() { setColumns(geo: geo) }
        }
        .padding(20)
    }
    
    func setColumns(geo: GeometryProxy) {
        let firstSize = geo.size.width / 1.4
        let size = (geo.size.width - firstSize) / 2
        
        var final: [GridItem] = [GridItem(.fixed(firstSize), spacing: 0, alignment: .trailing)]
        for _ in 1...2 {
            final.append(GridItem(.fixed(size), spacing: 0, alignment: .trailing))
        }
        columns = final
    }
    
    struct makeColumn1: View {
        
        let currentRow: Int
        let item1: BracketItem
        let item2: BracketItem
        
        let aRows = 4
        var aCurrentRow: Int {
            currentRow % aRows
        }
        
        var body: some View {
            ZStack {
                switch aCurrentRow {
                
                case 0:
                    HStack {
                        itemInterior(item: item1)
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
                        itemInterior(item: item2)
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
    
    struct itemInterior: View {
        let item: BracketItem
        
        var body: some View {
            HStack {
                switch item.uType {
                case .single:
                    Text(item.uNumber)
                        .lineLimit(1)
                        .foregroundColor(.secondary)
                        .frame(width: 45)
                    Text(item.singleFencer!.uName)
                        .lineLimit(1)
                case .multi:
                    Text(item.uNumber)
                        .lineLimit(1)
                        .foregroundColor(.secondary)
                        .frame(width: 45)
                    Text("Multi")
                        .lineLimit(1)
                case .bye:
                    Text("")
                        .frame(width: 45)
                    Text("Bye")
                        .lineLimit(1)
                }
            }
            .padding(.bottom, 1)
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
    
}

enum BorderType {
    case bottom, trailing, leading
}

struct singleBorder: ViewModifier {
    let type: BorderType
    
    func body(content: Content) -> some View {
        switch type {
        
        case .bottom:
            content
                .overlay(Rectangle().frame(width: nil, height: 1, alignment: .top).foregroundColor(.primary), alignment: .bottom)
            
        case .trailing:
            content
                .overlay(Rectangle().frame(width: 1, height: nil, alignment: .leading).foregroundColor(.primary), alignment: .trailing)
            
        case .leading:
            content
                .overlay(Rectangle().frame(width: 1, height: nil, alignment: .leading).foregroundColor(.primary), alignment: .leading)
        
        }
    }
}

extension View {
    func singleBorder(_ type: BorderType) -> some View {
        self.modifier(Fencing.singleBorder(type: type))
    }
}

struct OneBracket_Previews: PreviewProvider {
    static var previews: some View {
        BracketOfEight(items: [])
    }
}
