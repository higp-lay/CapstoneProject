import SwiftUI

struct InitialDecision: View {
    @Environment(\.dismiss) var dismiss
    @State private var currentDialogue = 0
    @State private var showChoices = false
    @State private var showConsequence = false
    @State private var currentConsequence = ""
    var onComplete: (() -> Void)?
    
    let dialogues = [
        DialogueItem(
            text: "I was wrapped in a cocoon of anxiety as I sat in the small room, fingers tapping nervously on the plastic armrest of the chair. The ticking clock was the only indication that time was moving forward, yet it felt suspended as I waited for the doctor to deliver news I dreaded but had somehow sensed was coming.",
            systemImage: "brain.filled.head.profile"
        ),
        DialogueItem(
            text: "When Dr. Morris finally entered, 'Good afternoon', he began, his voice steady but gentle. In my mind I had prepared for the worst, after all those worrisome Google searches I did prior to the meeting. My heart raced, a drumbeat of dread echoing in my ears.",
            systemImage: "person.circle.fill"
        ),
        DialogueItem(
            text: "\"The results from your tests have come back,\" he began, his voice gentle but professional. The pause that followed felt like an eternity.",
            systemImage: "doc.text.fill"
        ),
        DialogueItem(
            text: "\"I'm afraid we've found something concerning. You have a condition that requires immediate attention and some important decisions need to be made.\"",
            systemImage: "heart.text.square.fill"
        )
    ]
    
    let choices = [
        Choice(
            text: "Ask about treatment options",
            consequence: "Dr. Thompson explains the various paths forward, each with its own risks and benefits.",
            impact: 0,
            isCorrect: true,
            systemImage: "list.clipboard.fill"
        ),
        Choice(
            text: "Request time to process",
            consequence: "You feel overwhelmed and need space to absorb this life-changing information.",
            impact: 0,
            isCorrect: true,
            systemImage: "clock.fill"
        ),
        Choice(
            text: "Seek second opinion",
            consequence: "You want to be absolutely certain about the diagnosis before proceeding.",
            impact: 0,
            isCorrect: true,
            systemImage: "person.2.fill"
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
                                                    makeChoice(choice)
                                                }
                                            } label: {
                                                ChoiceCard(choice: choice, size: geometry.size)
                                            }
                                        }
                                    }
                                    .padding(.horizontal, geometry.size.width * 0.05)
                                }
                            } else if currentDialogue < dialogues.count {
                                Spacer()
                                Button("Continue") {
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
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Exit") {
                        dismiss()
                    }
                    .foregroundColor(.red)
                }
            }
        }
    }
    
    private func makeChoice(_ choice: Choice) {
        currentConsequence = choice.consequence
        showConsequence = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            showConsequence = false
            onComplete?()
            dismiss()
        }
    }
}

#Preview {
    InitialDecision()
}
