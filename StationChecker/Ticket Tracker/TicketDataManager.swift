import Foundation

class TicketDataManager {
    static let shared = TicketDataManager()
    
    private init() {}
    
    // MARK: - Import Tickets
    func importTickets(from fileURL: URL) -> [TicketRecord] {
        var ticketRecords: [TicketRecord] = []
        
        do {
            // Read the file contents
            let csvContent = try String(contentsOf: fileURL, encoding: .utf8)
            let rows = csvContent.components(separatedBy: "\n")
            guard let headerRow = rows.first else {
                print("[TicketDataManager] CSV file is empty.")
                return []
            }
            
            let headers = parseCSVRow(row: headerRow, delimiter: ",")
            let rowsWithoutHeader = rows.dropFirst()
            
            // Determine column indices dynamically
            let originIndex = headers.firstIndex(of: "Ticket Origin") ?? 0
            let destinationIndex = headers.firstIndex(of: "Ticket Destination") ?? 1
            let rangerRoverIndex = headers.firstIndex(of: "Ranger/Rover (If Applicable)")
            let ticketTypeIndex = headers.firstIndex(of: "Ticket Type") ?? 2
            let travelClassIndex = headers.firstIndex(of: "Class") ?? 3
            let priceIndex = headers.firstIndex(of: "Price") ?? 4
            let outboundDateIndex = headers.firstIndex(of: "Outbound Date")
            let returnDateIndex = headers.firstIndex(of: "Return Date")
            let delayRepayIndex = headers.firstIndex(of: "Delay Repay")
            let delayMinsIndex = headers.firstIndex(of: "Delay Mins")
            
            for row in rowsWithoutHeader {
                let columns = parseCSVRow(row: row, delimiter: ",")
                guard columns.count >= headers.count else {
                    print("[TicketDataManager] Skipping misaligned row: \(row)")
                    continue
                }
                
                // Parse fields
                let origin = columns[optional: originIndex]?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "Unknown"
                let destination = columns[optional: destinationIndex]?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "Unknown"
                let rangerRover = rangerRoverIndex != nil
                ? columns[optional: rangerRoverIndex!]?.trimmingCharacters(in: .whitespacesAndNewlines)
                : nil
                let ticketType = columns[optional: ticketTypeIndex]?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "Unknown"
                let travelClass = columns[optional: travelClassIndex]?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "Unknown"
                let price = columns[optional: priceIndex]?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "£0.00"
                let outboundDate = outboundDateIndex != nil
                ? columns[optional: outboundDateIndex!]?.trimmingCharacters(in: .whitespacesAndNewlines)
                : nil
                let returnDate = returnDateIndex != nil
                ? columns[optional: returnDateIndex!]?.trimmingCharacters(in: .whitespacesAndNewlines)
                : nil
                let delayRepay = delayRepayIndex != nil
                ? columns[optional: delayRepayIndex!]?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "£0.00"
                : "£0.00"
                let delayMins = delayMinsIndex != nil
                ? columns[optional: delayMinsIndex!]?.trimmingCharacters(in: .whitespacesAndNewlines)
                : nil
                
                // Create a TicketRecord object
                let ticket = TicketRecord(
                    origin: origin,
                    destination: destination,
                    rangerRover: rangerRover,
                    ticketType: ticketType,
                    travelClass: travelClass,
                    price: price,
                    delayRepay: delayRepay,
                    outboundDate: outboundDate,
                    returnDate: returnDate,
                    delayMins: delayMins
                )
                
                ticketRecords.append(ticket)
            }
        } catch {
            print("[TicketDataManager] Error reading file: \(error)")
        }
        
        return ticketRecords
    }
    
    // MARK: - Export Tickets
    func exportTickets(_ tickets: [TicketRecord]) -> URL? {
        let fileName = "Tickets.csv"
        let tempDirectory = FileManager.default.temporaryDirectory
        let fileURL = tempDirectory.appendingPathComponent(fileName)
        
        var csvText = """
        "Ticket Origin","Ticket Destination","Ranger/Rover","Ticket Type","Class","Price","Outbound Date","Return Date","Delay Repay","Delay Mins"\n
        """
        
        for ticket in tickets {
            let row = """
            "\(ticket.origin)","\(ticket.destination)","\(ticket.rangerRover ?? "")","\(ticket.ticketType)","\(ticket.travelClass)","\(ticket.price)","\(ticket.outboundDate ?? "")","\(ticket.returnDate ?? "")","\(ticket.delayRepay)","\(ticket.delayMins ?? "0")"\n
            """
            csvText += row
        }
        
        do {
            try csvText.write(to: fileURL, atomically: true, encoding: .utf8)
            print("[TicketDataManager] Tickets successfully exported to: \(fileURL)")
            return fileURL
        } catch {
            print("[TicketDataManager] Failed to export tickets: \(error)")
            return nil
        }
    }
    
    // MARK: - Helper Methods
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
    
    // MARK: - Load Tickets
    func loadTickets() -> [TicketRecord] {
        let fileURL = getFileURL()
        do {
            let data = try Data(contentsOf: fileURL)
            let tickets = try JSONDecoder().decode([TicketRecord].self, from: data)
            return tickets
        } catch {
            print("[TicketDataManager] Failed to load tickets: \(error)")
            return []
        }
    }
    
    // MARK: - Save Tickets
    func saveTicketsToDisk(_ tickets: [TicketRecord]) {
        let fileURL = getFileURL()
        do {
            let data = try JSONEncoder().encode(tickets)
            try data.write(to: fileURL)
            print("[TicketDataManager] Tickets saved successfully to \(fileURL.path)")
        } catch {
            print("[TicketDataManager] Failed to save tickets: \(error)")
        }
    }
    
    private func getFileURL() -> URL {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        return documentsDirectory.appendingPathComponent("tickets.json")
    }
}
// Renamed Subscript for Safe Array Access
extension Array {
    subscript(optional index: Int) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
