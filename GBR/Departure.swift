import Foundation

// Define the structure of each stop in a train service
struct TrainStop {
    let stationName: String
    let arrivalTime: String
    let departureTime: String
}

// Define the Departure struct, which includes details about train services
struct Departure: Identifiable {
    let id: UUID
    let time: String
    let destination: String
    let platform: String?
    let toc: String?
    let serviceUid: String // Unique identifier for the service

    let stops: [TrainStop]

    var timeFormatted: String {
        guard time.count == 4 else { return time }
        return "\(time.prefix(2)):\(time.suffix(2))"
    }
}
