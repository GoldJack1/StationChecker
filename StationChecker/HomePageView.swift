import SwiftUI

struct HomePageView: View {
    @Environment(\.horizontalSizeClass) var horizontalSizeClass

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 30) {
                    // Header
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Welcome to Station Tracker")
                            .font(.largeTitle)
                            .fontWeight(.bold)

                        Text("Easily track and explore various transportation networks.")
                            .font(.title2)
                            .foregroundColor(.secondary)
                    }
                    .padding(.horizontal)

                    // Tracker Options
                    if horizontalSizeClass == .compact {
                        VStack(alignment: .leading, spacing: 20) {
                            TrackerCard(
                                title: "Great Britain",
                                subtitle: "Track stations visited across Great Britain.",
                                pngName: "gbnr",
                                destination: UKNatRailTrackerView()
                            )

                            TrackerCard(
                                title: "Northern Ireland",
                                subtitle: "Coming soon.",
                                pngName: "nir",
                                destination: PlaceholderView(title: "Northern Ireland Tracker")
                            )

                            TrackerCard(
                                title: "Ireland",
                                subtitle: "Coming soon.",
                                pngName: "irerail",
                                destination: PlaceholderView(title: "Ireland Tracker")
                            )

                            TrackerCard(
                                title: "Manchester Metrolink",
                                subtitle: "Coming soon.",
                                pngName: "manbeenet",
                                destination: PlaceholderView(title: "Manchester Metrolink Tracker")
                            )
                        }
                        .padding(.horizontal)
                    } else {
                        LazyVGrid(
                            columns: [GridItem(.adaptive(minimum: 300), spacing: 20)],
                            spacing: 30
                        ) {
                            TrackerCard(
                                title: "Great Britain",
                                subtitle: "Track stations visited across Great Britain.",
                                pngName: "gbnr",
                                destination: UKNatRailTrackerView()
                            )

                            TrackerCard(
                                title: "Northern Ireland",
                                subtitle: "Coming soon.",
                                pngName: "nir",
                                destination: PlaceholderView(title: "Northern Ireland Tracker")
                            )

                            TrackerCard(
                                title: "Ireland",
                                subtitle: "Coming soon.",
                                pngName: "irerail",
                                destination: PlaceholderView(title: "Ireland Tracker")
                            )

                            TrackerCard(
                                title: "Manchester Metrolink",
                                subtitle: "Coming soon.",
                                pngName: "manbeenet",
                                destination: PlaceholderView(title: "Manchester Metrolink Tracker")
                            )
                        }
                        .padding()
                    }
                }
                .padding(.top, 20)
            }
            .background(Color(.systemGroupedBackground).ignoresSafeArea())
            .navigationBarHidden(true) // Hides the navigation bar entirely
        }
        .navigationViewStyle(StackNavigationViewStyle()) // Prevents sidebar behavior
    }
}

// MARK: - Tracker Card Component
struct TrackerCard<Destination: View>: View {
    let title: String
    let subtitle: String
    let pngName: String
    let destination: Destination

    var body: some View {
        NavigationLink(destination: destination) {
            HStack(alignment: .top, spacing: 15) {
                Image(pngName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 50, height: 50)

                VStack(alignment: .leading, spacing: 5) {
                    Text(title)
                        .font(.headline)
                        .foregroundColor(.primary)

                    Text(subtitle)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.leading)
                }
                Spacer()
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color(.systemBackground))
                    .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 5)
            )
        }
    }
}

// MARK: - Placeholder View
struct PlaceholderView: View {
    let title: String

    var body: some View {
        VStack {
            Text(title)
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding()

            Text("This feature is coming soon.")
                .font(.title2)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemGroupedBackground).ignoresSafeArea())
    }
}

struct HomePageView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            HomePageView()
                .previewDevice("iPhone 14")
            HomePageView()
                .previewDevice("iPad Pro (12.9-inch) (6th generation)")
        }
    }
}
