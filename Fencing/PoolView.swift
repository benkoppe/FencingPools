//
//  PoolView.swift
//  Fencing
//
//  Created by Ben K on 7/3/21.
//

import SwiftUI
import UIKit
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
    
    @State private var showingInfo = false
    
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
            if !pool.uFencers.isEmpty {
                Spacer()
                    .frame(height: 5)
                
                
                scoreTable(pool: pool, columns: columns, smallCellSize: smallCellSize)
                
                if showingEditScore, let bout = scoreBout, let tracked = pool.getTracked(), let opponent = bout.getOpponent(tracked) {
                    
                    Divider()
                    
                    editScore(yourScore: $yourScore, opponentScore: $opponentScore, showingEditScore: $showingEditScore, showingScoreAlert: $showingScoreAlert, bout: bout, tracked: tracked, opponent: opponent)
                }
                
                
                Divider()
                
                HStack {
                    
                    ScrollViewReader { proxy in
                        
                        boutList(pool: pool, yourScore: $yourScore, opponentScore: $opponentScore, scoreBout: $scoreBout, showingEditScore: $showingEditScore)
                            .toolbar {
                                ToolbarItemGroup(placement: .bottomBar) {
                                    toolbarItems(pool: pool, proxy: proxy, yourScore: $yourScore, opponentScore: $opponentScore, scoreBout: $scoreBout, showingEditScore: $showingEditScore)
                                }
                            }
                        
                    } // end of reader
                }
            }
        }
        .environmentObject(pool)
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle(pool.uName)
        /*.navigationBarItems(trailing: Button(action: {
            showingInfo = true
        }) {
            Image(systemName: "info.circle")
        })*/
        .fullScreenCover(isPresented: $showingInfo) {
            PoolInfo(pool: pool)
        }
    }
    
    struct scoreTable: View {
        @ObservedObject var pool: Pool
        
        let columns: [GridItem]
        let smallCellSize: CGFloat
        
        var body: some View {
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
                        fencerRow(pool: pool, num: i)
                        
                        ForEach(pool.uFencers) { fencer in
                            
                            if pool.isTracked(fencer: fencer) || pool.isTracked(fencer: pool.uFencers[i]) {
                                if i == fencer.uNumber {
                                    
                                    fencerCell(type: .trackedSelf, pool: pool, num: i, fencer: fencer, cellSize: smallCellSize)
                                    
                                } else if pool.isBoutScored(fencer: i, opponent: fencer.uNumber) {
                                    
                                    fencerCell(type: .trackedScore, pool: pool, num: i, fencer: fencer, cellSize: smallCellSize)
                                    
                                } else if pool.isBoutComplete(fencer: i, opponent: fencer.uNumber) {
                                    
                                    fencerCell(type: .trackedCompleted, pool: pool, num: i, fencer: fencer, cellSize: smallCellSize)
                                    
                                } else {
                                    
                                    fencerCell(type: .trackedNoScore, pool: pool, num: i, fencer: fencer, cellSize: smallCellSize)
                                    
                                }
                            } else  {
                                
                                if i == fencer.uNumber {
                                    
                                    fencerCell(type: .untrackedSelf, pool: pool, num: i, fencer: fencer, cellSize: smallCellSize)
                                    
                                } else if pool.isBoutComplete(fencer: i, opponent: fencer.uNumber) {
                                    
                                    fencerCell(type: .untrackedCompleted, pool: pool, num: i, fencer: fencer, cellSize: smallCellSize)
                                    
                                } else {
                                    
                                    fencerCell(type: .untrackedNoScore, pool: pool, num: i, fencer: fencer, cellSize: smallCellSize)
                                    
                                }
                            }
                        }
                        
                    }
                }
                .scaleEffect(0.9 + (CGFloat(pool.uFencers.count - 7) * -0.1))
                
                Spacer()
            }
        }
    } // Table with scores
    
    struct fencerRow: View {
        @ObservedObject var pool: Pool
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
    } // First column
    
    struct fencerCell: View {
        let type: cellTypes
        @ObservedObject var pool: Pool
        let num: Int
        @ObservedObject var fencer: Fencer
        let cellSize: CGFloat
        
        enum cellTypes {
            case untrackedSelf, untrackedNoScore, untrackedCompleted, untrackedScore, trackedSelf, trackedNoScore, trackedCompleted, trackedScore
        } // Types of cells
        
        var body: some View {
            switch type {
            
            case .untrackedSelf:
                Color(.darkGray)
                    .celll(size: cellSize, isTracked: false)
            case .trackedSelf:
                Color(.darkGray)
                    .celll(size: cellSize, isTracked: true)
                
            case .untrackedNoScore:
                Color(.clear)
                    .celll(size: cellSize, isTracked: false)
            case .untrackedCompleted:
                Image(systemName: "checkmark")
                    .celll(size: cellSize, isTracked: false)
            case .untrackedScore:
                Image(systemName: "checkmark")
                    .celll(size: cellSize, isTracked: false)
            case .trackedNoScore:
                Color(.clear)
                    .celll(size: cellSize, isTracked: true)
            case .trackedCompleted:
                Image(systemName: "checkmark")
                    .celll(size: cellSize, isTracked: true)
            case .trackedScore:
                Text(pool.getScore(fencer: num, opponent: fencer.uNumber) ?? "")
                    .celll(size: cellSize, isTracked: true)
                    .background(Color(pool.hasWon(fencer: num, opponent: fencer.uNumber) ? "GridGreen" : "GridRed"))
                
            }
        }
    } // Each score cell
    
    
    struct editScore: View {
        @Environment(\.managedObjectContext) private var moc
        
        @Binding var yourScore: String
        @Binding var opponentScore: String
        @Binding var showingEditScore: Bool
        @Binding var showingScoreAlert: Bool
        
        @EnvironmentObject var pool: Pool
        @ObservedObject var bout: Bout
        @ObservedObject var tracked: Fencer
        @ObservedObject var opponent: Fencer
        
        @State private var showingIssueAlert = false
        
        @State private var yourScoreInt = 0
        @State private var opponentScoreInt = 0
        @State private var scoreIssue: ScoreIssueType = .none
        
        var scoreIssueAlert: String {
            switch scoreIssue {
            case .you:
                return "Your score was higher than 5. Continue anyways?"
            case .opponent:
                return "Your opponent's score was higher than 5. Continue anyways?"
            case .all:
                return "Your and your opponent's scores were higher than 5. Continue anyways?"
            case .none:
                return ""
            }
        }
        
        var body: some View {
            VStack {
                HStack {
                    Spacer()
                    TextFieldContainer("You", text: $yourScore, alignment: .right)
                        .frame(width: 120, height: 10)
                    /*TextField("You", text: $yourScore)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .keyboardType(.numberPad)
                        .frame(width: 100)
                        .multilineTextAlignment(.trailing)*/
                    Spacer()
                    Text("-")
                        .font(.title)
                    Spacer()
                    TextFieldContainer("\(opponent.uName[0..<12])", text: $opponentScore, alignment: .left)
                        .frame(width: 120, height: 10)
                    /*TextField(opponent.uName, text: $opponentScore)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .keyboardType(.numberPad)
                        .frame(width: 100)*/
                    Spacer()
                }
                .padding()
                
                HStack {
                    Button(action: {
                        if let yourScoreInt = Int(yourScore), let opponentScoreInt = Int(opponentScore) {
                            self.yourScoreInt = yourScoreInt
                            self.opponentScoreInt = opponentScoreInt
                            checkScores()
                        }
                    }) {
                        Text("Done")
                            .padding(.horizontal)
                    }
                    .disabled(!isStringInt(yourScore) || !isStringInt(opponentScore))
                    .disabled(yourScore.isEmpty || opponentScore.isEmpty)
                    
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
            .alert(isPresented: $showingIssueAlert) {
                Alert(title: Text("Score too high"), message: Text(scoreIssueAlert), primaryButton: .destructive(Text("No"), action: { clearScores(scoreIssue) }), secondaryButton: .default(Text("Yes"), action: { setScores() }))
            }
        }
        
        struct TextFieldContainer: UIViewRepresentable {
            private var placeholder : String
            private var text : Binding<String>
            private var alignment: NSTextAlignment

            init(_ placeholder:String, text:Binding<String>, alignment: NSTextAlignment) {
                self.placeholder = placeholder
                self.text = text
                self.alignment = alignment
            }

            func makeCoordinator() -> TextFieldContainer.Coordinator {
                Coordinator(self)
            }

            func makeUIView(context: UIViewRepresentableContext<TextFieldContainer>) -> UITextField {

                let innertTextField = UITextField()
                innertTextField.placeholder = placeholder
                innertTextField.text = text.wrappedValue
                innertTextField.borderStyle = .roundedRect
                innertTextField.textAlignment = alignment
                innertTextField.keyboardType = .numberPad
                innertTextField.delegate = context.coordinator
                
                context.coordinator.setup(innertTextField)

                return innertTextField
            }

            func updateUIView(_ uiView: UITextField, context: UIViewRepresentableContext<TextFieldContainer>) {
                uiView.text = self.text.wrappedValue
            }

            class Coordinator: NSObject, UITextFieldDelegate {
                var parent: TextFieldContainer

                init(_ textFieldContainer: TextFieldContainer) {
                    self.parent = textFieldContainer
                }

                func setup(_ textField:UITextField) {
                    textField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
                    textField.addTarget(self, action: #selector(textFieldDidBeginEditing), for: .editingDidBegin)
                }
                
                @objc func textFieldDidChange(_ textField: UITextField) {
                    self.parent.text.wrappedValue = textField.text ?? ""
                }
                
                @objc func textFieldDidBeginEditing(_ textField: UITextField) {
                    DispatchQueue.main.async {
                        let newPosition = textField.endOfDocument
                        textField.selectedTextRange = textField.textRange(from: newPosition, to: newPosition)
                    }
                }
            }
        }
        
        func isStringInt(_ str: String) -> Bool {
            if let _ = Int(str) {
                return true
            } else {
                return false
            }
        }
        
        enum ScoreIssueType {
            case none, you, opponent, all
        }
        
        func clearScores(_ type: ScoreIssueType) {
            switch type {
            
            case .you:
                yourScoreInt = 0
                yourScore = ""
            case .opponent:
                opponentScoreInt = 0
                opponentScore = ""
            case .all:
                yourScoreInt = 0
                yourScore = ""
                opponentScoreInt = 0
                opponentScore = ""
            case .none:
                return
            }
        }
        
        func checkScores() {
            if yourScoreInt > 5 && opponentScoreInt > 5 {
                scoreIssue = .all
                showingIssueAlert = true
            } else if yourScoreInt > 5 {
                scoreIssue = .you
                showingIssueAlert = true
            } else if opponentScoreInt > 5 {
                scoreIssue = .opponent
                showingIssueAlert = true
            } else {
                scoreIssue = .none
                setScores()
            }
        }
        
        func setScores() {
            withAnimation { showingEditScore = false }
            pool.objectWillChange.send()
            bout.hasScore = true
            bout.setScore(for: tracked, score: yourScoreInt)
            bout.setScore(for: opponent, score: opponentScoreInt)
            self.yourScore = ""; self.opponentScore = ""
            try? moc.save()
        }
        
        
    } // Edit bout score
    
    
    struct boutList: View {
        @Environment(\.managedObjectContext) private var moc
        @Environment(\.presentationMode) var presentationMode
        
        @ObservedObject var pool: Pool
        
        @Binding var yourScore: String
        @Binding var opponentScore: String
        @Binding var scoreBout: Bout?
        @Binding var showingEditScore: Bool
        
        var body: some View {
            List {
                Section(header: Text("Bouts")) {
                    ForEach(pool.uBouts) { bout in
                        
                        boutListRow(pool: pool, bout: bout, yourScore: $yourScore, opponentScore: $opponentScore, scoreBout: $scoreBout, showingEditScore: $showingEditScore)
                        
                    }
                }
            }
            .listStyle(InsetGroupedListStyle())
        }
    } // Bout list
    
    struct boutListRow: View {
        @Environment(\.managedObjectContext) private var moc
        
        @ObservedObject var pool: Pool
        @ObservedObject var bout: Bout
        
        @Binding var yourScore: String
        @Binding var opponentScore: String
        @Binding var scoreBout: Bout?
        @Binding var showingEditScore: Bool
        
        var centerText: Text {
            if let tracked = pool.getTracked(), let opponent = bout.getOpponent(tracked) {
                if bout.hasScore, let score = pool.getScore(fencer: tracked, opponent: opponent) {
                    return Text(score)
                        .foregroundColor(pool.hasWon(fencer: tracked, opponent: opponent) ? .green : .red)
                } else if bout.isCompleted {
                    return Text("\(Image(systemName: "checkmark"))")
                        .foregroundColor(.primary)
                } else {
                    return Text("-")
                        .foregroundColor(.primary)
                }
            } else {
                if bout.isCompleted {
                    return Text("\(Image(systemName: "checkmark"))")
                        .foregroundColor(.secondaryLabel)
                } else {
                    return Text("-")
                        .foregroundColor(.secondaryLabel)
                }
            }
        }
        
        var body: some View {
            Group {
                HStack {
                    Text("\(bout.uLeft.uNumber+1)")
                        .foregroundColor(!pool.isTracked(fencer: bout.uLeft) ? .primary : Color.teal)
                    Text(bout.uLeft.uName)
                        .font(.caption)
                        .foregroundColor(!pool.isTracked(fencer: bout.uLeft) ? .secondary : Color.teal)
                        .if(pool.isTracked(fencer: bout.uLeft)) { view in
                            view.opacity(0.65)
                        }
                        .lineLimit(1)
                        .frame(width: 120, alignment: .leading)
                    Spacer()
                    
                    /*centerText
                        .font(.caption)*/
                    
                    Spacer()
                    Text(bout.uRight.uName)
                        .font(.caption)
                        .foregroundColor(!pool.isTracked(fencer: bout.uRight) ? .secondary : Color.teal)
                        .if(pool.isTracked(fencer: bout.uRight)) { view in
                            view.opacity(0.65)
                        }
                        .lineLimit(1)
                        .frame(width: 120, alignment: .trailing)
                    Text("\(bout.uRight.uNumber+1)")
                        .foregroundColor(!pool.isTracked(fencer: bout.uRight) ? .primary : Color.teal)
                }
                .contextMenu {
                    
                    if pool.getCurrentBout() != bout {
                        jumpToBoutButton(pool: pool, bout: bout)
                    }
                    
                    if pool.isBoutTracked(bout: bout) {
                        Section {
                            editBoutButtons(pool: pool, bout: bout, yourScore: $yourScore, opponentScore: $opponentScore, scoreBout: $scoreBout, showingEditScore: $showingEditScore)
                        }
                    }
                }
            }
            .id(bout)
            .listRowBackground((!pool.isTableComplete() && pool.getCurrentBout() == bout) ? Color.tertiaryGroupedBackground : Color.secondaryGroupedBackground)
        }
        
        struct jumpToBoutButton: View {
            @Environment(\.managedObjectContext) private var moc
            
            @ObservedObject var pool: Pool
            @ObservedObject var bout: Bout
            
            var body: some View {
                Button(action: {
                    jumpToBout(bout: bout)
                    try? moc.save()
                }) {
                    if pool.uCurrentBout > bout.num {
                        Image(systemName: "arrow.up.circle")
                    } else {
                        Image(systemName: "arrow.down.circle")
                    }
                    Text("Jump to Bout")
                }
            }
            
            func jumpToBout(bout: Bout) {
                if bout.num > pool.uCurrentBout {
                    for boutNum in pool.uCurrentBout ..< bout.num {
                        pool.uBouts[boutNum].isCompleted = true
                    }
                    pool.setCurrentBout(bout.num)
                } else if bout.num < pool.uCurrentBout {
                    for boutNum in bout.num ..< pool.uCurrentBout {
                        pool.uBouts[boutNum].isCompleted = false
                    }
                    pool.setCurrentBout(bout.num)
                }
            }
        } // Jumps to selected bout
        
        struct editBoutButtons: View {
            @ObservedObject var pool: Pool
            @ObservedObject var bout: Bout
            
            @Binding var yourScore: String
            @Binding var opponentScore: String
            @Binding var scoreBout: Bout?
            @Binding var showingEditScore: Bool
            
            var body: some View {
                if pool.isBoutTracked(bout: bout) {
                    Button(action: {
                        yourScore = ""; opponentScore = ""
                        scoreBout = bout
                        withAnimation { showingEditScore = true }
                    }) {
                        Image(systemName: "square.and.pencil")
                        Text("Input Score")
                    }
                    
                    if showingEditScore == true && scoreBout == bout {
                        Button(action: {
                            withAnimation { showingEditScore = false }
                        }) {
                            Image(systemName: "pencil.slash")
                            Text("Cancel Input")
                        }
                    }
                }
            }
        } // Edit bout
        
    } // Each item in bout list
    
    
    struct toolbarItems: View {
        @Environment(\.managedObjectContext) private var moc
        
        @ObservedObject var pool: Pool
        let proxy: ScrollViewProxy
        
        @Binding var yourScore: String
        @Binding var opponentScore: String
        @Binding var scoreBout: Bout?
        @Binding var showingEditScore: Bool
        
        var body: some View {
            Spacer()
            
            scrollToItem(pool: pool, proxy: proxy)
            
            Spacer()
            
            Group {
                
                backOneItem(pool: pool, proxy: proxy)
                    .environment(\.managedObjectContext, self.moc)
                
                Spacer().frame(width: 10)
                
                forwardOneItem(pool: pool, proxy: proxy)
                    .environment(\.managedObjectContext, self.moc)
                
            }
            
            Spacer()
            
            editScoreItem(yourScore: $yourScore, opponentScore: $opponentScore, scoreBout: $scoreBout, showingEditScore: $showingEditScore, pool: pool)
            
            Spacer()
        }
    } // Toolbar
    
    struct scrollToItem: View {
        @ObservedObject var pool: Pool
        let proxy: ScrollViewProxy
        
        var body: some View {
            Button(action: {
                withAnimation { proxy.scrollTo(pool.getCurrentBout(), anchor: .top) }
            }) {
                Image(systemName:"arrow.down.to.line")
                    .padding([.horizontal, .bottom])
            }
        }
    } // Scroll to item toolbar button
    
    struct backOneItem: View {
        @Environment(\.managedObjectContext) private var moc
        
        @ObservedObject var pool: Pool
        let proxy: ScrollViewProxy
        
        var body: some View {
            Button(action: {
                pool.currentBout -= 1
                try? moc.save()
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
                    try? moc.save()
                    withAnimation { proxy.scrollTo(pool.getCurrentBout()) }
                } label: {
                    Label("Jump to start", systemImage: "backward.fill")
                }
            }
        }
    } // Back one item toolbar button
    
    struct forwardOneItem: View {
        @Environment(\.managedObjectContext) private var moc
        
        @ObservedObject var pool: Pool
        let proxy: ScrollViewProxy
        
        var body: some View {
            Button(action: {
                if pool.currentBout < pool.uBouts.count {
                    pool.uBouts[pool.uCurrentBout].isCompleted = true
                    pool.currentBout += 1
                    try? moc.save()
                    withAnimation { proxy.scrollTo(pool.getCurrentBout()) }
                } else {
                    pool.uBouts[pool.uCurrentBout].isCompleted = true
                    pool.currentBout = Int16(pool.uBouts.count)
                    withAnimation { proxy.scrollTo(pool.uBouts.last) }
                    try? moc.save()
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
                    try? moc.save()
                    withAnimation { proxy.scrollTo(pool.getCurrentBout()) }
                } label: {
                    Label("Jump to end", systemImage: "forward.fill")
                }
            }
        }
    } // Forward one item toolbar button
    
    struct editScoreItem: View {
        @Binding var yourScore: String
        @Binding var opponentScore: String
        @Binding var scoreBout: Bout?
        @Binding var showingEditScore: Bool
        
        @ObservedObject var pool: Pool
        
        var body: some View {
            Button(action: {
                yourScore = ""; opponentScore = ""
                scoreBout = pool.uBouts[pool.uCurrentBout]
                withAnimation { showingEditScore.toggle() }
            }) {
                Image(systemName: "square.and.pencil")
                    .padding([.horizontal, .bottom])
            }
            .disabled(!pool.isBoutTracked(bout: pool.getCurrentBout()))
        }
    } // Edit score toolbar button
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
    func celll(size: CGFloat, isTracked: Bool) -> some View {
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
