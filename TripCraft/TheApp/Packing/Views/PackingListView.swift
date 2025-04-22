//
//  PackingListView.swift
//  TripCraft
//
//  Created by Siddharth Sehgal on 03/03/2025.
//

import SwiftUI

struct PackingListView: View {
    @StateObject private var viewModel = PackingListViewModel()
    @State private var showingAddItem = false
    @State private var showingAIAssistant = false
    @State private var searchText = ""
    @State private var isSelectionMode = false
    @State private var selectedItems: Set<UUID> = []
    @State private var showingDeleteAlert = false
    @StateObject private var aiService = AIService()
    
    var body: some View {
        Group {
            if viewModel.packingItems.isEmpty {
                EmptyStateView()
            } else {
                VStack(spacing: 0) {
                    // AI Assistant Button at the top
                    Button(action: { showingAIAssistant = true }) {
                        HStack {
                            Image(systemName: "wand.and.stars")
                                .font(.title2)
                            VStack(alignment: .leading, spacing: 2) {
                                Text("AI Packing Assistant")
                                    .font(.headline)
                                Text("Generate personalized packing list")
                                    .font(.caption)
                                    .foregroundColor(.blue.opacity(0.8))
                            }
                            Spacer()
                            VStack(alignment: .trailing, spacing: 2) {
                                Text("\(aiService.getRemainingPrompts()) left")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Text("Resets in \(aiService.getTimeUntilReset())")
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding()
                        .background(Color.blue.opacity(0.1))
                        .foregroundColor(.blue)
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.blue.opacity(0.2), lineWidth: 1)
                        )
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                    
                    // Search bar
                    if !searchText.isEmpty {
                        HStack {
                            Image(systemName: "magnifyingglass")
                                .foregroundColor(.secondary)
                            Text("Searching for '\(searchText)'")
                                .foregroundColor(.secondary)
                            Spacer()
                            Button(action: { searchText = "" }) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 8)
                    }
                    
                    // Existing packing list
                    packingList
                }
            }
        }
        .navigationTitle("Packing List")
        .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always))
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Menu {
                    Button(action: { isSelectionMode.toggle() }) {
                        Label(isSelectionMode ? "Cancel Selection" : "Select Items",
                              systemImage: isSelectionMode ? "xmark.circle" : "checkmark.circle")
                    }
                    
                    Button(role: .destructive, action: { showingDeleteAlert = true }) {
                        Label("Delete All", systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
            
            ToolbarItem(placement: .navigationBarTrailing) {
                if isSelectionMode {
                    Button("Delete Selected", role: .destructive) {
                        deleteSelectedItems()
                    }
                    .disabled(selectedItems.isEmpty)
                } else {
                    Button(action: { showingAddItem = true }) {
                        Label("Add Item", systemImage: "plus.circle.fill")
                    }
                }
            }
        }
        .sheet(isPresented: $showingAddItem) {
            AddItemView(viewModel: viewModel)
        }
        .sheet(isPresented: $showingAIAssistant) {
            AIAssistantView(viewModel: viewModel)
        }
        .alert("Delete All Items", isPresented: $showingDeleteAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete All", role: .destructive) {
                deleteAllItems()
            }
        } message: {
            Text("Are you sure you want to delete all items? This action cannot be undone.")
        }
    }
    
    private var filteredItems: [PackingCategory: [PackingItem]] {
        var result = [PackingCategory: [PackingItem]]()
        
        for category in PackingCategory.allCases {
            let categoryItems = viewModel.items(for: category)
            if !categoryItems.isEmpty {
                if searchText.isEmpty {
                    result[category] = categoryItems
                } else {
                    let filtered = categoryItems.filter { item in
                        item.name.localizedCaseInsensitiveContains(searchText) ||
                        item.details.notes?.localizedCaseInsensitiveContains(searchText) == true
                    }
                    if !filtered.isEmpty {
                        result[category] = filtered
                    }
                }
            }
        }
        return result
    }
    
    private var packingList: some View {
        List {
            ForEach(Array(filteredItems.keys.sorted(by: { $0.rawValue < $1.rawValue })), id: \.self) { category in
                categorySection(for: category)
            }
        }
        .listStyle(.insetGrouped)
        .animation(.default, value: selectedItems)
    }
    
    private func categorySection(for category: PackingCategory) -> some View {
        Section {
            ForEach(filteredItems[category] ?? []) { item in
                if isSelectionMode {
                    SelectableItemRow(item: item, isSelected: selectedItems.contains(item.id)) {
                        if selectedItems.contains(item.id) {
                            selectedItems.remove(item.id)
                        } else {
                            selectedItems.insert(item.id)
                        }
                    }
                } else {
                    PackingItemRow(item: item) {
                        withAnimation {
                            var updatedItem = item
                            updatedItem.isPacked.toggle()
                            viewModel.updateItem(updatedItem)
                        }
                    }
                    .swipeActions(edge: .leading) {
                        Button {
                            withAnimation {
                                var updatedItem = item
                                updatedItem.isPacked.toggle()
                                viewModel.updateItem(updatedItem)
                            }
                        } label: {
                            Label(item.isPacked ? "Unpack" : "Pack",
                                  systemImage: item.isPacked ? "circle" : "checkmark.circle.fill")
                        }
                        .tint(item.isPacked ? .gray : .green)
                    }
                }
            }
            .onDelete { indexSet in
                viewModel.deleteItems(at: indexSet, in: category)
            }
        } header: {
            HStack {
                Image(systemName: category.icon)
                Text(category.rawValue)
                Spacer()
                Text("\(filteredItems[category]?.count ?? 0) items")
                    .foregroundColor(.secondary)
                    .font(.caption)
            }
        }
    }
    
    private func deleteAllItems() {
        withAnimation {
            viewModel.deleteAll()
        }
    }
    
    private func deleteSelectedItems() {
        withAnimation {
            viewModel.deleteItems(with: selectedItems)
            selectedItems.removeAll()
            isSelectionMode = false
        }
    }
}

struct SelectableItemRow: View {
    let item: PackingItem
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        HStack {
            Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                .foregroundColor(.blue)
            
            VStack(alignment: .leading) {
                Text(item.name)
                    .strikethrough(item.isPacked)
                
                if item.details.quantity > 1 {
                    Text("Qty: \(item.details.quantity)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .contentShape(Rectangle())
        .onTapGesture(perform: onTap)
    }
}
