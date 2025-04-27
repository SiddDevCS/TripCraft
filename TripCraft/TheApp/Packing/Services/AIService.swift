import Foundation
import SwiftUI

class AIService: ObservableObject {
    private let apiKey = "Key-here" // Replace with actual key in production
    private let openAIEndpoint = "https://api.openai.com/v1/chat/completions"
    private let model = "gpt-3.5-turbo" // Using cheaper model for cost savings
    
    private let userDefaultsUsageKey = "aiPackingListGenerationCount"
    private let userDefaultsLastResetKey = "aiPackingListLastReset"
    private let maxPromptsPerWeek = 3 // Limit number of requests per week
    
    @Published var isLoading = false
    
    // Generate a packing list using OpenAI API
    func generatePackingList(tripDetails: TripDetails) async throws -> String {
        guard getRemainingPrompts() > 0 else {
            throw AIError.promptLimitReached
        }
        
        let prompt = buildPrompt(from: tripDetails)
        let requestBody: [String: Any] = [
            "model": model,
            "messages": [
                ["role": "system", "content": "You are a helpful travel assistant who creates detailed packing lists."],
                ["role": "user", "content": prompt]
            ],
            "temperature": 0.7,
            "max_tokens": 800
        ]
        
        guard let url = URL(string: openAIEndpoint) else {
            throw AIError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        } catch {
            throw AIError.requestEncodingError
        }
        
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse, 
                  (200...299).contains(httpResponse.statusCode) else {
                throw AIError.serverError
            }
            
            let jsonResponse = try JSONDecoder().decode(OpenAIResponse.self, from: data)
            
            if let content = jsonResponse.choices.first?.message.content {
                incrementUsageCount()
                return content
            } else {
                throw AIError.emptyResponse
            }
        } catch {
            if let aiError = error as? AIError {
                throw aiError
            } else {
                throw AIError.networkError(error.localizedDescription)
            }
        }
    }
    
    // Get remaining number of prompts for the week
    func getRemainingPrompts() -> Int {
        checkAndResetWeeklyCount()
        let usedPrompts = UserDefaults.standard.integer(forKey: userDefaultsUsageKey)
        return max(0, maxPromptsPerWeek - usedPrompts)
    }
    
    // Get time until the counter resets
    func getTimeUntilReset() -> String {
        let now = Date()
        let lastReset = UserDefaults.standard.object(forKey: userDefaultsLastResetKey) as? Date ?? now
        
        // Calculate next reset date (one week from last reset)
        let nextReset = Calendar.current.date(byAdding: .weekOfYear, value: 1, to: lastReset) ?? now
        
        let components = Calendar.current.dateComponents([.day, .hour], from: now, to: nextReset)
        if let days = components.day, let hours = components.hour {
            if days > 0 {
                return "\(days)d \(hours)h"
            } else {
                return "\(hours) hours"
            }
        }
        
        return "soon"
    }
    
    // Get next reset date for display
    func getNextResetDate() -> Date {
        let lastReset = UserDefaults.standard.object(forKey: userDefaultsLastResetKey) as? Date ?? Date()
        return Calendar.current.date(byAdding: .weekOfYear, value: 1, to: lastReset) ?? Date()
    }
    
    // Check if user has used up all their weekly prompts
    var hasReachedWeeklyLimit: Bool {
        getRemainingPrompts() <= 0
    }
    
    // Private methods
    private func incrementUsageCount() {
        let currentCount = UserDefaults.standard.integer(forKey: userDefaultsUsageKey)
        UserDefaults.standard.set(currentCount + 1, forKey: userDefaultsUsageKey)
        
        if currentCount == 0 {
            // If this is the first use, set the reset date
            UserDefaults.standard.set(Date(), forKey: userDefaultsLastResetKey)
        }
    }
    
    private func checkAndResetWeeklyCount() {
        guard let lastResetDate = UserDefaults.standard.object(forKey: userDefaultsLastResetKey) as? Date else {
            // No reset date found, initialize with current date
            UserDefaults.standard.set(Date(), forKey: userDefaultsLastResetKey)
            UserDefaults.standard.set(0, forKey: userDefaultsUsageKey)
            return
        }
        
        let calendar = Calendar.current
        let now = Date()
        
        // Check if a week has passed since the last reset
        let components = calendar.dateComponents([.weekOfYear], from: lastResetDate, to: now)
        if let weeks = components.weekOfYear, weeks > 0 {
            // Reset the counter for a new week
            UserDefaults.standard.set(0, forKey: userDefaultsUsageKey)
            UserDefaults.standard.set(now, forKey: userDefaultsLastResetKey)
        }
    }
    
    private func buildPrompt(from tripDetails: TripDetails) -> String {
        let activitiesText = tripDetails.activities.map { $0.rawValue }.joined(separator: ", ")
        
        // Add more context to get better quality outputs
        let themeSuggestion = tripDetails.theme?.rawValue ?? "general" 
        
        return """
        Please create a concise packing list for a \(tripDetails.duration)-day trip to \(tripDetails.destination) with a \(themeSuggestion) theme.
        
        Trip Details:
        - Duration: \(tripDetails.duration) days
        - Climate: \(tripDetails.climate.rawValue)
        - Activities: \(activitiesText)
        - Accommodation: \(tripDetails.accommodation.rawValue)
        - Additional Information: \(tripDetails.additionalInfo ?? "None")
        
        Please organize the packing list by these categories:
        - Clothing
        - Electronics
        - Toiletries
        - Documents
        - Accessories
        - Miscellaneous
        
        For each category, list essential items, taking into account the trip duration, climate, and activities.
        Format each category with a header followed by bullet points for each item.
        Be comprehensive but concise (around 25-30 items total).
        """
    }
}

// Response model for OpenAI API
struct OpenAIResponse: Decodable {
    struct Choice: Decodable {
        struct Message: Decodable {
            let role: String
            let content: String
        }
        
        let message: Message
    }
    
    let choices: [Choice]
}

// Error types for AI service
enum AIError: Error, LocalizedError {
    case invalidURL
    case requestEncodingError
    case serverError
    case networkError(String)
    case emptyResponse
    case promptLimitReached
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .requestEncodingError:
            return "Failed to encode request"
        case .serverError:
            return "Server error"
        case .networkError(let message):
            return "Network error: \(message)"
        case .emptyResponse:
            return "Empty response from server"
        case .promptLimitReached:
            return "You've reached your weekly limit of 3 AI-generated packing lists"
        }
    }
} 
 
