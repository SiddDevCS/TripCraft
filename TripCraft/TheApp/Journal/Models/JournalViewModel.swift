//
//  JournalViewModel.swift
//  TripCraft
//
//  Created by Siddharth Sehgal on 07/03/2025.
//

import SwiftUI
import CoreLocation

class JournalViewModel: ObservableObject {
    @Published var entries: [JournalEntry] = []
    @Published var searchText = ""
    @Published var selectedFilter: JournalFilter = .all
    @Published var error: JournalError?
    @Published var currentEntry: JournalEntry?
    
    private let journalManager = JournalManager.shared
    
    enum JournalFilter {
        case all, thisWeek, thisMonth, favorites
    }
    
    init() {
        loadEntries()
    }
    
    var filteredEntries: [JournalEntry] {
        var filtered = entries
        
        if !searchText.isEmpty {
            filtered = filtered.filter {
                $0.title.localizedCaseInsensitiveContains(searchText) ||
                $0.content.localizedCaseInsensitiveContains(searchText) ||
                $0.tags.contains { $0.localizedCaseInsensitiveContains(searchText) }
            }
        }
        
        switch selectedFilter {
        case .thisWeek:
            let oneWeekAgo = Calendar.current.date(byAdding: .day, value: -7, to: Date())!
            filtered = filtered.filter { $0.date >= oneWeekAgo }
        case .thisMonth:
            let oneMonthAgo = Calendar.current.date(byAdding: .month, value: -1, to: Date())!
            filtered = filtered.filter { $0.date >= oneMonthAgo }
        default:
            break
        }
        
        return filtered.sorted { $0.date > $1.date }
    }
    
    // Character limit computed properties
    var remainingTitleCharacters: Int {
        JournalManager.maxTitleLength - (currentEntry?.title.count ?? 0)
    }
    
    var remainingContentCharacters: Int {
        JournalManager.maxContentLength - (currentEntry?.content.count ?? 0)
    }
    
    var remainingTags: Int {
        JournalManager.maxTagsCount - (currentEntry?.tags.count ?? 0)
    }
    
    var remainingImages: Int {
        JournalManager.maxImagesCount - (currentEntry?.imageNames.count ?? 0)
    }
    
    func loadEntries() {
        entries = journalManager.entries
    }
    
    func saveEntry(_ entry: JournalEntry) {
        do {
            try journalManager.saveEntry(entry)
            loadEntries()
            error = nil
        } catch let journalError as JournalError {
            error = journalError
        } catch {
            print("Unexpected error: \(error)")
        }
    }
    
    func deleteEntry(_ entry: JournalEntry) {
        journalManager.deleteEntry(entry)
        loadEntries()
    }
    
    func saveImage(_ image: UIImage) -> String? {
        journalManager.saveImage(image)
    }
    
    func loadImage(named fileName: String) -> UIImage? {
        journalManager.loadImage(named: fileName)
    }
    
    func canAddTag(_ tag: String) -> Bool {
        guard let entry = currentEntry else { return false }
        return entry.tags.count < JournalManager.maxTagsCount &&
               tag.count <= JournalManager.maxTagLength
    }
    
    func canAddImage() -> Bool {
        guard let entry = currentEntry else { return false }
        return entry.imageNames.count < JournalManager.maxImagesCount
    }
}
