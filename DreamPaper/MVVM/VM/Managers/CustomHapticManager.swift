//
//  CustomHapticManager.swift
//  StomachBook
//
//  Created by 赵翔宇 on 2024/5/24.
//



import CoreHaptics
import Foundation
//
//extension UIImpactFeedbackGenerator {
//
//    
//    public enum FeedbackStyle : Int, @unchecked Sendable {
//        case sosoft = 99
//    }
//}

class CustomHapticManager {
    private var engine: CHHapticEngine?

    init() {
        do {
            engine = try CHHapticEngine()
            try engine?.start()
        } catch {
            print("Error starting haptic engine: \(error)")
        }
    }

    func playCustomHaptic(intensity: Float, sharpness: Float, duration: TimeInterval) {
        guard let engine = engine else { return }

        // Create haptic event parameters
        let intensityParameter = CHHapticEventParameter(parameterID: .hapticIntensity, value: intensity)
        let sharpnessParameter = CHHapticEventParameter(parameterID: .hapticSharpness, value: sharpness)

        // Create haptic event
        let event = CHHapticEvent(eventType: .hapticTransient, parameters: [intensityParameter, sharpnessParameter], relativeTime: 0, duration: duration)

        // Create haptic pattern
        do {
            let pattern = try CHHapticPattern(events: [event], parameters: [])
            let player = try engine.makePlayer(with: pattern)
            try player.start(atTime: CHHapticTimeImmediate)
        } catch {
            print("Error playing custom haptic: \(error)")
        }
    }
}
