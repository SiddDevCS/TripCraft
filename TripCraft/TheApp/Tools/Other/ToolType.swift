//
//  ToolType.swift
//  TripCraft
//
//  Created by Siddharth Sehgal on 08/03/2025.
//

import SwiftUI

enum ToolType: String, CaseIterable, Identifiable {
    case currencyConverter = "Currency Converter"
    case tipCalculator = "Tip Calculator"
    case offlineMaps = "Offline Maps"
    case timeZone = "Time Zone"
    case travelTips = "Travel Tips"
    case plugCompatibility = "Plug Compatibility"
    case unitConverter = "Unit Converter"
    
    var id: String { rawValue }
    
    var icon: String {
        switch self {
        case .currencyConverter: return "dollarsign.circle"
        case .plugCompatibility: return "power.circle"
        case .travelTips: return "lightbulb"
        case .timeZone: return "clock"
        case .offlineMaps: return "map.fill"
        case .tipCalculator: return "percent"
        case .unitConverter: return "arrow.2.squarepath"
        }
    }
    
    var description: String {
        switch self {
        case .currencyConverter:
            return "Real-time currency conversion and rates"
        case .plugCompatibility:
            return "Check power outlet compatibility worldwide"
        case .travelTips:
            return "Expert travel advice and local insights"
        case .timeZone:
            return "Easy time zone conversion and jet lag tips"
        case .offlineMaps:
            return "Interactive maps of major cities worldwide"
        case .tipCalculator:
            return "Calculate tips based on local customs"
        case .unitConverter:
            return "Convert between different units of measurement for your trip"
        }
    }
    
    var accentColor: Color {
        switch self {
        case .currencyConverter: return .green
        case .plugCompatibility: return .orange
        case .travelTips: return .purple
        case .timeZone: return .pink
        case .offlineMaps: return .indigo
        case .tipCalculator: return .mint
        case .unitConverter: return .purple
        }
    }
    
    static var featured: [ToolType] {
        [.currencyConverter, .travelTips]
    }
}
