import SwiftUI
import Foundation

@available(iOS 13.0, macOS 12.0, *)
struct s1A1b: View {
    @Environment(\.dismiss) private var dismiss
    @State private var navigateToNext = false
    @State private var nextDestination: AnyView?
    var onComplete: (() -> Void)?
    
    static var initialDialogues: [DialogueItem] {
        [
            DialogueItem(
                text: "My life? I chose to donate a fortune to a cancer fund. Don't mistake me for a savior; this money might only help save one child with that damn expensive treatment. But I could do it, so why not?",
                speaker: "You"
            ),
            DialogueItem(
                text: "My family has what they need, though I won't pretend that their lives are free from worry and hardship. In the end, those kids suffering from cancer need the funds more than my family does.",
                speaker: "You"
            ),
            DialogueItem(
                text: "I've endured rounds of chemo, feeling like I was spiraling down into a futureless abyss. And how much is a future worth to a young person? It's priceless.",
                speaker: "You"
            ),
            DialogueItem(
                text: "I know my time is limited after all I've endured, I feel it in my every breath. I'll probably go on a retreat when I'm about to die, to a remote place away from it all.",
                speaker: "You"
            ),
            DialogueItem(
                text: "I won't bring my children; I don't want them to witness my pain and suffering at the end of my journey. I don't want them to spend their time and energy trying to extend a life that feels nearly over.",
                speaker: "You"
            ),
            DialogueItem(
                text: "I've struggled long enough for life, and if my time is near, I will embrace it willingly.",
                speaker: "You"
            ),
            DialogueItem(
                text: "I'll spend my days writing about my thoughts on life and death, contemplating their meaning. Perhaps my dear children will read these reflections after I'm gone.",
                speaker: "You"
            ),
            DialogueItem(
                text: "Don't see this as a sad farewell; it's a celebration of living. I understand better than anyone that death is near and that life is fleeting. And—what's more—that's what makes life magical.",
                speaker: "You"
            )
        ]
    }
    
    var body: some View {
        NavigationStack {
            StoryView(
                title: "Compassion",
                dialogues: Self.initialDialogues,
                choices: [],
                onComplete: onComplete,
                onMakeChoice: { _ in },
                onDismiss: {
                    // Call the onComplete handler to return to the map
                    if let complete = onComplete {
                        complete()
                    }
                    dismiss()
                }
            )
            .navigationDestination(isPresented: $navigateToNext) {
                if let destination = nextDestination {
                    destination
                }
            }
        }
        .onAppear {
            // Complete this scenario when it appears
            ProgressManager.shared.completeScenario("s1A1b")
            
            // Force UI update
            NotificationCenter.default.post(name: NSNotification.Name("ScenarioCompleted"), object: nil)
//            NotificationCenter.default.post(name: NSNotification.Name("ForceGameMapRefresh"), object: nil)
            
            // Unlock the specific achievement for this ending
            AchievementManager.shared.unlockAchievement(id: "legacy_of_compassion")
            
            // Also unlock the general "reached terminal node" achievement
            AchievementManager.shared.checkTerminalNodeCompletion()
        }
    }
}

#if DEBUG
struct s1A1b_Previews: PreviewProvider {
    static var previews: some View {
        s1A1b()
    }
}
#endif 
