//
//  BoardingPage.swift
//  Fencing
//
//  Created by Ben K on 7/13/21.
//

import SwiftUI

struct BoardingPage: View {
    @Binding var showingLanding: Bool
    
    @State private var tab = 0
    @State private var isLastItem = false
    
    var body: some View {
        ZStack {
            
            TabView(selection: $tab) {
                BoardingItem(text: "Hello", tab: $tab)
                    .tag(0)
                BoardingItem(text: "Goodbye", tab: $tab)
                    .tag(1)
                BoardingItem(text: "Three", tab: $tab)
                    .tag(2)
                    .redacted(reason: .placeholder)
            }
            .tabViewStyle(PageTabViewStyle())
            .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .always))
            
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Button(action: {
                        if !isLastItem {
                            withAnimation { tab += 1 }
                        } else {
                            showingLanding = false
                        }
                    }) {
                        Image(systemName: "chevron.right")
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.blue)
                            .clipShape(Circle())
                            .rotationEffect(.degrees(!isLastItem ? 0 : 90))
                    }
                    .padding(20)
                }
            }
        }
        .onChange(of: tab) { _ in
            withAnimation {
                if tab >= 2 {
                    isLastItem = true
                } else {
                    isLastItem = false
                }
            }
        }
    }
}

struct BoardingItem: View {
    let text: String
    @Binding var tab: Int
    
    var body: some View {
        VStack {
            Image("IMG_Page1")
                .resizable()
                .scaledToFit()
                .padding(30)
                .clipShape(RoundedRectangle(cornerRadius: 40))
                .shadow(radius: 20)
            
            Spacer().frame(height: 20)
            
            HStack {
                Text(text)
                    .font(.title)
                    .bold()
                
                Spacer()
            }
            .padding(.horizontal, 40)
            
            HStack {
                Text("Create something something something")
                    .font(.callout)
                    .italic()
                
                Spacer()
            }
            .padding(.top, 5)
            .padding(.horizontal, 40)
            
            Spacer()
        }
    }
}

struct BoardingPage_Previews: PreviewProvider {
    static var previews: some View {
        BoardingPage(showingLanding: .constant(true))
    }
}
