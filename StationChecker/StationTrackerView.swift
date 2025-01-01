import SwiftUI
import WidgetKit

struct StationTrackerView: View {
    @State private var stations: [StationRecord] = []
    @State private var filteredStations: [StationRecord] = []
    @State private var searchQuery: String = ""
    @State private var showFilePicker: Bool = false
    @State private var showAddStationForm: Bool = false
    @State private var showFilterSheet: Bool = false
    @State private var showStatisticsView: Bool = false
    @State private var showDataOptionsSheet: Bool = false
    @State private var selectedDataType: StationDataType? = nil
    @State private var errorMessage: String? = nil

    // Filter State
    @State private var selectedCountry: String? = nil
    @State private var selectedCounty: String? = nil
    @State private var selectedTOC: String? = nil
    @State private var showOnlyVisited: Bool = false
    @State private var showOnlyNotVisited: Bool = false
    @State private var showOnlyFavorites: Bool = false

    var body: some View {
        NavigationView {
            VStack {
                // Search Bar
                TextField("Search stations...", text: $searchQuery)
                    .padding(10)
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
                    Text("No stations to display.\nImport a CSV file to get started.")
                        .multilineTextAlignment(.center)
                        .foregroundColor(.secondary)
                        .padding()
                } else {
                    List {
                        ForEach($filteredStations, id: \.id) { $station in
                            ZStack {
                                NavigationLink(
                                    destination: StationDetailView(
                                        station: $station, // Use the binding here
                                        onUpdate: { updatedStation in
                                            updateStation(updatedStation)
                                        }
                                    )
                                ) {
                                    EmptyView() // Invisible NavigationLink
                                }
                                .opacity(0) // Keeps the NavigationLink functional but invisible

                                StationCard(
                                    station: $station, // Pass binding to the station
                                    onUpdate: { updatedStation in
                                        updateStation(updatedStation)
                                    },
                                    onNavigate: {
                                        // Navigation logic or additional actions
                                    }
                                )
                            }
                        }
                        .onDelete { indices in
                            stations.remove(atOffsets: indices) // Remove from the original stations array
                            filterStations() // Reapply the filter
                        }
                    }
                    .listStyle(PlainListStyle())
                }
            }
            .navigationTitle("Station Tracker")
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    Button(action: { showStatisticsView = true }) {
                        Image(systemName: "chart.bar")
                    }
                    Button(action: { showFilterSheet = true }) {
                        Image(systemName: "line.horizontal.3.decrease.circle")
                    }
                    Button(action: { showDataOptionsSheet = true }) {
                        Image(systemName: "ellipsis.circle")
                    }
                }
            }
            .sheet(isPresented: $showAddStationForm) {
                AddStationForm(onAddStation: { newStation in
                    addStation(newStation)
                })
            }
            .sheet(isPresented: $showFilterSheet) {
                FilterSheet(
                    countries: Array(Set(stations.map { $0.country })).sorted(),
                    counties: Array(Set(stations.map { $0.county })).sorted(),
                    tocs: Array(Set(stations.map { $0.toc })).sorted(),
                    selectedCountry: $selectedCountry,
                    selectedCounty: $selectedCounty,
                    selectedTOC: $selectedTOC,
                    showOnlyVisited: $showOnlyVisited,
                    showOnlyNotVisited: $showOnlyNotVisited,
                    showOnlyFavorites: $showOnlyFavorites,
                    onApply: filterStations
                )
            }
            .sheet(isPresented: $showStatisticsView) {
                StatisticsView(stations: stations)
            }
            .sheet(isPresented: $showDataOptionsSheet) {
                DataOptionsSheet(
                    onImport: { dataType in
                        selectedDataType = dataType
                        showFilePicker = true
                    },
                    onExport: { dataType in
                        exportCSV(for: dataType)
                    },
                    onClearData: {
                        // Clear the stations array and any persisted data
                        stations.removeAll()  // Clear the stations array from the current view
                        StationDataManager.shared.clearStations()  // Ensure persistent data is cleared from StationDataManager
                        print("All data cleared.")
                    },
                    onAddStation: {
                        showAddStationForm = true
                    }
                )
            }
            .fileImporter(
                isPresented: $showFilePicker, // Ensure `showFilePicker` is defined as a `@State` property
                allowedContentTypes: [.commaSeparatedText],
                allowsMultipleSelection: false
            ) { result in
                handleFilePicker(result: result)
            }
        }
    }

    // MARK: - Helper Methods

    private func filterStations() {
        filteredStations = stations.filter { station in
            // Country Filter
            if let country = selectedCountry, station.country != country {
                return false
            }
            // County Filter
            if let selectedCounty = selectedCounty, station.county != selectedCounty {
                return false
            }
            // TOC Filter
            if let toc = selectedTOC, station.toc != toc {
                return false
            }
            // Visited Filter
            if showOnlyVisited && !station.visited {
                return false
            }
            // Not Visited Filter
            if showOnlyNotVisited && station.visited {
                return false
            }
            // Favorites Filter
            if showOnlyFavorites && !station.isFavorite {
                return false
            }
            // Search Query Filter
            if !searchQuery.isEmpty {
                return station.stationName.localizedCaseInsensitiveContains(searchQuery) ||
                       station.country.localizedCaseInsensitiveContains(searchQuery) ||
                       station.county.localizedCaseInsensitiveContains(searchQuery) ||
                       station.toc.localizedCaseInsensitiveContains(searchQuery)
            }
            return true
        }
    }

    private func addStation(_ newStation: StationRecord) {
        stations.append(newStation)
        filterStations()
    }

    private func updateStation(_ updatedStation: StationRecord) {
        if let index = stations.firstIndex(where: { $0.id == updatedStation.id }) {
            stations[index] = updatedStation
        }
    }

    private func deleteStation(at offsets: IndexSet) {
        stations.remove(atOffsets: offsets)
        filterStations()
    }

    private func handleFilePicker(result: Result<[URL], Error>) {
        switch result {
        case .success(let urls):
            guard let fileURL = urls.first else {
                print("No file selected.")
                return
            }

            guard fileURL.startAccessingSecurityScopedResource() else {
                print("Permission denied for file: \(fileURL)")
                return
            }

            defer { fileURL.stopAccessingSecurityScopedResource() }

            // Parse the CSV and get the imported stations
            let importedStations = StationDataManager.shared.parseCSV(from: fileURL, for: .nationalRail)
            if importedStations.isEmpty {
                print("Failed to parse the National Rail CSV file.")
            } else {
                print("Successfully imported \(importedStations.count) stations.")
                // Append the imported stations to the list
                stations.append(contentsOf: importedStations)
                // Call filterStations to update the filtered list
                filterStations()
                
                // Debugging: Print the filtered stations' names to ensure they are added correctly
                print("Filtered Stations: \(filteredStations.map { $0.stationName })")
            }
        case .failure(let error):
            print("Error importing file: \(error.localizedDescription)")
        }
    }

    private func exportCSV(for dataType: StationDataType) {
        if let exportedFileURL = StationDataManager.shared.exportStationsToCSV(stations: stations, for: dataType) {
            if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let rootViewController = scene.windows.first?.rootViewController {
                let activityVC = UIActivityViewController(activityItems: [exportedFileURL], applicationActivities: nil)
                rootViewController.present(activityVC, animated: true)
            }
        } else {
            errorMessage = "Failed to export \(dataType.displayName) CSV."
        }
    }

    private func loadStations() {
        // Load the stations from data manager or wherever your data is stored
        stations = StationDataManager.shared.loadStationsFromDisk()
    }

    private func saveStatisticsToSharedContainer() {
        guard let sharedDefaults = UserDefaults(suiteName: "group.com.gbr.statistics") else {
            print("Shared defaults not found")
            return
        }

        let totalStations = stations.count
        let visitedStations = stations.filter { $0.visited }.count
        let notVisitedStations = totalStations - visitedStations
        let percentageVisited = totalStations > 0 ? (Double(visitedStations) / Double(totalStations)) * 100 : 0.0

        sharedDefaults.set(totalStations, forKey: "totalStations")
        sharedDefaults.set(visitedStations, forKey: "visitedStations")
        sharedDefaults.set(notVisitedStations, forKey: "notVisitedStations")
        sharedDefaults.set(percentageVisited, forKey: "percentageVisited")

        WidgetCenter.shared.reloadAllTimelines()
    }
}
