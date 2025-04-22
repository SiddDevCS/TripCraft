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
                // Title Section
                Section {
                    TextField("Title", text: $entry.title)
                    HStack {
                        Text("\(viewModel.remainingTitleCharacters) characters remaining")
                            .font(.caption)
                            .foregroundColor(viewModel.remainingTitleCharacters < 10 ? .red : .secondary)
                        Spacer()
                    }
                } header: {
                    Text("Title")
                }
                
                // Content Section
                Section {
                    TextEditor(text: $entry.content)
                        .frame(minHeight: 100)
                    HStack {
                        Text("\(viewModel.remainingContentCharacters) characters remaining")
                            .font(.caption)
                            .foregroundColor(viewModel.remainingContentCharacters < 100 ? .red : .secondary)
                        Spacer()
                    }
                } header: {
                    Text("Content")
                }
                
                // Mood & Weather Section
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
                
                // Location Section
                Section {
                    Button(entry.location == nil ? "Add Location" : entry.location?.name ?? "") {
                        showingLocationPicker = true
                    }
                }
                
                // Tags Section
                Section {
                    FlowLayout(spacing: 8) {
                        ForEach(entry.tags, id: \.self) { tag in
                            TagView(tag: tag) {
                                entry.tags.removeAll { $0 == tag }
                            }
                        }
                    }
                    
                    if viewModel.remainingTags > 0 {
                        HStack {
                            TextField("Add tag", text: $newTag)
                            Button("Add") {
                                if !newTag.isEmpty && viewModel.canAddTag(newTag) {
                                    entry.tags.append(newTag)
                                    newTag = ""
                                }
                            }
                            .disabled(newTag.isEmpty || !viewModel.canAddTag(newTag))
                        }
                    }
                    
                    Text("\(viewModel.remainingTags) tags remaining")
                        .font(.caption)
                        .foregroundColor(viewModel.remainingTags < 2 ? .red : .secondary)
                } header: {
                    Text("Tags")
                }
                
                // Photos Section
                Section {
                    if !entry.imageNames.isEmpty {
                        PhotosGridView(
                            imageNames: entry.imageNames,
                            viewModel: viewModel
                        ) { imageName in
                            entry.imageNames.removeAll { $0 == imageName }
                        }
                    }
                    
                    if viewModel.canAddImage() {
                        Button("Add Photos") {
                            showingImagePicker = true
                        }
                    }
                    
                    Text("\(viewModel.remainingImages) photos remaining")
                        .font(.caption)
                        .foregroundColor(viewModel.remainingImages < 2 ? .red : .secondary)
                } header: {
                    Text("Photos")
                }
            }
            .navigationTitle(entry.id == nil ? "New Entry" : "Edit Entry")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        viewModel.saveEntry(entry)
                        if viewModel.error == nil {
                            dismiss()
                        }
                    }
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
}

