import SwiftUI
import SwiftCSV

struct StationTrackerView: View {
    @State private var stations: [StationRecord] = []
    @State private var showFileImporter = false
    
    var body: some View {
        NavigationView {
            VStack {
                List {
                    ForEach(stations) { station in
                        NavigationLink(destination: StationDetailView(station: station)) {
                            StationCard(station: station) { updatedStation in
                                if let index = stations.firstIndex(where: { $0.id == updatedStation.id }) {
                                    stations[index] = updatedStation
                                }
                            }
                        }
                    }
                    .onDelete { indexSet in
                        stations.remove(atOffsets: indexSet)
                    }
                }
                
                HStack {
                    Button("Add Station") {
                        addStation()
                    }
                    Spacer()
                    Button("Import CSV") {
                        showFileImporter = true
                    }
                }
                .padding()
            }
            .navigationTitle("Station Tracker")
            .fileImporter(isPresented: $showFileImporter, allowedContentTypes: [.commaSeparatedText]) { result in
                handleFileImport(result: result)
            }
        }
    }
    
    // Add a new blank station
    private func addStation() {
        let newStation = StationRecord(
            stationName: "New Station",
            country: "Unknown",
            county: "Unknown",
            toc: "Unknown",
            visited: false,
            visitDate: nil,
            isFavorite: false,
            latitude: 0.0,
            longitude: 0.0,
            usageEstimate: "Unknown"
        )
        stations.append(newStation)
    }
    
    // Handle importing a CSV file
    private func handleFileImport(result: Result<URL, Error>) {
        do {
            let url = try result.get()
            let csv = try CSV(url: url)
            
            stations = csv.namedRows.compactMap { row in
                guard let stationName = row["Station"],
                      let country = row["Country"],
                      let county = row["County"],
                      let toc = row["TOC"],
                      let visited = row["Visited"],
                      let latitude = row["Latitude"],
                      let longitude = row["Longitude"],
                      let usage = row["April 2022 - March 2023 Esitmate Usage"] else {
                    return nil
                }
                return StationRecord(
                    stationName: stationName,
                    country: country,
                    county: county,
                    toc: toc,
                    visited: visited.lowercased() == "yes",
                    visitDate: nil,
                    isFavorite: false,
                    latitude: Double(latitude) ?? 0.0,
                    longitude: Double(longitude) ?? 0.0,
                    usageEstimate: usage
                )
            }
        } catch {
            print("Failed to import CSV: \(error)")
        }
    }
}