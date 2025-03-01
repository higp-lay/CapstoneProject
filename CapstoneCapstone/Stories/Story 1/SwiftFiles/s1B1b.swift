import SwiftUI
import Foundation

@available(iOS 13.0, macOS 12.0, *)
struct s1B1b: View {
    @Environment(\.dismiss) private var dismiss
    @State private var navigateToNext = false
    @State private var nextDestination: AnyView?
    var onComplete: (() -> Void)?
    
    static var initialDialogues: [DialogueItem] {
        [
            DialogueItem(
                text: "My life can only be described as a miracle, and I am profoundly grateful for it. After so many rounds of chemotherapy, I knew I could have died at any moment; my will to survive could have crumbled under the weight of pain in any second.",
                speaker: "You"
            ),
            DialogueItem(
                text: "Yet, I am continually impressed by how that willpower triumphed over the suffering I endured—for myself and for my family. Because I survived, I was blessed with another decade or two to share with them. We created beautiful memories together, and I can confidently say it was worth every tear I shed.",
                speaker: "You"
            ),
            DialogueItem(
                text: "Eventually, I did not choose cryonics. Life is already filled with uncertainties; I had fought through countless moments without knowing if my efforts were in vain or what the best course of action was. The thought of my loved ones grappling with the ambiguity of my death—wondering if I might return—is unsettling.",
                speaker: "You"
            ),
            DialogueItem(
                text: "It creates a strange conflict: should they mourn me, or hold on to the hope that I am still alive? This turmoil would linger as long as I remained suspended at -196 degrees Celsius.",
                speaker: "You"
            ),
            DialogueItem(
                text: "I would rather they accept my death and celebrate the life we shared, cherishing the moments we had together. That, to me, is my death wish.",
                speaker: "You"
            )
        ]
    }
    
    var body: some View {
        NavigationStack {
            StoryView(
                title: "Nature Dictates",
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
            ProgressManager.shared.completeScenario("s1B1b")
            
            // Force UI update
            NotificationCenter.default.post(name: NSNotification.Name("ScenarioCompleted"), object: nil)
//            NotificationCenter.default.post(name: NSNotification.Name("ForceGameMapRefresh"), object: nil)
            
            // Unlock the specific achievement for this ending
            AchievementManager.shared.unlockAchievement(id: "acceptance_and_closure")
            
            // Also unlock the general "reached terminal node" achievement
            AchievementManager.shared.checkTerminalNodeCompletion()
        }
    }
}

#if DEBUG
struct s1B1b_Previews: PreviewProvider {
    static var previews: some View {
        s1B1b()
    }
}
#endif 
