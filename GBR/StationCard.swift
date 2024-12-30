import SwiftUI

struct StationCard: View {
    var station: StationRecord
    var onUpdate: (StationRecord) -> Void

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text(station.stationName)
                    .font(.headline)
                Spacer()
                Button(action: {
                    var updatedStation = station
                    updatedStation.isFavorite.toggle()
                    onUpdate(updatedStation)
                }) {
                    Image(systemName: station.isFavorite ? "star.fill" : "star")
                        .foregroundColor(station.isFavorite ? .yellow : .gray)
                }
            }
            Text("Visited: \(station.visited ? "Yes" : "No")")
            Text("Country: \(station.country)")
        }
        .padding()
    }
}