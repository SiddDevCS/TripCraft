import SwiftUI

struct OnboardingStep: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let systemImage: String
    let accentColor: Color
    let lightBackgroundColor: Color
    let darkBackgroundColor: Color
}

extension OnboardingStep {
    static let primaryColor = Color(red: 0.1, green: 0.5, blue: 0.9)
    static let secondaryColor = Color(red: 0.2, green: 0.6, blue: 1.0)
    
    static let steps = [
        OnboardingStep(
            title: "Welcome to TripCraft",
            description: "Plan trips, pack smart, capture memories.",
            systemImage: "airplane.circle.fill",
            accentColor: primaryColor,
            lightBackgroundColor: Color(red: 0.9, green: 0.95, blue: 1.0),
            darkBackgroundColor: Color(red: 0.12, green: 0.18, blue: 0.3)
        ),
        OnboardingStep(
            title: "Smart Travel Tools",
            description: "AI packing lists, currency conversion, and more.",
            systemImage: "gearshape.fill",
            accentColor: secondaryColor,
            lightBackgroundColor: Color(red: 0.8, green: 0.9, blue: 1.0),
            darkBackgroundColor: Color(red: 0.08, green: 0.14, blue: 0.25)
        )
    ]
}

// User data model for onboarding
struct UserOnboardingData {
    var travelPreferences: Set<TravelStyle> = []
    var tripInterests: Set<TripCategory> = []
    var travelSeasons: Set<TravelSeason> = []
    var accommodationTypes: Set<AccommodationType> = []
    var notificationsEnabled: Bool = true
    var shareTripsWithFriends: Bool = false
    
    enum TravelStyle: String, CaseIterable, Identifiable {
        case leisure = "Leisure"
        case business = "Business"
        case adventure = "Adventure"
        case cultural = "Cultural"
        case budget = "Budget"
        case luxury = "Luxury"
        case ecotourism = "Eco-friendly"
        case solo = "Solo Travel"
        
        var id: String { self.rawValue }
        
        var icon: String {
            switch self {
            case .leisure: return "beach.umbrella.fill"
            case .business: return "briefcase.fill"
            case .adventure: return "figure.hiking"
            case .cultural: return "building.columns.fill"
            case .budget: return "dollarsign.circle.fill"
            case .luxury: return "star.fill"
            case .ecotourism: return "leaf.fill"
            case .solo: return "person.fill"
            }
        }
    }
    
    enum TripCategory: String, CaseIterable, Identifiable {
        case beaches = "Beaches"
        case mountains = "Mountains"
        case cityBreaks = "City Breaks"
        case food = "Food & Dining"
        case history = "Historical Sites"
        case nature = "Nature & Wildlife"
        case shopping = "Shopping"
        case museums = "Museums & Art"
        case nightlife = "Nightlife"
        case sports = "Sports & Activities"
        
        var id: String { self.rawValue }
        
        var icon: String {
            switch self {
            case .beaches: return "water.waves"
            case .mountains: return "mountain.2.fill"
            case .cityBreaks: return "building.2.fill"
            case .food: return "fork.knife"
            case .history: return "scroll.fill"
            case .nature: return "leaf.fill"
            case .shopping: return "bag.fill"
            case .museums: return "paintpalette.fill"
            case .nightlife: return "moon.stars.fill"
            case .sports: return "figure.play"
            }
        }
    }
    
    enum TravelSeason: String, CaseIterable, Identifiable {
        case spring = "Spring"
        case summer = "Summer"
        case fall = "Fall"
        case winter = "Winter"
        case anytime = "Any season"
        
        var id: String { self.rawValue }
        
        var icon: String {
            switch self {
            case .spring: return "cloud.sun.rain.fill"
            case .summer: return "sun.max.fill"
            case .fall: return "leaf.fill"
            case .winter: return "snow"
            case .anytime: return "calendar"
            }
        }
    }
    
    enum AccommodationType: String, CaseIterable, Identifiable {
        case hotel = "Hotels"
        case hostel = "Hostels"
        case rental = "Vacation Rentals"
        case camping = "Camping"
        case familyFriends = "Family/Friends"
        
        var id: String { self.rawValue }
        
        var icon: String {
            switch self {
            case .hotel: return "building.2"
            case .hostel: return "bed.double.fill"
            case .rental: return "house.fill"
            case .camping: return "tent.fill"
            case .familyFriends: return "person.3.fill"
            }
        }
    }
} 
