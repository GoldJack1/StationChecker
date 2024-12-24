//
//  ContentView.swift
//  GBR
//
//  Created by Jack Wingate on 24/12/2024.
//

import SwiftUI

struct landingpage: View {
    var body: some View {NavigationStack { // Wrap everything in NavigationStack
        ZStack {
            Color.yellow
                .ignoresSafeArea()
            
            VStack (spacing: 40){
                Image("arrow") // Replace with your asset name
                    .resizable()
                    .scaledToFit()
                    .frame(height: 200)
                
                Text("Welcome to GBR")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(Color.black)
                
                NavigationLink(destination:Map()) { // Navigate to NextPageView
                    Text("Get Started")
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.black)
                        .cornerRadius(8)
                        .foregroundColor(.white)
                        .padding(.horizontal, 20)
                }
                .padding()
            }
        }
    }
    }
}
