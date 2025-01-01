//
//  MetrolinkStationCard.swift
//  StationChecker
//
//  Created by Jack Wingate on 01/01/2025.
//
import SwiftUI

struct MetrolinkStationCard: View {
    var station: MetrolinkStationRecord
    var onUpdate: (MetrolinkStationRecord) -> Void
    var onNavigate: () -> Void

    var body: some View {
        VStack {
            Text(station.stationName)
                .font(.headline)
                .onTapGesture {
                    onNavigate()
                }

            Button(action: {
                var updatedStation = station
                updatedStation.visited.toggle()
                onUpdate(updatedStation)
            }) {
                Text(station.visited ? "Mark as Not Visited" : "Mark as Visited")
            }
        }
    }
}
