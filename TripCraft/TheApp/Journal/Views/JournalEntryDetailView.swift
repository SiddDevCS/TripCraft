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
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Date and Weather Section
                HStack {
                    DatePicker("", selection: $entry.date, displayedComponents: [.date])
                        .labelsHidden()
                    
                    Spacer()
                    
                    // Weather Picker
                    Picker("Weather", selection: $entry.weather) {
                        ForEach(Weather.allCases, id: \.self) { weather in
                            Label(weather.rawValue, systemImage: weather.icon)
                                .tag(weather)
                        }
                    }
                    .pickerStyle(.menu)
                    
                    // Mood Picker
                    Picker("Mood", selection: $entry.mood) {
                        ForEach(Mood.allCases, id: \.self) { mood in
                            Text(mood.icon + " " + mood.rawValue)
                                .tag(mood)
                        }
                    }
                    .pickerStyle(.menu)
                }
                
                // Title Field
                TextField("Title", text: $entry.title)
                    .font(.title)
                    .fontWeight(.bold)
                    .textFieldStyle(.plain)
                
                // Location Section
                Button {
                    showingLocationPicker = true
                } label: {
                    HStack {
                        Image(systemName: "mappin.circle.fill")
                            .foregroundColor(.red)
                        if let location = entry.location {
                            Text(location.name)
                        } else {
                            Text("Add Location")
                        }
                        Spacer()
                    }
                }
                .foregroundColor(.primary)
                
                // Tags Section
                VStack(alignment: .leading) {
                    Text("Tags")
                        .font(.headline)
                    
                    FlowLayout(spacing: 8) {
                        ForEach(entry.tags, id: \.self) { tag in
                            TagView(tag: tag) {
                                entry.tags.removeAll { $0 == tag }
                            }
                        }
                        
                        Button {
                            showingTagInput = true
                        } label: {
                            Image(systemName: "plus.circle.fill")
                                .foregroundColor(.blue)
                        }
                    }
                }
                
                // Content Editor
                Text("Journal Entry")
                    .font(.headline)
                TextEditor(text: $entry.content)
                    .frame(minHeight: 200)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(.systemGray6))
                    )
                
                // Images Section
                VStack(alignment: .leading) {
                    Text("Photos")
                        .font(.headline)
                    
                    if !entry.imageNames.isEmpty {
                        PhotosGridView(imageNames: entry.imageNames, viewModel: viewModel) { imageName in
                            entry.imageNames.removeAll { $0 == imageName }
                        }
                    }
                    
                    Button {
                        showingImagePicker = true
                    } label: {
                        HStack {
                            Image(systemName: "photo.on.rectangle.angled")
                            Text("Add Photos")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.blue, lineWidth: 1)
                        )
                    }
                }
            }
            .padding()
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
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
                }
            }
            
            ToolbarItem(placement: .navigationBarLeading) {
                Button("Done") {
                    viewModel.saveEntry(entry)
                    dismiss()
                }
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
                if !newTag.isEmpty && !entry.tags.contains(newTag) {
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
            exportText += "Location: \(location.name)\n"
        }
        
        if !entry.tags.isEmpty {
            exportText += "\nTags: \(entry.tags.joined(separator: ", "))\n"
        }
        
        exportText += "\n\(entry.content)"
        
        let activityVC = UIActivityViewController(
            activityItems: [exportText],
            applicationActivities: nil
        )
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first,
           let rootVC = window.rootViewController {
            rootVC.present(activityVC, animated: true)
        }
    }
}
