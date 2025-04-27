import SwiftUI

// MARK: - Custom button style for scale animation on press
extension ButtonStyle {
    static var scaleEffect: some ButtonStyle {
        ScaleButtonStyle()
    }
}

struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.96 : 1)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
    }
} 