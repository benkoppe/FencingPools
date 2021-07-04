//
//  PoolView.swift
//  Fencing
//
//  Created by Ben K on 7/3/21.
//

import SwiftUI
import CoreData

struct PoolView: View {
    @Environment(\.managedObjectContext) private var moc
    @Environment(\.presentationMode) var presentationMode
    
    @ObservedObject var pool: Pool
    
    @State private var info: GridInfo = GridInfo()
    
    var columns: [GridItem] {
        var final: [GridItem] = [GridItem(.fixed(100), alignment: .leading)]
        for _ in 0..<pool.uFencers.count {
            final.append(GridItem(.flexible(maximum: 20), spacing: 10))
        }
        return final
    }
    
    var body: some View {
        VStack {
            GeometryReader { geo in
                LazyVGrid(columns: columns, spacing: 10) {
                    Text("")
                    ForEach(1...pool.uFencers.count, id: \.self) { i in
                        Text("\(i)")
                            .bold()
                            .font(.system(size: 11))
                    }
                    
                    ForEach(0..<pool.uFencers.count*2-1, id: \.self) { i in
                        if i%2 == 0 {
                            let num = i/2
                            HStack {
                                Text("\(num+1)")
                                    .font(.system(size: 11))
                                    .bold()
                                Text(pool.uFencers[num].uName)
                                    //.bold()
                                    .font(.system(size: 10))
                                    .lineLimit(1)
                            }
                            ForEach(pool.uFencers) { fencer in
                                if num == fencer.uNumber {
                                    Text("")
                                        .font(.system(size: 10))
                                        .id(UUID())
                                } else if pool.isTracked(fencer: fencer) {
                                    Text(pool.getScore(fencer: num, opponent: fencer.uNumber) ?? "")
                                        .font(.system(size: 10))
                                        .id(UUID())
                                } else if pool.isBoutComplete(fencer: num, opponent: fencer.uNumber) {
                                    Image(systemName: "checkmark")
                                        .font(.system(size: 10))
                                        .id(UUID())
                                } else {
                                    Text("")
                                        .font(.system(size: 10))
                                        .id(UUID())
                                }
                            }
                        } else {
                            EmptyDivider(left: pool.uFencers.count, geo: geo)
                        }
                    }
                }
                .scaleEffect(0.85 - (CGFloat(pool.uFencers.count - 7) * 0.05))
            }
            .frame(height: 10)
            
            Spacer()
                .frame(minHeight: 35)
            Divider()
            
            List {
                Section(header: Text("Bouts")) {
                    ForEach(pool.uBouts) { bout in
                        Menu {
                            Button(action: {
                                
                            }) {
                                Image(systemName: "pencil.circle")
                                Text("Input Score")
                            }
                            Button(action: {
                                pool.objectWillChange.send()
                                bout.isCompleted = true
                                try? moc.save()
                            }) {
                                Image(systemName: "checkmark")
                                Text("Mark as Done")
                            }
                        } label: {
                            HStack {
                                Text("\(bout.uLeft.uNumber+1)")
                                    .foregroundColor(.primary)
                                Text(bout.uLeft.uName)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Spacer()
                                Text(bout.uRight.uName)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Text("\(bout.uRight.uNumber+1)")
                                    .foregroundColor(.primary)
                            }
                        }
                        //.listRowBackground(Color(.green))
                    }
                }
                
                Button("Delete Pool") {
                    presentationMode.wrappedValue.dismiss()
                    moc.delete(pool)
                    try? moc.save()
                }
                .foregroundColor(.red)
            }
            .listStyle(InsetGroupedListStyle())
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}


struct EmptyDivider: View {
    let left: Int
    let geo: GeometryProxy
    
    var body: some View {
        Divider()
            .frame(width: geo.size.width)
        ForEach(0..<left, id: \.self) { i in
            Color.clear
                .id(UUID())
        }
    }
}

struct EmptySpace: View {
    let left: Int
    let height: Int
    
    var body: some View {
        Spacer()
            .frame(maxHeight: CGFloat(height))
        ForEach(0..<left, id: \.self) { i in
            Color.clear
                .id(UUID())
        }
    }
}

struct ExtendedDivider: View {
    var width: CGFloat = 2
    var direction: Axis.Set = .horizontal
    var customColor: Color? = nil
    @Environment(\.colorScheme) var colorScheme
    var body: some View {
        ZStack {
            Rectangle()
                .applyIf(customColor == nil) {
                    $0.fill(colorScheme == .dark ? Color(red: 0.278, green: 0.278, blue: 0.290) : Color(red: 0.706, green: 0.706, blue: 0.714))
                } else: {
                    $0.fill(customColor!)
                }
                .applyIf(direction == .vertical) {
                    $0.frame(width: width)
                    .edgesIgnoringSafeArea(.vertical)
                } else: {
                    $0.frame(height: width)
                    .edgesIgnoringSafeArea(.horizontal)
                }
        }
    }
}

extension View {
    @ViewBuilder func applyIf<T: View>(_ condition: @autoclosure () -> Bool, apply: (Self) -> T, else: (Self) -> T) -> some View {
        if condition() {
            apply(self)
        } else {
            `else`(self)
        }
    }
}


struct PoolView_Previews: PreviewProvider {
    static let moc = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
    
    static var previews: some View {
        let pool = Pool(name: "Test", context: moc)
        
        PoolView(pool: pool)
    }
}
