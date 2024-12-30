import WidgetKit
import Charts
import SwiftUI

// Main Widget Configuration
struct StatisticsWidget: Widget {
    let kind: String = "StatisticsWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: StatisticsProvider()) { entry in
            StatisticsWidgetEntryView(entry: entry) // Reference the Entry View here
        }
        .configurationDisplayName("Station Statistics")
        .description("Track your station statistics.")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}

// Entry View for the Widget
struct StatisticsWidgetEntryView: View {
    var entry: StatisticsEntry
    @Environment(\.widgetFamily) var family // Access widget size

    var body: some View {
        switch family {
        case .systemSmall:
            smallWidgetView
        case .systemMedium:
            mediumWidgetView
        case .systemLarge:
            largeWidgetView
        default:
            mediumWidgetView
        }
    }

    // Small Widget Layout
    private var smallWidgetView: some View {
        VStack(spacing: 8) {
            Text("Stations")
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(.primary)

            Text("\(entry.totalStations)")
                .font(.system(size: 36, weight: .bold)) // Large and responsive font size
                .foregroundColor(.primary)
                .minimumScaleFactor(0.5) // Allow the text to scale if needed
                .lineLimit(1)

            Text(String(format: "%.1f%% Visited", entry.percentageVisited))
                .font(.footnote) // Use a smaller font for the percentage text
                .foregroundColor(.secondary)
                .minimumScaleFactor(0.5) // Allow dynamic scaling
                .lineLimit(1)
        }
        .padding()
        .containerBackground(Material.regular, for: .widget)
    }

    // Medium Widget Layout
    private var mediumWidgetView: some View {
        HStack {
            VStack(alignment: .leading, spacing: 8) {
                Text("Station Statistics")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)

                HStack {
                    IconWithText(icon: "building.2", text: "Total", value: "\(entry.totalStations)")
                    Spacer()
                    IconWithText(icon: "checkmark.circle", text: "Visited", value: "\(entry.visitedStations)")
                }

                HStack {
                    IconWithText(icon: "xmark.circle", text: "Not Visited", value: "\(entry.notVisitedStations)")
                    Spacer()
                    VStack(alignment: .trailing) {
                        Text("Visited %")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text(String(format: "%.1f", entry.percentageVisited))
                            .font(.headline)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                    }
                }
            }
            .padding()
        }
        .containerBackground(Material.ultraThin, for: .widget)
    }

    // Large Widget Layout
    private var largeWidgetView: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Station Statistics")
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(.primary)

            HStack {
                IconWithText(icon: "building.2", text: "Total", value: "\(entry.totalStations)")
                Spacer()
                IconWithText(icon: "checkmark.circle", text: "Visited", value: "\(entry.visitedStations)")
            }

            HStack {
                IconWithText(icon: "xmark.circle", text: "Not Visited", value: "\(entry.notVisitedStations)")
                Spacer()
                VStack(alignment: .trailing) {
                    Text("Visited %")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(String(format: "%.1f", entry.percentageVisited))
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                }
            }

            // Add a chart for the large widget
            Chart {
                BarMark(
                    x: .value("Category", "Visited"),
                    y: .value("Count", entry.visitedStations)
                )
                .foregroundStyle(.green)

                BarMark(
                    x: .value("Category", "Not Visited"),
                    y: .value("Count", entry.notVisitedStations)
                )
                .foregroundStyle(.red)
            }
            .frame(height: 150)
            .padding()
        }
        .padding()
        .containerBackground(Material.thick, for: .widget)
    }
}

// Helper View for Icons and Text
struct IconWithText: View {
    let icon: String
    let text: String
    let value: String

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .resizable()
                .scaledToFit()
                .frame(width: 20, height: 20)
                .foregroundColor(.primary)

            VStack(alignment: .leading, spacing: 2) {
                Text(text)
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text(value)
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
            }
        }
    }
}

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
        StatisticsEntry(date: Date(), totalStations: 0, visitedStations: 0, notVisitedStations: 0, percentageVisited: 0.0)
    }

    func getSnapshot(in context: Context, completion: @escaping (StatisticsEntry) -> Void) {
        completion(placeholder(in: context))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<StatisticsEntry>) -> Void) {
        let sharedDefaults = UserDefaults(suiteName: "group.com.gbr.statistics")
        let totalStations = sharedDefaults?.integer(forKey: "totalStations") ?? 0
        let visitedStations = sharedDefaults?.integer(forKey: "visitedStations") ?? 0
        let notVisitedStations = sharedDefaults?.integer(forKey: "notVisitedStations") ?? 0
        let percentageVisited = sharedDefaults?.double(forKey: "percentageVisited") ?? 0.0

        let entry = StatisticsEntry(
            date: Date(),
            totalStations: totalStations,
            visitedStations: visitedStations,
            notVisitedStations: notVisitedStations,
            percentageVisited: percentageVisited
        )

        let timeline = Timeline(entries: [entry], policy: .atEnd)
        completion(timeline)
    }
}

// Preview
struct StatisticsWidget_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            StatisticsWidgetEntryView(
                entry: StatisticsEntry(
                    date: Date(),
                    totalStations: 2586,
                    visitedStations: 538,
                    notVisitedStations: 2048,
                    percentageVisited: 20.8
                )
            )
            .previewContext(WidgetPreviewContext(family: .systemSmall))

            StatisticsWidgetEntryView(
                entry: StatisticsEntry(
                    date: Date(),
                    totalStations: 2586,
                    visitedStations: 538,
                    notVisitedStations: 2048,
                    percentageVisited: 20.8
                )
            )
            .previewContext(WidgetPreviewContext(family: .systemMedium))

            StatisticsWidgetEntryView(
                entry: StatisticsEntry(
                    date: Date(),
                    totalStations: 2586,
                    visitedStations: 538,
                    notVisitedStations: 2048,
                    percentageVisited: 20.8
                )
            )
            .previewContext(WidgetPreviewContext(family: .systemLarge))
        }
    }
}
