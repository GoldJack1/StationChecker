import SwiftUI

struct UKNatRailDetailView: View {
    @Environment(\.presentationMode) var presentationMode
    @Binding var station: UKNatRailRecord // Binding to update station in the parent view
    var onUpdate: (UKNatRailRecord) -> Void

    @State private var isEditing: Bool = false

    var body: some View {
        VStack(spacing: 0) {
            // Custom Header
            HStack {
                // Back Button
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Image(systemName: "chevron.left")
                        .font(.title3)
                        .padding(10)
                        .background(Circle().fill(Color(.systemGray5)))
                        .foregroundColor(.primary)
                }
                
                Spacer()
                
                // Page Title
                Text("Station Details")
                    .font(.title)
                    .bold()
                    .foregroundColor(.primary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                Spacer()
                
                // Edit Button
                Button(action: toggleEditing) {
                    Image(systemName: isEditing ? "checkmark" : "pencil")
                        .font(.title3)
                        .padding(10)
                        .background(Circle().fill(Color(.systemGray5)))
                        .foregroundColor(.primary)
                }
            }
            .padding(.horizontal)
            .padding(.top, 10)
            .padding(.bottom, 10)
            .background(Color(.systemGray6))
            .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
            
            // Scrollable Content
            ScrollView {
                VStack(spacing: 16) {
                    // UKNatRail Info Section
                    Section {
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Image(systemName: "train.side.front.car")
                                    .foregroundColor(.blue)
                                    .font(.system(size: 32, weight: .bold))
                                if isEditing {
                                    styledTextField("UKNatRail Name", text: $station.stationName)
                                        .font(.title)
                                        .fontWeight(.semibold)
                                } else {
                                    Text(station.stationName)
                                        .font(.title)
                                        .fontWeight(.semibold)
                                }
                            }
                            
                            Divider()
                            
                            infoRow(icon: "flag", label: "Country", text: $station.country)
                            infoRow(icon: "map", label: "County", text: $station.county)
                            infoRow(icon: "building.2", label: "Operator", text: $station.toc)
                        }
                        .padding()
                    }
                    .frame(maxWidth: .infinity) // Adaptive for iPads
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    .shadow(color: .gray.opacity(0.2), radius: 4, x: 0, y: 2)
                    
                    // Coordinates Section
                    Section {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Coordinates")
                                .font(.headline)
                                .foregroundColor(.blue)
                            
                            fullWidthCoordinateRow(icon: "mappin.and.ellipse", label: "Latitude", value: $station.latitude)
                            fullWidthCoordinateRow(icon: "location.north.line", label: "Longitude", value: $station.longitude)
                        }
                        .padding()
                    }
                    .frame(maxWidth: .infinity) // Adaptive for iPads
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    .shadow(color: .gray.opacity(0.2), radius: 4, x: 0, y: 2)
                    
                    // Visit Status Section
                    Section {
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Text("Visited Status")
                                    .font(.headline)
                                    .foregroundColor(.blue)
                                Spacer()
                                Button(action: toggleFavorite) {
                                    Image(systemName: station.isFavorite ? "star.fill" : "star")
                                        .foregroundColor(.yellow)
                                        .font(.system(size: 24))
                                }
                            }
                            
                            Toggle(isOn: $station.visited) {
                                Text("Visited")
                                    .font(.body)
                            }
                            .onChange(of: station.visited) {
                                if !station.visited {
                                    station.visitDate = nil
                                }
                            }
                            if station.visited {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Visit Date")
                                        .font(.headline)
                                        .foregroundColor(.blue)
                                    HStack {
                                        Image(systemName: "calendar")
                                            .foregroundColor(.blue)
                                        DatePicker(
                                            "",
                                            selection: Binding<Date>(
                                                get: { station.visitDate ?? Date() },
                                                set: { station.visitDate = $0 }
                                            ),
                                            displayedComponents: [.date]
                                        )
                                        .labelsHidden()
                                    }
                                }
                            }
                        }
                        .padding()
                    }
                    .frame(maxWidth: .infinity) // Adaptive for iPads
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    .shadow(color: .gray.opacity(0.2), radius: 4, x: 0, y: 2)
                    
                    // Usage Data Section
                    if !station.usageData.isEmpty {
                        Section {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Usage Data")
                                    .font(.headline)
                                    .foregroundColor(.blue)
                                
                                ForEach(station.usageData.keys.sorted(by: >), id: \.self) { year in
                                    HStack {
                                        Text("\(year):")
                                            .font(.body)
                                            .fontWeight(.bold)
                                            .foregroundColor(.blue)
                                        Spacer()
                                        if isEditing {
                                            styledTextField(
                                                "Usage",
                                                text: Binding<String>(
                                                    get: { station.usageData[year] ?? "N/A" },
                                                    set: { station.usageData[year] = $0 }
                                                )
                                            )
                                            .font(.body)
                                            .multilineTextAlignment(.leading)
                                        } else {
                                            Text(station.usageData[year] ?? "N/A")
                                                .font(.body)
                                                .foregroundColor(.primary)
                                                .multilineTextAlignment(.leading) // Ensure left alignment
                                        }
                                    }
                                    .padding(.vertical, 2)
                                }
                            }
                            .padding()
                        }
                        .frame(maxWidth: .infinity) // Adaptive for iPads
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                        .shadow(color: .gray.opacity(0.2), radius: 4, x: 0, y: 2)
                    }
                }
                .padding()
            }
        }
        .onDisappear {
            onUpdate(station)
        }
        .toolbar(.hidden, for: .navigationBar) // Hide the default navigation bar
        .toolbar(.hidden)
    }

    private func toggleFavorite() {
        station.isFavorite.toggle()
        onUpdate(station) // Ensure favorite status is saved
    }

    private func toggleEditing() {
        isEditing.toggle()
        if !isEditing {
            onUpdate(station) // Save all changes when exiting edit mode
        }
    }

    // Helper for Information Rows
    private func infoRow(icon: String, label: String, text: Binding<String>) -> some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.secondary)
                .font(.system(size: 20))
            VStack(alignment: .leading, spacing: 4) {
                Text(label)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                if isEditing {
                    styledTextField(label, text: text)
                        .font(.body)
                } else {
                    Text(text.wrappedValue)
                        .font(.body)
                        .foregroundColor(.primary)
                }
            }
        }
    }

    // Helper for Full-Width Coordinate Rows
    private func fullWidthCoordinateRow(icon: String, label: String, value: Binding<Double>) -> some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.red)
                .font(.system(size: 20))
            VStack(alignment: .leading, spacing: 4) {
                Text(label)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                if isEditing {
                    styledTextField(label, value: value)
                        .font(.body)
                } else {
                    Text("\(value.wrappedValue, specifier: "%.6f")")
                        .font(.body)
                        .foregroundColor(.primary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
        }
        .frame(maxWidth: .infinity) // Ensures full-width alignment
    }

    // Custom Text Field with Shading
    private func styledTextField(_ placeholder: String, text: Binding<String>) -> some View {
        TextField(placeholder, text: text)
            .padding(8)
            .background(isEditing ? Color(.systemGray5) : Color(.systemGray6))
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(isEditing ? Color.blue : Color(.systemGray4), lineWidth: 1)
            )
    }

    private func styledTextField(_ placeholder: String, value: Binding<Double>) -> some View {
        TextField(placeholder, value: value, format: .number)
            .padding(8)
            .background(isEditing ? Color(.systemGray5) : Color(.systemGray6))
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(isEditing ? Color.blue : Color(.systemGray4), lineWidth: 1)
            )
            .keyboardType(.decimalPad)
    }
}
