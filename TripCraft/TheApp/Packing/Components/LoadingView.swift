//
//  LoadingView.swift
//  TripCraft
//
//  Created by Siddharth Sehgal on 06/03/2025.
//

import SwiftUI

struct LoadingView: View {
    let message: String
    @State private var isAnimating = false
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.4)
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 20) {
                LoadingAnimation(color: .green)
                
                Text(message)
                    .font(.headline)
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.center)
            }
            .padding(30)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color(.systemBackground))
                    .shadow(radius: 10)
            )
            .padding(40)
        }
    }
}

private struct LoadingAnimation: View {
    @State private var isAnimating = false
    let color: Color
    
    init(color: Color = .green) {
        self.color = color
    }
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(color.opacity(0.3), lineWidth: 3)
                .frame(width: 50, height: 50)
            
            Circle()
                .trim(from: 0, to: 0.7)
                .stroke(color, lineWidth: 3)
                .frame(width: 50, height: 50)
                .rotationEffect(Angle(degrees: isAnimating ? 360 : 0))
                .animation(
                    .linear(duration: 1)
                    .repeatForever(autoreverses: false),
                    value: isAnimating
                )
        }
        .onAppear { isAnimating = true }
    }
}
