//
//  AIService.swift
//  TripCraft
//
//  Created by Siddharth Sehgal on 06/03/2025.
//

import Foundation

class AIService: ObservableObject {
    @Published var isGenerating = false
    @Published var error: Error?
    
    private let maxPromptsPerWeek = 2
    private let promptResetDays = 7
    private let userDefaultsKey = "ai_prompt_usage"
    
    private struct PromptUsage: Codable {
        var count: Int
        var lastResetDate: Date
    }
    
    func getRemainingPrompts() -> Int {
        let usage = getCurrentUsage()
        return maxPromptsPerWeek - usage.count
    }
    
    func getTimeUntilReset() -> String {
        let usage = getCurrentUsage()
        let resetDate = usage.lastResetDate.addingTimeInterval(TimeInterval(promptResetDays * 24 * 3600))
        let difference = resetDate.timeIntervalSince(Date())
        
        if difference <= 0 {
            return "Now"
        }
        
        let days = Int(difference) / (24 * 3600)
        let hours = (Int(difference) % (24 * 3600)) / 3600
        
        if days > 0 {
            return "\(days)d \(hours)h"
        } else {
            let minutes = (Int(difference) % 3600) / 60
            return "\(hours)h \(minutes)m"
        }
    }
    
    private func getCurrentUsage() -> PromptUsage {
        if let data = UserDefaults.standard.data(forKey: userDefaultsKey),
           let usage = try? JSONDecoder().decode(PromptUsage.self, from: data) {
            
            // Check if we need to reset based on time (7 days)
            let daysSinceLastReset = usage.lastResetDate.timeIntervalSinceNow / (24 * 3600)
            if abs(daysSinceLastReset) >= Double(promptResetDays) {
                // Reset count if enough time has passed
                let newUsage = PromptUsage(count: 0, lastResetDate: Date())
                saveUsage(newUsage)
                return newUsage
            }
            
            return usage
        }
        
        // If no existing usage, create new
        let newUsage = PromptUsage(count: 0, lastResetDate: Date())
        saveUsage(newUsage)
        return newUsage
    }
    
    private func incrementPromptCount() {
        var usage = getCurrentUsage()
        usage.count += 1
        saveUsage(usage)
    }
    
    private func saveUsage(_ usage: PromptUsage) {
        if let encoded = try? JSONEncoder().encode(usage) {
            UserDefaults.standard.set(encoded, forKey: userDefaultsKey)
        }
    }
    
    func generatePackingList(tripDetails: TripDetails) async throws -> String {
        // Check if we've exceeded weekly limit
        let remainingPrompts = getRemainingPrompts()
        guard remainingPrompts > 0 else {
            throw NSError(
                domain: "AIService",
                code: -1,
                userInfo: [NSLocalizedDescriptionKey: "Weekly limit of 2 AI-generated packing lists reached. Please try again next week."]
            )
        }
        
        let prompt = """
        Generate a detailed packing list for a trip with the following details:
        - Destination: \(tripDetails.destination)
        - Duration: \(tripDetails.duration) days
        - Season: \(tripDetails.season)
        - Activities: \(tripDetails.activities.joined(separator: ", "))
        - Trip Type: \(tripDetails.tripType.rawValue)
        - Accommodation: \(tripDetails.accommodation.rawValue)
        - Transportation: \(tripDetails.transportation.rawValue)
        - Budget Level: \(tripDetails.budget)
        \(tripDetails.childrenCount > 0 ? "- Children: \(tripDetails.childrenCount)" : "")
        \(tripDetails.hasLaundry ? "- Laundry facilities available" : "")
        \(tripDetails.specialNeeds.map { "- Special Needs: \($0)" } ?? "")
        \(tripDetails.additionalNotes.isEmpty ? "" : "- Additional Notes: \(tripDetails.additionalNotes)")
        
        Please organize the packing list by categories (Clothing, Electronics, Toiletries, Documents, Accessories, Miscellaneous).
        For each item, consider the trip duration, weather, activities, and accommodation type.
        Prioritize essential items and adjust quantities based on laundry availability.
        """
        
        // Simulate API call with sample response
        try await Task.sleep(nanoseconds: 2 * 1_000_000_000) // 2 second delay
        
        // Increment the prompt count after successful generation
        incrementPromptCount()
        
        // Return sample response - Replace this with actual API call in production
        return """
        Clothing:
        - 7 T-shirts
        - 3 pairs of pants/jeans
        - 7 sets of underwear
        - 7 pairs of socks
        - 1 light jacket
        - 1 rain jacket
        - 2 pairs of shoes
        
        Electronics:
        - Phone and charger
        - Camera
        - Universal adapter
        - Power bank
        
        Toiletries:
        - Toothbrush and toothpaste
        - Shampoo and conditioner
        - Deodorant
        - Sunscreen
        
        Documents:
        - Passport
        - Travel insurance
        - Booking confirmations
        - Emergency contacts
        
        Accessories:
        - Sunglasses
        - Hat
        - Day bag/backpack
        - Water bottle
        
        Miscellaneous:
        - First aid kit
        - Travel pillow
        - Books/e-reader
        - Snacks
        """
    }
}
