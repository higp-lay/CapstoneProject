import SwiftUI

class Scenario: Identifiable {
    let id = UUID()
    let title: String
    let description: String
    var isCompleted: Bool
    var position: CGPoint
    let difficulty: String
    let icon: String
    var isLocked: Bool
    var connections: [UUID]
    
    init(title: String, description: String, isCompleted: Bool, position: CGPoint, difficulty: String, icon: String, isLocked: Bool) {
        self.title = title
        self.description = description
        self.isCompleted = isCompleted
        self.position = position
        self.difficulty = difficulty
        self.icon = icon
        self.isLocked = isLocked
        self.connections = []  // Initialize as empty
    }
    
    // Helper method to connect scenarios
    func connectTo(_ scenario: Scenario) {
        connections.append(scenario.id)
    }
}

struct GameMapView: View {
    @State private var scenarios: [Scenario] = {
        let progress = ProgressManager.shared.currentProgress
        
        let emergencyRoom = Scenario(
            title: "Emergency Room",
            description: "A critical patient arrives from a car accident. Quick decisions are needed.",
            isCompleted: progress.completedScenarios["Emergency Room"]?.isCompleted ?? false,
            position: CGPoint(x: 300, y: 400),
            difficulty: "Easy",
            icon: "cross.circle.fill",
            isLocked: progress.completedScenarios["Emergency Room"]?.isLocked ?? true
        )
        
        let surgeryWard = Scenario(
            title: "Surgery Ward",
            description: "Complex surgery case requiring careful planning and execution.",
            isCompleted: progress.completedScenarios["Surgery Ward"]?.isCompleted ?? false,
            position: CGPoint(x: 250, y: 300),
            difficulty: "Medium",
            icon: "heart.circle.fill",
            isLocked: progress.completedScenarios["Surgery Ward"]?.isLocked ?? true
        )
        
        let initialDecision = Scenario(
            title: "Initial Decision",
            description: "Your journey begins with an important medical decision.",
            isCompleted: progress.completedScenarios["Initial Decision"]?.isCompleted ?? false,
            position: CGPoint(x: 100, y: 200),
            difficulty: "Easy",
            icon: "play.fill",
            isLocked: progress.completedScenarios["Initial Decision"]?.isLocked ?? false
        )
        
        // Connect scenarios
        initialDecision.connectTo(emergencyRoom)
        emergencyRoom.connectTo(surgeryWard)
        
        return [initialDecision, emergencyRoom, surgeryWard]
    }()
    
    @State private var selectedScenario: Scenario?
    @State private var showingDetail = false
    @State private var mapOffset = CGSize.zero  // For map panning
    @State private var mapScale: CGFloat = 1.0  // For map zooming
    @GestureState private var dragOffset = CGSize.zero
    
    var body: some View {
        GeometryReader { geometry in
            ScrollView([.horizontal, .vertical], showsIndicators: false) {
                ZStack {
                    // Background
                    Color.gray.opacity(0.1)
                        .frame(width: max(geometry.size.width * 2, 1000),
                               height: max(geometry.size.height * 2, 1000))
                    
                    // Map Content
                    ZStack {
                        // Connection lines - Updated to include dragOffset
                        ForEach(scenarios) { scenario in
                            ForEach(scenario.connections, id: \.self) { connectionId in
                                if let targetScenario = scenarios.first(where: { $0.id == connectionId }) {
                                    ConnectionLine(
                                        start: CGPoint(
                                            x: scenario.position.x + mapOffset.width + dragOffset.width,
                                            y: scenario.position.y + mapOffset.height + dragOffset.height
                                        ),
                                        end: CGPoint(
                                            x: targetScenario.position.x + mapOffset.width + dragOffset.width,
                                            y: targetScenario.position.y + mapOffset.height + dragOffset.height
                                        )
                                    )
                                }
                            }
                        }
                        
                        // Scenario nodes
                        ForEach(scenarios) { scenario in
                            ScenarioNode(scenario: scenario)
                                .position(
                                    x: scenario.position.x + mapOffset.width + dragOffset.width,
                                    y: scenario.position.y + mapOffset.height + dragOffset.height
                                )
                                .onTapGesture {
                                    selectedScenario = scenario
                                    showingDetail = true
                                }
                        }
                    }
                    .scaleEffect(mapScale)
                }
                .gesture(
                    SimultaneousGesture(
                        DragGesture()
                            .updating($dragOffset) { value, state, _ in
                                state = value.translation
                            }
                            .onEnded { value in
                                mapOffset.width += value.translation.width
                                mapOffset.height += value.translation.height
                            },
                        MagnificationGesture()
                            .onChanged { scale in
                                let delta = scale - 1.0
                                mapScale = max(0.5, min(2.0, mapScale + delta))
                            }
                    )
                )
            }
            .sheet(isPresented: $showingDetail) {
                if let scenario = selectedScenario {
                    ScenarioDetailView(scenario: scenario)
                }
            }
        }
        .navigationTitle("Game Map")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    // Function to unlock a scenario
    func unlockScenario(at index: Int) {
        guard index < scenarios.count else { return }
        scenarios[index].isLocked = false
    }
    
    // Function to mark a scenario as completed and unlock the next one
    func completeScenario(at index: Int) {
        guard index < scenarios.count else { return }
        scenarios[index].isCompleted = true
        
        // Unlock connected scenarios
        let completedScenario = scenarios[index]
        for connectionId in completedScenario.connections {
            if let connectedIndex = scenarios.firstIndex(where: { $0.id == connectionId }) {
                scenarios[connectedIndex].isLocked = false
            }
        }
    }
    
    private func completeScenario(_ scenario: Scenario) {
        if let index = scenarios.firstIndex(where: { $0.id == scenario.id }) {
            ProgressManager.shared.completeScenario(scenario.title)
            // Refresh scenarios array to reflect new progress
            let progress = ProgressManager.shared.currentProgress
            
            // Update the current scenario's status
            scenarios[index].isCompleted = true
            
            // Update connected scenarios' locked status
            for connectionId in scenarios[index].connections {
                if let connectedIndex = scenarios.firstIndex(where: { $0.id == connectionId }) {
                    scenarios[connectedIndex].isLocked = false
                }
            }
        }
    }
    
    // Add this to ScenarioDetailView to handle completion
    private func onScenarioComplete() {
        if let scenario = selectedScenario {
            completeScenario(scenario)
        }
    }
}

#if DEBUG
struct GameMapView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            GameMapView()
        }
    }
}
#endif

struct ConnectionLine: View {
    let start: CGPoint
    let end: CGPoint
    
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
//                        Text(scenario.difficulty)
//                            .font(.subheadline)
//                            .foregroundColor(difficultyColor(scenario.difficulty))
//                            .padding(.horizontal, 16)
//                            .padding(.vertical, 8)
//                            .background(
//                                Capsule()
//                                    .fill(difficultyColor(scenario.difficulty).opacity(0.1))
//                            )
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
                        Button {
                            isShowingScenario = true
                        } label: {
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
                        .navigationDestination(isPresented: $isShowingScenario) {
                            destinationForScenario(scenario)
                        }
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
    
    @ViewBuilder
    private func destinationForScenario(_ scenario: Scenario) -> some View {
        switch scenario.title {
        case "Initial Decision":
            InitialDecision()
        case "Emergency Room":
            EmergencyRoomScene()
        default:
            EmergencyRoomScene() // Default fallback
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

struct ScenarioNode: View {
    let scenario: Scenario
    
    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(nodeColor)
                    .frame(width: 70, height: 70)
                    .shadow(color: nodeColor.opacity(0.3), radius: 5)
                
                if scenario.isLocked {
                    Image(systemName: "lock.fill")
                        .foregroundColor(.white)
                        .font(.system(size: 24))
                } else {
                    Image(systemName: scenario.icon)
                        .foregroundColor(.white)
                        .font(.system(size: 24))
                }
                
                if scenario.isCompleted {
                    Circle()
                        .strokeBorder(Color.green, lineWidth: 3)
                        .frame(width: 70, height: 70)
                }
            }
            
            Text(scenario.title)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(scenario.isLocked ? .gray : .primary)
                .multilineTextAlignment(.center)
                .frame(width: 100)
        }
    }
    
    private var nodeColor: Color {
        if scenario.isLocked {
            return .gray
        }
        if scenario.isCompleted {
            return .green
        }
        switch scenario.difficulty {
        case "Easy": return .blue
        case "Medium": return .orange
        case "Hard": return .red
        default: return .blue
        }
    }
}
