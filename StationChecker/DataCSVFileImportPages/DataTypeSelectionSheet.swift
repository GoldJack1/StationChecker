import SwiftUI

struct DataTypeSelectionSheet: View {
    var onSelection: (DataType) -> Void
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        NavigationView {
            List {
                ForEach(DataType.allCases) { dataType in
                    Button(action: {
                        dismissAndPerform {
                            onSelection(dataType)
                        }
                    }) {
                        Text(dataType.displayName)
                            .font(.headline)
                    }
                }
            }
            .navigationTitle("Select Data Type")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    private func dismissAndPerform(action: @escaping () -> Void) {
        presentationMode.wrappedValue.dismiss() // Dismiss DataTypeSelectionSheet
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            action()
        }
    }
}
