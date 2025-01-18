//
//  EditableField.swift
//  StationChecker
//
//  Created by Jack Wingate on 18/01/2025.
//
import SwiftUI

struct EditableField: View {
    let label: String
    @Binding var text: String

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(label)
                .font(.subheadline)
                .foregroundColor(.gray)
            TextField(label, text: $text)
                .padding(10)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.gray.opacity(0.1))
                )
                .font(.body)
        }
        .padding(.vertical, 5)
    }
}
