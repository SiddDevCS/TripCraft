//
//  TravelToolsView.swift
//  TripCraft
//
//  Created by Siddharth Sehgal on 03/03/2025.
//

import SwiftUI

struct TravelToolsView: View {
    @State private var navigationPath = NavigationPath()
    @State private var searchText = ""
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.openURL) private var openURL
    
    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    // Define categories
    private let categories = [
        ("Essential", [ToolType.currencyConverter, .tipCalculator, .unitConverter]), // Add it here
        ("Navigation", [ToolType.offlineMaps, .timeZone]),
        ("Information", [ToolType.travelTips, .plugCompatibility])
    ]
    
    var filteredTools: [ToolType] {
        if searchText.isEmpty {
            return ToolType.allCases
        }
        return ToolType.allCases.filter {
            $0.rawValue.localizedCaseInsensitiveContains(searchText) ||
            $0.description.localizedCaseInsensitiveContains(searchText)
        }
    }
    
    var body: some View {
        NavigationStack(path: $navigationPath) {
            ScrollView {
                VStack(spacing: 24) {
                    // Categories
                    ForEach(categories, id: \.0) { category in
                        CategorySection(title: category.0, tools: category.1)
                    }
                    
                    // All Tools Grid
                    Text("All Tools")
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal)
                    
                    LazyVGrid(columns: columns, spacing: 16) {
                        ForEach(filteredTools) { tool in
                            NavigationLink(value: tool) {
                                ToolCard(type: tool)
                            }
                        }
                    }
                    .padding(.horizontal)
                    
                    // Privacy Policy Button
                    Divider()
                        .padding(.vertical)
                    
                    Button(action: {
                        if let url = URL(string: "https://www.termsfeed.com/live/ca02ea31-b874-40db-8025-f0dae3ee5c76") {
                            openURL(url)
                        }
                    }) {
                        HStack {
                            Image(systemName: "lock.shield")
                                .foregroundColor(.secondary)
                            Text("Privacy Policy")
                                .foregroundColor(.secondary)
                        }
                        .font(.footnote)
                    }
                    .padding(.bottom, 8)
                }
                .padding(.vertical)
            }
            .navigationTitle("Travel Tools")
            .searchable(text: $searchText, prompt: "Search tools")
            .navigationDestination(for: ToolType.self) { tool in
                toolView(for: tool)
            }
            .background(Color(.systemGroupedBackground))
        }
    }
    
    @ViewBuilder
    private func toolView(for type: ToolType) -> some View {
        switch type {
        case .currencyConverter:
            CurrencyConverterView()
                .navigationBarTitleDisplayMode(.inline)
        case .plugCompatibility:
            PlugCompatibilityView()
                .navigationBarTitleDisplayMode(.inline)
        case .travelTips:
            TravelTipsView()
                .navigationBarTitleDisplayMode(.inline)
        case .timeZone:
            TimeZoneConverterView()
                .navigationBarTitleDisplayMode(.inline)
        case .offlineMaps:
            OfflineMapsView()
                .navigationBarTitleDisplayMode(.inline)
        case .tipCalculator:
            TipCalculatorView()
                .navigationBarTitleDisplayMode(.inline)
        case .unitConverter:
            UnitConverterView()
                .navigationBarTitleDisplayMode(.inline)
        }
    }
}

// MARK: - Supporting Views
struct CategorySection: View {
    let title: String
    let tools: [ToolType]
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.headline)
                .padding(.horizontal)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(tools) { tool in
                        NavigationLink(value: tool) {
                            CategoryCard(tool: tool)
                        }
                    }
                }
                .padding(.horizontal)
            }
        }
    }
}

struct CategoryCard: View {
    let tool: ToolType
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Image(systemName: tool.icon)
                .font(.title)
                .foregroundColor(.white)
                .frame(width: 50, height: 50)
                .background(tool.accentColor)
                .cornerRadius(12)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(tool.rawValue)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Text(tool.description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
        }
        .frame(width: 200)
        .padding()
        .background(colorScheme == .dark ? Color(.systemGray6) : .white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}

struct ToolCard: View {
    let type: ToolType
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Image(systemName: type.icon)
                .font(.title2)
                .foregroundColor(.white)
                .frame(width: 40, height: 40)
                .background(type.accentColor)
                .cornerRadius(10)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(type.rawValue)
                    .font(.headline)
                
                Text(type.description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(colorScheme == .dark ? Color(.systemGray6) : .white)
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}
