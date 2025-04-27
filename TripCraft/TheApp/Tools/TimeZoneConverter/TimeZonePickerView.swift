//
//  TimeZonePickerView.swift
//  TripCraft
//
//  Created by Siddharth Sehgal on 08/03/2025.
//

import SwiftUI

struct TimeZonePickerView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var selection: TimeZone
    let timeZones: [TimeZone]
    let formatTimeZone: (TimeZone) -> String
    @State private var searchText = ""
    
    var filteredTimeZones: [TimeZone] {
        if searchText.isEmpty {
            return timeZones
        }
        return timeZones.filter {
            formatTimeZone($0).localizedCaseInsensitiveContains(searchText)
        }
    }
    
    var body: some View {
        NavigationView {
            List(filteredTimeZones, id: \.identifier) { timeZone in
                Button {
                    selection = timeZone
                    dismiss()
                } label: {
                    HStack {
                        Text(formatTimeZone(timeZone))
                        Spacer()
                        if timeZone == selection {
                            Image(systemName: "checkmark")
                                .foregroundColor(.blue)
                        }
                    }
                }
            }
            .navigationTitle("Select Time Zone")
            .navigationBarTitleDisplayMode(.inline)
            .searchable(text: $searchText, prompt: "Search time zones")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}
