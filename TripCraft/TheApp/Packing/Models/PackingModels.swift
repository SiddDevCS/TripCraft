import Foundation
import SwiftUI

// Trip theme enum - moved to top for proper reference
enum PackingTripTheme: String, CaseIterable, Codable {
    case beach = "Beach"
    case business = "Business"
    case hiking = "Hiking"
    case cityBreak = "City Break"
    case winter = "Winter"
    case tropical = "Tropical"
    case camping = "Camping"
    case roadTrip = "Road Trip"
    
    var icon: String {
        switch self {
        case .beach: return "sun.max.fill"
        case .business: return "briefcase.fill"
        case .hiking: return "mountain.2.fill"
        case .cityBreak: return "building.2.fill"
        case .winter: return "snowflake"
        case .tropical: return "leaf.fill"
        case .camping: return "tent.fill"
        case .roadTrip: return "car.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .beach: return .orange
        case .business: return .gray
        case .hiking: return .green
        case .cityBreak: return .blue
        case .winter: return .cyan
        case .tropical: return .mint
        case .camping: return .brown
        case .roadTrip: return .indigo
        }
    }
    
    var suggestedItems: [String] {
        switch self {
        case .beach:
            return ["Swimsuit", "Sunscreen", "Sunglasses", "Beach towel", "Flip flops"]
        case .business:
            return ["Formal attire", "Business cards", "Laptop", "Chargers", "Notebook"]
        case .hiking:
            return ["Hiking boots", "Water bottle", "First aid kit", "Trail map", "Backpack"]
        case .cityBreak:
            return ["Comfortable shoes", "City map", "Travel guide", "Camera", "Day bag"]
        case .winter:
            return ["Warm coat", "Gloves", "Scarf", "Thermal layers", "Boots"]
        case .tropical:
            return ["Light clothing", "Insect repellent", "Hat", "Sunscreen", "Rain jacket"]
        case .camping:
            return ["Tent", "Sleeping bag", "Flashlight", "Multi-tool", "Cooking gear"]
        case .roadTrip:
            return ["Maps", "Snacks", "Emergency kit", "Music playlist", "Pillow"]
        }
    }
}

// Main model for packing items
struct PackingItem: Identifiable, Codable, Equatable {
    var id: UUID
    var name: String
    var category: String
    var isPacked: Bool
    var details: PackingItemDetails
    var isAIGenerated: Bool = false
    var tripId: UUID? // To associate with specific trips
    
    static func == (lhs: PackingItem, rhs: PackingItem) -> Bool {
        lhs.id == rhs.id
    }
}

// Details for each packing item
struct PackingItemDetails: Codable, Equatable {
    var quantity: Int
    var priority: Priority
    var purchased: Bool
    var notes: String?
    
    enum Priority: String, Codable, CaseIterable {
        case high = "High"
        case medium = "Medium"
        case low = "Low"
        case none = "None"
        
        var color: Color {
            switch self {
            case .high: return .red
            case .medium: return .orange
            case .low: return .blue
            case .none: return .gray
            }
        }
    }
}

// Predefined categories for packing items
enum PackingCategory: String, CaseIterable, Identifiable {
    case clothing = "Clothing"
    case electronics = "Electronics"
    case toiletries = "Toiletries"
    case documents = "Documents"
    case accessories = "Accessories"
    case miscellaneous = "Miscellaneous"
    
    var id: String { self.rawValue }
    
    var icon: String {
        switch self {
        case .clothing: return "tshirt"
        case .electronics: return "laptopcomputer"
        case .toiletries: return "shower"
        case .documents: return "doc.text"
        case .accessories: return "eyeglasses"
        case .miscellaneous: return "ellipsis"
        }
    }
    
    var color: Color {
        switch self {
        case .clothing: return .blue
        case .electronics: return .gray
        case .toiletries: return .green
        case .documents: return .orange
        case .accessories: return .purple
        case .miscellaneous: return .secondary
        }
    }
}

// Custom categories
struct CustomCategory: Identifiable, Codable {
    var id: UUID
    var name: String
    var icon: String
    var color: String
}

// Model for trip details when using AI to generate packing list
struct TripDetails: Codable {
    var destination: String
    var duration: Int
    var climate: Climate
    var activities: [Activity]
    var accommodation: Accommodation
    var additionalInfo: String?
    var theme: PackingTripTheme?
    
    enum Climate: String, Codable, CaseIterable {
        case tropical = "Tropical"
        case desert = "Desert"
        case mediterranean = "Mediterranean"
        case continental = "Continental"
        case polar = "Polar"
        case temperate = "Temperate"
    }
    
    enum Activity: String, Codable, CaseIterable, Identifiable {
        case beach = "Beach"
        case hiking = "Hiking"
        case skiing = "Skiing"
        case business = "Business"
        case sightseeing = "Sightseeing"
        case nightlife = "Nightlife"
        case sports = "Sports"
        case relaxation = "Relaxation"
        
        var id: String { self.rawValue }
        
        var icon: String {
            switch self {
            case .beach: return "umbrella.beach"
            case .hiking: return "mountain.2"
            case .skiing: return "figure.skiing.downhill"
            case .business: return "briefcase"
            case .sightseeing: return "binoculars"
            case .nightlife: return "moon.stars"
            case .sports: return "sportscourt"
            case .relaxation: return "bed.double"
            }
        }
    }
    
    enum Accommodation: String, Codable, CaseIterable {
        case hotel = "Hotel"
        case hostel = "Hostel"
        case apartment = "Apartment"
        case house = "House"
        case camping = "Camping"
        case other = "Other"
    }
}

// Model for a trip that can have multiple packing lists
struct Trip: Identifiable, Codable, Equatable {
    var id: UUID
    var name: String
    var startDate: Date
    var endDate: Date
    var destination: String
    var notes: String?
    var theme: PackingTripTheme?
    
    var duration: Int {
        Calendar.current.dateComponents([.day], from: startDate, to: endDate).day ?? 0
    }
    
    enum CodingKeys: String, CodingKey {
        case id, name, startDate, endDate, destination, notes, theme
    }
    
    init(id: UUID, name: String, startDate: Date, endDate: Date, destination: String, notes: String? = nil, theme: PackingTripTheme? = nil) {
        self.id = id
        self.name = name
        self.startDate = startDate
        self.endDate = endDate
        self.destination = destination
        self.notes = notes
        self.theme = theme
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        startDate = try container.decode(Date.self, forKey: .startDate)
        endDate = try container.decode(Date.self, forKey: .endDate)
        destination = try container.decode(String.self, forKey: .destination)
        notes = try container.decodeIfPresent(String.self, forKey: .notes)
        
        // Handle potential missing theme for backward compatibility
        theme = try container.decodeIfPresent(PackingTripTheme.self, forKey: .theme)
    }
    
    static func == (lhs: Trip, rhs: Trip) -> Bool {
        return lhs.id == rhs.id
    }
}

// Data Manager for storing data locally
class DataManager {
    static let shared = DataManager()
    
    private let packingItemsKey = "packingItems"
    private let tripsKey = "trips"
    
    func loadPackingItems() -> [PackingItem] {
        guard let data = UserDefaults.standard.data(forKey: packingItemsKey) else { return [] }
        
        do {
            return try JSONDecoder().decode([PackingItem].self, from: data)
        } catch {
            print("Error loading packing items: \(error)")
            return []
        }
    }
    
    func savePackingItems(_ items: [PackingItem]) {
        do {
            let data = try JSONEncoder().encode(items)
            UserDefaults.standard.set(data, forKey: packingItemsKey)
        } catch {
            print("Error saving packing items: \(error)")
        }
    }
    
    func loadTrips() -> [Trip] {
        guard let data = UserDefaults.standard.data(forKey: tripsKey) else { return [] }
        
        do {
            return try JSONDecoder().decode([Trip].self, from: data)
        } catch {
            print("Error loading trips: \(error)")
            return []
        }
    }
    
    func saveTrips(_ trips: [Trip]) {
        do {
            let data = try JSONEncoder().encode(trips)
            UserDefaults.standard.set(data, forKey: tripsKey)
        } catch {
            print("Error saving trips: \(error)")
        }
    }
} 