import SwiftUI

struct EmptyTripStateView: View {
    let trip: Trip?
    let aiService: AIService
    let onAIAssistantTapped: () -> Void
    let onAddItemTapped: () -> Void
    let onBackTapped: () -> Void
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            ScrollView {
                ZStack {
                    // Background gradient
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color.blue.opacity(0.05),
                            Color.clear
                        ]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .ignoresSafeArea()
                    
                    VStack(spacing: 40) {
                        // Heading with illustration
                        VStack(spacing: 24) {
                            ZStack {
                                Circle()
                                    .fill(Color.blue.opacity(0.08))
                                    .frame(width: 120, height: 120)
                                
                                if let tripTheme = trip?.theme {
                                    Image(systemName: tripTheme.icon)
                                        .font(.system(size: 40))
                                        .foregroundColor(tripTheme.color)
                                        .scaleEffect(1.2)
                                } else {
                                    Image(systemName: "checklist")
                                        .font(.system(size: 40))
                                        .foregroundColor(.blue)
                                }
                            }
                            .padding(.top, 40)
                            
                            VStack(spacing: 12) {
                                Text("Let's Pack for \(trip?.name ?? "Your Trip")")
                                    .font(.system(size: 24, weight: .bold, design: .rounded))
                                    .multilineTextAlignment(.center)
                                    .lineLimit(nil)
                                    .fixedSize(horizontal: false, vertical: true)
                                    .padding(.horizontal)
                                
                                Text("How would you like to create your packing list?")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal)
                            }
                        }
                        
                        // Creation options with card design
                        VStack(spacing: 20) {
                            PackingCreationOptionCard(
                                icon: "wand.and.stars",
                                title: "AI Packing Assistant",
                                description: "Get smart suggestions based on your trip details",
                                remainingUses: aiService.getRemainingPrompts(),
                                accentColor: .blue,
                                isMain: true,
                                action: onAIAssistantTapped
                            )
                            
                            PackingCreationOptionCard(
                                icon: "list.bullet.clipboard",
                                title: "Custom Packing List",
                                description: "Create your own list from scratch",
                                accentColor: .indigo,
                                isMain: false,
                                action: onAddItemTapped
                            )
                            
                            // Back button card
                            PackingCreationOptionCard(
                                icon: "arrow.left",
                                title: "Change Trip",
                                description: "Go back to your trip list",
                                accentColor: .gray,
                                isMain: false,
                                action: onBackTapped
                            )
                        }
                        .padding(.horizontal)
                        
                        // Progress indicator
                        if let trip = trip {
                            HStack {
                                Image(systemName: "calendar")
                                    .foregroundColor(.secondary)
                                
                                let days = Calendar.current.dateComponents([.day], from: Date(), to: trip.startDate).day ?? 0
                                if days > 0 {
                                    Text("\(days) days until your trip")
                                        .font(.footnote)
                                        .foregroundColor(.secondary)
                                } else if days == 0 {
                                    Text("Your trip is today!")
                                        .font(.footnote)
                                        .foregroundColor(.blue)
                                        .fontWeight(.medium)
                                } else {
                                    Text("Trip in progress")
                                        .font(.footnote)
                                        .foregroundColor(.green)
                                        .fontWeight(.medium)
                                }
                            }
                            .padding(.bottom, 16)
                        }
                    }
                    .padding()
                    .frame(minHeight: UIScreen.main.bounds.height - 100)
                }
            }
            
            // Back button in top left
            Button(action: onBackTapped) {
                HStack(spacing: 4) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 14, weight: .semibold))
                    Text("Back")
                        .font(.system(size: 16, weight: .medium))
                }
                .foregroundStyle(.blue)
                .padding(12)
            }
            .buttonStyle(ScaleButtonStyle())
            .padding(.leading, 16)
            .padding(.top, 16)
        }
    }
} 
