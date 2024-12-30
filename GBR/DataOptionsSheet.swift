struct DataOptionsSheet: View {
    let onImport: () -> Void
    let onExport: () -> Void
    let onClearData: () -> Void

    var body: some View {
        NavigationView {
            List {
                Button(action: onImport) {
                    Label("Import Data", systemImage: "tray.and.arrow.down")
                }
                .foregroundColor(.blue)

                Button(action: onExport) {
                    Label("Export Data", systemImage: "square.and.arrow.up")
                }
                .foregroundColor(.green)

                Button(action: onClearData) {
                    Label("Clear All Data", systemImage: "trash")
                }
                .foregroundColor(.red)
            }
            .navigationTitle("Data Options")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") {
                        UIApplication.shared.windows.first?.rootViewController?.dismiss(animated: true)
                    }
                }
            }
        }
    }
}