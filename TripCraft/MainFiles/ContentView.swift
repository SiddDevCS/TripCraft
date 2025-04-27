import SwiftUI

struct ContentView: View {
    @State private var selectedTab = 0
    @StateObject private var packingViewModel = PackingListViewModel()
    @Environment(\.colorScheme) private var colorScheme
    
    // Define colors - using standard SwiftUI colors to avoid conflicts
    private let primaryBlue = Color(red: 0.25, green: 0.55, blue: 1.0) // Similar to #3F8CFF
    private let lightBlue = Color(red: 0.82, green: 0.9, blue: 1.0) // Similar to #D0E5FF
    private let inactiveGray = Color.gray.opacity(0.6)
    
    // Fixed tab bar height
    private let tabBarHeight: CGFloat = 68
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .bottom) {
                TabView(selection: $selectedTab) {
                    NavigationStack {
                        PackingListView()
                            .environmentObject(packingViewModel)
                    }
                    .tag(0)
                    
                    NavigationStack {
                        JournalView()
                    }
                    .tag(1)
                    
                    NavigationStack {
                        TravelToolsView()
                    }
                    .tag(2)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .ignoresSafeArea(.keyboard, edges: .bottom)
                .ignoresSafeArea(.container, edges: .bottom)
                .padding(.bottom, tabBarHeight - 20) // Adjust content padding to account for floating tab bar
                
                // Modern floating tab bar
                customTabBar
                    .frame(height: tabBarHeight - 16)
                    .padding(.horizontal, 24)
                    .padding(.bottom, 12) // Give some space at the bottom
                    .background(
                        RoundedRectangle(cornerRadius: 28)
                            .fill(colorScheme == .dark ? Color(.systemGray6) : Color.white)
                            .shadow(color: Color.black.opacity(0.15), radius: 8, x: 0, y: 0)
                            .padding(.horizontal, 16)
                            .padding(.bottom, 8)
                    )
                    .ignoresSafeArea(edges: .bottom)
            }
        }
        .ignoresSafeArea(.keyboard, edges: .bottom)
    }
    
    private func safeAreaInsets(_ geometry: GeometryProxy) -> EdgeInsets {
        geometry.safeAreaInsets
    }
    
    var customTabBar: some View {
        HStack(spacing: 0) {
            ForEach(0..<3) { index in
                Button(action: {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        selectedTab = index
                    }
                }) {
                    VStack(spacing: 4) {
                        Image(systemName: getTabIconName(for: index))
                            .font(.system(size: 20, weight: selectedTab == index ? .semibold : .regular))
                            .foregroundColor(selectedTab == index ? primaryBlue : inactiveGray)
                            .frame(width: 48, height: 26) // Fixed icon frame
                            .background(
                                ZStack {
                                    if selectedTab == index {
                                        RoundedRectangle(cornerRadius: 14)
                                            .fill(lightBlue.opacity(colorScheme == .dark ? 0.3 : 0.4))
                                            .matchedGeometryEffect(id: "TAB_BACKGROUND", in: namespace)
                                    }
                                }
                            )
                        
                        Text(getTabTitle(for: index))
                            .font(.system(size: 10, weight: selectedTab == index ? .medium : .regular))
                            .foregroundColor(selectedTab == index ? primaryBlue : inactiveGray)
                    }
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(TabButtonStyle())
            }
        }
        .padding(.vertical, 8)
    }
    
    @Namespace private var namespace
    
    private func getTabIconName(for index: Int) -> String {
        switch index {
        case 0: return "checkmark.circle.fill"
        case 1: return "book.fill"
        case 2: return "gearshape.fill"
        default: return "questionmark"
        }
    }
    
    private func getTabTitle(for index: Int) -> String {
        switch index {
        case 0: return "Packing"
        case 1: return "Journal"
        case 2: return "Tools"
        default: return "Unknown"
        }
    }
}

// Custom button style to remove default button effects
struct TabButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1)
            .animation(.easeOut(duration: 0.2), value: configuration.isPressed)
    }
}

// MARK: - View Extensions
extension PackingListView {
    func withScrollTracking() -> some View {
        self
    }
}

extension JournalView {
    func withScrollTracking() -> some View {
        self
    }
}

extension TravelToolsView {
    func withScrollTracking() -> some View {
        self
    }
}
