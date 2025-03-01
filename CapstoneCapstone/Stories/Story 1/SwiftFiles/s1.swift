import SwiftUI
import Foundation

@available(iOS 13.0, macOS 12.0, *)
struct s1: View {
    @Environment(\.dismiss) private var dismiss
    @State private var navigateToNext = false
    @State private var nextDestination: AnyView?
    var onComplete: (() -> Void)?
    
    static var initialDialogues: [DialogueItem] {
        [
            DialogueItem(
                text: "I was wrapped in a cocoon of anxiety as I sat in the small room, fingers tapping nervously on the plastic armrest. The ticking clock was the only indication that time was moving forward, yet it felt suspended as I waited for the news to be delivered.",
                speaker: "You"
            ),
            DialogueItem(
                text: "When Dr. Morris finally entered, 'Good afternoon', he began, his voice steady but gentle. In my mind I had prepared for the worst, after all those worrisome Google searches I did prior to the appointment. My heart raced, a drumbeat of dread echoing in my ears.",
                speaker: "You"
            ),
            DialogueItem(
                text: "I think we should discuss your test results.",
                speaker: "Dr. Morris"
            ),
            DialogueItem(
                text: "I thought back to the years of raising my three children as a single parent. I could see them wide-eyed with wonder, and hear their laughter echoing through our cramped apartment. The four of us had fought against the tide of grief after losing my beloved one.",
                speaker: "You"
            ),
            DialogueItem(
                text: "We fought as a family, as a team and as friends. Twenty years had passed since that fateful day, yet the ache of loss had never fully left me.",
                speaker: "You"
            ),
            DialogueItem(
                text: "After all those years, my life had finally begun to stabilize as my kids were grown, each branching out into the world. My youngest child, Nick, who had just graduated, just found a job at a corporate's office. All those years of sacrifice, sleepless nights, and worry had not been in vain.",
                speaker: "You"
            ),
            DialogueItem(
                text: "Then I had won the lottery. I had developed the habit of buying lottery tickets once in a while since the passing of my partner. When life was tough and the light at the end of the tunnel was not to be seen, a dream of luck comforted me a little.",
                speaker: "You"
            ),
            DialogueItem(
                text: "It wasn't an astronomical sum though, a sum just enough to buy 4 Teslas—the cheapest kind. But it did allow me freedom to leave the corporate grind behind, retire at 55, and finally step into the life I had always dreamt of having.",
                speaker: "You"
            ),
            DialogueItem(
                text: "Two weeks prior, I had visited the clinic after experiencing a worsening fatigue that draped over me like a heavy blanket. At first, I attributed it to the emotional and physical toll of raising my children alone for two decades.",
                speaker: "You"
            ),
            DialogueItem(
                text: "From what I heard from my friends, it is absolutely normal to be totally exhausted after retirement. Maybe this fatigue was just my body's way of asking for a break—a demand years in the making.",
                speaker: "You"
            ),
            DialogueItem(
                text: "The doctor leaned forward, paused for a few seconds, and announced the verdict.",
                speaker: "You"
            ),
            DialogueItem(
                text: "\(UserSettingsManager.shared.currentSettings.playerName), you have liver cancer, and it's an aggressive form. We need to start treatment immediately. Chemotherapy would be…",
                speaker: "Dr. Morris"
            ),
            DialogueItem(
                text: "Liver cancer. I had prepared myself for this possibility—it was written on one of the web pages I had visited.",
                speaker: "You"
            ),
            DialogueItem(
                text: "Yet the word echoed in my mind like a cruel joke and I felt my world falling apart. It was like when my first child was born. We thought we had already prepared for labour, but when the contractions started it went out of control.",
                speaker: "You"
            ),
            DialogueItem(
                text: "Liver cancer. As if it was the name of a new friend. And I will have to live with it side by side for the next few months. The weight of liver cancer was pressing down on me, threatening to vacuum out the hope I could finally embrace.",
                speaker: "You"
            ),
            DialogueItem(
                text: "'What will happen next?' I asked, my voice betraying a tremor I could not suppress.",
                speaker: "You"
            ),
            DialogueItem(
                text: "We'll start chemotherapy right away. You're not alone in this.",
                speaker: "Dr. Morris"
            ),
            DialogueItem(
                text: "As the weight of his words spread across my mind, I took a deep breath, trying to merge anxiety with a flicker of determination. Just as I had faced the challenges of raising three children on my own, perhaps I could confront this battle, too.",
                speaker: "You"
            ),
            DialogueItem(
                text: "I told my kids about it. Allow me to omit the details. I hate to cry while I write. Three months had passed since I complied with my eldest son, Mark's, adamant request of moving into my place.",
                speaker: "You"
            ),
            DialogueItem(
                text: "I agreed under the condition that he persuaded the other two to not care about me too much and focus on their own lives. Christina deserved time with her new husband while Nick needed to fight for a bright career. Their focus should not be on a feeble old man.",
                speaker: "You"
            ),
            DialogueItem(
                text: "As I laid there during my first round of chemotherapy, I felt nothing—neither physically or emotionally. It was as though I was stuck on a train barreling down a trackless route, lost, with no destination in sight.",
                speaker: "You"
            ),
            DialogueItem(
                text: "It seemed absurd that I could have retired and be content to explore passions I had long shelved, only now to find myself on the brink of what could be the end, that I'm no longer retiring from work, but perhaps retiring from life.",
                speaker: "You"
            ),
            DialogueItem(
                text: "I was encased in the sterile white of the treatment room, IV fluids humming quietly as they flowed through me. Friends and family tried to convince me that I would emerge from this stronger, but I knew that I was waving at Death. Death. Perhaps soon another friend of mine.",
                speaker: "You"
            ),
            DialogueItem(
                text: "Once you wave at Death, however, survival feels so tangible. It hummed in my fatigued muscles throughout the day. The chemotherapy promised to eradicate cancer, yet I felt its intrusion into my body instead.",
                speaker: "You"
            ),
            DialogueItem(
                text: "Not only am I fighting liver cancer, my body where this battle is fought, with soldiers trampling over my every sinew. When the day for my next doctor's appointment arrived, I felt that I had aged ten years.",
                speaker: "You"
            ),
            DialogueItem(
                text: "The muted colors of the clinic had become all too familiar over the past few months. When I finally sat in the small examination room, I felt a growing sense of dread that was about to engulf me.",
                speaker: "You"
            ),
            DialogueItem(
                text: "Once in the consultation room, I sat opposite Dr. Morris, who shuffled through papers, occasionally glancing up at me, his face a mask of professionalism. I fidgeted with the hem of my unironed shirt, waiting for the words that would make the torment I had been suffering worthwhile.",
                speaker: "You"
            ),
            DialogueItem(
                text: "But as Dr. Morris finally spoke, my heart sank.",
                speaker: "You"
            ),
            DialogueItem(
                text: "I'm afraid the results aren't what we had hoped for,",
                speaker: "Dr. Morris"
            ),
            DialogueItem(
                text: "He said softly, the disappointment palpable in his tone and in the air.",
                speaker: "You"
            ),
            DialogueItem(
                text: "The chemotherapy isn't having the desired effect.",
                speaker: "Dr. Morris"
            ),
            DialogueItem(
                text: "It was as if God had decided to strip away all the blessings slowly bestowed upon me.",
                speaker: "You"
            ),
            DialogueItem(
                text: "I felt weightless for a moment, as though the world had shifted under me. I had imagined a future where I would reclaim my life—travel all around the world, maybe see my children have kids—but now those aspirations felt like distant dreams.",
                speaker: "You"
            ),
            DialogueItem(
                text: "'What does this mean?' I managed to ask, my voice a whisper caught between denial and despair.",
                speaker: "You"
            ),
            DialogueItem(
                text: "For your case, a liver transplant can be considered. Yet given the severity of your case, only a deceased liver will do, and there is only a very slim chance for that. We need other options. But there is still hope. Let me walk you through the options now.",
                speaker: "Dr. Morris"
            ),
            DialogueItem(
                text: "'20% chance of success for the next chemo,' I muttered to myself, trying to remain calm. I looked up at Dr. Morris, trying to gauge his confidence in the alternative.",
                speaker: "You"
            ),
            DialogueItem(
                text: "'And the new drug?' I asked, already knowing the answer but needing to hear it from him.",
                speaker: "You"
            ),
            DialogueItem(
                text: "Well, it's still a relatively new treatment, but the results so far have been promising. In some cases, it's been extremely effective, but we do see instances where it doesn't work as well.",
                speaker: "Dr. Morris"
            ),
            DialogueItem(
                text: "The odds of success, however, are much higher than any of the traditional chemo treatments, at around 70%.",
                speaker: "Dr. Morris"
            ),
            DialogueItem(
                text: "The drawback is the cost, I'm afraid. The new drug is expensive – very, very expensive…",
                speaker: "Dr. Morris"
            ),
            DialogueItem(
                text: "My mind reeled as I thought about the amount of money he was talking about—my lottery money, my pension and three quarters of my savings combined. Could I justify spending almost everything on a gamble for having a life?",
                speaker: "You"
            ),
            DialogueItem(
                text: "A 70% chance of success was much better than the 20% for the next chemo, but what about the cost? Is it even worth it? If the chemo doesn't work out and I can't make it till fall, at least I would have left quite some money for my kids, I thought. They could live their lives without financial burden.",
                speaker: "You"
            ),
            DialogueItem(
                text: "I'm afraid it would be a difficult decision to make, but I want you to know that I support you either way.",
                speaker: "Dr. Morris"
            ),
            DialogueItem(
                text: "I nodded, feeling overwhelmed. I knew I had to make a decision, but it was one of life and death.",
                speaker: "You"
            )
        ]
    }
    
    var choices: [Choice] {
        [
            Choice(
                text: "New drug treatment\n(70% success rate)",
                systemImage: "pills.fill",
                unlocksScenario: "s1A"
            ),
            Choice(
                text: "Traditional chemotherapy\n(20% success rate)",
                systemImage: "xmark.circle.fill",
                unlocksScenario: "s1B"
            )
        ]
    }
    
    var body: some View {
        NavigationStack {
            StoryView(
                title: "The Cost of Survival",
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
        if choice.text.contains("70%") {
//            print("CHOSEN 1")
            // First unlock and complete scenarios
            ProgressManager.shared.unlockScenario("s1A")
            ProgressManager.shared.completeScenario("s1")
            
//            print(completedScenarios["s1"].isCompleted)
            
            // Force UI update
            NotificationCenter.default.post(name: NSNotification.Name("ScenarioUnlocked"), object: nil)
            NotificationCenter.default.post(name: NSNotification.Name("ScenarioCompleted"), object: nil)
//            NotificationCenter.default.post(name: NSNotification.Name("ForceGameMapRefresh"), object: nil)
            
            // Direct navigation to the next scene instead of dismissing
            nextDestination = AnyView(SceneManager.shared.getScene("s1A", onComplete: onComplete))
            navigateToNext = true
        } else {
            // First unlock and complete scenarios
            ProgressManager.shared.unlockScenario("s1B")
            ProgressManager.shared.completeScenario("s1")
            
            // Force UI update
            NotificationCenter.default.post(name: NSNotification.Name("ScenarioUnlocked"), object: nil)
            NotificationCenter.default.post(name: NSNotification.Name("ScenarioCompleted"), object: nil)
//            NotificationCenter.default.post(name: NSNotification.Name("ForceGameMapRefresh"), object: nil)
            
            // Direct navigation to the next scene instead of dismissing
            nextDestination = AnyView(SceneManager.shared.getScene("s1B", onComplete: onComplete))
            navigateToNext = true
        }
    }
}

#if DEBUG
struct s1_Previews: PreviewProvider {
    static var previews: some View {
        s1()
    }
}
#endif
