import SwiftUI

struct AddStationForm: View {
    @State private var stationName: String = ""
    @State private var country: String = ""
    @State private var county: String = ""
    @State private var toc: String = ""
    @State private var visited: Bool = false
    @State private var visitDate: Date? = nil
    @State private var isFavorite: Bool = false
    @State private var latitude: String = ""
    @State private var longitude: String = ""
    @State private var usageData: [String: String] = [:]
    @State private var newUsageYear: String = ""
    @State private var newUsageValue: String = ""

    var onSave: (StationRecord) -> Void
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("General Information")) {
                    TextField("Station Name", text: $stationName)
                    TextField("Country", text: $country)
                    TextField("County", text: $county)
                    TextField("Operator (TOC)", text: $toc)
                }

                Section(header: Text("Visited Information")) {
                    Toggle("Visited", isOn: $visited)
                    if visited {
                        DatePicker("Visit Date", selection: Binding($visitDate, Date()))
                            .datePickerStyle(GraphicalDatePickerStyle())
                    }
                }

                Section(header: Text("Location")) {
                    TextField("Latitude", text: $latitude)
                        .keyboardType(.decimalPad)
                    TextField("Longitude", text: $longitude)
                        .keyboardType(.decimalPad)
                }

                Section(header: Text("Preferences")) {
                    Toggle("Favorite", isOn: $isFavorite)
                }

                Section(header: Text("Usage Data")) {
                    ForEach(usageData.sorted(by: { $0.key > $1.key }), id: \.key) { year, value in
                        HStack {
                            Text(year)
                            Spacer()
                            Text(value)
                        }
                    }
                    HStack {
                        TextField("Year", text: $newUsageYear)
                            .keyboardType(.numberPad)
                        TextField("Usage Value", text: $newUsageValue)
                            .keyboardType(.default)
                        Button(action: addUsageData) {
                            Image(systemName: "plus.circle.fill")
                                .foregroundColor(.green)
                        }
                        .disabled(newUsageYear.isEmpty || newUsageValue.isEmpty)
                    }
                }
            }
            .navigationTitle("Add New Station")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveStation()
                    }
                    .disabled(stationName.isEmpty || country.isEmpty || county.isEmpty || toc.isEmpty)
                }
            }
        }
    }

    private func addUsageData() {
        usageData[newUsageYear] = newUsageValue
        newUsageYear = ""
        newUsageValue = ""
    }

    private func saveStation() {
        let newStation = StationRecord(
            id: UUID(),
            stationName: stationName,
            country: country,
            county: county,
            toc: toc,
            visited: visited,
            visitDate: visitDate,
            isFavorite: isFavorite,
            latitude: Double(latitude) ?? 0.0,
            longitude: Double(longitude) ?? 0.0,
            usageData: usageData
        )
        onSave(newStation)
        dismiss()
    }
}