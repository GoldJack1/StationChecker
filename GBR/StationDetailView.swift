import SwiftUI

struct StationDetailView: View {
    var station: StationRecord

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Station: \(station.stationName)")
                .font(.title)
            Text("Longitude: \(station.longitude)")
            Text("Latitude: \(station.latitude)")
            Text("Usage Estimate: \(station.usageEstimate)")
            Spacer()
        }
        .padding()
        .navigationTitle("Station Details")
    }
}