//
//  JournalView.swift
//  TripCraft
//
//  Created by Siddharth Sehgal on 03/03/2025.
//

import SwiftUI

enum JournalFilter {
    case all, thisWeek, thisMonth, favorites
}

struct JournalView: View {
    @StateObject private var viewModel = JournalViewModel()
    @State private var showingNewEntry = false
    @State private var selectedFilter: JournalFilter = .all
    
    var body: some View {
            Group {
                if viewModel.filteredEntries.isEmpty {
                    if viewModel.searchText.isEmpty && selectedFilter == .all {
                        EmptyJournalView(onCreateEntry: {
                            showingNewEntry = true
                        })
                    } else {
                        // Show "no results" for search/filter
                        VStack(spacing: 12) {
                            Image(systemName: "magnifyingglass")
                                .font(.system(size: 40))
                                .foregroundColor(.secondary)
                            
                            Text("No entries found")
                                .font(.headline)
                            
                            if !viewModel.searchText.isEmpty {
                                Text("Try different search terms")
                                    .foregroundColor(.secondary)
                            } else {
                                Text("Try a different filter")
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding()
                    }
                } else {
                    // Existing journal entries view
                    VStack(spacing: 0) {
                        // Filter Picker
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                FilterButton(title: "All", filter: .all, selectedFilter: $selectedFilter)
                                FilterButton(title: "This Week", filter: .thisWeek, selectedFilter: $selectedFilter)
                                FilterButton(title: "This Month", filter: .thisMonth, selectedFilter: $selectedFilter)
                            }
                            .padding(.horizontal)
                        }
                        .padding(.vertical, 8)
                        
                        // Journal Entries
                        ScrollView {
                            LazyVStack(spacing: 16) {
                                ForEach(viewModel.filteredEntries) { entry in
                                    NavigationLink {
                                        JournalEntryDetailView(viewModel: viewModel, entry: entry)
                                    } label: {
                                        JournalEntryCard(entry: entry, viewModel: viewModel)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                            }
                            .padding()
                        }
                    }
                }
            }
            .navigationTitle("Travel Journal")
                    .searchable(
                        text: $viewModel.searchText,
                        prompt: "Search entries..."
                    )
                    .toolbar {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button {
                                showingNewEntry = true
                            } label: {
                                Image(systemName: "plus.circle.fill")
                                    .font(.title3)
                            }
                        }
                    }
                    .sheet(isPresented: $showingNewEntry) {
                        NavigationView {
                            JournalEntryDetailView(
                                viewModel: viewModel,
                                entry: JournalEntry(
                                    title: "",
                                    date: Date(),
                                    content: "",
                                    mood: .neutral,
                                    weather: .sunny
                                )
                            )
                        }
                    }
    }
}

struct FilterButton: View {
    let title: String
    let filter: JournalFilter
    @Binding var selectedFilter: JournalFilter
    
    var body: some View {
        Button {
            selectedFilter = filter
        } label: {
            Text(title)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(selectedFilter == filter ? Color.blue : Color.gray.opacity(0.1))
                )
                .foregroundColor(selectedFilter == filter ? .white : .primary)
        }
    }
}

struct JournalEntryCard: View {
    let entry: JournalEntry
    let viewModel: JournalViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header with date and mood
            HStack {
                Text(entry.date.formatted(.dateTime.day().month(.wide)))
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Spacer()
                HStack(spacing: 8) {
                    Text(entry.mood.icon)
                    Image(systemName: entry.weather.icon)
                        .foregroundColor(.orange)
                }
            }
            
            // Title
            Text(entry.title)
                .font(.title2)
                .fontWeight(.bold)
                .lineLimit(2)
            
            // Location if available
            if let location = entry.location {
                HStack {
                    Image(systemName: "mappin.circle.fill")
                        .foregroundColor(.red)
                    Text(location.name)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
            
            // Content Preview
            Text(entry.content)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .lineLimit(3)
            
            // Tags
            if !entry.tags.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(entry.tags, id: \.self) { tag in
                            Text("#\(tag)")
                                .font(.caption)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.blue.opacity(0.1))
                                .foregroundColor(.blue)
                                .cornerRadius(8)
                        }
                    }
                }
            }
            
            // Images Preview
            if !entry.imageNames.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(entry.imageNames.prefix(3), id: \.self) { imageName in
                            if let image = viewModel.loadImage(named: imageName) {
                                Image(uiImage: image)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 80, height: 80)
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                            }
                        }
                        if entry.imageNames.count > 3 {
                            ZStack {
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(.ultraThinMaterial)
                                    .frame(width: 80, height: 80)
                                Text("+\(entry.imageNames.count - 3)")
                                    .font(.title3)
                                    .fontWeight(.semibold)
                            }
                        }
                    }
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
        )
    }
}
