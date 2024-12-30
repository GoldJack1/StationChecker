import SwiftUI

struct TrainServiceDetailView: View {
    let departure: Departure
    
    var body: some View {
        VStack {
            Text("Service Details")
                .font(.largeTitle)
                .padding()
            
            List(departure.stops, id: \.stationName) { stop in
                VStack(alignment: .leading) {
                    Text(stop.stationName)
                        .font(.headline)
                    Text("Arrival Time: \(stop.arrivalTime)")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    Text("Departure Time: \(stop.departureTime)")
                        .font(.subheadline)
                        .foregroundColor(.blue)
                }
                .padding(.vertical, 5)
            }
            
            Spacer()
        }
        .navigationTitle("Train Service Detail")
    }
}