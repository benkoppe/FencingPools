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
                BoardingItem(text: "Create Pools", description: "Quickly generate pools with just a URL.", tab: $tab)
                    .tag(0)
                BoardingItem(text: "Follow in real time", description: "Use the toolbar to move forwards and backwards through bouts, and to enter your scores.", tab: $tab)
                    .tag(1)
                BoardingItem(text: "And more!", description: "Customize in the settings menu, and hold names to access extra options.", tab: $tab)
                    .tag(2)
                    //.redacted(reason: .placeholder)
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
    let description: String
    @Binding var tab: Int
    
    var body: some View {
        VStack {
            Image("IMG_Page1")
                .resizable()
                .scaledToFit()
                .padding(30)
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .shadow(radius: 20)
            
            Spacer().frame(height: 20)
            
            HStack {
                Text(text)
                    .font(.title)
                    .foregroundColor(.blue)
                    .bold()
                Spacer()
            }
            .padding(.horizontal, 40)
            
            HStack {
                Text(description)
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
            .preferredColorScheme(.dark)
    }
}
