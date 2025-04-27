//
//  JournalEntryView.swift
//  TripCraft
//
//  Created by Siddharth Sehgal on 10/03/2025.
//

import SwiftUI
import PhotosUI

struct JournalEntryView: View {
    @ObservedObject var viewModel: JournalViewModel
    @Environment(\.dismiss) private var dismiss
    
    @State private var entry: JournalEntry
    @State private var showingImagePicker = false
    @State private var showingLocationPicker = false
    @State private var newTag = ""
    
    // App theme color
    private let themeColor = Color.blue.opacity(0.8)
    
    // Helper computed properties
    private var titleColor: Color {
        viewModel.remainingTitleCharacters < 10 ? .red : .secondary
    }
    
    private var contentColor: Color {
        viewModel.remainingContentCharacters < 100 ? .red : .secondary
    }
    
    private var tagsColor: Color {
        viewModel.remainingTags < 2 ? .red : .secondary
    }
    
    private var photosColor: Color {
        viewModel.remainingImages < 2 ? .red : .secondary
    }
    
    @Environment(\.colorScheme) private var colorScheme
    
    init(viewModel: JournalViewModel, entry: JournalEntry? = nil) {
        self.viewModel = viewModel
        self._entry = State(initialValue: entry ?? JournalEntry(
            title: "",
            date: Date(),
            content: "",
            mood: .neutral,
            weather: .sunny,
            tags: [],
            imageNames: []
        ))
    }
    
    var body: some View {
        NavigationView {
            Form {
                titleSection
                contentSection
                moodWeatherSection
                locationSection
                tagsSection
                photosSection
            }
            .navigationTitle(entry.id == UUID.init() ? "New Entry" : "Edit Entry")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    cancelButton
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    saveButton
                }
            }
            .sheet(isPresented: $showingImagePicker) {
                ImagePicker(imageNames: $entry.imageNames, viewModel: viewModel)
            }
            .sheet(isPresented: $showingLocationPicker) {
                LocationPicker(location: $entry.location)
            }
            .alert("Error", isPresented: .constant(viewModel.error != nil)) {
                Button("OK") { viewModel.error = nil }
            } message: {
                Text(viewModel.error?.localizedDescription ?? "")
            }
        }
    }
    
    // MARK: - View Sections
    
    private var titleSection: some View {
        Section {
            TextField("Title", text: $entry.title)
            HStack {
                Text("\(viewModel.remainingTitleCharacters) characters remaining")
                    .font(.caption)
                    .foregroundColor(titleColor)
                Spacer()
            }
        } header: {
            Text("Title")
        }
    }
    
    private var contentSection: some View {
        Section {
            TextEditor(text: $entry.content)
                .frame(minHeight: 100)
            HStack {
                Text("\(viewModel.remainingContentCharacters) characters remaining")
                    .font(.caption)
                    .foregroundColor(contentColor)
                Spacer()
            }
        } header: {
            Text("Content")
        }
    }
    
    private var moodWeatherSection: some View {
        Section {
            Picker("Mood", selection: $entry.mood) {
                ForEach(Mood.allCases, id: \.self) { mood in
                    Text("\(mood.icon) \(mood.rawValue)").tag(mood)
                }
            }
            
            Picker("Weather", selection: $entry.weather) {
                ForEach(Weather.allCases, id: \.self) { weather in
                    Label(weather.rawValue, systemImage: weather.icon).tag(weather)
                }
            }
        }
    }
    
    private var locationSection: some View {
        Section {
            Button(entry.location == nil ? "Add Location" : entry.location?.name ?? "") {
                showingLocationPicker = true
            }
            .foregroundColor(entry.location == nil ? themeColor : .primary)
        }
    }
    
    private var tagsSection: some View {
        Section {
            tagsFlowLayout
            
            if viewModel.remainingTags > 0 {
                addTagRow
            }
            
            Text("\(viewModel.remainingTags) tags remaining")
                .font(.caption)
                .foregroundColor(tagsColor)
        } header: {
            Text("Tags")
        }
    }
    
    private var tagsFlowLayout: some View {
        FlowLayout(spacing: 8) {
            ForEach(entry.tags, id: \.self) { tag in
                TagView(tag: tag, themeColor: themeColor) {
                    entry.tags.removeAll { $0 == tag }
                }
            }
        }
    }
    
    private var addTagRow: some View {
        HStack {
            TextField("Add tag", text: $newTag)
            Button("Add") {
                if !newTag.isEmpty && viewModel.canAddTag(newTag) {
                    entry.tags.append(newTag)
                    newTag = ""
                }
            }
            .foregroundColor(themeColor)
            .disabled(newTag.isEmpty || !viewModel.canAddTag(newTag))
        }
    }
    
    private var photosSection: some View {
        Section {
            if !entry.imageNames.isEmpty {
                PhotosGridViewJournal(
                    imageNames: entry.imageNames,
                    viewModel: viewModel,
                    themeColor: themeColor
                ) { imageName in
                    entry.imageNames.removeAll { $0 == imageName }
                }
            }
            
            if viewModel.canAddImage() {
                Button("Add Photos") {
                    showingImagePicker = true
                }
                .foregroundColor(themeColor)
            }
            
            Text("\(viewModel.remainingImages) photos remaining")
                .font(.caption)
                .foregroundColor(photosColor)
        } header: {
            Text("Photos")
        }
    }
    
    private var cancelButton: some View {
        Button("Cancel") { 
            dismiss() 
        }
        .foregroundColor(themeColor)
    }
    
    private var saveButton: some View {
        Button("Save") {
            viewModel.saveEntry(entry)
            if viewModel.error == nil {
                dismiss()
            }
        }
        .foregroundColor(themeColor)
    }
}

