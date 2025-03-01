//
//  1A1.swift
//  CapstoneCapstone
//
//  Created by Hugo Lau on 25/2/2025.
//

import SwiftUI
import Foundation

@available(iOS 13.0, macOS 12.0, *)
struct s1A1: View {
    @Environment(\.dismiss) private var dismiss
    @State private var navigateToNext = false
    @State private var nextDestination: AnyView?
    var onComplete: (() -> Void)?
    
    static var initialDialogues: [DialogueItem] {
        [
            DialogueItem(
                text: "A few days later, I was finally able to sit up. I felt a mix of nervousness and anticipation as I prepared to meet Flynn, the man who had received my kidney.",
                speaker: "You"
            ),
            DialogueItem(
                text: "Flynn was in his late forties, with salt-and-pepper hair and warm, expressive eyes that seemed to have carried a lot.",
                speaker: "You"
            ),
            DialogueItem(
                text: "Hi there, I'm Flynn.",
                speaker: "Flynn"
            ),
            DialogueItem(
                text: "Hi, I'm—well, I guess you know who I am.",
                speaker: "You"
            ),
            DialogueItem(
                text: "We settled into a conversation as Flynn shared his story about him battling with renal failure. I shared mine being a single parent, fighting cancer—using up pretty much all my money, getting old.",
                speaker: "You"
            ),
            DialogueItem(
                text: "To be honest \(UserSettingsManager.shared.currentSettings.playerName), I never thought I'd have a new chance at life.",
                speaker: "Flynn"
            ),
            DialogueItem(
                text: "I wanted to help. It's incredible to hear how much this means to you.",
                speaker: "You"
            ),
            DialogueItem(
                text: "I'm actually a reporter. I've covered stories about organ donation and the impact it has on families for years. But experiencing it from this side… it's a whole different world. Perhaps I should write about my experience too, man.",
                speaker: "Flynn"
            ),
            DialogueItem(
                text: "I can relate to the uncertainty you felt. I'm a single parent, and I faced my own battle with cancer. I underwent countless rounds of chemotherapy and had to make tough decisions about expensive medications. Somehow, I survived miraculously.",
                speaker: "You"
            ),
            DialogueItem(
                text: "It wasn't easy. Life after the treatment has been difficult; I still struggle with the side effects of the drugs and the emotional toll it took on me. There were days when I felt completely defeated, but my children kept me going.",
                speaker: "You"
            ),
            DialogueItem(
                text: "After everything I went through, donating my kidney felt like a way to pay it forward. I wanted to give someone else the chance to experience life, just as I had been given.",
                speaker: "You"
            ),
            DialogueItem(
                text: "You know what, let me write about you, mate. Not just the donation, but your whole journey. I believe it will resonate with so many people.",
                speaker: "Flynn"
            ),
            DialogueItem(
                text: "Me? I thought you said you're gonna write about your journey. I'm just an ordinary old dude you know.",
                speaker: "You"
            ),
            DialogueItem(
                text: "Exactly. Ordinary people can do extraordinary things. Your story needs to be told.",
                speaker: "Flynn"
            ),
            DialogueItem(
                text: "Should you wait until you have recovered?",
                speaker: "You"
            ),
            DialogueItem(
                text: "As I prepared to discharge from the hospital, I felt a renewed sense of purpose. Flynn promised to keep in touch, and as he left, I couldn't shake the feeling that our paths had crossed for a reason. And that a part of my abdomen emptied, a part of me was fulfilled to have helped.",
                speaker: "You"
            ),
            DialogueItem(
                text: "In the following weeks, as Flynn's article gained traction, I was overwhelmed by people reaching out with their heartfelt gratitude and admiration.",
                speaker: "You"
            ),
            DialogueItem(
                text: "Amidst the discourse, a fundraiser was organized in my honor, aimed at helping those who faced similar struggles. The total sum was staggering after a week–I guess that's the power of social media...",
                speaker: "You"
            )
        ]
    }
    
    var choices: [Choice] {
        [
            Choice(
                text: "Spend the money on family",
                systemImage: "heart.fill",
                unlocksScenario: "s1A1a"
            ),
            Choice(
                text: "Donate to cancer charity",
                systemImage: "gift.fill",
                unlocksScenario: "s1A1b"
            )
        ]
    }
    
    var body: some View {
        NavigationStack {
            StoryView(
                title: "Self and Strangers",
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
        if choice.text.contains("Spend the money") {
            // First unlock and complete scenarios
            ProgressManager.shared.unlockScenario("s1A1a")
            ProgressManager.shared.completeScenario("s1A1")
            
            // Force UI update
            NotificationCenter.default.post(name: NSNotification.Name("ScenarioUnlocked"), object: nil)
            NotificationCenter.default.post(name: NSNotification.Name("ScenarioCompleted"), object: nil)
//            NotificationCenter.default.post(name: NSNotification.Name("ForceGameMapRefresh"), object: nil)
            
            // Direct navigation to the next scene instead of dismissing
            nextDestination = AnyView(SceneManager.shared.getScene("s1A1a", onComplete: onComplete))
            navigateToNext = true
        } else {
            // First unlock and complete scenarios
            ProgressManager.shared.unlockScenario("s1A1b")
            ProgressManager.shared.completeScenario("s1A1")
            
            // Force UI update
            NotificationCenter.default.post(name: NSNotification.Name("ScenarioUnlocked"), object: nil)
            NotificationCenter.default.post(name: NSNotification.Name("ScenarioCompleted"), object: nil)
//            NotificationCenter.default.post(name: NSNotification.Name("ForceGameMapRefresh"), object: nil)
            
            // Direct navigation to the next scene instead of dismissing
            nextDestination = AnyView(SceneManager.shared.getScene("s1A1b", onComplete: onComplete))
            navigateToNext = true
        }
    }
}

#if DEBUG
struct s1A1_Previews: PreviewProvider {
    static var previews: some View {
        s1A1()
    }
}
#endif

