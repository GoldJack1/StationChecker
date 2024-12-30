import SwiftUI

struct DataOptionsSheet: View {
    var onImport: () -> Void
    var onExport: () -> Void
    var onClearData: () -> Void
    var onAddStation: () -> Void

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Data Options").font(.headline)) {
                    Button(action: onImport) {
                        Label("Import Data", systemImage: "tray.and.arrow.down")
                            .foregroundColor(.blue)
                    }

                    Button(action: onExport) {
                        Label("Export Data", systemImage: "tray.and.arrow.up")
                            .foregroundColor(.green)
                    }

                    Button(action: onClearData) {
                        Label("Clear All Data", systemImage: "trash")
                            .foregroundColor(.red)
                    }

                    Button(action: onAddStation) {
                        Label("Add Station", systemImage: "plus.circle")
                            .foregroundColor(.orange)
                    }
                }
            }
            .navigationTitle("Data Options")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
