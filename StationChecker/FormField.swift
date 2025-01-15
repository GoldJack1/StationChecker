//
//  FormField.swift
//  StationChecker
//
//  Created by Jack Wingate on 10/01/2025.
//


import SwiftUI

struct FormField: View {
    let label: String
    @Binding var text: String
    let icon: String

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(label)
                .font(.subheadline)
                .foregroundColor(.gray)
            HStack {
                Image(systemName: icon)
                    .foregroundColor(.blue)
                TextField(label, text: $text)
                    .padding(10)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color.gray.opacity(0.1))
                    )
            }
        }
    }
}