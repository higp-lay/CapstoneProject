import SwiftUI
import Foundation

@available(iOS 13.0, macOS 12.0, *)
struct s1A2b: View {
    @Environment(\.dismiss) private var dismiss
    @State private var navigateToNext = false
    @State private var nextDestination: AnyView?
    var onComplete: (() -> Void)?
    
    static var initialDialogues: [DialogueItem] {
        [
            DialogueItem(
                text: "My life has officially come to an end. My heartbeat stops, my lungs eternally rest, and my brain runs out of power. And to my delight, my organs managed to help 12 people in total. And as I rest in peace, now I can look at Life from Death's eyes. I see the brevity of life compared to the eternity of death.",
                systemImage: "person.fill",
                speaker: "You"
            ),
            DialogueItem(
                text: "After all the hardships of being a single parent and battling cancer, one might expect me to seize any chance to extend my life. Yet, I've chosen not to have my stem cells extracted, as I no longer wish to prolong my existence.",
                systemImage: "person.fill",
                speaker: "You"
            ),
            DialogueItem(
                text: "Many participate in the extraction in hopes of experiencing a different life in a new era, but in fact there's no guarantee that this second life would be fulfilling. It could be far worse than enduring lifelong struggles, or it might confine me to a reality where I can no longer make my own choices. Living once was enough.",
                systemImage: "person.fill",
                speaker: "You"
            ),
            DialogueItem(
                text: "Life is like a short-lived candle. Death is eternal, like a candle quietly resting, while life burns fiercely, illuminating the darkness for a fleeting moment. That candle sat on the shelf for a long stretch of time. It flickers to life for just a few precious minutes before returning to the abyss, forgotten.",
                systemImage: "person.fill",
                speaker: "You"
            ),
            DialogueItem(
                text: "All of existence is in those brief bursts of light, and there is no need to reignite a flame that has already gone out. It fulfilled its purpose, and now it's time for me to go. I don't require a version of myself to re-emerge on Earth someday; that's simply unnecessary.",
                systemImage: "person.fill",
                speaker: "You"
            ),
            DialogueItem(
                text: "A life is worth the voyage ultimately because every soul is unique, be it good or bad—and I wholeheartedly embrace that.",
                systemImage: "person.fill",
                speaker: "You"
            )
        ]
    }
    
    var body: some View {
        NavigationStack {
            StoryView(
                title: "Acceptance",
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
        .withTerminalNodeConfetti()
        .onAppear {
            // Complete this scenario when it appears
            ProgressManager.shared.completeScenario("s1A2b")
            
            // Force UI update
            NotificationCenter.default.post(name: NSNotification.Name("ScenarioCompleted"), object: nil)
//            NotificationCenter.default.post(name: NSNotification.Name("ForceGameMapRefresh"), object: nil)
            
            // Unlock the specific achievement for this ending
            AchievementManager.shared.unlockAchievement(id: "one_life_is_enough")
            
            // Also unlock the general "reached terminal node" achievement
            AchievementManager.shared.checkTerminalNodeCompletion()
        }
    }
}

#if DEBUG
struct s1A2b_Previews: PreviewProvider {
    static var previews: some View {
        s1A2b()
    }
}
#endif 
