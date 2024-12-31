import SwiftUI

struct FilterSheet: View {
    let countries: [String]
    let counties: [String]
    let tocs: [String]

    @Binding var selectedCountry: String?
    @Binding var selectedCounty: String?
    @Binding var selectedTOC: String?
    @Binding var showOnlyVisited: Bool
    @Binding var showOnlyNotVisited: Bool
    @Binding var showOnlyFavorites: Bool

    var onApply: () -> Void

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Country")) {
                    Picker("Select Country", selection: $selectedCountry) {
                        Text("All").tag(String?.none)
                        ForEach(countries, id: \.self) { country in
                            Text(country).tag(String?.some(country))
                        }
                    }
                }

                Section(header: Text("County")) {
                    Picker("Select County", selection: $selectedCounty) {
                        Text("All").tag(String?.none)
                        ForEach(counties, id: \.self) { county in
                            Text(county).tag(String?.some(county))
                        }
                    }
                }

                Section(header: Text("TOC")) {
                    Picker("Select TOC", selection: $selectedTOC) {
                        Text("All").tag(String?.none)
                        ForEach(tocs, id: \.self) { toc in
                            Text(toc).tag(String?.some(toc))
                        }
                    }
                }

                Section {
                    Toggle("Show Only Visited", isOn: $showOnlyVisited)
                    Toggle("Show Only Not Visited", isOn: $showOnlyNotVisited)
                    Toggle("Show Only Favorites", isOn: $showOnlyFavorites)
                }
            }
            .navigationTitle("Filters")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Apply") {
                        onApply()
                        dismiss()
                    }
                }
            }
        }
    }
}
