import SwiftUI
import UniformTypeIdentifiers

struct DataOptionsSheet: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var showFilePicker: Bool = false
    @State private var selectedDataType: StationDataType? = nil
    var onImport: (StationDataType) -> Void
    var onExport: (StationDataType) -> Void
    var onClearData: () -> Void
    var onAddStation: () -> Void

    var body: some View {
        VStack {
            Text("Data Options")
                .font(.title)
                .padding()

            Divider()

            // Import Button
            Button(action: {
                dismissAndPerform {
                    selectedDataType = StationDataType.nationalRail
                }
            }) {
                HStack {
                    Image(systemName: "square.and.arrow.down")
                        .font(.title3)
                    Text("Import Data")
                        .font(.headline)
                }
            }
            .padding(.vertical, 10)

            // Export Button
            Button(action: {
                dismissAndPerform {
                    selectedDataType = StationDataType.nationalRail
                }
            }) {
                HStack {
                    Image(systemName: "square.and.arrow.up")
                        .font(.title3)
                    Text("Export Data")
                        .font(.headline)
                }
            }
            .padding(.vertical, 10)

            // Clear Data Button
            Button(action: {
                dismissAndPerform {
                    onClearData()
                }
            }) {
                HStack {
                    Image(systemName: "trash")
                        .font(.title3)
                    Text("Clear All Data")
                        .font(.headline)
                        .foregroundColor(.red)
                }
            }
            .padding(.vertical, 10)

            // Add Station Button
            Button(action: {
                dismissAndPerform {
                    onAddStation()
                }
            }) {
                HStack {
                    Image(systemName: "plus.circle")
                        .font(.title3)
                    Text("Add New Station")
                        .font(.headline)
                }
            }
            .padding(.vertical, 10)
        }
        .padding()
        .actionSheet(item: $selectedDataType) { dataType in
            ActionSheet(
                title: Text("Select Data Type"),
                buttons: [
                    .default(Text(dataType.displayName)) {
                        onImport(dataType)
                    },
                    .cancel()
                ]
            )
        }
        .fileImporter(
            isPresented: $showFilePicker,
            allowedContentTypes: [.commaSeparatedText],
            allowsMultipleSelection: false
        ) { result in
            handleFilePicker(result: result)
        }
    }

    // Helper Methods
    private func dismissAndPerform(action: @escaping () -> Void) {
        presentationMode.wrappedValue.dismiss()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            action()
        }
    }

    private func handleFilePicker(result: Result<[URL], Error>) {
        switch result {
        case .success(let urls):
            guard let fileURL = urls.first else { return }
            print("File selected: \(fileURL.lastPathComponent)")
        case .failure(let error):
            print("File picker error: \(error.localizedDescription)")
        }
    }
}
