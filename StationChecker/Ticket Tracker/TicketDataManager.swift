import Foundation

class TicketDataManager {
    static let shared = TicketDataManager()

    private init() {}

    // MARK: - Save Tickets to Disk
    func saveTicketsToDisk(_ tickets: [TicketRecord]) {
        do {
            let fileURL = getFileURL()
            let data = try JSONEncoder().encode(tickets)
            try data.write(to: fileURL, options: [.atomic])
            print("[TicketDataManager] Tickets successfully saved to: \(fileURL)")
        } catch {
            print("[TicketDataManager] Error saving tickets to disk: \(error)")
        }
    }

    // MARK: - Load Tickets from Disk
    func loadTicketsFromDisk() -> [TicketRecord] {
        do {
            let fileURL = getFileURL()
            let data = try Data(contentsOf: fileURL)
            let tickets = try JSONDecoder().decode([TicketRecord].self, from: data)
            print("[TicketDataManager] Loaded \(tickets.count) tickets from disk.")
            return tickets
        } catch {
            print("[TicketDataManager] Error loading tickets from disk: \(error)")
            return []
        }
    }

    // MARK: - Helper to Get File URL
    private func getFileURL() -> URL {
        let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return documentDirectory.appendingPathComponent("tickets.json")
    }

    // MARK: - CSV Parsing
    func parseTickets(from fileURL: URL) -> [TicketRecord] {
        var tickets: [TicketRecord] = []

        do {
            let csvContent = try String(contentsOf: fileURL, encoding: .utf8)
            let rows = csvContent.components(separatedBy: "\n")
            guard let headerRow = rows.first else {
                print("CSV file is empty.")
                return []
            }

            let headers = headerRow.components(separatedBy: ",")
            let rowsWithoutHeader = rows.dropFirst()

            for row in rowsWithoutHeader {
                let columns = parseCSVRow(row: row, delimiter: ",")
                guard columns.count >= headers.count else { continue }

                // Parse loyalty programs
                let loyaltyProgramString = columns[safe: headers.firstIndex(of: "Loyalty Program") ?? 9] ?? ""
                _ = loyaltyProgramString.components(separatedBy: "; ")

                let ticket = TicketRecord(
                    origin: columns[safe: headers.firstIndex(of: "Origin") ?? 0] ?? "",
                    destination: columns[safe: headers.firstIndex(of: "Destination") ?? 1] ?? "",
                    price: columns[safe: headers.firstIndex(of: "Price") ?? 2] ?? "",
                    ticketType: columns[safe: headers.firstIndex(of: "Ticket Type") ?? 3] ?? "",
                    classType: columns[safe: headers.firstIndex(of: "Class Type") ?? 4] ?? "Standard",
                    toc: columns[safe: headers.firstIndex(of: "TOC") ?? 5],
                    outboundDate: columns[safe: headers.firstIndex(of: "Outbound Date") ?? 6] ?? "",
                    returnDate: columns[safe: headers.firstIndex(of: "Return Date") ?? 7] ?? "",
                    wasDelayed: columns[safe: headers.firstIndex(of: "Was Delayed") ?? 8] ?? "",
                    delayDuration: columns[safe: headers.firstIndex(of: "Delay Duration") ?? 9] ?? "",
                    compensation: columns[safe: headers.firstIndex(of: "Compensation") ?? 10] ?? "",
                    loyaltyProgram: columns[safe: headers.firstIndex(of: "Loyalty Program") ?? 11] ?? "",
                    rewardValue: columns[safe: headers.firstIndex(of: "Reward Value") ?? 12] ?? ""
                )
                tickets.append(ticket)
            }
        } catch {
            print("[TicketDataManager] Error parsing tickets: \(error)")
        }

        return tickets
    }

    // Helper Function for Parsing CSV Rows
    private func parseCSVRow(row: String, delimiter: String) -> [String] {
        var fields: [String] = []
        var currentField = ""
        var insideQuotes = false

        for char in row {
            if char == "\"" {
                insideQuotes.toggle()
            } else if char == delimiter.first && !insideQuotes {
                fields.append(currentField)
                currentField = ""
            } else {
                currentField.append(char)
            }
        }
        fields.append(currentField)
        return fields
    }
    func exportTicketsToCSV(tickets: [TicketRecord]) -> String {
        let header = "Origin,Destination,Price,Ticket Type,Class Type,TOC,Outbound Date,Return Date,Was Delayed,Delay Duration,Compensation,Loyalty Program,Reward Value"
        let rows = tickets.map { ticket in
            [
                ticket.origin,
                ticket.destination,
                ticket.price,
                ticket.ticketType,
                ticket.classType,
                ticket.toc ?? "", // Use empty string if TOC is nil
                ticket.outboundDate,
                ticket.returnDate,
                ticket.wasDelayed,
                ticket.delayDuration,
                ticket.compensation,
                ticket.loyaltyProgram,
                ticket.rewardValue
            ]
            .map { field in
                if field.contains(",") || field.contains("\n") || field.contains("\"") {
                    return "\"\(field.replacingOccurrences(of: "\"", with: "\"\""))\""
                }
                return field
            }
            .joined(separator: ",")
        }
        return ([header] + rows).joined(separator: "\n")
    }
}
