import Foundation

struct LoyaltyProgram: Codable, Equatable {
    var virginPoints: String?
    var lnerCashValue: String?
    var clubAvantiJourneys: String?
}

struct TicketRecord: Identifiable, Codable, Equatable {
    let id: UUID
    var origin: String
    var destination: String
    var price: String
    var ticketType: String
    var classType: String
    var toc: String?
    var outboundDate: String
    var outboundTime: String
    var returnDate: String
    var returnTime: String
    var wasDelayed: Bool
    var delayDuration: String
    var pendingCompensation: Bool
    var compensation: String
    var loyaltyProgram: LoyaltyProgram?

    init(
        id: UUID = UUID(),
        origin: String = "Unknown",
        destination: String = "Unknown",
        price: String = "£0.00",
        ticketType: String = "N/A",
        classType: String = "Standard",
        toc: String? = nil,
        outboundDate: String = "Unknown",
        outboundTime: String = "00:00",
        returnDate: String = "",
        returnTime: String = "00:00",
        wasDelayed: Bool = false, // Correct default to a Bool value
        delayDuration: String = "",
        pendingCompensation: Bool = false,
        compensation: String = "",
        loyaltyProgram: LoyaltyProgram? = nil
    ) {
        self.id = id
        self.origin = origin
        self.destination = destination
        self.price = price
        self.ticketType = ticketType
        self.classType = classType
        self.toc = toc
        self.outboundDate = outboundDate
        self.outboundTime = outboundTime
        self.returnDate = returnDate
        self.returnTime = returnTime
        self.wasDelayed = wasDelayed
        self.delayDuration = delayDuration
        self.pendingCompensation = pendingCompensation
        self.compensation = compensation
        self.loyaltyProgram = loyaltyProgram
    }
}
