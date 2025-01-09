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
    @State private var hasReturnTicket: Bool = false
    @State private var returnDate: Date = Date()
    @State private var wasDelayed: Bool = false
    @State private var delayDuration: String = "15-29"
    @State private var pendingCompensation: Bool = false
    @State private var compensation: String = ""
    @State private var isVirginEnabled: Bool = false
    @State private var virginPoints: String = ""
    @State private var isLNEREEnabled: Bool = false
    @State private var lnerCashValue: String = ""
    @State private var isClubAvantiEnabled: Bool = false
    @State private var clubAvantiJourneys: String = ""

    let delayOptions = ["15-29", "30-59", "60-120", "Cancelled"]

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

                        FormField(label: "TOC (Optional)", text: $toc, icon: "building.2")

                        DatePicker("Outbound Date", selection: $outboundDate, displayedComponents: .date)
                            .padding(.vertical)

                        Toggle("Return Ticket", isOn: $hasReturnTicket)
                            .padding(.vertical)

                        if hasReturnTicket {
                            DatePicker("Return Date", selection: $returnDate, displayedComponents: .date)
                                .padding(.vertical)
                        }
                    }

                    // Delay Information Section
                    FormSection(title: "Delay Information", icon: "clock.arrow.circlepath") {
                        Toggle("Was Delayed?", isOn: $wasDelayed)
                            .padding(.vertical)

                        if wasDelayed {
                            Picker("Delay Duration", selection: $delayDuration) {
                                ForEach(delayOptions, id: \.self) { option in
                                    Text(option)
                                }
                            }
                            .pickerStyle(MenuPickerStyle())
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

    private func saveTicket() {
        // Save logic remains unchanged
    }
}

struct FormSection<Content: View>: View {
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
            .background(RoundedRectangle(cornerRadius: 10)
                .fill(Color(.secondarySystemBackground))
                .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2))
        }
        .padding(.horizontal)
    }
}

struct FormField: View {
    let label: String
    @Binding var text: String
    let icon: String

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(.gray)
                Text(label)
                    .font(.subheadline)
                    .foregroundColor(.primary)
            }
            TextField(label, text: $text)
                .padding(10)
                .background(RoundedRectangle(cornerRadius: 10).fill(Color.gray.opacity(0.1)))
        }
    }
}
