import SwiftUI
import WidgetKit
import UniformTypeIdentifiers

struct StationTrackerView: View {
    @State private var stations: [StationRecord] = [] {
        didSet {
            StationDataManager.shared.saveStationsToDisk(stations)
            saveStatisticsToSharedContainer() // Ensure widget statistics are updated
        }
    }
    @State private var filteredStations: [StationRecord] = []
    @State private var searchQuery: String = ""
    @State private var showFilePicker: Bool = false
    @State private var showAddStationForm: Bool = false
    @State private var showFilterSheet: Bool = false
    @State private var showStatisticsView: Bool = false
    @State private var showDataOptionsSheet: Bool = false
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
                        ForEach(filteredStations) { station in
                            StationCard(
                                station: station,
                                onUpdate: updateStation,
                                onNavigate: {
                                    // Navigate to StationDetailView
                                    let destination = StationDetailView(station: station, onUpdate: updateStation)
                                    // Provide navigation logic here (e.g., using a NavigationLink or manual push)
                                }
                            )
                        }
                        .onDelete(perform: deleteStation)
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
                    onImport: { dismissDataOptionsAndTriggerImport() },
                    onExport: { dismissDataOptionsAndTriggerExport() },
                    onClearData: { dismissDataOptionsAndClearData() },
                    onAddStation: { showAddStationForm = true } // Show the Add Station form
                )
            }
            .fileImporter(
                isPresented: $showFilePicker,
                allowedContentTypes: [UTType.commaSeparatedText],
                allowsMultipleSelection: false
            ) { result in
                handleFileImport(result: result)
            }
            .onAppear {
                loadStations()
                filterStations()
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
        filterStations() // Update the filtered list after adding
    }

    private func updateStation(_ updatedStation: StationRecord) {
        if let index = stations.firstIndex(where: { $0.id == updatedStation.id }) {
            stations[index] = updatedStation
            filterStations()
        }
    }

    private func deleteStation(at offsets: IndexSet) {
        stations.remove(atOffsets: offsets)
        filterStations()
    }

    private func handleFileImport(result: Result<[URL], Error>) {
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

            let importedStations = StationDataManager.shared.parseCSV(from: fileURL)
            if importedStations.isEmpty {
                errorMessage = "Failed to parse the CSV file. Ensure it is formatted correctly."
            } else {
                errorMessage = nil
                stations.append(contentsOf: importedStations)
                filterStations()
            }
        case .failure(let error):
            errorMessage = "Error importing file: \(error.localizedDescription)"
        }
    }

    private func dismissDataOptionsAndTriggerImport() {
        showDataOptionsSheet = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            showFilePicker = true
        }
    }

    private func dismissDataOptionsAndTriggerExport() {
        showDataOptionsSheet = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            exportCSV()
        }
    }

    private func dismissDataOptionsAndClearData() {
        showDataOptionsSheet = false
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            stations.removeAll()
            StationDataManager.shared.clearStations()
            filterStations()
        }
    }

    private func exportCSV() {
        if let exportedFileURL = StationDataManager.shared.exportStationsToCSV(stations: stations) {
            if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let rootViewController = scene.windows.first?.rootViewController {
                let activityVC = UIActivityViewController(activityItems: [exportedFileURL], applicationActivities: nil)
                rootViewController.present(activityVC, animated: true)
            }
        } else {
            print("Failed to export CSV.")
        }
    }

    private func loadStations() {
        stations = StationDataManager.shared.loadStationsFromDisk()
        filterStations()
    }

    private func saveStatisticsToSharedContainer() {
        let sharedDefaults = UserDefaults(suiteName: "group.com.gbr.statistics")
        guard let sharedDefaults = sharedDefaults else {
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
        sharedDefaults.synchronize() // Save changes immediately

        print("Statistics updated in shared container")

        // Reload widget timeline to reflect changes
        WidgetCenter.shared.reloadAllTimelines()
    }
}
