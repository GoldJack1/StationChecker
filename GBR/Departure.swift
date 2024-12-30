import Foundation

struct Departure: Identifiable {
    let id: UUID
    let time: String
    let destination: String
    let platform: String?
    let toc: String?

    var timeFormatted: String {
        guard time.count == 4 else { return time }
        return "\(time.prefix(2)):\(time.suffix(2))"
    }
}