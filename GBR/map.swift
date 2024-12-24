//
//  Map.swift
//  GBR
//
//  Created by Jack Wingate on 24/12/2024.
//

import SwiftUI

struct Map: View {
    // State variables to handle zooming and panning
    @State private var scale: CGFloat = 1.0 // Current scale (zoom level)
    @State private var offset: CGSize = .zero // Current drag offset
    @State private var lastOffset: CGSize = .zero // Accumulated offset after dragging ends

    var body: some View {
        NavigationStack {
            VStack {
                Spacer()

                // Zoomable and Movable Map Image
                GeometryReader { geometry in
                    Image("map")
                        .resizable()
                        .scaledToFit()
                        .scaleEffect(scale) // Apply zoom scale
                        .offset(x: offset.width, y: offset.height) // Apply drag offset
                        .gesture(
                            SimultaneousGesture(
                                MagnificationGesture()
                                    .onChanged { value in
                                        let zoomDampening: CGFloat = 0.5 // Adjust this value for sensitivity
                                        scale = max(1.0, scale + (value - 1.0) * zoomDampening)
                                    }
                                    .onEnded { value in
                                        scale = max(1.0, scale) // Ensure scale doesn’t go below 1.0
                                    },
                                DragGesture()
                                    .onChanged { value in
                                        offset = CGSize(
                                            width: lastOffset.width + value.translation.width,
                                            height: lastOffset.height + value.translation.height
                                        ) // Update the drag offset dynamically
                                    }
                                    .onEnded { value in
                                        lastOffset = offset // Save the final drag offset
                                    }
                            )
                        )
                        .animation(.spring(), value: offset) // Smooth transition for dragging
                        .animation(.spring(), value: scale) // Smooth transition for zooming
                }
                .edgesIgnoringSafeArea(.all) // Ensure it uses the full screen space

                Spacer()
            }
            .navigationBarBackButtonHidden(true) // Hide the default back button
            .toolbar {
                // Custom Back Button and Header
                ToolbarItemGroup(placement: .navigationBarLeading) {
                    HStack(spacing: 8) {
                        // Back Button
                        NavigationLink(destination: landingpage()) {
                            Image("Group 37")
                                .resizable()
                                .frame(width: 37, height: 37)
                        }

                        // Header Title
                        Text("Map View")
                            .font(.title2)
                            .foregroundColor(.black)
                    }
                }
            }
            .toolbarBackground(
                Color.yellow, // Set yellow background
                for: .navigationBar
            )
            .toolbarBackground(
                .visible, // Ensure visibility of the background
                for: .navigationBar
            )
        }
    }
}
