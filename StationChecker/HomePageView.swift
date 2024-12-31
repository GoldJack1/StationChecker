import SwiftUI

struct HomePageView: View {
    @State private var searchQuery: String = ""
    @State private var selectedDate: Date = Date()
    @State private var selectedTime: Date = Date()
    @State private var showTrainResults: Bool = false
    @State private var stationCode: String?

    @State private var showDatePicker: Bool = false
    @State private var showTimePicker: Bool = false
    @State private var filteredSuggestions: [Station] = []

    var body: some View {
        NavigationStack {
            ZStack {
                // Background color
                Color(.systemBackground)
                    .edgesIgnoringSafeArea(.all)

                VStack(spacing: 20) {
                    // Map Button
                    mapButtonSection

                    // StnTr Button
                    stnTrButton

                    // Search Section
                    searchSection

                    // Date and Time Selection
                    dateTimeSelectionSection

                    Spacer()
                }
                .padding(.horizontal)
            }
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarLeading) {
                    Text("Home")
                        .font(.title3)
                        .foregroundColor(.primary)
                }
            }
            .toolbarBackground(.visible, for: .navigationBar)
            .navigationBarBackButtonHidden(true)
            .navigationBarTitleDisplayMode(.inline)
            .navigationDestination(isPresented: $showTrainResults) {
                if let stationCode = stationCode {
                    TrainDeparturesResultView(stationCode: stationCode, selectedDate: combinedDateTime())
                } else {
                    Text("Invalid CRS Code or Station Name")
                }
            }
            .sheet(isPresented: $showDatePicker) {
                DatePickerPopup(selectedDate: $selectedDate)
            }
            .sheet(isPresented: $showTimePicker) {
                TimePickerPopup(selectedTime: $selectedTime)
            }
        }
    }

    // Map Button Section
    var mapButtonSection: some View {
        VStack(spacing: 15) {
            NavigationLink(destination: Map()) {
                Text("View Map")
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity, minHeight: 50)
                    .background(Color.yellow)
                    .foregroundColor(.black)
                    .cornerRadius(10)
                    .shadow(radius: 3)
            }
        }
    }

    // StnTr Button Section
    var stnTrButton: some View {
        VStack(spacing: 15) {
            NavigationLink(destination: StationTrackerView()) {
                Text("Station Tracker")
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity, minHeight: 50)
                    .background(Color.yellow)
                    .foregroundColor(.black)
                    .cornerRadius(10)
                    .shadow(radius: 3)
            }
        }
    }

    // Search Section
    var searchSection: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Search for Train Times")
                .font(.headline)
                .foregroundColor(.primary)

            ZStack {
                VStack(spacing: 0) {
                    HStack {
                        TextField("Enter CRS code or station name", text: $searchQuery)
                            .padding(10)
                            .background(Color(UIColor.secondarySystemBackground))
                            .cornerRadius(8)
                            .shadow(radius: 2)
                            .autocorrectionDisabled(true)
                            .onChange(of: searchQuery, initial: false) { _, newQuery in
                                updateFilteredSuggestions(for: newQuery)
                            }

                        Button(action: {
                            if let code = getStationCRSCode(for: searchQuery) {
                                stationCode = code
                                showTrainResults = true
                            } else {
                                stationCode = nil
                                print("Invalid CRS code or station name")
                            }
                        }) {
                            Image(systemName: "magnifyingglass")
                                .foregroundColor(.white)
                                .padding(10)
                                .background(Color.blue)
                                .cornerRadius(8)
                        }
                    }
                    .padding(.bottom, filteredSuggestions.isEmpty ? 0 : 5)

                    // Suggestions Dropdown
                    if !filteredSuggestions.isEmpty {
                        ScrollView {
                            VStack(spacing: 0) {
                                ForEach(filteredSuggestions, id: \.crsCode) { suggestion in
                                    Button(action: {
                                        searchQuery = suggestion.stationName
                                        stationCode = suggestion.crsCode
                                        filteredSuggestions = []
                                    }) {
                                        HStack {
                                            Text(suggestion.stationName)
                                                .foregroundColor(.primary)
                                                .padding(.vertical, 10)
                                            Spacer()
                                            Text(suggestion.crsCode)
                                                .foregroundColor(.secondary)
                                                .font(.subheadline)
                                        }
                                        .padding(.horizontal)
                                    }
                                    Divider()
                                }
                            }
                        }
                        .background(Color(UIColor.secondarySystemBackground))
                        .cornerRadius(8)
                        .shadow(radius: 2)
                        .frame(maxHeight: 150) // Limit suggestions height
                    }
                }
            }
        }
    }

    // Date and Time Selection Section
    var dateTimeSelectionSection: some View {
        VStack(alignment: .leading, spacing: 20) {
            Button(action: {
                showDatePicker = true
            }) {
                HStack {
                    Text("Date: \(formattedDate(selectedDate))")
                        .foregroundColor(.primary)
                    Spacer()
                    Image(systemName: "calendar")
                        .foregroundColor(.blue)
                }
                .padding()
                .background(Color(UIColor.secondarySystemBackground))
                .cornerRadius(10)
                .shadow(radius: 3)
            }

            Button(action: {
                showTimePicker = true
            }) {
                HStack {
                    Text("Time: \(formattedTime(selectedTime))")
                        .foregroundColor(.primary)
                    Spacer()
                    Image(systemName: "clock")
                        .foregroundColor(.blue)
                }
                .padding()
                .background(Color(UIColor.secondarySystemBackground))
                .cornerRadius(10)
                .shadow(radius: 3)
            }
        }
    }

    // Update Suggestions
    func updateFilteredSuggestions(for query: String) {
        if query.isEmpty {
            filteredSuggestions = []
        } else {
            filteredSuggestions = stations.filter { $0.stationName.lowercased().contains(query.lowercased()) }
        }
    }

    // Get CRS Code
    func getStationCRSCode(for input: String) -> String? {
        let uppercasedInput = input.uppercased()

        if validateCRSCode(uppercasedInput) {
            return uppercasedInput
        }

        if let match = stations.first(where: { $0.stationName.lowercased() == input.lowercased() }) {
            return match.crsCode
        }

        return nil
    }

    // Validate CRS Code
    func validateCRSCode(_ input: String) -> Bool {
        let crsRegex = "^[A-Z]{3}$"
        return NSPredicate(format: "SELF MATCHES %@", crsRegex).evaluate(with: input)
    }

    // Format Date
    func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }

    // Format Time
    func formattedTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }

    // Combine Date and Time
    func combinedDateTime() -> Date {
        let calendar = Calendar.current
        let dateComponents = calendar.dateComponents([.year, .month, .day], from: selectedDate)
        let timeComponents = calendar.dateComponents([.hour, .minute], from: selectedTime)

        var combinedComponents = DateComponents()
        combinedComponents.year = dateComponents.year
        combinedComponents.month = dateComponents.month
        combinedComponents.day = dateComponents.day
        combinedComponents.hour = timeComponents.hour
        combinedComponents.minute = timeComponents.minute

        return calendar.date(from: combinedComponents) ?? Date()
    }
}
