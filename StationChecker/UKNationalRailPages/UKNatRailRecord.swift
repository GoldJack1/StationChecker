import Foundation

struct UKNatRailRecord: Identifiable, Codable, Hashable {
    let id: UUID
    var stationName: String
    var country: String
    var county: String
    var toc: String // Train Operating Company
    var visited: Bool
    var visitDate: Date? // Optional date of visit
    var isFavorite: Bool
    var latitude: Double
    var longitude: Double
    var usageData: [String: String] // Key-value pairs for usage statistics

    init(
        id: UUID = UUID(),
        stationName: String,
        country: String,
        county: String,
        toc: String,
        visited: Bool = false,
        visitDate: Date? = nil,
        isFavorite: Bool = false,
        latitude: Double,
        longitude: Double,
        usageData: [String: String] = [:]
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
