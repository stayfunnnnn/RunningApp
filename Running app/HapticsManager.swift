//
//  HapticsManager.swift
//  Running app
//
//  Created by Stefan Hemady on 5/8/2025.
//


import CoreHaptics
import UIKit

class HapticsManager {
    static let shared = HapticsManager()
    
    private var engine: CHHapticEngine?
    
    private init() {
        guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else { return }
        do {
            engine = try CHHapticEngine()
            try engine?.start()
        } catch {
            print("Haptic engine creation error: \(error.localizedDescription)")
        }
    }
    
    // 1. Quick half-second vibrate for warm-up
    func playWarmupHaptic() {
        let pattern = singleVibration(duration: 0.5, intensity: 0.8)
        playSound(pattern: pattern)
    }
    
    // 2. Two quick consecutive vibrates for high intensity
    func playHighIntensityHaptic() {
        let pattern = doubleVibration(duration: 0.2, intensity: 1.0, delay: 0.1)
        playSound(pattern: pattern)
    }
    
    // 3. One long (1 second) vibrate for low intensity
    func playLowIntensityHaptic() {
        let pattern = singleVibration(duration: 1.0, intensity: 0.6)
        playSound(pattern: pattern)
    }
    
    // 4. Two long (1 second) vibrates for completion
    func playCompletionHaptic() {
        let pattern = doubleVibration(duration: 1.0, intensity: 1.0, delay: 0.3)
        playSound(pattern: pattern)
    }
    
    // MARK: - Private Helper Methods
    private func singleVibration(duration: TimeInterval, intensity: Float) -> CHHapticPattern? {
        let event = CHHapticEvent(eventType: .hapticContinuous, parameters: [
            CHHapticEventParameter(parameterID: .hapticIntensity, value: intensity),
            CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.5)
        ], relativeTime: 0, duration: duration)
        
        return try? CHHapticPattern(events: [event], parameters: [])
    }
    
    private func doubleVibration(duration: TimeInterval, intensity: Float, delay: TimeInterval) -> CHHapticPattern? {
        let event1 = CHHapticEvent(eventType: .hapticContinuous, parameters: [
            CHHapticEventParameter(parameterID: .hapticIntensity, value: intensity),
            CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.5)
        ], relativeTime: 0, duration: duration)
        
        let event2 = CHHapticEvent(eventType: .hapticContinuous, parameters: [
            CHHapticEventParameter(parameterID: .hapticIntensity, value: intensity),
            CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.5)
        ], relativeTime: duration + delay, duration: duration)
        
        return try? CHHapticPattern(events: [event1, event2], parameters: [])
    }
    
    private func playSound(pattern: CHHapticPattern?) {
        guard let engine = engine, let pattern = pattern else { return }
        do {
            try engine.start()
            let player = try engine.makePlayer(with: pattern)
            try player.start(atTime: 0)
        } catch {
            print("Failed to play haptic pattern: \(error.localizedDescription)")
        }
    }
}