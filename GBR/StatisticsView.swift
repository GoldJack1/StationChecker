import SwiftUI
import Charts
import WidgetKit

struct StatisticsView: View {
    let stations: [StationRecord]

    // Filter State
    @State private var selectedCountry: String? = nil
    @State private var selectedCounty: String? = nil
    @State private var showOnlyVisited: Bool = false
    @State private var showOnlyFavorites: Bool = false

    // Statistics Data
    @State private var totalStations: Int = 0
    @State private var visitedStations: Int = 0
    @State private var notVisitedStations: Int = 0
    @State private var percentageVisited: Double = 0.0

    // Filtered Stations
    private var filteredStations: [StationRecord] {
        stations.filter { station in
            if let country = selectedCountry, station.country != country {
                return false
            }
            if let county = selectedCounty, station.county != county {
                return false
            }
            if showOnlyVisited && !station.visited {
                return false
            }
            if showOnlyFavorites && !station.isFavorite {
                return false
            }
            return true
        }
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

                Toggle("Show Visited Only", isOn: $showOnlyVisited)
                    .padding(.horizontal)
                    .toggleStyle(SwitchToggleStyle())

                Toggle("Show Favorites Only", isOn: $showOnlyFavorites)
                    .padding(.horizontal)
                    .toggleStyle(SwitchToggleStyle())

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
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: saveStatisticsToSharedContainer) {
                        Image(systemName: "square.and.arrow.up")
                    }
                }
            }
            .onAppear {
                calculateStatistics()
            }
        }
    }

    // MARK: - Helper Methods

    private var availableCountries: [String] {
        Array(Set(stations.map { $0.country })).sorted()
    }

    private var availableCounties: [String] {
        Array(Set(stations.map { $0.county })).sorted()
    }

    private func calculateStatistics() {
        totalStations = filteredStations.count
        visitedStations = filteredStations.filter { $0.visited }.count
        notVisitedStations = totalStations - visitedStations
        percentageVisited = totalStations > 0 ? (Double(visitedStations) / Double(totalStations)) * 100 : 0.0
    }

    private func saveStatisticsToSharedContainer() {
        let sharedDefaults = UserDefaults(suiteName: "group.com.gbr.statistics")
        sharedDefaults?.set(totalStations, forKey: "totalStations")
        sharedDefaults?.set(visitedStations, forKey: "visitedStations")
        sharedDefaults?.set(notVisitedStations, forKey: "notVisitedStations")
        sharedDefaults?.set(percentageVisited, forKey: "percentageVisited")

        WidgetCenter.shared.reloadAllTimelines() // Refresh widget data
    }
}

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
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(10)
        .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
}

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

            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.red.opacity(0.3)) // Background
                    .frame(height: 15)

                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.green) // Progress
                    .frame(width: progressBarWidth(progress: progress), height: 15)
            }
        }
        .frame(maxWidth: .infinity, minHeight: 100)
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(10)
        .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
    }

    private func progressBarWidth(progress: Double) -> CGFloat {
        let totalWidth = UIScreen.main.bounds.width - 40 // Padding for screen edges
        return totalWidth * CGFloat(progress)
    }
}
