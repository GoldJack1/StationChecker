import SwiftUI
import WidgetKit
import UniformTypeIdentifiers

struct StationTrackerView: View {
    @State private var stations: [StationRecord] = [] {
        didSet {
            saveStations()
            saveStatisticsToSharedContainer() // This ensures statistics are updated when stations change
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

            // County Filter (safely unwrap selectedCounty)
            if let selectedCounty = selectedCounty {
                let correctedCounty = getCorrectedCountyName(selectedCounty) ?? ""
                if station.county != correctedCounty {
                    return false
                }
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
            saveStations()
            saveStatisticsToSharedContainer() // Save updated statistics
            WidgetCenter.shared.reloadAllTimelines() // Trigger widget refresh
        }
    }

    private func deleteStation(at offsets: IndexSet) {
        stations.remove(atOffsets: offsets)
        filterStations()
    }

    private func handleFileImport(result: Result<[URL], Error>) {
        do {
            let selectedFiles = try result.get()
            guard let fileURL = selectedFiles.first else {
                print("No file selected.")
                return
            }

            guard fileURL.startAccessingSecurityScopedResource() else {
                print("Permission denied.")
                return
            }
            defer { fileURL.stopAccessingSecurityScopedResource() }

            let csvContent = try String(contentsOf: fileURL, encoding: .utf8)
            parseCSV(content: csvContent)
        } catch {
            print("Error: \(error.localizedDescription)")
        }
    }

    private func parseCSV(content: String) {
        var loadedStations: [StationRecord] = []

        let rows = content.components(separatedBy: "\n").dropFirst() // Skip header row
        let csvDelimiter = ","

        for row in rows {
            let columns = parseCSVRow(row: row, delimiter: csvDelimiter)

            guard columns.count >= 9 else { continue } // Ensure we have enough columns

            // Map county name to fix potential discrepancies
            let correctedCounty = getCorrectedCountyName(columns[2])

            let visited = columns[4].lowercased() == "yes"
            let visitDate = columns[5].isEmpty ? (visited ? Date() : nil) : dateFormatter.date(from: columns[5])

            let latitude = Double(columns[7]) ?? 0.0
            let longitude = Double(columns[8]) ?? 0.0

            let station = StationRecord(
                stationName: columns[0].replacingOccurrences(of: "\"", with: ""),
                country: columns[1].replacingOccurrences(of: "\"", with: ""),
                county: correctedCounty ?? columns[2].replacingOccurrences(of: "\"", with: ""),
                toc: columns[3].replacingOccurrences(of: "\"", with: ""),
                visited: visited,
                visitDate: visitDate,
                isFavorite: columns[6].lowercased() == "yes",
                latitude: latitude,
                longitude: longitude,
                usageData: parseUsageData(columns: Array(columns[9...]))
            )
            loadedStations.append(station)
        }

        stations = loadedStations
        filterStations()
    }

    private func parseCSVRow(row: String, delimiter: String) -> [String] {
        var fields: [String] = []
        var currentField = ""
        var insideQuotes = false
        
        for char in row {
            if char == "\"" {
                insideQuotes.toggle()
            } else if char == delimiter.first && !insideQuotes {
                fields.append(currentField)
                currentField = ""
            } else {
                currentField.append(char)
            }
        }
        fields.append(currentField)
        return fields
    }

    private func parseUsageData(columns: [String]) -> [String: String] {
        var usageData: [String: String] = [:]
        let startYear = 1997 // First year for usage data
        for (index, value) in columns.enumerated() {
            let year = String(startYear + index)
            if !value.isEmpty {
                usageData[year] = value
            }
        }
        return usageData
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
            clearAllData()
        }
    }

    private func exportCSV() {
        let fileManager = FileManager.default
        let tempURL = fileManager.temporaryDirectory.appendingPathComponent("stations.csv")
        
        // CSV Header
        var csvContent = """
        "Station Name","Country","County","Operator","Visited","Visit Date","Favorite","Latitude","Longitude"
        """
        
        // Include usage data headers dynamically
        let allUsageYears = Set(stations.flatMap { $0.usageData.keys }).sorted(by: >)
        csvContent += "," + allUsageYears.map { "\"\($0)\"" }.joined(separator: ",") + "\n"
        
        // CSV Rows
        for station in stations {
            let visited = station.visited ? "Yes" : "No"
            let visitDate = station.visitDate.map { dateFormatter.string(from: $0) } ?? ""
            let favorite = station.isFavorite ? "Yes" : "No"
            let correctedCounty = getCorrectedCountyName(station.county)

            // Base Station Details
            var row = [
                station.stationName,
                station.country,
                correctedCounty ?? station.county,
                station.toc,
                visited,
                visitDate,
                favorite,
                String(station.latitude),
                String(station.longitude)
            ].map { "\"\($0.replacingOccurrences(of: "\"", with: "\"\""))\"" }.joined(separator: ",")
            
            // Append usage data for each year
            for year in allUsageYears {
                let usageValue = station.usageData[year] ?? "N/A"
                row += ",\"\(usageValue.replacingOccurrences(of: "\"", with: "\"\""))\""
            }
            
            csvContent += row + "\n"
        }
        
        // Write to CSV file and share
        do {
            try csvContent.write(to: tempURL, atomically: true, encoding: .utf8)
            
            // Present share sheet
            if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let rootViewController = scene.windows.first?.rootViewController {
                let activityVC = UIActivityViewController(activityItems: [tempURL], applicationActivities: nil)
                rootViewController.present(activityVC, animated: true)
            }
        } catch {
            print("Failed to export CSV: \(error.localizedDescription)")
        }
    }

    private func saveStations() {
        let fileManager = FileManager.default
        let appFolderURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("GBR")
        ensureAppFolderExists()

        let fileURL = appFolderURL.appendingPathComponent("stations.json")
        do {
            let data = try JSONEncoder().encode(stations)
            try data.write(to: fileURL, options: .atomic)
        } catch {
            print("Failed to save stations: \(error.localizedDescription)")
        }
    }

    private func ensureAppFolderExists() {
        let fileManager = FileManager.default
        let appFolderURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("GBR")
        if !fileManager.fileExists(atPath: appFolderURL.path) {
            try? fileManager.createDirectory(at: appFolderURL, withIntermediateDirectories: true, attributes: nil)
        }
    }
    
    private func loadStations() {
        let fileManager = FileManager.default
        let appFolderURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("GBR")
        let fileURL = appFolderURL.appendingPathComponent("stations.json")

        guard fileManager.fileExists(atPath: fileURL.path) else { return }

        do {
            let data = try Data(contentsOf: fileURL)
            stations = try JSONDecoder().decode([StationRecord].self, from: data)
            filterStations()
        } catch {
            print("Failed to load stations: \(error.localizedDescription)")
        }
    }
    
    private func getCorrectedCountyName(_ county: String?) -> String? {
        guard let county = county else { return nil }
        if county == "Rhondda, Cynon, Taf" {
            return "Rhondda, Cynon, Taff"
        }
        return county
    }
    
    private func clearAllData() {
        stations.removeAll()
        filterStations()
    }

    private func saveStatisticsToSharedContainer() {
        let sharedDefaults = UserDefaults(suiteName: "group.com.gbr.statistics") // Replace with your app group
        let totalStations = stations.count
        let visitedStations = stations.filter { $0.visited }.count
        let notVisitedStations = totalStations - visitedStations
        let percentageVisited = totalStations > 0 ? (Double(visitedStations) / Double(totalStations)) * 100 : 0.0

        sharedDefaults?.set(totalStations, forKey: "totalStations")
        sharedDefaults?.set(visitedStations, forKey: "visitedStations")
        sharedDefaults?.set(notVisitedStations, forKey: "notVisitedStations")
        sharedDefaults?.set(percentageVisited, forKey: "percentageVisited")

        print("Data Saved to Shared Container - Total: \(totalStations), Visited: \(visitedStations), Not Visited: \(notVisitedStations), Percentage: \(percentageVisited)")
    }
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }
}
