import SwiftUI

struct TrainServiceDetailView: View {
    let serviceUid: String
    let runDate: Date

    @State private var stops: [TrainStop] = []
    @State private var operatorName: String = ""
    @State private var trainIdentity: String = ""
    @State private var powerType: String = ""
    @State private var isRealtimeActivated: Bool = false
    @State private var startStation: String = ""
    @State private var startDeparture: String = ""
    @State private var destinationStation: String = ""
    @State private var destinationArrival: String = ""
    @State private var isLoading: Bool = true
    @State private var errorMessage: String?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Header Section
                VStack(alignment: .leading, spacing: 8) {
                    Text("Train Service Details")
                        .font(.largeTitle)
                        .bold()
                        .padding(.top)

                    Text("Service UID: \(serviceUid)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal)

                if isLoading {
                    ProgressView("Loading service details...")
                        .progressViewStyle(CircularProgressViewStyle())
                        .padding()
                } else if let errorMessage = errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .multilineTextAlignment(.center)
                        .padding()
                } else {
                    // Service Info Section
                    GroupBox(label: Label("Service Information", systemImage: "info.circle")) {
                        VStack(alignment: .leading, spacing: 8) {
                            InfoRow(label: "Operator", value: operatorName)
                            InfoRow(label: "Train Identity", value: trainIdentity)
                            InfoRow(label: "Power Type", value: powerType)
                            InfoRow(label: "Realtime Status", value: isRealtimeActivated ? "Activated" : "Not Activated", valueColor: isRealtimeActivated ? .green : .gray)
                        }
                        .padding()
                    }
                    .padding(.horizontal)

                    // Stops Section
                    GroupBox(label: Label("Stops", systemImage: "list.bullet.rectangle")) {
                        VStack(alignment: .leading, spacing: 8) {
                            ForEach(stops, id: \.stationName) { stop in
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(stop.stationName)
                                        .font(stop.stationName == startStation || stop.stationName == destinationStation ? .headline.bold() : .headline)
                                        .foregroundColor(.primary)

                                    if isStationDeparted(stop) {
                                        Text("Departed at \(stop.departureTime)")
                                            .font(.subheadline)
                                            .foregroundColor(.red)
                                    } else if stop.stationName == startStation {
                                        Text("Departure: \(stop.departureTime)")
                                            .font(.subheadline)
                                            .foregroundColor(.blue)
                                    } else if stop.stationName == destinationStation {
                                        Text("Arrival: \(stop.arrivalTime)")
                                            .font(.subheadline)
                                            .foregroundColor(.blue)
                                    } else {
                                        HStack {
                                            Text("Arrival: \(stop.arrivalTime)")
                                                .font(.subheadline)
                                                .foregroundColor(.gray)
                                            Spacer()
                                            Text("Departure: \(stop.departureTime)")
                                                .font(.subheadline)
                                                .foregroundColor(.blue)
                                        }
                                    }
                                }
                                .padding(.vertical, 5)
                                Divider()
                            }
                        }
                        .padding()
                    }
                    .padding(.horizontal)
                }
            }
        }
        .navigationTitle("Service Detail")
        .onAppear {
            fetchServiceDetails()
        }
    }

    func fetchServiceDetails() {
        let username = "rttapi_Jwingate"
        let password = "cdc13453d23bbbad1cad0deba56b9f3497eacd96"

        let loginString = "\(username):\(password)"
        guard let loginData = loginString.data(using: .utf8) else {
            self.errorMessage = "Failed to encode API credentials."
            self.isLoading = false
            return
        }
        let base64LoginString = loginData.base64EncodedString()

        // Format date for API
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy/MM/dd"
        let formattedDate = dateFormatter.string(from: runDate)

        let urlString = "https://api.rtt.io/api/v1/json/service/\(serviceUid)/\(formattedDate)"
        guard let url = URL(string: urlString) else {
            self.errorMessage = "Invalid URL format."
            self.isLoading = false
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Basic \(base64LoginString)", forHTTPHeaderField: "Authorization")

        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    self.errorMessage = "Network error: \(error.localizedDescription)"
                    self.isLoading = false
                    return
                }

                guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                    self.errorMessage = "Failed to fetch service details."
                    self.isLoading = false
                    return
                }

                guard let data = data else {
                    self.errorMessage = "No data received."
                    self.isLoading = false
                    return
                }

                do {
                    if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                        self.operatorName = json["atocName"] as? String ?? "Unknown"
                        self.trainIdentity = json["trainIdentity"] as? String ?? "Unknown"
                        self.powerType = json["powerType"] as? String ?? "Unknown"
                        self.isRealtimeActivated = json["realtimeActivated"] as? Bool ?? false

                        if let origins = json["origin"] as? [[String: Any]],
                           let originDescription = origins.first?["description"] as? String,
                           let originDeparture = origins.first?["publicTime"] as? String {
                            self.startStation = originDescription
                            self.startDeparture = originDeparture
                        }

                        if let destinations = json["destination"] as? [[String: Any]],
                           let destinationDescription = destinations.first?["description"] as? String,
                           let destinationArrival = destinations.first?["publicTime"] as? String {
                            self.destinationStation = destinationDescription
                            self.destinationArrival = destinationArrival
                        }

                        if let locations = json["locations"] as? [[String: Any]] {
                            self.stops = locations.compactMap { location in
                                guard let stationName = location["description"] as? String else {
                                    return nil
                                }
                                let arrivalTime = location["realtimeArrival"] as? String ?? location["gbttBookedArrival"] as? String ?? "N/A"
                                let departureTime = location["realtimeDeparture"] as? String ?? location["gbttBookedDeparture"] as? String ?? "N/A"
                                return TrainStop(
                                    stationName: stationName,
                                    arrivalTime: arrivalTime,
                                    departureTime: departureTime
                                )
                            }
                        }
                    } else {
                        self.errorMessage = "Invalid response format."
                    }
                } catch {
                    self.errorMessage = "JSON parsing error: \(error.localizedDescription)"
                }
                self.isLoading = false
            }
        }.resume()
    }

    func isStationDeparted(_ stop: TrainStop) -> Bool {
        guard let currentTime = getCurrentTime() else { return false }
        return stop.departureTime != "N/A" && stop.departureTime < currentTime
    }

    func getCurrentTime() -> String? {
        let formatter = DateFormatter()
        formatter.dateFormat = "HHmm"
        return formatter.string(from: Date())
    }
}

// Reusable InfoRow Component
struct InfoRow: View {
    let label: String
    let value: String
    var valueColor: Color = .primary

    var body: some View {
        HStack {
            Text("\(label):")
                .font(.subheadline)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .font(.subheadline)
                .foregroundColor(valueColor)
        }
    }
}
