//
//  1B1.swift
//  CapstoneCapstone
//
//  Created by Hugo Lau on 25/2/2025.
//

import SwiftUI
import Foundation

@available(iOS 13.0, macOS 12.0, *)
struct s1B1: View {
    @Environment(\.dismiss) private var dismiss
    @State private var navigateToNext = false
    @State private var nextDestination: AnyView?
    var onComplete: (() -> Void)?
    
    static var initialDialogues: [DialogueItem] {
        [
            DialogueItem(
                text: "The moment I stepped out of the doctor's office, a heavy weight suffocated my chest. I chose to continue the fight through more rounds of chemo. I could only imagine how agonizing it would be, but what else would give me a chance of survival?",
                systemImage: "person.fill",
                speaker: "You"
            ),
            DialogueItem(
                text: "As I walked to the car, the sun felt almost too bright against the backdrop of my dark swirling thoughts.",
                systemImage: "person.fill",
                speaker: "You"
            ),
            DialogueItem(
                text: "Back home, I tried to put on a brave face. Mark was at the kitchen table, buried in paperwork, while Christina arrived with my favorite pastries, hoping to lighten the mood. I told them I would keep on fighting. Mark nodded, but I could see the tightness in his jaw, the unspoken fear lurking beneath his unwavering support.",
                systemImage: "person.fill",
                speaker: "You"
            ),
            DialogueItem(
                text: "The first week of therapy was brutal. Each session left me feeling more depleted than the last. The nausea returned to haunt me and I spent hours curled up on the couch.",
                systemImage: "person.fill",
                speaker: "You"
            ),
            DialogueItem(
                text: "I felt guilty for the burden I placed on my family, especially as I watched Christina's face fall when I pushed the pastries away, knowing they would likely be vomited back up later anyway. But what was the point of indulging in treats that would only end in disappointment?",
                systemImage: "person.fill",
                speaker: "You"
            ),
            DialogueItem(
                text: "I stayed mostly at home as the outside world gradually seemed like a distant blur. Sometimes—perhaps often—fighting on felt like the only thing left within me is my will to live, and I wasn't sure if this struggle was worth it.",
                systemImage: "person.fill",
                speaker: "You"
            ),
            DialogueItem(
                text: "Yet, amidst the pain, there were rays of hope: Christina announced she was pregnant. The news brought a momentary lightness to our home, a glimmer of joy that cut through the heaviness of my illness.",
                systemImage: "person.fill",
                speaker: "You"
            ),
            DialogueItem(
                text: "I told myself, 'at least I should live to see my grandchild be born. At least I will be on Christina's side when that happens. At least I will be a grandparent.'",
                systemImage: "person.fill",
                speaker: "You"
            ),
            DialogueItem(
                text: "As days turned into weeks, it was time to start the fourth drug. The infusion began. How was I supposed to feel, having tried three drugs that were to no avail? The fourth drug was the most torturous of all, to an extent where I puked so much I had to visit the hospital on one occasion.",
                systemImage: "person.fill",
                speaker: "You"
            ),
            DialogueItem(
                text: "Despite the agony, I clung to the hope that this would be the turning point. The days following the treatment were a blur of discomfort and despair. I spent hours in and out of sleep, my body protesting every movement. Yet, deep down, I held onto the belief that this pain might lead to something greater.",
                systemImage: "person.fill",
                speaker: "You"
            ),
            DialogueItem(
                text: "Finally, the day came for my next appointment with Dr. Morris. I walked into the office–without any sign of strength. My heart was pounding—not just from anxiety, but from the remnants of the drug still coursing through my veins. As I sat across from him, I could see the anticipation in his eyes.",
                systemImage: "person.fill",
                speaker: "You"
            ),
            DialogueItem(
                text: "'Your latest scans are in,' he began, a slight smile breaking through his usually serious demeanor. 'I have good news.'",
                systemImage: "person.circle.fill",
                speaker: "Dr. Morris"
            ),
            DialogueItem(
                text: "The words hung in the air, and I felt a flicker of hope ignite within me. 'The fourth drug has been very effective. The tumor has shrunk significantly, and it is now operable.'",
                systemImage: "person.circle.fill",
                speaker: "Dr. Morris"
            ),
            DialogueItem(
                text: "I still vividly remember that moment, which was more delighting than winning the lottery, literally. I could hardly process what he was saying. The pain I had endured suddenly felt like a necessary sacrifice. Tears of relief and joy welled up in my eyes. I had fought through the worst of it, and now I had a chance—a real chance.",
                systemImage: "person.fill",
                speaker: "You"
            ),
            DialogueItem(
                text: "'Yes, sweetheart,' I replied Christina, trying to sound reassuring. 'This surgery is the last step.'",
                systemImage: "person.fill",
                speaker: "You"
            ),
            DialogueItem(
                text: "'But what if something goes wrong?' Nick chimed in, his voice trembling. 'What if you…?'",
                systemImage: "person.fill",
                speaker: "Nick"
            ),
            DialogueItem(
                text: "'I'll be in good hands, I promise. The doctors are skilled at what they do.' I sensed a whirlwind of emotions within them, akin to a player on the verge of winning a tiebreaker in a sports match—completely focused, caught between joy and fear, holding their breath until the outcome was 100% certain.",
                systemImage: "person.fill",
                speaker: "You"
            ),
            DialogueItem(
                text: "The surgery went well, and with each passing day, I felt stronger. Yet, beneath that gratitude lay an undercurrent of anxiety. The reality of our finances was stark; we had just enough to get by, but not much more. I worried about how we would manage in the long run. Would I ever reclaim the stability we once briefly had?",
                systemImage: "person.fill",
                speaker: "You"
            ),
            DialogueItem(
                text: "I was oscillating between hope and fear after recovery. Having little savings while approaching the age of 60 filled me with trepidation. I wanted to be present for my children, to guide them through life's challenges, but I feared what my illness had already cost us.",
                systemImage: "person.fill",
                speaker: "You"
            ),
            DialogueItem(
                text: "Ten years later…",
                systemImage: "clock.fill",
                speaker: "Narrator"
            ),
            DialogueItem(
                text: "On a brisk autumn afternoon, ten years after my surgery, the world was abuzz with shocking news: a beloved celebrity had recently passed away, but his 'ostensible' death ignited a firestorm of conversation.",
                systemImage: "person.fill",
                speaker: "You"
            ),
            DialogueItem(
                text: "This star, known for his lifelong passion and advocacy for life extension, had signed up for cryonics prior to his passing. His decision to be cryopreserved after death became a focal point for media outlets and social media platforms alike.",
                systemImage: "person.fill",
                speaker: "You"
            ),
            DialogueItem(
                text: "The discourse echoed in my mind, compelling me to reflect on my own journey. At 68, it was difficult to be unaware of life's fragility. The celebrity's decision led to a train of thoughts within me. Ever since my partner passed away, leaving me with the three kids, life had always been tough.",
                systemImage: "person.fill",
                speaker: "You"
            ),
            DialogueItem(
                text: "I faced the financial struggles throughout the years to raise them all in that small apartment, as well as stress from my day job. Then my two-year battle with cancer just after winning the lottery.",
                systemImage: "person.fill",
                speaker: "You"
            ),
            DialogueItem(
                text: "And when I had finally recovered from cancer, I realised time and youth had flown on the wings of those bygone years. And, there was so much that I had not experienced yet. But I knew time was running short, and my stamina was declining.",
                systemImage: "person.fill",
                speaker: "You"
            ),
            DialogueItem(
                text: "Many people recover completely from cancer, but for me, I felt that a part of me was permanently damaged by it. No longer could I stay up until 11 at night, and no longer could I physically manage a day job Monday to Friday.",
                systemImage: "person.fill",
                speaker: "You"
            ),
            DialogueItem(
                text: "Nearing my 70, I could feel that death was probably only a few years away. I could not put my finger on it, but I simply knew.",
                systemImage: "person.fill",
                speaker: "You"
            ),
            DialogueItem(
                text: "As I sat in my sunlit living room, I listened to the news anchor's voice, which was both somber and puzzling at the same time. The celebrity's story was not just about his untimely death; it was about his belief in the possibility of a future where he could be revived, where advancements in science could offer him a second chance at life.",
                systemImage: "person.fill",
                speaker: "You"
            ),
            DialogueItem(
                text: "Interviews flooded in with fans, scientists, and ethicists discussing his unorthodox choice to his own 'death', some praising his open-mindedness while others had serious doubts.",
                systemImage: "person.fill",
                speaker: "You"
            ),
            DialogueItem(
                text: "I wondered what would happen if I were cryopreserved. Then, somehow, I thought of the life I have waking up a hundred years later. Until my thoughts went adrift and my eyes hid under my eyelids in the night.",
                systemImage: "person.fill",
                speaker: "You"
            )
        ]
    }
    
    var choices: [Choice] {
        [
            Choice(
                text: "Agree to cryonics",
                consequence: "You've chosen to be cryopreserved after death.",
                systemImage: "snowflake",
                unlocksScenario: "s1B1a"
            ),
            Choice(
                text: "Decline cryonics",
                consequence: "You've decided against cryopreservation.",
                systemImage: "xmark.circle.fill",
                unlocksScenario: "s1B1b"
            )
        ]
    }
    
    var body: some View {
        NavigationStack {
            StoryView(
                title: "Eternity",
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
        if choice.text.contains("Agree") {
            // First unlock and complete scenarios
            ProgressManager.shared.unlockScenario("s1B1a")
            ProgressManager.shared.completeScenario("s1B1")
            
            // Force UI update
            NotificationCenter.default.post(name: NSNotification.Name("ScenarioUnlocked"), object: nil)
            NotificationCenter.default.post(name: NSNotification.Name("ScenarioCompleted"), object: nil)
//            NotificationCenter.default.post(name: NSNotification.Name("ForceGameMapRefresh"), object: nil)
            
            // Direct navigation to the next scene instead of dismissing
            nextDestination = AnyView(SceneManager.shared.getScene("s1B1a", onComplete: onComplete))
            navigateToNext = true
        } else {
            // First unlock and complete scenarios
            ProgressManager.shared.unlockScenario("s1B1b")
            ProgressManager.shared.completeScenario("s1B1")
            
            // Force UI update
            NotificationCenter.default.post(name: NSNotification.Name("ScenarioUnlocked"), object: nil)
            NotificationCenter.default.post(name: NSNotification.Name("ScenarioCompleted"), object: nil)
//            NotificationCenter.default.post(name: NSNotification.Name("ForceGameMapRefresh"), object: nil)
            
            // Direct navigation to the next scene instead of dismissing
            nextDestination = AnyView(SceneManager.shared.getScene("s1B1b", onComplete: onComplete))
            navigateToNext = true
        }
    }
}

#if DEBUG
struct s1B1_Previews: PreviewProvider {
    static var previews: some View {
        s1B1()
    }
}
#endif

