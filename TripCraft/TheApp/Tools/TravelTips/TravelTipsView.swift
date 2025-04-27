//
//  TravelTipsView.swift
//  TripCraft
//
//  Created by Siddharth Sehgal on 03/03/2025.
//

import SwiftUI

struct TravelTipsView: View {
    @State private var selectedCategory: TipCategory?
    @State private var searchText = ""
    
    private let tipsService = TravelTipsService.shared
    
    var filteredTips: [TravelTip] {
        if searchText.isEmpty {
            return selectedCategory.map { tipsService.getTipsByCategory($0) } ?? tipsService.tips
        }
        return tipsService.tips.filter { tip in
            tip.title.localizedCaseInsensitiveContains(searchText) ||
            tip.description.localizedCaseInsensitiveContains(searchText)
        }
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Categories ScrollView
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(TipCategory.allCases, id: \.self) { category in
                            CategoryButton(
                                category: category,
                                isSelected: category == selectedCategory,
                                action: { toggleCategory(category) }
                            )
                        }
                    }
                    .padding(.horizontal)
                }
                
                // Tips List
                LazyVStack(spacing: 16) {
                    ForEach(filteredTips) { tip in
                        TipCard(tip: tip)
                    }
                }
                .padding(.horizontal)
            }
        }
        .navigationTitle("Travel Tips")
        .searchable(text: $searchText, prompt: "Search tips")
    }
    
    private func toggleCategory(_ category: TipCategory) {
        if selectedCategory == category {
            selectedCategory = nil
        } else {
            selectedCategory = category
        }
    }
}

struct CategoryButton: View {
    let category: TipCategory
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: category.icon)
                Text(category.rawValue)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(isSelected ? Color.blue : Color(.systemGray6))
            .foregroundColor(isSelected ? .white : .primary)
            .cornerRadius(20)
        }
    }
}

struct TipCard: View {
    let tip: TravelTip
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: tip.icon)
                    .foregroundColor(.blue)
                    .font(.title3)
                
                Text(tip.title)
                    .font(.headline)
            }
            
            Text(tip.description)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            HStack {
                Image(systemName: tip.category.icon)
                    .foregroundColor(.blue)
                Text(tip.category.rawValue)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}
