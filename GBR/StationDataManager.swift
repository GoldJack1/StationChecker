import SwiftCSV
import Foundation

class StationDataManager {
    static let shared = StationDataManager()

    private init() {}

    // MARK: - CSV Export
    func exportStationsToCSV(stations: [StationRecord]) -> URL? {
        let fileName = "ExportedStations.csv"
        let tempDirectory = FileManager.default.temporaryDirectory
        let fileURL = tempDirectory.appendingPathComponent(fileName)

        var csvText = """
        "Station Name","Country","County","Operator","Visited","Visit Date","Favorite","Latitude","Longitude"
        """

        // Include usage data headers dynamically
        let allUsageYears = Set(stations.flatMap { $0.usageData.keys }).sorted(by: >)
        csvText += "," + allUsageYears.map { "\"\($0)\"" }.joined(separator: ",") + "\n"

        for station in stations {
            let visited = station.visited ? "Yes" : "No"
            let visitDate = station.visitDate.map { dateFormatter.string(from: $0) } ?? ""
            let favorite = station.isFavorite ? "Yes" : "No"

            var row = [
                station.stationName,
                station.country,
                station.county,
                station.toc,
                visited,
                visitDate,
                favorite,
                "\(station.latitude)",
                "\(station.longitude)"
            ].map { "\"\($0.replacingOccurrences(of: "\"", with: "\"\""))\"" }.joined(separator: ",")

            for year in allUsageYears {
                let usageValue = station.usageData[year] ?? "N/A"
                row += ",\"\(usageValue.replacingOccurrences(of: "\"", with: "\"\""))\""
            }

            csvText += row + "\n"
        }

        do {
            try csvText.write(to: fileURL, atomically: true, encoding: .utf8)
            print("CSV file successfully saved to: \(fileURL)")
            return fileURL
        } catch {
            print("Failed to save CSV file: \(error)")
            return nil
        }
    }

    // MARK: - CSV Parsing
    func parseCSV(from fileURL: URL) -> [StationRecord] {
        var loadedStations: [StationRecord] = []

        do {
            let csvContent = try String(contentsOf: fileURL, encoding: .utf8)
            let rows = csvContent.components(separatedBy: "\n").dropFirst() // Skip header row
            let csvDelimiter = ","

            for row in rows {
                let columns = parseCSVRow(row: row, delimiter: csvDelimiter)

                guard columns.count >= 9 else { continue } // Ensure we have enough columns

                let visited = columns[4].lowercased() == "yes"
                let visitDate = columns[5].isEmpty ? nil : dateFormatter.date(from: columns[5])
                let latitude = Double(columns[7]) ?? 0.0
                let longitude = Double(columns[8]) ?? 0.0

                let station = StationRecord(
                    stationName: columns[0].replacingOccurrences(of: "\"", with: ""),
                    country: columns[1].replacingOccurrences(of: "\"", with: ""),
                    county: columns[2].replacingOccurrences(of: "\"", with: ""),
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
        } catch {
            print("Error parsing CSV file: \(error)")
        }

        return loadedStations
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
        let startYear = 1997 // Example: first year for usage data
        for (index, value) in columns.enumerated() {
            let year = String(startYear + index)
            if !value.isEmpty {
                usageData[year] = value
            }
        }
        return usageData
    }

    // MARK: - JSON Persistence
    func saveStationsToDisk(_ stations: [StationRecord]) {
        let fileURL = getDocumentsDirectory().appendingPathComponent("stations.json")
        do {
            let data = try JSONEncoder().encode(stations)
            try data.write(to: fileURL, options: .atomic)
            print("Stations successfully saved to: \(fileURL)")
        } catch {
            print("Error saving stations to disk: \(error)")
        }
    }

    func loadStationsFromDisk() -> [StationRecord] {
        let fileURL = getDocumentsDirectory().appendingPathComponent("stations.json")
        do {
            let data = try Data(contentsOf: fileURL)
            return try JSONDecoder().decode([StationRecord].self, from: data)
        } catch {
            print("Error loading stations from disk: \(error)")
            return []
        }
    }

    func clearStations() {
        let fileURL = getDocumentsDirectory().appendingPathComponent("stations.json")
        do {
            try FileManager.default.removeItem(at: fileURL)
        } catch {
            print("Error clearing stations: \(error)")
        }
    }

    private func getDocumentsDirectory() -> URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }

    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }
}
