//
//  TagView.swift
//  TripCraft
//
//  Created by Siddharth Sehgal on 07/03/2025.
//

import SwiftUI

struct TagView: View {
    let tag: String
    let themeColor: Color
    let onDelete: () -> Void
    
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        HStack(spacing: 6) {
            Text("#\(tag)")
                .font(.subheadline)
                .fontWeight(.medium)
            
            Button(action: onDelete) {
                Image(systemName: "xmark.circle.fill")
                    .font(.caption)
                    .foregroundColor(themeColor.opacity(0.8))
            }
            .buttonStyle(ScaleButtonStyleFlowLayout())
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(themeColor.opacity(colorScheme == .dark ? 0.2 : 0.1))
        .foregroundColor(themeColor)
        .cornerRadius(10)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(themeColor.opacity(colorScheme == .dark ? 0.3 : 0.2), lineWidth: 1)
        )
    }
}
