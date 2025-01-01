import SwiftUI

struct DataOptionsSheet: View {
    var onImport: (StationDataType) -> Void
    var onExport: (StationDataType) -> Void
    var onClearData: () -> Void
    var onAddStation: () -> Void
    @Environment(\.presentationMode) var presentationMode

    @State private var showDataTypeSheet: Bool = false
    @State private var actionType: DataAction? = nil

    // Navigation State
    @State private var navigateToStationTracker = false
    @State private var navigateToMetrolinkTracker = false

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Data Options").font(.headline)) {
                    Button(action: {
                        actionType = .import
                        showDataTypeSheet = true
                    }) {
                        Label("Import Data", systemImage: "tray.and.arrow.down")
                            .foregroundColor(.blue)
                    }

                    Button(action: {
                        actionType = .export
                        showDataTypeSheet = true
                    }) {
                        Label("Export Data", systemImage: "tray.and.arrow.up")
                            .foregroundColor(.green)
                    }

                    Button(action: {
                        onClearData()
                        dismissSheet()
                    }) {
                        Label("Clear All Data", systemImage: "trash")
                            .foregroundColor(.red)
                    }

                    Button("Add Station") {
                        onAddStation()
                    }
                    .padding()

                    // Navigation Buttons
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            navigateToStationTracker = true
                        }
                    }) {
                        Label("Go to General Stations", systemImage: "list.bullet")
                    }

                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            navigateToMetrolinkTracker = true
                        }
                    }) {
                        Label("Go to Metrolink Tracker", systemImage: "tram")
                    }
                }
            }
            .navigationTitle("Data Options")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showDataTypeSheet) {
                DataTypeSelectionSheet(
                    onSelection: { dataType in
                        dismissSheetsAndPerform {
                            if actionType == .import {
                                onImport(dataType)
                            } else if actionType == .export {
                                onExport(dataType)
                            }
                        }
                    }
                )
            }
            .background(
                NavigationLink("", destination: StationTrackerView(), isActive: $navigateToStationTracker)
                    .hidden()
            )
            .background(
                NavigationLink("", destination: MetrolinkTrackerView(), isActive: $navigateToMetrolinkTracker)
                    .hidden()
            )
        }
    }

    // MARK: - Helper Methods
    private func dismissSheet() {
        presentationMode.wrappedValue.dismiss()
    }

    private func dismissSheetsAndPerform(action: @escaping () -> Void) {
        presentationMode.wrappedValue.dismiss()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            action()
        }
    }
}
