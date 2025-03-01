import SwiftUI
import Foundation

@available(iOS 13.0, macOS 12.0, *)
struct s1B2b: View {
    @Environment(\.dismiss) private var dismiss
    @State private var navigateToNext = false
    @State private var nextDestination: AnyView?
    @State private var hasCompleted = false
    var onComplete: (() -> Void)?
    
    static var initialDialogues: [DialogueItem] {
        [
            DialogueItem(
                text: "My life was worth the journey. One might say there were many mishaps. I lost my partner, got cancer, didn't manage to receive a transplant, suffered a lot near the end of my life…",
                speaker: "You"
            ),
            DialogueItem(
                text: "I never lived to get the chance to take a break from all the hustle. I did not manage to see Mark or Nick getting married—if they at all did.",
                speaker: "You"
            ),
            DialogueItem(
                text: "Life is a brief-lived candle, and the fact is, no joy is guaranteed for the self. Some might feel they are burning in an inferno, while some feel that they are illuminating the world.",
                speaker: "You"
            ),
            DialogueItem(
                text: "But if life is a brief-lived candle, all I wish for is that I get lit for as long as I can, and then pass the light on to others.",
                speaker: "You"
            ),
            DialogueItem(
                text: "But anyhow, I was fortunate enough to make my own choices in life. My choice was to ensure that my children live a good life.",
                speaker: "You"
            ),
            DialogueItem(
                text: "You see, if I had paid for that expensive therapy, I might live for another 10 years. 15 years? But my kids would have a hard life.",
                speaker: "You"
            ),
            DialogueItem(
                text: "At least now they inherited my lottery money, pensions and savings. I know, from my experience, how worrying about money can be such a hurdle to enjoying life.",
                speaker: "You"
            ),
            DialogueItem(
                text: "On Earth we might not be the lucky ones, but I'm glad to have made my children the luckier ones. That's all that matters to me.",
                speaker: "You"
            )
        ]
    }
    
    // Create a custom onComplete handler that ensures it's only called once
    private var safeOnComplete: (() -> Void)? {
        guard let originalOnComplete = onComplete else { return nil }
        
        return {
            // Only call the original onComplete if we haven't completed
            if !self.hasCompleted {
                self.hasCompleted = true
                print("s1B2b.safeOnComplete called, calling original onComplete")
                originalOnComplete()
            }
        }
    }
    
    var body: some View {
        NavigationStack {
            StoryView(
                title: "Passing on the Light",
                dialogues: Self.initialDialogues,
                choices: [],
                onComplete: safeOnComplete, // Use the safe wrapper
                onMakeChoice: { _ in },
                onDismiss: {
                    guard !hasCompleted else { return }
                    hasCompleted = true
                    
                    if let complete = onComplete {
                        print("s1B2b.onDismiss calling onComplete")
                        complete()
                    }
                    
                    navigateToNext = false
                    
                    dismiss()
                }
            )
        }
        .onAppear {
            print("s1B2b.onAppear called with onComplete: \(String(describing: onComplete))")
            ProgressManager.shared.completeScenario("s1B2b")
            
            NotificationCenter.default.post(name: NSNotification.Name("ScenarioCompleted"), object: nil)
//            NotificationCenter.default.post(name: NSNotification.Name("ForceGameMapRefresh"), object: nil)
            
            // Unlock the specific achievement for this ending
            AchievementManager.shared.unlockAchievement(id: "passing_the_light")
            
            // Also unlock the general "reached terminal node" achievement
            AchievementManager.shared.checkTerminalNodeCompletion()
        }
        .onDisappear {
            print("s1B2b.onDisappear called, hasCompleted=\(hasCompleted)")
            hasCompleted = false
        }
    }
}

#if DEBUG
struct s1B2b_Previews: PreviewProvider {
    static var previews: some View {
        s1B2b()
    }
}
#endif 
