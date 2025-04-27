//
//  JournalManager.swift
//  TripCraft
//
//  Created by Siddharth Sehgal on 07/03/2025.
//

import Foundation
import UIKit

class JournalManager: ObservableObject {
    static let shared = JournalManager()
    @Published var entries: [JournalEntry] = []
    
    // Character limits
    static let maxTitleLength = 100
    static let maxContentLength = 5000
    static let maxTagLength = 30
    static let maxTagsCount = 10
    static let maxImagesCount = 10
    
    private let entriesKey = "journalEntries"
    private let fileManager = FileManager.default
    private let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    
    init() {
        loadEntries()
    }
    
    func saveEntry(_ entry: JournalEntry) throws {
        // Validate entry
        try validateEntry(entry)
        
        if let index = entries.firstIndex(where: { $0.id == entry.id }) {
            entries[index] = entry
        } else {
            entries.append(entry)
        }
        saveEntries()
    }
    
    func deleteEntry(_ entry: JournalEntry) {
        // Delete associated images
        for imageName in entry.imageNames {
            deleteImage(named: imageName)
        }
        
        entries.removeAll { $0.id == entry.id }
        saveEntries()
    }
    
    // MARK: - Image Handling
    func saveImage(_ image: UIImage) -> String? {
        let fileName = UUID().uuidString + ".jpg"
        let fileURL = documentsPath.appendingPathComponent(fileName)
        
        if let data = image.jpegData(compressionQuality: 0.8) {
            try? data.write(to: fileURL)
            return fileName
        }
        return nil
    }
    
    func loadImage(named fileName: String) -> UIImage? {
        let fileURL = documentsPath.appendingPathComponent(fileName)
        return UIImage(contentsOfFile: fileURL.path)
    }
    
    func deleteImage(named fileName: String) {
        let fileURL = documentsPath.appendingPathComponent(fileName)
        try? fileManager.removeItem(at: fileURL)
    }
    
    // MARK: - Private Methods
    private func loadEntries() {
        if let data = UserDefaults.standard.data(forKey: entriesKey),
           let decoded = try? JSONDecoder().decode([JournalEntry].self, from: data) {
            entries = decoded
        }
    }
    
    private func saveEntries() {
        if let encoded = try? JSONEncoder().encode(entries) {
            UserDefaults.standard.set(encoded, forKey: entriesKey)
        }
    }
    
    private func validateEntry(_ entry: JournalEntry) throws {
        if entry.title.count > Self.maxTitleLength {
            throw JournalError.titleTooLong
        }
        
        if entry.content.count > Self.maxContentLength {
            throw JournalError.contentTooLong
        }
        
        if entry.tags.count > Self.maxTagsCount {
            throw JournalError.tooManyTags
        }
        
        if let invalidTag = entry.tags.first(where: { $0.count > Self.maxTagLength }) {
            throw JournalError.tagTooLong(tag: invalidTag)
        }
        
        if entry.imageNames.count > Self.maxImagesCount {
            throw JournalError.tooManyImages
        }
    }
}

enum JournalError: LocalizedError {
    case titleTooLong
    case contentTooLong
    case tooManyTags
    case tagTooLong(tag: String)
    case tooManyImages
    
    var errorDescription: String? {
        switch self {
        case .titleTooLong:
            return "Title cannot exceed \(JournalManager.maxTitleLength) characters"
        case .contentTooLong:
            return "Content cannot exceed \(JournalManager.maxContentLength) characters"
        case .tooManyTags:
            return "Cannot add more than \(JournalManager.maxTagsCount) tags"
        case .tagTooLong(let tag):
            return "Tag '\(tag)' is too long. Maximum length is \(JournalManager.maxTagLength) characters"
        case .tooManyImages:
            return "Cannot add more than \(JournalManager.maxImagesCount) images"
        }
    }
}
