import SwiftUI
import Foundation

@available(iOS 13.0, macOS 12.0, *)
struct s1B2: View {
    @Environment(\.dismiss) private var dismiss
    @State private var navigateToNext = false
    @State private var nextDestination: AnyView?
    @State private var hasNavigated = false
    var onComplete: (() -> Void)?
    
    static var initialDialogues: [DialogueItem] {
        [
            DialogueItem(
                text: "The sun spilled golden light through my window each morning, casting warm patches on the floor that danced with my every heartbeat. The vibrant colors of spring spilled into my room like an embrace, a relief from the long, painful months I had endured with chemotherapy.",
                speaker: "You"
            ),
            DialogueItem(
                text: "It had been a grueling journey, marked by days shrouded in fatigue and moments of despair. But the shift to palliative care transformed my experience profoundly.",
                speaker: "You"
            ),
            DialogueItem(
                text: "No longer did I wake each day to the weight of relentless treatments; instead, I was enveloped in a cocoon of comfort that allowed me to savor life's simple pleasures.",
                speaker: "You"
            ),
            DialogueItem(
                text: "In these gentle days, I found joy in the little things. My children visited and their laughter brightened my otherwise dim existence. With their exhausted eyes after a day of work, they shared their stories, their voices rising and falling in the cadence of childhood.",
                speaker: "You"
            ),
            DialogueItem(
                text: "I could also have a taste of Christina's delicious pastries as I was no longer under the nauseating chemotherapy. And, what's more, I get to see Christina's new child—my beloved granddaughter.",
                speaker: "You"
            ),
            DialogueItem(
                text: "As I caressed her forehead resting in my arms, her small, bright eyes filled the room with warmth. We played games, her tiny fingers wrapping around mine, and I reveled in her innocent laughter.",
                speaker: "You"
            ),
            DialogueItem(
                text: "But as the seasons changed, so did my health. The vibrant energy that had slowly crept back into our lives began to wither, much like the leaves that turned brittle and fell. I could sense the shift in the room when my children came to visit—an unspoken heaviness hung in the air, weighing upon their shoulders and mine.",
                speaker: "You"
            ),
            DialogueItem(
                text: "My breaths had become labored, the days growing shorter. My children had visibly aged too after spending many of their evenings with me in my small, dishevelled home.",
                speaker: "You"
            ),
            DialogueItem(
                text: "The lightness I cherished began to fade, and the laughter that had once filled the space felt distant as the inevitable pressed closer. The inevitable that my children and I never verbalised.",
                speaker: "You"
            ),
            DialogueItem(
                text: "In the quiet evenings, when the house was hushed and the darkness settled around me like a heavy blanket, I was confronted with the stark reality of my condition.",
                speaker: "You"
            ),
            DialogueItem(
                text: "I would sometimes catch glimpses of despair etched into Mark's forehead, Christina's frown, and Nick's distracted smile, and my heart ached for the burdens I had placed upon them.",
                speaker: "You"
            ),
            DialogueItem(
                text: "I had hoped to shield them from hurt, but in my frailty, I could see the toll my condition had taken on their spirits. And soon, I had to move into the palliative care centre, leaving the house that I did not know if I would ever step into once more.",
                speaker: "You"
            ),
            DialogueItem(
                text: "During casual conversations with the nurses at the centre, the topic subtly shifted from comfort measures to rather poignant considerations about quality of life.",
                speaker: "You"
            ),
            DialogueItem(
                text: "They spoke kindly, but there was an undercurrent in their words that drew my attention—choices that I had pushed aside in healthier days were now inching into my consciousness. The idea of euthanasia floated in the air, a word heavy with implications, a possibility whispering in my ear.",
                speaker: "You"
            ),
            DialogueItem(
                text: "'Is it wrong to think about this?' I asked one nurse, the words escaping my lips before I could catch them.",
                speaker: "You"
            ),
            DialogueItem(
                text: "Her gaze was steady, compassionate.",
                speaker: "You"
            ),
            DialogueItem(
                text: "It's not wrong - you're not the only one. It's natural to seek peace for yourself and your family when you're in pain.'",
                speaker: "Nurse"
            ),
            DialogueItem(
                text: "Those words echoed in my mind, stirring an emotional tempest. I grappled with conflicting feelings—the desire for an end to my suffering and a deep-seated fear of leaving my children reeling from my absence. I envisioned their futures without the lingering shadows of grief that had no due date.",
                speaker: "You"
            ),
            DialogueItem(
                text: "As I lay there, pondering the road before me, I slowly accepted that euthanasia was a possibility on my journey, a choice I hadn't considered before.",
                speaker: "You"
            ),
            DialogueItem(
                text: "Yet, I found myself standing at the precipice of that decision, torn between the pain my body and soul was suffering and the palpable love tethering me to this world; and between the mere struggle of survival and the simple pursuit of peace.",
                speaker: "You"
            )
        ]
    }
    
    var choices: [Choice] {
        [
            Choice(
                text: "Agree to euthanasia",
                systemImage: "peacesign",
                unlocksScenario: "s1B2a"
            ),
            Choice(
                text: "Refuse euthanasia",
                systemImage: "xmark.circle.fill",
                unlocksScenario: "s1B2b"
            )
        ]
    }
    
    // Create a custom onComplete handler that ensures it's only called once
    private var safeOnComplete: (() -> Void)? {
        guard let originalOnComplete = onComplete else { return nil }
        
        return {
            // Only call the original onComplete if we haven't navigated
            if !self.hasNavigated {
                print("s1B2.safeOnComplete called, hasNavigated=\(self.hasNavigated)")
                originalOnComplete()
            }
        }
    }
    
    var body: some View {
        NavigationStack {
            StoryView(
                title: "Dignity",
                dialogues: Self.initialDialogues,
                choices: choices,
                onComplete: safeOnComplete, // Use the safe wrapper
                onMakeChoice: makeChoice,
                onDismiss: {
                    if hasNavigated {
                        return
                    }
                    
                    if let complete = onComplete {
                        print("s1B2.onDismiss calling onComplete")
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
        .onDisappear {
            print("s1B2.onDisappear called, resetting state")
            navigateToNext = false
            nextDestination = nil
            hasNavigated = false
        }
    }
    
    private func makeChoice(_ choice: Choice) {
        guard !hasNavigated else { return }
        
        print("s1B2.makeChoice called with choice: \(choice.text)")
        hasNavigated = true
        
        if choice.text.contains("Agree") {
            ProgressManager.shared.unlockScenario("s1B2a")
            ProgressManager.shared.completeScenario("s1B2")
            
            NotificationCenter.default.post(name: NSNotification.Name("ScenarioUnlocked"), object: nil)
            NotificationCenter.default.post(name: NSNotification.Name("ScenarioCompleted"), object: nil)
//            NotificationCenter.default.post(name: NSNotification.Name("ForceGameMapRefresh"), object: nil)
            
            // Pass the original onComplete to ensure proper navigation chain
            nextDestination = AnyView(SceneManager.shared.getScene("s1B2a", onComplete: onComplete))
            navigateToNext = true
            
            // Debug print to track navigation
            print("Navigating from s1B2 to s1B2a with onComplete: \(String(describing: onComplete))")
        } else {
            ProgressManager.shared.unlockScenario("s1B2b")
            ProgressManager.shared.completeScenario("s1B2")
            
            NotificationCenter.default.post(name: NSNotification.Name("ScenarioUnlocked"), object: nil)
            NotificationCenter.default.post(name: NSNotification.Name("ScenarioCompleted"), object: nil)
//            NotificationCenter.default.post(name: NSNotification.Name("ForceGameMapRefresh"), object: nil)
            
            // Pass the original onComplete to ensure proper navigation chain
            nextDestination = AnyView(SceneManager.shared.getScene("s1B2b", onComplete: onComplete))
            navigateToNext = true
            
            // Debug print to track navigation
            print("Navigating from s1B2 to s1B2b with onComplete: \(String(describing: onComplete))")
        }
    }
}

#if DEBUG
struct s1B2_Previews: PreviewProvider {
    static var previews: some View {
        s1B2()
    }
}
#endif
