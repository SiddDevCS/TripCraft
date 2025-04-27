import SwiftUI

struct EmptyStateView: View {
    let onCreateTapped: () -> Void
    
    var body: some View {
        ScrollView {
            ZStack {
                // Background gradient
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color.blue.opacity(0.1),
                        Color.blue.opacity(0.05)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack(spacing: 32) {
                    Spacer()
                    
                    // Illustration with animation
                    ZStack {
                        Circle()
                            .fill(Color.blue.opacity(0.12))
                            .frame(width: 180, height: 180)
                        
                        Circle()
                            .fill(Color.blue.opacity(0.08))
                            .frame(width: 220, height: 220)
                        
                        Image(systemName: "airplane.circle.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 100, height: 100)
                            .foregroundColor(.blue)
                            .rotationEffect(.degrees(-45))
                            .shadow(color: .blue.opacity(0.5), radius: 10, x: 0, y: 5)
                    }
                    .padding(.bottom, 20)
                    .padding(.top, 40)
                    
                    Text("Start Your Packing Journey")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .multilineTextAlignment(.center)
                        .lineLimit(nil)
                        .foregroundColor(.primary)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.horizontal, 20)
                    
                    Text("Create your first packing list to ensure you never forget essential items for your trips.")
                        .font(.body)
                        .multilineTextAlignment(.center)
                        .foregroundStyle(.secondary)
                        .padding(.horizontal, 32)
                        .padding(.bottom, 16)
                    
                    // Action button with shadow and animation
                    Button(action: onCreateTapped) {
                        HStack(spacing: 12) {
                            Image(systemName: "plus.circle.fill")
                                .font(.system(size: 20))
                            
                            Text("Create First Packing List")
                                .fontWeight(.semibold)
                        }
                        .frame(minWidth: 240)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.blue)
                        )
                        .foregroundColor(.white)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color.white.opacity(0.2), lineWidth: 1)
                        )
                        .shadow(color: Color.blue.opacity(0.5), radius: 8, x: 0, y: 4)
                    }
                    .buttonStyle(ScaleButtonStyle())
                    
                    Spacer()
                    
                    // App branding
                    HStack {
                        Image(systemName: "suitcase.fill")
                            .foregroundColor(.blue.opacity(0.7))
                        Text("TripCraft")
                            .font(.system(.footnote, design: .rounded))
                            .fontWeight(.medium)
                            .foregroundColor(.secondary)
                    }
                    .padding(.bottom, 16)
                }
                .padding()
                .frame(minHeight: UIScreen.main.bounds.height - 100)
            }
        }
    }
} 