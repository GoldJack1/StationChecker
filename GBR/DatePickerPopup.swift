import SwiftUI

struct DatePickerPopup: View {
    @Binding var selectedDate: Date
    @Environment(\.dismiss) private var dismiss // Environment property to dismiss the view

    var body: some View {
        NavigationView {
            VStack {
                DatePicker("Select a Date", selection: $selectedDate, displayedComponents: [.date])
                    .datePickerStyle(GraphicalDatePickerStyle())
                    .padding()

                Button("Done") {
                    dismiss() // Dismiss the sheet when Done is tapped
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
                .padding()
            }
            .navigationTitle("Select Date")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss() // Dismiss the sheet when Cancel is tapped
                    }
                }
            }
        }
    }
}
