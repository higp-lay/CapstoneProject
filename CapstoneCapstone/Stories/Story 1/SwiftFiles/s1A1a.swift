import SwiftUI
import Foundation

@available(iOS 13.0, macOS 12.0, *)
struct s1A1a: View {
    @Environment(\.dismiss) private var dismiss
    @State private var navigateToNext = false
    @State private var nextDestination: AnyView?
    @ObservedObject private var transitionManager = TransitionManager.shared
    @State private var dialoguesReady = false
    @State private var isExiting = false
    var onComplete: (() -> Void)?
    
    static var initialDialogues: [DialogueItem] {
        [
            DialogueItem(
                text: "My life is peaceful and enjoyable now. I can afford to visit my children often and don't need to work as hard. We indulge in good food, go on holidays together, and cherish what may be my last few years as a family.",
                systemImage: "person.fill",
                speaker: "You"
            ),
            DialogueItem(
                text: "I know my time is limited. I can feel it in every footstep I take. But I no longer fear death. I've faced it, been closer to it than I am right now, and I choose to savor every moment with my loved ones.",
                systemImage: "person.fill",
                speaker: "You"
            ),
            DialogueItem(
                text: "Thoughts sometimes drift through my mind. I think about Flynn and wonder if he will manage to survive another 20 years, maybe even 30. I keep him in my thoughts, hoping for the best. ",
                systemImage: "person.fill",
                speaker: "You"
            ),
            DialogueItem(
                text: "Occasionally, I thought about the kids with cancer who I could have donated to help. Their bright futures and innocent faces remind me of my own children, and I can't help but tear up a little. It's a complex feeling, balancing my own happiness with the desire to help others. But I keep them in my thoughts too.",
                systemImage: "person.fill",
                speaker: "You"
            ),
            DialogueItem(
                text: "But if nothing goes wrong, I should be able to live happily for a few more years. And who knows? By then, Mark might be married, and Christina might have a child. More importantly, I hope I will be there.",
                systemImage: "person.fill",
                speaker: "You"
            )
        ]
    }
    
    var body: some View {
        NavigationStack {
            StoryView(
                title: "Family First",
                dialogues: Self.initialDialogues,
                choices: [],
                onComplete: onComplete,
                onMakeChoice: { _ in },
                onDismiss: {
                    // This is a terminal node, so we should directly call onComplete
                    // and dismiss without trying to navigate to another scene
                    if let complete = onComplete {
                        complete()
                    }
                    
                    // Ensure we're not setting navigateToNext to true
                    navigateToNext = false
                    
                    // Dismiss this view to return to the map
                    dismiss()
                }
            )
            // We don't need this navigationDestination for terminal nodes
            // since we never want to navigate further
        }
        .onAppear {
            // Force reset transition state to ensure we're not stuck in a transition
            transitionManager.resetTransitionState()
            
            // Reset transition state when view appears
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                withAnimation(.easeIn(duration: 0.3)) {
                    transitionManager.isTransitioning = false
                }
                
                // Mark dialogues as ready after transition completes
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    dialoguesReady = true
                }
            }
            
            // Complete this scenario when it appears
            ProgressManager.shared.completeScenario("s1A1a")
            
            // Force UI update
            NotificationCenter.default.post(name: NSNotification.Name("ScenarioCompleted"), object: nil)
//            NotificationCenter.default.post(name: NSNotification.Name("ForceGameMapRefresh"), object: nil)
            
            // Unlock the specific achievement for this ending
            AchievementManager.shared.unlockAchievement(id: "family_first")
            
            // Also unlock the general "reached terminal node" achievement
            AchievementManager.shared.checkTerminalNodeCompletion()
        }
    }
}

#if DEBUG
struct s1A1a_Previews: PreviewProvider {
    static var previews: some View {
        s1A1a()
    }
}
#endif 
