import SwiftUI

struct UKNatRailCard: View {
    @Binding var station: UKNatRailRecord // Pass the station as a binding
        var onUpdate: (UKNatRailRecord) -> Void // Call onUpdate to send changes back to UKNatRailTrackerView
    var onNavigate: () -> Void // Callback for navigation

    var body: some View {
        ZStack {
            NavigationLink(
                destination: UKNatRailDetailView(
                    station: $station, // Pass Binding to UKNatRailDetailView
                    onUpdate: { updatedUKNatRail in
                        onUpdate(updatedUKNatRail) // Send updated station back to parent
                    }
                )
            ) {
                EmptyView() // Invisible NavigationLink
            }
            .opacity(0) // Makes it invisible but still functional
            
            VStack(alignment: .leading, spacing: 12) { // Reduced spacing
                // UKNatRail Name
                HStack {
                    Text(station.stationName)
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                        .lineLimit(1)
                    if station.isFavorite {
                        Image(systemName: "star.fill")
                            .foregroundColor(.yellow)
                            .imageScale(.small)
                    }
                }

                // County Information
                Text(station.county)
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                HStack(spacing: 8) {
                    // Operator with Icon
                    Image(systemName: "train.side.front.car")
                        .foregroundColor(.blue)
                    Text(station.toc)
                        .font(.footnote)
                        .foregroundColor(.blue)

                    Spacer()

                    // Visited Status
                    Text(station.visited ? "Visited" : "Not Visited")
                        .font(.footnote)
                        .fontWeight(.semibold)
                        .foregroundColor(station.visited ? .green : .red)
                }

                // Visit Date
                if let visitDate = station.visitDate {
                    Text("Visited on \(dateFormatter.string(from: visitDate))")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                // Update Visit Status Button
                Button(action: toggleVisitStatus) {
                    HStack {
                        Image(systemName: "pencil.circle")
                            .font(.headline)
                        Text("Update Visit Status")
                            .font(.footnote)
                            .fontWeight(.bold)
                    }
                    .padding(6)
                    .background(Color.gray.opacity(0.2)) // Gray background
                    .foregroundColor(station.visited ? .green : .red) // Dynamic text color
                    .clipShape(Capsule())
                }
                .buttonStyle(PlainButtonStyle()) // Prevents NavigationLink from hijacking tap
                .padding(.top, 8)
            }
            .padding(12) // Reduced padding inside the card
            .background(
                Color(.systemBackground)
                    .cornerRadius(12) // Reduced corner radius
                    .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1) // Softer shadow
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(station.visited ? Color.green : Color.red, lineWidth: 1.5)
            )
        }
        .padding(.vertical, 6) // Reduced spacing between cards
    }

    // Helper to toggle the visited status
    private func toggleVisitStatus() {
        station.visited.toggle()
        if station.visited {
            station.visitDate = station.visitDate ?? Date() // Set current date if none exists
        } else {
            station.visitDate = nil // Clear visit date if unvisited
        }
        onUpdate(station) // Call the parent update callback
    }

    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }
}
