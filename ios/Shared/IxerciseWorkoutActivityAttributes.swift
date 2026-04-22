import ActivityKit
import Foundation

@available(iOS 16.2, *)
struct IxerciseWorkoutActivityAttributes: ActivityAttributes {
  struct ContentState: Codable, Hashable {
    var phase: String
    var title: String
    var subtitle: String
    var remainingSeconds: Int?
    var totalSeconds: Int?
    var progress: Double
    var isPaused: Bool
    var updatedAt: Date
  }

  var sessionId: String
  var planName: String
}
