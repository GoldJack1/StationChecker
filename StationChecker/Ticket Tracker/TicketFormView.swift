import SwiftUI

struct TicketFormView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var origin: String = ""
    @State private var destination: String = ""
    @State private var price: String = ""
    @State private var ticketType: String = ""
    @State private var classType: String = "Standard"
    @State private var toc: String = ""
    @State private var outboundDate: Date = Date()
    @State private var outboundTime: Date = Date()
    @State private var hasReturnTicket: Bool = false
    @State private var returnDate: Date = Date()
    @State private var returnTime: Date = Date()
    @State private var wasDelayed: Bool = false
    @State private var delayDurationIndex: Int = 0
    @State private var pendingCompensation: Bool = false
    @State private var compensation: String = ""
    @State private var isVirginEnabled: Bool = false
    @State private var virginPoints: String = ""
    @State private var isLNEREEnabled: Bool = false
    @State private var lnerCashValue: String = ""
    @State private var isClubAvantiEnabled: Bool = false
    @State private var clubAvantiJourneys: String = ""

    private let delayOptions = ["15-29", "30-59", "60-120", "Cancelled"]

    private let tocOptions = [
        "Avanti West Coast",
        "CrossCountry",
        "East Midlands Railway",
        "Great Western Railway",
        "LNER",
        "Multi-Operator",
        "Northern",
        "ScotRail",
        "Southern",
        "Thameslink/Great Northern",
        "TransPennine Express",
        "Transport For Wales",
        "West Midlands Trains"
    ]

    @State private var showDropdown = false
    @State private var selectedTocIndex: Int = 0
    @State private var showDelayDropdown = false

    var onSave: (TicketRecord) -> Void

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Journey Details Section
                    FormSection(title: "Journey Details", icon: "train.side.front.car") {
                        FormField(label: "Origin", text: $origin, icon: "map")
                        FormField(label: "Destination", text: $destination, icon: "map")
                    }

                    // Ticket Details Section
                    FormSection(title: "Ticket Details", icon: "ticket") {
                        FormField(label: "Price (£)", text: $price, icon: "sterlingsign.circle")
                            .keyboardType(.decimalPad)
                        FormField(label: "Ticket Type", text: $ticketType, icon: "tag")

                        Picker("Class Type", selection: $classType) {
                            Text("Standard").tag("Standard")
                            Text("First").tag("First")
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        .padding(.vertical)

                        VStack(alignment: .leading, spacing: 4) {
                            Text("Train Operator")
                                .font(.subheadline)
                                .foregroundColor(.secondary)

                            Button(action: {
                                withAnimation {
                                    showDropdown.toggle()
                                }
                            }) {
                                HStack {
                                    Text(tocOptions[selectedTocIndex])
                                        .foregroundColor(tocOptions[selectedTocIndex].isEmpty ? .secondary : .primary)
                                    Spacer()
                                    Image(systemName: "chevron.down")
                                }
                                .padding()
                                .background(Color(.systemGray5))
                                .cornerRadius(6)
                            }

                            if showDropdown {
                                ScrollView {
                                    VStack(spacing: 0) {
                                        ForEach(tocOptions.indices, id: \ .self) { index in
                                            Button(action: {
                                                withAnimation {
                                                    selectedTocIndex = index
                                                    showDropdown = false
                                                }
                                            }) {
                                                HStack {
                                                    Text(tocOptions[index])
                                                    Spacer()
                                                    if selectedTocIndex == index {
                                                        Image(systemName: "checkmark")
                                                            .foregroundColor(.blue)
                                                    }
                                                }
                                                .padding()
                                                .background(Color(.systemGray6))
                                            }
                                        }
                                    }
                                }
                                .frame(height: min(CGFloat(tocOptions.count), 5) * 44) // Display first 5 options
                                .background(Color(.systemGray5))
                                .cornerRadius(6)
                                .shadow(radius: 5)
                                .padding(.top, 8) // Ensure dropdown appears below the button
                            }
                        }
                    }

                    // Outbound and Return Date Section
                    FormSection(title: "Travel Dates", icon: "calendar") {
                        DatePicker("Outbound Date", selection: $outboundDate, displayedComponents: .date)
                            .padding(.vertical)

                        DatePicker("Outbound Time", selection: $outboundTime, displayedComponents: .hourAndMinute)
                            .padding(.vertical)

                        Toggle("Return Ticket", isOn: $hasReturnTicket)
                            .padding(.vertical)

                        if hasReturnTicket {
                            DatePicker("Return Date", selection: $returnDate, displayedComponents: .date)
                                .padding(.vertical)
                            DatePicker("Return Time", selection: $returnTime, displayedComponents: .hourAndMinute)
                                .padding(.vertical)
                        }
                    }

                    // Delay Information Section
                    FormSection(title: "Delay Information", icon: "clock.arrow.circlepath") {
                        Toggle("Was Delayed?", isOn: $wasDelayed)
                            .padding(.vertical)

                        if wasDelayed {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Delay Duration")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)

                                Button(action: {
                                    withAnimation {
                                        showDelayDropdown.toggle()
                                    }
                                }) {
                                    HStack {
                                        Text(delayOptions[delayDurationIndex])
                                            .foregroundColor(.primary)
                                        Spacer()
                                        Image(systemName: "chevron.down")
                                    }
                                    .padding()
                                    .background(Color(.systemGray5))
                                    .cornerRadius(6)
                                }

                                if showDelayDropdown {
                                    ScrollView {
                                        VStack(spacing: 0) {
                                            ForEach(delayOptions.indices, id: \ .self) { index in
                                                Button(action: {
                                                    withAnimation {
                                                        delayDurationIndex = index
                                                        showDelayDropdown = false
                                                    }
                                                }) {
                                                    HStack {
                                                        Text(delayOptions[index])
                                                        Spacer()
                                                        if delayDurationIndex == index {
                                                            Image(systemName: "checkmark")
                                                                .foregroundColor(.blue)
                                                        }
                                                    }
                                                    .padding()
                                                    .background(Color(.systemGray6))
                                                }
                                            }
                                        }
                                    }
                                    .frame(height: min(CGFloat(delayOptions.count), 5) * 44) // Display first 5 options
                                    .background(Color(.systemGray5))
                                    .cornerRadius(6)
                                    .shadow(radius: 5)
                                    .padding(.top, 8) // Ensure dropdown appears below the button
                                }
                            }
                        }
                    }

                    // Compensation Section
                    if wasDelayed {
                        FormSection(title: "Compensation", icon: "banknote") {
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
                                FormField(label: "Compensation Amount (£)", text: $compensation, icon: "sterlingsign.circle")
                                    .keyboardType(.decimalPad)
                            }
                        }
                    }

                    // Loyalty Programs Section
                    FormSection(title: "Points/Loyalty Rewards", icon: "star") {
                        Toggle("Virgin Train Ticket", isOn: $isVirginEnabled)
                        if isVirginEnabled {
                            FormField(label: "Virgin Points", text: $virginPoints, icon: "number.circle")
                                .keyboardType(.numberPad)
                        }

                        Toggle("LNER Perks", isOn: $isLNEREEnabled)
                        if isLNEREEnabled {
                            FormField(label: "LNER Cash Value (£)", text: $lnerCashValue, icon: "sterlingsign.circle")
                                .keyboardType(.decimalPad)
                        }

                        Toggle("Club Avanti", isOn: $isClubAvantiEnabled)
                        if isClubAvantiEnabled {
                            FormField(label: "Avanti Journeys", text: $clubAvantiJourneys, icon: "train.side.front.car")
                                .keyboardType(.numberPad)
                        }
                    }
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground).edgesIgnoringSafeArea(.all))
            .navigationTitle("Add Ticket")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveTicket()
                    }
                    .disabled(origin.isEmpty || destination.isEmpty || price.isEmpty || ticketType.isEmpty)
                }
            }
        }
    }

    func saveTicket() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy"
        let formattedOutboundDate = dateFormatter.string(from: outboundDate)
        let formattedOutboundTime = formatTime(outboundTime)
        let formattedReturnDate = hasReturnTicket ? dateFormatter.string(from: returnDate) : ""
        let formattedReturnTime = hasReturnTicket ? formatTime(returnTime) : ""

        let loyaltyProgram = LoyaltyProgram(
            virginPoints: isVirginEnabled ? virginPoints : nil,
            lnerCashValue: isLNEREEnabled ? lnerCashValue : nil,
            clubAvantiJourneys: isClubAvantiEnabled ? clubAvantiJourneys : nil
        )

        let newTicket = TicketRecord(
            origin: origin,
            destination: destination,
            price: price.hasPrefix("£") ? price : "£\(price)",
            ticketType: ticketType,
            classType: classType,
            toc: tocOptions[selectedTocIndex],
            outboundDate: formattedOutboundDate,
            outboundTime: formattedOutboundTime,
            returnDate: formattedReturnDate,
            returnTime: formattedReturnTime,
            wasDelayed: wasDelayed,
            delayDuration: wasDelayed ? delayOptions[delayDurationIndex] : "",
            pendingCompensation: pendingCompensation,
            compensation: pendingCompensation ? "" : compensation,
            loyaltyProgram: loyaltyProgram
        )

        onSave(newTicket)
        dismiss()
    }

    private func formatTime(_ time: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: time)
    }
}
