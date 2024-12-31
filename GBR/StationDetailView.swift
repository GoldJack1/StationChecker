import SwiftUI

struct StationDetailView: View {
    @State var station: StationRecord
    var onUpdate: (StationRecord) -> Void

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text(station.stationName)
                    .font(.largeTitle)
                    .fontWeight(.bold)

                Text("Country: \(station.country)")
                Text("County: \(station.county)")
                Text("Operator: \(station.toc)")

                if station.visited {
                    Text("Visited: Yes")
                    if let date = station.visitDate {
                        Text("Visit Date: \(date, formatter: dateFormatter)")
                    }
                } else {
                    Text("Visited: No")
                }

                // Update Visit Status Button
                Button(action: toggleVisitStatus) {
                    Text(station.visited ? "Mark as Not Visited" : "Mark as Visited")
                        .padding()
                        .background(station.visited ? Color.red : Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }

                if !station.usageData.isEmpty {
                    Text("Usage Data:")
                        .font(.headline)

                    ForEach(station.usageData.keys.sorted(), id: \.self) { year in
                        Text("\(year): \(station.usageData[year] ?? "N/A")")
                    }
                }
            }
            .padding()
        }
        .navigationTitle(station.stationName)
        .onDisappear {
            onUpdate(station)
        }
    }

    private func toggleVisitStatus() {
        station.visited.toggle()
        if station.visited {
            station.visitDate = Date()
        } else {
            station.visitDate = nil
        }
        onUpdate(station)
    }

    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }
}
