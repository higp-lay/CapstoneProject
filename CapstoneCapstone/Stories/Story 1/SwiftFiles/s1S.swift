import SwiftUI
import Foundation

@available(iOS 13.0, macOS 12.0, *)
struct s1S: View {
    @Environment(\.dismiss) private var dismiss
    @State private var navigateToNext = false
    @State private var nextDestination: AnyView?
    var onComplete: (() -> Void)?
    
    static var initialDialogues: [DialogueItem] {
        [
            DialogueItem(
                text: "Hey \(UserSettingsManager.shared.currentSettings.playerName)!",
                speaker: "Narrator"
            ),
            DialogueItem(
                text: "Before we enter the story...",
                speaker: "Narrator"
            ),
            DialogueItem(
                text: "Think about this.",
                speaker: "Narrator"
            ),
            DialogueItem(
                text: "Is your life a matter of...",
                speaker: "Narrator"
            ),
        ]
    }
    
    var choices: [Choice] {
        [
            Choice(
                text: "Living",
                systemImage: "waveform.path.ecg",
                unlocksScenario: "s1"
            ),
            Choice(
                text: "Not dying",
                systemImage: "shield.fill",
                unlocksScenario: "s1"
            )
        ]
    }
    
    var body: some View {
        NavigationStack {
            StoryView(
                title: "Why We Live",
                dialogues: Self.initialDialogues,
                choices: choices,
                onComplete: onComplete,
                onMakeChoice: makeChoice,
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
    }
    
    private func makeChoice(_ choice: Choice) {
        // First unlock and complete scenarios
        ProgressManager.shared.unlockScenario("s1")
        ProgressManager.shared.completeScenario("s1S")
        AchievementManager.shared.unlockAchievement(id: "first_decision")
        
        // Force UI update
        NotificationCenter.default.post(name: NSNotification.Name("ScenarioUnlocked"), object: nil)
        NotificationCenter.default.post(name: NSNotification.Name("ScenarioCompleted"), object: nil)
        
        // Direct navigation to the next scene instead of dismissing
        nextDestination = AnyView(SceneManager.shared.getScene("s1", onComplete: onComplete))
        navigateToNext = true
    }
}

#if DEBUG
struct s1S_Previews: PreviewProvider {
    static var previews: some View {
        s1S()
    }
}
#endif
