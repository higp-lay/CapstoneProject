import SwiftUI
import Combine

class ConfettiManager: ObservableObject {
    static let shared = ConfettiManager()
    
    @Published var showConfetti = false
    @Published var confettiOrigin: CGPoint? = nil
    private var cancellables = Set<AnyCancellable>()
    
    private init() {
        // Remove automatic confetti trigger on scenario completion
    }
    
    func triggerConfetti(from origin: CGPoint? = nil) {
        // Set the origin point for the confetti
        confettiOrigin = origin
        
        // Show confetti
        withAnimation {
            showConfetti = true
        }
        
        // Hide confetti after 3 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) { [weak self] in
            withAnimation {
                self?.showConfetti = false
                self?.confettiOrigin = nil
            }
        }
    }
} 