//
//  BracketView.swift
//  Fencing
//
//  Created by Ben K on 7/10/21.
//

import SwiftUI

struct BracketView: View {
    var boutedItems: [[[BracketItem]]] = []
    
    var body: some View {
        ScrollView {
            VStack {
                ForEach(boutedItems, id: \.self) { eight in
                    BracketOfEight(items: eight)
                    Spacer().frame(height: 350)
                }
            }
        }
    }
}

struct BracketView_Previews: PreviewProvider {
    static var previews: some View {
        BracketView()
    }
}
