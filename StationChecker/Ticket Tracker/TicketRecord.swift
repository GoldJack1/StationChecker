import Foundation

struct TicketRecord: Identifiable, Codable {
    var id: UUID = UUID()
    let origin: String
    let destination: String
    let price: String
    let ticketType: String
    let classType: String
    let toc: String? // Optional TOC
    let outboundDate: String
    let returnDate: String
    let wasDelayed: String
    let delayDuration: String
    let compensation: String
    let loyaltyProgram: String
    let rewardValue: String

    init(
        id: UUID = UUID(),
        origin: String,
        destination: String,
        price: String,
        ticketType: String,
        classType: String = "Standard",  // Default value
        toc: String? = nil,  // Optional TOC
        outboundDate: String,
        returnDate: String,
        wasDelayed: String,
        delayDuration: String,
        compensation: String,
        loyaltyProgram: String = "",  // Default value
        rewardValue: String = ""  // Default value
    ) {
        self.id = id
        self.origin = origin
        self.destination = destination
        self.price = price
        self.ticketType = ticketType
        self.classType = classType
        self.toc = toc
        self.outboundDate = outboundDate
        self.returnDate = returnDate
        self.wasDelayed = wasDelayed
        self.delayDuration = delayDuration
        self.compensation = compensation
        self.loyaltyProgram = loyaltyProgram
        self.rewardValue = rewardValue
    }
}
