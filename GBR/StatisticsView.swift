import SwiftUI

struct StatisticsView: View {
    let stations: [StationRecord]

    // Calculated statistics
    private var totalStations: Int {
        stations.count
    }

    private var visitedStations: Int {
        stations.filter { $0.visited }.count
    }

    private var notVisitedStations: Int {
        totalStations - visitedStations
    }

    private var percentageVisited: Double {
        totalStations > 0 ? (Double(visitedStations) / Double(totalStations)) * 100 : 0.0
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                StatisticCard(title: "Total Stations", value: "\(totalStations)")
                StatisticCard(title: "Visited Stations", value: "\(visitedStations)")
                StatisticCard(title: "Not Visited Stations", value: "\(notVisitedStations)")
                StatisticCard(title: "Percentage Visited", value: String(format: "%.2f%%", percentageVisited))

                Spacer()
            }
            .padding()
            .navigationTitle("Statistics")
        }
    }
}

struct StatisticCard: View {
    let title: String
    let value: String

    var body: some View {
        VStack {
            Text(title)
                .font(.headline)
                .foregroundColor(.secondary)
            Text(value)
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.primary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(10)
        .shadow(radius: 3)
    }
}