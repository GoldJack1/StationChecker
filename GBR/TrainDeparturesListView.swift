//
//  TrainDeparturesView.swift
//  GBR
//
//  Created by Jack Wingate on 25/12/2024.
//


import SwiftUI

struct TrainDeparturesView: View {
    @State private var departures: [String] = [] // State variable to store fetched departures
    @State private var isLoading: Bool = true // To show a loading indicator

    var body: some View {
        NavigationView {
            VStack {
                if isLoading {
                    ProgressView("Loading Departures...")
                } else if departures.isEmpty {
                    Text("No departures found.")
                        .foregroundColor(.gray)
                } else {
                    List(departures, id: \.self) { departure in
                        Text(departure)
                    }
                }
            }
            .navigationTitle("Leeds Departures")
            .onAppear {
                fetchTrainDepartures { fetchedDepartures in
                    self.departures = fetchedDepartures
                    self.isLoading = false
                }
            }
        }
    }

    func fetchTrainDepartures(completion: @escaping ([String]) -> Void) {
        // Replace with your Real Time Trains API credentials
        let username = "rttapi_Jwingate"
        let password = "cdc13453d23bbbad1cad0deba56b9f3497eacd96"

        // Encode credentials in Base64
        let loginString = "\(username):\(password)"
        guard let loginData = loginString.data(using: .utf8) else {
            print("Failed to encode credentials")
            return
        }
        let base64LoginString = loginData.base64EncodedString()

        // Construct API URL for Leeds departures on 30th December 2024
        let urlString = "https://api.rtt.io/api/v1/json/search/LDS/departures/2024/12/30"
        guard let url = URL(string: urlString) else {
            print("Invalid URL")
            return
        }

        // Create the URLRequest
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Basic \(base64LoginString)", forHTTPHeaderField: "Authorization")

        // Perform the network request
        URLSession.shared.dataTask(with: request) { data, response, error in
            // Handle errors
            if let error = error {
                print("Error: \(error.localizedDescription)")
                return
            }

            // Check response and data
            guard let data = data else {
                print("No data received")
                return
            }

            // Parse JSON response
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                   let services = json["services"] as? [[String: Any]] {
                    var fetchedDepartures: [String] = []
                    for service in services {
                        if let destination = service["destination"] as? [[String: Any]],
                           let destinationName = destination.first?["locationName"] as? String,
                           let std = service["std"] as? String {
                            fetchedDepartures.append("Departure at \(std) to \(destinationName)")
                        }
                    }
                    DispatchQueue.main.async {
                        completion(fetchedDepartures)
                    }
                }
            } catch {
                print("JSON parsing error: \(error.localizedDescription)")
            }
        }.resume()
    }
}
