import SwiftUI

struct HomePageView: View {
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
                    VStack(alignment: .leading, spacing: 20) {
                        TrackerCard(
                            title: "GB National Rail",
                            subtitle: "Track stations visited across Great Britain.",
                            systemImage: "train.side.front.car",
                            destination: UKNatRailTrackerView()
                        )

                        TrackerCard(
                            title: "Northern Ireland",
                            subtitle: "Track stations visited across Northern Ireland.",
                            systemImage: "building.2.crop.circle",
                            destination: PlaceholderView(title: "Northern Ireland Tracker")
                        )

                        TrackerCard(
                            title: "Ireland",
                            subtitle: "Track stations visited across Ireland.",
                            systemImage: "ferry",
                            destination: PlaceholderView(title: "Ireland Tracker")
                        )

                        TrackerCard(
                            title: "Manchester Metrolink",
                            subtitle: "Track Stops visited on the Manchester Metrolink.",
                            systemImage: "tram",
                            destination: PlaceholderView(title: "Manchester Metrolink Tracker")
                        )
                    }
                    .padding(.horizontal)
                }
                .padding(.top, 20)
            }
            .background(Color(.systemGroupedBackground).ignoresSafeArea())
        }
    }
}

// MARK: - Tracker Card Component
struct TrackerCard<Destination: View>: View {
    let title: String
    let subtitle: String
    let systemImage: String
    let destination: Destination

    var body: some View {
        NavigationLink(destination: destination) {
            HStack(alignment: .top, spacing: 15) {
                Image(systemName: systemImage)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 50, height: 50)
                    .foregroundColor(.accentColor)

                VStack(alignment: .leading, spacing: 5) {
                    Text(title)
                        .font(.headline)
                        .foregroundColor(.primary)

                    Text(subtitle)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.leading) // Fix alignment
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
        HomePageView()
    }
}
