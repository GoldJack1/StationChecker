import SwiftUI

struct TrainDeparturesResultView: View {
    let stationCode: String
    let selectedDate: Date

    @State private var departures: [Departure] = []
    @State private var isLoading: Bool = true
    @State private var errorMessage: String?

    var body: some View {
        VStack {
            if isLoading {
                ProgressView("Fetching Train Times...")
                    .progressViewStyle(CircularProgressViewStyle(tint: .blue))
                    .padding()
            } else if let errorMessage = errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .multilineTextAlignment(.center)
                    .padding()
            } else if departures.isEmpty {
                Text("No departures found for the selected date and time.")
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
        .navigationTitle("Departures for \(stationCode)")
        .onAppear {
            fetchDepartures()
        }
    }

    func fetchDepartures() {
        // Add API logic here to fetch data using stationCode and selectedDate
        // Update departures or errorMessage accordingly
        isLoading = false
    }
}