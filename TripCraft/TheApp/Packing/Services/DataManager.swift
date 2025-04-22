//
//  DataManager.swift
//  TripCraft
//
//  Created by Siddharth Sehgal on 06/03/2025.
//

import Foundation

class DataManager {
    static let shared = DataManager()
    private let packingListKey = "savedPackingList"
    
    func savePackingItems(_ items: [PackingItem]) {
        if let encoded = try? JSONEncoder().encode(items) {
            UserDefaults.standard.set(encoded, forKey: packingListKey)
        }
    }
    
    func loadPackingItems() -> [PackingItem] {
        if let data = UserDefaults.standard.data(forKey: packingListKey),
           let items = try? JSONDecoder().decode([PackingItem].self, from: data) {
            return items
        }
        return []
    }
}
