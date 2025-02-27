import SwiftUI
import Foundation

@available(iOS 13.0, macOS 12.0, *)
struct s1A: View {
    @Environment(\.dismiss) private var dismiss
    @State private var navigateToNext = false
    @State private var nextDestination: AnyView?
    @State private var hasNavigated = false
    var onComplete: (() -> Void)?
    
    static var initialDialogues: [DialogueItem] {
        [
            DialogueItem(
                text: "The day I accepted the expensive drug treatment felt heavy. It was a choice that shone hope but was shadowed by fear. As I signed the papers, I could feel the weight of uncertainty pressing down on my chest. ",
                systemImage: "person.fill",
                speaker: "You"
            ),
            DialogueItem(
                text: "Would this treatment truly work? Would I be able to return to the life I once knew? Would I use all my money and die in the coming year anyway? I thought of my children.",
                systemImage: "person.fill",
                speaker: "You"
            ),
            DialogueItem(
                text: "As the weeks turned into months, I endured the physical toll of the medication. Hope was one thing that I clung onto like a loyal friend, but exhaustion, my battle with nausea and midnight visits to the toilet became testaments to our friendship.",
                systemImage: "person.fill",
                speaker: "You"
            ),
            DialogueItem(
                text: "I often laid awake at night, staring at the ceiling, thoughts swirling like a storm. The financial burden loomed large in my mind. We had drained our savings, and the weight of that decision felt heavier with each passing day.",
                systemImage: "person.fill",
                speaker: "You"
            ),
            DialogueItem(
                text: "Mark tried to remain optimistic, but I could see the worry etched on his face. Mark had always had a growing collection of sneakers—sneakers had always been his kind of thing. Ever since I agreed to trying the new drug, I noticed that his collection had only been shrinking.",
                systemImage: "person.fill",
                speaker: "You"
            ),
            DialogueItem(
                text: "With each visit to the hospital, I watched the clock, counting down the days until my next scan. The prospect of the tumor shrinking enough for surgery felt like a distant dream.",
                systemImage: "person.fill",
                speaker: "You"
            ),
            DialogueItem(
                text: "What if the treatment failed? What if I never returned to work? The uncertainty gnawed at me, and I could feel the anxiety creeping in.",
                systemImage: "person.fill",
                speaker: "You"
            ),
            DialogueItem(
                text: "On midsummer's day Dr. Morris entered the room and, for the first time, had a smile on his face. Thereby I returned a smile, one I had never shown in that sterile, emotionless room. I was making good progress. After the treatment went on for a few more months, the tumour became operable.",
                systemImage: "person.fill",
                speaker: "You"
            ),
            DialogueItem(
                text: "One evening, as I prepared for the surgery, I gathered the kids in the living room. 'Yes, Christina,' I replied, trying to sound reassuring. 'This surgery is the last step.'",
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
                text: "On a frigid winter morning, ten years later, the world was buzzing with news of a young celebrity on the brink of death, fighting for survival. The urgency of his situation—a dire need for a kidney transplant—sent shockwaves across social media.",
                systemImage: "person.fill",
                speaker: "You"
            ),
            DialogueItem(
                text: "Days filled with anxious discussions and sentiments of despair grew until a young man stepped forward, bravely offering his kidney in a living donation that would save the star's life.",
                systemImage: "person.fill",
                speaker: "You"
            ),
            DialogueItem(
                text: "Interviews with the altruistic donor and discussions around living donations dominated headlines. As I sat in my armchair, bundled in a thick blanket next to Mark, I read an article detailing the eligibility criteria for donors.",
                systemImage: "person.fill",
                speaker: "You"
            ),
            DialogueItem(
                text: "At 68, I was retired. Though my hair never returned to its former glory, I was living a decent life. As I was watching the news unfold on the television screen, the stark contrast between my life and that of someone like Nick rested heavily on my mind.",
                systemImage: "person.fill",
                speaker: "You"
            ),
            DialogueItem(
                text: "I thought of young people being interviewed on TV, vibrant and ambitious, trapped in hospital beds undergoing dialysis when they should be chasing their dreams. And my heart ached for those parents—like I once was—who might be unable to care for their children while battling illness. I sighed with my eyebrows furrowed.",
                systemImage: "person.fill",
                speaker: "You"
            ),
            DialogueItem(
                text: "As the news permeated the city, I thought about my own journey of life and death. If I were fortunate enough to receive an organ donation, how much easier would my life be? My mind kept thinking about the young lives still unfolding, the dreams yet to be realized.",
                systemImage: "person.fill",
                speaker: "You"
            ),
            DialogueItem(
                text: "What if it was Nick, I thought. But I didn't dare to think deeper. Nobody on Earth should go through all these sufferings. I had my own bitter taste of it, but I wanted to make a difference so that fewer people would have to.",
                systemImage: "person.fill",
                speaker: "You"
            ),
            DialogueItem(
                text: "I thought of the relief on a parent's face, the joy on a young person's lips, the weight lifted from their shoulders. Could you imagine how great that must feel? In that moment, all those running thoughts transformed into a call to action.",
                systemImage: "person.fill",
                speaker: "You"
            ),
            DialogueItem(
                text: "I looked into a living organ donation. To many, it may be a radical choice. But I felt that it was the right way. I was way past my youth, without any contributions to society. I kept asking myself how my life would change if I received an organ transplant when I battled liver cancer. And I wanted somebody to be blessed with those changes.",
                systemImage: "person.fill",
                speaker: "You"
            ),
            DialogueItem(
                text: "Determined to explore this option, I sought out my family doctor, Dr Evans. During my appointment, I laid out my thoughts, my voice steady yet filled with urgency. He listened intently, nodding in understanding.",
                systemImage: "person.fill",
                speaker: "You"
            ),
            DialogueItem(
                text: "'Given your history, we should run some preliminary blood tests to see if you're a suitable donor. Your cancer history shouldn't be a concern, especially after all this time without recurrences. If you want, we can have your blood taken now.'",
                systemImage: "person.fill",
                speaker: "You"
            ),
            DialogueItem(
                text: "With a mix of anxiety and excitement, I agreed and scheduled the blood tests as I could always decide after having my blood taken. The next step would be to tell my children, so I called Christina and Nick for a family dinner over the weekend.",
                systemImage: "person.fill",
                speaker: "You"
            ),
            DialogueItem(
                text: "With a mix of anxiety and excitement, I agreed and scheduled the blood tests as I could always decide after having my blood taken. The next step would be to tell my children, so I called Christina and Nick for a family dinner over the weekend.",
                systemImage: "person.fill",
                speaker: "You"
            ),
            DialogueItem(
                text: "'Kids,' I began, my voice steady yet filled with emotion, and I told them everything.",
                systemImage: "person.fill",
                speaker: "You"
            ),
            DialogueItem(
                text: "The room fell silent. Christina and Nick exchanged glances, then looked at Mark in unison, who was staring at his plate of carbonara, belying not a bit of his emotions. After a few moments, he looked up at me and, as if he had gathered his words, said, 'This is truly an altruistic act and there shouldn't be any reason on Earth that is against that.' I gulped. ",
                systemImage: "person.fill",
                speaker: "Mark"
            ),
            DialogueItem(
                text: "'But', he continued, ' I have been thinking about it since you brought those leaflets about living donation home and asked me to read you all those articles about organ donation and calling for Dr Evans for an appointment without telling us and…' he broke, tears melting into the pasta.",
                systemImage: "person.fill",
                speaker: "Mark"
            ),
            DialogueItem(
                text: "'The liver surgery was risky and we're so grateful that you made it. But what happens if…if it doesn't work this time?' Nick's voice quivered.",
                systemImage: "person.fill",
                speaker: "Nick"
            ),
            DialogueItem(
                text: "'Nick, kidney removal is much easier. It'll be fine, you know…' At that moment, I realised that it was impossible to convince loved ones with those words. Bringing up surgery was like disturbing a calm sea, awakening the turmoil deep in their hearts.",
                systemImage: "person.fill",
                speaker: "You"
            ),
            DialogueItem(
                text: "'I will think about it.' I blurted out in a strong tone.",
                systemImage: "person.fill",
                speaker: "You"
            ),
            DialogueItem(
                text: "I struggled to sleep that night, pondering what I should do. I felt a strong urge to help somebody in this way.",
                systemImage: "person.fill",
                speaker: "You"
            ),
            DialogueItem(
                text: "I wanted to explain to my kids that it isn't simply an act of kindness, but a gift of hope. I could still vividly recall the torture chemotherapy brought me. The torturous part however, is that you never see the light of day. The thought that everything might be futile kills.",
                systemImage: "person.fill",
                speaker: "You"
            ),
            DialogueItem(
                text: "It does kill. Donating my kidney is not a gesture of charity, because to me it is an act of necessity. One kidney is enough. Yes. One kidney is all they need.",
                systemImage: "person.fill",
                speaker: "You"
            ),
            DialogueItem(
                text: "But I understood what they thought. If Mark told me the same, my first reaction would be a big NO. It is insanely difficult to encourage a loved one to take risks that, you might argue, are unnecessary.",
                systemImage: "person.fill",
                speaker: "You"
            ),
            DialogueItem(
                text: "I did not want to upset them either. I could not even recall the last time I saw Mark's tears, and it was when he cried that night that I finally realised how much pain and anxiety was embedded in the hearts of my children.",
                systemImage: "person.fill",
                speaker: "You"
            ),
            DialogueItem(
                text: "Dr Evans called the next day. It is highly likely that I can donate one of my kidneys.",
                systemImage: "person.fill",
                speaker: "You"
            )
        ]
    }
    
    var choices: [Choice] {
        [
            Choice(
                text: "Donate your organs",
                consequence: "You've chosen to donate your kidney.",
                systemImage: "heart.fill",
                unlocksScenario: "s1A1"
            ),
            Choice(
                text: "Take more time to consider",
                consequence: "You've decided to take more time to consider the donation.",
                systemImage: "clock.fill",
                unlocksScenario: "s1A2"
            )
        ]
    }
    
    var body: some View {
        NavigationStack {
            StoryView(
                title: "The Risk We Take",
                dialogues: Self.initialDialogues,
                choices: choices,
                onComplete: onComplete,
                onMakeChoice: makeChoice,
                onDismiss: {
                    // Prevent duplicate calls
                    guard !hasNavigated else {
                        print("s1A.onDismiss: Prevented duplicate onComplete call")
                        return
                    }
                    
                    // Call the onComplete handler to return to the map
                    if let complete = onComplete {
                        print("s1A.onDismiss calling onComplete")
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
            print("s1A.onDisappear called, hasNavigated=\(hasNavigated)")
        }
    }
    
    private func makeChoice(_ choice: Choice) {
        // Prevent duplicate navigation
        guard !hasNavigated else {
            print("s1A.makeChoice: Prevented duplicate navigation")
            return
        }
        
        // Set flag to prevent duplicate navigation
        hasNavigated = true
        print("s1A.makeChoice called with choice: \(choice.text)")
        
        if choice.text.contains("Donate") {
            // First unlock and complete scenarios
            ProgressManager.shared.unlockScenario("s1A1")
            ProgressManager.shared.completeScenario("s1A")
            
            // Force UI update
            NotificationCenter.default.post(name: NSNotification.Name("ScenarioUnlocked"), object: nil)
            NotificationCenter.default.post(name: NSNotification.Name("ScenarioCompleted"), object: nil)
//            NotificationCenter.default.post(name: NSNotification.Name("ForceGameMapRefresh"), object: nil)
            
            // Direct navigation to the next scene instead of dismissing
            nextDestination = AnyView(SceneManager.shared.getScene("s1A1", onComplete: onComplete))
            navigateToNext = true
            
            // Debug print to track navigation
            print("Navigating from s1A to s1A1 with onComplete: \(String(describing: onComplete))")
        } else {
            // First unlock and complete scenarios
            ProgressManager.shared.unlockScenario("s1A2")
            ProgressManager.shared.completeScenario("s1A")
            
            // Force UI update
            NotificationCenter.default.post(name: NSNotification.Name("ScenarioUnlocked"), object: nil)
            NotificationCenter.default.post(name: NSNotification.Name("ScenarioCompleted"), object: nil)
//            NotificationCenter.default.post(name: NSNotification.Name("ForceGameMapRefresh"), object: nil)
            
            // Direct navigation to the next scene instead of dismissing
            nextDestination = AnyView(SceneManager.shared.getScene("s1A2", onComplete: onComplete))
            navigateToNext = true
            
            // Debug print to track navigation
            print("Navigating from s1A to s1A2 with onComplete: \(String(describing: onComplete))")
        }
    }
}

#if DEBUG
struct s1A_Previews: PreviewProvider {
    static var previews: some View {
        s1A()
    }
}
#endif
