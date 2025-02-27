import SwiftUI

class TransitionManager: ObservableObject {
    static let shared = TransitionManager()
    
    // Prevent multiple instances
    private init() {}
    
    // Transition state for cross-node animations
    @Published var isTransitioning = false
    
    // Track the previous and next scenario for better transitions
    @Published var previousScenario: String?
    @Published var nextScenario: String?
    
    // Add a completion handler for transitions
    private var transitionCompletionHandler: (() -> Void)?
    
    // Add a flag to track if we're in the middle of a transition
    private var isInTransition = false
    
    // Add a method to force initialize a transition when navigating from the map
    func initializeMapTransition(to sceneName: String) {
        // Reset any ongoing transitions
        resetTransitionState()
        
        // Set the scenario names
        self.previousScenario = nil // Coming from map, no previous scenario
        self.nextScenario = sceneName
        
        // Set transitioning state to true immediately
        self.isTransitioning = true
        self.isInTransition = true
        
        // Schedule the transition to complete after a delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            withAnimation(.easeIn(duration: 0.4)) {
                self.isTransitioning = false
            }
            
            // Mark transition as complete
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                self.isInTransition = false
            }
        }
    }
    
    // Prepare a smooth transition to the next node
    func prepareTransition(from currentView: some View, to nextScenario: String, onComplete: (() -> Void)?) -> AnyView {
        // Update scenario tracking
        self.previousScenario = SceneManager.shared.currentScene
        self.nextScenario = nextScenario
        
        // Check if this is a parent-child transition
        let isParentChildTransition = SceneManager.shared.isTransitioningBetweenNodes(
            from: self.previousScenario ?? "",
            to: nextScenario
        )
        
        // Set transitioning state to true immediately
        self.isTransitioning = true
        self.isInTransition = true
        
        // Create the destination view with appropriate animation
        let destinationView = SceneManager.shared.getScene(nextScenario, onComplete: onComplete)
            .onAppear {
                // Ensure the view is fully loaded before starting the transition
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    // Use a slightly different animation timing based on transition type
                    if isParentChildTransition {
                        // Faster, smoother transition for parent-child navigation
                        withAnimation(.easeIn(duration: 0.4)) {
                            self.isTransitioning = false
                        }
                    } else {
                        // Standard transition for other navigations
                        withAnimation(.easeIn(duration: 0.5)) {
                            self.isTransitioning = false
                        }
                    }
                    
                    // Mark transition as complete
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                        self.isInTransition = false
                        
                        // Call completion handler if set
                        if let completion = self.transitionCompletionHandler {
                            completion()
                            self.transitionCompletionHandler = nil
                        }
                    }
                }
            }
        
        return AnyView(destinationView)
    }
    
    // Set a completion handler for the transition
    func setTransitionCompletion(_ completion: @escaping () -> Void) {
        self.transitionCompletionHandler = completion
    }
    
    // Force reset the transition state (use in emergency cases)
    func resetTransitionState() {
        if isInTransition {
            // Only reset if we're actually in a transition
            DispatchQueue.main.async {
                self.isTransitioning = false
                self.isInTransition = false
            }
        }
    }
    
    // Get a transition modifier for story nodes
    func getTransitionModifier() -> some ViewModifier {
        return TransitionViewModifier()
    }
}

// View modifier for smooth transitions
struct TransitionViewModifier: ViewModifier {
    @ObservedObject private var transitionManager = TransitionManager.shared
    
    func body(content: Content) -> some View {
        content
            .opacity(transitionManager.isTransitioning ? 0 : 1)
            .scaleEffect(transitionManager.isTransitioning ? 0.98 : 1.0)
            // Use combined animation for smoother effect
            .animation(.easeInOut(duration: 0.3), value: transitionManager.isTransitioning)
            // Prevent interaction during transitions
            .allowsHitTesting(!transitionManager.isTransitioning)
            // Add transition to ensure consistent behavior
            .transition(.opacity)
    }
}

// Extension to make it easier to apply the transition
extension View {
    func withSmoothTransition() -> some View {
        self.modifier(TransitionManager.shared.getTransitionModifier())
    }
} 
