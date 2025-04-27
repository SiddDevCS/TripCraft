import SwiftUI
import Foundation

// MARK: - Packing List Creation View
struct PackingListCreationView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme
    
    @State private var tripName = ""
    @State private var destination = ""
    @State private var startDate = Date()
    @State private var endDate = Date().addingTimeInterval(7 * 24 * 60 * 60) // Default 7 days
    @State private var notes = ""
    @State private var currentStep = 0
    @State private var selectedTheme: PackingTripTheme = .beach
    @FocusState private var isNameFocused: Bool
    @FocusState private var isDestinationFocused: Bool
    
    let onComplete: (Trip) -> Void
    
    private let steps = ["Trip Details", "Dates", "Theme", "Notes"]
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background color with subtle pattern
                backGroundView
                
                VStack(spacing: 0) {
                    // Progress indicator
                    ProgressView(value: Double(currentStep), total: Double(steps.count - 1))
                        .tint(.blue)
                        .padding(.horizontal)
                        .padding(.top)
                    
                    HStack {
                        ForEach(0..<steps.count, id: \.self) { index in
                            Text(steps[index])
                                .font(.caption)
                                .foregroundColor(currentStep >= index ? .blue : .secondary)
                                .fontWeight(currentStep == index ? .bold : .regular)
                            
                            if index < steps.count - 1 {
                                Spacer()
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 8)
                    
                    // Step content
                    ScrollView {
                        VStack(alignment: .leading, spacing: 24) {
                            Text(stepTitle)
                                .font(.system(size: 28, weight: .bold, design: .rounded))
                                .foregroundColor(.primary)
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
                        HStack {
                            if currentStep > 0 {
                                Button(action: { currentStep -= 1 }) {
                                    HStack {
                                        Image(systemName: "chevron.left")
                                        Text("Back")
                                            .fontWeight(.medium)
                                    }
                                    .padding(.horizontal, 20)
                                    .padding(.vertical, 14)
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(Color.blue.opacity(0.1))
                                    )
                                    .foregroundColor(.blue)
                                }
                                .buttonStyle(ScaleButtonStyle())
                            } else {
                                Spacer()
                                    .frame(height: 45)
                            }
                            
                            Spacer()
                            
                            if currentStep < steps.count - 1 {
                                Button(action: { advanceStep() }) {
                                    HStack {
                                        Text("Next")
                                            .fontWeight(.medium)
                                        Image(systemName: "chevron.right")
                                    }
                                    .padding(.horizontal, 20)
                                    .padding(.vertical, 14)
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(canAdvance ? Color.blue : Color.blue.opacity(0.3))
                                    )
                                    .foregroundColor(.white)
                                }
                                .buttonStyle(ScaleButtonStyle())
                                .disabled(!canAdvance)
                            } else {
                                Button(action: createTrip) {
                                    HStack {
                                        Image(systemName: "checkmark")
                                        Text("Create Trip")
                                            .fontWeight(.semibold)
                                    }
                                    .padding(.horizontal, 20)
                                    .padding(.vertical, 14)
                                    .frame(maxWidth: .infinity)
                                    .background(
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(canAdvance ? Color.blue : Color.blue.opacity(0.3))
                                    )
                                    .foregroundColor(.white)
                                }
                                .buttonStyle(ScaleButtonStyle())
                                .disabled(!canAdvance)
                            }
                        }
                        .padding(.horizontal)
                    }
                    .padding(.vertical, 16)
                    .padding(.horizontal, 16)
                    .background(
                        Rectangle()
                            .fill(Color(.systemBackground))
                            .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: -4)
                    )
                }
            }
            .navigationTitle("New Trip")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private var backGroundView: some View {
        ZStack {
            Color(.systemBackground)
                .ignoresSafeArea()
            
            GeometryReader { geometry in
                let width = geometry.size.width
                let height = geometry.size.height
                
                // Top bubble
                Circle()
                    .fill(Color.blue.opacity(0.1))
                    .frame(width: width * 0.4)
                    .position(x: width * 0.9, y: height * 0.1)
                
                // Bottom bubble
                Circle()
                    .fill(Color.blue.opacity(0.08))
                    .frame(width: width * 0.6)
                    .position(x: width * 0.1, y: height * 0.85)
            }
        }
    }
    
    private var stepTitle: String {
        switch currentStep {
        case 0: return "Trip Details"
        case 1: return "When are you traveling?"
        case 2: return "What's your trip theme?"
        case 3: return "Any additional notes?"
        default: return ""
        }
    }
    
    private var stepDescription: String {
        switch currentStep {
        case 0: return "Let's start with some basic information about your trip."
        case 1: return "Select your travel dates to help organize your packing."
        case 2: return "Choose a theme that best matches your trip style."
        case 3: return "Add any details that might help with packing suggestions."
        default: return ""
        }
    }
    
    @ViewBuilder
    private var stepContent: some View {
        switch currentStep {
        case 0:
            tripDetailsStep
        case 1:
            datesStep
        case 2:
            themeStep
        case 3:
            notesStep
        default:
            EmptyView()
        }
    }
    
    private var tripDetailsStep: some View {
        VStack(spacing: 24) {
            // Trip name field
            VStack(alignment: .leading, spacing: 8) {
                Text("Trip Name")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                HStack {
                    Image(systemName: "airplane")
                        .foregroundColor(.secondary)
                    
                    TextField("e.g., Summer Vacation", text: $tripName)
                        .focused($isNameFocused)
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(colorScheme == .dark ? Color(.systemGray6) : Color(.systemGray6))
                        .shadow(color: Color.black.opacity(0.03), radius: 3, x: 0, y: 1)
                )
            }
            .padding(.horizontal)
            
            // Destination field
            VStack(alignment: .leading, spacing: 8) {
                Text("Destination")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                HStack {
                    Image(systemName: "mappin.and.ellipse")
                        .foregroundColor(.secondary)
                    
                    TextField("e.g., Paris, France", text: $destination)
                        .focused($isDestinationFocused)
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(colorScheme == .dark ? Color(.systemGray6) : Color(.systemGray6))
                        .shadow(color: Color.black.opacity(0.03), radius: 3, x: 0, y: 1)
                )
            }
            .padding(.horizontal)
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                isNameFocused = true
            }
        }
    }
    
    private var datesStep: some View {
        VStack(spacing: 24) {
            // Card with dates
            VStack(alignment: .leading, spacing: 16) {
                // Start date
                VStack(alignment: .leading, spacing: 8) {
                    Text("Start Date")
                        .font(.headline)
                    
                    DatePicker("", selection: $startDate, displayedComponents: .date)
                        .datePickerStyle(.graphical)
                        .tint(.blue)
                        .onChange(of: startDate) { oldValue, newValue in
                            if endDate < newValue {
                                endDate = newValue.addingTimeInterval(24 * 60 * 60) // Add 1 day
                            }
                        }
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color(.systemBackground))
                        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                )
                
                // End date
                VStack(alignment: .leading, spacing: 8) {
                    Text("End Date")
                        .font(.headline)
                    
                    DatePicker("", selection: $endDate, in: startDate..., displayedComponents: .date)
                        .datePickerStyle(.graphical)
                        .tint(.blue)
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color(.systemBackground))
                        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                )
                
                // Display trip length
                HStack {
                    Image(systemName: "calendar.badge.clock")
                        .foregroundColor(.blue)
                    
                    let days = Calendar.current.dateComponents([.day], from: startDate, to: endDate).day! + 1
                    Text("Total: \(days) \(days == 1 ? "day" : "days")")
                        .fontWeight(.medium)
                }
                .padding(.top, 8)
            }
            .padding(.horizontal)
        }
    }
    
    private var themeStep: some View {
        VStack(spacing: 16) {
            // Theme selection
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                ForEach(PackingTripTheme.allCases, id: \.self) { theme in
                    ThemeSelectionButton(
                        theme: theme,
                        isSelected: selectedTheme == theme
                    ) {
                        selectedTheme = theme
                    }
                }
            }
            .padding(.horizontal)
            
            // Preview of suggested items
            VStack(alignment: .leading, spacing: 8) {
                Text("This theme suggests packing:")
                    .font(.headline)
                    .padding(.horizontal)
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(selectedTheme.suggestedItems, id: \.self) { item in
                            Text(item)
                                .font(.caption)
                                .lineLimit(1)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(
                                    Capsule()
                                        .fill(Color.blue.opacity(0.1))
                                )
                                .foregroundColor(.blue)
                        }
                    }
                    .padding(.horizontal)
                }
            }
            .padding(.top, 16)
        }
    }
    
    private var notesStep: some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Trip Notes (Optional)")
                    .font(.headline)
                
                ZStack(alignment: .topLeading) {
                    TextEditor(text: $notes)
                        .frame(minHeight: 180)
                        .padding(4)
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                        )
                    
                    if notes.isEmpty {
                        Text("Add any details about your trip that might be helpful for packing...")
                            .foregroundColor(.secondary)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 12)
                            .allowsHitTesting(false)
                    }
                }
            }
            .padding(.horizontal)
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Examples:")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                ForEach(["Business meetings require formal attire", "Wedding on day 3", "Hiking trip with rough terrain", "Beach resort with dress code for dining"], id: \.self) { example in
                    HStack(alignment: .top, spacing: 8) {
                        Image(systemName: "circle.fill")
                            .font(.system(size: 6))
                            .foregroundColor(.secondary)
                            .padding(.top, 6)
                        
                        Text(example)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .padding(.horizontal)
            .padding(.top, 8)
        }
    }
    
    private var canAdvance: Bool {
        switch currentStep {
        case 0:
            let nameIsValid = !tripName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            let destinationIsValid = !destination.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            return nameIsValid && destinationIsValid
        case 1:
            return endDate >= startDate
        case 2, 3:
            return true
        default:
            return false
        }
    }
    
    private func advanceStep() {
        withAnimation {
            currentStep = min(currentStep + 1, steps.count - 1)
            
            if currentStep == 0 {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    isNameFocused = true
                }
            }
        }
    }
    
    private func createTrip() {
        let newTrip = Trip(
            id: UUID(),
            name: tripName.trimmingCharacters(in: .whitespacesAndNewlines),
            startDate: startDate,
            endDate: endDate,
            destination: destination.trimmingCharacters(in: .whitespacesAndNewlines),
            notes: notes.isEmpty ? nil : notes,
            theme: selectedTheme
        )
        
        onComplete(newTrip)
        dismiss()
    }
} 