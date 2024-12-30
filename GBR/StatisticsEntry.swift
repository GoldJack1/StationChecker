import WidgetKit
import SwiftUI

struct StatisticsEntry: TimelineEntry {
    let date: Date
    let totalStations: Int
    let visitedStations: Int
    let favoriteStations: Int
}

struct StatisticsProvider: TimelineProvider {
    func placeholder(in context: Context) -> StatisticsEntry {
        StatisticsEntry(date: Date(), totalStations: 0, visitedStations: 0, favoriteStations: 0)
    }

    func getSnapshot(in context: Context, completion: @escaping (StatisticsEntry) -> Void) {
        let entry = StatisticsEntry(date: Date(), totalStations: 100, visitedStations: 50, favoriteStations: 20)
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<StatisticsEntry>) -> Void) {
        // Load data from shared storage
        let sharedDefaults = UserDefaults(suiteName: "group.com.yourapp.statistics")
        let totalStations = sharedDefaults?.integer(forKey: "totalStations") ?? 0
        let visitedStations = sharedDefaults?.integer(forKey: "visitedStations") ?? 0
        let favoriteStations = sharedDefaults?.integer(forKey: "favoriteStations") ?? 0

        let entry = StatisticsEntry(
            date: Date(),
            totalStations: totalStations,
            visitedStations: visitedStations,
            favoriteStations: favoriteStations
        )

        let timeline = Timeline(entries: [entry], policy: .atEnd)
        completion(timeline)
    }
}

struct StatisticsWidgetEntryView: View {
    var entry: StatisticsProvider.Entry

    var body: some View {
        VStack(alignment: .leading) {
            Text("Station Statistics")
                .font(.headline)
                .padding(.bottom, 8)

            HStack {
                VStack(alignment: .leading) {
                    Text("Total: \(entry.totalStations)")
                    Text("Visited: \(entry.visitedStations)")
                    Text("Favorites: \(entry.favoriteStations)")
                }
                Spacer()
            }
            .font(.subheadline)
            .padding()
        }
        .padding()
    }
}

@main
struct StatisticsWidget: Widget {
    let kind: String = "StatisticsWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: StatisticsProvider()) { entry in
            StatisticsWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Station Statistics")
        .description("Track your station visit and favorite statistics.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}