//
//  Currency.swift
//  TripCraft
//
//  Created by Siddharth Sehgal on 08/03/2025.
//

import Foundation

struct Currency: Identifiable, Hashable {
    let id = UUID()
    let code: String
    let name: String
    let symbol: String
    let flag: String
    
    static let all: [Currency] = [
        Currency(code: "USD", name: "US Dollar", symbol: "$", flag: "🇺🇸"),
        Currency(code: "EUR", name: "Euro", symbol: "€", flag: "🇪🇺"),
        Currency(code: "GBP", name: "British Pound", symbol: "£", flag: "🇬🇧"),
        Currency(code: "JPY", name: "Japanese Yen", symbol: "¥", flag: "🇯🇵"),
        Currency(code: "AUD", name: "Australian Dollar", symbol: "$", flag: "🇦🇺"),
        Currency(code: "CAD", name: "Canadian Dollar", symbol: "$", flag: "🇨🇦"),
        Currency(code: "CHF", name: "Swiss Franc", symbol: "Fr", flag: "🇨🇭"),
        Currency(code: "CNY", name: "Chinese Yuan", symbol: "¥", flag: "🇨🇳"),
        Currency(code: "INR", name: "Indian Rupee", symbol: "₹", flag: "🇮🇳"),
        Currency(code: "NZD", name: "New Zealand Dollar", symbol: "$", flag: "🇳🇿"),
        Currency(code: "SGD", name: "Singapore Dollar", symbol: "$", flag: "🇸🇬"),
        Currency(code: "AED", name: "UAE Dirham", symbol: "د.إ", flag: "🇦🇪")
    ]
}
