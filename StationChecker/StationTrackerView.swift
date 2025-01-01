import SwiftUI

struct StationTrackerView: View {
    @State private var stations: [StationRecord] = []
    @State private var filteredStations: [StationRecord] = []
    @State private var searchQuery: String = ""
    @State private var errorMessage: String? = nil
    @State private var showFilterSheet: Bool = false
    @State private var showDataOptionsSheet: Bool = false

    // Navigation States
    @State private var navigateToMetrolinkTracker = false
    @State private var isMenuVisible = false

    var body: some View {
        ZStack {
            NavigationView {
                VStack {
                    // Search Bar
                    TextField("Search stations...", text: $searchQuery)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                        .padding(.horizontal)
                        .onChange(of: searchQuery) { _ in
                            filterStations()
                        }

                    if let errorMessage = errorMessage {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .padding()
                    } else if filteredStations.isEmpty {
                        Text("No stations to display.")
                            .multilineTextAlignment(.center)
                            .foregroundColor(.secondary)
                            .padding()
                    } else {
                        List {
                            ForEach($filteredStations, id: \.id) { $station in
                                ZStack {
                                    NavigationLink(
                                        destination: StationDetailView(
                                            station: $station,
                                            onUpdate: { updatedStation in updateStation(updatedStation) }
                                        )
                                    ) {
                                        EmptyView()
                                    }
                                    .opacity(0)

                                    StationCard(
                                        station: $station,
                                        onUpdate: { updatedStation in updateStation(updatedStation) },
                                        onNavigate: { }
                                    )
                                }
                            }
                            .onDelete { indices in
                                stations.remove(atOffsets: indices)
                                filterStations()
                            }
                        }
                        .listStyle(PlainListStyle())
                    }
                }
                .navigationTitle("Station Tracker")
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button(action: {
                            withAnimation {
                                isMenuVisible.toggle()
                            }
                        }) {
                            Image(systemName: "line.horizontal.3")
                        }
                    }

                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Options") {
                            showDataOptionsSheet = true
                        }
                    }
                }
            }

            // Navigation Overlay
            NavigationOverlayView(
                isVisible: $isMenuVisible,
                onNavigateToStationTracker: {
                    isMenuVisible = false
                    // Already on Station Tracker
                },
                onNavigateToMetrolinkTracker: {
                    isMenuVisible = false
                    navigateToMetrolinkTracker = true
                }
            )

            // Navigation Link to Metrolink Tracker
            NavigationLink(
                destination: MetrolinkTrackerView(),
                isActive: $navigateToMetrolinkTracker
            ) {
                EmptyView()
            }
        }
        .sheet(isPresented: $showDataOptionsSheet) {
            DataOptionsSheet(
                onImport: { dataType in
                    if dataType == .metrolink {
                        navigateToMetrolinkTracker = true
                    }
                },
                onExport: { _ in },
                onClearData: {
                    stations.removeAll()
                    filterStations()
                },
                onAddStation: {
                    // Add station logic here
                }
            )
        }
    }

    // MARK: - Helper Methods

    func filterStations() {
        filteredStations = stations.filter { station in
            if !searchQuery.isEmpty {
                return station.stationName.localizedCaseInsensitiveContains(searchQuery)
            }
            return true
        }
    }

    func updateStation(_ updatedStation: StationRecord) {
        if let index = stations.firstIndex(where: { $0.id == updatedStation.id }) {
            stations[index] = updatedStation
            filterStations()
        }
    }
}
