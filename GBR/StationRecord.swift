import Foundation

struct StationRecord: Identifiable, Codable {
    let id: UUID
    var stationName: String
    var country: String
    var county: String
    var toc: String
    var visited: Bool
    var visitDate: Date? // Optional Date
    var isFavorite: Bool
    var latitude: Double
    var longitude: Double
    var usageData: [String: String] // Example: ["2023": "1000", "2022": "950"]

    init(
        id: UUID = UUID(),
        stationName: String,
        country: String,
        county: String,
        toc: String,
        visited: Bool,
        visitDate: Date?,
        isFavorite: Bool,
        latitude: Double,
        longitude: Double,
        usageData: [String: String]
    ) {
        self.id = id
        self.stationName = stationName
        self.country = country
        self.county = county
        self.toc = toc
        self.visited = visited
        self.visitDate = visitDate
        self.isFavorite = isFavorite
        self.latitude = latitude
        self.longitude = longitude
        self.usageData = usageData
    }
}
