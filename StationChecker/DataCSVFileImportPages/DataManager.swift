import SwiftCSV
import Foundation
import WidgetKit

class DataManager {
    static let shared = DataManager()

    private init() {}

    // MARK: - CSV Export
    func exportStationsToCSV(stations: [UKNatRailRecord], for dataType: DataType) -> URL? {
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

    private func generateNationalRailCSV(stations: [UKNatRailRecord]) -> String {
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

    private func generateNorthernIrelandCSV(stations: [UKNatRailRecord]) -> String {
        return "Northern Ireland CSV generation not implemented yet."
    }

    private func generateIrelandCSV(stations: [UKNatRailRecord]) -> String {
        return "Ireland CSV generation not implemented yet."
    }

    private func generateMetrolinkCSV(stations: [UKNatRailRecord]) -> String {
        return "Manchester Metrolink CSV generation not implemented yet."
    }

    // MARK: - CSV Parsing
    func parseCSV(from fileURL: URL, for dataType: DataType) -> [UKNatRailRecord] {
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

    func parseNationalRailCSV(from fileURL: URL) -> [UKNatRailRecord] {
        var loadedStations: [UKNatRailRecord] = []

        do {
            let csvContent = try String(contentsOf: fileURL, encoding: .utf8)
            let rows = csvContent.components(separatedBy: "\n")
            guard let headerRow = rows.first else {
                print("[DataManager] CSV file is empty.")
                return []
            }

            let headers = parseCSVRow(row: headerRow, delimiter: ",")
            let rowsWithoutHeader = rows.dropFirst()

            // Determine column indices dynamically
            let stationNameIndex = headers.firstIndex(of: "Station Name") ?? 0
            let countryIndex = headers.firstIndex(of: "Country") ?? 1
            let countyIndex = headers.firstIndex(of: "County") ?? 2
            let tocIndex = headers.firstIndex(of: "Operator") ?? 3
            let visitedIndex = headers.firstIndex(of: "Visited")
            let visitDateIndex = headers.firstIndex(of: "Visit Date")
            let favoriteIndex = headers.firstIndex(of: "Favorite")
            let latitudeIndex = headers.firstIndex(of: "Latitude") ?? 7
            let longitudeIndex = headers.firstIndex(of: "Longitude") ?? 8
            let usageDataStartIndex = max(latitudeIndex, longitudeIndex) + 1

            for row in rowsWithoutHeader {
                let columns = parseCSVRow(row: row, delimiter: ",")
                guard columns.count >= headers.count else {
                    print("[DataManager] Skipping misaligned row: \(row)")
                    continue
                }

                // Parse required fields
                let stationName = columns[safe: stationNameIndex]?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "Unknown"
                let country = columns[safe: countryIndex]?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "Unknown"
                let county = columns[safe: countyIndex]?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "Unknown"
                let toc = columns[safe: tocIndex]?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "Unknown"

                // Handle optional fields (add default values if missing)
                let visited = visitedIndex != nil
                    ? (columns[safe: visitedIndex!]?.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() == "yes")
                    : false
                let visitDate = visitDateIndex != nil
                    ? dateFormatter.date(from: columns[safe: visitDateIndex!]?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "")
                    : nil
                let isFavorite = favoriteIndex != nil
                    ? (columns[safe: favoriteIndex!]?.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() == "yes")
                    : false

                // Parse latitude and longitude
                let latitude = Double(columns[safe: latitudeIndex]?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "0.0") ?? 0.0
                let longitude = Double(columns[safe: longitudeIndex]?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "0.0") ?? 0.0

                // Parse usage data
                let usageData = parseUsageData(columns: Array(columns[usageDataStartIndex...]), startYear: 2024)

                let station = UKNatRailRecord(
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
            print("[DataManager] Error parsing National Rail CSV: \(error)")
        }

        return loadedStations
    }

    func parseNorthernIrelandCSV(from fileURL: URL) -> [UKNatRailRecord] {
        print("Parsing Northern Ireland CSV is not yet implemented.")
        return []
    }

    func parseIrelandCSV(from fileURL: URL) -> [UKNatRailRecord] {
        print("Parsing Ireland CSV is not yet implemented.")
        return []
    }

    func parseMetrolinkCSV(from fileURL: URL) -> [UKNatRailRecord] {
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

        fields.append(currentField)
        return fields
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

    // MARK: - JSON Persistence with Widget Updates
    private var fileURL: URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("stations.json")
    }
    
    // MARK: - Shared File URL
    private var sharedFileURL: URL {
        guard let sharedContainer = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.com.gbr.statistics") else {
            fatalError("App Group is not configured correctly.")
        }
        return sharedContainer.appendingPathComponent("NationalRailData.json")
    }

    // MARK: - Save National Rail Data to Disk
    func saveStationsToDisk(_ stations: [UKNatRailRecord]) {
        do {
            let jsonData = try JSONEncoder().encode(stations)
            try jsonData.write(to: sharedFileURL, options: .atomic)
            print("[DataManager] Stations successfully saved to: \(sharedFileURL.path)")

            // Debug saved content
            let savedData = try Data(contentsOf: sharedFileURL)
            let savedStations = try JSONDecoder().decode([UKNatRailRecord].self, from: savedData)
            print("[DataManager] Saved stations count: \(savedStations.count)")

            // Trigger widget update
            WidgetCenter.shared.reloadAllTimelines()
            print("[DataManager] Widget timelines reloaded.")
        } catch {
            print("[DataManager] Error saving stations to disk: \(error)")
        }
    }

    // MARK: - Load Stations from Disk
    func loadStationsFromDisk() -> [UKNatRailRecord] {
        do {
            let data = try Data(contentsOf: sharedFileURL)
            let stations = try JSONDecoder().decode([UKNatRailRecord].self, from: data)
            print("[DataManager] Loaded \(stations.count) stations from disk.")
            return stations
        } catch {
            print("[DataManager] Error loading stations from disk: \(error)")
            return []
        }
    }

    // MARK: - Clear National Rail Data from Disk
    func clearStations() {
        do {
            try FileManager.default.removeItem(at: sharedFileURL)
            print("[DataManager] Stations file cleared at: \(sharedFileURL.path)")
            
            guard let sharedDefaults = UserDefaults(suiteName: "group.com.gbr.statistics") else { return }
            sharedDefaults.removeObject(forKey: "totalStations")
            sharedDefaults.removeObject(forKey: "visitedStations")
            sharedDefaults.removeObject(forKey: "notVisitedStations")
            sharedDefaults.removeObject(forKey: "percentageVisited")

            // Trigger widget update
            WidgetCenter.shared.reloadAllTimelines()
            print("[DataManager] Widget timelines reloaded after clearing data.")
        } catch {
            print("[DataManager] Error clearing stations file: \(error)")
        }
    }

    func saveStatisticsToSharedContainer(stations: [UKNatRailRecord]) {
        guard let sharedDefaults = UserDefaults(suiteName: "group.com.gbr.statistics") else {
            print("[DataManager] Shared defaults not found.")
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

        // Trigger widget update
        WidgetCenter.shared.reloadAllTimelines()
        print("[DataManager] Statistics saved and widget timeline reloaded.")
    }

    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }
}

extension Array {
    subscript(safe index: Int) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
