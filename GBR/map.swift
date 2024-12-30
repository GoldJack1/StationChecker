import SwiftUI

struct Map: View {
    @State private var isLoading: Bool = true // Track loading state
    @State private var scale: CGFloat = 4.0 // Default zoom level (4x)
    @State private var offset: CGSize = .zero // Current drag offset
    @State private var lastOffset: CGSize = .zero // Accumulated drag offset
    @State private var anchorPoint: UnitPoint = .center // Anchor point for zooming
    @State private var gestureAnchor: UnitPoint = .center // Anchor for the pinch gesture

    var body: some View {
        NavigationStack {
            ZStack {
                Color.white.ignoresSafeArea() // Set background color to white

                if isLoading {
                    // Show a placeholder or progress indicator
                    VStack {
                        ProgressView("Loading map...") // iOS default loading spinner
                            .progressViewStyle(CircularProgressViewStyle())
                            .tint(.gray) // Set spinner color to light mode gray
                            .padding()
                        Spacer()
                    }
                } else {
                    GeometryReader { geometry in
                        let screenSize = geometry.size

                        Image("map") // Lazy-loaded map image
                            .resizable()
                            .scaledToFit()
                            .frame(width: screenSize.width, height: screenSize.height)
                            .clipped()
                            .scaleEffect(scale, anchor: anchorPoint) // Apply zoom with dynamic anchor
                            .offset(x: offset.width, y: offset.height) // Apply pan offset
                            .gesture(
                                SimultaneousGesture(
                                    MagnificationGesture()
                                        .onChanged { value in
                                            let zoomDampening: CGFloat = 0.7

                                            // Dynamically calculate the anchor point for zoom
                                            anchorPoint = gestureAnchor
                                            scale = max(3.0, min(10.0, scale + (value - 1.0) * zoomDampening))
                                        }
                                        .onEnded { _ in },
                                    DragGesture()
                                        .onChanged { value in
                                            // Update the offset dynamically during drag
                                            offset = CGSize(
                                                width: lastOffset.width + value.translation.width,
                                                height: lastOffset.height + value.translation.height
                                            )
                                        }
                                        .onEnded { value in
                                            lastOffset = offset // Save the final offset
                                        }
                                )
                            )
                            .gesture(
                                DragGesture(minimumDistance: 0)
                                    .onChanged { value in
                                        // Calculate the anchor point for zoom based on the gesture location
                                        let gestureLocation = value.location
                                        gestureAnchor = UnitPoint(
                                            x: gestureLocation.x / screenSize.width,
                                            y: gestureLocation.y / screenSize.height
                                        )
                                    }
                            )
                    }
                }
            }
            .onAppear {
                loadMap() // Simulate delayed image load
            }
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarLeading) {
                    HStack(spacing: 8) {
                        // Custom Back Button
                        NavigationLink(destination: HomePageView()) {
                            Image("Group 37")
                                .resizable()
                                .frame(width: 37, height: 37)
                        }
                        // Custom Title
                        Text("Map View")
                            .font(.title3)
                            .foregroundColor(.black)
                    }
                }
            }
            .toolbarBackground(Color.yellow, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .navigationBarBackButtonHidden(true)
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    // Simulate loading the map with a delay
    private func loadMap() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { // 1.5s delay
            isLoading = false
        }
    }
}
