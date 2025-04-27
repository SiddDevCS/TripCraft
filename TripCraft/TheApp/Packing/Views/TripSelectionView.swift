import SwiftUI

struct TripSelectionView: View {
    @ObservedObject var viewModel: PackingListViewModel
    @Environment(\.colorScheme) private var colorScheme
    let onTripSelected: (Trip) -> Void
    let onCreateTapped: () -> Void
    let onDeleteTrip: (Trip) -> Void
    
    // Animation properties
    @State private var animateCards = false
    @State private var headerAppeared = false
    @State private var showEmptyState = false
    
    var body: some View {
        ZStack {
            // Beautiful background with subtle gradient and decorative elements
            backgroundView
            
            // Empty state when no trips exist
            if viewModel.trips.isEmpty {
                ScrollView {
                    emptyStateView
                        .opacity(showEmptyState ? 1 : 0)
                        .animation(.easeIn(duration: 0.4).delay(0.3), value: showEmptyState)
                        .frame(minHeight: UIScreen.main.bounds.height - 100)
                }
            } else {
                // Main content with trips
                ScrollView {
                    VStack(spacing: 0) {
                        // Modern header with visual elements
                        VStack(spacing: 16) {
                            // Icon with animation
                            ZStack {
                                Circle()
                                    .fill(
                                        LinearGradient(
                                            gradient: Gradient(colors: [.blue.opacity(0.15), .blue.opacity(0.25)]),
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .frame(width: 92, height: 92)
                                
                                Image(systemName: "suitcase.rolling.fill")
                                    .font(.system(size: 38))
                                    .foregroundColor(.blue)
                                    .symbolEffect(.bounce, options: .repeating, value: animateCards)
                                    .symbolEffect(.pulse, options: .repeating, value: headerAppeared)
                            }
                            .padding(.top, 50)
                            .scaleEffect(headerAppeared ? 1 : 0.8)
                            .opacity(headerAppeared ? 1 : 0)
                            
                            Text("Your Trips")
                                .font(.system(size: 32, weight: .bold, design: .rounded))
                                .foregroundColor(.primary)
                                .opacity(headerAppeared ? 1 : 0)
                                .offset(y: headerAppeared ? 0 : 10)
                            
                            Text("Select a trip to view or edit its packing list")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                                .fixedSize(horizontal: false, vertical: true)
                                .padding(.horizontal, 40)
                                .padding(.bottom, 8)
                                .opacity(headerAppeared ? 1 : 0)
                                .offset(y: headerAppeared ? 0 : 10)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.bottom, 12)
                        .padding(.top, 20)
                        .animation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.1), value: headerAppeared)
                        
                        // Trip count badge
                        Text("\(viewModel.trips.count) \(viewModel.trips.count == 1 ? "Trip" : "Trips")")
                            .font(.system(size: 14, weight: .semibold, design: .rounded))
                            .padding(.horizontal, 14)
                            .padding(.vertical, 7)
                            .background(
                                Capsule()
                                    .fill(Color.blue.opacity(0.15))
                            )
                            .foregroundColor(.blue)
                            .padding(.bottom, 20)
                            .opacity(headerAppeared ? 1 : 0)
                            .scaleEffect(headerAppeared ? 1 : 0.8)
                        
                        // Trip List with grouped style
                        LazyVStack(spacing: 24) {
                            ForEach(Array(viewModel.trips.enumerated()), id: \.element.id) { index, trip in
                                TripCard(
                                    trip: trip, 
                                    itemCount: viewModel.packingItemsForTrip(tripId: trip.id).count,
                                    onSelect: { onTripSelected(trip) },
                                    onDelete: { onDeleteTrip(trip) }
                                )
                                .scaleEffect(animateCards ? 1 : 0.92)
                                .opacity(animateCards ? 1 : 0)
                                .offset(y: animateCards ? 0 : 20)
                                .animation(
                                    .spring(response: 0.5, dampingFraction: 0.7)
                                    .delay(0.2 + Double(index) * 0.07), 
                                    value: animateCards
                                )
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 100) // Add padding for the button
                    }
                }
            }
            
            // Floating action button for adding new trip
            VStack {
                Spacer()
                
                Button(action: onCreateTapped) {
                    HStack(spacing: 12) {
                        Image(systemName: "plus")
                            .font(.system(size: 18, weight: .bold))
                        Text("New Trip")
                            .font(.system(size: 17, weight: .semibold, design: .rounded))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        ZStack {
                            RoundedRectangle(cornerRadius: 18)
                                .fill(LinearGradient(
                                    gradient: Gradient(colors: [Color.blue, Color.blue.opacity(0.8)]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                ))
                            
                            // Subtle shine effect
                            RoundedRectangle(cornerRadius: 18)
                                .fill(LinearGradient(
                                    gradient: Gradient(colors: [Color.white.opacity(0.3), Color.white.opacity(0)]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ))
                                .padding(1)
                        }
                    )
                    .foregroundColor(.white)
                    .cornerRadius(18)
                    .shadow(color: Color.blue.opacity(0.3), radius: 10, x: 0, y: 5)
                }
                .buttonStyle(ScaleButtonStyle())
                .padding(.horizontal, 20)
                .padding(.bottom, 80) // Significantly increase bottom padding
                .opacity(headerAppeared ? 1 : 0)
                .offset(y: headerAppeared ? 0 : 20)
                .animation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.5), value: headerAppeared)
            }
        }
        .onAppear {
            // Animate cards when view appears
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation {
                    headerAppeared = true
                }
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                withAnimation {
                    animateCards = true
                    showEmptyState = true
                }
            }
        }
    }
    
    // Custom background view with decorative elements
    private var backgroundView: some View {
        ZStack {
            // Base background
            LinearGradient(
                gradient: Gradient(colors: [
                    colorScheme == .dark ? Color.black : Color.white,
                    colorScheme == .dark ? Color.black.opacity(0.95) : Color.blue.opacity(0.06)
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            // Decorative elements
            GeometryReader { geometry in
                let width = geometry.size.width
                let height = geometry.size.height
                
                // Top right bubble
                Circle()
                    .fill(Color.blue.opacity(0.12))
                    .frame(width: width * 0.4)
                    .position(x: width * 0.95, y: height * 0.05)
                    .blur(radius: 50)
                
                // Middle right bubble
                Circle()
                    .fill(Color.purple.opacity(0.04))
                    .frame(width: width * 0.3)
                    .position(x: width * 0.85, y: height * 0.45)
                    .blur(radius: 30)
                
                // Bottom left bubble
                Circle()
                    .fill(Color.blue.opacity(0.07))
                    .frame(width: width * 0.6)
                    .position(x: width * 0.1, y: height * 0.92)
                    .blur(radius: 40)
            }
        }
    }
    
    // Empty state view
    private var emptyStateView: some View {
        VStack(spacing: 24) {
            Image(systemName: "backpack.fill")
                .font(.system(size: 70))
                .foregroundColor(.blue.opacity(0.7))
                .symbolEffect(.pulse, options: .repeating, value: showEmptyState)
            
            Text("No Trips Yet")
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundColor(.primary)
            
            Text("Create your first trip to start planning your packing list")
                .font(.system(size: 17))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            Spacer().frame(height: 30)
            
            // Get started button
            Button(action: onCreateTapped) {
                HStack(spacing: 12) {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 20))
                    Text("Create First Trip")
                        .font(.system(size: 17, weight: .semibold, design: .rounded))
                }
                .frame(width: 220)
                .padding(.vertical, 16)
                .background(
                    ZStack {
                        RoundedRectangle(cornerRadius: 18)
                            .fill(LinearGradient(
                                gradient: Gradient(colors: [Color.blue, Color.blue.opacity(0.8)]),
                                startPoint: .leading,
                                endPoint: .trailing
                            ))
                        
                        // Subtle shine effect
                        RoundedRectangle(cornerRadius: 18)
                            .fill(LinearGradient(
                                gradient: Gradient(colors: [Color.white.opacity(0.3), Color.white.opacity(0)]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ))
                            .padding(1)
                    }
                )
                .foregroundColor(.white)
                .cornerRadius(18)
                .shadow(color: Color.blue.opacity(0.3), radius: 10, x: 0, y: 5)
            }
            .buttonStyle(ScaleButtonStyle())
        }
        .padding()
        .offset(y: -40)
    }
} 