import SwiftUI

struct HomePageView: View {
    @State private var searchQuery: String = ""
    @State private var selectedDate: Date = Date()
    @State private var selectedTime: Date = Date()
    @State private var showTrainResults: Bool = false
    @State private var showDatePicker: Bool = false
    @State private var showTimePicker: Bool = false
    @State private var stationCode: String?

    var body: some View {
        NavigationStack {
            ZStack {
                // Background color
                LinearGradient(gradient: Gradient(colors: [Color.yellow.opacity(0.3), Color.white]), startPoint: .top, endPoint: .bottom)
                    .edgesIgnoringSafeArea(.all)

                VStack(spacing: 20) {
                    Spacer()

                    // Search Box
                    VStack(alignment: .leading, spacing: 15) {
                        Text("Search for Train Times")
                            .font(.headline)
                            .foregroundColor(.black)

                        HStack {
                            TextField("Enter CRS code or station name", text: $searchQuery)
                                .autocorrectionDisabled(true)
                                .padding()
                                .background(Color.white)
                                .cornerRadius(10)
                                .shadow(radius: 3)

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
                                    .padding()
                                    .background(Color.blue)
                                    .cornerRadius(10)
                            }
                        }
                    }
                    .padding(.horizontal)

                    // Date and Time Buttons
                    VStack(alignment: .leading, spacing: 20) {
                        Button(action: {
                            showDatePicker = true // Open Date Picker
                        }) {
                            HStack {
                                Text("Date: \(formattedDate(selectedDate))")
                                    .foregroundColor(.black)
                                Spacer()
                                Image(systemName: "calendar")
                                    .foregroundColor(.blue)
                            }
                            .padding()
                            .background(Color.white)
                            .cornerRadius(10)
                            .shadow(radius: 3)
                        }

                        Button(action: {
                            showTimePicker = true // Open Time Picker
                        }) {
                            HStack {
                                Text("Time: \(formattedTime(selectedTime))")
                                    .foregroundColor(.black)
                                Spacer()
                                Image(systemName: "clock")
                                    .foregroundColor(.blue)
                            }
                            .padding()
                            .background(Color.white)
                            .cornerRadius(10)
                            .shadow(radius: 3)
                        }
                    }
                    .padding(.horizontal)

                    Spacer()

                    // Navigation Button
                    VStack(spacing: 15) {
                        NavigationLink(destination: Map()) {
                            Text("View Map")
                                .fontWeight(.semibold)
                                .frame(maxWidth: .infinity, minHeight: 50)
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                                .shadow(radius: 3)
                        }
                    }
                    .padding(.horizontal)
                }
            }
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarLeading) {
                    Text("Home")
                        .font(.title3)
                        .foregroundColor(.black)
                }
            }
            .toolbarBackground(Color.yellow, for: .navigationBar)
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

    func getStationCRSCode(for input: String) -> String? {
        let uppercasedInput = input.uppercased()

        // Check if input is already a valid CRS code
        if validateCRSCode(uppercasedInput) {
            return uppercasedInput
        }

        // Check if input matches a station name in the `stations` array
        if let match = stations.first(where: { $0.stationName.lowercased() == input.lowercased() }) {
            return match.crsCode
        }

        // If no match found, return nil
        return nil
    }

    func validateCRSCode(_ input: String) -> Bool {
        let crsRegex = "^[A-Z]{3}$"
        return NSPredicate(format: "SELF MATCHES %@", crsRegex).evaluate(with: input)
    }

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

    func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }

    func formattedTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}
