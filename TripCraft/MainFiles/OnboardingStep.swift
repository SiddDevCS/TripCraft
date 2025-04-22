//
//  OnboardingStep.swift
//  TripCraft
//
//  Created by Siddharth Sehgal on 25/03/2025.
//

import SwiftUI

struct OnboardingStep: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let systemImage: String
    let accentColor: Color
}

extension OnboardingStep {
    static let steps = [
        OnboardingStep(
            title: "Smart Packing Lists",
            description: "Create and manage your packing lists with AI assistance. Never forget essential items for your trips.",
            systemImage: "checklist.checked",
            accentColor: .blue
        ),
        OnboardingStep(
            title: "Travel Journal",
            description: "Document your adventures, save memories, and keep track of your favorite places.",
            systemImage: "book.fill",
            accentColor: .orange
        ),
        OnboardingStep(
            title: "Travel Tools",
            description: "Access essential travel tools like currency converter, unit converter, and more - all in one place.",
            systemImage: "gear",
            accentColor: .purple
        )
    ]
}
