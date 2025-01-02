import Foundation

enum DataType: String, CaseIterable, Identifiable {
    case nationalRail = "National Rail"
    case northernIreland = "Northern Ireland Railways"
    case ireland = "Ireland Rail"
    case metrolink = "Manchester Metrolink"

    var id: String { rawValue }

    var displayName: String {
        rawValue
    }
}
