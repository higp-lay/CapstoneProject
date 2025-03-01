import SwiftUI
import Foundation

@available(iOS 13.0, macOS 12.0, *)
struct s1A2a: View {
    @Environment(\.dismiss) private var dismiss
    @State private var navigateToNext = false
    @State private var nextDestination: AnyView?
    var onComplete: (() -> Void)?
    
    static var initialDialogues: [DialogueItem] {
            [
                DialogueItem(
                    text: "My life has been a journey woven with joy, sorrow, triumph, and loss. I've escaped the hands of cancer by bribing it with a sum of money. I've survived for another decade or so.",
                    speaker: "You"
                ),
                DialogueItem(
                    text: "And now that I am dead, I am glad to know that my donated organs managed to help 12 people in total. I had battled cancer, descended into depths of despair.",
                    speaker: "You"
                ),
                DialogueItem(
                    text: "Each hardship accompanied difficult choices I had to make, reminding me of the fragility of life and the beauty found within its uncertainties.",
                    speaker: "You"
                ),
                DialogueItem(
                    text: "I had thought deeply about the implications of having my stem cells extracted; there were so many uncertainties surrounding what would arise from my cells.",
                    speaker: "You"
                ),
                DialogueItem(
                    text: "I do not know whether future scientists can create life from my several cells. Even if they can, I do not know if a soul would be in this cell; and if there is; would it be mine?",
                    speaker: "You"
                ),
                DialogueItem(
                    text: "Would they truly lead to someone who bore my essence, or would they simply be a collection of moments, memories, and biology—a shadow of who I was?",
                    speaker: "You"
                ),
                DialogueItem(
                    text: "But if there is one thing I learnt from life, it is that there are always uncertainties. We are often uncertain about who we are when we are alive, and we question our identities from day to day.",
                    speaker: "You"
                ),
                DialogueItem(
                    text: "These uncertainties are a testament to our will. There was no way I could determine if the expensive cancer therapy would work, or if the stem cells I gave would become garbage.",
                    speaker: "You"
                ),
                DialogueItem(
                    text: "But all I do is that I live with those uncertainties. How boring would a life with certainties be?",
                    speaker: "You"
                ),
                DialogueItem(
                    text: "One day, I might stand on Earth again. Or, I might never. But at least I made a decision before I die, and I am at peace with the fact that the currents of uncertainty will lead me forward.",
                    speaker: "You"
                )
            ]
        }
    
    var body: some View {
        NavigationStack {
            StoryView(
                title: "Embracing Uncertainties",
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
            // Complete this scenario when it appears
            ProgressManager.shared.completeScenario("s1A2a")
            
            // Force UI update
            NotificationCenter.default.post(name: NSNotification.Name("ScenarioCompleted"), object: nil)
//            NotificationCenter.default.post(name: NSNotification.Name("ForceGameMapRefresh"), object: nil)
            
            // Unlock the specific achievement for this ending
            AchievementManager.shared.unlockAchievement(id: "embracing_uncertainty")
            
            // Also unlock the general "reached terminal node" achievement
            AchievementManager.shared.checkTerminalNodeCompletion()
        }
    }
}

#if DEBUG
struct s1A2a_Previews: PreviewProvider {
    static var previews: some View {
        s1A2a()
    }
}
#endif 
