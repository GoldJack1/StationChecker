import SwiftUI

struct TicketDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var ticket: TicketRecord
    var onUpdate: (TicketRecord) -> Void
    var onDelete: () -> Void // Add a closure for delete functionality

    @State private var isEditing: Bool = false
    @State private var localTicket: TicketRecord

    @State private var isVirginEnabled: Bool = false
    @State private var virginPoints: String = ""
    @State private var isLNEREEnabled: Bool = false
    @State private var lnerCashValue: String = ""
    @State private var isClubAvantiEnabled: Bool = false
    @State private var avantiJourneys: String = ""

    @State private var showTocDropdown = false
    @State private var selectedTocIndex = 0

    @State private var showDelayDropdown = false
    @State private var delayDurationIndex = 0
    
    @State private var showDeleteConfirmation: Bool = false
    @State private var filteredStations: [Station] = []
    @State private var originSearchActive: Bool = false
    @State private var destinationSearchActive: Bool = false

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

    private let delayOptions = ["15-29", "30-59", "60-120", "Cancelled"]


    init(ticket: Binding<TicketRecord>, onUpdate: @escaping (TicketRecord) -> Void, onDelete: @escaping () -> Void) {
        self._ticket = ticket
        self.onUpdate = onUpdate
        self.onDelete = onDelete
        self._localTicket = State(initialValue: ticket.wrappedValue)
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                journeyDetailsSection()
                ticketDetailsSection()
                compensationSection()
                loyaltyProgramsSection()
                deleteButtonSection()
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
            if let toc = localTicket.toc, let index = tocOptions.firstIndex(of: toc) {
                selectedTocIndex = index
            } else {
                selectedTocIndex = 0 // Default to the first TOC if none is set
            }
        }
    }

    private func journeyDetailsSection() -> some View {
        FormSection(title: "Journey Details", icon: "train.side.front.car") {
            if isEditing {
                VStack(alignment: .leading) {
                    Text("Origin")
                        .font(.headline)

                    TextField("Enter station name or CRS code", text: $localTicket.origin)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                        .onChange(of: localTicket.origin) { newValue in
                            handleOriginChange(newValue)
                        }

                    if originSearchActive && !filteredStations.isEmpty {
                        ScrollView {
                            VStack(spacing: 0) {
                                ForEach(filteredStations, id: \.crsCode) { station in
                                    Text("\(station.stationName) (\(station.crsCode))")
                                        .padding()
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .background(Color(.secondarySystemBackground))
                                        .cornerRadius(6)
                                        .onTapGesture {
                                            localTicket.origin = "\(station.stationName) (\(station.crsCode))"
                                            filteredStations = []
                                            originSearchActive = false
                                        }
                                }
                            }
                        }
                        .frame(maxHeight: 220)
                        .background(Color(.systemBackground))
                        .cornerRadius(8)
                        .shadow(radius: 5)
                    }
                }

                VStack(alignment: .leading) {
                    Text("Destination")
                        .font(.headline)

                    TextField("Enter station name or CRS code", text: $localTicket.destination)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                        .onChange(of: localTicket.destination) { newValue in
                            handleDestinationChange(newValue)
                        }

                    if destinationSearchActive && !filteredStations.isEmpty {
                        ScrollView {
                            VStack(spacing: 0) {
                                ForEach(filteredStations, id: \.crsCode) { station in
                                    Text("\(station.stationName) (\(station.crsCode))")
                                        .padding()
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .background(Color(.secondarySystemBackground))
                                        .cornerRadius(6)
                                        .onTapGesture {
                                            localTicket.destination = "\(station.stationName) (\(station.crsCode))"
                                            filteredStations = []
                                            destinationSearchActive = false
                                        }
                                }
                            }
                        }
                        .frame(maxHeight: 220)
                        .background(Color(.systemBackground))
                        .cornerRadius(8)
                        .shadow(radius: 5)
                    }
                }
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

                VStack(alignment: .leading, spacing: 4) {
                    Text("Train Operator")
                        .font(.subheadline)
                        .foregroundColor(.secondary)

                    Button(action: {
                        withAnimation { showTocDropdown.toggle() }
                    }) {
                        HStack {
                            Text(localTicket.toc ?? "Select an operator")
                                .foregroundColor(.primary)
                            Spacer()
                            Image(systemName: "chevron.down")
                        }
                        .padding()
                        .background(Color(.systemGray5))
                        .cornerRadius(6)
                    }

                    if showTocDropdown {
                        ScrollView {
                            VStack(spacing: 0) {
                                ForEach(tocOptions.indices, id: \.self) { index in
                                    Button(action: {
                                        withAnimation {
                                            localTicket.toc = tocOptions[index] // Update `localTicket.toc` directly
                                            selectedTocIndex = index
                                            showTocDropdown = false
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
                        .frame(height: min(CGFloat(tocOptions.count), 5) * 44)
                        .background(Color(.systemGray5))
                        .cornerRadius(6)
                        .shadow(radius: 5)
                        .padding(.top, 8)
                    }
                }

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

    private func deleteButtonSection() -> some View {
        VStack {
            Button(action: {
                showDeleteConfirmation = true
            }) {
                HStack {
                    Image(systemName: "trash")
                        .foregroundColor(.white)
                    Text("Delete Ticket")
                        .foregroundColor(.white)
                        .bold()
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.red)
                .cornerRadius(10)
            }
            .padding(.top, 20)
            .confirmationDialog("Are you sure you want to delete this ticket?", isPresented: $showDeleteConfirmation, titleVisibility: .visible) {
                Button("Delete", role: .destructive, action: {
                    onDelete() // Call the onDelete closure
                    dismiss()  // Automatically navigate back to the parent view
                })
                Button("Cancel", role: .cancel, action: {})
            }
        }
    }
    
    private func compensationSection() -> some View {
        FormSection(title: "Delay & Compensation Information", icon: "clock.arrow.circlepath") {
            if isEditing {
                Toggle("Was Delayed?", isOn: $localTicket.wasDelayed)

                if localTicket.wasDelayed {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Delay Duration")
                            .font(.subheadline)
                            .foregroundColor(.secondary)

                        Button(action: {
                            withAnimation { showDelayDropdown.toggle() }
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
                                    ForEach(delayOptions.indices, id: \.self) { index in
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
                            .frame(height: min(CGFloat(delayOptions.count), 5) * 44)
                            .background(Color(.systemGray5))
                            .cornerRadius(6)
                            .shadow(radius: 5)
                            .padding(.top, 8)
                        }
                    }
                }

                Toggle("Pending Compensation", isOn: $localTicket.pendingCompensation)
                if !localTicket.pendingCompensation {
                    EditableField(label: "Compensation (£)", text: $localTicket.compensation)
                }
            } else {
                DetailRow(label: "Was Delayed", value: localTicket.wasDelayed ? "Yes" : "No", color: localTicket.wasDelayed ? .red : .green)
                if localTicket.wasDelayed {
                    DetailRow(label: "Delayed by", value: "\(delayOptions[delayDurationIndex]) minutes")
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
                        }
                    }
                }
            )
        } else {
            return AnyView(EmptyView())
        }
    }
    
    private func hasLoyaltyPrograms() -> Bool {
        guard let program = localTicket.loyaltyProgram else { return false }
        return (program.virginPoints != nil && program.virginPoints != "0") ||
               (program.lnerCashValue != nil && program.lnerCashValue != "0") ||
               (program.clubAvantiJourneys != nil && program.clubAvantiJourneys != "0")
    }

    private func saveChanges() {
        // Update the TOC and Delay Duration based on the selected indices
        localTicket.toc = tocOptions[selectedTocIndex]
        localTicket.delayDuration = delayOptions[delayDurationIndex]

        // Save loyalty program details
        localTicket.loyaltyProgram = LoyaltyProgram(
            virginPoints: isVirginEnabled ? virginPoints : nil,
            lnerCashValue: isLNEREEnabled ? lnerCashValue : nil,
            clubAvantiJourneys: isClubAvantiEnabled ? avantiJourneys : nil
        )

        // Update the ticket binding and call the onUpdate closure
        ticket = localTicket
        onUpdate(localTicket)
    }
    
    private func handleOriginChange(_ newValue: String) {
        originSearchActive = true
        destinationSearchActive = false // Ensure destination dropdown is hidden
        let lowercasedInput = newValue.lowercased()

        // Filter stations and prioritize CRS code matches
        filteredStations = stations.filter { station in
            station.crsCode.lowercased() == lowercasedInput ||
            station.stationName.lowercased().contains(lowercasedInput) ||
            station.crsCode.lowercased().contains(lowercasedInput)
        }.sorted { station1, station2 in
            station1.crsCode.lowercased() == lowercasedInput && station2.crsCode.lowercased() != lowercasedInput
        }
    }

    private func handleDestinationChange(_ newValue: String) {
        destinationSearchActive = true
        originSearchActive = false // Ensure origin dropdown is hidden
        let lowercasedInput = newValue.lowercased()

        // Filter stations and prioritize CRS code matches
        filteredStations = stations.filter { station in
            station.crsCode.lowercased() == lowercasedInput ||
            station.stationName.lowercased().contains(lowercasedInput) ||
            station.crsCode.lowercased().contains(lowercasedInput)
        }.sorted { station1, station2 in
            station1.crsCode.lowercased() == lowercasedInput && station2.crsCode.lowercased() != lowercasedInput
        }
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
