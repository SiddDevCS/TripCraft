//
//  TravelTipModels.swift
//  TripCraft
//
//  Created by Siddharth Sehgal on 08/03/2025.
//

import Foundation

struct TravelTip: Identifiable, Hashable {
    let id = UUID()
    let title: String
    let description: String
    let category: TipCategory
    let icon: String
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

enum TipCategory: String, CaseIterable {
    case safety = "Safety"
    case packing = "Packing"
    case culture = "Culture & Etiquette"
    case transportation = "Transportation"
    case accommodation = "Accommodation"
    case food = "Food & Dining"
    case money = "Money & Budget"
    case health = "Health & Wellness"
    
    var icon: String {
        switch self {
        case .safety: return "shield.fill"
        case .packing: return "bag.fill"
        case .culture: return "globe"
        case .transportation: return "airplane"
        case .accommodation: return "house.fill"
        case .food: return "fork.knife"
        case .money: return "dollarsign.circle.fill"
        case .health: return "heart.fill"
        }
    }
}

class TravelTipsService {
    static let shared = TravelTipsService()
    
    let tips: [TravelTip] = [
        // Safety Tips
        TravelTip(
            title: "Digital Document Backup",
            description: "Store digital copies of all important documents in a secure cloud service. Include passport, visas, insurance cards, and emergency contacts.",
            category: .safety,
            icon: "doc.fill"
        ),
        TravelTip(
            title: "Emergency Contacts",
            description: "Save local emergency numbers and embassy contacts before arrival. Keep both digital and physical copies.",
            category: .safety,
            icon: "phone.fill"
        ),
        TravelTip(
            title: "Location Sharing",
            description: "Share your live location with trusted family members or friends during your trip.",
            category: .safety,
            icon: "location.fill"
        ),
        TravelTip(
            title: "Travel Insurance",
            description: "Get comprehensive travel insurance that covers medical emergencies, trip cancellation, and lost belongings.",
            category: .safety,
            icon: "cross.case.fill"
        ),
        
        // Packing Tips
        TravelTip(
            title: "3-2-1 Rule",
            description: "Pack 3 bottoms, 2 tops for each bottom, and 1 pair of shoes that goes with everything.",
            category: .packing,
            icon: "tshirt.fill"
        ),
        TravelTip(
            title: "Roll Don't Fold",
            description: "Roll clothes instead of folding to save space and prevent wrinkles.",
            category: .packing,
            icon: "arrow.up.and.down.and.arrow.left.and.right"
        ),
        
        // Culture Tips
        TravelTip(
            title: "Local Customs Research",
            description: "Research local customs, gestures, and taboos before your trip to avoid cultural faux pas.",
            category: .culture,
            icon: "book.fill"
        ),
        TravelTip(
            title: "Basic Phrases",
            description: "Learn basic phrases in the local language - greetings, thank you, excuse me, and numbers.",
            category: .culture,
            icon: "text.bubble.fill"
        ),
        
        // Transportation
        TravelTip(
            title: "Local Transport Apps",
            description: "Download local transportation apps and maps for offline use before arrival.",
            category: .transportation,
            icon: "car.fill"
        ),
        TravelTip(
            title: "Airport Transfer",
            description: "Book airport transfers in advance, especially for late-night arrivals.",
            category: .transportation,
            icon: "airplane.arrival"
        ),
        
        // Accommodation
        TravelTip(
            title: "Location Check",
            description: "Research neighborhood safety and proximity to attractions before booking accommodation.",
            category: .accommodation,
            icon: "map.fill"
        ),
        TravelTip(
            title: "Review Photos",
            description: "Look for recent guest photos rather than professional marketing images when booking.",
            category: .accommodation,
            icon: "photo.fill"
        ),
        
        // Food & Dining
        TravelTip(
            title: "Street Food Safety",
            description: "Choose busy street food stalls with high turnover and watch food being prepared.",
            category: .food,
            icon: "cart.fill"
        ),
        TravelTip(
            title: "Water Safety",
            description: "Check if tap water is safe to drink. When in doubt, stick to bottled water.",
            category: .food,
            icon: "drop.fill"
        ),
        
        // Money
        TravelTip(
            title: "Card Notification",
            description: "Notify your bank of travel dates and destinations to prevent card blocks.",
            category: .money,
            icon: "creditcard.fill"
        ),
        TravelTip(
            title: "Currency Mix",
            description: "Keep a mix of cash and cards. Store them separately as backup.",
            category: .money,
            icon: "banknote.fill"
        ),
        
        // Health
        TravelTip(
            title: "First Aid Kit",
            description: "Pack basic medications, bandages, and any prescription medicines you need.",
            category: .health,
            icon: "cross.fill"
        ),
        TravelTip(
            title: "Time Zone Adjustment",
            description: "Start adjusting your sleep schedule a few days before long-distance travel.",
            category: .health,
            icon: "clock.fill"
        )
    ]
    
    func getTipsByCategory(_ category: TipCategory) -> [TravelTip] {
        tips.filter { $0.category == category }
    }
}
