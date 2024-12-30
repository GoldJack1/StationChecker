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
                        
                        if let visitDate = station.visitDate {
                            if isEditing {
                                // Editable visit date
                                DatePicker("Visit Date", selection: Binding($station.visitDate)!, displayedComponents: .date)
                                    .datePickerStyle(CompactDatePickerStyle())
                            } else {
                                // Display visit date in view mode
                                HStack {
                                    Text("Visit Date:")
                                        .fontWeight(.bold)
                                    Spacer()
                                    Text(visitDate, style: .date)
                                        .foregroundColor(.gray)
                                }
                            }
                        }
                    }
                }
                
                // Section: Usage Data
                SectionView(title: "Usage Data (1997–2024)") {
                    VStack(alignment: .leading, spacing: 8) {
                        // Ensure all years from 1997 to 2024 are included
                        let allYears = (1997...2024).map { String($0) }
                        ForEach(allYears.sorted(by: >), id: \.self) { year in
                            HStack {
                                Text(year)
                                    .fontWeight(.bold)
                                Spacer()
                                Text(station.usageData[year] ?? "N/A") // Show "N/A" if data is missing
                                    .foregroundColor(.gray)
                            }
                        }
                    }
                }
            }
            .padding()
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    isEditing.toggle()
                }) {
                    Text(isEditing ? "Done" : "Edit")
                }
            }
        }
    }
}

// EditableField and SectionView are assumed to be reusable components.
struct EditableField: View {
    let label: String
    @Binding var text: String
    var isEditing: Bool
    
    var body: some View {
        HStack {
            Text(label)
                .fontWeight(.bold)
            Spacer()
            if isEditing {
                TextField("Enter \(label)", text: $text)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
            } else {
                Text(text)
                    .foregroundColor(.gray)
            }
        }
    }
}

struct SectionView<Content: View>: View {
    let title: String
    let content: Content
    
    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(title)
                .font(.headline)
                .padding(.bottom, 8)
            content
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(10)
        }
        .padding(.vertical)
    }
}
