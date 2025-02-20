import Foundation

struct UserProgress: Codable {
    var completedScenarios: [String: ScenarioProgress]
    
    struct ScenarioProgress: Codable {
        var isCompleted: Bool
        var isLocked: Bool
        var dateCompleted: Date?
    }
    
    static let defaultProgress: [String: ScenarioProgress] = [
        "Initial Decision": ScenarioProgress(isCompleted: false, isLocked: false, dateCompleted: nil),
        "Emergency Room": ScenarioProgress(isCompleted: false, isLocked: true, dateCompleted: nil),
        "Surgery Ward": ScenarioProgress(isCompleted: false, isLocked: true, dateCompleted: nil)
    ]
}

class ProgressManager {
    static let shared = ProgressManager()
    private let userDefaultsKey = "userProgress"
    
    var currentProgress: UserProgress {
        get {
            if let data = UserDefaults.standard.data(forKey: userDefaultsKey) {
                do {
                    return try JSONDecoder().decode(UserProgress.self, from: data)
                } catch {
                    print("Error decoding progress: \(error)")
                    return UserProgress(completedScenarios: UserProgress.defaultProgress)
                }
            }
            return UserProgress(completedScenarios: UserProgress.defaultProgress)
        }
        set {
            do {
                let data = try JSONEncoder().encode(newValue)
                UserDefaults.standard.set(data, forKey: userDefaultsKey)
            } catch {
                print("Error saving progress: \(error)")
            }
        }
    }
    
    func completeScenario(_ title: String) {
        var progress = currentProgress
        progress.completedScenarios[title]?.isCompleted = true
        progress.completedScenarios[title]?.dateCompleted = Date()
        
        // Unlock next scenarios based on connections
        if title == "Initial Decision" {
            progress.completedScenarios["Emergency Room"]?.isLocked = false
        } else if title == "Emergency Room" {
            progress.completedScenarios["Surgery Ward"]?.isLocked = false
        }
        
        currentProgress = progress
    }
    
    func resetProgress() {
        currentProgress = UserProgress(completedScenarios: UserProgress.defaultProgress)
    }
} 