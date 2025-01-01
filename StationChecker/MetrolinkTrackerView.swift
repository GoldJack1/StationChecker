import SwiftUI

struct MetrolinkTrackerView: View {
    @State private var metrolinkStations: [MetrolinkStationRecord] = []
    @State private var filteredStations: [MetrolinkStationRecord] = []
    @State private var searchQuery: String = ""
    @State private var errorMessage: String? = nil

    // Navigation overlay state
    @State private var isMenuVisible = false
    @State private var navigateToStationTracker = false

    @State private var showFilterSheet: Bool = false
    @State private var showDataOptionsSheet: Bool = false

    // Filtering state
    @State private var showOnlyVisited: Bool = false
    @State private var showOnlyNotVisited: Bool = false
    @State private var showOnlyFavorites: Bool = false

    var body: some View {
        ZStack {
            NavigationView {
                VStack {
                    // Search Bar
                    TextField("Search Metrolink stations...", text: $searchQuery)
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
                        Text("No Metrolink stations to display.")
                            .multilineTextAlignment(.center)
                            .foregroundColor(.secondary)
                            .padding()
                    } else {
                        List {
                            ForEach(filteredStations, id: \.id) { station in
                                MetrolinkStationCard(
                                    station: station,
                                    onUpdate: { updatedStation in updateStation(updatedStation) },
                                    onNavigate: {
                                        // Handle navigation logic if needed
                                    }
                                )
                            }
                            .onDelete { indices in
                                deleteStations(at: indices)
                            }
                        }
                        .listStyle(PlainListStyle())
                    }
                }
                .navigationTitle("Metrolink Tracker")
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button(action: {
                            withAnimation {
                                isMenuVisible.toggle()
                            }
                        }) {
                            Image(systemName: "line.horizontal.3")
                                .imageScale(.large)
                        }
                    }

                    ToolbarItemGroup(placement: .navigationBarTrailing) {
                        Button("Filters") {
                            showFilterSheet = true
                        }
                        Button("Options") {
                            showDataOptionsSheet = true
                        }
                    }
                }
                .onAppear {
                    loadStations()
                }
            }

            // Navigation Overlay
            NavigationOverlayView(
                isVisible: $isMenuVisible,
                onNavigateToStationTracker: {
                    isMenuVisible = false
                    navigateToStationTracker = true
                },
                onNavigateToMetrolinkTracker: {
                    isMenuVisible = false
                    // Already on Metrolink Tracker
                }
            )

            // Navigation Link to Station Tracker
            NavigationLink(
                destination: StationTrackerView(),
                isActive: $navigateToStationTracker
            ) {
                EmptyView()
            }
        }
        .sheet(isPresented: $showDataOptionsSheet) {
            DataOptionsSheet(
                onImport: { dataType in
                    guard dataType == .metrolink else { return }
                    showDataOptionsSheet = false
                },
                onExport: { dataType in
                    guard dataType == .metrolink else { return }
                    // Add export logic if needed
                },
                onClearData: {
                    metrolinkStations.removeAll()
                    StationDataManager.shared.saveMetrolinkStations(metrolinkStations)
                    filterStations()
                },
                onAddStation: {
                    // Metrolink does not currently support manual station addition
                    errorMessage = "Manual station addition is not supported for Metrolink."
                }
            )
        }
        .sheet(isPresented: $showFilterSheet) {
            FilterSheet(
                countries: [], // Metrolink has no country filter
                counties: [], // Metrolink has no county filter
                tocs: [], // Metrolink does not filter by TOC
                selectedCountry: .constant(nil),
                selectedCounty: .constant(nil),
                selectedTOC: .constant(nil),
                showOnlyVisited: $showOnlyVisited,
                showOnlyNotVisited: $showOnlyNotVisited,
                showOnlyFavorites: $showOnlyFavorites,
                onApply: filterStations
            )
        }
    }

    // MARK: - Helper Methods

    func filterStations() {
        filteredStations = metrolinkStations.filter { station in
            if showOnlyVisited && !station.visited {
                return false
            }
            if showOnlyNotVisited && station.visited {
                return false
            }
            if showOnlyFavorites && !station.isFavorite {
                return false
            }
            if !searchQuery.isEmpty {
                return station.stationName.localizedCaseInsensitiveContains(searchQuery)
            }
            return true
        }
    }

    func loadStations() {
        metrolinkStations = StationDataManager.shared.loadMetrolinkStations()
        filterStations()
    }

    func updateStation(_ updatedStation: MetrolinkStationRecord) {
        if let index = metrolinkStations.firstIndex(where: { $0.id == updatedStation.id }) {
            metrolinkStations[index] = updatedStation
            StationDataManager.shared.saveMetrolinkStations(metrolinkStations)
            filterStations()
        }
    }

    func deleteStations(at offsets: IndexSet) {
        metrolinkStations.remove(atOffsets: offsets)
        StationDataManager.shared.saveMetrolinkStations(metrolinkStations)
        filterStations()
    }
}
