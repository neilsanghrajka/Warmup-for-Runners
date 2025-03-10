//
//  WorkoutWidget.swift
//  WorkoutWidget
//
//  Created by Neil Sanghrajka on 04/03/25.
//

import WidgetKit
import SwiftUI

// MARK: - Provider

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> WorkoutEntry {
        WorkoutEntry(date: Date(), workoutState: .sample)
    }

    func getSnapshot(in context: Context, completion: @escaping (WorkoutEntry) -> ()) {
        let entry = WorkoutEntry(date: Date(), workoutState: .sample)
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        // Get current workout state from app group container
        let currentState = WorkoutState.loadFromAppGroup() ?? .notRunning
        
        // If workout is active, update more frequently
        let updateInterval: TimeInterval = currentState.isActive ? 15 : 60
        
        var entries: [WorkoutEntry] = []
        let currentDate = Date()
        
        // Create timeline entries
        for minuteOffset in 0..<5 {
            let entryDate = Calendar.current.date(byAdding: .second, value: Int(updateInterval) * minuteOffset, to: currentDate)!
            let entry = WorkoutEntry(date: entryDate, workoutState: currentState)
            entries.append(entry)
        }
        
        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
}

// MARK: - Entry

struct WorkoutEntry: TimelineEntry {
    let date: Date
    let workoutState: WorkoutState
}

// MARK: - WorkoutState

struct WorkoutState: Codable {
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
    
    var isActive: Bool {
        status == .exercising || status == .resting
    }
    
    static var sample: WorkoutState {
        WorkoutState(
            status: .exercising,
            currentExerciseName: "Jumping Jacks",
            timeRemaining: 15,
            totalProgress: 0.4
        )
    }
    
    static var notRunning: WorkoutState {
        WorkoutState(
            status: .notRunning,
            currentExerciseName: nil,
            timeRemaining: nil,
            totalProgress: 0.0
        )
    }
    
    // Load from app group container
    static func loadFromAppGroup() -> WorkoutState? {
        guard let containerURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.com.neilsanghrajka.warmupforrunners") else {
            return nil
        }
        
        let fileURL = containerURL.appendingPathComponent("workout_state.json")
        
        do {
            let data = try Data(contentsOf: fileURL)
            let decoder = JSONDecoder()
            return try decoder.decode(WorkoutState.self, from: data)
        } catch {
            print("Error loading workout state: \(error)")
            return nil
        }
    }
}

// MARK: - Widget Views

struct WorkoutWidgetEntryView : View {
    var entry: Provider.Entry
    @Environment(\.widgetFamily) var family
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.9)
            
            VStack(spacing: 8) {
                // Header
                HStack {
                    Image(systemName: "figure.run")
                        .foregroundColor(.blue)
                    Text("Runner's Warmup")
                        .font(.system(.headline, design: .rounded))
                        .foregroundColor(.white)
                }
                
                // Content based on state
                if entry.workoutState.status == .notRunning {
                    notRunningView
                } else if entry.workoutState.status == .completed {
                    completedView
                } else {
                    activeWorkoutView
                }
            }
            .padding()
        }
    }
    
    // Not running state
    private var notRunningView: some View {
        VStack(spacing: 5) {
            Text("No active workout")
                .font(.caption)
                .foregroundColor(.gray)
            
            Button(action: {}) {
                Text("Start Workout")
                    .font(.caption2)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 5)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            .widgetURL(URL(string: "warmupapp://start"))
        }
    }
    
    // Completed state
    private var completedView: some View {
        VStack(spacing: 5) {
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(.green)
                .font(.title2)
            
            Text("Workout Completed")
                .font(.caption)
                .foregroundColor(.white)
                
            Text("Great job!")
                .font(.caption2)
                .foregroundColor(.gray)
        }
    }
    
    // Active workout state
    private var activeWorkoutView: some View {
        VStack(spacing: 4) {
            // Exercise info
            if let exerciseName = entry.workoutState.currentExerciseName {
                Text(exerciseName)
                    .font(.system(.caption, design: .rounded))
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
            }
            
            // Timer if available
            if let timeRemaining = entry.workoutState.timeRemaining {
                HStack(spacing: 2) {
                    Image(systemName: "timer")
                        .font(.caption2)
                        .foregroundColor(.orange)
                    
                    let minutes = timeRemaining / 60
                    let seconds = timeRemaining % 60
                    Text(String(format: "%d:%02d", minutes, seconds))
                        .font(.system(.caption, design: .monospaced))
                        .foregroundColor(.white)
                }
            }
            
            // Progress indicator
            ProgressView(value: entry.workoutState.totalProgress)
                .progressViewStyle(LinearProgressViewStyle(tint: .blue))
                .frame(height: 4)
                .padding(.top, 2)
                
            Text(entry.workoutState.status == .exercising ? "Exercising" : "Resting")
                .font(.caption2)
                .foregroundColor(.gray)
        }
    }
}

// MARK: - Widget Configuration

struct WorkoutWidget: Widget {
    let kind: String = "WorkoutWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            WorkoutWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Workout Status")
        .description("Track your ongoing warmup routine.")
        .supportedFamilies([.accessoryCircular, .accessoryRectangular])
    }
}

// MARK: - Preview

#Preview(as: .accessoryRectangular) {
    WorkoutWidget()
} timeline: {
    WorkoutEntry(date: Date(), workoutState: .sample)
    WorkoutEntry(date: Date(), workoutState: .notRunning)
}

#Preview(as: .accessoryCircular) {
    WorkoutWidget()
} timeline: {
    WorkoutEntry(date: Date(), workoutState: .sample)
}