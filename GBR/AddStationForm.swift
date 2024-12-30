import SwiftUI

struct AddStationForm: View {
    // Form state properties
    @State private var stationName: String = ""
    @State private var country: String = ""
    @State private var county: String = ""
    @State private var toc: String = ""
    @State private var isFavorite: Bool = false
    @State private var latitude: String = ""
    @State private var longitude: String = ""
    @State private var usageData: [String: String] = [:]
    @State private var newUsageYear: String = ""
    @State private var newUsageValue: String = ""

    // Closure to handle adding a new station
    var onAddStation: (StationRecord) -> Void

    // Environment variable to manage the presentation
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Station Details")) {
                    TextField("Station Name", text: $stationName)
                    TextField("Country", text: $country)
                    TextField("County", text: $county)
                    TextField("Operator (TOC)", text: $toc)
                    Toggle("Mark as Favorite", isOn: $isFavorite)
                }

                Section(header: Text("Location Details")) {
                    TextField("Latitude", text: $latitude)
                        .keyboardType(.decimalPad)
                    TextField("Longitude", text: $longitude)
                        .keyboardType(.decimalPad)
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
                        TextField("Value", text: $newUsageValue)
                            .keyboardType(.default)
                        Button(action: addUsageData) {
                            Image(systemName: "plus.circle.fill")
                                .foregroundColor(.green)
                        }
                        .disabled(newUsageYear.isEmpty || newUsageValue.isEmpty)
                    }
                }
            }
            .navigationTitle("Add Station")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        addStation()
                    }
                    .disabled(stationName.isEmpty || country.isEmpty || county.isEmpty || toc.isEmpty)
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }

    // MARK: - Helper Methods

    private func addUsageData() {
        usageData[newUsageYear] = newUsageValue
        newUsageYear = ""
        newUsageValue = ""
    }

    private func addStation() {
        let newStation = StationRecord(
            id: UUID(),
            stationName: stationName,
            country: country,
            county: county,
            toc: toc,
            visited: false,
            visitDate: nil,
            isFavorite: isFavorite,
            latitude: Double(latitude) ?? 0.0,
            longitude: Double(longitude) ?? 0.0,
            usageData: usageData
        )
        onAddStation(newStation)
        dismiss()
    }
}
