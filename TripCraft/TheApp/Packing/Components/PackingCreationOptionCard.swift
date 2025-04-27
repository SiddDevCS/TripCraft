import SwiftUI
import Foundation

// Card view for packing list creation options
struct PackingCreationOptionCard: View {
    let icon: String
    let title: String
    let description: String
    var remainingUses: Int? = nil
    let accentColor: Color
    let isMain: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                // Left icon
                ZStack {
                    Circle()
                        .fill(accentColor.opacity(0.15))
                        .frame(width: 50, height: 50)
                    
                    Image(systemName: icon)
                        .font(.system(size: 22))
                        .foregroundColor(accentColor)
                }
                
                // Text content
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text(description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    if let uses = remainingUses {
                        HStack(spacing: 4) {
                            if uses > 0 {
                                Text("\(uses) uses remaining")
                                    .font(.caption2)
                                    .foregroundColor(accentColor)
                            } else {
                                Text("No uses remaining")
                                    .font(.caption2)
                                    .foregroundColor(.red)
                            }
                        }
                        .padding(.top, 2)
                    }
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.secondary)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(.systemBackground))
                    .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 4)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(isMain ? accentColor.opacity(0.3) : Color.clear, lineWidth: isMain ? 2 : 0)
            )
        }
        .buttonStyle(ScaleButtonStyle())
        .disabled(remainingUses == 0)
    }
} 