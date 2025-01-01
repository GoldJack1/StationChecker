import Foundation // Required for UUID and Equatable

struct StationDataType: Identifiable, Equatable {
    let id = UUID() // Unique identifier for each type
    let name: String // Display name for the data type

    // Predefined types of data
    static let nationalRail = StationDataType(name: "National Rail")
    static let northernIreland = StationDataType(name: "Northern Ireland Railways")
    static let ireland = StationDataType(name: "Ireland Rail")
    static let metrolink = StationDataType(name: "Manchester Metrolink")

    // Conformance to Equatable
    static func == (lhs: StationDataType, rhs: StationDataType) -> Bool {
        lhs.id == rhs.id
    }
}
