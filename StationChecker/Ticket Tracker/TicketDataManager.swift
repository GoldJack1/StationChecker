import Foundation
import SwiftCSV

class TicketDataManager {
    static let shared = TicketDataManager()
    private init() {}

    // MARK: - File Path
    private var filePath: URL {
        let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        return documents.appendingPathComponent("tickets.json")
    }

    // MARK: - Save Tickets to Disk
    func saveTicketsToDisk(_ tickets: [TicketRecord]) {
        do {
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted
            let data = try encoder.encode(tickets)
            try data.write(to: filePath)
        } catch {
            print("Error saving tickets to disk: \(error)")
        }
    }

    // MARK: - Load Tickets from Disk
    func loadTicketsFromDisk() -> [TicketRecord] {
        do {
            let data = try Data(contentsOf: filePath)
            let decoder = JSONDecoder()
            return try decoder.decode([TicketRecord].self, from: data)
        } catch {
            print("Error loading tickets from disk: \(error)")
            return []
        }
    }

    // MARK: - Parse CSV
    func parseCSV(fileURL: URL) -> [TicketRecord] {
        do {
            let csv = try CSV<Named>(url: fileURL)
            var tickets: [TicketRecord] = []

            for row in csv.rows {
                // Validate and include only numeric loyalty data
                let virginPoints: String? = {
                    if let value = row["VirginPoints"], !value.isEmpty, Double(value) != nil {
                        return value
                    }
                    return nil
                }()

                let lnerPerks: String? = {
                    if let value = row["LNERperks"], !value.isEmpty, Double(value) != nil {
                        return value
                    }
                    return nil
                }()

                let clubAvantiJourneys: String? = {
                    if let value = row["ClubAvantiJourneys"], !value.isEmpty, Double(value) != nil {
                        return value
                    }
                    return nil
                }()

                let loyaltyProgram = LoyaltyProgram(
                    virginPoints: virginPoints,
                    lnerCashValue: lnerPerks,
                    clubAvantiJourneys: clubAvantiJourneys
                )

                // Create a TicketRecord
                let ticket = TicketRecord(
                    origin: row["Origin"] ?? "Unknown",
                    destination: row["Destination"] ?? "Unknown",
                    price: row["Price"] ?? "£0.00",
                    ticketType: row["TicketType"] ?? "N/A",
                    classType: row["ClassType"] ?? "Standard",
                    toc: row["TOC"],
                    outboundDate: row["OutboundDate"] ?? "Unknown",
                    outboundTime: row["OutboundTime"] ?? "00:00",
                    returnDate: row["ReturnDate"] ?? "",
                    returnTime: row["ReturnTime"] ?? "00:00",
                    wasDelayed: (row["WasDelayed"] ?? "No").lowercased() == "yes",
                    delayDuration: row["DelayDuration"] ?? "",
                    pendingCompensation: (row["PendingCompensation"] ?? "No").lowercased() == "yes",
                    compensation: row["Compensation"] ?? "",
                    loyaltyProgram: virginPoints == nil && lnerPerks == nil && clubAvantiJourneys == nil ? nil : loyaltyProgram
                )
                tickets.append(ticket)
            }
            return tickets
        } catch {
            print("Error parsing CSV: \(error)")
            return []
        }
    }
    
    // MARK: - Export CSV
    func exportCSV(tickets: [TicketRecord], to url: URL) {
        var csvContent = "Origin,Destination,Price,TicketType,ClassType,TOC,OutboundDate,OutboundTime,ReturnDate,ReturnTime,WasDelayed,DelayDuration,PendingCompensation,Compensation,VirginPoints,LNERperks,ClubAvantiJourneys\n"

        for ticket in tickets {
            let row = [
                ticket.origin,
                ticket.destination,
                ticket.price,
                ticket.ticketType,
                ticket.classType,
                ticket.toc ?? "",
                ticket.outboundDate,
                ticket.outboundTime,
                ticket.returnDate,
                ticket.returnTime,
                ticket.wasDelayed ? "Yes" : "No",
                ticket.delayDuration,
                ticket.pendingCompensation ? "Yes" : "No",
                ticket.compensation,
                ticket.loyaltyProgram?.virginPoints ?? "",
                ticket.loyaltyProgram?.lnerCashValue ?? "",
                ticket.loyaltyProgram?.clubAvantiJourneys ?? ""
            ].joined(separator: ",")

            csvContent += row + "\n"
        }

        do {
            try csvContent.write(to: url, atomically: true, encoding: .utf8)
        } catch {
            print("Error exporting CSV: \(error)")
        }
    }
}
