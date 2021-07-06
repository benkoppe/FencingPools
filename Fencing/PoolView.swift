//
//  PoolView.swift
//  Fencing
//
//  Created by Ben K on 7/3/21.
//

import SwiftUI
import CoreData
import PopupView

struct PoolView: View {
    @Environment(\.managedObjectContext) private var moc
    @Environment(\.presentationMode) var presentationMode
    
    @ObservedObject var pool: Pool
    
    @State private var expand = false
    
    @State private var showingEditScore = false
    @State private var scoreBout: Bout?
    @State private var yourScore = ""
    @State private var opponentScore = ""
    
    @State private var showingScoreAlert = false
    
    let smallCellSize: CGFloat = 35
    
    var columns: [GridItem] {
        var final: [GridItem] = [GridItem(.fixed(100), spacing: 0, alignment: .leading)]
        for _ in 0..<pool.uFencers.count {
            final.append(GridItem(.fixed(smallCellSize), spacing: 0))
        }
        return final
    }
    
    var body: some View {
        VStack {
            Spacer()
                .frame(height: 5)
            
            
            ZoomableScrollView {
                LazyVGrid(columns: columns, spacing: 0) {
                    Text("")
                    ForEach(1...pool.uFencers.count, id: \.self) { i in
                        VStack {
                            Text("\(i)")
                                .bold()
                                .if(pool.isTracked(fencer: pool.uFencers[i-1])) {view in
                                    view.foregroundColor(Color.teal)
                                }
                                .font(.system(size: 11))
                                
                            Spacer()
                                .frame(height: 3)
                        }
                    }
                    
                    
                    ForEach(0..<pool.uFencers.count, id: \.self) { i in
                        let num = i
                        fencerRow(pool: pool, num: i)
                        
                        ForEach(pool.uFencers) { fencer in
                            if num == fencer.uNumber {
                                Color(.darkGray)
                                    .cell(size: smallCellSize, isTracked: false)
                            } else if pool.isTracked(fencer: fencer) || pool.isTracked(fencer: pool.uFencers[i]) {
                                if pool.isBoutScored(fencer: num, opponent: fencer.uNumber) {
                                    Text(pool.getScore(fencer: num, opponent: fencer.uNumber) ?? "")
                                        .font(.system(size: 10))
                                        .frame(minWidth: smallCellSize+1, minHeight: smallCellSize+1)
                                        .background(Color(pool.hasWon(fencer: num, opponent: fencer.uNumber) ? "GridGreen" : "GridRed"))
                                        .border(Color.secondary)
                                        .id(UUID())
                                } else if pool.isBoutComplete(fencer: num, opponent: fencer.uNumber) {
                                    Image(systemName: "checkmark")
                                        .font(.system(size: 10))
                                        .frame(minWidth: smallCellSize+1, minHeight: smallCellSize+1)
                                        .border(Color.secondary)
                                        .id(UUID())
                                } else {
                                    Color(.clear)
                                        .font(.system(size: 10))
                                        .frame(minWidth: smallCellSize+1, minHeight: smallCellSize+1)
                                        .border(Color.secondary)
                                        .id(UUID())
                                }
                            } else if pool.isBoutComplete(fencer: num, opponent: fencer.uNumber) {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.secondary)
                                    .font(.system(size: 10))
                                    .frame(minWidth: smallCellSize+1, minHeight: smallCellSize+1)
                                    .border(Color.secondary)
                                    .id(UUID())
                            } else {
                                Color(.clear)
                                    .font(.system(size: 10))
                                    .frame(minWidth: smallCellSize+1, minHeight: smallCellSize+1)
                                    .border(Color.secondary)
                                    .id(UUID())
                            }
                        }
                        
                    }
                }
                .scaleEffect(0.9 + (CGFloat(pool.uFencers.count - 7) * -0.1))
                
                Spacer()
            }
            
            if showingEditScore, let bout = scoreBout, let tracked = pool.getTracked(), let opponent = bout.getOpponent(tracked) {
                Divider()
                
                VStack {
                    HStack {
                        Spacer()
                        TextField("You", text: $yourScore)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .keyboardType(.numberPad)
                            .frame(width: 100)
                            .multilineTextAlignment(.trailing)
                        Spacer()
                        Text("-")
                            .font(.title)
                        Spacer()
                        TextField(opponent.uName, text: $opponentScore)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .keyboardType(.numberPad)
                            .frame(width: 100)
                        Spacer()
                    }
                    .padding()
                    
                    HStack {
                        Button(action: {
                            if let yourScore = Int(yourScore), let opponentScore = Int(opponentScore) {
                                withAnimation { showingEditScore = false }
                                bout.hasScore = true
                                bout.setScore(for: tracked, score: yourScore)
                                bout.setScore(for: opponent, score: opponentScore)
                                self.yourScore = ""; self.opponentScore = ""
                                try? moc.save()
                            } else {
                                showingScoreAlert = false
                            }
                        }) {
                            Text("Done")
                                .padding(.horizontal)
                        }
                        
                        Spacer().frame(width: 35)
                        
                        Button(action: {
                            self.yourScore = ""; self.opponentScore = ""
                            withAnimation { showingEditScore = false }
                        }) {
                            Text("Cancel")
                                .padding(.horizontal)
                        }
                        .foregroundColor(.red)
                    }
                }
            }
            
            
            Divider()
            
            HStack {
                
                ScrollViewReader { proxy in
                    List {
                        Section(header: Text("Bouts")) {
                            ForEach(pool.uBouts) { bout in
                                Group {
                                    Menu {
                                        if pool.isBoutTracked(bout: bout) {
                                            Button(action: {
                                                yourScore = ""; opponentScore = ""
                                                scoreBout = bout
                                                withAnimation { showingEditScore = true }
                                            }) {
                                                Image(systemName: "pencil")
                                                Text("Input Score")
                                            }
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
                                                .foregroundColor(!pool.isTracked(fencer: bout.uLeft) ? .primary : Color.teal)
                                            Text(bout.uLeft.uName)
                                                .font(.caption)
                                                .foregroundColor(!pool.isTracked(fencer: bout.uLeft) ? .secondary : Color.teal)
                                            Spacer()
                                            Text(bout.uRight.uName)
                                                .font(.caption)
                                                .foregroundColor(!pool.isTracked(fencer: bout.uRight) ? .secondary : Color.teal)
                                            Text("\(bout.uRight.uNumber+1)")
                                                .foregroundColor(!pool.isTracked(fencer: bout.uRight) ? .primary : Color.teal)
                                        }
                                    }
                                }
                                .id(bout)
                                .listRowBackground((!pool.isTableComplete() && pool.getCurrentBout() == bout) ? Color.tertiaryGroupedBackground : Color.secondaryGroupedBackground)
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
                    .toolbar {
                        ToolbarItemGroup(placement: .bottomBar) {
                            
                            Spacer()
                            
                            Button(action: {
                                withAnimation { proxy.scrollTo(pool.getCurrentBout(), anchor: .top) }
                            }) {
                                Image(systemName:"arrow.down.to.line")
                                    .padding([.horizontal, .bottom])
                            }
                            
                            Spacer()
                            
                            Group {
                                Button(action: {
                                    pool.currentBout -= 1; try? moc.save()
                                    pool.uBouts[pool.uCurrentBout].isCompleted = false
                                    withAnimation { proxy.scrollTo(pool.getCurrentBout()) }
                                }) {
                                    Image(systemName:"arrow.left")
                                        .padding([.horizontal, .bottom])
                                }
                                .disabled(pool.currentBout == 0)
                                .contextMenu {
                                    Button {
                                        for boutNum in 0..<Int(pool.currentBout) {
                                            pool.uBouts[boutNum].isCompleted = false
                                        }
                                        pool.currentBout = 0
                                        withAnimation { proxy.scrollTo(pool.getCurrentBout()) }
                                    } label: {
                                        Label("Jump to start", systemImage: "backward.fill")
                                    }
                                }
                                
                                Spacer().frame(width: 30)
                                
                                Button(action: {
                                    if pool.currentBout < pool.uBouts.count {
                                        pool.uBouts[pool.uCurrentBout].isCompleted = true
                                        pool.currentBout += 1; try? moc.save()
                                        withAnimation { proxy.scrollTo(pool.getCurrentBout()) }
                                    } else {
                                        pool.uBouts[pool.uCurrentBout].isCompleted = true
                                        pool.currentBout = Int16(pool.uBouts.count)
                                        withAnimation { proxy.scrollTo(pool.uBouts.last) }
                                    }
                                }) {
                                    Image(systemName:"arrow.right")
                                        .padding([.horizontal, .bottom])
                                }
                                .disabled(pool.currentBout == pool.uBouts.count)
                                .contextMenu {
                                    Button {
                                        pool.currentBout = Int16(pool.uBouts.count)
                                        for boutNum in 0..<Int(pool.currentBout) {
                                            pool.uBouts[boutNum].isCompleted = true
                                        }
                                        
                                        withAnimation { proxy.scrollTo(pool.getCurrentBout()) }
                                    } label: {
                                        Label("Jump to end", systemImage: "forward.fill")
                                    }
                                }
                                
                            }
                            
                            Spacer()
                            
                            Button(action: {
                                yourScore = ""; opponentScore = ""
                                scoreBout = pool.uBouts[pool.uCurrentBout]
                                withAnimation { showingEditScore.toggle() }
                            }) {
                                Image(systemName: "square.and.pencil")
                                    .padding([.horizontal, .bottom])
                            }
                            
                            Spacer()
                            
                        }
                    }
                    
                } // end of reader
            }
        }
        /*.navigationBarItems(trailing: Button(action: { print("i Button Pressed")} {
            Image(systemName: "info.circle")
        }))*/
        .navigationBarTitleDisplayMode(.inline)
    }
    
    struct fencerRow: View {
        let pool: Pool
        let num: Int
        
        var body: some View {
            HStack {
                Text("\(num+1)")
                    .font(.system(size: 11))
                    .bold()
                    .if(pool.isTracked(fencer: pool.uFencers[num])) {view in
                        view.foregroundColor(Color.teal)
                    }
                Text(pool.uFencers[num].uName)
                    //.bold()
                    .font(.system(size: 10))
                    .if(pool.isTracked(fencer: pool.uFencers[num])) {view in
                        view.foregroundColor(Color.teal)
                    }
                    .lineLimit(1)
                Text(" ")
                    .font(.system(size: 10))
            }
        }
    }
    
    enum cellTypes {
        case untrackedNoScore, untrackedCompleted, untrackedScore, trackedNoScore, trackedCompleted, trackedScore
    }
    
    struct fencerCell: View {
        let type: cellTypes
        let pool: Pool
        let num: Int
        let fencer: Fencer
        let cellSize: CGFloat
        
        var body: some View {
            switch type {
            
            case .untrackedNoScore:
                Color(.clear)
                    .cell(size: cellSize, isTracked: false)
            case .untrackedCompleted:
                Image(systemName: "checkmark")
                    .cell(size: cellSize, isTracked: false)
            case .untrackedScore:
                Image(systemName: "checkmark")
                    .cell(size: cellSize, isTracked: false)
            case .trackedNoScore:
                Color(.clear)
                    .cell(size: cellSize, isTracked: true)
            case .trackedCompleted:
                Image(systemName: "checkmark")
                    .cell(size: cellSize, isTracked: true)
            case .trackedScore:
                Text(pool.getScore(fencer: num, opponent: fencer.uNumber) ?? "")
                    .cell(size: cellSize, isTracked: true)
                    .background(Color(pool.hasWon(fencer: num, opponent: fencer.uNumber) ? "GridGreen" : "GridRed"))
                    
            }
        }
    }
}

struct fencerCellFormat: ViewModifier {
    let cellSize: CGFloat
    let isTracked: Bool
    
    func body(content: Content) -> some View {
        content
            .foregroundColor(isTracked ? .primary : .secondary)
            .font(.system(size: 10))
            .frame(minWidth: cellSize+1, minHeight: cellSize+1)
            .border(isTracked ? Color.secondary : Color.secondary)
            .id(UUID())
    }
}

extension View {
    func cell(size: CGFloat, isTracked: Bool) -> some View {
        self.modifier(fencerCellFormat(cellSize: size, isTracked: isTracked))
    }
}


struct PoolView_Previews: PreviewProvider {
    static let moc = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
    
    static var previews: some View {
        let pool = Pool(name: "Test", context: moc)
        
        PoolView(pool: pool)
    }
}
