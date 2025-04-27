import SwiftUI
import Foundation

struct AIAssistantView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: PackingListViewModel
    @StateObject private var aiService = AIService()
    let tripId: UUID?
    
    @State private var currentStep = 0
    @State private var destination = ""
    @State private var duration = 7
    @State private var climate = TripDetails.Climate.temperate
    @State private var selectedActivities: Set<TripDetails.Activity> = []
    @State private var accommodation = TripDetails.Accommodation.hotel
    @State private var additionalInfo = ""
    @State private var selectedTheme: PackingTripTheme? = nil
    @State private var isGenerating = false
    @State private var errorMessage: String?
    @State private var generatedList = ""
    @State private var showResults = false
    @State private var generatedItems: [PackingItem] = []
    
    private let steps = ["Destination", "Duration", "Climate", "Activities", "Accommodation", "Additional Info"]
    
    var body: some View {
        NavigationStack {
            if aiService.hasReachedWeeklyLimit {
                limitReachedView
            } else {
                assistantFlowView
            }
        }
    }
    
    // View when user has reached their limit
    private var limitReachedView: some View {
        VStack(spacing: 24) {
            Spacer()
            
            Image(systemName: "hourglass")
                .font(.system(size: 70))
                .foregroundColor(.blue.opacity(0.7))
                .padding()
                .background(
                    Circle()
                        .fill(Color.blue.opacity(0.1))
                        .frame(width: 160, height: 160)
                )
            
            Text("Weekly Limit Reached")
                .font(.system(.title, design: .rounded))
                .fontWeight(.bold)
            
            Text("You've used all 3 of your AI-generated packing lists for this week.")
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
                .padding(.horizontal, 24)
            
            VStack(alignment: .leading, spacing: 20) {
                HStack(spacing: 16) {
                    Image(systemName: "calendar.badge.clock")
                        .foregroundColor(.blue)
                        .font(.title3)
                        .frame(width: 24)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Next Reset")
                            .font(.headline)
                        
                        Text("Your limit will reset in \(aiService.getTimeUntilReset())")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                
                HStack(spacing: 16) {
                    Image(systemName: "pencil.and.list.clipboard")
                        .foregroundColor(.green)
                        .font(.title3)
                        .frame(width: 24)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Create Manually")
                            .font(.headline)
                        
                        Text("You can still create packing lists manually")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(.systemBackground))
                    .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 5)
            )
            .padding(.horizontal, 24)
            .padding(.top, 16)
            
            Spacer()
            
            Button(action: { dismiss() }) {
                Text("Got It")
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.blue)
                    )
                    .foregroundColor(.white)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 24)
        }
        .navigationTitle("AI Assistant")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("Close") {
                    dismiss()
                }
            }
        }
    }
    
    // Main assistant flow view
    private var assistantFlowView: some View {
        VStack(spacing: 0) {
            // Progress indicator
            ProgressBar(currentStep: currentStep, totalSteps: steps.count)
                .padding(.top)
            
            // Step content
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    Text(stepTitle)
                        .font(.title2)
                        .fontWeight(.bold)
                        .padding(.horizontal)
                    
                    Text(stepDescription)
                        .font(.body)
                        .foregroundStyle(.secondary)
                        .padding(.horizontal)
                    
                    stepContent
                        .padding(.top, 8)
                }
                .padding(.top, 20)
                .padding(.bottom, 100)
            }
            
            // Navigation buttons
            VStack {
                if errorMessage != nil {
                    Text(errorMessage!)
                        .font(.caption)
                        .foregroundColor(.red)
                        .padding(.bottom, 8)
                }
                
                HStack {
                    if currentStep > 0 {
                        Button(action: { currentStep -= 1 }) {
                            HStack {
                                Image(systemName: "chevron.left")
                                Text("Back")
                            }
                            .padding(.horizontal, 20)
                            .padding(.vertical, 12)
                            .background(Color.blue.opacity(0.1))
                            .foregroundColor(.blue)
                            .cornerRadius(10)
                        }
                    }
                    
                    Spacer()
                    
                    if currentStep < steps.count - 1 {
                        Button(action: advanceStep) {
                            HStack {
                                Text("Next")
                                Image(systemName: "chevron.right")
                            }
                            .padding(.horizontal, 20)
                            .padding(.vertical, 12)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                        }
                        .disabled(!canAdvance)
                    } else {
                        Button(action: generatePackingList) {
                            if isGenerating {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            } else {
                                HStack {
                                    Text("Generate List")
                                    Image(systemName: "wand.and.stars")
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 12)
                        .background(canAdvance ? Color.blue : Color.blue.opacity(0.5))
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .disabled(!canAdvance || isGenerating)
                    }
                }
                .padding(.horizontal)
                
                HStack {
                    Image(systemName: "wand.and.stars")
                        .font(.caption)
                        .foregroundColor(.blue)
                    
                    Text("\(aiService.getRemainingPrompts()) of 3 AI generations remaining this week")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    
                    Spacer()
                    
                    Text("Resets in \(aiService.getTimeUntilReset())")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding(.horizontal)
                .padding(.top, 8)
            }
            .padding(.vertical, 16)
            .padding(.horizontal, 16)
            .background(
                Rectangle()
                    .fill(Color(.systemBackground))
                    .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: -4)
            )
        }
        .navigationTitle("AI Packing Assistant")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("Cancel") {
                    dismiss()
                }
            }
        }
        .sheet(isPresented: $showResults) {
            AIResultsView(items: $generatedItems, viewModel: viewModel, onDismiss: { dismiss() })
        }
    }
    
    private var stepTitle: String {
        switch currentStep {
        case 0: return "Where are you going?"
        case 1: return "How long is your trip?"
        case 2: return "What's the climate like?"
        case 3: return "What activities are you planning?"
        case 4: return "Where will you be staying?"
        case 5: return "Any additional information?"
        default: return ""
        }
    }
    
    private var stepDescription: String {
        switch currentStep {
        case 0: return "Enter your travel destination to help us create a personalized packing list."
        case 1: return "The length of your trip helps determine how many items to pack."
        case 2: return "Different climates require different clothing and gear."
        case 3: return "Select all activities you plan to do during your trip."
        case 4: return "Your accommodation type may affect what you need to bring."
        case 5: return "Any special requirements or details you want to include in your packing list."
        default: return ""
        }
    }
    
    @ViewBuilder
    private var stepContent: some View {
        switch currentStep {
        case 0:
            destinationStep
        case 1:
            durationStep
        case 2:
            climateStep
        case 3:
            activitiesStep
        case 4:
            accommodationStep
        case 5:
            additionalInfoStep
        default:
            EmptyView()
        }
    }
    
    private var destinationStep: some View {
        VStack {
            TextField("Enter destination", text: $destination)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(10)
                .padding(.horizontal)
        }
    }
    
    private var durationStep: some View {
        VStack {
            Stepper("Days: \(duration)", value: $duration, in: 1...90)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(10)
                .padding(.horizontal)
            
            HStack {
                ForEach([3, 7, 14, 30], id: \.self) { days in
                    Button("\(days) days") {
                        duration = days
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(duration == days ? Color.blue : Color(.systemGray6))
                    .foregroundColor(duration == days ? .white : .primary)
                    .cornerRadius(8)
                }
            }
            .padding(.horizontal)
        }
    }
    
    private var climateStep: some View {
        VStack {
            Picker("Climate", selection: $climate) {
                ForEach(TripDetails.Climate.allCases, id: \.self) { climate in
                    Text(climate.rawValue).tag(climate)
                }
            }
            .pickerStyle(.wheel)
            .padding(.horizontal)
        }
    }
    
    private var activitiesStep: some View {
        VStack {
            ScrollView {
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                    ForEach(TripDetails.Activity.allCases) { activity in
                        ActivitySelectionButton(
                            activity: activity,
                            isSelected: selectedActivities.contains(activity)
                        ) {
                            if selectedActivities.contains(activity) {
                                selectedActivities.remove(activity)
                            } else {
                                selectedActivities.insert(activity)
                            }
                        }
                    }
                }
                .padding(.horizontal)
            }
        }
    }
    
    private var accommodationStep: some View {
        VStack {
            Picker("Accommodation", selection: $accommodation) {
                ForEach(TripDetails.Accommodation.allCases, id: \.self) { accommodation in
                    Text(accommodation.rawValue).tag(accommodation)
                }
            }
            .pickerStyle(.wheel)
            .padding(.horizontal)
        }
    }
    
    private var additionalInfoStep: some View {
        VStack {
            TextEditor(text: $additionalInfo)
                .frame(minHeight: 150)
                .padding(4)
                .background(Color(.systemGray6))
                .cornerRadius(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                )
                .padding(.horizontal)
            
            Text("Examples: business meetings, formal dinner, beach wedding, hiking in mountains, etc.")
                .font(.caption)
                .foregroundStyle(.secondary)
                .padding(.horizontal)
        }
    }
    
    private var canAdvance: Bool {
        switch currentStep {
        case 0: return !destination.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        case 3: return !selectedActivities.isEmpty
        default: return true
        }
    }
    
    private func advanceStep() {
        withAnimation {
            errorMessage = nil
            currentStep = min(currentStep + 1, steps.count - 1)
        }
    }
    
    private func generatePackingList() {
        isGenerating = true
        errorMessage = nil
        
        // Initialize from the selected trip's theme if we have one
        if selectedTheme == nil, let trip = viewModel.trips.first(where: { $0.id == tripId }) {
            selectedTheme = trip.theme
        }
        
        let tripDetails = TripDetails(
            destination: destination,
            duration: duration,
            climate: climate,
            activities: Array(selectedActivities),
            accommodation: accommodation,
            additionalInfo: additionalInfo.isEmpty ? nil : additionalInfo,
            theme: selectedTheme
        )
        
        Task {
            do {
                let response = try await aiService.generatePackingList(tripDetails: tripDetails)
                var parsedItems = viewModel.parseAIResponse(response)
                
                // Associate items with the trip
                if let tripId = tripId {
                    parsedItems = parsedItems.map { item in
                        var newItem = item
                        newItem.tripId = tripId
                        return newItem
                    }
                }
                
                generatedItems = parsedItems
                showResults = true
            } catch {
                errorMessage = error.localizedDescription
            }
            
            isGenerating = false
        }
    }
}

struct ProgressBar: View {
    let currentStep: Int
    let totalSteps: Int
    
    var body: some View {
        HStack(spacing: 4) {
            ForEach(0..<totalSteps, id: \.self) { step in
                RoundedRectangle(cornerRadius: 2)
                    .frame(height: 4)
                    .foregroundColor(step <= currentStep ? .blue : Color.gray.opacity(0.3))
            }
        }
        .padding(.horizontal)
    }
}

struct ActivitySelectionButton: View {
    let activity: TripDetails.Activity
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: activity.icon)
                    .font(.title2)
                    .frame(width: 32, height: 32)
                
                Text(activity.rawValue)
                    .font(.callout)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? Color.blue.opacity(0.15) : Color(.systemGray6))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 2)
                    )
            )
            .foregroundColor(isSelected ? .blue : .primary)
        }
        .buttonStyle(.plain)
    }
}

struct AIResultsView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var items: [PackingItem]
    @ObservedObject var viewModel: PackingListViewModel
    let onDismiss: () -> Void
    
    var body: some View {
        NavigationStack {
            VStack {
                VStack(spacing: 16) {
                    Image(systemName: "wand.and.stars.inverse")
                        .font(.system(size: 60))
                        .foregroundColor(.blue)
                        .padding(.bottom, 8)
                    
                    Text("AI Suggestions Ready!")
                        .font(.title)
                        .fontWeight(.bold)
                    
                    Text("We've created a personalized packing list for your trip with \(items.count) items.")
                        .multilineTextAlignment(.center)
                        .foregroundStyle(.secondary)
                }
                .padding()
                
                List {
                    ForEach(PackingCategory.allCases) { category in
                        let categoryItems = items.filter { $0.category == category.rawValue }
                        if !categoryItems.isEmpty {
                            Section(header: HStack {
                                Image(systemName: category.icon)
                                Text(category.rawValue)
                            }) {
                                ForEach(categoryItems) { item in
                                    Text(item.name)
                                }
                            }
                        }
                    }
                }
                .listStyle(.insetGrouped)
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Add to List") {
                        viewModel.addItems(items)
                        onDismiss()
                    }
                    .fontWeight(.semibold)
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .navigationTitle("AI Suggestions")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
} 