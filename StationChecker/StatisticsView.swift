import SwiftUI
import Charts

struct StatisticsView: View {
    let stations: [StationRecord]

    // Filter State
    @State private var selectedCountry: String? = nil
    @State private var selectedCounty: String? = nil

    // Filtered Stations
    private var filteredStations: [StationRecord] {
        stations.filter { station in
            if let country = selectedCountry, station.country != country {
                return false
            }
            if let county = selectedCounty, station.county != county {
                return false
            }
            return true
        }
    }

    // Calculated statistics
    private var totalStations: Int {
        filteredStations.count
    }

    private var visitedStations: Int {
        filteredStations.filter { $0.visited }.count
    }

    private var notVisitedStations: Int {
        totalStations - visitedStations
    }

    private var percentageVisited: Double {
        totalStations > 0 ? (Double(visitedStations) / Double(totalStations)) * 100 : 0.0
    }

    private var availableCountries: [String] {
        Array(Set(stations.map { $0.country })).sorted()
    }

    private var availableCounties: [String] {
        Array(Set(stations.map { $0.county })).sorted()
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 15) {
                // Filter Section
                HStack(spacing: 10) {
                    Picker("Country", selection: $selectedCountry) {
                        Text("All Countries").tag(String?.none)
                        ForEach(availableCountries, id: \.self) { country in
                            Text(country).tag(String?.some(country))
                        }
                    }
                    .pickerStyle(MenuPickerStyle())

                    Picker("County", selection: $selectedCounty) {
                        Text("All Counties").tag(String?.none)
                        ForEach(availableCounties, id: \.self) { county in
                            Text(county).tag(String?.some(county))
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                }
                .padding(.horizontal)
                .background(Color(.systemGray6))
                .cornerRadius(8)

                // Statistics Section
                ScrollView {
                    VStack(spacing: 15) {
                        StatisticCard(title: "Total Stations", value: "\(totalStations)")
                        StatisticCard(title: "Visited Stations", value: "\(visitedStations)")
                        StatisticCard(title: "Not Visited Stations", value: "\(notVisitedStations)")
                        ProgressStatisticCard(
                            title: "Percentage Visited",
                            value: String(format: "%.2f%%", percentageVisited),
                            progress: percentageVisited / 100
                        )

                        // Chart Section
                        Chart {
                            BarMark(
                                x: .value("Category", "Visited"),
                                y: .value("Count", visitedStations)
                            )
                            .foregroundStyle(.green)

                            BarMark(
                                x: .value("Category", "Not Visited"),
                                y: .value("Count", notVisitedStations)
                            )
                            .foregroundStyle(.red)
                        }
                        .frame(height: 200)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                        .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
                    }
                }
                .padding(.horizontal)
            }
            .padding(.vertical)
            .background(Color(.systemBackground).ignoresSafeArea())
            .navigationTitle("Statistics")
        }
    }
}

// MARK: - Statistic Card View
struct StatisticCard: View {
    let title: String
    let value: String

    var body: some View {
        VStack(spacing: 8) {
            Text(title)
                .font(.headline)
                .foregroundColor(.secondary)
            Text(value)
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.primary)
        }
        .frame(maxWidth: .infinity, minHeight: 80)
        .padding(10)
        .background(Color(.systemGray6))
        .cornerRadius(8)
        .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
}

// MARK: - Progress Statistic Card View
struct ProgressStatisticCard: View {
    let title: String
    let value: String
    let progress: Double

    var body: some View {
        VStack(spacing: 8) {
            Text(title)
                .font(.headline)
                .foregroundColor(.secondary)
            Text(value)
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.primary)

            // Adaptive Progress Bar
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.red.opacity(0.3)) // Background (not visited portion)
                    .frame(height: 15)

                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.green) // Visited portion
                    .frame(width: progressBarWidth(progress: progress), height: 15)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .frame(maxWidth: .infinity, minHeight: 100)
        .padding(10)
        .background(Color(.systemGray6))
        .cornerRadius(8)
        .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
    }

    private func progressBarWidth(progress: Double) -> CGFloat {
        let totalWidth: CGFloat = UIScreen.main.bounds.width - 40 // Adjust for screen padding
        return totalWidth * CGFloat(progress)
    }
}
