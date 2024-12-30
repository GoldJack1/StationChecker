import WidgetKit
import SwiftUI

// Timeline Entry
struct StatisticsEntry: TimelineEntry {
    let date: Date
    let totalStations: Int
    let visitedStations: Int
    let notVisitedStations: Int
    let percentageVisited: Double
}

// Provider
struct StatisticsProvider: TimelineProvider {
    func placeholder(in context: Context) -> StatisticsEntry {
        StatisticsEntry(
            date: Date(),
            totalStations: 0,
            visitedStations: 0,
            notVisitedStations: 0,
            percentageVisited: 0.0
        )
    }

    func getSnapshot(in context: Context, completion: @escaping (StatisticsEntry) -> Void) {
        let entry = fetchStatistics()
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<StatisticsEntry>) -> Void) {
        let entry = fetchStatistics()
        let timeline = Timeline(entries: [entry], policy: .atEnd)
        completion(timeline)
    }

    private func fetchStatistics() -> StatisticsEntry {
        let sharedDefaults = UserDefaults(suiteName: "group.com.gbr.statistics")
        let totalStations = sharedDefaults?.integer(forKey: "totalStations") ?? 0
        let visitedStations = sharedDefaults?.integer(forKey: "visitedStations") ?? 0
        let notVisitedStations = sharedDefaults?.integer(forKey: "notVisitedStations") ?? 0
        let percentageVisited = sharedDefaults?.double(forKey: "percentageVisited") ?? 0.0

        return StatisticsEntry(
            date: Date(),
            totalStations: totalStations,
            visitedStations: visitedStations,
            notVisitedStations: notVisitedStations,
            percentageVisited: percentageVisited
        )
    }
}

// Entry View
struct StatisticsWidgetEntryView: View {
    var entry: StatisticsEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Station Statistics")
                .font(.headline)
                .fontWeight(.bold)

            Text("Total Stations: \(entry.totalStations)")
            Text("Visited Stations: \(entry.visitedStations)")
            Text("Not Visited: \(entry.notVisitedStations)")
            Text(String(format: "Visited %%: %.2f", entry.percentageVisited))
        }
        .padding()
        .containerBackground(Material.regular, for: .widget) // Widget background
    }
}

// Main Widget
struct StatisticsWidget: Widget {
    let kind: String = "StatisticsWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: StatisticsProvider()) { entry in
            StatisticsWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Station Statistics")
        .description("Track your station statistics.")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}

// Preview
struct StatisticsWidget_Previews: PreviewProvider {
    static var previews: some View {
        StatisticsWidgetEntryView(
            entry: StatisticsEntry(
                date: Date(),
                totalStations: 100,
                visitedStations: 50,
                notVisitedStations: 50,
                percentageVisited: 50.0
            )
        )
        .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
