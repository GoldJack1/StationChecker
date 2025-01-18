//
//  DetailRow.swift
//  StationChecker
//
//  Created by Jack Wingate on 18/01/2025.
//
import SwiftUI

struct DetailRow: View {
    let label: String
    let value: String
    var color: Color = .primary

    var body: some View {
        HStack {
            Text(label + ":")
                .font(.subheadline)
                .foregroundColor(.gray)
            Spacer()
            Text(value)
                .font(.body)
                .foregroundColor(color)
        }
        .padding(.vertical, 4)
    }
}
