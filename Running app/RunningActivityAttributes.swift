import ActivityKit
import SwiftUI

struct RunningActivityAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // FIX: Track the Date when the workout will end
        var endTime: Date
        var progress: Double
        var isComplete: Bool
        var isPaused: Bool
        var timeRemainingWhenPaused: TimeInterval
    }

    var totalWorkoutDuration: TimeInterval
}
