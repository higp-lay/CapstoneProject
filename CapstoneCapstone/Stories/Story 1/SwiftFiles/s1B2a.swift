import SwiftUI
import Foundation

@available(iOS 13.0, macOS 12.0, *)
struct s1B2a: View {
    @Environment(\.dismiss) private var dismiss
    @State private var navigateToNext = false
    @State private var nextDestination: AnyView?
    @State private var hasCompleted = false
    var onComplete: (() -> Void)?
    
    static var initialDialogues: [DialogueItem] {
        [
            DialogueItem(
                text: "My life ended with strength. It was short—perhaps shorter than it might have been. For two years, or maybe more, I endured the inferno of malignancy. My family and I lived in a pain that escalated daily. It felt futile to continue; I sensed my soul slowly slipping away, and no medication could change that.",
                speaker: "You"
            ),
            DialogueItem(
                text: "Life should end, and I wished for it to conclude with dignity and strength. Some people might argue that I should prolong life for as long as I can, but what makes the opportunity to live outweigh all suffering in that moment?",
                speaker: "You"
            ),
            DialogueItem(
                text: "Some might also ask if I regret my decisions. Honestly, I find peace in them. If I had chosen that expensive therapy, who knows if I would have been gone in two years anyway? I didn't want to leave my children burdened by financial strain.",
                speaker: "You"
            ),
            DialogueItem(
                text: "We shouldn't regret choices based solely on negative outcomes; rather, we should regret when we don't feel what we hoped for. I envisioned financial stability for my family, a pause in my suffering, and the ability to end my life on my terms with strength. And I achieved all three.",
                speaker: "You"
            )
        ]
    }
    
    private var safeOnComplete: (() -> Void)? {
        guard let originalOnComplete = onComplete else { return nil }
        
        return {
            if !self.hasCompleted {
                self.hasCompleted = true
                print("s1B2a.safeOnComplete called, calling original onComplete")
                originalOnComplete()
            }
        }
    }
    
    var body: some View {
        NavigationStack {
            StoryView(
                title: "Strength in Endings",
                dialogues: Self.initialDialogues,
                choices: [],
                onComplete: safeOnComplete,
                onMakeChoice: { _ in },
                onDismiss: {
                    guard !hasCompleted else { return }
                    hasCompleted = true
                    
                    if let complete = onComplete {
                        print("s1B2a.onDismiss calling onComplete")
                        complete()
                    }
                    
                    navigateToNext = false
                    
                    dismiss()
                }
            )
        }
        .onAppear {
            print("s1B2a.onAppear called with onComplete: \(String(describing: onComplete))")
            ProgressManager.shared.completeScenario("s1B2a")
            
            NotificationCenter.default.post(name: NSNotification.Name("ScenarioCompleted"), object: nil)
//            NotificationCenter.default.post(name: NSNotification.Name("ForceGameMapRefresh"), object: nil)
            
            AchievementManager.shared.unlockAchievement(id: "ending_with_dignity")
            
            AchievementManager.shared.checkTerminalNodeCompletion()
        }
        .onDisappear {
            print("s1B2a.onDisappear called, hasCompleted=\(hasCompleted)")
            hasCompleted = false
        }
    }
}

#if DEBUG
struct s1B2a_Previews: PreviewProvider {
    static var previews: some View {
        s1B2a()
    }
}
#endif 
