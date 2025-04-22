//
//  EmptyStateView.swift
//  TripCraft
//
//  Created by Siddharth Sehgal on 06/03/2025.
//

import SwiftUI

struct EmptyStateView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "backpack.fill")
                .font(.system(size: 60))
                .foregroundColor(.blue)
            
            Text("Your Packing List is Empty")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("Start by adding items manually or use our AI assistant to generate a personalized packing list for your trip!")
                .multilineTextAlignment(.center)
                .foregroundColor(.gray)
                .padding(.horizontal)
            
            Image(systemName: "arrow.down.circle.fill")
                .font(.system(size: 30))
                .foregroundColor(.blue)
        }
        .padding()
    }
}
