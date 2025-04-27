import SwiftUI

struct OnboardingView: View {
    @Binding var hasSeenOnboarding: Bool
    @State private var currentStep = 0
    @State private var userData = UserOnboardingData()
    @State private var currentFormStep = 0
    @State private var offset = CGSize.zero
    @State private var isExiting = false
    @Environment(\.colorScheme) private var colorScheme
    
    // Animation settings
    private let transitionAnimation = Animation.spring(response: 0.4, dampingFraction: 0.8)
    private let selectionAnimation = Animation.spring(response: 0.3, dampingFraction: 0.7)
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Background with dark mode support
                backgroundColor
                    .ignoresSafeArea()
                
                // Dynamic background decorative elements
                backgroundElements(for: geometry)
                
                VStack(spacing: 0) {
                    // Skip/Back button
                    HStack {
                        if currentStep == OnboardingStep.steps.count - 1 && currentFormStep > 0 {
                            Button(action: {
                                withAnimation(transitionAnimation) {
                                    currentFormStep -= 1
                                }
                            }) {
                                HStack(spacing: 4) {
                                    Image(systemName: "chevron.left")
                                    Text("Back")
                                }
                                .font(.subheadline)
                                .foregroundColor(accentColor)
                            }
                            .padding(.leading, 20)
                        }
                        
                        Spacer()
                        
                        Button(currentStep == OnboardingStep.steps.count - 1 ? "Skip" : "Skip") {
                            withAnimation(transitionAnimation) {
                                if currentStep < OnboardingStep.steps.count - 1 {
                                    withAnimation(.easeIn(duration: 0.2)) {
                                        offset.width = -geometry.size.width / 3
                                    }
                                    
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                        currentStep = OnboardingStep.steps.count - 1
                                        withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                                            offset = .zero
                                        }
                                    }
                                } else {
                                    animateExit()
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                        .font(.subheadline)
                        .foregroundColor(accentColor)
                    }
                    .padding(.top, 16)
                    
                    Spacer()
                    
                    if currentStep == OnboardingStep.steps.count - 1 {
                        userPreferencesView(geometry: geometry)
                            .transition(.asymmetric(
                                insertion: .move(edge: .trailing).combined(with: .opacity),
                                removal: .move(edge: .leading).combined(with: .opacity)
                            ))
                    } else {
                        featureOnboardingView(geometry: geometry)
                            .transition(.asymmetric(
                                insertion: .move(edge: .trailing).combined(with: .opacity),
                                removal: .move(edge: .leading).combined(with: .opacity)
                            ))
                            .offset(x: offset.width)
                            .gesture(
                                DragGesture()
                                    .onChanged { gesture in
                                        self.offset = gesture.translation
                                    }
                                    .onEnded { gesture in
                                        if gesture.translation.width < -50 && currentStep < OnboardingStep.steps.count - 1 {
                                            withAnimation(transitionAnimation) {
                                                currentStep += 1
                                                offset = .zero
                                            }
                                        } else if gesture.translation.width > 50 && currentStep > 0 {
                                            withAnimation(transitionAnimation) {
                                                currentStep -= 1
                                                offset = .zero
                                            }
                                        } else {
                                            withAnimation(transitionAnimation) {
                                                offset = .zero
                                            }
                                        }
                                    }
                            )
                    }
                }
                .offset(x: isExiting ? -geometry.size.width : 0)
            }
        }
    }
    
    // MARK: - Helper Methods
    
    private func animateExit() {
        withAnimation(.easeInOut(duration: 0.4)) {
            isExiting = true
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            hasSeenOnboarding = true
        }
    }
    
    // MARK: - Computed Properties
    
    private var backgroundColor: Color {
        let step = OnboardingStep.steps[min(currentStep, OnboardingStep.steps.count - 1)]
        return colorScheme == .dark ? step.darkBackgroundColor : step.lightBackgroundColor
    }
    
    private var accentColor: Color {
        OnboardingStep.steps[min(currentStep, OnboardingStep.steps.count - 1)].accentColor
    }
    
    // MARK: - Background Elements
    
    private func backgroundElements(for geometry: GeometryProxy) -> some View {
        ZStack {
            // Modern blurred circles
            Circle()
                .fill(accentColor.opacity(0.15))
                .frame(width: geometry.size.width * 0.7)
                .offset(x: -geometry.size.width * 0.3, y: -geometry.size.height * 0.1)
                .blur(radius: 30)
                .offset(x: offset.width / 8, y: 0)
            
            Circle()
                .fill(accentColor.opacity(0.1))
                .frame(width: geometry.size.width * 0.5)
                .offset(x: geometry.size.width * 0.3, y: -geometry.size.height * 0.2)
                .blur(radius: 25)
                .offset(x: -offset.width / 10, y: 0)
        }
    }
    
    // MARK: - User Preferences View
    
    @ViewBuilder
    private func userPreferencesView(geometry: GeometryProxy) -> some View {
        VStack(spacing: 0) {
            // Form title and steps indicator
            VStack(spacing: 5) {
                Text(formTitle)
                    .font(.title3.bold())
                    .foregroundColor(.primary)
                
                // Page indicators
                HStack(spacing: 8) {
                    ForEach(0..<4, id: \.self) { index in
                        Capsule()
                            .fill(index == currentFormStep ? accentColor : Color.gray.opacity(0.3))
                            .frame(width: index == currentFormStep ? 20 : 8, height: 6)
                            .animation(selectionAnimation, value: currentFormStep)
                    }
                }
                .padding(.top, 8)
            }
            .padding(.bottom, 15)
            
            // Form content with scrolling
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    Group {
                        switch currentFormStep {
                        case 0:
                            // Travel style
                            VStack(alignment: .leading, spacing: 12) {
                                Text("How do you like to travel?")
                                    .font(.headline)
                                    .foregroundColor(.primary)
                                    .padding(.bottom, 5)
                                
                                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                                    ForEach(UserOnboardingData.TravelStyle.allCases) { style in
                                        travelStyleButton(style: style)
                                    }
                                }
                            }
                        case 1:
                            // Trip interests
                            VStack(alignment: .leading, spacing: 12) {
                                Text("What are you interested in?")
                                    .font(.headline)
                                    .foregroundColor(.primary)
                                    .padding(.bottom, 5)
                                
                                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                                    ForEach(UserOnboardingData.TripCategory.allCases) { category in
                                        tripInterestButton(category: category)
                                    }
                                }
                            }
                        case 2:
                            // Preferred travel seasons
                            VStack(alignment: .leading, spacing: 12) {
                                Text("When do you prefer to travel?")
                                    .font(.headline)
                                    .foregroundColor(.primary)
                                    .padding(.bottom, 5)
                                
                                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                                    ForEach(UserOnboardingData.TravelSeason.allCases) { season in
                                        travelSeasonButton(season: season)
                                    }
                                }
                            }
                        case 3:
                            // Accommodation preferences
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Where do you prefer to stay?")
                                    .font(.headline)
                                    .foregroundColor(.primary)
                                    .padding(.bottom, 5)
                                
                                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                                    ForEach(UserOnboardingData.AccommodationType.allCases) { type in
                                        accommodationButton(type: type)
                                    }
                                }
                                
                                Divider()
                                    .padding(.vertical, 10)
                                
                                Toggle(isOn: $userData.notificationsEnabled) {
                                    HStack(spacing: 8) {
                                        Image(systemName: "bell.fill")
                                            .foregroundColor(accentColor)
                                        Text("Trip reminders & alerts")
                                    }
                                    .font(.subheadline)
                                }
                                .toggleStyle(SwitchToggleStyle(tint: accentColor))
                                
                                Toggle(isOn: $userData.shareTripsWithFriends) {
                                    HStack(spacing: 8) {
                                        Image(systemName: "person.2.fill")
                                            .foregroundColor(accentColor)
                                        Text("Share trips with friends")
                                    }
                                    .font(.subheadline)
                                }
                                .toggleStyle(SwitchToggleStyle(tint: accentColor))
                                .padding(.top, 8)
                            }
                        default:
                            EmptyView()
                        }
                    }
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing).combined(with: .opacity),
                        removal: .move(edge: .leading).combined(with: .opacity)
                    ))
                }
                .padding(.horizontal, 20)
            }
            .frame(maxHeight: geometry.size.height * 0.6)
            
            Spacer()
            
            // Continue/Get Started button
            Button(action: {
                if currentFormStep < 3 {
                    withAnimation(transitionAnimation) {
                        currentFormStep += 1
                    }
                } else {
                    animateExit()
                }
            }) {
                HStack {
                    Text(currentFormStep < 3 ? "Continue" : "Start My Journey")
                    Image(systemName: "arrow.right")
                }
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 15)
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [OnboardingStep.primaryColor, OnboardingStep.secondaryColor]),
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                    .cornerRadius(15)
                )
                .shadow(color: OnboardingStep.primaryColor.opacity(0.3), radius: 5, x: 0, y: 3)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 25)
        }
    }
    
    private var formTitle: String {
        switch currentFormStep {
        case 0: return "Your Travel Style"
        case 1: return "Trip Interests"
        case 2: return "Travel Seasons"
        case 3: return "Final Preferences"
        default: return ""
        }
    }
    
    // MARK: - Selection Buttons
    
    private func travelStyleButton(style: UserOnboardingData.TravelStyle) -> some View {
        let isSelected = userData.travelPreferences.contains(style)
        
        return Button(action: {
            withAnimation(selectionAnimation) {
                if isSelected {
                    userData.travelPreferences.remove(style)
                } else {
                    userData.travelPreferences.insert(style)
                }
            }
        }) {
            HStack(spacing: 10) {
                // Icon
                ZStack {
                    Circle()
                        .fill(isSelected ? accentColor : Color.gray.opacity(0.1))
                        .frame(width: 36, height: 36)
                    
                    Image(systemName: style.icon)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(isSelected ? .white : accentColor)
                }
                
                // Text
                Text(style.rawValue)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(.primary)
                
                Spacer()
                
                // Selection indicator
                if isSelected {
                    Image(systemName: "checkmark")
                        .font(.footnote)
                        .foregroundColor(accentColor)
                }
            }
            .padding(.vertical, 10)
            .padding(.horizontal, 12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.gray.opacity(0.05))
                    .shadow(color: isSelected ? accentColor.opacity(0.15) : Color.gray.opacity(0.05),
                           radius: isSelected ? 3 : 1, x: 0, y: isSelected ? 1 : 0)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? accentColor : Color.gray.opacity(0.2), lineWidth: 1)
            )
        }
    }
    
    private func tripInterestButton(category: UserOnboardingData.TripCategory) -> some View {
        let isSelected = userData.tripInterests.contains(category)
        
        return Button(action: {
            withAnimation(selectionAnimation) {
                if isSelected {
                    userData.tripInterests.remove(category)
                } else {
                    userData.tripInterests.insert(category)
                }
            }
        }) {
            HStack(spacing: 10) {
                // Icon
                ZStack {
                    Circle()
                        .fill(isSelected ? accentColor : Color.gray.opacity(0.1))
                        .frame(width: 36, height: 36)
                    
                    Image(systemName: category.icon)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(isSelected ? .white : accentColor)
                }
                
                // Text
                Text(category.rawValue)
                    .font(.system(size: 15, weight: .medium))
                    .lineLimit(1)
                    .minimumScaleFactor(0.9)
                    .foregroundColor(.primary)
                
                Spacer()
                
                // Selection indicator
                if isSelected {
                    Image(systemName: "checkmark")
                        .font(.footnote)
                        .foregroundColor(accentColor)
                }
            }
            .padding(.vertical, 10)
            .padding(.horizontal, 12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.gray.opacity(0.05))
                    .shadow(color: isSelected ? accentColor.opacity(0.15) : Color.gray.opacity(0.05),
                           radius: isSelected ? 3 : 1, x: 0, y: isSelected ? 1 : 0)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? accentColor : Color.gray.opacity(0.2), lineWidth: 1)
            )
        }
    }
    
    private func travelSeasonButton(season: UserOnboardingData.TravelSeason) -> some View {
        let isSelected = userData.travelSeasons.contains(season)
        
        return Button(action: {
            withAnimation(selectionAnimation) {
                if isSelected {
                    userData.travelSeasons.remove(season)
                } else {
                    userData.travelSeasons.insert(season)
                }
            }
        }) {
            HStack(spacing: 10) {
                // Icon
                ZStack {
                    Circle()
                        .fill(isSelected ? accentColor : Color.gray.opacity(0.1))
                        .frame(width: 36, height: 36)
                    
                    Image(systemName: season.icon)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(isSelected ? .white : accentColor)
                }
                
                // Text
                Text(season.rawValue)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(.primary)
                
                Spacer()
                
                // Selection indicator
                if isSelected {
                    Image(systemName: "checkmark")
                        .font(.footnote)
                        .foregroundColor(accentColor)
                }
            }
            .padding(.vertical, 10)
            .padding(.horizontal, 12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.gray.opacity(0.05))
                    .shadow(color: isSelected ? accentColor.opacity(0.15) : Color.gray.opacity(0.05),
                           radius: isSelected ? 3 : 1, x: 0, y: isSelected ? 1 : 0)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? accentColor : Color.gray.opacity(0.2), lineWidth: 1)
            )
        }
    }
    
    private func accommodationButton(type: UserOnboardingData.AccommodationType) -> some View {
        let isSelected = userData.accommodationTypes.contains(type)
        
        return Button(action: {
            withAnimation(selectionAnimation) {
                if isSelected {
                    userData.accommodationTypes.remove(type)
                } else {
                    userData.accommodationTypes.insert(type)
                }
            }
        }) {
            HStack(spacing: 10) {
                // Icon
                ZStack {
                    Circle()
                        .fill(isSelected ? accentColor : Color.gray.opacity(0.1))
                        .frame(width: 36, height: 36)
                    
                    Image(systemName: type.icon)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(isSelected ? .white : accentColor)
                }
                
                // Text
                Text(type.rawValue)
                    .font(.system(size: 15, weight: .medium))
                    .lineLimit(1)
                    .minimumScaleFactor(0.9)
                    .foregroundColor(.primary)
                
                Spacer()
                
                // Selection indicator
                if isSelected {
                    Image(systemName: "checkmark")
                        .font(.footnote)
                        .foregroundColor(accentColor)
                }
            }
            .padding(.vertical, 10)
            .padding(.horizontal, 12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.gray.opacity(0.05))
                    .shadow(color: isSelected ? accentColor.opacity(0.15) : Color.gray.opacity(0.05),
                           radius: isSelected ? 3 : 1, x: 0, y: isSelected ? 1 : 0)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? accentColor : Color.gray.opacity(0.2), lineWidth: 1)
            )
        }
    }
    
    // MARK: - Feature Onboarding View
    
    private func featureOnboardingView(geometry: GeometryProxy) -> some View {
        VStack(spacing: 30) {
            // Icon with animated background
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                accentColor.opacity(0.2),
                                accentColor.opacity(0.05)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: geometry.size.width * 0.5, height: geometry.size.width * 0.5)
                
                Image(systemName: OnboardingStep.steps[currentStep].systemImage)
                    .font(.system(size: 60, weight: .light))
                    .foregroundColor(accentColor)
                    .offset(x: offset.width / 10, y: offset.height / 10)
            }
            .padding(.top, 20)
            
            // Title and description
            VStack(spacing: 12) {
                Text(OnboardingStep.steps[currentStep].title)
                    .font(.system(size: 28, weight: .bold))
                    .multilineTextAlignment(.center)
                    .foregroundColor(.primary)
                
                Text(OnboardingStep.steps[currentStep].description)
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 32)
            }
            .offset(x: offset.width / 6)
            
            Spacer()
            
            // Pagination and next button
            VStack(spacing: 30) {
                // Step indicators
                HStack(spacing: 8) {
                    ForEach(0..<OnboardingStep.steps.count, id: \.self) { index in
                        Capsule()
                            .fill(index == currentStep ?
                                  accentColor :
                                  Color.gray.opacity(0.3))
                            .frame(width: index == currentStep ? 20 : 8, height: 6)
                            .animation(selectionAnimation, value: currentStep)
                    }
                }
                
                // Next button
                Button(action: {
                    withAnimation(transitionAnimation) {
                        if currentStep < OnboardingStep.steps.count - 1 {
                            currentStep += 1
                        }
                    }
                }) {
                    HStack {
                        Text(currentStep < OnboardingStep.steps.count - 1 ? "Next" : "Personalize")
                        Image(systemName: "arrow.right")
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 15)
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: [OnboardingStep.primaryColor, OnboardingStep.secondaryColor]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                        .cornerRadius(15)
                    )
                    .shadow(color: OnboardingStep.primaryColor.opacity(0.3), radius: 5, x: 0, y: 3)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 25)
            }
        }
    }
}

// MARK: - BlurView
struct BlurView: UIViewRepresentable {
    let style: UIBlurEffect.Style
    
    func makeUIView(context: Context) -> UIVisualEffectView {
        UIVisualEffectView(effect: UIBlurEffect(style: style))
    }
    
    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {
        uiView.effect = UIBlurEffect(style: style)
    }
}
