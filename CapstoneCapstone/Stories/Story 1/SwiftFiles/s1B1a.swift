import SwiftUI
import Foundation

@available(iOS 13.0, macOS 12.0, *)
struct s1B1a: View {
    @Environment(\.dismiss) private var dismiss
    @State private var navigateToNext = false
    @State private var nextDestination: AnyView?
    var onComplete: (() -> Void)?
    
    static var initialDialogues: [DialogueItem] {
        [
            DialogueItem(
                text: "My life was almost over after the first round of chemo, and I declined the expensive treatment. It was just so damn pricey that I wouldn't want my children to worry about money in the future. I love my family, and for that, I continued with the more affordable therapy.",
                systemImage: "person.fill",
                speaker: "You"
            ),
            DialogueItem(
                text: "It was truly miraculous that I survived; when cancer was about to engulf me, my body found a way to untangle itself. This is why I chose cryonics. I didn't want my life to end here. In some way, I felt that there were so many adventures left to experience and crossroads I had never made my choice in.",
                systemImage: "person.fill",
                speaker: "You"
            ),
            DialogueItem(
                text: "I wanted another chance to live, especially since I had enough money now, and doing cryonics didn't burden my children. I look forward to living a second life on Earth again, because the first one was too short and I hadn't enjoyed it to the fullest. Life is so worth celebrating, so why not have another go?",
                systemImage: "person.fill",
                speaker: "You"
            ),
            DialogueItem(
                text: "Now, I find myself observing my own funeral, suspended in a state of quiet contemplation. Mark stands at the front, his face a mix of sorrow and confusion, unsure whether to mourn or celebrate my decision. Christina clutches Nick's hand, her eyes glistening, sharing the same turmoil of emotions swirling within her.",
                systemImage: "person.fill",
                speaker: "You"
            ),
            DialogueItem(
                text: "They seem to wrestle with the weight of loss while grappling with the hope that my story isn't truly over. I wish I could comfort them, to assure them that this isn't an end but merely a pause, a chance for a new beginning.",
                systemImage: "person.fill",
                speaker: "You"
            ),
            DialogueItem(
                text: "I can't help but feel a bittersweet sense of peace as I watch them navigate their feelings, knowing that, in a way, I'm still here, waiting for the next chapter.",
                systemImage: "person.fill",
                speaker: "You"
            )
        ]
    }
    
    var body: some View {
        NavigationStack {
            StoryView(
                title: "Second Chance",
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
            ProgressManager.shared.completeScenario("s1B1a")
            
            // Force UI update
            NotificationCenter.default.post(name: NSNotification.Name("ScenarioCompleted"), object: nil)
//            NotificationCenter.default.post(name: NSNotification.Name("ForceGameMapRefresh"), object: nil)
            
            // Unlock the specific achievement for this ending
            AchievementManager.shared.unlockAchievement(id: "a_pause_not_an_end")
            
            // Also unlock the general "reached terminal node" achievement
            AchievementManager.shared.checkTerminalNodeCompletion()
        }
    }
}

#if DEBUG
struct s1B1a_Previews: PreviewProvider {
    static var previews: some View {
        s1B1a()
    }
}
#endif 
