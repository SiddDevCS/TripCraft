//
//  AIAssistantView.swift
//  TripCraft
//
//  Created by Siddharth Sehgal on 06/03/2025.
//

import SwiftUI

struct AIAssistantView: View {
    @ObservedObject var viewModel: PackingListViewModel
    @Environment(\.dismiss) private var dismiss
    @StateObject private var aiService = AIService()
    
    // Essential Details
    @State private var destination = ""
    @State private var duration = 7
    @State private var season = "Summer"
    @State private var activities: Set<String> = []
    
    // Trip Type & Accommodation
    @State private var tripType = TripType.leisure
    @State private var accommodation = AccommodationType.hotel
    @State private var transportation = TransportationType.plane
    
    // Additional Details
    @State private var budget = "Mid-range"
    @State private var specialNeeds = ""
    @State private var childrenCount = 0
    @State private var hasLaundry = false
    @State private var additionalNotes = ""
    
    // UI State
    @State private var showingAIResponse = false
    @State private var generatedItems: [PackingItem] = []
    
    // Constants
    private let seasons = ["Spring", "Summer", "Fall", "Winter"]
    private let budgetOptions = ["Budget", "Mid-range", "Luxury"]
    
    var body: some View {
        NavigationView {
            ZStack {
                Form {
                    Section(header: Text("Essential Details")) {
                        TextField("Destination", text: $destination)
                            .autocapitalization(.words)
                            .required()
                        
                        Stepper("Duration: \(duration) days", value: $duration, in: 1...30)
                        
                        Picker("Season", selection: $season) {
                            ForEach(seasons, id: \.self) { season in
                                Text(season)
                            }
                        }
                        
                        NavigationLink(destination: ActivitySelectionView(selectedActivities: $activities)) {
                            HStack {
                                Text("Activities")
                                Spacer()
                                Text(activities.isEmpty ? "None selected" : "\(activities.count) selected")
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    
                    Section(header: Text("Trip Type & Accommodation")) {
                        Picker("Trip Type", selection: $tripType) {
                            ForEach(TripType.allCases, id: \.self) { type in
                                Text(type.rawValue)
                            }
                        }
                        
                        Picker("Accommodation", selection: $accommodation) {
                            ForEach(AccommodationType.allCases, id: \.self) { type in
                                Text(type.rawValue)
                            }
                        }
                        
                        Picker("Transportation", selection: $transportation) {
                            ForEach(TransportationType.allCases, id: \.self) { type in
                                Text(type.rawValue)
                            }
                        }
                    }
                    
                    Section(header: Text("Additional Details")) {
                        Picker("Budget Level", selection: $budget) {
                            ForEach(budgetOptions, id: \.self) { option in
                                Text(option)
                            }
                        }
                        
                        Stepper("Children: \(childrenCount)", value: $childrenCount, in: 0...10)
                        
                        Toggle("Access to Laundry", isOn: $hasLaundry)
                        
                        TextField("Special Needs/Requirements", text: $specialNeeds)
                            .textInputAutocapitalization(.sentences)
                    }
                    
                    Section(header: Text("Additional Notes (Optional)")) {
                        TextEditor(text: $additionalNotes)
                            .frame(height: 100)
                    }
                    
                    // AI Usage Status Section
                    Section {
                        HStack {
                            Image(systemName: "number.circle.fill")
                            Text("Remaining Prompts: \(aiService.getRemainingPrompts())")
                        }
                        
                        HStack {
                            Image(systemName: "clock.fill")
                            Text("Next Reset: \(aiService.getTimeUntilReset())")
                        }
                        
                        HStack {
                            Image(systemName: "character.cursor.ibeam")
                            Text("Max Characters: 500")
                        }
                    }
                    
                    Section {
                        Button(action: generateList) {
                            HStack {
                                Image(systemName: "wand.and.stars")
                                Text("Generate AI Packing List")
                                    .font(.headline)
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(isGenerateButtonEnabled ? Color.blue : Color.gray)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                        }
                        .disabled(!isGenerateButtonEnabled)
                    }
                }
                .navigationTitle("AI Packing Assistant")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Cancel") { dismiss() }
                    }
                }
                .disabled(aiService.isGenerating)
                
                if aiService.isGenerating {
                    LoadingView(message: "Generating your personalized packing list...")
                }
            }
        }
        .sheet(isPresented: $showingAIResponse) {
            NavigationView {
                AIResponseView(viewModel: viewModel, aiSuggestions: generatedItems)
                    .toolbar {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button("Done") {
                                showingAIResponse = false
                                dismiss()
                            }
                        }
                    }
            }
        }
        .alert("Error", isPresented: .constant(aiService.error != nil)) {
            Button("OK") { aiService.error = nil }
        } message: {
            Text(aiService.error?.localizedDescription ?? "An error occurred")
        }
    }
    
    // MARK: - Computed Properties
    
    private var isGenerateButtonEnabled: Bool {
        !destination.isEmpty &&
        !activities.isEmpty &&
        !aiService.isGenerating &&
        aiService.getRemainingPrompts() > 0 &&
        totalCharacterCount <= 500
    }
    
    private var totalCharacterCount: Int {
        destination.count +
        season.count +
        String(duration).count +
        activities.joined(separator: ", ").count +
        tripType.rawValue.count +
        accommodation.rawValue.count +
        transportation.rawValue.count +
        budget.count +
        specialNeeds.count +
        String(childrenCount).count +
        additionalNotes.count
    }
    
    // MARK: - Functions
    
    private func generateList() {
        let tripDetails = TripDetails(
            destination: destination,
            duration: duration,
            season: season,
            activities: activities,
            tripType: tripType,
            accommodation: accommodation,
            transportation: transportation,
            budget: budget,
            specialNeeds: specialNeeds.isEmpty ? nil : specialNeeds,
            childrenCount: childrenCount,
            hasLaundry: hasLaundry,
            additionalNotes: additionalNotes
        )
        
        Task {
            await MainActor.run { aiService.isGenerating = true }
            
            do {
                let response = try await aiService.generatePackingList(tripDetails: tripDetails)
                
                await MainActor.run {
                    generatedItems = viewModel.parseAIResponse(response)
                    aiService.isGenerating = false
                    
                    if generatedItems.isEmpty {
                        aiService.error = NSError(
                            domain: "AIService",
                            code: -1,
                            userInfo: [NSLocalizedDescriptionKey: "No items were generated"]
                        )
                    } else {
                        showingAIResponse = true
                    }
                }
            } catch {
                await MainActor.run {
                    aiService.error = error
                    aiService.isGenerating = false
                }
            }
        }
    }
}
