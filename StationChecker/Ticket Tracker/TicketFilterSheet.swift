//
//  TicketFilterSheet.swift
//  StationChecker
//
//  Created by Jack Wingate on 07/01/2025.
//


import SwiftUI

struct TicketFilterSheet: View {
    @Environment(\.presentationMode) var presentationMode

    @Binding var selectedCountry: String?
    @Binding var selectedCounty: String?
    @Binding var selectedTOC: String?
    @Binding var showOnlyVisited: Bool
    @Binding var showOnlyNotVisited: Bool
    @Binding var showOnlyFavorites: Bool

    let countries: [String]
    let counties: [String]
    let tocs: [String]

    var onApply: () -> Void

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Filter by Country")) {
                    Picker("Country", selection: $selectedCountry) {
                        Text("All").tag(String?.none)
                        ForEach(countries, id: \.self) {
                            Text($0)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                }

                Section(header: Text("Filter by County")) {
                    Picker("County", selection: $selectedCounty) {
                        Text("All").tag(String?.none)
                        ForEach(counties, id: \.self) {
                            Text($0)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                }

                Section(header: Text("Filter by TOC")) {
                    Picker("TOC", selection: $selectedTOC) {
                        Text("All").tag(String?.none)
                        ForEach(tocs, id: \.self) {
                            Text($0)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                }

                Section {
                    Toggle("Show Only Visited", isOn: $showOnlyVisited)
                    Toggle("Show Only Not Visited", isOn: $showOnlyNotVisited)
                    Toggle("Show Only Favorites", isOn: $showOnlyFavorites)
                }

                Button("Apply Filters") {
                    onApply()
                    presentationMode.wrappedValue.dismiss()
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(8)
            }
            .navigationTitle("Filters")
            .navigationBarItems(trailing: Button("Cancel") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
}