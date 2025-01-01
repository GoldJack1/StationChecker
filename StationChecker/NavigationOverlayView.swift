import SwiftUI

struct NavigationOverlayView: View {
    @Binding var isVisible: Bool
    var onNavigateToStationTracker: () -> Void
    var onNavigateToMetrolinkTracker: () -> Void

    var body: some View {
        ZStack {
            // Background Dimmer
            if isVisible {
                Color.black.opacity(0.5)
                    .ignoresSafeArea()
                    .onTapGesture {
                        withAnimation {
                            isVisible = false
                        }
                    }
            }

            // Slide-Out Menu
            HStack {
                VStack(alignment: .leading, spacing: 20) {
                    Button(action: {
                        withAnimation {
                            isVisible = false
                            onNavigateToStationTracker()
                        }
                    }) {
                        HStack {
                            Image(systemName: "list.bullet")
                            Text("General Stations")
                        }
                        .font(.headline)
                    }

                    Button(action: {
                        withAnimation {
                            isVisible = false
                            onNavigateToMetrolinkTracker()
                        }
                    }) {
                        HStack {
                            Image(systemName: "tram")
                            Text("Metrolink Tracker")
                        }
                        .font(.headline)
                    }

                    Spacer()
                }
                .padding(.top, 50)
                .padding(.horizontal, 20)
                .frame(maxWidth: 250)
                .background(Color.white)
                .ignoresSafeArea(edges: .vertical)
                .shadow(radius: 5)

                Spacer()
            }
            .offset(x: isVisible ? 0 : -250)
            .animation(.easeInOut, value: isVisible)
        }
        .opacity(isVisible ? 1 : 0)
    }
}
