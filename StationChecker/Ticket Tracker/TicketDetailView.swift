import SwiftUI

struct TicketDetailView: View {
    @State private var isEditing: Bool = false

    @State var origin: String
    @State var destination: String
    @State var price: String
    @State var ticketType: String
    @State var outboundDate: String
    @State var returnDate: String
    @State var wasDelayed: String
    @State var delayDuration: String
    @State var compensation: String
    @State var loyaltyProgram: String

    @State private var isVirginEnabled: Bool = false
    @State private var virginPoints: String = ""
    @State private var isLNEREEnabled: Bool = false
    @State private var lnerCashValue: String = ""
    @State private var isClubAvantiEnabled: Bool = false
    @State private var avantiJourneys: String = ""

    var onSave: (TicketRecord) -> Void

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Journey Details Section
                DetailSection(title: "Journey Details", icon: "airplane.departure") {
                    if isEditing {
                        EditableField(label: "Origin", text: $origin)
                        EditableField(label: "Destination", text: $destination)
                    } else {
                        DetailRow(label: "Origin", value: origin)
                        DetailRow(label: "Destination", value: destination)
                    }
                }

                // Ticket Details Section
                DetailSection(title: "Ticket Details", icon: "ticket") {
                    if isEditing {
                        EditableField(label: "Price (£)", text: $price)
                        EditableField(label: "Ticket Type", text: $ticketType)
                        EditableField(label: "Outbound Date (dd/MM/yyyy)", text: $outboundDate)
                        if !returnDate.isEmpty {
                            EditableField(label: "Return Date (dd/MM/yyyy)", text: $returnDate)
                        }
                    } else {
                        DetailRow(label: "Price", value: price)
                        DetailRow(label: "Type", value: ticketType)
                        DetailRow(label: "Outbound Date", value: outboundDate)
                        if !returnDate.isEmpty {
                            DetailRow(label: "Return Date", value: returnDate)
                        }
                    }
                }

                // Delay Information Section (Non-editable)
                DetailSection(title: "Delay Information", icon: "clock.arrow.circlepath") {
                    DetailRow(label: "Was Delayed", value: wasDelayed, color: wasDelayed == "Yes" ? .red : .green)
                    if wasDelayed == "Yes" {
                        DetailRow(label: "Delayed by", value: "\(delayDuration) minutes")
                    }
                }

                // Compensation Section
                DetailSection(title: "Compensation", icon: "banknote") {
                    if isEditing {
                        EditableField(label: "Compensation (£)", text: $compensation)
                    } else {
                        if compensation == "Pending" {
                            Text("Compensation: Pending")
                                .foregroundColor(.orange)
                        } else if !compensation.isEmpty {
                            Text("Compensation Given: \(compensation.hasPrefix("£") ? compensation : "£\(compensation)")")
                                .foregroundColor(.green)
                        } else {
                            Text("No Compensation")
                                .foregroundColor(.secondary)
                        }
                    }
                }

                // Loyalty Programs Section
                DetailSection(title: "Points/Loyalty Rewards", icon: "star") {
                    if isEditing {
                        Toggle("Virgin Train Ticket", isOn: $isVirginEnabled)
                        if isVirginEnabled {
                            EditableField(label: "Virgin Points", text: $virginPoints)
                        }

                        Toggle("LNER Perks", isOn: $isLNEREEnabled)
                        if isLNEREEnabled {
                            EditableField(label: "LNER Cash Value (£)", text: $lnerCashValue)
                        }

                        Toggle("Club Avanti", isOn: $isClubAvantiEnabled)
                        if isClubAvantiEnabled {
                            EditableField(label: "Club Avanti Journeys", text: $avantiJourneys)
                        }
                    } else {
                        if !loyaltyProgram.isEmpty {
                            let programs = loyaltyProgram.components(separatedBy: "; ")
                            ForEach(programs, id: \.self) { program in
                                Text(program)
                                    .padding(.vertical, 4)
                            }
                        } else {
                            Text("No Loyalty Programs Used")
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
            .padding(.horizontal)
        }
        .background(Color(.systemGroupedBackground).edgesIgnoringSafeArea(.all))
        .navigationTitle(isEditing ? "Edit Ticket" : "Ticket Details")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(isEditing ? "Save" : "Edit") {
                    if isEditing {
                        saveChanges()
                    }
                    isEditing.toggle()
                }
            }
        }
        .onAppear {
            parseLoyaltyPrograms()
        }
    }

    private func saveChanges() {
        // Combine loyalty programs into a single string
        var programs: [String] = []
        if isVirginEnabled {
            programs.append("Virgin Train Ticket: \(virginPoints) Points")
        }
        if isLNEREEnabled {
            programs.append("LNER Perks: £\(lnerCashValue)")
        }
        if isClubAvantiEnabled {
            programs.append("Club Avanti: \(avantiJourneys) Journeys")
        }
        loyaltyProgram = programs.joined(separator: "; ")

        let updatedTicket = TicketRecord(
            origin: origin,
            destination: destination,
            price: price,
            ticketType: ticketType,
            outboundDate: outboundDate,
            returnDate: returnDate,
            wasDelayed: wasDelayed,
            delayDuration: delayDuration,
            compensation: compensation,
            loyaltyProgram: loyaltyProgram
        )
        onSave(updatedTicket)
    }

    private func parseLoyaltyPrograms() {
        // Parse the loyalty program string into individual fields
        let programs = loyaltyProgram.components(separatedBy: "; ")
        isVirginEnabled = programs.contains { $0.contains("Virgin Train Ticket") }
        virginPoints = programs.first(where: { $0.contains("Virgin Train Ticket") })?.components(separatedBy: ": ").last?.replacingOccurrences(of: " Points", with: "") ?? ""

        isLNEREEnabled = programs.contains { $0.contains("LNER Perks") }
        lnerCashValue = programs.first(where: { $0.contains("LNER Perks") })?.components(separatedBy: ": ").last?.replacingOccurrences(of: "£", with: "") ?? ""

        isClubAvantiEnabled = programs.contains { $0.contains("Club Avanti") }
        avantiJourneys = programs.first(where: { $0.contains("Club Avanti") })?.components(separatedBy: ": ").last?.replacingOccurrences(of: " Journeys", with: "") ?? ""
    }
}

struct DetailSection<Content: View>: View {
    let title: String
    let icon: String
    let content: Content

    init(title: String, icon: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.icon = icon
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(.blue)
                Text(title)
                    .font(.headline)
                    .foregroundColor(.primary)
            }
            .padding(.bottom, 5)

            VStack(alignment: .leading, spacing: 8) {
                content
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(RoundedRectangle(cornerRadius: 10)
                .fill(Color(.secondarySystemBackground))
                .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2))
        }
    }
}

struct EditableField: View {
    let label: String
    @Binding var text: String

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(label)
                .font(.subheadline)
                .foregroundColor(.gray)
            TextField(label, text: $text)
                .padding(10)
                .background(RoundedRectangle(cornerRadius: 10).fill(Color.gray.opacity(0.1)))
                .font(.body)
        }
    }
}

struct DetailRow: View {
    let label: String
    let value: String
    var color: Color = .primary

    var body: some View {
        HStack {
            Text(label + ":")
                .font(.subheadline)
                .foregroundColor(.gray)
            Spacer()
            Text(value)
                .font(.body)
                .foregroundColor(color)
        }
        .padding(.vertical, 4)
    }
}
