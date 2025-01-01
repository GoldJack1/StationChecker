//
//  SelectDataTypeView.swift
//  StationChecker
//
//  Created by Jack Wingate on 01/01/2025.
//


import SwiftUI

struct SelectDataTypeView: View {
    var actionTitle: String // "Import" or "Export"
    var onSelect: (StationDataType) -> Void // Callback for the selected data type
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        NavigationView {
            List {
                ForEach(StationDataType.allCases) { dataType in
                    Button(action: {
                        onSelect(dataType)
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Text(dataType.displayName)
                    }
                }
            }
            .navigationTitle("\(actionTitle) Data")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}