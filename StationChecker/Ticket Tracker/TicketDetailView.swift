import SwiftUI

struct TicketDetailView: View {
    @Binding var ticket: TicketRecord
    var onUpdate: (TicketRecord) -> Void

    @State private var isEditing: Bool = false
    @State private var localTicket: TicketRecord

    @State private var isVirginEnabled: Bool = false
    @State private var virginPoints: String = ""
    @State private var isLNEREEnabled: Bool = false
    @State private var lnerCashValue: String = ""
    @State private var isClubAvantiEnabled: Bool = false
    @State private var avantiJourneys: String = ""

    init(ticket: Binding<TicketRecord>, onUpdate: @escaping (TicketRecord) -> Void) {
        self._ticket = ticket
        self.onUpdate = onUpdate
        self._localTicket = State(initialValue: ticket.wrappedValue)
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                journeyDetailsSection()
                ticketDetailsSection()
                compensationSection()
                loyaltyProgramsSection()
            }
            .padding(.horizontal)
        }
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

    private func journeyDetailsSection() -> some View {
        FormSection(title: "Journey Details", icon: "train.side.front.car") {
            if isEditing {
                EditableField(label: "Origin", text: $localTicket.origin)
                EditableField(label: "Destination", text: $localTicket.destination)
            } else {
                DetailRow(label: "Origin", value: localTicket.origin)
                DetailRow(label: "Destination", value: localTicket.destination)
            }
        }
    }

    private func ticketDetailsSection() -> some View {
        FormSection(title: "Ticket Details", icon: "ticket") {
            if isEditing {
                EditableField(label: "Price (£)", text: $localTicket.price)
                EditableField(label: "Ticket Type", text: $localTicket.ticketType)
                Picker("Class", selection: $localTicket.classType) {
                    Text("Standard").tag("Standard")
                    Text("First").tag("First")
                }
                .pickerStyle(SegmentedPickerStyle())
                EditableField(
                    label: "TOC (Optional)",
                    text: Binding(
                        get: { localTicket.toc ?? "" },
                        set: { localTicket.toc = $0.isEmpty ? nil : $0 }
                    )
                )
                datePickersSection()
            } else {
                DetailRow(label: "Price", value: localTicket.price)
                DetailRow(label: "Type", value: localTicket.ticketType)
                DetailRow(label: "Class", value: localTicket.classType)
                if let toc = localTicket.toc {
                    DetailRow(label: "TOC", value: toc)
                }
                DetailRow(label: "Outbound Date", value: localTicket.outboundDate)
                DetailRow(label: "Outbound Time", value: localTicket.outboundTime)
                if !localTicket.returnDate.isEmpty {
                    DetailRow(label: "Return Date", value: localTicket.returnDate)
                    DetailRow(label: "Return Time", value: localTicket.returnTime)
                }
            }
        }
    }

    private func datePickersSection() -> some View {
        VStack {
            DatePicker("Outbound Date", selection: Binding(get: { dateFormatter.date(from: localTicket.outboundDate) ?? Date() }, set: { localTicket.outboundDate = dateFormatter.string(from: $0) }), displayedComponents: .date)
            DatePicker("Outbound Time", selection: Binding(get: { timeFormatter.date(from: localTicket.outboundTime) ?? Date() }, set: { localTicket.outboundTime = timeFormatter.string(from: $0) }), displayedComponents: .hourAndMinute)
            Toggle("Return Ticket", isOn: Binding(get: { !localTicket.returnDate.isEmpty }, set: { isOn in localTicket.returnDate = isOn ? dateFormatter.string(from: Date()) : "" }))
            if !localTicket.returnDate.isEmpty {
                DatePicker("Return Date", selection: Binding(get: { dateFormatter.date(from: localTicket.returnDate) ?? Date() }, set: { localTicket.returnDate = dateFormatter.string(from: $0) }), displayedComponents: .date)
                DatePicker("Return Time", selection: Binding(get: { timeFormatter.date(from: localTicket.returnTime) ?? Date() }, set: { localTicket.returnTime = timeFormatter.string(from: $0) }), displayedComponents: .hourAndMinute)
            }
        }
    }

    private func compensationSection() -> some View {
        FormSection(title: "Delay & Compensation Information", icon: "clock.arrow.circlepath") {
            if isEditing {
                Toggle("Was Delayed?", isOn: $localTicket.wasDelayed)
                if localTicket.wasDelayed {
                    EditableField(label: "Delay Duration", text: $localTicket.delayDuration)
                }
                Toggle("Pending Compensation", isOn: $localTicket.pendingCompensation)
                if !localTicket.pendingCompensation {
                    EditableField(label: "Compensation (£)", text: $localTicket.compensation)
                }
            } else {
                DetailRow(label: "Was Delayed", value: localTicket.wasDelayed ? "Yes" : "No", color: localTicket.wasDelayed ? .red : .green)
                if localTicket.wasDelayed {
                    DetailRow(label: "Delayed by", value: "\(localTicket.delayDuration) minutes")
                }
                if localTicket.pendingCompensation {
                    DetailRow(label: "Compensation", value: "Pending", color: .orange)
                } else if !localTicket.compensation.isEmpty {
                    DetailRow(label: "Compensation", value: "£\(localTicket.compensation)", color: .green)
                }
            }
        }
    }

    private func loyaltyProgramsSection() -> some View {
        if isEditing || hasLoyaltyPrograms() {
            return AnyView(
                FormSection(title: "Loyalty Programs", icon: "star") {
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
                        if let program = localTicket.loyaltyProgram {
                            if let points = program.virginPoints, points != "0" {
                                DetailRow(label: "Virgin Points", value: points)
                            }
                            if let cash = program.lnerCashValue, cash != "0" {
                                DetailRow(label: "LNER Cash Value", value: cash)
                            }
                            if let journeys = program.clubAvantiJourneys, journeys != "0" {
                                DetailRow(label: "Club Avanti Journeys", value: journeys)
                            }
                        } else {
                            Text("No Loyalty Programs").foregroundColor(.secondary)
                        }
                    }
                }
            )
        } else {
            return AnyView(EmptyView())
        }
    }
    
    private func saveChanges() {
        localTicket.loyaltyProgram = LoyaltyProgram(
            virginPoints: isVirginEnabled ? virginPoints : nil,
            lnerCashValue: isLNEREEnabled ? lnerCashValue : nil,
            clubAvantiJourneys: isClubAvantiEnabled ? avantiJourneys : nil
        )
        ticket = localTicket
        onUpdate(localTicket)
    }

    private func parseLoyaltyPrograms() {
        if let program = localTicket.loyaltyProgram {
            isVirginEnabled = program.virginPoints != nil && program.virginPoints != "0"
            virginPoints = program.virginPoints ?? "0"

            isLNEREEnabled = program.lnerCashValue != nil && program.lnerCashValue != "0"
            lnerCashValue = program.lnerCashValue ?? "0"

            isClubAvantiEnabled = program.clubAvantiJourneys != nil && program.clubAvantiJourneys != "0"
            avantiJourneys = program.clubAvantiJourneys ?? "0"
        }
    }

    private func hasLoyaltyPrograms() -> Bool {
        guard let program = localTicket.loyaltyProgram else { return false }
        return program.virginPoints != nil || program.lnerCashValue != nil || program.clubAvantiJourneys != nil
    }

    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        return formatter
    }

    private var timeFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter
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
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.gray.opacity(0.1))
                )
                .font(.body)
        }
        .padding(.vertical, 5)
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
