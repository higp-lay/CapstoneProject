//
//  1A2.swift
//  CapstoneCapstone
//
//  Created by Hugo Lau on 25/2/2025.
//

import SwiftUI
import Foundation

@available(iOS 13.0, macOS 12.0, *)
struct s1A2: View {
    @Environment(\.dismiss) private var dismiss
    @State private var navigateToNext = false
    @State private var nextDestination: AnyView?
    @ObservedObject private var transitionManager = TransitionManager.shared
    @State private var dialoguesReady = false
    var onComplete: (() -> Void)?
    
    static var initialDialogues: [DialogueItem] {
        [
            DialogueItem(
                text: "After much thought and seeing the increasing worries on my family's faces, I made the difficult decision to forgo the kidney donation. Yet, every time I thought of the people on the long waiting list, a subtle feeling of guilt crept in. I couldn't entirely quell my urge to contribute.",
                speaker: "You"
            ),
            DialogueItem(
                text: "Therefore, immediately after deciding not to proceed with living donation, I signed up for posthumous organ donation. It seemed a fitting compromise, a way to extend my compassion beyond my lifetime.",
                speaker: "You"
            ),
            DialogueItem(
                text: "My family gladly agreed, understanding my desire to help others even when I was no longer here. Yet, the shadow of guilt lingered, a quiet reminder of the sacrifice I had chosen to forgo…",
                speaker: "You"
            ),
            DialogueItem(
                text: "For the next five years, I lived a peaceful life and I found joy in simple moments—a walk in the park, laughter around the dinner table, and quiet evenings with a good old book. During this time, I also became involved in community activities, advocating for organ donation and sharing my own story with those around me.",
                speaker: "You"
            ),
            DialogueItem(
                text: "Each day brought new reflections on my choices and their implications, deepening my appreciation for the time I had with my loved ones. And as day passed by and I grew old, I started to contemplate death once again. Death. My old friend.",
                speaker: "You"
            ),
            DialogueItem(
                text: "It was during one of these quiet moments that I stumbled upon an intriguing opportunity. A leading research institution was seeking elderly volunteers to have their stem cells extracted, with the hope that one day, when technology advanced, these cells could be used to grow a new person with their DNA.",
                speaker: "You"
            ),
            DialogueItem(
                text: "With their pioneering research, they were confident that such things would be possible in less than 20 years.",
                speaker: "You"
            ),
            DialogueItem(
                text: "I took a leaflet from the community centre and studied it back at home. It felt interesting the more I thought about it. Not the extraction itself, but how it made me feel.",
                speaker: "You"
            ),
            DialogueItem(
                text: "The procedure was harmless and low-cost, but the idea that someone could potentially be grown from my cells in the future filled me with a peculiar mix of emotions. It's a wonderfully simple procedure like blood-taking—which I'm no stranger to.",
                speaker: "You"
            ),
            DialogueItem(
                text: "Yet as a consequence, some years down the line, there might be a clone of me on the planet. The strong juxtaposition stirred up emotions within me, ones that I could merely describe as unusually exciting while frightening. Would they be a continuation of me, or simply a separate entity with my genetic material?",
                speaker: "You"
            ),
            DialogueItem(
                text: "Who would I be, if I am not unique? What would death mean, if a few cells are kept alive?",
                speaker: "You"
            )
        ]
    }
    
    var choices: [Choice] {
        [
            Choice(
                text: "Agree to stem cell extraction",
                systemImage: "waveform.path",
                unlocksScenario: "s1A2a"
            ),
            Choice(
                text: "Refuse stem cell extraction",
                systemImage: "xmark.circle.fill",
                unlocksScenario: "s1A2b"
            )
        ]
    }
    
    var body: some View {
        NavigationStack {
            StoryView(
                title: "Identity",
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
            .withSmoothTransition()
            .navigationDestination(isPresented: $navigateToNext) {
                if let destination = nextDestination {
                    destination
                }
            }
        }
        .onAppear {
            // Force reset transition state to ensure we're not stuck in a transition
            transitionManager.resetTransitionState()
            
            // Reset transition state when view appears
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                withAnimation(.easeIn(duration: 0.3)) {
                    transitionManager.isTransitioning = false
                }
                
                // Mark dialogues as ready after transition completes
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    dialoguesReady = true
                }
            }
        }
    }
    
    private func makeChoice(_ choice: Choice) {
        if choice.text.contains("Agree") {
            // First unlock and complete scenarios
            ProgressManager.shared.unlockScenario("s1A2a")
            ProgressManager.shared.completeScenario("s1A2")
            
            // Force UI update
            NotificationCenter.default.post(name: NSNotification.Name("ScenarioUnlocked"), object: nil)
            NotificationCenter.default.post(name: NSNotification.Name("ScenarioCompleted"), object: nil)
//            NotificationCenter.default.post(name: NSNotification.Name("ForceGameMapRefresh"), object: nil)
            
            // Direct navigation to the next scene instead of dismissing
            nextDestination = AnyView(SceneManager.shared.getScene("s1A2a", onComplete: onComplete))
            navigateToNext = true
        } else {
            // First unlock and complete scenarios
            ProgressManager.shared.unlockScenario("s1A2b")
            ProgressManager.shared.completeScenario("s1A2")
            
            // Force UI update
            NotificationCenter.default.post(name: NSNotification.Name("ScenarioUnlocked"), object: nil)
            NotificationCenter.default.post(name: NSNotification.Name("ScenarioCompleted"), object: nil)
//            NotificationCenter.default.post(name: NSNotification.Name("ForceGameMapRefresh"), object: nil)
            
            // Direct navigation to the next scene instead of dismissing
            nextDestination = AnyView(SceneManager.shared.getScene("s1A2b", onComplete: onComplete))
            navigateToNext = true
        }
    }
}

#if DEBUG
struct s1A2_Previews: PreviewProvider {
    static var previews: some View {
        s1A2()
    }
}
#endif

