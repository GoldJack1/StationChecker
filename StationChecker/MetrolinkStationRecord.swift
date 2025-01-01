import Foundation

struct MetrolinkStationRecord: Identifiable, Codable {
    let id: UUID
    let stationName: String
    let latitude: Double
    let longitude: Double
    var visited: Bool
    var isFavorite: Bool
    var visitDate: Date?

    init(
        id: UUID = UUID(),
        stationName: String,
        latitude: Double,
        longitude: Double,
        visited: Bool = false,
        isFavorite: Bool = false,
        visitDate: Date? = nil
    ) {
        self.id = id
        self.stationName = stationName
        self.latitude = latitude
        self.longitude = longitude
        self.visited = visited
        self.isFavorite = isFavorite
        self.visitDate = visitDate
    }
}

extension MetrolinkStationRecord {
    func toStationRecord() -> StationRecord {
        return StationRecord(
            id: self.id,
            stationName: self.stationName,
            country: "England", // Default country for Metrolink
            county: "Manchester", // Default county for Metrolink
            toc: "Metrolink", // Operator for Metrolink
            visited: self.visited,
            visitDate: self.visitDate,
            isFavorite: self.isFavorite,
            latitude: self.latitude,
            longitude: self.longitude,
            usageData: [:] // Metrolink might not have usage data
        )
    }
}
