import SwiftUI

extension View {
    /// Adds confetti celebration to a view when it appears
    func withTerminalNodeConfetti() -> some View {
        self.modifier(TerminalNodeConfettiModifier())
    }
}

/// A view modifier that adds confetti celebration to terminal nodes
struct TerminalNodeConfettiModifier: ViewModifier {
    @ObservedObject private var confettiManager = ConfettiManager.shared
    
    func body(content: Content) -> some View {
        ZStack {
            content
            
            if confettiManager.showConfetti {
                ConfettiView()
                    .allowsHitTesting(false)
                    .zIndex(100)
            }
        }
    }
} 