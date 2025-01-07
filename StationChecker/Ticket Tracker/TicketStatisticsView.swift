//
//  TicketStatisticsView.swift
//  StationChecker
//
//  Created by Jack Wingate on 07/01/2025.
//


import SwiftUI

struct TicketStatisticsView: View {
    var tickets: [TicketRecord] // Assuming statistics are based on tickets

    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Total Tickets")) {
                    Text("\(tickets.count)")
                }

                Section(header: Text("Visited Tickets")) {
                    Text("\(tickets.filter { $0.delayRepay != "£0.00" }.count)")
                }

                Section(header: Text("Not Visited Tickets")) {
                    Text("\(tickets.filter { $0.delayRepay == "£0.00" }.count)")
                }

                // Add other stats as necessary
            }
            .navigationTitle("Statistics")
            .navigationBarItems(trailing: Button("Close") {
                // Close or handle dismissing
            })
        }
    }
}