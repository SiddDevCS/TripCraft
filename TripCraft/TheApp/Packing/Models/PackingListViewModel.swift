//
//  PackingListViewModel.swift
//  TripCraft
//
//  Created by Siddharth Sehgal on 07/03/2025.
//

import Foundation
import SwiftUI

class PackingListViewModel: ObservableObject {
    @Published private(set) var packingItems: [PackingItem] = []
    @Published var trips: [Trip] = []
    @Published var customCategories: [CustomCategory] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    private let dataManager = DataManager.shared
    
    // Character limits
    private let maxTripNameLength = 50
    private let maxDestinationLength = 100
    private let maxNotesLength = 500
    private let maxAdditionalInfoLength = 300
    private let maxAIResponseLength = 200
    private let maxItemNameLength = 100
    private let maxCategoryNameLength = 30
    
    init() {
        
        loadItems()
        loadTrips()
        loadCustomCategories()
    }
    
    // MARK: - Trip Management
    
    func loadTrips() {
        trips = dataManager.loadTrips()
    }
    
    func addTrip(_ trip: Trip) {
        var validatedTrip = trip
        validatedTrip.name = String(trip.name.prefix(maxTripNameLength))
        validatedTrip.destination = String(trip.destination.prefix(maxDestinationLength))
        validatedTrip.notes = trip.notes.map { String($0.prefix(maxNotesLength)) }
        
        trips.append(validatedTrip)
        saveTrips()
    }
    
    func updateTrip(_ trip: Trip) {
        var validatedTrip = trip
        validatedTrip.name = String(trip.name.prefix(maxTripNameLength))
        validatedTrip.destination = String(trip.destination.prefix(maxDestinationLength))
        validatedTrip.notes = trip.notes.map { String($0.prefix(maxNotesLength)) }
        
        if let index = trips.firstIndex(where: { $0.id == trip.id }) {
            trips[index] = validatedTrip
            saveTrips()
        }
    }
    
    func deleteTrip(_ trip: Trip) {
        trips.removeAll { $0.id == trip.id }
        saveTrips()
        
        // Delete all associated packing items
        packingItems.removeAll { $0.tripId == trip.id }
        saveItems()
    }
    
    private func saveTrips() {
        dataManager.saveTrips(trips)
    }
    
    // MARK: - Item Management by Trip
    
    func packingItemsForTrip(tripId: UUID) -> [PackingItem] {
        packingItems.filter { $0.tripId == tripId }
    }
    
    func deleteAllItemsForTrip(tripId: UUID) {
        packingItems.removeAll { $0.tripId == tripId }
        saveItems()
    }
        
    func deleteItem(_ item: PackingItem) {
        packingItems.removeAll { $0.id == item.id }
        saveItems()
    }
    
    // MARK: - Item Management
    
    func loadItems() {
        packingItems = dataManager.loadPackingItems()
    }
    
    func addItems(_ items: [PackingItem]) {
        let validatedItems = items.map { validateItem($0) }
        packingItems.append(contentsOf: validatedItems)
        saveItems()
    }
    
    func updateItem(_ item: PackingItem) {
        let validatedItem = validateItem(item)
        if let index = packingItems.firstIndex(where: { $0.id == item.id }) {
            packingItems[index] = validatedItem
            saveItems()
        }
    }
    
    private func validateItem(_ item: PackingItem) -> PackingItem {
        var validated = item
        validated.name = String(item.name.prefix(maxItemNameLength))
        return validated
    }
    
    func deleteItems(at indexSet: IndexSet, in category: PackingCategory) {
        let categoryItems = items(for: category)
        let itemsToDelete = indexSet.map { categoryItems[$0] }
        packingItems.removeAll { item in
            itemsToDelete.contains { $0.id == item.id }
        }
        saveItems()
    }
    
    func deleteAll() {
        packingItems.removeAll()
        saveItems()
    }
        
    func deleteItems(with ids: Set<UUID>) {
        packingItems.removeAll { ids.contains($0.id) }
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
        let validatedName = String(name.prefix(maxCategoryNameLength))
        let newCategory = CustomCategory(id: UUID(), name: validatedName, icon: icon, color: color)
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
            // Apply character limits to trip details
            let sanitizedDetails = sanitizeTripDetails(tripDetails)
            let response = try await AIService().generatePackingList(tripDetails: sanitizedDetails)
            
            // Limit AI response length for security
            let limitedResponse = String(response.prefix(maxAIResponseLength))
            let _ = parseAIResponse(limitedResponse)
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    private func sanitizeTripDetails(_ details: TripDetails) -> TripDetails {
        var sanitized = details
        sanitized.destination = String(details.destination.prefix(maxDestinationLength))
        sanitized.additionalInfo = details.additionalInfo.map { String($0.prefix(maxAdditionalInfoLength)) }
        return sanitized
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
                    let validatedItemName = String(itemText.prefix(maxItemNameLength))
                    let item = PackingItem(
                        id: UUID(),
                        name: validatedItemName,
                        category: currentCategory,
                        isPacked: false,
                        details: PackingItemDetails(
                            quantity: 1,
                            priority: .none,
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
    
    func getRemainingPrompts() -> Int {
        AIService().getRemainingPrompts()
    }
}
