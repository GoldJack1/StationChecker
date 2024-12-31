import SwiftUI

struct TrainDeparturesListView: View {
    @State private var departures: [Departure] = []
    @State private var isLoading: Bool = true
    @State private var errorMessage: String?

    var body: some View {
        VStack {
            if isLoading {
                ProgressView("Fetching Departures...")
                    .progressViewStyle(CircularProgressViewStyle(tint: .blue))
                    .padding()
            } else if let errorMessage = errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .multilineTextAlignment(.center)
                    .padding()
            } else if departures.isEmpty {
                Text("No departures found.")
                    .foregroundColor(.gray)
                    .padding()
            } else {
                List(departures) { departure in
                    VStack(alignment: .leading, spacing: 8) {
                        Text(departure.destination)
                            .font(.title2)
                            .fontWeight(.bold)
                        Text(departure.timeFormatted)
                            .font(.title2)
                            .foregroundColor(.gray)
                        if let platform = departure.platform {
                            Text("Platform: \(platform)")
                                .font(.subheadline)
                                .foregroundColor(.blue)
                        }
                        if let toc = departure.toc {
                            Text("Operator: \(toc)")
                                .font(.footnote)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.vertical, 5)
                }
                .listStyle(PlainListStyle())
            }
        }
    }
}
