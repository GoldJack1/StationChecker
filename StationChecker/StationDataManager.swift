import SwiftCSV
import Foundation

class StationDataManager {
    static let shared = StationDataManager()

    private init() {}

    // MARK: - CSV Export
    func exportStationsToCSV(stations: [StationRecord], for dataType: StationDataType) -> URL? {
        let fileName: String
        switch dataType {
        case .nationalRail:
            fileName = "NationalRailData.csv"
        case .northernIreland:
            fileName = "NorthernIrelandData.csv"
        case .ireland:
            fileName = "IrelandData.csv"
        case .metrolink:
            fileName = "MetrolinkData.csv"
        }

        let tempDirectory = FileManager.default.temporaryDirectory
        let fileURL = tempDirectory.appendingPathComponent(fileName)

        var csvText: String

        switch dataType {
        case .nationalRail:
            csvText = generateNationalRailCSV(stations: stations)
        case .northernIreland:
            csvText = generateNorthernIrelandCSV(stations: stations)
        case .ireland:
            csvText = generateIrelandCSV(stations: stations)
        case .metrolink:
            csvText = generateMetrolinkCSV(stations: stations)
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

    private func generateNationalRailCSV(stations: [StationRecord]) -> String {
        var csvText = """
        "Station Name","Country","County","Operator","Visited","Visit Date","Favorite","Latitude","Longitude"
        """

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
        return csvText
    }

    // Placeholder functions for other data types (add actual logic if needed)
    private func generateNorthernIrelandCSV(stations: [StationRecord]) -> String {
        return "Northern Ireland CSV generation not implemented yet."
    }

    private func generateIrelandCSV(stations: [StationRecord]) -> String {
        return "Ireland CSV generation not implemented yet."
    }

    private func generateMetrolinkCSV(stations: [StationRecord]) -> String {
        return "Manchester Metrolink CSV generation not implemented yet."
    }

    // MARK: - CSV Parsing
    func parseCSV(from fileURL: URL, for dataType: StationDataType) -> [StationRecord] {
        switch dataType {
        case .nationalRail:
            return parseNationalRailCSV(from: fileURL)
        case .northernIreland:
            return parseNorthernIrelandCSV(from: fileURL)
        case .ireland:
            return parseIrelandCSV(from: fileURL)
        case .metrolink:
            return parseMetrolinkCSV(from: fileURL)
        }
    }
    // Example: Parse National Rail CSV
    func parseNationalRailCSV(from fileURL: URL) -> [StationRecord] {
        var loadedStations: [StationRecord] = []

        do {
            let csvContent = try String(contentsOf: fileURL, encoding: .utf8)
            let rows = csvContent.components(separatedBy: "\n").dropFirst() // Skip header row

            for row in rows {
                let columns = parseCSVRow(row: row, delimiter: ",")
                guard columns.count >= 8 else { continue } // Ensure enough columns

                let stationName = columns[0].trimmingCharacters(in: .whitespacesAndNewlines)
                let country = columns[1].trimmingCharacters(in: .whitespacesAndNewlines)
                let county = columns[2].trimmingCharacters(in: .whitespacesAndNewlines)
                let toc = columns[3].trimmingCharacters(in: .whitespacesAndNewlines)
                let visited = columns[4].trimmingCharacters(in: .whitespacesAndNewlines).lowercased() == "yes"
                let visitDate: Date? = nil // Update if your CSV includes visit dates
                let isFavorite = false // Default for imported data
                let latitude = Double(columns[5]) ?? 0.0
                let longitude = Double(columns[6]) ?? 0.0
                let usageData = parseUsageData(columns: Array(columns[7...]), startYear: 2024)

                // Initialize StationRecord with a UUID
                let station = StationRecord(
                    stationName: stationName,
                    country: country,
                    county: county,
                    toc: toc,
                    visited: visited,
                    visitDate: visitDate,
                    isFavorite: isFavorite,
                    latitude: latitude,
                    longitude: longitude,
                    usageData: usageData
                )

                loadedStations.append(station)
            }
        } catch {
            print("Error parsing National Rail CSV: \(error)")
        }

        return loadedStations
    }

    // Placeholder for the other CSV parsers
    func parseNorthernIrelandCSV(from fileURL: URL) -> [StationRecord] {
        print("Parsing Northern Ireland CSV is not yet implemented.")
        return []
    }

    func parseIrelandCSV(from fileURL: URL) -> [StationRecord] {
        print("Parsing Ireland CSV is not yet implemented.")
        return []
    }

    func parseMetrolinkCSV(from fileURL: URL) -> [StationRecord] {
        print("Parsing Metrolink CSV is not yet implemented.")
        return []
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

        fields.append(currentField) // Add the last field
        return fields
    }

    private func parseUsageData(columns: [String], startYear: Int) -> [String: String] {
        var usageData: [String: String] = [:]
        for (index, value) in columns.enumerated() {
            let year = String(startYear - index) // Dynamically calculate the year
            let cleanValue = value.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
            usageData[year] = cleanValue == "n/a" ? "N/A" : cleanValue
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
            
            // Remove the stations JSON file from the document directory
            do {
                try FileManager.default.removeItem(at: fileURL)
                print("Stations file cleared.")
            } catch {
                print("Error clearing stations file: \(error)")
            }

            // If you're using UserDefaults or other persistence mechanisms, clear them as well
            UserDefaults.standard.removeObject(forKey: "stationsKey")
            print("UserDefaults cleared.")
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
