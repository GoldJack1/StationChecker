import SwiftUI

struct TicketFilterSheet: View {
    @Binding var tickets: [TicketRecord]
    @Binding var filteredTickets: [TicketRecord]
    @Binding var selectedTOC: String
    @Binding var selectedClassType: String
    @Binding var selectedTicketType: String
    @Binding var selectedDelayMinutes: String
    @Binding var selectedLoyaltyProgram: String
    @Binding var startDate: Date
    @Binding var endDate: Date
    @Binding var isPresented: Bool

    var body: some View {
        NavigationView {
            Form {
                // Filter by TOC
                Section(header: Text("Filter by TOC")) {
                    Picker("TOC", selection: $selectedTOC) {
                        Text("All").tag("")
                        ForEach(uniqueTOCs(), id: \.self) { toc in
                            Text(toc).tag(toc)
                        }
                    }
                }

                // Filter by Class Type
                Section(header: Text("Filter by Class Type")) {
                    Picker("Class Type", selection: $selectedClassType) {
                        Text("All").tag("")
                        Text("Standard").tag("Standard")
                        Text("First").tag("First")
                    }
                }

                // Filter by Ticket Type
                Section(header: Text("Filter by Ticket Type")) {
                    Picker("Ticket Type", selection: $selectedTicketType) {
                        Text("All").tag("")
                        ForEach(uniqueTicketTypes(), id: \.self) { type in
                            Text(type).tag(type)
                        }
                    }
                }

                // Filter by Delay Minutes
                Section(header: Text("Filter by Delay Minutes")) {
                    Picker("Delay Minutes", selection: $selectedDelayMinutes) {
                        Text("All").tag("")
                        ForEach(uniqueDelayMinutes(), id: \.self) { delay in
                            Text(delay).tag(delay)
                        }
                    }
                }

                // Filter by Loyalty Program
                Section(header: Text("Filter by Loyalty Program")) {
                    Picker("Loyalty Program", selection: $selectedLoyaltyProgram) {
                        Text("All").tag("")
                        ForEach(uniqueLoyaltyPrograms(), id: \.self) { program in
                            Text(program).tag(program)
                        }
                    }
                }

                // Filter by Date Range
                Section(header: Text("Date Range")) {
                    DatePicker("Start Date", selection: $startDate, displayedComponents: .date)
                    DatePicker("End Date", selection: $endDate, displayedComponents: .date)
                }
            }
            .navigationTitle("Filter Tickets")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        isPresented = false
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Apply") {
                        applyFiltersAndDismiss()
                    }
                }
            }
        }
    }

    private func applyFiltersAndDismiss() {
        filterTickets()
        print("Filters applied. Filtered tickets: \(filteredTickets.count)")
        isPresented = false
    }

    private func filterTickets() {
        filteredTickets = tickets.filter { ticket in
            // TOC filter
            (selectedTOC.isEmpty || ticket.toc == selectedTOC) &&
            // Class type filter
            (selectedClassType.isEmpty || ticket.classType == selectedClassType) &&
            // Ticket type filter
            (selectedTicketType.isEmpty || ticket.ticketType == selectedTicketType) &&
            // Delay minutes filter
            (selectedDelayMinutes.isEmpty || ticket.delayDuration == selectedDelayMinutes) &&
            // Loyalty program filter
            (selectedLoyaltyProgram.isEmpty || loyaltyProgramMatches(ticket.loyaltyProgram)) &&
            // Date range filter
            (parseDate(from: ticket.outboundDate) >= startDate &&
             parseDate(from: ticket.outboundDate) <= endDate)
        }

        print("Filtered tickets count: \(filteredTickets.count)")
    }

    private func loyaltyProgramMatches(_ loyaltyProgram: LoyaltyProgram?) -> Bool {
        guard let program = loyaltyProgram else { return false }
        switch selectedLoyaltyProgram {
        case "Virgin Train Ticket":
            return program.virginPoints != nil
        case "LNER Perks":
            return program.lnerCashValue != nil
        case "Club Avanti":
            return program.clubAvantiJourneys != nil
        default:
            return true
        }
    }

    private func uniqueTOCs() -> [String] {
        Array(Set(tickets.compactMap { $0.toc })).sorted()
    }

    private func uniqueTicketTypes() -> [String] {
        Array(Set(tickets.map { $0.ticketType })).sorted()
    }

    private func uniqueDelayMinutes() -> [String] {
        Array(Set(tickets.compactMap { $0.delayDuration })).sorted()
    }

    private func uniqueLoyaltyPrograms() -> [String] {
        var programs = [String]()
        for ticket in tickets {
            if let loyaltyProgram = ticket.loyaltyProgram {
                if loyaltyProgram.virginPoints != nil { programs.append("Virgin Train Ticket") }
                if loyaltyProgram.lnerCashValue != nil { programs.append("LNER Perks") }
                if loyaltyProgram.clubAvantiJourneys != nil { programs.append("Club Avanti") }
            }
        }
        return Array(Set(programs)).sorted()
    }

    private func parseDate(from string: String) -> Date {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        return formatter.date(from: string) ?? Date()
    }
}
