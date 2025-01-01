import Foundation

struct StationDataType: Identifiable, Equatable {
    let id = UUID()
    let name: String

    // Add equatable conformance
    static func == (lhs: StationDataType, rhs: StationDataType) -> Bool {
        lhs.id == rhs.id
    }

    var displayName: String {
        return name
    }

    // Predefined types of data
    static let nationalRail = StationDataType(name: "National Rail")
    static let northernIreland = StationDataType(name: "Northern Ireland Railways")
    static let ireland = StationDataType(name: "Ireland Rail")
    static let metrolink = StationDataType(name: "Manchester Metrolink")
}
