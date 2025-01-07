import Foundation

struct TicketRecord: Identifiable, Codable, Hashable {
    let id: UUID
    var origin: String
    var destination: String
    var rangerRover: String?
    var ticketType: String
    var travelClass: String
    var price: String
    var delayRepay: String
    var outboundDate: String?
    var returnDate: String?
    var delayMins: String? // New optional field for delay minutes
    
    init(
        id: UUID = UUID(),
        origin: String,
        destination: String,
        rangerRover: String? = nil,
        ticketType: String,
        travelClass: String,
        price: String,
        delayRepay: String,
        outboundDate: String? = nil,
        returnDate: String? = nil,
        delayMins: String? = nil // Include in initializer
    ) {
        self.id = id
        self.origin = origin
        self.destination = destination
        self.rangerRover = rangerRover
        self.ticketType = ticketType
        self.travelClass = travelClass
        self.price = price
        self.delayRepay = delayRepay
        self.outboundDate = outboundDate
        self.returnDate = returnDate
        self.delayMins = delayMins
    }
}
