//
//  PackingListViewModel.swift
//  TripCraft
//
//  Created by Siddharth Sehgal on 07/03/2025.
//

import Foundation

class PackingListViewModel: ObservableObject {
    @Published private(set) var packingItems: [PackingItem] = []
    @Published var customCategories: [CustomCategory] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var aiSuggestions: [PackingItem] = []
    
    private let dataManager = DataManager.shared
    
    init() {
        loadItems()
        loadCustomCategories()
    }
    
    // MARK: - New funcs
    
    func deleteAll() {
        packingItems.removeAll()
        saveItems()
    }
        
    func deleteItems(with ids: Set<UUID>) {
        packingItems.removeAll { ids.contains($0.id) }
        saveItems()
    }
    
    // MARK: - Item Management
    func loadItems() {
        packingItems = dataManager.loadPackingItems()
    }
    
    func addItems(_ items: [PackingItem]) {
        packingItems.append(contentsOf: items)
        saveItems()
    }
    
    func updateItem(_ item: PackingItem) {
        if let index = packingItems.firstIndex(where: { $0.id == item.id }) {
            packingItems[index] = item
            saveItems()
        }
    }
    
    func deleteItems(at indexSet: IndexSet, in category: PackingCategory) {
        let categoryItems = items(for: category)
        let itemsToDelete = indexSet.map { categoryItems[$0] }
        packingItems.removeAll { item in
            itemsToDelete.contains { $0.id == item.id }
        }
        saveItems()
    }
    
    private func saveItems() {
        dataManager.savePackingItems(packingItems)
    }
    
    // MARK: - Category Management
    func items(for category: PackingCategory) -> [PackingItem] {
        packingItems.filter { $0.category == category.rawValue }
    }
    
    func addCustomCategory(name: String, icon: String, color: String) {
        let newCategory = CustomCategory(id: UUID(), name: name, icon: icon, color: color)
        customCategories.append(newCategory)
        saveCustomCategories()
    }
    
    private func loadCustomCategories() {
        if let data = UserDefaults.standard.data(forKey: "customCategories"),
           let categories = try? JSONDecoder().decode([CustomCategory].self, from: data) {
            customCategories = categories
        }
    }
    
    private func saveCustomCategories() {
        if let encoded = try? JSONEncoder().encode(customCategories) {
            UserDefaults.standard.set(encoded, forKey: "customCategories")
        }
    }
    
    // MARK: - AI Integration
    @MainActor
    func generateAIPackingList(tripDetails: TripDetails) async {
        isLoading = true
        errorMessage = nil
        
        do {
            let response = try await AIService().generatePackingList(tripDetails: tripDetails)
            aiSuggestions = parseAIResponse(response)
            addItems(aiSuggestions)
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    func parseAIResponse(_ response: String) -> [PackingItem] {
        var items: [PackingItem] = []
        var currentCategory = PackingCategory.miscellaneous.rawValue
        
        let lines = response.components(separatedBy: .newlines)
        
        for line in lines {
            let trimmedLine = line.trimmingCharacters(in: .whitespaces)
            
            if trimmedLine.isEmpty { continue }
            
            // Check if line is a category header
            if trimmedLine.hasSuffix(":") {
                let categoryName = trimmedLine.dropLast().trimmingCharacters(in: .whitespaces)
                currentCategory = mapToPackingCategory(categoryName)
                continue
            }
            
            // Parse item
            if trimmedLine.hasPrefix("-") || trimmedLine.hasPrefix("•") {
                let itemText = trimmedLine.trimmingCharacters(in: CharacterSet(charactersIn: "-•"))
                    .trimmingCharacters(in: .whitespaces)
                
                if !itemText.isEmpty {
                    let item = PackingItem(
                        id: UUID(),
                        name: itemText,
                        category: currentCategory,
                        isPacked: false,
                        details: PackingItemDetails(
                            quantity: 1,
                            priority: .medium,
                            purchased: false
                        ),
                        isAIGenerated: true
                    )
                    
                    items.append(item)
                }
            }
        }
        
        return items
    }
    
    private func mapToPackingCategory(_ categoryName: String) -> String {
        let normalizedName = categoryName.lowercased()
        
        switch normalizedName {
        case "clothing", "clothes":
            return PackingCategory.clothing.rawValue
        case "electronics", "tech":
            return PackingCategory.electronics.rawValue
        case "toiletries", "bathroom":
            return PackingCategory.toiletries.rawValue
        case "documents", "paperwork":
            return PackingCategory.documents.rawValue
        case "accessories":
            return PackingCategory.accessories.rawValue
        default:
            return PackingCategory.miscellaneous.rawValue
        }
    }
    
    // Add this method to handle adding AI suggestions
    func addAISuggestions(_ suggestions: [PackingItem]) {
        DispatchQueue.main.async {
            self.packingItems.append(contentsOf: suggestions)
            self.saveItems()
        }
    }
    
    func getRemainingPrompts() -> Int {
        AIService().getRemainingPrompts()
    }
}
