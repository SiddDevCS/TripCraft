//
//  ActivitySelectionView.swift
//  TripCraft
//
//  Created by Siddharth Sehgal on 09/03/2025.
//

import SwiftUI

struct ActivitySelectionView: View {
    @Binding var selectedActivities: Set<String>
    @Environment(\.dismiss) private var dismiss
    @State private var customActivity = ""
    
    private let commonActivities = [
        "Sightseeing",
        "Swimming",
        "Hiking",
        "Beach",
        "Business",
        "Skiing",
        "Shopping",
        "Photography",
        "Camping",
        "Dining Out"
    ]
    
    var body: some View {
        List {
            Section(header: Text("Add Custom Activity")) {
                HStack {
                    TextField("Enter custom activity", text: $customActivity)
                    
                    Button(action: {
                        if !customActivity.isEmpty {
                            selectedActivities.insert(customActivity)
                            customActivity = ""
                        }
                    }) {
                        Image(systemName: "plus.circle.fill")
                    }
                    .disabled(customActivity.isEmpty)
                }
            }
            
            Section(header: Text("Common Activities")) {
                ForEach(commonActivities, id: \.self) { activity in
                    Button(action: {
                        if selectedActivities.contains(activity) {
                            selectedActivities.remove(activity)
                        } else {
                            selectedActivities.insert(activity)
                        }
                    }) {
                        HStack {
                            Text(activity)
                            Spacer()
                            if selectedActivities.contains(activity) {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.blue)
                            }
                        }
                    }
                }
            }
            
            if !selectedActivities.isEmpty {
                Section(header: Text("Selected Activities")) {
                    ForEach(Array(selectedActivities), id: \.self) { activity in
                        HStack {
                            Text(activity)
                            Spacer()
                            Button(action: {
                                selectedActivities.remove(activity)
                            }) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.red)
                            }
                        }
                    }
                }
            }
        }
        .navigationTitle("Select Activities")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Done") { dismiss() }
            }
        }
    }
}
