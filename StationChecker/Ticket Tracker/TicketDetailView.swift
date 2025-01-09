import SwiftUI

struct TicketDetailView: View {
    let ticket: TicketRecord

    var body: some View {
        Form {
            Section(header: Text("Journey Details")) {
                Text("Origin: \(ticket.origin)")
                Text("Destination: \(ticket.destination)")
            }

            Section(header: Text("Ticket Details")) {
                Text("Price: \(ticket.price)")
                Text("Type: \(ticket.ticketType)")
                Text("Outbound Date: \(ticket.outboundDate)")
                if !ticket.returnDate.isEmpty {
                    Text("Return Date: \(ticket.returnDate)")
                }
            }

            Section(header: Text("Delay Information")) {
                Text("Was Delayed: \(ticket.wasDelayed)")
                    .foregroundColor(ticket.wasDelayed == "Yes" ? .red : .green)
                if ticket.wasDelayed == "Yes" {
                    Text("Delayed by: \(ticket.delayDuration)")
                }
            }

            Section(header: Text("Compensation")) {
                if ticket.compensation == "Pending" {
                    Text("Compensation: Pending")
                        .foregroundColor(.orange)
                } else if !ticket.compensation.isEmpty {
                    Text("Compensation Given: \(ticket.compensation)")
                        .foregroundColor(.green)
                } else {
                    Text("No Compensation")
                        .foregroundColor(.secondary)
                }
            }

            Section(header: Text("Loyalty Programs")) {
                if !ticket.loyaltyProgram.isEmpty {
                    let programs = ticket.loyaltyProgram.components(separatedBy: "; ")
                    ForEach(programs, id: \.self) { program in
                        Text(program)
                    }
                } else {
                    Text("No Loyalty Programs Used")
                        .foregroundColor(.secondary)
                }
            }
        }
        .navigationTitle("Ticket Details")
    }
}
