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
                ProgressView("Fetching Departures...")
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
                    NavigationLink(
                        destination: TrainServiceDetailView(
                            serviceUid: departure.serviceUid,
                            runDate: selectedDate
                        )
                    ) {
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
                }
                .listStyle(PlainListStyle())
            }
        }
        .navigationTitle("Departures for \(stationCode)")
        .onAppear {
            fetchDepartures()
        }
    }

    // Add this function to fetch train departures
    func fetchDepartures() {
        let username = "rttapi_Jwingate"
        let password = "cdc13453d23bbbad1cad0deba56b9f3497eacd96"

        let loginString = "\(username):\(password)"
        guard let loginData = loginString.data(using: .utf8) else {
            self.errorMessage = "Failed to encode API credentials."
            self.isLoading = false
            return
        }
        let base64LoginString = loginData.base64EncodedString()

        // Format date and time for API
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy/MM/dd"
        let formattedDate = dateFormatter.string(from: selectedDate)

        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "HHmm" // Format for hhmm (e.g., 0810)
        let formattedTime = timeFormatter.string(from: selectedDate)

        // Construct API URL
        let urlString = "https://api.rtt.io/api/v1/json/search/\(stationCode)/\(formattedDate)/\(formattedTime)"
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
                    self.errorMessage = "Failed to fetch train departures."
                    self.isLoading = false
                    return
                }

                guard let data = data else {
                    self.errorMessage = "No data received."
                    self.isLoading = false
                    return
                }

                do {
                    if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                       let services = json["services"] as? [[String: Any]] {
                        self.departures = services.compactMap { service in
                            guard let locationDetail = service["locationDetail"] as? [String: Any],
                                  let gbttBookedDeparture = locationDetail["gbttBookedDeparture"] as? String,
                                  let destinationArray = locationDetail["destination"] as? [[String: Any]],
                                  let destinationDescription = destinationArray.first?["description"] as? String,
                                  let toc = service["atocName"] as? String,
                                  let serviceUid = service["serviceUid"] as? String else {
                                return nil
                            }

                            let platform = locationDetail["platform"] as? String

                            return Departure(
                                id: UUID(),
                                time: gbttBookedDeparture,
                                destination: destinationDescription,
                                platform: platform,
                                toc: toc,
                                serviceUid: serviceUid,
                                stops: [] // Stops can be fetched later in TrainServiceDetailView
                            )
                        }
                        self.isLoading = false
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
}
