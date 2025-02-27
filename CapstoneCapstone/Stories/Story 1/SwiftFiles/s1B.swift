import SwiftUI
import Foundation

@available(iOS 13.0, macOS 12.0, *)
struct s1B: View {
    @Environment(\.dismiss) private var dismiss
    @State private var navigateToNext = false
    @State private var nextDestination: AnyView?
    var onComplete: (() -> Void)?
    
    static var initialDialogues: [DialogueItem] {
        [
            DialogueItem(
                text: "Days passed by. Hours. Minutes. Then seconds. They felt like a battle I was losing. The chemotherapy had left me weak and borderline cynical, each treatment draining more of my strength. I sat in the living room, watching the sunlight filter through the curtains, yet I could not help feeling darkness creeping in.",
                systemImage: "person.fill",
                speaker: "You"
            ),
            DialogueItem(
                text: "Mark had moved back into my house to help care for me. He juggled his own work while taking on the responsibilities I could no longer manage. I heard him sighing in the kitchen, the sound of pots clanging as he prepared meals I could barely take in. Guilt washed over me, knowing he was making sacrifices to care for me.",
                systemImage: "person.fill",
                speaker: "You"
            ),
            DialogueItem(
                text: "Christina had just started her own family. I could see the worry in her eyes when she visited. She should have been enjoying her new role as a wife, but instead, she was caught between her responsibilities and her love for me. I hated that I was pulling her away from the joy she deserved.",
                systemImage: "person.fill",
                speaker: "You"
            ),
            DialogueItem(
                text: "Then there was Nick. I couldn't help but feel like a weight dragging him down. I wanted to tell him to focus on his career, to chase his dreams, that he didn't need to come a few times a week. But I knew he still felt the need to be here, to support his older brother and me.",
                systemImage: "person.fill",
                speaker: "You"
            ),
            DialogueItem(
                text: "The day of my appointment with Dr. Morris arrived. In the doctor's office, I sensed the gravity of the moment as he reviewed my results. His face was serious, and I braced myself for what was to come.",
                systemImage: "person.fill",
                speaker: "You"
            ),
            DialogueItem(
                text: "The chemotherapy hasn't produced the results we hoped for.",
                systemImage: "person.fill",
                speaker: "Dr. Morris"
            ),
            DialogueItem(
                text: "A wave of hopelessness washed over me. I had clung to the belief that each session was a step toward healing, but now I felt as if the ground had crumbled beneath me. We discussed options—continuing with another round of therapy or considering palliative care.",
                systemImage: "person.fill",
                speaker: "You"
            ),
            DialogueItem(
                text: "Palliative care can be an option, and it doesn't mean we give up on treating the tumour, but rather it simply focuses on relieving your symptoms. And if you choose to continue therapy, we can try a new combo of drugs and therapies to fight the tumour.",
                systemImage: "person.fill",
                speaker: "Dr. Morris"
            ),
            DialogueItem(
                text: "The options hung in the air, heavy and foreboding. Palliative care did feel like surrendering, yet there was a part of me that longed for relief from the pain and uncertainty. I looked into the doctor's eyes, searching for a glimmer of hope, but all I saw was the stark reality of my situation.",
                systemImage: "person.fill",
                speaker: "You"
            ),
            DialogueItem(
                text: "As I left the office, my heart was heavy with the burden of the decision ahead. I knew that whatever path I chose would not only affect me but also my family, who had already sacrificed so much.",
                systemImage: "person.fill",
                speaker: "You"
            )
        ]
    }
    
    var choices: [Choice] {
        [
            Choice(
                text: "Continue standard therapy",
                consequence: "You decide to continue with standard therapy, hoping for a breakthrough in your treatment.",
                systemImage: "pills.fill",
                unlocksScenario: "s1B1"
            ),
            Choice(
                text: "Turn to palliative care",
                consequence: "You choose palliative care, focusing on quality of life and symptom management.",
                systemImage: "heart.fill",
                unlocksScenario: "s1B2"
            )
        ]
    }
    
    var body: some View {
        NavigationStack {
            StoryView(
                title: "The Reason Why",
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
        if choice.text.contains("Continue standard therapy") {
            // First unlock and complete scenarios
            ProgressManager.shared.unlockScenario("s1B1")
            ProgressManager.shared.completeScenario("s1B")
            
            // Force UI update
            NotificationCenter.default.post(name: NSNotification.Name("ScenarioUnlocked"), object: nil)
            NotificationCenter.default.post(name: NSNotification.Name("ScenarioCompleted"), object: nil)
//            NotificationCenter.default.post(name: NSNotification.Name("ForceGameMapRefresh"), object: nil)
            
            // Direct navigation to the next scene instead of dismissing
            nextDestination = AnyView(SceneManager.shared.getScene("s1B1", onComplete: onComplete))
            navigateToNext = true
        } else {
            // First unlock and complete scenarios
            ProgressManager.shared.unlockScenario("s1B2")
            ProgressManager.shared.completeScenario("s1B")
            
            // Force UI update
            NotificationCenter.default.post(name: NSNotification.Name("ScenarioUnlocked"), object: nil)
            NotificationCenter.default.post(name: NSNotification.Name("ScenarioCompleted"), object: nil)
//            NotificationCenter.default.post(name: NSNotification.Name("ForceGameMapRefresh"), object: nil)
            
            // Direct navigation to the next scene instead of dismissing
            nextDestination = AnyView(SceneManager.shared.getScene("s1B2", onComplete: onComplete))
            navigateToNext = true
        }
    }
}

#if DEBUG
struct s1B_Previews: PreviewProvider {
    static var previews: some View {
        s1B()
    }
}
#endif

