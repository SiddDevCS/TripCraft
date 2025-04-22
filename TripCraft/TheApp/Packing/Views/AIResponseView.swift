//
//  AIResponseView.swift
//  TripCraft
//
//  Created by Siddharth Sehgal on 06/03/2025.
//

import SwiftUI

struct AIResponseView: View {
    @ObservedObject var viewModel: PackingListViewModel
    let aiSuggestions: [PackingItem]
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        List {
            ForEach(PackingCategory.allCases, id: \.self) { category in
                let items = aiSuggestions.filter { $0.category == category.rawValue }
                if !items.isEmpty {
                    Section(header: Text(category.rawValue)) {
                        ForEach(items) { item in
                            Text(item.name)
                        }
                    }
                }
            }
        }
        .navigationTitle("AI Suggestions")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Add All") {
                    viewModel.addAISuggestions(aiSuggestions)
                    dismiss()
                }
            }
        }
    }
}
