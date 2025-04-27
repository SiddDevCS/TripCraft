import SwiftUI

struct PackingListContentView: View {
    @ObservedObject var viewModel: PackingListViewModel
    let trip: Trip
    @Binding var searchText: String
    @Binding var isSelectionMode: Bool
    @Binding var selectedItems: Set<UUID>
    let onAddItemTapped: () -> Void
    let onAIAssistantTapped: () -> Void
    let onBackTapped: () -> Void
    
    var body: some View {
        ZStack(alignment: .top) {
            VStack(spacing: 0) {
                // Stats bar
                packingStatsView
                
                // Search indicator
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
                    .padding(.vertical, 8)
                    .background(Color(.systemGray6).opacity(0.5))
                }
                
                // Packing list
                List {
                    ForEach(Array(filteredItems.keys.sorted(by: { $0.rawValue < $1.rawValue })), id: \.self) { category in
                        categorySection(for: category)
                    }
                }
                .listStyle(.insetGrouped)
                .animation(.default, value: selectedItems)
                
                // Bottom action bar
                if !isSelectionMode {
                    HStack {
                        Button(action: onAIAssistantTapped) {
                            HStack {
                                Image(systemName: "wand.and.stars")
                                Text("Use AI")
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 10)
                            .background(Color.blue.opacity(0.15))
                            .foregroundColor(.blue)
                            .cornerRadius(10)
                        }
                        
                        Spacer()
                        
                        Button(action: onAddItemTapped) {
                            HStack {
                                Image(systemName: "plus")
                                Text("Add Item")
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 10)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                    .padding(.bottom, 60)
                    .background(
                        Rectangle()
                            .fill(Color(.systemBackground))
                            .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: -2)
                    )
                }
            }
            
            // Back button
            Button(action: onBackTapped) {
                HStack(spacing: 4) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 14, weight: .semibold))
                    Text("All Trips")
                        .font(.system(size: 16, weight: .medium))
                }
                .foregroundStyle(.blue)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(
                    Capsule()
                        .fill(Color(.systemBackground).opacity(0.9))
                        .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
                )
            }
            .buttonStyle(ScaleButtonStyle())
            .padding(.leading, 16)
            .padding(.top, 10)
            .zIndex(1) // Ensure button stays on top
        }
    }
    
    // MARK: - Stats Bar
    private var packingStatsView: some View {
        // Break up complex expressions to help compiler
        let itemsForTrip = viewModel.packingItemsForTrip(tripId: trip.id)
        let packedCount = itemsForTrip.filter { $0.isPacked }.count
        let totalCount = itemsForTrip.count
        let progressValue = totalCount > 0 ? Double(packedCount) / Double(totalCount) : 0.0
        let progressWidth = min(120 * progressValue, 120) // Ensure it doesn't exceed container width
        
        return HStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Packing Progress")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                HStack(alignment: .bottom, spacing: 4) {
                    Text("\(packedCount)/\(totalCount)")
                        .font(.headline)
                    
                    Text("items packed")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.bottom, 1)
                }
            }
            
            Spacer(minLength: 8)
            
            // Progress bar
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.gray.opacity(0.2))
                    .frame(width: 120, height: 8)
                
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.blue)
                    .frame(width: progressWidth, height: 8)
            }
            
            Text("\(Int(progressValue * 100))%")
                .font(.headline)
                .foregroundColor(.blue)
                .frame(width: 45, alignment: .trailing) // Fixed width to prevent shifting
        }
        .padding(.horizontal)
        .padding(.vertical, 12)
        .background(
            Rectangle()
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.05), radius: 3, x: 0, y: 2)
        )
    }
    
    // MARK: - Category Section
    private func categorySection(for category: PackingCategory) -> some View {
        // Get items for this category
        let items = filteredItems[category] ?? []
        
        return Section {
            ForEach(items) { item in
                if isSelectionMode {
                    // Selection mode row
                    SelectableItemRow(
                        item: item,
                        isSelected: selectedItems.contains(item.id)
                    ) {
                        toggleItemSelection(id: item.id)
                    }
                } else {
                    // Normal item row
                    itemRow(for: item)
                }
            }
        } header: {
            categoryHeader(for: category, itemCount: items.count)
        }
    }
    
    // MARK: - Item Rows
    private func itemRow(for item: PackingItem) -> some View {
        PackingItemRow(item: item) {
            withAnimation {
                var updatedItem = item
                updatedItem.isPacked.toggle()
                viewModel.updateItem(updatedItem)
            }
        }
        .swipeActions(edge: .trailing) {
            Button(role: .destructive) {
                viewModel.deleteItem(item)
            } label: {
                Label("Delete", systemImage: "trash")
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
    
    // Helper function to toggle item selection
    private func toggleItemSelection(id: UUID) {
        if selectedItems.contains(id) {
            selectedItems.remove(id)
        } else {
            selectedItems.insert(id)
        }
    }
    
    // Extract category header to separate function
    private func categoryHeader(for category: PackingCategory, itemCount: Int) -> some View {
        HStack {
            Image(systemName: category.icon)
                .foregroundColor(category.color)
            
            Text(category.rawValue)
                .lineLimit(1)
            
            Spacer(minLength: 12)
            
            Text("\(itemCount) items")
                .foregroundColor(.secondary)
                .font(.caption)
                .lineLimit(1)
        }
    }
    
    // MARK: - Filtered Items
    private var filteredItems: [PackingCategory: [PackingItem]] {
        var result = [PackingCategory: [PackingItem]]()
        let tripItems = viewModel.packingItemsForTrip(tripId: trip.id)
        
        for category in PackingCategory.allCases {
            // Get items for this category
            let categoryItems = tripItems.filter { $0.category == category.rawValue }
            
            // Skip if empty
            if categoryItems.isEmpty { continue }
            
            if searchText.isEmpty {
                // No search filter
                result[category] = categoryItems
            } else {
                // Apply search filter
                let matchesName = { (item: PackingItem) -> Bool in
                    item.name.localizedCaseInsensitiveContains(searchText)
                }
                
                let matchesNotes = { (item: PackingItem) -> Bool in
                    if let notes = item.details.notes {
                        return notes.localizedCaseInsensitiveContains(searchText)
                    }
                    return false
                }
                
                let filtered = categoryItems.filter { matchesName($0) || matchesNotes($0) }
                
                if !filtered.isEmpty {
                    result[category] = filtered
                }
            }
        }
        
        return result
    }
} 