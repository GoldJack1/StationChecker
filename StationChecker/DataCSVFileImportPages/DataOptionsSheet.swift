import SwiftUI

struct DataOptionsSheet: View {
    var onImport: (DataType) -> Void
    var onExport: (DataType) -> Void
    var onClearData: () -> Void
    var onAddStation: () -> Void
    @Environment(\.presentationMode) var presentationMode

    @State private var showDataTypeSheet: Bool = false
    @State private var actionType: DataAction? = nil

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
                        onClearData() // Trigger the onClearData closure
                        dismissSheet() // Dismiss the DataOptionsSheet after clearing data
                    }) {
                        Label("Clear All Data", systemImage: "trash")
                            .foregroundColor(.red)
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
        }
    }

    // Dismiss the DataOptionsSheet
    private func dismissSheet() {
        presentationMode.wrappedValue.dismiss()
    }

    private func dismissSheetsAndPerform(action: @escaping () -> Void) {
        // Dismiss DataOptionsSheet and perform the action
        presentationMode.wrappedValue.dismiss()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            action()
        }
    }
}
