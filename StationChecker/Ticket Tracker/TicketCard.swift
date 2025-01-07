import SwiftUI

struct TicketCard: View {
    var ticket: TicketRecord

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                // Check if rangerRover is not empty (optional, unwrapped safely)
                if let rangerRover = ticket.rangerRover, !rangerRover.isEmpty {
                    Text(rangerRover)
                        .font(.headline)
                        .foregroundColor(.blue)
                } else {
                    Text("\(ticket.origin) → \(ticket.destination)")
                        .font(.headline)
                        .fontWeight(.bold)
                }
                Spacer()
                Image(systemName: "ticket")
                    .foregroundColor(.secondary)
            }

            Text("Type: \(ticket.ticketType)")
                .font(.subheadline)
                .foregroundColor(.secondary)

            Text("Class: \(ticket.travelClass)")
                .font(.subheadline)
                .foregroundColor(.secondary)

            Text("Price: \(ticket.price)")
                .font(.subheadline)
                .foregroundColor(.secondary)

            // Check if delayRepay is not "£0.00" (No need for optional binding)
            if ticket.delayRepay != "£0.00" {
                Text("Delay Repay: \(ticket.delayRepay)")
                    .font(.subheadline)
                    .foregroundColor(.red)
            }

            // Check if outboundDate is not nil and not empty
            if let outboundDate = ticket.outboundDate, !outboundDate.isEmpty {
                Text("Outbound: \(outboundDate)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }

            // Check if returnDate is not nil and not empty
            if let returnDate = ticket.returnDate, !returnDate.isEmpty {
                Text("Return: \(returnDate)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
}
