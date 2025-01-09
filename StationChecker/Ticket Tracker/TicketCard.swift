import SwiftUI

struct TicketCard: View {
    let ticket: TicketRecord

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("\(ticket.origin) → \(ticket.destination)")
                .font(.headline)
                .padding(.bottom, 4)

            Text("Price: \(ticket.price)")
                .font(.subheadline)

            Text("Outbound: \(ticket.outboundDate)")
                .font(.subheadline)

            Text("Delayed: \(ticket.wasDelayed)")
                .font(.subheadline)
                .foregroundColor(ticket.wasDelayed == "Yes" ? .red : .green)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(10)
        .shadow(radius: 2)
    }
}
