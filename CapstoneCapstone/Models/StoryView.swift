import SwiftUI
import Foundation

@available(iOS 13.0, macOS 12.0, *)
struct DialogueBox: View {
    let dialogue: DialogueItem
    let geometry: GeometryProxy
    @State private var isVisible = false
    
    var body: some View {
        let systemImageDictionary = [
            "You": "person.fill",
            "Dr. Morris": "stethoscope",
            "Nick": "figure.and.child.holdinghands",
            "Narrator": "person.wave.2.fill",
            "Flynn": "person.crop.circle.badge.checkmark",
            "Nurse": "cross.fill",
            "Mark": "figure.and.child.holdinghands"
        ]
        VStack(alignment: .leading, spacing: geometry.size.height * 0.02) {
            HStack {
                Image(systemName: systemImageDictionary[dialogue.speaker] ?? "exclamationmark.triangle.fill")
                    .font(.system(size: geometry.size.width * 0.06))
                    .foregroundColor(.indigo)
                
                Text(dialogue.speaker)
                    .font(.system(size: geometry.size.width * 0.04))
                    .foregroundColor(.indigo)
                    .fontWeight(.medium)
                
                Spacer()
            }
            .padding(.bottom, 5)
            
            Text(dialogue.text)
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
        .opacity(isVisible ? 1 : 0)
        .onAppear {
            // Animate the dialogue box appearance
            withAnimation(.easeIn(duration: 0.3).delay(0.1)) {
                isVisible = true
            }
        }
    }
}

@available(iOS 13.0, macOS 12.0, *)
struct ChoiceButton: View {
    let choice: Choice
    let geometry: GeometryProxy
    let isDisabled: Bool
    let opacity: Double
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: choice.systemImage)
                    .font(.system(size: geometry.size.width * 0.06))
                    .foregroundColor(.blue)
                    .frame(width: geometry.size.width * 0.1)
                
                Text(choice.text)
                    .font(.system(size: geometry.size.width * 0.04))
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.gray)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 15)
                    .fill(Color.white)
                    .shadow(color: Color.black.opacity(0.05), radius: 5)
            )
        }
        .disabled(isDisabled)
        .opacity(opacity)
    }
}

@available(iOS 13.0, macOS 12.0, *)
struct StoryView: View {
    @Environment(\.dismiss) var dismiss
    @State private var currentDialogue = 0
    @State private var showChoices = false
    @State private var showConsequence = false
    @State private var currentConsequence = ""
    @State private var isViewLoaded = false
    @State private var hasChosen = false
    @State private var showingConfirmation = false
    @State private var selectedChoice: Choice? = nil
    @State private var isExiting = false
    @State private var dialoguesLoaded = false
    @ObservedObject private var transitionManager = TransitionManager.shared
    @ObservedObject private var achievementNotificationManager = AchievementNotificationManager.shared
    @State private var hasDismissed = false
    
    // Add TTS instance
    private let tts = TTS()
    private var isTTSEnabled: Bool {
        return UserSettingsManager.shared.currentSettings.ttsEnabled
    }
    
    // Add a method to determine voice type based on speaker
    private func getVoiceForSpeaker(_ speaker: String) -> VoiceType {
        // Define which speakers use which voice types
        let maleCharacters = ["Flynn", "Dr. Chen", "Mark", "John", "Michael", "David", "Robert", "Dr. Morris"]
        let femaleCharacters = ["Christina", "Sarah", "Emily", "Jessica", "Lisa", "Nurse", "Dr. Wilson"]
        
        if maleCharacters.contains(speaker) {
            return .studioMaleUK
        } else if femaleCharacters.contains(speaker) {
            return .studioFemaleUK
        } else {
            // Default to female voice for unspecified characters
            return .studioFemaleUK
        }
    }
    
    // Add a method to handle TTS for the current dialogue
    private func speakCurrentDialogue() {
        guard isTTSEnabled, currentDialogue < dialogues.count else { return }
        
        let dialogue = dialogues[showChoices ? dialogues.count - 1 : currentDialogue]
        
        // Skip TTS if the speaker is "You"
        if dialogue.speaker == "You" {
            return
        }
        
        // Get the appropriate voice for the speaker
        let voiceType = getVoiceForSpeaker(dialogue.speaker)
        
        // Speak the dialogue text
        tts.textToSpeech(dialogue.text, voiceType: voiceType)
    }
    
    let title: String
    let dialogues: [DialogueItem]
    let choices: [Choice]
    let onComplete: (() -> Void)?
    let onMakeChoice: (Choice) -> Void
    let onDismiss: (() -> Void)?
    
    init(
        title: String,
        dialogues: [DialogueItem],
        choices: [Choice],
        onComplete: (() -> Void)? = nil,
        onMakeChoice: @escaping (Choice) -> Void,
        onDismiss: (() -> Void)? = nil
    ) {
        self.title = title
        self.dialogues = dialogues
        self.choices = choices
        self.onComplete = onComplete
        self.onMakeChoice = onMakeChoice
        self.onDismiss = onDismiss
    }
    
    var body: some View {
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
                    storySection(geometry)
                    
                    // Choices Section (40% of screen)
                    choicesSection(geometry)
                }
                .opacity(isExiting ? 0 : 1) // Fade out when exiting
            }
        }
        .navigationTitle(title)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            #if os(iOS)
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Exit") {
                    // Replace direct refreshMap() call with a notification
                    NotificationCenter.default.post(name: NSNotification.Name("ForceGameMapRefresh"), object: nil)
                    exitStory()
                }
            }
            #elseif os(macOS)
            ToolbarItem(placement: .automatic) {
                Button("Exit") {
                    // Replace direct refreshMap() call with a notification
                    NotificationCenter.default.post(name: NSNotification.Name("ForceGameMapRefresh"), object: nil)
                    exitStory()
                }
            }
            #endif
        }
        .interactiveDismissDisabled()
        .onAppear(perform: handleOnAppear)
        // Apply transition effect from TransitionManager
        .opacity(transitionManager.isTransitioning ? 0 : 1)
        .animation(.easeInOut(duration: 0.3), value: transitionManager.isTransitioning)
        // Add achievement popup overlay
        .overlay {
            if achievementNotificationManager.showingAchievement,
               let achievement = achievementNotificationManager.currentAchievement {
                AchievementPopupView(
                    achievement: achievement,
                    isPresented: $achievementNotificationManager.showingAchievement
                )
            }
        }
        .onAppear {
            // Check if this is a terminal node (ends with a letter)
            if title.count >= 5 && title.last?.isLetter == true {
                // Check if the entire story is completed
                ProgressManager.shared.checkStoryCompletion(for: String(title.prefix(2)))
            }
        }
    }
    
    private func storySection(_ geometry: GeometryProxy) -> some View {
        VStack {
            if dialoguesLoaded && (currentDialogue < dialogues.count || showChoices) {
                VStack(spacing: geometry.size.height * 0.03) {
                    DialogueBox(
                        dialogue: dialogues[showChoices ? dialogues.count - 1 : currentDialogue],
                        geometry: geometry
                    )
                    .onAppear {
                        // Use the new method to handle TTS
                        speakCurrentDialogue()
                    }
                }
            } else {
                // Show a loading placeholder if dialogues aren't loaded yet
                VStack {
                    Text("Loading story...\n\nIf this persists, please exit and restart the story.")
                        .font(.headline)
                        .foregroundColor(.secondary)
                }
            }
        }
        .frame(height: geometry.size.height * 0.6)
    }
    
    private func choicesSection(_ geometry: GeometryProxy) -> some View {
        VStack {
            if showChoices {
                choiceButtons(geometry)
            } else if currentDialogue < dialogues.count {
                continueButton(geometry)
            }
        }
        .frame(height: geometry.size.height * 0.4)
    }
    
    private func choiceButtons(_ geometry: GeometryProxy) -> some View {
        VStack {
            Spacer().frame(height: geometry.size.height * 0.02)
            VStack(spacing: geometry.size.height * 0.02) {
                if showingConfirmation, let choice = selectedChoice {
                    // Show confirmation options when a choice is selected
                    Text("Are you sure you want to choose:\n \(choice.text)?\n")
                        .font(.system(size: geometry.size.width * 0.04))
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    
                    HStack(spacing: geometry.size.width * 0.05) {
                        // No button
                        Button {
                            withAnimation {
                                showingConfirmation = false
                                selectedChoice = nil
                            }
                        } label: {
                            HStack {
                                Image(systemName: "xmark.circle")
                                    .font(.system(size: geometry.size.width * 0.06))
                                    .foregroundColor(.blue)
                                    .frame(width: geometry.size.width * 0.1)
                                
                                Text("No")
                                    .font(.system(size: geometry.size.width * 0.04))
                                    .fontWeight(.medium)
                                    .foregroundColor(.primary)
                                    .multilineTextAlignment(.center)
                                    .frame(maxWidth: .infinity)
                                
                                Spacer()
                            }
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 15)
                                    .fill(Color.white)
                                    .shadow(color: Color.black.opacity(0.05), radius: 5)
                            )
                        }
                        
                        // Yes button
                        Button {
                            // Stop TTS if enabled
                            if isTTSEnabled {
                                tts.stopSpeech()
                            }
                            
                            showingConfirmation = false
                            hasChosen = true
                            if let choice = selectedChoice {
                                onMakeChoice(choice)
                            }
                        } label: {
                            HStack {
                                Image(systemName: "checkmark.circle")
                                    .font(.system(size: geometry.size.width * 0.06))
                                    .foregroundColor(.green)
                                    .frame(width: geometry.size.width * 0.1)
                                
                                Text("Yes")
                                    .font(.system(size: geometry.size.width * 0.04))
                                    .fontWeight(.medium)
                                    .foregroundColor(.primary)
                                    .multilineTextAlignment(.center)
                                    .frame(maxWidth: .infinity)
                                
                                Spacer()
                            }
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 15)
                                    .fill(Color.white)
                                    .shadow(color: Color.black.opacity(0.05), radius: 5)
                            )
                        }
                    }
                    .padding(.horizontal, geometry.size.width * 0.05)
                } else {
                    // Show regular choice buttons when no choice is selected yet
                    ForEach(choices) { choice in
                        ChoiceButton(
                            choice: choice,
                            geometry: geometry,
                            isDisabled: hasChosen,
                            opacity: hasChosen ? 0.6 : 1.0
                        ) {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                // Stop TTS if enabled
                                if isTTSEnabled {
                                    tts.stopSpeech()
                                }
                                
                                selectedChoice = choice
                                showingConfirmation = true
                            }
                        }
                    }
                }
            }
            .padding(.horizontal, geometry.size.width * 0.05)
            Spacer().frame(height: 40)
            
            // Add Previous button at the bottom of choices section
            if !showingConfirmation && currentDialogue > 0 {
                Button {
                    // Stop TTS if enabled
                    if isTTSEnabled {
                        tts.stopSpeech()
                    }
                    
                    // Create a local copy of the current dialogue index
//                    let previousDialogueIndex = currentDialogue - 1
                    
                    // Update state in a specific order
                    withAnimation(.easeInOut(duration: 0.3)) {
                        showChoices = false
                        currentDialogue -= 1
                        // Speak the previous dialogue after a short delay
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            speakCurrentDialogue()
                        }
                    }
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.system(size: geometry.size.width * 0.05))
                        .foregroundColor(.white)
                        .frame(width: geometry.size.width * 0.1, height: geometry.size.width * 0.1)
                        .background(Circle().fill(Color.blue))
                }
                .padding(.bottom, geometry.size.height * 0.03)
            }
        }
    }
    
    private func continueButton(_ geometry: GeometryProxy) -> some View {
        VStack {
            Spacer()
            
            // Check if this is an end node (no choices available) and we're at the last dialogue
            if choices.isEmpty && currentDialogue >= dialogues.count - 1 {
                // For end nodes at the last dialogue, show a fancy Exit button
                Button {
                    // Stop TTS if enabled
                    if isTTSEnabled {
                        tts.stopSpeech()
                    }
                    
                    // Exit after a short delay
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        exitStory()
                    }
                    
                    NotificationCenter.default.post(name: NSNotification.Name("ForceGameMapRefresh"), object: nil)
                } label: {
                    Text("Complete Story")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(.vertical, 12)
                        .padding(.horizontal, 24)
                        .background(
                            ZStack {
                                // Main button background
                                RoundedRectangle(cornerRadius: 15)
                                    .fill(
                                        LinearGradient(
                                            gradient: Gradient(colors: [Color.purple, Color.purple.opacity(0.8)]),
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                
                                // Sparkling effect
                                SparkleView()
                            }
                        )
                        .shadow(color: Color.purple.opacity(0.3), radius: 5, x: 0, y: 2)
                }
                .padding(.bottom, geometry.size.height * 0.05)
                .padding(.horizontal, geometry.size.width * 0.25) // Make button narrower
                .transition(.opacity)
            } else {
                // Navigation buttons for regular dialogue
                HStack(spacing: geometry.size.width * 0.05) {
                    // Previous button - only show if not on first page
                    if currentDialogue > 0 {
                        Button(action: {
                            // Stop TTS if enabled
                            if isTTSEnabled {
                                tts.stopSpeech()
                            }
                            
                            withAnimation(.easeInOut(duration: 0.3)) {
                                if currentDialogue > 0 {
                                    currentDialogue -= 1
                                    // Speak the previous dialogue after a short delay
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                        speakCurrentDialogue()
                                    }
                                }
                            }
                        }) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: geometry.size.width * 0.05))
                                .foregroundColor(.white)
                                .frame(width: geometry.size.width * 0.1, height: geometry.size.width * 0.1)
                                .background(Circle().fill(Color.blue))
                        }
                    }
                    
                    // Next button
                    Button(action: {
                        // Stop TTS if enabled
                        if isTTSEnabled {
                            tts.stopSpeech()
                        }
                        
                        withAnimation(.easeInOut(duration: 0.3)) {
                            currentDialogue += 1
                            if currentDialogue >= dialogues.count {
                                showChoices = true
                            } else {
                                // Speak the next dialogue after a short delay
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                    speakCurrentDialogue()
                                }
                            }
                        }
                    }) {
                        Image(systemName: "chevron.right")
                            .font(.system(size: geometry.size.width * 0.05))
                            .foregroundColor(.white)
                            .frame(width: geometry.size.width * 0.1, height: geometry.size.width * 0.1)
                            .background(Circle().fill(Color.blue))
                    }
                }
                .padding(.bottom, geometry.size.height * 0.05)
            }
        }
    }
    
    private func handleOnAppear() {
        // Reset transition state when view appears
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            // Force reset transition state to ensure we're not stuck in a transition
            transitionManager.resetTransitionState()
            
            withAnimation(.easeIn(duration: 0.3)) {
                transitionManager.isTransitioning = false
            }
            
            // Set view as loaded
            isViewLoaded = true
            
            // Ensure dialogues are properly loaded before displaying
            if !dialogues.isEmpty {
                // Reset to first dialogue
                currentDialogue = 0
                
                // Mark dialogues as loaded after a short delay
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    dialoguesLoaded = true
                    
                    // Speak the first dialogue after a short delay to ensure the view is fully loaded
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        speakCurrentDialogue()
                    }
                }
            }
        }
    }
    
    private func exitStory() {
        // Prevent multiple dismissals
        guard !hasDismissed else { return }
        hasDismissed = true
        
        // Stop TTS if enabled
        if isTTSEnabled {
            tts.stopSpeech()
        }
        
        // Set transition state to true for smooth exit
        withAnimation(.easeOut(duration: 0.3)) {
            transitionManager.isTransitioning = true
            isExiting = true
        }
        
        // Then dismiss after a short delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            if let customDismiss = onDismiss {
                customDismiss()
            } else {
                dismiss()
            }
        }
    }
}

struct SparkleView: View {
    @State private var isAnimating = false
    
    var body: some View {
        ZStack {
            // Add multiple sparkles
            ForEach(0..<12) { i in
                Sparkle(delay: Double(i) * 0.1)
            }
        }
        .onAppear {
            isAnimating = true
        }
    }
}

struct Sparkle: View {
    let delay: Double
    @State private var isVisible = false
    @State private var position = CGPoint(x: 0, y: 0)
    
    var body: some View {
        Image(systemName: "sparkle")
            .font(.system(size: 10))
            .foregroundColor(.white)
            .opacity(isVisible ? 0.8 : 0)
            .scaleEffect(isVisible ? 1.0 : 0.3)
            .position(x: position.x, y: position.y)
            .onAppear {
                // Random position within the button
                position = CGPoint(
                    x: CGFloat.random(in: 10...90),
                    y: CGFloat.random(in: 10...30)
                )
                
                // Start animation with delay
                withAnimation(
                    Animation
                        .easeInOut(duration: 0.8)
                        .repeatForever(autoreverses: true)
                        .delay(delay)
                ) {
                    isVisible = true
                }
            }
    }
}
