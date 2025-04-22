//
//  PackingModels.swift
//  TripCraft
//
//  Created by Siddharth Sehgal on 06/03/2025.
//

import Foundation

// MARK: - Enums
enum PackingCategory: String, CaseIterable {
    case clothing = "Clothing"
    case electronics = "Electronics"
    case toiletries = "Toiletries"
    case documents = "Documents"
    case accessories = "Accessories"
    case miscellaneous = "Miscellaneous"
    
    var icon: String {
        switch self {
        case .clothing: return "tshirt"
        case .electronics: return "laptopcomputer"
        case .toiletries: return "shower"
        case .documents: return "doc.text"
        case .accessories: return "bag"
        case .miscellaneous: return "ellipsis.circle"
        }
    }
}

enum Priority: String, Codable, CaseIterable {
    case high = "High"
    case medium = "Medium"
    case low = "Low"
}

// MARK: - Models
struct PackingItem: Identifiable, Codable, Equatable {
    let id: UUID
    var name: String
    var category: String
    var isPacked: Bool
    var details: PackingItemDetails
    var isAIGenerated: Bool
}

struct PackingItemDetails: Codable, Equatable {
    var quantity: Int
    var notes: String?
    var priority: Priority
    var weight: Double?
    var price: Double?
    var purchased: Bool
}

struct CustomCategory: Codable, Identifiable, Hashable {
    let id: UUID
    var name: String
    var icon: String
    var color: String
}

struct ChatMessage: Identifiable {
    let id = UUID()
    let content: String
    let isFromAI: Bool
    let timestamp = Date()
}

enum TripType: String, CaseIterable {
    case leisure = "Leisure"
    case business = "Business"
    case adventure = "Adventure"
    case backpacking = "Backpacking"
    case luxury = "Luxury"
}

enum AccommodationType: String, CaseIterable {
    case hotel = "Hotel"
    case hostel = "Hostel"
    case camping = "Camping"
    case airbnb = "Airbnb"
    case resort = "Resort"
}

enum TransportationType: String, CaseIterable {
    case plane = "Plane"
    case train = "Train"
    case car = "Car"
    case bus = "Bus"
    case ship = "Ship"
}

// Add this struct to organize trip details
struct TripDetails {
    var destination: String
    var duration: Int
    var season: String
    var activities: Set<String>
    var tripType: TripType
    var accommodation: AccommodationType
    var transportation: TransportationType
    var budget: String
    var specialNeeds: String?
    var childrenCount: Int
    var hasLaundry: Bool
    var additionalNotes: String
}
