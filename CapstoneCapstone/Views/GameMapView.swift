import SwiftUI
import Foundation
import Combine

// No need for import CapstoneCapstone as the managers are directly accessible

#if os(macOS)
typealias UIColor = NSColor
#endif

// Add ZoomableScrollView component
struct ZoomableScrollView<Content: View>: View {
    private var content: Content
    @State private var currentScale: CGFloat = 0.9  // Start slightly zoomed out
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        ScrollView([.horizontal, .vertical], showsIndicators: false) {
            content
                .scaleEffect(currentScale)
                .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
                // Add some padding to ensure content can be scrolled to edges
                .padding(100)
        }
        .background(Color.clear) // Make background clear to see content better
    }
}

class Scenario: Identifiable {
    let id = UUID()
    let codeName: String
    let title: String
    let description: String
    var isCompleted: Bool
    var position: CGPoint
    let icon: String
    var isLocked: Bool
    var connections: [UUID]
    var parentId: UUID?  // Add parent ID tracking
    var isHidden: Bool = true  // Add isHidden property
    
    init(codeName: String, title: String, description: String, isCompleted: Bool, position: CGPoint, icon: String, isLocked: Bool) {
        self.codeName = codeName
        self.title = title
        self.description = description
        self.isCompleted = isCompleted
        self.position = position
        self.icon = icon
        self.isLocked = isLocked
        self.connections = []
        self.parentId = nil
        self.isHidden = true  // Initialize as hidden
    }
    
    // Helper method to connect scenarios
    func connectTo(_ scenario: Scenario) {
        connections.append(scenario.id)
        scenario.parentId = self.id  // Set parent ID when connecting
    }
    
    // Helper method to update visibility based on parent's locked status
    func updateVisibility(scenarios: [Scenario]) {
        // Root node (s1S) is always visible
        if codeName == "s1S" {
            self.isHidden = false
//            print("Root node \(codeName) is always visible")
            return
        }
        
        // If this scenario is already unlocked, make it visible
        if !isLocked {
            self.isHidden = false
//            print("Scenario \(codeName) is unlocked, making it visible")
            return
        }
        
        // For locked scenarios, check if parent is unlocked
        if let parentId = self.parentId,
           let parent = scenarios.first(where: { $0.id == parentId }) {
            // Direct children of unlocked parents should be visible but still locked
            if !parent.isLocked {
                self.isHidden = false
//                print("Scenario \(codeName) is a child of unlocked \(parent.codeName), making it visible but keeping it locked")
            } else {
                // If parent is locked, this should be hidden
                self.isHidden = true
//                print("Scenario \(codeName) has locked parent \(parent.codeName), hiding it")
            }
        } else {
            // No parent means it's a root node - always visible
            self.isHidden = false
            print("Scenario \(codeName) has no parent, making it visible as a root node")
        }
        
        print("Visibility updated for \(codeName): isHidden = \(isHidden), isLocked = \(isLocked)")
    }
}

@available(iOS 13.0, macOS 12.0, *)
struct GameMapView: View {
    @Environment(\.dismiss) var dismiss
    @State private var scenarios: [Scenario]
    @State private var selectedScenario: Scenario?
    @State private var showingDetail = false
    @State private var needsRefresh = false
    @State private var mapOffset = CGSize.zero  // For map panning
    @State private var currentScale: CGFloat = 0.95  // For map zooming
    @GestureState private var dragOffset = CGSize.zero
    @State private var screenSize: CGSize = .zero // Add this to store screen size
    @State private var contentOffset = CGSize.zero // For centering content
    
    // Add missing state variables
    @State private var showingScenarioDetail = false
    @State private var showingLockedAlert = false
    @State private var showingAchievements = false
    @State private var scrollViewProxy: ScrollViewProxy? = nil
    
    // Add constants for node and map size
    private let nodeSize = CGSize(width: 60, height: 60)
    private var mapSize: CGSize {
        // Reduce the map size to eliminate excess space while ensuring all nodes fit
        return CGSize(width: max(screenSize.width * 1.4, 800), height: max(screenSize.height * 1, 800))
    }
    
    init() {
        _scenarios = State(initialValue: []) // Initialize as empty
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background - use a cross-platform solution
                #if os(iOS)
                Color(UIColor.systemBackground)
                    .ignoresSafeArea()
                #elseif os(macOS)
                Color(.windowBackgroundColor)
                    .ignoresSafeArea()
                #endif
                
                // Map content
        GeometryReader { geometry in
                    // Use ScrollViewReader to programmatically scroll to the first node
                    ScrollViewReader { scrollProxy in
                        // Remove the VStack and Spacer that are creating the white border
                        ZStack {
                            // Scrollable content
            ScrollView([.horizontal, .vertical], showsIndicators: false) {
                ZStack {
                                    // Background grid for visual reference
                                    GridBackground(mapSize: mapSize)
                                        .opacity(0.1)
                                    
                                    // Connections between nodes
                                    ConnectionsView(scenarios: scenarios)
                                    
                                    // Scenario nodes
                                    ScenariosView(
                                        scenarios: scenarios,
                                        nodeSize: nodeSize,
                                        selectedScenario: $selectedScenario,
                                        showingScenarioDetail: $showingScenarioDetail,
                                        showingLockedAlert: $showingLockedAlert
                                    )
                                    
                                    // Add an invisible center marker for positioning
                                    Color.clear
                                        .frame(width: 1, height: 1)
                                        .id("mapCenter")
                                        .position(x: mapSize.width / 2 + 100, y: mapSize.height / 2) // Increased to 100 points to the right
                                }
                                .frame(width: mapSize.width, height: mapSize.height)
                                // Apply a scale effect for zooming - slightly larger to make nodes more visible
                                .scaleEffect(0.95)
                                // Add generous padding to ensure content isn't cut off at edges
                                .padding(200)
                            }
                            // Adjust the padding to account for the 100-point shift
                            .padding(.leading, -mapSize.width / 2 + 100) // Changed from 170 to 100 for proper centering
                            .padding(.top, -mapSize.height / 2 + 200)
                            .background(Color.clear)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .clipped(antialiased: true)
                            
                            // Add center button at bottom right corner
                            VStack {
                                Spacer()
                                HStack {
                                    Spacer()
                                    Button(action: {
                                        // Call the existing centerOnFirstNode function
                                        centerOnFirstNode()
                                        
                                        // Also scroll to the center marker
                                        withAnimation(.easeInOut(duration: 0.5)) {
                                            scrollProxy.scrollTo("mapCenter", anchor: .center)
                                        }
                                    }) {
                                        Image(systemName: "scope")
                                            .font(.system(size: 20))
                                            .foregroundColor(.white)
                                            .frame(width: 50, height: 50)
                                            .background(Color.blue)
                                            .clipShape(Circle())
                                            .shadow(radius: 3)
                                    }
                                    .padding(20)
                                }
                            }
                        }
                        
                        // Use onAppear to scroll to the center of the map
                        .onAppear {
                            // Delay to ensure layout is complete
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                // Scroll to the center anchor
                                withAnimation(.easeInOut(duration: 0.5)) {
                                    scrollProxy.scrollTo("mapCenter", anchor: .center)
                                }
                                print("Scrolled to map center")
                            }
                        }
                    }
                }
                
                // UI Controls - Trophy button removed
            }
            // Add padding to the top to eliminate the empty space
            .padding(.top, 8)
            #if os(iOS)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("The Gift of Life")
                        .font(.headline)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
            #elseif os(macOS)
            .toolbar {
                ToolbarItem(placement: .automatic) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
            #endif
            .sheet(item: $selectedScenario) { scenario in
                ScenarioDetailView(
                    scenario: scenario,
                    onDismiss: {
                        selectedScenario = nil
                        showingDetail = false
                    }
                )
            }
            .onAppear {
                // Use a default size that works on both platforms
                #if os(iOS)
                let mainScreen = UIScreen.main.bounds.size
                screenSize = CGSize(width: mainScreen.width, height: mainScreen.height)
                #elseif os(macOS)
                screenSize = CGSize(width: 800, height: 600) // Default size for macOS
                #endif
                scenarios = Self.createScenarios(screenSize: screenSize)
                
                // Force center on first node after a short delay to ensure layout is complete
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    centerOnFirstNode()
                }
            }
        }
//        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("ProgressUpdated"))) { _ in
//            refreshMap()
//        }
//        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("ScenarioUnlocked"))) { _ in
//            refreshMap()
//        }
//        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("ScenarioCompleted"))) { _ in
//            refreshMap()
//        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("ForceGameMapRefresh"))) { _ in
            refreshMap()
        }
    }
    
    private func centerOnFirstNode() {
        // This function explicitly centers the first node
        print("Explicitly centering on first node")
        
        // Find the first node (s1)
        if let firstNode = scenarios.first(where: { $0.codeName == "s1" }) {
            // Calculate the offset needed to center the first node
            // For the s1 node, we need a specific offset that works well
            // These values are determined through testing
            let offsetX: CGFloat = 80  // Increased from 50 to 80 to account for the 30-point shift
            let offsetY: CGFloat = -300   // No vertical adjustment needed
            
            // Apply the offset with animation
            withAnimation(.easeInOut(duration: 0.5)) {
                mapOffset = CGSize(width: offsetX, height: offsetY)
            }
            
            print("First node position: \(firstNode.position)")
            print("Applied fixed offset: \(offsetX), \(offsetY)")
        } else {
            print("First node (s1) not found!")
            
            // Default offset if node not found
            withAnimation(.easeInOut(duration: 0.5)) {
                mapOffset = CGSize.zero
            }
        }
        
        // Force UI update to ensure centering takes effect
        needsRefresh.toggle()
    }
    
    func refreshMap() {
        // Force recreate scenarios and reset state
        DispatchQueue.main.async {
            // Clear current scenarios to ensure complete rebuild
            self.scenarios = []
            
            // Recreate all scenarios with current progress
            self.scenarios = Self.createScenarios(screenSize: self.screenSize)
            
            // Force UI update
            self.needsRefresh.toggle()
        }
    }
    
    static func createScenarios(screenSize: CGSize) -> [Scenario] {
        var progress = ProgressManager.shared.currentProgress
        print("Creating scenarios with current progress:")
        ProgressManager.shared.printCurrentProgress()
        
        // Calculate center position - use the map size instead of screen size
        let mapWidth = max(screenSize.width * 1.3, 800)
        let mapHeight = max(screenSize.height * 1.3, 800)
        let centerX = mapWidth / 2 + 160 // Increased to 100 points to the right
        let centerY = mapHeight / 2
        
        // Create scenarios with current progress state
        let s1S = Scenario(
            codeName: "s1S",
            title: "Why We Live",
            description: "Before we begin, let's talk about life.",
            isCompleted: progress.completedScenarios["s1S"]?.isCompleted ?? false,
            position: CGPoint(x: centerX, y: centerY - 160),
            icon: "play.fill",
            isLocked: false
        )
        
        let s1 = Scenario(
            codeName: "s1",
            title: "The Cost of Survival",
            description: "A routine check-up becomes a life-changing moment. Face a decision that will test your values and reshape your family's future.",
            isCompleted: progress.completedScenarios["s1"]?.isCompleted ?? false,
            position: CGPoint(x: centerX, y: centerY), // Center of map, shifted right
            icon: "bolt.heart.fill",
            isLocked: progress.completedScenarios["s1"]?.isLocked ?? true
        )
        
        // Position other nodes relative to center with improved spacing
        let s1A = Scenario(
            codeName: "s1A",
            title: "The Risk We Take",
            description: "Face the aftermath of your expensive treatment. Confront decisions that involve risks to, not just yourself, but others. What makes a risk worth taking?",
            isCompleted: progress.completedScenarios["s1A"]?.isCompleted ?? false,
            position: CGPoint(x: centerX - 180, y: centerY - 120), // Adjusted position
            icon: "pills.circle.fill",
            isLocked: progress.completedScenarios["s1A"]?.isLocked ?? true
        )
        
        let s1B = Scenario(
            codeName: "s1B",
            title: "The Reason Why",
            description: "Confront a difficult reality as treatment turns out to be ineffective. Does prolonging life matter more than quality of life in the current moment?",
            isCompleted: progress.completedScenarios["s1B"]?.isCompleted ?? false,
            position: CGPoint(x: centerX + 180, y: centerY - 120), // Adjusted position
            icon: "waveform.path.ecg",
            isLocked: progress.completedScenarios["s1B"]?.isLocked ?? true
        )
        
        let s1A1 = Scenario(
            codeName: "s1A1",
            title: "Self and Strangers",
            description: "You have experienced a lot of hardship in the past. A reward has come. Is it a time to help strangers, or a time to bring solace to the family?",
            isCompleted: progress.completedScenarios["s1A1"]?.isCompleted ?? false,
            position: CGPoint(x: centerX - 280, y: centerY - 200), // Adjusted position
            icon: "person.2.fill",
            isLocked: progress.completedScenarios["s1A1"]?.isLocked ?? true
        )
        
        let s1A2 = Scenario(
            codeName: "s1A2",
            title: "Identity",
            description: "Meet an unexpected opportunity that can be life-changing. What constitutes our identity? How important is our uniqueness?",
            isCompleted: progress.completedScenarios["s1A2"]?.isCompleted ?? false,
            position: CGPoint(x: centerX - 240, y: centerY + 20), // Adjusted position
            icon: "person.crop.circle.badge.questionmark",
            isLocked: progress.completedScenarios["s1A2"]?.isLocked ?? true
        )
        
        let s1B1 = Scenario(
            codeName: "s1B1",
            title: "Eternity",
            description: "Continue your fight against cancer through more rounds of chemotherapy. How much longer do you want to live?",
            isCompleted: progress.completedScenarios["s1B1"]?.isCompleted ?? false,
            position: CGPoint(x: centerX + 280, y: centerY - 200), // Adjusted position
            icon: "hourglass",
            isLocked: progress.completedScenarios["s1B1"]?.isLocked ?? true
        )
        
        let s1B2 = Scenario(
            codeName: "s1B2",
            title: "Dignity",
            description: "You explored the Cost of Survival. What about the Value of Survival? What makes surviving meaningful?.",
            isCompleted: progress.completedScenarios["s1B2"]?.isCompleted ?? false,
            position: CGPoint(x: centerX + 240, y: centerY + 20), // Adjusted position
            icon: "sun.max.fill",
            isLocked: progress.completedScenarios["s1B2"]?.isLocked ?? true
        )
        
        let s1A1a = Scenario(
            codeName: "s1A1a",
            title: "Joy",
            description: "Spend the money on your family, ensuring quality time together in your remaining years. Find peace in simple moments with loved ones.",
            isCompleted: progress.completedScenarios["s1A1a"]?.isCompleted ?? false,
            position: CGPoint(x: centerX - 380, y: centerY - 240), // Adjusted position
            icon: "house.fill",
            isLocked: progress.completedScenarios["s1A1a"]?.isLocked ?? true
        )
        
        let s1A1b = Scenario(
            codeName: "s1A1b",
            title: "Compassion",
            description: "Donate your fortune to a cancer fund, hoping to help others facing the same struggles you endured. Your sacrifice may save a child's life.",
            isCompleted: progress.completedScenarios["s1A1b"]?.isCompleted ?? false,
            position: CGPoint(x: centerX - 340, y: centerY - 100), // Adjusted position
            icon: "hand.raised.fill",
            isLocked: progress.completedScenarios["s1A1b"]?.isLocked ?? true
        )
        
        let s1A2a = Scenario(
            codeName: "s1A2a",
            title: "Embracing Uncertainties",
            description: "Agree to have your stem cells extracted for future research, contemplating what it means to leave a part of yourself behind after death.",
            isCompleted: progress.completedScenarios["s1A2a"]?.isCompleted ?? false,
            position: CGPoint(x: centerX - 300, y: centerY + 140), // Adjusted position
            icon: "leaf.fill",
            isLocked: progress.completedScenarios["s1A2a"]?.isLocked ?? true
        )
        
        let s1A2b = Scenario(
            codeName: "s1A2b",
            title: "Peace In Endings",
            description: "Decline the stem cell extraction, finding peace in the natural end of your life. You've lived once and that was enough.",
            isCompleted: progress.completedScenarios["s1A2b"]?.isCompleted ?? false,
            position: CGPoint(x: centerX - 180, y: centerY + 200), // Adjusted position
            icon: "peacesign",
            isLocked: progress.completedScenarios["s1A2b"]?.isLocked ?? true
        )
        
        let s1B1a = Scenario(
            codeName: "s1B1a",
            title: "It Never Ends",
            description: "Choose cryonics to preserve your body after death, hoping for a second life in the future. You believe life is worth celebrating with another chance.",
            isCompleted: progress.completedScenarios["s1B1a"]?.isCompleted ?? false,
            position: CGPoint(x: centerX + 380, y: centerY - 240), // Adjusted position
            icon: "snowflake",
            isLocked: progress.completedScenarios["s1B1a"]?.isLocked ?? true
        )
        
        let s1B1b = Scenario(
            codeName: "s1B1b",
            title: "Nature Dictates",
            description: "Decline cryonics, preferring your loved ones to have closure rather than lingering hope. You want them to celebrate the life you shared together.",
            isCompleted: progress.completedScenarios["s1B1b"]?.isCompleted ?? false,
            position: CGPoint(x: centerX + 340, y: centerY - 100), // Adjusted position
            icon: "moon.stars.fill",
            isLocked: progress.completedScenarios["s1B1b"]?.isLocked ?? true
        )
        
        let s1B2a = Scenario(
            codeName: "s1B2a",
            title: "Strength in Endings",
            description: "Find dignity in accepting the end of your life on your own terms. You choose to leave your family financially stable rather than prolonging your suffering.",
            isCompleted: progress.completedScenarios["s1B2a"]?.isCompleted ?? false,
            position: CGPoint(x: centerX + 300, y: centerY + 140), // Adjusted position
            icon: "mountain.2.fill",
            isLocked: progress.completedScenarios["s1B2a"]?.isLocked ?? true
        )
        
        let s1B2b = Scenario(
            codeName: "s1B2b",
            title: "Passing on the Light",
            description: "Reflect on your life's journey and the choices you've made. Find peace in knowing your children will have financial stability after you're gone.",
            isCompleted: progress.completedScenarios["s1B2b"]?.isCompleted ?? false,
            position: CGPoint(x: centerX + 180, y: centerY + 200), // Adjusted position
            icon: "sparkles.rectangle.stack",
            isLocked: progress.completedScenarios["s1B2b"]?.isLocked ?? true
        )
        
        // Connect scenarios
        s1S.connectTo(s1)
        
        s1.connectTo(s1A)
        s1.connectTo(s1B)
        
        s1A.connectTo(s1A1)
        s1A.connectTo(s1A2)
        
        s1A1.connectTo(s1A1a)
        s1A1.connectTo(s1A1b)
        
        s1A2.connectTo(s1A2a)
        s1A2.connectTo(s1A2b)
        
        s1B.connectTo(s1B1)
        s1B.connectTo(s1B2)
        
        s1B1.connectTo(s1B1a)
        s1B1.connectTo(s1B1b)
        
        s1B2.connectTo(s1B2a)
        s1B2.connectTo(s1B2b)
        
        let allScenarios = [s1S, s1, s1A, s1B, s1A1, s1A2, s1A1a, s1A1b, s1A2a, s1A2b, s1B1, s1B2, s1B1a, s1B1b, s1B2a, s1B2b]
        
        // Print the locked status of all scenarios before updating visibility
//        print("\n===== SCENARIO STATUS BEFORE VISIBILITY UPDATE =====")
//        for scenario in allScenarios {
//            print("\(scenario.codeName): locked=\(scenario.isLocked), completed=\(scenario.isCompleted)")
//        }
//        
        // Update visibility for all scenarios
        for scenario in allScenarios {
            scenario.updateVisibility(scenarios: allScenarios)
        }
//        
//        // Print the final status of all scenarios after updating visibility
//        print("\n===== FINAL SCENARIO STATUS AFTER VISIBILITY UPDATE =====")
//        for scenario in allScenarios {
//            print("\(scenario.codeName): locked=\(scenario.isLocked), hidden=\(scenario.isHidden), completed=\(scenario.isCompleted)")
//        }
        
        return allScenarios
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
        print("GameMapView is trying to complete scenario: \(scenario.codeName)")
        if let index = scenarios.firstIndex(where: { $0.id == scenario.id }) {
            print("Found scenario at index \(index)")
            ProgressManager.shared.completeScenario(scenario.codeName)
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
        } else {
            print("ERROR: Could not find scenario with ID \(scenario.id) in the scenarios array")
        }
    }
    
    private func onScenarioComplete(_ scenarioCodeName: String) {
        // Prevent duplicate calls
        print("GameMapView.onScenarioComplete called with: \(scenarioCodeName)")
        
        // Mark the scenario as completed using the passed code name
        ProgressManager.shared.completeScenario(scenarioCodeName)
        
        // First dismiss the scenario view - use showingScenario instead of isShowingScenario
        // This method is in GameMapView, so we don't have access to isShowingScenario
        
        // Then dismiss the detail sheet after a short delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            print("GameMapView: Dismissing detail sheet for \(scenarioCodeName) after delay")
            withAnimation {
                self.showingDetail = false
            }
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
    let isCompleted: Bool
    let isTargetLocked: Bool
    
    var body: some View {
        Path { path in
            path.move(to: start)
            path.addLine(to: end)
        }
        .stroke(isCompleted && !isTargetLocked ? Color.blue : Color.gray.opacity(0.7), style: StrokeStyle(
            lineWidth: 3, // Increased line width
            lineCap: .round,
            lineJoin: .round,
            dash: isCompleted && !isTargetLocked ? [] : [5, 5] // Always use dashed style for locked targets
        ))
    }
}

struct ScenarioDetailView: View {
    let scenario: Scenario
    let onDismiss: () -> Void
    @Environment(\.dismiss) var dismiss
    @State private var isShowingScenario = false
    @State private var isNavigationActive = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 30) {
                    // Header
                    VStack(spacing: 15) {
                        // Icon
                        ZStack {
                            Circle()
                                .fill(scenario.isLocked ? Color.gray.opacity(0.2) : Color.blue.opacity(0.1))
                                .frame(width: 100, height: 100)
                            
                            if scenario.isLocked {
                                Image(systemName: "lock.fill")
                                    .font(.system(size: 40))
                                    .foregroundColor(.gray)
                            } else {
                            Image(systemName: scenario.icon)
                                .font(.system(size: 40))
                                .foregroundColor(.blue)
                            }
                        }
                        
                        // Title - show ??? for locked scenarios
                        Text(scenario.isLocked ? "???" : scenario.title)
                            .font(.title)
                            .fontWeight(.bold)
                            .multilineTextAlignment(.center)
                    }
                    
                    // Description - show ??? for locked scenarios
                    VStack(alignment: .leading, spacing: 15) {
                        Text("Scenario Description")
                            .font(.headline)
                        
                        Text(scenario.isLocked ? "???" : scenario.description)
                            .font(.body)
                            .foregroundColor(.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .padding(.horizontal)
                    
                    // Start Button
                    if !scenario.isLocked {
                        Button {
                            if scenario.codeName == "s1S" {
                                // Post notification after a slight delay to avoid immediate dismissal
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                    NotificationCenter.default.post(name: NSNotification.Name("ForceGameMapRefresh"), object: nil)
                                }
                            }
                            // Set isShowingScenario to true to show the scenario
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
                        .sheet(isPresented: $isShowingScenario) {
                            destinationForScenario(scenario)
                        }
                    } else {
                        // Locked message
                        HStack {
                            Image(systemName: "lock.fill")
                            Text("Return to the previous scenario to unlock")
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
            #if os(iOS)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text(scenario.isLocked ? "???" : scenario.title)
                        .font(.headline)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Close") {
                        onDismiss()
                        dismiss()
                    }
                }
            }
            #elseif os(macOS)
            .toolbar {
                ToolbarItem(placement: .automatic) {
                    Button("Close") {
                        onDismiss()
                        dismiss()
                    }
                }
            }
            #endif
            .interactiveDismissDisabled()
        }
    }
    
    @ViewBuilder
    private func destinationForScenario(_ scenario: Scenario) -> some View {
        let scenarioCodeName = scenario.codeName
        
//        print("Creating destination for scenario: \(scenarioCodeName)")
        
        // Create a wrapper view that handles the scenario and prevent multiple dismissals
        ScenarioWrapperView(scenarioName: scenarioCodeName, onComplete: {
            print("ScenarioWrapperView onComplete callback triggered for \(scenarioCodeName)")
            onScenarioComplete(scenarioCodeName)
        })
    }
    
    // Add a wrapper view that handles the scenario and prevent multiple dismissals
    private struct ScenarioWrapperView: View {
        let scenarioName: String
        let onComplete: () -> Void
        @State private var hasCompleted = false
        @State private var isLoading = true
        @State private var hasNavigated = false
        @State private var isFirstAppear = true
        @State private var completionCalled = false
        
        var body: some View {
            ZStack {
                // Show a loading indicator while the scene is being prepared
                if isLoading {
                    ProgressView("Loading scenario...")
                        .padding()
                        .background(Color.white.opacity(0.8))
                        .cornerRadius(10)
                }
                
                // Use a custom wrapper to prevent recursive calls
                SceneWrapper(scenarioName: scenarioName, onComplete: {
                    // Only call onComplete once
                    guard !hasCompleted && !hasNavigated && !completionCalled else { 
                        print("ScenarioWrapperView: Prevented duplicate onComplete call for \(scenarioName)")
                        return 
                    }
                    
                    // Set flags to prevent multiple calls
                    hasCompleted = true
                    hasNavigated = true
                    completionCalled = true
                    
                    print("ScenarioWrapperView: onComplete called for \(scenarioName)")
                    
                    // Add a small delay to ensure proper sequence
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        print("ScenarioWrapperView: Executing delayed onComplete for \(scenarioName)")
                        onComplete()
                    }
                })
                .onAppear {
                    // Only initialize on first appear to prevent duplicate initialization
                    if isFirstAppear {
                        isFirstAppear = false
                        
                        // Reset state variables
                        hasCompleted = false
                        hasNavigated = false
                        completionCalled = false
                        
                        // Initialize transition
                        TransitionManager.shared.initializeMapTransition(to: scenarioName)
                        
                        print("Loading scenario: \(scenarioName) (first appear)")
                        
                        // Hide loading indicator after a short delay
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            isLoading = false
                        }
                    } else {
                        print("Ignoring subsequent onAppear for \(scenarioName)")
                    }
                }
                .onDisappear {
                    print("ScenarioWrapperView.onDisappear for \(scenarioName), hasCompleted=\(hasCompleted), hasNavigated=\(hasNavigated), completionCalled=\(completionCalled)")
                }
            }
        }
    }
    
    // Add a wrapper struct to prevent recursive scene loading
    private struct SceneWrapper: View {
        let scenarioName: String
        let onComplete: () -> Void
        @State private var hasLoaded = false
        @State private var sceneContent: AnyView?
        
        var body: some View {
            ZStack {
                if let content = sceneContent {
                    content
                } else {
                    // Show a placeholder while loading
                    Color.clear
                        .onAppear {
                            if !hasLoaded {
                                hasLoaded = true
                                print("SceneWrapper: Loading scene \(scenarioName) (first time)")
                                sceneContent = SceneManager.shared.getScene(scenarioName, onComplete: onComplete )
                            }
                        }
                }
            }
        }
    }
    
    private func onScenarioComplete(_ scenarioCodeName: String) {
        // Prevent duplicate calls
        print("ScenarioDetailView.onScenarioComplete called with: \(scenarioCodeName)")
        
        // Mark the scenario as completed using the passed code name
        ProgressManager.shared.completeScenario(scenarioCodeName)
        
        // First dismiss the scenario view
        isShowingScenario = false
        
        // Then dismiss the detail sheet after a short delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            print("Dismissing scenario detail after completion of \(scenarioCodeName)")
            onDismiss()
            dismiss()
        }
    }
}

struct ScenarioNode: View {
    let scenario: Scenario
    let size: CGSize
    let onTap: () -> Void
    
    var body: some View {
        VStack(spacing: 12) { // Increased spacing
            ZStack {
                Circle()
                    .fill(nodeColor)
                    .frame(width: size.width * 1.3, height: size.height * 1.3) // Increased node size by 30%
                    .shadow(color: nodeColor.opacity(0.3), radius: 5)
                
                if scenario.isLocked {
                    Image(systemName: "lock.fill")
                        .foregroundColor(.white)
                        .font(.system(size: 30)) // Increased icon size
                } else {
                    Image(systemName: scenario.icon)
                        .foregroundColor(.white)
                        .font(.system(size: 30)) // Increased icon size
                }
            }
            .background(Circle().fill(Color.white))
            
            Text(scenario.isLocked ? "???" : scenario.title)
                .font(.system(size: 14, weight: .medium)) // Increased font size and made it medium weight
                .foregroundColor(scenario.isLocked ? .gray : .primary)
                .multilineTextAlignment(.center)
                .frame(width: 120) // Increased text width
        }
        .opacity(scenario.isLocked ? 0.8 : 1.0)  // Slightly dim locked nodes
        .onTapGesture {
            onTap()
        }
    }
    
    var nodeColor: Color {
        if scenario.isLocked {
            return Color.gray
        } else if scenario.isCompleted {
            return Color.green // Changed from blue to green for completed nodes
        } else {
            return Color.blue.opacity(0.7)
        }
    }
}

// Fix platform-specific code
#if os(iOS)
// iOS-specific extensions
extension View {
    func navigationBarTitleDisplayMode(_ mode: NavigationBarItem.TitleDisplayMode) -> some View {
        self
    }
}
#endif

// Add this new struct to break down the complex expression
struct MapContentView: View {
    let scenarios: [Scenario]
    let nodeSize: CGSize
    let mapSize: CGSize
    @Binding var selectedScenario: Scenario?
    @Binding var showingScenarioDetail: Bool
    @Binding var showingLockedAlert: Bool
    
    var body: some View {
        ZStack {
            // Background grid for visual reference (optional)
            GridBackground(mapSize: mapSize)
                .opacity(0.1)
            
            // Connections between nodes
            ConnectionsView(scenarios: scenarios)
            
            // Scenario nodes
            ScenariosView(
                scenarios: scenarios,
                nodeSize: nodeSize,
                selectedScenario: $selectedScenario,
                showingScenarioDetail: $showingScenarioDetail,
                showingLockedAlert: $showingLockedAlert
            )
        }
    }
}

// Add a grid background to help with visual orientation
struct GridBackground: View {
    let mapSize: CGSize
    let gridSpacing: CGFloat = 100
    
    var body: some View {
        Canvas { context, size in
            // Draw vertical lines
            for x in stride(from: 0, to: mapSize.width, by: gridSpacing) {
                let path = Path { p in
                    p.move(to: CGPoint(x: x, y: 0))
                    p.addLine(to: CGPoint(x: x, y: mapSize.height))
                }
                context.stroke(path, with: .color(.gray), lineWidth: 0.5)
            }
            
            // Draw horizontal lines
            for y in stride(from: 0, to: mapSize.height, by: gridSpacing) {
                let path = Path { p in
                    p.move(to: CGPoint(x: 0, y: y))
                    p.addLine(to: CGPoint(x: mapSize.width, y: y))
                }
                context.stroke(path, with: .color(.gray), lineWidth: 0.5)
            }
        }
        .frame(width: mapSize.width, height: mapSize.height)
    }
}

// Further break down the connections view
struct ConnectionsView: View {
    let scenarios: [Scenario]
    
    var body: some View {
        ForEach(scenarios) { scenario in
            ForEach(scenario.connections, id: \.self) { connectionId in
                ConnectionLineView(scenario: scenario, connectionId: connectionId, scenarios: scenarios)
            }
        }
    }
}

// Break down the connection line view
struct ConnectionLineView: View {
    let scenario: Scenario
    let connectionId: UUID
    let scenarios: [Scenario]
    
    var body: some View {
        Group {
            if let targetScenario = scenarios.first(where: { $0.id == connectionId }),
               !scenario.isHidden && !targetScenario.isHidden {
                ConnectionLine(
                    start: scenario.position,
                    end: targetScenario.position,
                    isCompleted: scenario.isCompleted,
                    isTargetLocked: targetScenario.isLocked
                )
            }
        }
    }
}

// Break down the scenarios view
struct ScenariosView: View {
    let scenarios: [Scenario]
    let nodeSize: CGSize
    @Binding var selectedScenario: Scenario?
    @Binding var showingScenarioDetail: Bool
    @Binding var showingLockedAlert: Bool
    
    var body: some View {
        ForEach(scenarios) { scenario in
            if !scenario.isHidden {
                ScenarioNode(
                    scenario: scenario,
                    size: nodeSize,
                    onTap: {
                        // Always show the scenario detail view, regardless of lock status
                        selectedScenario = scenario
                        showingScenarioDetail = true
                    }
                )
                .position(scenario.position)
            }
        }
    }
}

#if os(iOS)
private func findScrollView(in geometry: GeometryProxy) -> UIScrollView? {
    // Find the UIScrollView in the view hierarchy
    for subview in UIApplication.shared.windows.first?.rootViewController?.view.subviews ?? [] {
        if let scrollView = findScrollViewRecursively(in: subview) {
            return scrollView
        }
    }
    return nil
}

private func findScrollViewRecursively(in view: UIView) -> UIScrollView? {
    // Check if this view is a scroll view
    if let scrollView = view as? UIScrollView {
        return scrollView
    }
    
    // Check all subviews recursively
    for subview in view.subviews {
        if let scrollView = findScrollViewRecursively(in: subview) {
            return scrollView
        }
    }
    
    return nil
}
#endif
