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
            if let metrolinkStations = stations as? [MetrolinkStationRecord] {
                csvText = generateMetrolinkCSV(stations: metrolinkStations)
            } else {
                csvText = "Invalid Metrolink data."
            }
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

    func generateNationalRailCSV(stations: [StationRecord]) -> String {
        var csvText = """
        "Station Name","Country","County","Operator","Visited","Visit Date","Favorite","Latitude","Longitude"
        """

        // Include dynamic usage data headers
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

    func generateMetrolinkCSV(stations: [MetrolinkStationRecord]) -> String {
        var csvText = """
        "Station Name","Latitude","Longitude","Visited","Favorite","Visit Date"
        """

        for station in stations {
            let visited = station.visited ? "Yes" : "No"
            let favorite = station.isFavorite ? "Yes" : "No"
            let visitDate = station.visitDate.map { dateFormatter.string(from: $0) } ?? ""

            let row = [
                station.stationName,
                "\(station.latitude)",
                "\(station.longitude)",
                visited,
                favorite,
                visitDate
            ].map { "\"\($0)\"" }.joined(separator: ",")

            csvText += "\n\(row)"
        }
        return csvText
    }

    func generateNorthernIrelandCSV(stations: [StationRecord]) -> String {
        return "Northern Ireland CSV generation not implemented yet."
    }

    func generateIrelandCSV(stations: [StationRecord]) -> String {
        return "Ireland CSV generation not implemented yet."
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
            return parseMetrolinkCSV(from: fileURL).map { $0.toStationRecord() }
        }
    }

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
                let visitDate = columns[5].isEmpty ? nil : dateFormatter.date(from: columns[5])
                let isFavorite = columns[6].lowercased() == "yes"
                let latitude = Double(columns[7]) ?? 0.0
                let longitude = Double(columns[8]) ?? 0.0
                let usageData = parseUsageData(columns: Array(columns[9...]), startYear: 2024)

                let station = StationRecord(
                    id: UUID(),
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
    
    func parseNorthernIrelandCSV(from fileURL: URL) -> [StationRecord] {
        print("Parsing Northern Ireland CSV is not implemented yet.")
        // Return an empty array to prevent disruptions
        return []
    }
    
    func parseIrelandCSV(from fileURL: URL) -> [StationRecord] {
        print("Parsing Ireland CSV is not implemented yet.")
        // Return an empty array to prevent disruptions
        return []
    }

    func parseMetrolinkCSV(from fileURL: URL) -> [MetrolinkStationRecord] {
        var loadedStations: [MetrolinkStationRecord] = []

        do {
            let csvContent = try String(contentsOf: fileURL, encoding: .utf8)
            let rows = csvContent.components(separatedBy: "\n").dropFirst()

            for row in rows {
                let columns = parseCSVRow(row: row, delimiter: ",")
                guard columns.count >= 3 else { continue }

                let stationName = columns[0].trimmingCharacters(in: .whitespacesAndNewlines)
                guard let latitude = Double(columns[1].trimmingCharacters(in: .whitespacesAndNewlines)) else { continue }
                guard let longitude = Double(columns[2].trimmingCharacters(in: .whitespacesAndNewlines)) else { continue }

                let visited = columns.count > 3 && columns[3].trimmingCharacters(in: .whitespacesAndNewlines).lowercased() == "yes"
                let favorite = columns.count > 4 && columns[4].trimmingCharacters(in: .whitespacesAndNewlines).lowercased() == "yes"
                let visitDate = columns.count > 5 && !columns[5].isEmpty ? dateFormatter.date(from: columns[5]) : nil

                let station = MetrolinkStationRecord(
                    id: UUID(),
                    stationName: stationName,
                    latitude: latitude,
                    longitude: longitude,
                    visited: visited,
                    isFavorite: favorite,
                    visitDate: visitDate
                )

                loadedStations.append(station)
            }
        } catch {
            print("Error parsing Metrolink CSV: \(error)")
        }

        return loadedStations
    }

    private func parseUsageData(columns: [String], startYear: Int) -> [String: String] {
        var usageData: [String: String] = [:]
        for (index, value) in columns.enumerated() {
            let year = String(startYear - index)
            let cleanValue = value.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
            usageData[year] = cleanValue == "n/a" ? "N/A" : cleanValue
        }
        return usageData
    }

    // MARK: - Helper Methods
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

    func loadStationsFromDisk() -> [StationRecord] {
        let fileURL = getDocumentsDirectory().appendingPathComponent("stations.json")
        do {
            let data = try Data(contentsOf: fileURL)
            let loadedStations = try JSONDecoder().decode([StationRecord].self, from: data)
            return loadedStations
        } catch {
            print("Error loading stations from disk: \(error)")
            return []
        }
    }

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

    private func getDocumentsDirectory() -> URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }

    func saveMetrolinkStations(_ stations: [MetrolinkStationRecord]) {
        let fileURL = getDocumentsDirectory().appendingPathComponent("metrolinkStations.json")
        do {
            let data = try JSONEncoder().encode(stations)
            try data.write(to: fileURL, options: .atomic)
            print("Metrolink stations successfully saved to: \(fileURL)")
        } catch {
            print("Error saving Metrolink stations to disk: \(error)")
        }
    }
    
    func loadMetrolinkStations() -> [MetrolinkStationRecord] {
        let fileURL = getDocumentsDirectory().appendingPathComponent("metrolinkStations.json")
        do {
            let data = try Data(contentsOf: fileURL)
            let loadedStations = try JSONDecoder().decode([MetrolinkStationRecord].self, from: data)
            return loadedStations
        } catch {
            print("Error loading Metrolink stations from disk: \(error)")
            return []
        }
    }
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }
}
