import SwiftUI
import WidgetKit

struct UKNatRailTrackerView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var stations: [UKNatRailRecord] = []
    @State private var filteredUKNatRails: [UKNatRailRecord] = []
    @State private var searchQuery: String = ""
    @State private var showFilePicker: Bool = false
    @State private var showAddStationForm: Bool = false
    @State private var showFilterSheet: Bool = false
    @State private var showStatisticsView: Bool = false
    @State private var showDataOptionsSheet: Bool = false
    @State private var selectedDataType: DataType? = nil
    @State private var errorMessage: String? = nil
    @State private var debounceWorkItem: DispatchWorkItem?

    // Filter State
    @State private var selectedCountry: String? = nil
    @State private var selectedCounty: String? = nil
    @State private var selectedTOC: String? = nil
    @State private var showOnlyVisited: Bool = false
    @State private var showOnlyNotVisited: Bool = false
    @State private var showOnlyFavorites: Bool = false

    var body: some View {
        VStack(spacing: 0) {
            // Custom Header
            VStack(spacing: 0) {
                // First Row: Back Button and Page Title
                HStack {
                    // Back Button
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Image(systemName: "chevron.left")
                            .font(.title3)
                            .padding(10)
                            .background(Circle().fill(Color(.systemGray5)))
                            .foregroundColor(.primary)
                    }

                    Spacer()

                    // Page Title
                    Text("GB National Rail")
                        .font(.title)
                        .bold()
                        .foregroundColor(.primary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding(.horizontal)
                .padding(.top, 10)
                .padding(.bottom, 5)
                .background(Color(.systemGray6))
                .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)

                // Second Row: Search Bar and Buttons
                HStack {
                    // Search Bar
                    TextField("Search Stations", text: $searchQuery)
                        .padding(10)
                        .background(Color(.systemGray5))
                        .cornerRadius(25)
                        .onChange(of: searchQuery) { oldValue, newValue in
                            debounceFilter()
                        }

                    // Add Station Button
                    Button(action: { showAddStationForm = true }) {
                        Image(systemName: "plus")
                            .font(.title3)
                            .padding(10)
                            .background(Circle().fill(Color(.systemGray5)))
                            .foregroundColor(.primary)
                    }

                    // Statistics Button
                    Button(action: { showStatisticsView = true }) {
                        Image(systemName: "chart.bar")
                            .font(.title3)
                            .padding(10)
                            .background(Circle().fill(Color(.systemGray5)))
                            .foregroundColor(.primary)
                    }

                    // Filter Button
                    Button(action: { showFilterSheet = true }) {
                        Image(systemName: "line.horizontal.3.decrease.circle")
                            .font(.title3)
                            .padding(10)
                            .background(Circle().fill(Color(.systemGray5)))
                            .foregroundColor(.primary)
                    }

                    // Import/Export Button
                    Button(action: { showDataOptionsSheet = true }) {
                        Image(systemName: "square.and.arrow.up")
                            .font(.title3)
                            .padding(10)
                            .background(Circle().fill(Color(.systemGray5)))
                            .foregroundColor(.primary)
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 10)
                .background(Color(.systemGray6))
            }

            // Content
            if let errorMessage = errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .padding()
            } else if filteredUKNatRails.isEmpty {
                VStack {
                    Spacer()
                    Text("No stations to display.\nImport a CSV file to get started.")
                        .multilineTextAlignment(.center)
                        .foregroundColor(.secondary)
                        .padding()
                    Spacer()
                }
            } else {
                List {
                    ForEach($filteredUKNatRails, id: \.id) { $station in
                        ZStack {
                            NavigationLink(
                                destination: UKNatRailDetailView(
                                    station: $station,
                                    onUpdate: { updatedUKNatRail in
                                        updateUKNatRail(updatedUKNatRail)
                                    }
                                )
                            ) {
                                EmptyView()
                            }
                            .opacity(0)

                            UKNatRailCard(
                                station: $station,
                                onUpdate: { updatedUKNatRail in
                                    updateUKNatRail(updatedUKNatRail)
                                },
                                onNavigate: { /* Add custom navigation actions if needed */ }
                            )
                        }
                    }
                    .onDelete { indices in
                        deleteUKNatRail(at: indices)
                    }
                }
                .listStyle(PlainListStyle())
            }
        }
        .navigationBarHidden(true) // Ensure the default navigation bar is hidden
        .toolbar(.hidden) // Ensures toolbar doesn't appear
        .onAppear {
            loadUKNatRails()
        }
        .sheet(isPresented: $showAddStationForm) {
            AddStationForm(onAddStation: { newStation in
                addUKNatRail(newStation)
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
                onApply: filterUKNatRails
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
                    stations.removeAll()
                    DataManager.shared.clearStations()
                    filterUKNatRails()
                },
                onAddStation: {
                    showAddStationForm = true
                }
            )
        }
        .fileImporter(
            isPresented: $showFilePicker,
            allowedContentTypes: [.commaSeparatedText],
            allowsMultipleSelection: false
        ) { result in
            handleFilePicker(result: result)
        }
    }

    // MARK: - Helper Methods

    private func filterUKNatRails() {
        filteredUKNatRails = stations.filter { station in
            if let country = selectedCountry, station.country != country { return false }
            if let selectedCounty = selectedCounty, station.county != selectedCounty { return false }
            if let toc = selectedTOC, station.toc != toc { return false }
            if showOnlyVisited && !station.visited { return false }
            if showOnlyNotVisited && station.visited { return false }
            if showOnlyFavorites && !station.isFavorite { return false }
            if !searchQuery.isEmpty {
                return station.stationName.localizedCaseInsensitiveContains(searchQuery) ||
                station.country.localizedCaseInsensitiveContains(searchQuery) ||
                station.county.localizedCaseInsensitiveContains(searchQuery) ||
                station.toc.localizedCaseInsensitiveContains(searchQuery)
            }
            return true
        }
    }
    
    private func addUKNatRail(_ newStation: UKNatRailRecord) {
        stations.append(newStation)
        DataManager.shared.saveStationsToDisk(stations)
        DataManager.shared.saveStatisticsToSharedContainer(stations: stations)
        filterUKNatRails()
        print("[UKNatRailTrackerView] Added station: \(newStation.stationName). Total: \(stations.count).")
    }
    
    private func updateUKNatRail(_ updatedUKNatRail: UKNatRailRecord) {
        if let index = stations.firstIndex(where: { $0.id == updatedUKNatRail.id }) {
            stations[index] = updatedUKNatRail
            DataManager.shared.saveStationsToDisk(stations) // Save updated stations to disk
            DataManager.shared.saveStatisticsToSharedContainer(stations: stations) // Update widget statistics
            print("[UKNatRailTrackerView] Updated station: \(updatedUKNatRail.stationName). Visit status: \(updatedUKNatRail.visited).")
        }
    }
    
    private func deleteUKNatRail(at offsets: IndexSet) {
        stations.remove(atOffsets: offsets)
        DataManager.shared.saveStationsToDisk(stations)
        DataManager.shared.saveStatisticsToSharedContainer(stations: stations)
        filterUKNatRails()
        print("[UKNatRailTrackerView] Deleted station(s). Total: \(stations.count).")
    }
    
    private func debounceFilter() {
        // Cancel any existing debounce operation
        debounceWorkItem?.cancel()

        // Create a new debounce operation
        let workItem = DispatchWorkItem {
            filterUKNatRails()
        }

        // Store the work item and execute it after a delay
        debounceWorkItem = workItem
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3, execute: workItem)
    }
    
    private func exportCSV(for dataType: DataType) {
        if let exportedFileURL = DataManager.shared.exportStationsToCSV(stations: stations, for: dataType) {
            // Present the exported file using a UIActivityViewController
            if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let rootViewController = scene.windows.first?.rootViewController {
                let activityVC = UIActivityViewController(activityItems: [exportedFileURL], applicationActivities: nil)
                rootViewController.present(activityVC, animated: true)
            }
        } else {
            errorMessage = "Failed to export \(dataType.displayName) CSV."
        }
    }
    
    private func handleFilePicker(result: Result<[URL], Error>) {
        switch result {
        case .success(let urls):
            guard let fileURL = urls.first else { return }
            guard fileURL.startAccessingSecurityScopedResource() else { return }
            defer { fileURL.stopAccessingSecurityScopedResource() }
            
            let importedStations = DataManager.shared.parseCSV(from: fileURL, for: .nationalRail)
            if !importedStations.isEmpty {
                stations.append(contentsOf: importedStations)
                DataManager.shared.saveStationsToDisk(stations)
                print("[UKNatRailTrackerView] Imported \(importedStations.count) stations.")
                filterUKNatRails()
                saveStatisticsToSharedContainer()
            }
        case .failure(let error):
            print("[UKNatRailTrackerView] File picker error: \(error.localizedDescription)")
        }
    }
    
    private func loadUKNatRails() {
        stations = DataManager.shared.loadStationsFromDisk()
        print("[UKNatRailTrackerView] Loaded \(stations.count) stations.")
        filterUKNatRails()
    }
    
    private func saveStatisticsToSharedContainer() {
        guard let sharedDefaults = UserDefaults(suiteName: "group.com.gbr.statistics") else {
            print("[UKNatRailTrackerView] Shared defaults not found.")
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
        
        // Notify widget to reload its timeline
        WidgetCenter.shared.reloadAllTimelines()
        print("[UKNatRailTrackerView] Statistics saved and widget timeline reloaded.")
    }
}
