//
//  TicketDataOptionsSheet.swift
//  StationChecker
//
//  Created by Jack Wingate on 07/01/2025.
//


import SwiftUI

struct TicketDataOptionsSheet: View {
    var onImport: (DataType) -> Void
    var onExport: (DataType) -> Void
    var onClearData: () -> Void
    var onAddTicket: () -> Void

    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Data Operations")) {
                    Button("Import Tickets") {
                        onImport(.nationalRail) // Add other data types as needed
                    }
                    Button("Export Tickets") {
                        onExport(.nationalRail)
                    }
                    Button("Clear All Data") {
                        onClearData()
                    }
                }
                
                Section {
                    Button("Add Ticket") {
                        onAddTicket()
                    }
                }
            }
            .navigationTitle("Data Options")
            .navigationBarItems(trailing: Button("Close") {
                // Handle dismiss
            })
        }
    }
}