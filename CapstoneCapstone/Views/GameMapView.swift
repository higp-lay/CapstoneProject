import SwiftUI

class Scenario: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    let isCompleted: Bool
    let position: CGPoint
    let difficulty: String
    let icon: String
    let isLocked: Bool
    var connections: [UUID]
    
    init(title: String, description: String, isCompleted: Bool, position: CGPoint, difficulty: String, icon: String, isLocked: Bool, connections: [UUID]) {
        self.title = title
        self.description = description
        self.isCompleted = isCompleted
        self.position = position
        self.difficulty = difficulty
        self.icon = icon
        self.isLocked = isLocked
        self.connections = connections
    }
}

struct GameMapView: View {
    @State private var scenarios: [Scenario] = []
    @State private var scale: CGFloat = 1.0
    
    var body: some View {
        NavigationView {
            ScrollView([.horizontal, .vertical], showsIndicators: true) {
                ZStack {
                    // Connection lines
                    ForEach(scenarios) { scenario in
                        ForEach(scenario.connections, id: \.self) { connectionId in
                            if let connectedScenario = scenarios.first(where: { $0.id == connectionId }) {
                                ConnectionLine(
                                    start: scenario.position,
                                    end: connectedScenario.position
                                )
                            }
                        }
                    }
                    
                    // Scenario nodes
                    ForEach(scenarios) { scenario in
                        ScenarioNode(scenario: scenario)
                            .position(scenario.position)
                    }
                }
                .frame(width: 1200, height: 800)
                .scaleEffect(scale)
                .gesture(
                    MagnificationGesture()
                        .onChanged { value in
                            scale = min(max(value.magnitude, 0.5), 3.0)
                        }
                )
            }
            .navigationTitle("Medical Journey")
            .navigationBarTitleDisplayMode(.inline)
        }
        .onAppear {
            generateScenarios()
        }
    }
    
    private func generateScenarios() {
        let emergencyRoom = Scenario(
            title: "Emergency Room",
            description: "A critical patient arrives with multiple injuries. Time is of the essence.",
            isCompleted: false,
            position: CGPoint(x: 300, y: 400),
            difficulty: "Easy",
            icon: "cross.case.fill",
            isLocked: false,
            connections: []
        )
        
        let resourceAllocation = Scenario(
            title: "Resource Allocation",
            description: "Multiple patients need attention. How do you allocate limited resources?",
            isCompleted: false,
            position: CGPoint(x: 500, y: 300),
            difficulty: "Medium",
            icon: "person.2.fill",
            isLocked: true,
            connections: []
        )
        
        let treatmentPriority = Scenario(
            title: "Treatment Priority",
            description: "Choose between treating a critical but complex case or multiple stable patients.",
            isCompleted: false,
            position: CGPoint(x: 500, y: 500),
            difficulty: "Medium",
            icon: "list.bullet.clipboard",
            isLocked: true,
            connections: []
        )
        
        let familyConflict = Scenario(
            title: "Family Conflict",
            description: "Navigate a complex family disagreement about treatment options.",
            isCompleted: false,
            position: CGPoint(x: 700, y: 200),
            difficulty: "Hard",
            icon: "person.2.circle",
            isLocked: true,
            connections: []
        )
        
        let surgicalDecision = Scenario(
            title: "Surgical Decision",
            description: "Choose between two risky surgical procedures.",
            isCompleted: false,
            position: CGPoint(x: 700, y: 400),
            difficulty: "Hard",
            icon: "heart.text.square",
            isLocked: true,
            connections: []
        )
        
        let ethicalDilemma = Scenario(
            title: "Ethical Dilemma",
            description: "Make a difficult ethical decision that will affect multiple lives.",
            isCompleted: false,
            position: CGPoint(x: 700, y: 600),
            difficulty: "Hard",
            icon: "scale.3d",
            isLocked: true,
            connections: []
        )
        
        let criticalMoment = Scenario(
            title: "Critical Moment",
            description: "A life-or-death decision must be made immediately.",
            isCompleted: false,
            position: CGPoint(x: 900, y: 300),
            difficulty: "Hard",
            icon: "timer",
            isLocked: true,
            connections: []
        )
        
        let finalDecision = Scenario(
            title: "Final Decision",
            description: "Your final choice will determine the ultimate outcome.",
            isCompleted: false,
            position: CGPoint(x: 900, y: 500),
            difficulty: "Hard",
            icon: "arrow.triangle.branch",
            isLocked: true,
            connections: []
        )
        
        let outcomeA = Scenario(
            title: "Best Outcome",
            description: "The patient makes a full recovery.",
            isCompleted: false,
            position: CGPoint(x: 1100, y: 200),
            difficulty: "Final",
            icon: "checkmark.circle",
            isLocked: true,
            connections: []
        )
        
        let outcomeB = Scenario(
            title: "Mixed Outcome",
            description: "The patient stabilizes but faces challenges.",
            isCompleted: false,
            position: CGPoint(x: 1100, y: 400),
            difficulty: "Final",
            icon: "arrow.triangle.2.circlepath",
            isLocked: true,
            connections: []
        )
        
        let outcomeC = Scenario(
            title: "Challenging Outcome",
            description: "The situation takes an unexpected turn.",
            isCompleted: false,
            position: CGPoint(x: 1100, y: 600),
            difficulty: "Final",
            icon: "exclamationmark.triangle",
            isLocked: true,
            connections: []
        )
        
        // Add all scenarios to array
        scenarios = [
            emergencyRoom,
            resourceAllocation,
            treatmentPriority,
            familyConflict,
            surgicalDecision,
            ethicalDilemma,
            criticalMoment,
            finalDecision,
            outcomeA,
            outcomeB,
            outcomeC
        ]
        
        // Set up connections
        emergencyRoom.connections = [resourceAllocation.id, treatmentPriority.id]
        resourceAllocation.connections = [familyConflict.id, surgicalDecision.id]
        treatmentPriority.connections = [surgicalDecision.id, ethicalDilemma.id]
        familyConflict.connections = [criticalMoment.id]
        surgicalDecision.connections = [criticalMoment.id, finalDecision.id]
        ethicalDilemma.connections = [finalDecision.id]
        criticalMoment.connections = [outcomeA.id, outcomeB.id]
        finalDecision.connections = [outcomeB.id, outcomeC.id]
    }
}

struct ConnectionLine: View {
    let start: CGPoint
    let end: CGPoint
    let nodeRadius: CGFloat = 35
    
    var body: some View {
        Path { path in
            path.move(to: start)
            path.addLine(to: end)
        }
        .stroke(Color.blue.opacity(0.5), style: StrokeStyle(
            lineWidth: 3,
            lineCap: .round,
            lineJoin: .round,
            dash: [5, 5]
        ))
    }
}

struct ScenarioDetailView: View {
    let scenario: Scenario
    @Environment(\.dismiss) var dismiss
    @State private var isShowingScenario = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 30) {
                    // Header
                    VStack(spacing: 15) {
                        // Icon
                        ZStack {
                            Circle()
                                .fill(Color.blue.opacity(0.1))
                                .frame(width: 100, height: 100)
                            
                            Image(systemName: scenario.icon)
                                .font(.system(size: 40))
                                .foregroundColor(.blue)
                        }
                        
                        // Title
                        Text(scenario.title)
                            .font(.title)
                            .fontWeight(.bold)
                            .multilineTextAlignment(.center)
                        
                        // Difficulty Badge
                        Text(scenario.difficulty)
                            .font(.subheadline)
                            .foregroundColor(difficultyColor(scenario.difficulty))
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(
                                Capsule()
                                    .fill(difficultyColor(scenario.difficulty).opacity(0.1))
                            )
                    }
                    
                    // Description
                    VStack(alignment: .leading, spacing: 15) {
                        Text("Scenario Description")
                            .font(.headline)
                        
                        Text(scenario.description)
                            .font(.body)
                            .foregroundColor(.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .padding(.horizontal)
                    
                    // Start Button
                    if !scenario.isLocked {
                        NavigationLink(destination: EmergencyRoomScene(), isActive: $isShowingScenario) {
                            HStack {
                                Image(systemName: "play.fill")
                                Text("Begin Scenario")
                            }
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(15)
                        }
                        .padding(.horizontal)
                        .simultaneousGesture(TapGesture().onEnded {
                            dismiss()
                        })
                    } else {
                        // Locked message
                        HStack {
                            Image(systemName: "lock.fill")
                            Text("Complete previous scenarios to unlock")
                        }
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(10)
                    }
                }
                .padding(.vertical, 30)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func difficultyColor(_ difficulty: String) -> Color {
        switch difficulty {
        case "Easy": return .green
        case "Medium": return .orange
        case "Hard": return .red
        case "Final": return .purple
        default: return .blue
        }
    }
}

// Update the ScenarioNode struct
struct ScenarioNode: View {
    let scenario: Scenario
    @State private var isShowingDetail = false
    
    var body: some View {
        Button(action: {
            isShowingDetail.toggle()
        }) {
            VStack(spacing: 8) {
                ZStack {
                    Circle()
                        .fill(scenario.isLocked ? Color.gray.opacity(0.3) : Color.blue.opacity(0.2))
                        .frame(width: 70, height: 70)
                    
                    if scenario.isLocked {
                        Image(systemName: "lock.fill")
                            .foregroundColor(.gray)
                            .font(.system(size: 24))
                    } else {
                        Image(systemName: scenario.icon)
                            .foregroundColor(.blue)
                            .font(.system(size: 24))
                    }
                }
                
                Text(scenario.title)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(scenario.isLocked ? .gray : .primary)
                    .multilineTextAlignment(.center)
                
                Text(scenario.difficulty)
                    .font(.caption2)
                    .foregroundColor(difficultyColor(scenario.difficulty))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background(
                        Capsule()
                            .fill(difficultyColor(scenario.difficulty).opacity(0.2))
                    )
            }
        }
        .sheet(isPresented: $isShowingDetail) {
            ScenarioDetailView(scenario: scenario)
        }
        .disabled(scenario.isLocked)
    }
    
    private func difficultyColor(_ difficulty: String) -> Color {
        switch difficulty {
        case "Easy": return .green
        case "Medium": return .orange
        case "Hard": return .red
        case "Final": return .purple
        default: return .blue
        }
    }
}

#Preview {
    GameMapView()
} 