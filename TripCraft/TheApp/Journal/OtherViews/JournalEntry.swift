//
//  JournalEntry.swift
//  TripCraft
//
//  Created by Siddharth Sehgal on 03/03/2025.
//

import SwiftUI
import UIKit

struct JournalEntry: Identifiable, Codable {
    let id: UUID
    var title: String
    var date: Date
    var content: String
    var location: Location?
    var mood: Mood
    var weather: Weather
    var tags: [String]
    var imageNames: [String] // Store image file names instead of UIImages
    
    init(
        id: UUID = UUID(),
        title: String,
        date: Date,
        content: String,
        location: Location? = nil,
        mood: Mood = .neutral,
        weather: Weather = .sunny,
        tags: [String] = [],
        imageNames: [String] = []
    ) {
        self.id = id
        self.title = title
        self.date = date
        self.content = content
        self.location = location
        self.mood = mood
        self.weather = weather
        self.tags = tags
        self.imageNames = imageNames
    }
}

struct Location: Codable {
    var name: String
    var latitude: Double
    var longitude: Double
}

enum Mood: String, Codable, CaseIterable {
    case happy = "Happy"
    case excited = "Excited"
    case relaxed = "Relaxed"
    case neutral = "Neutral"
    case tired = "Tired"
    case sad = "Sad"
    
    var icon: String {
        switch self {
        case .happy: return "😊"
        case .excited: return "🤩"
        case .relaxed: return "😌"
        case .neutral: return "😐"
        case .tired: return "😴"
        case .sad: return "😔"
        }
    }
}

enum Weather: String, Codable, CaseIterable {
    case sunny = "Sunny"
    case cloudy = "Cloudy"
    case rainy = "Rainy"
    case snowy = "Snowy"
    case stormy = "Stormy"
    
    var icon: String {
        switch self {
        case .sunny: return "sun.max.fill"
        case .cloudy: return "cloud.fill"
        case .rainy: return "cloud.rain.fill"
        case .snowy: return "snow"
        case .stormy: return "cloud.bolt.fill"
        }
    }
}
