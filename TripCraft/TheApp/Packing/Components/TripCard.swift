import SwiftUI
import Foundation

struct TripCard: View {
    let trip: Trip
    let itemCount: Int
    let onSelect: () -> Void
    let onDelete: () -> Void
    
    // Animation state
    @State private var isHovering = false
    
    // Formatted date range
    private var dateRangeText: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        return "\(formatter.string(from: trip.startDate)) - \(formatter.string(from: trip.endDate))"
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header with theme color and icon
            ZStack(alignment: .topLeading) {
                // Theme color bar
                Rectangle()
                    .fill(trip.theme?.color ?? Color.blue.opacity(0.8))
                    .frame(height: 8)
                
                VStack(alignment: .leading, spacing: 16) {
                    // Top section with trip info
                    HStack(alignment: .top) {
                        // Theme icon in circle
                        ZStack {
                            Circle()
                                .fill((trip.theme?.color ?? Color.blue).opacity(0.15))
                                .frame(width: 42, height: 42)
                            
                            Image(systemName: trip.theme?.icon ?? "airplane")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(trip.theme?.color ?? Color.blue)
                        }
                        .padding(.top, 12)
                        
                        // Trip details
                        VStack(alignment: .leading, spacing: 6) {
                            Text(trip.name)
                                .font(.system(size: 18, weight: .bold, design: .rounded))
                                .foregroundColor(.primary)
                                .lineLimit(1)
                            
                            Text(trip.destination)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .lineLimit(1)
                        }
                        .padding(.top, 14)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        
                        // Right actions
                        Button(action: onDelete) {
                            Image(systemName: "trash")
                                .foregroundColor(.red.opacity(0.7))
                                .font(.system(size: 15))
                                .frame(width: 36, height: 36)
                                .background(Color.red.opacity(0.1))
                                .clipShape(Circle())
                        }
                        .buttonStyle(ScaleButtonStyle())
                        .padding(.top, 12)
                    }
                    
                    // Date and stats
                    HStack(spacing: 12) {
                        // Date range
                        HStack(spacing: 6) {
                            Image(systemName: "calendar")
                                .font(.system(size: 13))
                                .foregroundColor(.blue.opacity(0.7))
                            Text(dateRangeText)
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        // Duration badge
                        HStack(spacing: 4) {
                            Image(systemName: "clock.fill")
                                .font(.system(size: 12))
                            Text("\(trip.duration) days")
                                .font(.system(size: 13, weight: .medium))
                        }
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.blue.opacity(0.15))
                        .foregroundColor(Color.blue.opacity(0.8))
                        .clipShape(Capsule())
                        
                        // Item count badge
                        HStack(spacing: 4) {
                            Image(systemName: "checklist")
                                .font(.system(size: 12))
                            Text("\(itemCount)")
                                .font(.system(size: 13, weight: .medium))
                        }
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.green.opacity(0.15))
                        .foregroundColor(Color.green.opacity(0.8))
                        .clipShape(Capsule())
                        
                        // Chevron
                        Image(systemName: "chevron.right")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.secondary.opacity(0.6))
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 16)
            }
        }
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 4)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.blue.opacity(0.1), lineWidth: 1)
        )
        .scaleEffect(isHovering ? 0.98 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isHovering)
        .onTapGesture {
            hapticFeedback()
            withAnimation {
                isHovering = true
            }
            
            // Delay to show press animation before navigating
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                onSelect()
                
                // Reset after navigation
                withAnimation {
                    isHovering = false
                }
            }
        }
    }
    
    // Haptic feedback for better UX
    private func hapticFeedback() {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
    }
} 