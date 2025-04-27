import SwiftUI
import Foundation

struct ThemeSelectionButton: View {
    let theme: PackingTripTheme
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(theme.color.opacity(0.15))
                        .frame(width: 60, height: 60)
                    
                    Image(systemName: theme.icon)
                        .font(.system(size: 28))
                        .foregroundColor(theme.color)
                }
                
                Text(theme.rawValue)
                    .font(.headline)
                    .fontWeight(isSelected ? .semibold : .regular)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(isSelected ? Color.blue.opacity(0.1) : Color(.systemGray6))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 2)
                    )
            )
            .foregroundColor(isSelected ? .blue : .primary)
        }
        .buttonStyle(ScaleButtonStyle())
    }
} 