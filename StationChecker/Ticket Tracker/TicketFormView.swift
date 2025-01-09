import SwiftUI

struct TicketFormView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var origin: String = ""
    @State private var destination: String = ""
    @State private var price: String = ""
    @State private var ticketType: String = ""
    @State private var classType: String = "Standard" // Default to Standard
    @State private var toc: String = ""              // TOC is optional
    @State private var outboundDate: Date = Date()
    @State private var hasReturnTicket: Bool = false
    @State private var returnDate: Date = Date()
    @State private var wasDelayed: Bool = false
    @State private var delayDuration: String = "15-29"
    @State private var pendingCompensation: Bool = false
    @State private var compensation: String = ""
    @State private var selectedProgram: String = "Virgin Train Ticket"
    @State private var rewardValue: String = ""
    @State private var isVirginEnabled: Bool = false
    @State private var virginPoints: String = ""
    @State private var isLNEREEnabled: Bool = false
    @State private var lnerCashValue: String = ""
    @State private var isClubAvantiEnabled: Bool = false
    @State private var clubAvantiJourneys: String = ""

    let delayOptions = ["15-29", "30-59", "60-120", "Cancelled"]
    let loyaltyPrograms = ["Virgin Train Ticket", "LNER Perks", "Club Avanti"]

    var onSave: (TicketRecord) -> Void

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Journey Details")) {
                    TextField("Origin", text: $origin)
                        .autocapitalization(.words)
                        .disableAutocorrection(true) // Disable autocorrection for origin

                    TextField("Destination", text: $destination)
                        .autocapitalization(.words)
                        .disableAutocorrection(true) // Disable autocorrection for destination
                }

                Section(header: Text("Ticket Details")) {
                    HStack {
                        Text("£")
                        TextField("Price", text: $price)
                            .keyboardType(.decimalPad)
                            .autocapitalization(.none)
                    }

                    TextField("Ticket Type", text: $ticketType)
                        .autocapitalization(.words)

                    Picker("Class Type", selection: $classType) {
                        Text("Standard").tag("Standard")
                        Text("First").tag("First")
                    }
                    .pickerStyle(SegmentedPickerStyle())

                    TextField("TOC (Optional)", text: $toc)
                        .autocapitalization(.words)
                        .disableAutocorrection(true) // Disable autocorrection for TOC (optional)

                    DatePicker("Outbound Date", selection: $outboundDate, displayedComponents: .date)

                    Toggle("Return Ticket", isOn: $hasReturnTicket)

                    if hasReturnTicket {
                        DatePicker("Return Date", selection: $returnDate, displayedComponents: .date)
                    }
                }

                Section(header: Text("Delay Information")) {
                    Toggle("Was Delayed?", isOn: $wasDelayed)

                    if wasDelayed {
                        Picker("Delay Duration", selection: $delayDuration) {
                            ForEach(delayOptions, id: \.self) { option in
                                Text(option)
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                    }
                }

                if wasDelayed {
                    Section(header: Text("Compensation")) {
                        Toggle("Pending Compensation", isOn: Binding(
                            get: { pendingCompensation },
                            set: { newValue in
                                pendingCompensation = newValue
                                if newValue {
                                    compensation = "" // Clear compensation if pending
                                }
                            }
                        ))

                        if !pendingCompensation {
                            HStack {
                                Text("£")
                                TextField("Compensation Amount", text: $compensation)
                                    .keyboardType(.decimalPad)
                            }
                        }
                    }
                }

                Section(header: Text("Points/Loyalty Rewards")) {
                    Toggle("Virgin Train Ticket", isOn: $isVirginEnabled)
                    if isVirginEnabled {
                        HStack {
                            Text("Points:")
                            TextField("Enter Points", text: $virginPoints)
                                .keyboardType(.numberPad)
                        }
                    }

                    Toggle("LNER Perks", isOn: $isLNEREEnabled)
                    if isLNEREEnabled {
                        HStack {
                            Text("£")
                            TextField("Cash Value", text: $lnerCashValue)
                                .keyboardType(.decimalPad)
                        }
                    }

                    Toggle("Club Avanti", isOn: $isClubAvantiEnabled)
                    if isClubAvantiEnabled {
                        HStack {
                            Text("Journeys:")
                            TextField("Enter Journeys", text: $clubAvantiJourneys)
                                .keyboardType(.numberPad)
                        }
                    }
                }
            }
            .navigationTitle("Add Ticket")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        let dateFormatter = DateFormatter()
                        dateFormatter.dateFormat = "dd/MM/yyyy"
                        let formattedOutboundDate = dateFormatter.string(from: outboundDate)
                        let formattedReturnDate = hasReturnTicket ? dateFormatter.string(from: returnDate) : ""

                        // Build a string for loyalty programs
                        var loyaltyProgramDetails = [String]()
                        if isVirginEnabled {
                            loyaltyProgramDetails.append("Virgin Train Ticket: \(virginPoints) Points")
                        }
                        if isLNEREEnabled {
                            loyaltyProgramDetails.append("LNER Perks: £\(lnerCashValue)")
                        }
                        if isClubAvantiEnabled {
                            loyaltyProgramDetails.append("Club Avanti: \(clubAvantiJourneys) Journeys")
                        }
                        let combinedLoyaltyProgram = loyaltyProgramDetails.joined(separator: "; ")

                        let newTicket = TicketRecord(
                            origin: origin,
                            destination: destination,
                            price: "£\(price)",
                            ticketType: ticketType,
                            classType: classType,
                            toc: toc.isEmpty ? nil : toc,
                            outboundDate: formattedOutboundDate,
                            returnDate: formattedReturnDate,
                            wasDelayed: wasDelayed ? "Yes" : "No",
                            delayDuration: wasDelayed ? delayDuration : "",
                            compensation: pendingCompensation ? "Pending" : (compensation.isEmpty ? "" : "£\(compensation)"),
                            loyaltyProgram: combinedLoyaltyProgram,
                            rewardValue: "" // Reward value logic remains unchanged
                        )
                        onSave(newTicket)
                        dismiss()
                    }
                    .disabled(origin.isEmpty || destination.isEmpty || price.isEmpty || ticketType.isEmpty)
                }
            }
        }
    }
}
