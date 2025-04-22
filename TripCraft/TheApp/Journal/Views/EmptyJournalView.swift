//
//  EmptyJournalView.swift
//  TripCraft
//
//  Created by Siddharth Sehgal on 07/03/2025.
//

import SwiftUI

struct EmptyJournalView: View {
    let onCreateEntry: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "book.closed.circle.fill")
                .font(.system(size: 80))
                .foregroundStyle(.blue.gradient)
                .symbolEffect(.bounce)
            
            Text("Start Your Travel Story")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("Capture your travel memories, photos, and experiences in your personal journal.")
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
                .padding(.horizontal, 32)
            
            Button(action: onCreateEntry) {
                Label("Create First Entry", systemImage: "plus.circle.fill")
                    .font(.headline)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                    .padding(.horizontal, 32)
                    .shadow(radius: 3)
            }
            .padding(.top, 10)
        }
        .padding()
    }
}
