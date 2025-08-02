import Foundation
import ActivityKit
import SwiftUI

class ActivityManager {
    static let shared = ActivityManager()
    
    private var activity: Activity<RunningActivityAttributes>? = nil
    
    func start(warmUpDuration: TimeInterval, highIntensityDuration: TimeInterval, lowIntensityDuration: TimeInterval, numberOfIntervals: Int) {
        guard activity == nil else {
            print("Activity already active.")
            return
        }
        
        let workoutIntervalsDuration = (highIntensityDuration + lowIntensityDuration) * Double(numberOfIntervals)
        let totalDuration = warmUpDuration + workoutIntervalsDuration
        
        let attributes = RunningActivityAttributes(totalWorkoutDuration: totalDuration)
        let endTime = Date().addingTimeInterval(totalDuration)
        
        // FIX: Added the missing arguments for the initial state
        let initialState = RunningActivityAttributes.ContentState(
            endTime: endTime,
            progress: 0,
            isComplete: false,
            isPaused: false,
            timeRemainingWhenPaused: 0
        )
        let content = ActivityContent(state: initialState, staleDate: nil)
        
        do {
            activity = try Activity.request(attributes: attributes, content: content)
            print("Live Activity started successfully.")
        } catch {
            print("Error starting Live Activity: \(error.localizedDescription)")
        }
    }
    
    func update(totalTimeRemaining: TimeInterval) {
        guard let activity = activity else { return }
        
        let totalDuration = activity.attributes.totalWorkoutDuration
        let timeElapsed = totalDuration - totalTimeRemaining
        let newProgress = timeElapsed / totalDuration
        
        let newState = RunningActivityAttributes.ContentState(
            endTime: activity.content.state.endTime,
            progress: newProgress,
            isComplete: false,
            isPaused: false,
            timeRemainingWhenPaused: 0
        )
        let staleDate = Date().addingTimeInterval(30)
        let newContent = ActivityContent(state: newState, staleDate: staleDate)
        
        Task {
            await activity.update(newContent)
        }
    }
    
    func pause(timeRemaining: TimeInterval) {
        guard let activity = activity else { return }
        
        let newState = RunningActivityAttributes.ContentState(
            endTime: activity.content.state.endTime,
            progress: activity.content.state.progress,
            isComplete: false,
            isPaused: true,
            timeRemainingWhenPaused: timeRemaining
        )
        // When paused, we don't want it to go stale
        let newContent = ActivityContent(state: newState, staleDate: nil)
        
        Task { await activity.update(newContent) }
    }
    
    func resume(timeRemaining: TimeInterval) {
        guard let activity = activity else { return }
        
        let newEndTime = Date().addingTimeInterval(timeRemaining)
        let newState = RunningActivityAttributes.ContentState(
            endTime: newEndTime,
            progress: activity.content.state.progress,
            isComplete: false,
            isPaused: false,
            timeRemainingWhenPaused: 0
        )
        let newContent = ActivityContent(state: newState, staleDate: nil)
        
        Task { await activity.update(newContent) }
    }
    
    func end() {
        guard let activity = activity else { return }
        
        let finalState = RunningActivityAttributes.ContentState(
            endTime: activity.content.state.endTime,
            progress: 1.0,
            isComplete: true,
            isPaused: false,
            timeRemainingWhenPaused: 0
        )
        let finalContent = ActivityContent(state: finalState, staleDate: nil)
        
        Task {
            await activity.end(finalContent, dismissalPolicy: .immediate)
            self.activity = nil
            print("Live Activity ended.")
        }
    }
}
