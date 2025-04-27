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
    
    // App theme color
    private let themeColor = Color.blue.opacity(0.8)
    
    @Environment(\.colorScheme) private var colorScheme
    
    private var cardBackgroundColor: Color {
        colorScheme == .dark ? Color(.systemGray6) : Color.white
    }
    
    private var systemBackgroundColor: Color {
        colorScheme == .dark ? Color(.systemBackground) : Color(.systemGroupedBackground)
    }
    
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
                                .font(.system(size: 50))
                                .foregroundColor(themeColor)
                                .padding(.bottom, 8)
                            
                            Text("No entries found")
                                .font(.headline)
                                .foregroundColor(themeColor)
                            
                            if !viewModel.searchText.isEmpty {
                                Text("Try different search terms")
                                    .foregroundColor(.secondary)
                            } else {
                                Text("Try a different filter")
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(cardBackgroundColor)
                    }
                } else {
                    // Existing journal entries view
                    VStack(spacing: 0) {
                        // Filter Picker
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                FilterButton(title: "All", filter: .all, selectedFilter: $selectedFilter, themeColor: themeColor)
                                FilterButton(title: "This Week", filter: .thisWeek, selectedFilter: $selectedFilter, themeColor: themeColor)
                                FilterButton(title: "This Month", filter: .thisMonth, selectedFilter: $selectedFilter, themeColor: themeColor)
                            }
                            .padding(.horizontal)
                        }
                        .padding(.vertical, 12)
                        .background(cardBackgroundColor)
                        
                        // Journal Entries
                        ScrollView {
                            LazyVStack(spacing: 16) {
                                ForEach(viewModel.filteredEntries) { entry in
                                    NavigationLink {
                                        JournalEntryDetailView(viewModel: viewModel, entry: entry)
                                    } label: {
                                        JournalEntryCard(entry: entry, viewModel: viewModel, themeColor: themeColor)
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                            }
                            .padding()
                        }
                        .background(systemBackgroundColor)
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
                                    .foregroundColor(themeColor)
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
    let themeColor: Color
    
    var body: some View {
        Button {
            selectedFilter = filter
        } label: {
            Text(title)
                .fontWeight(selectedFilter == filter ? .semibold : .regular)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(selectedFilter == filter ? themeColor : Color.gray.opacity(0.1))
                )
                .foregroundColor(selectedFilter == filter ? .white : .primary)
                .animation(.easeInOut(duration: 0.2), value: selectedFilter)
        }
        .buttonStyle(ScaleButtonStyleFlowLayout())
    }
}

struct JournalEntryCard: View {
    let entry: JournalEntry
    let viewModel: JournalViewModel
    let themeColor: Color
    
    @Environment(\.colorScheme) private var colorScheme
    
    private var cardBackgroundColor: Color {
        colorScheme == .dark ? Color(.systemGray6) : Color.white
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            // Header with date and mood
            HStack {
                Text(entry.date.formatted(.dateTime.day().month(.wide)))
                    .font(.subheadline)
                    .foregroundColor(themeColor)
                Spacer()
                HStack(spacing: 8) {
                    Text(entry.mood.icon)
                    Image(systemName: entry.weather.icon)
                        .foregroundColor(.orange)
                }
            }
            
            // Title
            Text(entry.title)
                .font(.title3)
                .fontWeight(.bold)
                .lineLimit(2)
                .padding(.top, 2)
            
            // Location if available
            if let location = entry.location {
                HStack {
                    Image(systemName: "mappin.circle.fill")
                        .foregroundColor(.red)
                    Text(location.name)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.top, 1)
            }
            
            // Content Preview
            Text(entry.content)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .lineLimit(3)
                .padding(.top, 1)
            
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
                                    .clipShape(RoundedRectangle(cornerRadius: 10))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 10)
                                            .stroke(Color.white, lineWidth: 1)
                                    )
                                    .shadow(color: Color.black.opacity(0.1), radius: 2, x: 0, y: 1)
                            }
                        }
                        
                        if entry.imageNames.count > 3 {
                            ZStack {
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(themeColor.opacity(0.2))
                                    .frame(width: 80, height: 80)
                                
                                Text("+\(entry.imageNames.count - 3)")
                                    .font(.title3)
                                    .fontWeight(.bold)
                                    .foregroundColor(themeColor)
                            }
                        }
                    }
                }
                .padding(.top, 4)
            }
            
            // Tags
            if !entry.tags.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(entry.tags, id: \.self) { tag in
                            Text("#\(tag)")
                                .font(.caption)
                                .fontWeight(.medium)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(themeColor.opacity(0.1))
                                .foregroundColor(themeColor)
                                .cornerRadius(8)
                        }
                    }
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(cardBackgroundColor)
                .shadow(color: colorScheme == .dark ? Color.black.opacity(0.3) : Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(themeColor.opacity(colorScheme == .dark ? 0.2 : 0.1), lineWidth: 1)
        )
    }
}
