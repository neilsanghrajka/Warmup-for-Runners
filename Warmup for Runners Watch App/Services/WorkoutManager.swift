//
//  WorkoutManager.swift
//  Warmup for Runners Watch App
//
//  Created by Neil Sanghrajka on 04/03/25.
//

import Foundation
import SwiftUI
import Combine
import AVFoundation
import WatchKit
import WidgetKit

// Using WorkoutState from Models.swift

class WorkoutManager: ObservableObject {
    // Config and Settings
    private let configService: ConfigService
    
    // Workout State
    @Published var currentState: WorkoutState = .notStarted {
        didSet {
            saveWorkoutStateForWidget()
        }
    }
    @Published var currentRoutine: WarmupRoutine?
    @Published var currentExerciseIndex: Int = 0 {
        didSet {
            saveWorkoutStateForWidget()
        }
    }
    @Published var timeRemaining: Int = 0 {
        didSet {
            saveWorkoutStateForWidget()
        }
    }
    @Published var totalProgressPercentage: Double = 0.0 {
        didSet {
            saveWorkoutStateForWidget()
        }
    }
    @Published var exerciseProgressPercentage: Double = 0.0
    
    // Total elapsed time tracking
    @Published var workoutStartTime: Date?
    @Published var totalElapsedTime: TimeInterval = 0
    private var elapsedTimeTimer: Timer?
    
    // Removed heart rate monitoring
    
    // Audio and Haptic feedback
    private var audioPlayer: AVAudioPlayer?
    private var speechSynthesizer = AVSpeechSynthesizer()
    
    // Timers
    private var workoutTimer: Timer?
    private var restTimer: Timer?
    
    // Combine
    private var cancellables = Set<AnyCancellable>()
    
    init(configService: ConfigService) {
        self.configService = configService
    }
    
    // MARK: - Workout Control
    
    func startWorkout(routineId: String? = nil) {
        guard currentState == .notStarted else { return }
        
        // Load the specified routine or default
        if let routineId = routineId, let routine = configService.getWarmupRoutine(id: routineId) {
            currentRoutine = routine
        } else {
            currentRoutine = configService.getDefaultRoutine()
        }
        
        // Prepare for workout
        currentState = .preparing
        currentExerciseIndex = 0
        
        // Initialize timers and tracking
        workoutStartTime = Date()
        totalElapsedTime = 0
        startElapsedTimeTracking()
        
        // Heart rate monitoring removed
        
        // Start first exercise with a brief delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.startCurrentExercise()
        }
    }
    
    // Start tracking total elapsed time
    private func startElapsedTimeTracking() {
        elapsedTimeTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self, let startTime = self.workoutStartTime else { return }
            self.totalElapsedTime = Date().timeIntervalSince(startTime)
        }
    }
    
    // Heart rate monitoring functionality removed
    
    // Skip to the next exercise
    func skipToNextExercise() {
        // Only allow skipping during an exercise
        guard currentState == .exercising else { return }
        
        // Stop current timer
        workoutTimer?.invalidate()
        
        // Provide haptic feedback
        WKInterfaceDevice.current().play(.click)
        
        // Complete current exercise (this will move to the next one)
        completeCurrentExercise()
    }
    
    func startCurrentExercise() {
        guard let routine = currentRoutine,
              currentExerciseIndex < routine.exercises.count else {
            completeWorkout()
            return
        }
        
        let exercise = routine.exercises[currentExerciseIndex]
        timeRemaining = exercise.durationSeconds
        currentState = .exercising
        
        // Play start audio
        speakInstruction(exercise.audioInstructions)
        
        // Trigger start haptic
        WKInterfaceDevice.current().play(.start)
        
        // Start timer
        workoutTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            
            self.timeRemaining -= 1
            self.updateExerciseProgress()
            
            // Halfway haptic and audio cue
            if self.timeRemaining == exercise.durationSeconds / 2, 
               let halfwayCue = exercise.halfwayAudioCue {
                WKInterfaceDevice.current().play(.notification)
                self.speakInstruction(halfwayCue)
            }
            
            // Countdown beeps for last 5 seconds
            self.playCountdownBeeps(secondsLeft: self.timeRemaining)
            
            // Time's up
            if self.timeRemaining <= 0 {
                self.workoutTimer?.invalidate()
                WKInterfaceDevice.current().play(.success)
                self.completeCurrentExercise()
            }
        }
    }
    
    func completeCurrentExercise() {
        guard let routine = currentRoutine else { return }
        
        // Play completion haptic
        WKInterfaceDevice.current().play(.success)
        
        // Move to next exercise or complete
        currentExerciseIndex += 1
        
        // Update total progress
        updateTotalProgress()
        
        if currentExerciseIndex < routine.exercises.count {
            // Start rest period before next exercise
            startRestPeriod()
        } else {
            // Workout complete
            completeWorkout()
        }
    }
    
    func startRestPeriod() {
        guard let routine = currentRoutine,
              currentExerciseIndex < routine.exercises.count else {
            completeWorkout()
            return
        }
        
        currentState = .resting
        timeRemaining = routine.restDurationSeconds
        
        // Announce next exercise
        let nextExercise = routine.exercises[currentExerciseIndex]
        speakInstruction("Next: \(nextExercise.name)")
        
        // Start rest timer
        restTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            
            self.timeRemaining -= 1
            self.exerciseProgressPercentage = 1.0 - Double(self.timeRemaining) / Double(routine.restDurationSeconds)
            
            // Countdown beeps for last 3 seconds
            if self.timeRemaining <= 3 && self.timeRemaining > 0 {
                WKInterfaceDevice.current().play(.click)
            }
            
            // Time's up
            if self.timeRemaining <= 0 {
                self.restTimer?.invalidate()
                // Play a distinct sound to signal rest period is over
                WKInterfaceDevice.current().play(.start)
                self.startCurrentExercise()
            }
        }
    }
    
    func completeWorkout() {
        // Stop any running timers
        workoutTimer?.invalidate()
        restTimer?.invalidate()
        elapsedTimeTimer?.invalidate()
        
        // Heart rate monitoring removed
        
        // Update state
        currentState = .completed
        totalProgressPercentage = 1.0
        
        // Play completion feedback
        speakInstruction("Warmup completed! Great job!")
        WKInterfaceDevice.current().play(.success)
        
        // Log to HealthKit would be done here
        
        // Auto-start run if enabled
        if let routine = currentRoutine, routine.autoStartRunAfterCompletion {
            // Start run session logic would go here
            speakInstruction("Starting run tracking")
        }
    }
    
    func cancelWorkout() {
        // Stop all timers
        workoutTimer?.invalidate()
        restTimer?.invalidate()
        elapsedTimeTimer?.invalidate()
        
        // Heart rate monitoring removed
        
        // Reset state
        currentState = .notStarted
        currentExerciseIndex = 0
        timeRemaining = 0
        totalProgressPercentage = 0.0
        exerciseProgressPercentage = 0.0
        totalElapsedTime = 0
    }
    
    // Heart rate monitoring functionality removed
    
    // MARK: - Helper Methods
    
    private func updateExerciseProgress() {
        guard let exercise = currentExercise else { return }
        exerciseProgressPercentage = 1.0 - Double(timeRemaining) / Double(exercise.durationSeconds)
    }
    
    private func updateTotalProgress() {
        guard let routine = currentRoutine, !routine.exercises.isEmpty else { return }
        
        // Calculate progress based on completed exercises and current progress
        let totalExercises = routine.exercises.count
        let completedExercises = currentExerciseIndex
        
        totalProgressPercentage = Double(completedExercises) / Double(totalExercises)
    }
    
    private func speakInstruction(_ instruction: String) {
        guard configService.settings.audioEnabled else { return }
        
        let utterance = AVSpeechUtterance(string: instruction)
        utterance.rate = 0.5
        utterance.pitchMultiplier = 1.0
        utterance.volume = 1.0
        
        speechSynthesizer.speak(utterance)
    }
    
    // Play countdown beeps
    private func playCountdownBeeps(secondsLeft: Int) {
        guard configService.settings.audioEnabled, 
              secondsLeft <= 5 && secondsLeft > 0 else { return }
        
        // Play beep sound using system sound
        switch secondsLeft {
        case 3, 2, 1:
            WKInterfaceDevice.current().play(.click)
        case 5:
            speakInstruction("\(secondsLeft) seconds left")
        default:
            break
        }
    }
    
    // MARK: - Computed Properties
    
    var currentExercise: Exercise? {
        guard let routine = currentRoutine,
              currentExerciseIndex < routine.exercises.count else {
            return nil
        }
        return routine.exercises[currentExerciseIndex]
    }
    
    var nextExercise: Exercise? {
        guard let routine = currentRoutine,
              currentExerciseIndex + 1 < routine.exercises.count else {
            return nil
        }
        return routine.exercises[currentExerciseIndex + 1]
    }
    
    var formattedTimeRemaining: String {
        let minutes = timeRemaining / 60
        let seconds = timeRemaining % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
    
    var formattedTotalElapsedTime: String {
        let minutes = Int(totalElapsedTime) / 60
        let seconds = Int(totalElapsedTime) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
    
    // Heart rate functionality removed
    
    // MARK: - Widget Support
    
    /// Save current state to app group container for widget to read
    private func saveWorkoutStateForWidget() {
        // Map our internal state to widget state
        let widgetStatus: WorkoutWidgetState.Status
        switch currentState {
        case .notStarted, .preparing:
            widgetStatus = .notRunning
        case .exercising:
            widgetStatus = .exercising
        case .resting:
            widgetStatus = .resting
        case .completed:
            widgetStatus = .completed
        }
        
        // Create widget state
        let widgetState = WorkoutWidgetState(
            status: widgetStatus,
            currentExerciseName: currentExercise?.name,
            timeRemaining: timeRemaining > 0 ? timeRemaining : nil,
            totalProgress: totalProgressPercentage
        )
        
        saveToAppGroup(widgetState)
        
        // Reload widgets
        WidgetCenter.shared.reloadAllTimelines()
    }
    
    /// Save widget state to app group container
    private func saveToAppGroup(_ state: WorkoutWidgetState) {
        guard let containerURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.com.neilsanghrajka.warmupforrunners") else {
            print("Failed to get app group container")
            return
        }
        
        let fileURL = containerURL.appendingPathComponent("workout_state.json")
        
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(state)
            try data.write(to: fileURL)
        } catch {
            print("Error saving workout state: \(error)")
        }
    }
    
    /// Widget state structure
    struct WorkoutWidgetState: Codable {
        enum Status: String, Codable {
            case notRunning
            case exercising
            case resting
            case completed
        }
        
        let status: Status
        let currentExerciseName: String?
        let timeRemaining: Int?
        let totalProgress: Double
    }
}