//
//  StatisticsWidgetLiveActivity.swift
//  StatisticsWidget
//
//  Created by Jack Wingate on 29/12/2024.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct StatisticsWidgetAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic stateful properties about your activity go here!
        var emoji: String
    }

    // Fixed non-changing properties about your activity go here!
    var name: String
}

struct StatisticsWidgetLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: StatisticsWidgetAttributes.self) { context in
            // Lock screen/banner UI goes here
            VStack {
                Text("Hello \(context.state.emoji)")
            }
            .activityBackgroundTint(Color.cyan)
            .activitySystemActionForegroundColor(Color.black)

        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded UI goes here.  Compose the expanded UI through
                // various regions, like leading/trailing/center/bottom
                DynamicIslandExpandedRegion(.leading) {
                    Text("Leading")
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text("Trailing")
                }
                DynamicIslandExpandedRegion(.bottom) {
                    Text("Bottom \(context.state.emoji)")
                    // more content
                }
            } compactLeading: {
                Text("L")
            } compactTrailing: {
                Text("T \(context.state.emoji)")
            } minimal: {
                Text(context.state.emoji)
            }
            .widgetURL(URL(string: "http://www.apple.com"))
            .keylineTint(Color.red)
        }
    }
}

extension StatisticsWidgetAttributes {
    fileprivate static var preview: StatisticsWidgetAttributes {
        StatisticsWidgetAttributes(name: "World")
    }
}

extension StatisticsWidgetAttributes.ContentState {
    fileprivate static var smiley: StatisticsWidgetAttributes.ContentState {
        StatisticsWidgetAttributes.ContentState(emoji: "😀")
     }
     
     fileprivate static var starEyes: StatisticsWidgetAttributes.ContentState {
         StatisticsWidgetAttributes.ContentState(emoji: "🤩")
     }
}

#Preview("Notification", as: .content, using: StatisticsWidgetAttributes.preview) {
   StatisticsWidgetLiveActivity()
} contentStates: {
    StatisticsWidgetAttributes.ContentState.smiley
    StatisticsWidgetAttributes.ContentState.starEyes
}
