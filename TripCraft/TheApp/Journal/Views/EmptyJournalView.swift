//
//  EmptyJournalView.swift
//  TripCraft
//
//  Created by Siddharth Sehgal on 07/03/2025.
//

import SwiftUI

struct EmptyJournalView: View {
    let onCreateEntry: () -> Void
    
    // App theme color
    private let themeColor = Color.blue.opacity(0.8)
    
    @Environment(\.colorScheme) private var colorScheme
    
    private var backgroundColor: Color {
        colorScheme == .dark ? Color(.systemBackground) : Color.white
    }
    
    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: "book.closed.circle.fill")
                .font(.system(size: 100))
                .foregroundStyle(
                    LinearGradient(
                        colors: [themeColor, themeColor.opacity(0.7)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .symbolEffect(.bounce)
                .shadow(color: themeColor.opacity(0.3), radius: 10, x: 0, y: 5)
            
            Text("Start Your Travel Story")
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            
            Text("Capture your travel memories, photos, and experiences in your personal journal.")
                .font(.subheadline)
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
                .padding(.horizontal, 32)
            
            Button(action: onCreateEntry) {
                Label("Create First Entry", systemImage: "plus.circle.fill")
                    .font(.headline)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(
                        LinearGradient(
                            colors: [themeColor, themeColor.opacity(0.8)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .foregroundColor(.white)
                    .cornerRadius(16)
                    .padding(.horizontal, 32)
                    .shadow(color: themeColor.opacity(0.4), radius: 5, x: 0, y: 3)
            }
            .buttonStyle(ScaleButtonStyleFlowLayout())
            .padding(.top, 16)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(backgroundColor)
    }
}
