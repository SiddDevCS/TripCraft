//
//  OnboardingView.swift
//  TripCraft
//
//  Created by Siddharth Sehgal on 25/03/2025.
//

import SwiftUI

struct OnboardingView: View {
    @Binding var hasSeenOnboarding: Bool
    @State private var currentStep = 0
    
    var body: some View {
        ZStack {
            // Background color
            OnboardingStep.steps[currentStep].accentColor
                .opacity(0.1)
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                Spacer()
                
                // Progress indicator
                HStack(spacing: 8) {
                    ForEach(0..<OnboardingStep.steps.count, id: \.self) { index in
                        Circle()
                            .fill(index == currentStep ?
                                  OnboardingStep.steps[currentStep].accentColor :
                                  .gray.opacity(0.3))
                            .frame(width: 8, height: 8)
                            .scaleEffect(index == currentStep ? 1.2 : 1.0)
                            .animation(.spring(), value: currentStep)
                    }
                }
                .padding(.bottom, 50)
                
                // Icon
                Image(systemName: OnboardingStep.steps[currentStep].systemImage)
                    .font(.system(size: 80))
                    .foregroundColor(OnboardingStep.steps[currentStep].accentColor)
                    .padding(.bottom, 20)
                
                // Title and description
                VStack(spacing: 16) {
                    Text(OnboardingStep.steps[currentStep].title)
                        .font(.title)
                        .bold()
                        .multilineTextAlignment(.center)
                    
                    Text(OnboardingStep.steps[currentStep].description)
                        .font(.body)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 32)
                }
                
                Spacer()
                
                // Navigation buttons
                HStack {
                    if currentStep > 0 {
                        Button(action: { currentStep -= 1 }) {
                            Image(systemName: "arrow.left")
                                .font(.headline)
                                .padding()
                                .background(Circle().fill(.ultraThinMaterial))
                        }
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        if currentStep < OnboardingStep.steps.count - 1 {
                            withAnimation {
                                currentStep += 1
                            }
                        } else {
                            withAnimation {
                                hasSeenOnboarding = true
                            }
                        }
                    }) {
                        if currentStep == OnboardingStep.steps.count - 1 {
                            Text("Get Started")
                                .font(.headline)
                                .padding()
                                .background(Capsule().fill(OnboardingStep.steps[currentStep].accentColor))
                                .foregroundColor(.white)
                        } else {
                            Image(systemName: "arrow.right")
                                .font(.headline)
                                .padding()
                                .background(Circle().fill(.ultraThinMaterial))
                        }
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
            }
        }
        .transition(.opacity)
    }
}
