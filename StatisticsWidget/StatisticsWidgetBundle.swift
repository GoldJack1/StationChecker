//
//  StatisticsWidgetBundle.swift
//  StatisticsWidget
//
//  Created by Jack Wingate on 29/12/2024.
//

import WidgetKit
import SwiftUI

@main
struct StatisticsWidgetBundle: WidgetBundle {
    var body: some Widget {
        StatisticsWidget()
        StatisticsWidgetControl()
        StatisticsWidgetLiveActivity()
    }
}
