//
//  CurrencyService.swift
//  TripCraft
//
//  Created by Siddharth Sehgal on 08/03/2025.
//

import Foundation

class CurrencyService: ObservableObject {
    @Published var rates: [String: Double] = [:]
    @Published var lastUpdated: Date?
    @Published var isLoading = false
    @Published var error: String?
    
    // Estimated fixed exchange rates (as of March 2024)
    private let estimatedRates: [String: Double] = [
        "USD": 1.0,
        "EUR": 0.92,
        "GBP": 0.79,
        "JPY": 147.50,
        "AUD": 1.52,
        "CAD": 1.35,
        "CHF": 0.88,
        "CNY": 7.19,
        "INR": 82.80,
        "NZD": 1.64,
        "SGD": 1.34,
        "AED": 3.67
    ]
    
    init() {
        updateRates(base: "USD")
    }
    
    func fetchLatestRates(base: String) async {
        await MainActor.run {
            self.isLoading = true
            updateRates(base: base)
            self.isLoading = false
        }
    }
    
    private func updateRates(base: String) {
        guard let baseRate = estimatedRates[base] else { return }
        
        var newRates: [String: Double] = [:]
        for (currency, rate) in estimatedRates {
            newRates[currency] = rate / baseRate
        }
        
        self.rates = newRates
        self.lastUpdated = Date()
    }
}
