import Foundation

struct StationRecord: Identifiable {
    let id = UUID()
    var stationName: String
    var country: String
    var county: String
    var toc: String
    var visited: Bool
    var visitDate: Date?
    var isFavorite: Bool
    var latitude: Double
    var longitude: Double
    var usageEstimate: String
}