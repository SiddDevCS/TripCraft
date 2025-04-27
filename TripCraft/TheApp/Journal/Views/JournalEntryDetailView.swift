//
//  JournalEntryDetailView.swift
//  TripCraft
//
//  Created by Siddharth Sehgal on 03/03/2025.
//

import SwiftUI
import PhotosUI
import MapKit

struct JournalEntryDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: JournalViewModel
    @State var entry: JournalEntry
    
    @State private var showingImagePicker = false
    @State private var showingLocationPicker = false
    @State private var showingDeleteConfirmation = false
    @State private var showingTagInput = false
    @State private var newTag = ""
    
    // App theme color
    private let themeColor = Color.blue.opacity(0.8)
    
    // Helper computed properties to simplify expressions
    private var titleCharacterColor: Color {
        entry.title.count > Int(Double(JournalManager.maxTitleLength) * 0.8) ? .orange : .secondary
    }
    
    private var contentCharacterColor: Color {
        entry.content.count > Int(Double(JournalManager.maxContentLength) * 0.9) ? .orange : .secondary
    }
    
    private var canAddMoreTags: Bool {
        entry.tags.count < JournalManager.maxTagsCount
    }
    
    private var canAddMoreImages: Bool {
        entry.imageNames.count < JournalManager.maxImagesCount
    }
    
    @Environment(\.colorScheme) private var colorScheme
    
    private var cardBackgroundColor: Color {
        colorScheme == .dark ? Color(.systemGray6) : Color.white
    }
    
    private var systemBackgroundColor: Color {
        colorScheme == .dark ? Color(.systemBackground) : Color(.systemGroupedBackground)
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Date and Weather Section
                dateAndWeatherSection
                
                // Title Field
                titleSection
                
                // Location Section
                locationSection
                
                // Tags Section
                tagsSection
                
                // Content Editor
                contentSection
                
                // Images Section
                imagesSection
            }
            .padding()
        }
        .background(systemBackgroundColor)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                trailingToolbarContent
            }
            
            ToolbarItem(placement: .navigationBarLeading) {
                leadingToolbarContent
            }
        }
        .sheet(isPresented: $showingImagePicker) {
            ImagePicker(imageNames: $entry.imageNames, viewModel: viewModel)
        }
        .sheet(isPresented: $showingLocationPicker) {
            LocationPicker(location: $entry.location)
        }
        .alert("Add Tag", isPresented: $showingTagInput) {
            TextField("Tag name", text: $newTag)
            Button("Cancel", role: .cancel) {}
            Button("Add") {
                if !newTag.isEmpty && !entry.tags.contains(newTag) && newTag.count <= JournalManager.maxTagLength {
                    entry.tags.append(newTag)
                    newTag = ""
                }
            }
        }
        .alert("Delete Entry", isPresented: $showingDeleteConfirmation) {
            Button("Delete", role: .destructive) {
                viewModel.deleteEntry(entry)
                dismiss()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Are you sure you want to delete this entry? This action cannot be undone.")
        }
    }
    
    // MARK: - View Sections
    
    private var dateAndWeatherSection: some View {
        HStack {
            DatePicker("", selection: $entry.date, displayedComponents: [.date])
                .labelsHidden()
                .tint(themeColor)
            
            Spacer()
            
            // Weather Picker
            Picker("Weather", selection: $entry.weather) {
                ForEach(Weather.allCases, id: \.self) { weather in
                    Label(weather.rawValue, systemImage: weather.icon)
                        .tag(weather)
                }
            }
            .pickerStyle(.menu)
            .tint(themeColor)
            
            // Mood Picker
            Picker("Mood", selection: $entry.mood) {
                ForEach(Mood.allCases, id: \.self) { mood in
                    Text(mood.icon + " " + mood.rawValue)
                        .tag(mood)
                }
            }
            .pickerStyle(.menu)
            .tint(themeColor)
        }
        .padding(.vertical, 6)
    }
    
    private var titleSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Title")
                .font(.headline)
                .foregroundColor(.secondary)
            
            TextField("Enter a title", text: $entry.title)
                .font(.title3)
                .fontWeight(.semibold)
                .padding()
                .background(cardBackgroundColor)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(themeColor.opacity(0.2), lineWidth: 1)
                )
            
            if entry.title.count > 0 {
                Text("\(entry.title.count)/\(JournalManager.maxTitleLength) characters")
                    .font(.caption)
                    .foregroundColor(titleCharacterColor)
            }
        }
    }
    
    private var locationSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Location")
                .font(.headline)
                .foregroundColor(.secondary)
            
            Button {
                showingLocationPicker = true
            } label: {
                locationButtonContent
            }
        }
    }
    
    private var locationButtonContent: some View {
        HStack {
            Image(systemName: "mappin.circle.fill")
                .foregroundColor(.red)
            if let location = entry.location {
                Text(location.name)
                    .foregroundColor(.primary)
            } else {
                Text("Add Location")
                    .foregroundColor(themeColor)
            }
            Spacer()
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(cardBackgroundColor)
    }
    
    private var tagsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Tags")
                    .font(.headline)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                if !entry.tags.isEmpty {
                    Text("\(entry.tags.count)/\(JournalManager.maxTagsCount)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            if entry.tags.isEmpty {
                emptyTagsButton
            } else {
                tagsList
            }
        }
    }
    
    private var emptyTagsButton: some View {
        Button {
            showingTagInput = true
        } label: {
            HStack {
                Image(systemName: "tag")
                    .foregroundColor(themeColor)
                Text("Add Tags")
                    .foregroundColor(themeColor)
                Spacer()
            }
            .padding()
            .background(cardBackgroundColor)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(themeColor, lineWidth: 1)
                    .background(themeColor.opacity(0.05))
            )
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }
    
    private var tagsList: some View {
        FlowLayout(spacing: 8) {
            ForEach(entry.tags, id: \.self) { tag in
                TagView(tag: tag, themeColor: themeColor) {
                    entry.tags.removeAll { $0 == tag }
                }
            }
            
            if canAddMoreTags {
                Button {
                    showingTagInput = true
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .foregroundColor(themeColor)
                        .font(.title3)
                }
                .buttonStyle(ScaleButtonStyleFlowLayout())
            }
        }
    }
    
    private var contentSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Journal Entry")
                    .font(.headline)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                if entry.content.count > 0 {
                    Text("\(entry.content.count)/\(JournalManager.maxContentLength) characters")
                        .font(.caption)
                        .foregroundColor(contentCharacterColor)
                }
            }
            
            TextEditor(text: $entry.content)
                .frame(minHeight: 200)
                .padding()
                .background(cardBackgroundColor)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(themeColor.opacity(0.2), lineWidth: 1)
                )
        }
    }
    
    private var imagesSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Photos")
                    .font(.headline)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                if !entry.imageNames.isEmpty {
                    Text("\(entry.imageNames.count)/\(JournalManager.maxImagesCount)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            if !entry.imageNames.isEmpty {
                PhotosGridViewJournal(imageNames: entry.imageNames, viewModel: viewModel, themeColor: themeColor) { imageName in
                    entry.imageNames.removeAll { $0 == imageName }
                }
            }
            
            if canAddMoreImages {
                addImagesButton
            }
        }
    }
    
    private var addImagesButton: some View {
        Button {
            showingImagePicker = true
        } label: {
            HStack {
                Image(systemName: "photo.on.rectangle.angled")
                    .foregroundColor(themeColor)
                Text("Add Photos")
                    .foregroundColor(themeColor)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(cardBackgroundColor)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(themeColor, lineWidth: 1)
                    .background(themeColor.opacity(0.05))
            )
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .buttonStyle(ScaleButtonStyleFlowLayout())
    }
    
    private var trailingToolbarContent: some View {
        Menu {
            Button {
                exportJournal()
            } label: {
                Label("Export", systemImage: "square.and.arrow.up")
            }
            
            Button(role: .destructive) {
                showingDeleteConfirmation = true
            } label: {
                Label("Delete", systemImage: "trash")
            }
        } label: {
            Image(systemName: "ellipsis.circle")
                .foregroundColor(themeColor)
        }
    }
    
    private var leadingToolbarContent: some View {
        Button("Done") {
            viewModel.saveEntry(entry)
            dismiss()
        }
        .foregroundColor(themeColor)
        .fontWeight(.semibold)
    }
    
    private func exportJournal() {
        // Create formatted text for export
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .long
        
        var exportText = """
        Title: \(entry.title)
        Date: \(dateFormatter.string(from: entry.date))
        Weather: \(entry.weather.rawValue)
        Mood: \(entry.mood.rawValue)
        
        """
        
        if let location = entry.location {
            exportText += "Location: \(location.name)\n\n"
        }
        
        if !entry.tags.isEmpty {
            exportText += "Tags: \(entry.tags.joined(separator: ", "))\n\n"
        }
        
        exportText += entry.content
        
        let activityVC = UIActivityViewController(activityItems: [exportText], applicationActivities: nil)
        UIApplication.shared.windows.first?.rootViewController?.present(activityVC, animated: true, completion: nil)
    }
}

struct PhotosGridViewJournal: View {
    let imageNames: [String]
    let viewModel: JournalViewModel
    let themeColor: Color
    let onDelete: (String) -> Void
    
    var body: some View {
        LazyVGrid(columns: [
            GridItem(.flexible()),
            GridItem(.flexible()),
            GridItem(.flexible())
        ], spacing: 12) {
            ForEach(imageNames, id: \.self) { imageName in
                if let image = viewModel.loadImage(named: imageName) {
                    ZStack(alignment: .topTrailing) {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFill()
                            .frame(height: 100)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.white, lineWidth: 1)
                            )
                            .shadow(color: Color.black.opacity(0.1), radius: 3, x: 0, y: 2)
                        
                        Button {
                            onDelete(imageName)
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 22))
                                .foregroundColor(.white)
                                .background(Circle().fill(Color.black.opacity(0.6)))
                        }
                        .padding(6)
                    }
                }
            }
        }
    }
}
