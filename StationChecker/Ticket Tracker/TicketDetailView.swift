import SwiftUI

struct TicketDetailView: View {
    let ticket: TicketRecord

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Journey Details Section
                DetailSection(title: "Journey Details", icon: "airplane.departure") {
                    DetailRow(label: "Origin", value: ticket.origin)
                    DetailRow(label: "Destination", value: ticket.destination)
                }

                // Ticket Details Section
                DetailSection(title: "Ticket Details", icon: "ticket") {
                    DetailRow(label: "Price", value: ticket.price.hasPrefix("£") ? ticket.price : "£\(ticket.price)")
                    DetailRow(label: "Type", value: ticket.ticketType)
                    DetailRow(label: "Outbound Date", value: ticket.outboundDate)
                    if !ticket.returnDate.isEmpty {
                        DetailRow(label: "Return Date", value: ticket.returnDate)
                    }
                }

                // Delay Information Section
                DetailSection(title: "Delay Information", icon: "clock.arrow.circlepath") {
                    DetailRow(label: "Was Delayed", value: ticket.wasDelayed, color: ticket.wasDelayed == "Yes" ? .red : .green)
                    if ticket.wasDelayed == "Yes" {
                        DetailRow(label: "Delayed by", value: "\(ticket.delayDuration) minutes")
                    }
                }

                // Compensation Section
                DetailSection(title: "Compensation", icon: "banknote") {
                    if ticket.compensation == "Pending" {
                        Text("Compensation: Pending")
                            .foregroundColor(.orange)
                            .font(.body)
                    } else if !ticket.compensation.isEmpty {
                        Text("Compensation Given: \(ticket.compensation.hasPrefix("£") ? ticket.compensation : "£\(ticket.compensation)")")
                            .foregroundColor(.green)
                            .font(.body)
                    } else {
                        Text("No Compensation")
                            .foregroundColor(.secondary)
                            .font(.body)
                    }
                }

                // Loyalty Programs Section
                DetailSection(title: "Loyalty Programs", icon: "star") {
                    if !ticket.loyaltyProgram.isEmpty {
                        let programs = ticket.loyaltyProgram.components(separatedBy: "; ")
                        ForEach(programs, id: \.self) { program in
                            Text(program)
                                .font(.body)
                                .padding(.vertical, 4)
                        }
                    } else {
                        Text("No Loyalty Programs Used")
                            .foregroundColor(.secondary)
                            .font(.body)
                    }
                }
            }
            .padding(.horizontal) // Ensure consistent horizontal padding
        }
        .background(Color(.systemGroupedBackground).edgesIgnoringSafeArea(.all))
        .navigationTitle("Ticket Details")
    }
}

struct DetailSection<Content: View>: View {
    let title: String
    let icon: String
    let content: Content

    init(title: String, icon: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.icon = icon
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // Section Header
            HStack {
                Image(systemName: icon)
                    .foregroundColor(.blue)
                Text(title)
                    .font(.headline)
                    .foregroundColor(.primary)
            }
            .padding(.bottom, 5)

            // Section Content
            VStack(alignment: .leading, spacing: 8) {
                content
            }
            .padding()
            .frame(maxWidth: .infinity) // Ensure sections align consistently
            .background(RoundedRectangle(cornerRadius: 10)
                .fill(Color(.secondarySystemBackground))
                .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2))
        }
    }
}

struct DetailRow: View {
    let label: String
    let value: String
    var color: Color = .primary

    var body: some View {
        HStack {
            Text(label + ":")
                .font(.subheadline)
                .foregroundColor(.gray)
            Spacer()
            Text(value)
                .font(.body)
                .foregroundColor(color)
        }
        .padding(.vertical, 4)
    }
}
