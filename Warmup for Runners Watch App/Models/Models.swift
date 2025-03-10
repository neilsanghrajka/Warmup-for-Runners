//
//  Models.swift
//  Warmup for Runners Watch App
//
//  Created by Neil Sanghrajka on 04/03/25.
//

import Foundation
import SwiftUI

// MARK: - Workout Models
struct WarmupRoutine: Identifiable, Codable {
    var id: String
    var name: String
    var description: String
    var exercises: [Exercise]
    var restDurationSeconds: Int
    var autoStartRunAfterCompletion: Bool
}

struct Exercise: Identifiable, Codable {
    var id: String
    var name: String
    var description: String
    var durationSeconds: Int
    var animationName: String
    var audioInstructions: String
    var halfwayAudioCue: String?
    
    // For app defaults when config can't be loaded
    static func defaultExercise() -> Exercise {
        Exercise(
            id: "default_exercise",
            name: "Jumping Jacks",
            description: "Stand with feet together, arms at sides, then jump while spreading legs and raising arms",
            durationSeconds: 30,
            animationName: "jumping_jacks",
            audioInstructions: "Do jumping jacks for 30 seconds",
            halfwayAudioCue: "Halfway there, keep going!"
        )
    }
}

// MARK: - App Settings
struct AppSettings: Codable {
    var audioEnabled: Bool = true
    var hapticsEnabled: Bool = true
    var defaultRoutineId: String?
    var remoteConfigEnabled: Bool = false
    var remoteConfigURL: String?
}

// MARK: - Workout State
enum WorkoutState {
    case notStarted, preparing, exercising, resting, completed
}

// MARK: - Helper Types
struct IdentifiableString: Identifiable, Hashable {
    let string: String
    var id: String { string }
    
    init(_ string: String) {
        self.string = string
    }
} 