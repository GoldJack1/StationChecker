import SwiftUI

struct TimePickerPopup: View {
    @Binding var selectedTime: Date
    @Environment(\.dismiss) private var dismiss // Environment property to dismiss the view

    var body: some View {
        NavigationView {
            VStack {
                DatePicker("Select a Time", selection: $selectedTime, displayedComponents: [.hourAndMinute])
                    .datePickerStyle(WheelDatePickerStyle())
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
            .navigationTitle("Select Time")
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
