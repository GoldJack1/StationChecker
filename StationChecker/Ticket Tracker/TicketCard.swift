import SwiftUI

struct TicketCard: View {
    var ticket: TicketRecord

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Date and Price Row
            HStack {
                Text(formatDate(ticket.outboundDate))
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Spacer()
                Text(ticket.price)
                    .font(.title3)
                    .bold()
            }

            // Time and Journey Row
            Text("\(ticket.outboundTime) \(ticket.origin) to \(ticket.destination)")
                .font(.headline)
                .foregroundColor(.primary)

            // Ticket Type
            Text(ticket.ticketType)
                .font(.subheadline)
                .bold()
                .foregroundColor(.secondary)

            // Operator and Delay Information
            HStack {
                Text(ticket.toc ?? "Unknown")
                    .font(.subheadline)
                    .foregroundColor(colorForTOC(ticket.toc) ?? .primary)

                Spacer()

                if ticket.wasDelayed, let compensation = Double(ticket.compensation), compensation > 0 {
                    Text("Delay Repay - £\(compensation, specifier: "%.2f")")
                        .font(.subheadline)
                        .foregroundColor(.red)
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemGray6))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(colorForTOC(ticket.toc) ?? Color.primary, lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
        .padding(.horizontal)
    }

    // Helper function to format date
    private func formatDate(_ date: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        guard let dateObj = formatter.date(from: date) else { return date }
        let displayFormatter = DateFormatter()
        displayFormatter.dateStyle = .medium
        return displayFormatter.string(from: dateObj)
    }

    // Helper function for TOC colors
    private func colorForTOC(_ toc: String?) -> Color? {
        guard let toc = toc, let hex = tocColors[toc] else {
            return nil
        }
        return Color(hex: hex)
    }
}
