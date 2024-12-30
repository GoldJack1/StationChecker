import SwiftUI

struct StationDetailView: View {
    @State var station: StationRecord
    var onUpdate: (StationRecord) -> Void

    @State private var isEditing: Bool = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Section: General Information
                SectionView(title: "General Information") {
                    VStack(alignment: .leading, spacing: 12) {
                        EditableField(label: "Station Name", text: $station.stationName, isEditing: isEditing)
                        EditableField(label: "Country", text: $station.country, isEditing: isEditing)
                        EditableField(label: "County", text: $station.county, isEditing: isEditing)
                        EditableField(label: "Operator (TOC)", text: $station.toc, isEditing: isEditing)
                    }
                }

                // Section: Visit Information
                SectionView(title: "Visit Information") {
                    VStack(alignment: .leading, spacing: 12) {
                        // Toggle Button for Visited Status
                        HStack {
                            Label("Visited", systemImage: "checkmark.circle.fill")
                                .foregroundColor(station.visited ? .green : .red)
                            Spacer()
                            Button(action: {
                                station.visited.toggle()
                                if station.visited {
                                    station.visitDate = station.visitDate ?? Date()
                                } else {
                                    station.visitDate = nil
                                }
                                onUpdate(station)
                            }) {
                                Text(station.visited ? "Mark as Not Visited" : "Mark as Visited")
                                    .fontWeight(.bold)
                                    .padding()
                                    .background(station.visited ? Color.red.opacity(0.2) : Color.green.opacity(0.2))
                                    .foregroundColor(station.visited ? .red : .green)
                                    .clipShape(Capsule())
                            }
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(10)

                        // Display Date Visited (if applicable)
                        if station.visited {
                            HStack {
                                Label("Date Visited", systemImage: "calendar")
                                Spacer()
                                if isEditing {
                                    DatePicker(
                                        "",
                                        selection: Binding($station.visitDate, replacingNilWith: Date()),
                                        displayedComponents: .date
                                    )
                                    .labelsHidden()
                                } else {
                                    Text(station.visitDate ?? Date(), formatter: dateFormatter)
                                        .foregroundColor(.primary)
                                }
                            }
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(10)
                        }
                    }
                }

                // Section: Usage Data
                SectionView(title: "Usage Data (2023 → 1997)") {
                    VStack(alignment: .leading, spacing: 12) {
                        ForEach(station.usageData.keys.sorted(by: >), id: \.self) { key in
                            HStack {
                                Text("\(key):")
                                    .fontWeight(.semibold)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                Spacer()
                                Text(station.usageData[key] ?? "N/A")
                                    .frame(maxWidth: .infinity, alignment: .trailing)
                            }
                            .padding(8)
                            .background(Color(.systemGray6))
                            .cornerRadius(10)
                        }
                    }
                }

                // Favorite Toggle
                SectionView(title: "Settings") {
                    Toggle(isOn: $station.isFavorite) {
                        Label("Mark as Favorite", systemImage: "star.fill")
                            .foregroundColor(.yellow)
                    }
                    .toggleStyle(SwitchToggleStyle(tint: .yellow))
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 24)
        }
        .background(Color(.systemGroupedBackground).edgesIgnoringSafeArea(.all))
        .navigationTitle(isEditing ? "Edit Station" : station.stationName)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    if isEditing {
                        onUpdate(station) // Save changes
                    }
                    isEditing.toggle()
                }) {
                    Image(systemName: isEditing ? "checkmark" : "pencil")
                        .font(.title2)
                        .foregroundColor(isEditing ? .green : .blue)
                }
            }
        }
    }

    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }
}

// MARK: - EditableField Component
struct EditableField: View {
    let label: String
    @Binding var text: String
    var isEditing: Bool

    var body: some View {
        HStack {
            HStack {
                Image(systemName: iconForLabel(label))
                Text(label)
            }
            .fontWeight(.semibold)
            .frame(maxWidth: .infinity, alignment: .leading)

            if isEditing {
                TextField(label, text: $text)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .frame(maxWidth: .infinity)
            } else {
                Text(text)
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .foregroundColor(.primary)
            }
        }
        .padding(8)
        .background(isEditing ? Color(.systemGray6) : Color.clear)
        .cornerRadius(10)
    }

    private func iconForLabel(_ label: String) -> String {
        switch label {
        case "Station Name": return "building.2.fill"
        case "Country": return "globe.europe.africa.fill"
        case "County": return "map.fill"
        case "Operator (TOC)": return "train.side.front.car.fill"
        default: return "info.circle.fill"
        }
    }
}

// MARK: - SectionView Component
struct SectionView<Content: View>: View {
    let title: String
    let content: Content

    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.headline)
                .padding(.bottom, 4)
            content
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
                .shadow(color: .gray.opacity(0.2), radius: 4, x: 0, y: 2)
        }
    }
}

// MARK: - Extensions for Binding
extension Binding {
    init(_ source: Binding<Value?>, replacingNilWith defaultValue: Value) {
        self.init(get: { source.wrappedValue ?? defaultValue },
                  set: { source.wrappedValue = $0 })
    }
}
