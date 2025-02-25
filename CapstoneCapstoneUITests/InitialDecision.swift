import SwiftUI
import Foundation

@available(iOS 13.0, macOS 12.0, *)
struct InitialDecision: View {
    @Environment(\.dismiss) var dismiss
    @State private var currentDialogue = 0
    @State private var showChoices = false
    @State private var showConsequence = false
    @State private var currentConsequence = ""
    @State private var isViewLoaded = false
    @State private var hasChosen = false
    @State private var nextScene: AnyView? = nil
    @State private var showNextScene = false
    @State private var showingConfirmation = false
    @State private var selectedChoice: Choice? = nil
    @StateObject private var speechManager = SpeechManager.shared
    var onComplete: (() -> Void)?
    
    init(onComplete: (() -> Void)? = nil) {
        self.onComplete = onComplete
    }
    
    var dialogues: [DialogueItem] {
        [
            DialogueItem(
                text: "I was wrapped in a cocoon of anxiety as I sat in the small room, fingers tapping nervously on the plastic armrest of the chair. The ticking clock was the only indication that time was moving forward, yet it felt suspended as I waited for the doctor to deliver news I dreaded but had somehow sensed was coming.",
                systemImage: "person.fill",
                speaker: "You"
            ),
            DialogueItem(
                text: "When Dr. Morris finally entered, 'Good afternoon', he began, his voice steady but gentle. In my mind I had prepared for the worst, after all those worrisome Google searches I did prior to the meeting. My heart raced, a drumbeat of dread echoing in my ears.",
                systemImage: "person.circle.fill",
                speaker: "Narrator"
            ),
            DialogueItem(
                text: "I thought back to the years of raising my three children, the rollercoaster of single parenthood. We fought as a family after losing my partner. Twelve years had passed since that fateful day, yet the ache of loss had never fully left me.",
                systemImage: "brain.head.profile.fill",
                speaker: "You"
            ),
            DialogueItem(
                text: "My life had finally begun to stabilize. The kids were grown, each branching out into the world. Then I had won the lottery - enough to buy 4 Teslas. It allowed me freedom to leave the corporate grind behind.",
                systemImage: "brain.head.profile.fill",
                speaker: "You"
            ),
            DialogueItem(
                text: "Two weeks prior, I had visited the clinic after experiencing a worsening fatigue. At first, I attributed it to the emotional and physical toll of raising my children alone for over a decade.",
                systemImage: "brain.head.profile.fill",
                speaker: "You"
            ),
            DialogueItem(
                text: "\(UserSettingsManager.shared.currentSettings.playerName), you have liver cancer, and it's an aggressive form. We need to start treatment immediately.",
                systemImage: "stethoscope",
                speaker: "Dr. Morris"
            ),
            DialogueItem(
                text: "Liver cancer. The word echoed in my mind like a cruel joke and I felt my world falling apart. It was like when my first child was born. We thought we had prepared for labour, but when the contractions started it went out of control.",
                systemImage: "person.fill",
                speaker: "You"
            ),
            DialogueItem(
                text: "We'll start chemotherapy right away. You're not alone in this.",
                systemImage: "stethoscope",
                speaker: "Dr. Morris"
            ),
            DialogueItem(
                text: "Three months had passed since my eldest son, Mark, moved in with me. I agreed under the condition that he persuaded the others to focus on their own lives. Christina deserves time with her new husband while Nick needs to fight for a bright career.",
                systemImage: "person.fill",
                speaker: "You"
            ),
            DialogueItem(
                text: "I'm afraid the results aren't what we had hoped for. The chemotherapy isn't having the desired effect.",
                systemImage: "stethoscope",
                speaker: "Dr. Morris"
            ),
            DialogueItem(
                text: "For your case, a liver transplant can be considered. Yet given the severity, only a deceased liver will do, and there is only a very slim chance. We need other options.",
                systemImage: "stethoscope",
                speaker: "Dr. Morris"
            ),
            DialogueItem(
                text: "The new drug has shown promising results with a 70% success rate, much higher than the 20% for traditional chemo. However, it's very expensive - it would cost almost all your savings and lottery money.",
                systemImage: "stethoscope",
                speaker: "Dr. Morris"
            )
        ]
    }
    
    let choices = [
        Choice(
            text: "Choose the New Drug Treatment (70% Success Rate)",
            consequence: "You decide to risk your savings for the better chance at life. The medical team begins preparing the new treatment plan.",
            systemImage: "pill.fill",
            unlocksScenario: "Emergency Room"
        ),
        Choice(
            text: "Continue with Traditional Chemotherapy (20% Success Rate)",
            consequence: "You choose to preserve your savings for your children's future, accepting the lower success rate.",
            systemImage: "cross.circle.fill",
            unlocksScenario: "Surgery Ward"
        )
    ]
    
    var body: some View {
        NavigationStack {
            GeometryReader { geometry in
                ZStack {
                    // Background gradient
                    LinearGradient(
                        gradient: Gradient(colors: [Color.indigo.opacity(0.1), Color.white]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    .ignoresSafeArea()
                    
                    VStack(spacing: 0) {
                        // Story Section (60% of screen)
                        VStack {
                            if currentDialogue < dialogues.count {
                                VStack(spacing: geometry.size.height * 0.03) {
                                    // Narrative Box
                                    VStack(alignment: .leading, spacing: geometry.size.height * 0.02) {
                                        HStack {
                                            Image(systemName: dialogues[currentDialogue].systemImage)
                                                .font(.system(size: geometry.size.width * 0.06))
                                                .foregroundColor(.indigo)
                                            
                                            Text(dialogues[currentDialogue].speaker)
                                                .font(.system(size: geometry.size.width * 0.04))
                                                .foregroundColor(.indigo)
                                                .fontWeight(.medium)
                                            
                                            Spacer()
                                        }
                                        .padding(.bottom, 5)
                                        
                                        Text(dialogues[currentDialogue].text)
                                            .font(.system(size: geometry.size.width * 0.045))
                                            .lineSpacing(8)
                                            .foregroundColor(.black.opacity(0.8))
                                    }
                                    .padding(geometry.size.width * 0.06)
                                    .background(
                                        RoundedRectangle(cornerRadius: 20)
                                            .fill(Color.white)
                                            .shadow(color: Color.black.opacity(0.1), radius: 10)
                                    )
                                    .padding(.horizontal, geometry.size.width * 0.05)
                                }
                                .onChange(of: currentDialogue) { oldValue, newValue in
                                    // Speak the new dialogue
                                    if currentDialogue < dialogues.count {
                                        let dialogue = dialogues[currentDialogue]
                                        speechManager.speak(dialogue.text, speaker: dialogue.speaker)
                                    }
                                }
                            }
                        }
                        .frame(height: geometry.size.height * 0.6)
                        
                        // Choices Section (40% of screen)
                        VStack {
                            if showChoices {
                                ScrollView {
                                    VStack(spacing: geometry.size.height * 0.02) {
                                        ForEach(choices) { choice in
                                            Button {
                                                withAnimation {
                                                    selectedChoice = choice
                                                    showingConfirmation = true
                                                }
                                            } label: {
                                                ChoiceCard(
                                                    choice: choice,
                                                    size: geometry.size,
                                                    isConfirming: showingConfirmation && selectedChoice?.id == choice.id,
                                                    onConfirm: {
                                                        withAnimation {
                                                            makeChoice(choice)
                                                            showingConfirmation = false
                                                        }
                                                    },
                                                    onCancel: {
                                                        withAnimation {
                                                            selectedChoice = nil
                                                            showingConfirmation = false
                                                        }
                                                    }
                                                )
                                            }
                                            .disabled(hasChosen || (showingConfirmation && selectedChoice?.id != choice.id))
                                            .opacity(hasChosen || (showingConfirmation && selectedChoice?.id != choice.id) ? 0.6 : 1.0)
                                        }
                                    }
                                    .padding(.horizontal, geometry.size.width * 0.05)
                                }
                            } else if currentDialogue < dialogues.count {
                                Spacer()
                                Button("Continue") {
                                    // Stop any ongoing speech when continuing
                                    speechManager.stopSpeaking()
                                    
                                    withAnimation(.easeInOut(duration: 0.3)) {
                                        if currentDialogue < dialogues.count - 1 {
                                            currentDialogue += 1
                                        } else {
                                            showChoices = true
                                        }
                                    }
                                }
                                .buttonStyle(CustomButtonStyle(size: geometry.size))
                                .padding(.bottom, geometry.size.height * 0.05)
                            }
                            
                            if showConsequence {
                                Text(currentConsequence)
                                    .font(.system(size: geometry.size.width * 0.04))
                                    .multilineTextAlignment(.center)
                                    .padding()
                                    .frame(maxWidth: .infinity)
                                    .background(
                                        RoundedRectangle(cornerRadius: 15)
                                            .fill(Color.white)
                                            .shadow(color: Color.black.opacity(0.05), radius: 5)
                                    )
                                    .padding(.horizontal, geometry.size.width * 0.05)
                                    .transition(.move(edge: .bottom).combined(with: .opacity))
                            }
                        }
                        .frame(height: geometry.size.height * 0.4)
                    }
                }
            }
            .navigationTitle("Initial Decision")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Exit") {
                        // Stop speech when exiting
                        speechManager.stopSpeaking()
                        withAnimation {
                            dismiss()
                        }
                    }
                }
            }
            .interactiveDismissDisabled()
            .onAppear {
                DispatchQueue.main.async {
                    isViewLoaded = true
                    // Start speaking the first dialogue
                    if !dialogues.isEmpty {
                        speechManager.speak(dialogues[0].text, speaker: dialogues[0].speaker)
                    }
                }
            }
            .onDisappear {
                // Stop speech when view disappears
                speechManager.stopSpeaking()
            }
            .background(
                Group {
                    if let scene = nextScene {
                        NavigationLink(
                            destination: scene,
                            isActive: $showNextScene,
                            label: { EmptyView() }
                        )
                    }
                }
            )
        }
    }
    
    private func makeChoice(_ choice: Choice) {
        // Stop any ongoing speech when making a choice
        speechManager.stopSpeaking()
        
        // Immediately disable all choices and show consequence
        withAnimation(.easeInOut(duration: 0.3)) {
            hasChosen = true
            currentConsequence = choice.consequence
            showConsequence = true
        }
        
        // Unlock the corresponding scenario immediately
        if let scenarioToUnlock = choice.unlocksScenario {
            ProgressManager.shared.unlockScenario(scenarioToUnlock)
            
            // Set up the next scene based on the choice
            switch scenarioToUnlock {
//            case "Second Node":
//                nextScene = AnyView(SecondNode())
            case "Surgery Ward":
                nextScene = AnyView(Text("Surgery Ward - Coming Soon"))
            default:
                break
            }
        }
        
        // Mark this scenario as completed
        ProgressManager.shared.completeScenario("Initial Decision")
        
        // Show consequence, then navigate to next scene
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
            // First fade out the consequence
            withAnimation(.easeOut(duration: 0.5)) {
                showConsequence = false
            }
            
            // Wait for consequence to completely fade out
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                // Show achievement
                AchievementManager.shared.unlockAchievement(id: "first_decision")
                
                // Navigate to next scene
                withAnimation(.easeInOut(duration: 0.3)) {
                    showNextScene = true
                }
            }
        }
    }
}

#if DEBUG
struct InitialDecision_Previews: PreviewProvider {
    static var previews: some View {
        InitialDecision()
    }
}
#endif
