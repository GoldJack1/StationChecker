import SwiftUI

struct HomePageView: View {
    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 20) {
                // Header
                Text("Welcome to Station Tracker")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.bottom, 10)

                Text("Choose a tracker to get started:")
                    .font(.title2)
                    .foregroundColor(.secondary)
                    .padding(.bottom, 20)

                // List View
                List {
                    Section(header: Text("UK National Rail")) {
                        NavigationLink(destination: UKNatRailTrackerView()) {
                            Label("UK National Rail Tracker", systemImage: "train.side.front.car")
                                .font(.headline)
                        }
                    }

                    Section(header: Text("Northern Ireland")) {
                        Button(action: {
                            print("Northern Ireland Tracker Placeholder")
                        }) {
                            Label("Northern Ireland Tracker", systemImage: "building.2.crop.circle")
                                .font(.headline)
                        }
                    }

                    Section(header: Text("Ireland")) {
                        Button(action: {
                            print("Ireland Tracker Placeholder")
                        }) {
                            Label("Ireland Tracker", systemImage: "ferry")
                                .font(.headline)
                        }
                    }

                    Section(header: Text("Manchester Metrolink")) {
                        Button(action: {
                            print("Manchester Metrolink Tracker Placeholder")
                        }) {
                            Label("Manchester Metrolink Tracker", systemImage: "tram")
                                .font(.headline)
                        }
                    }
                }
                .listStyle(InsetGroupedListStyle())
            }
            .padding()
            .navigationTitle("Home")
        }
    }
}

struct HomePageView_Previews: PreviewProvider {
    static var previews: some View {
        HomePageView()
    }
}
