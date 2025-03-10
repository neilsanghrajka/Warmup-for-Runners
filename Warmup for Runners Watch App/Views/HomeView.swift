//
//  HomeView.swift
//  Warmup for Runners Watch App
//
//  Created by Neil Sanghrajka on 04/03/25.
//

import SwiftUI
import Foundation


struct HomeView: View {
    @ObservedObject var configService: ConfigService
    @ObservedObject var workoutManager: WorkoutManager
    @State private var selectedRoutineId: IdentifiableString? = nil
    
    var body: some View {
        TabView {
            // Main workout dial screen wrapped in NavigationStack
            NavigationStack {
                mainDialView
                    .navigationDestination(item: $selectedRoutineId) { identifiableString in
                        if let routine = configService.getWarmupRoutine(id: identifiableString.string) {
                            WorkoutPreviewView(
                                configService: configService,
                                workoutManager: workoutManager,
                                routine: routine,
                                isPresented: Binding(
                                    get: { selectedRoutineId != nil },
                                    set: { if !$0 { selectedRoutineId = nil } }
                                )
                            )
                            .navigationBarBackButtonHidden(true)
                            .toolbar(.hidden, for: .navigationBar)
                        }
                    }
                    .ignoresSafeArea()
            }
            .tabItem {
                Label("Workouts", systemImage: "figure.run")
            }
            
            // Settings screen as a tab instead of a button
            SettingsView(configService: configService)
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
        }
        .ignoresSafeArea(edges: .top)
    }
    
    // Main dial view
    private var mainDialView: some View {
        ZStack {
            // Background
            Color.black.ignoresSafeArea()
            
            // Main workout options in a dial layout
            GeometryReader { geometry in
                let spacing = geometry.size.width * 0.05
                
                ScrollView {
                    LazyVGrid(
                        columns: [
                            GridItem(.flexible(), spacing: spacing),
                            GridItem(.flexible(), spacing: spacing)
                        ],
                        spacing: spacing
                    ) {
                        // Generate workout option buttons from available routines
                        ForEach(configService.warmupRoutines) { routine in
                            WorkoutDialButton(routine: routine, action: {
                                selectedRoutineId = IdentifiableString(routine.id)
                            })
                            .frame(height: geometry.size.width * 0.45)
                        }
                    }
                    .padding(.horizontal, geometry.size.width * 0.02)
                }
            }
        }
        .edgesIgnoringSafeArea(.all)
    }
}

// Using IdentifiableString from Models.swift

// Circular dial-style button for workouts
struct WorkoutDialButton: View {
    let routine: WarmupRoutine
    let action: () -> Void
    
    // Compute total time
    private var totalTime: Int {
        let exerciseTime = routine.exercises.reduce(0) { $0 + $1.durationSeconds }
        let restTime = routine.restDurationSeconds * max(0, routine.exercises.count - 1)
        return exerciseTime + restTime
    }
    
    // Format time as minutes:seconds
    private var formattedTime: String {
        let minutes = totalTime / 60
        let seconds = totalTime % 60
        if minutes > 0 {
            return "\(minutes)m \(seconds)s"
        } else {
            return "\(seconds)s"
        }
    }
    
    // Get icon for workout type
    private var iconName: String {
        if routine.id.contains("quick") {
            return "figure.walk"
        } else if routine.id.contains("advanced") {
            return "figure.run.circle"
        } else if routine.id.contains("basic") {
            return "figure.run"
        } else {
            return "figure.mixed.cardio"
        }
    }
    
    // Color based on workout intensity
    private var buttonColor: Color {
        if routine.id.contains("quick") {
            return .green
        } else if routine.id.contains("advanced") {
            return .orange
        } else {
            return .blue
        }
    }
    
    var body: some View {
        GeometryReader { geometry in
            let size = min(geometry.size.width, geometry.size.height) * 0.85
            
            Button(action: action) {
                VStack(spacing: 5) {
                    // Icon
                    Image(systemName: iconName)
                        .font(.system(size: size * 0.25))
                        .foregroundColor(buttonColor)
                    
                    // Workout name
                    Text(routine.name.components(separatedBy: " ").first ?? "")
                        .font(.system(size: size * 0.15, weight: .medium))
                        .foregroundColor(.white)
                        .lineLimit(1)
                    
                    // Time
                    Text(formattedTime)
                        .font(.system(size: size * 0.12))
                        .foregroundColor(.gray)
                }
                .frame(width: size, height: size)
                .background(Color.black.opacity(0.8))
                .cornerRadius(size / 2)
                .overlay(
                    Circle()
                        .stroke(buttonColor, lineWidth: 2)
                )
            }
            .buttonStyle(PlainButtonStyle())
            .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
        }
    }
}

struct SettingsView: View {
    @ObservedObject var configService: ConfigService
    
    @State private var audioEnabled: Bool
    @State private var hapticsEnabled: Bool
    @State private var selectedRoutineId: String?
    
    init(configService: ConfigService) {
        self.configService = configService
        self._audioEnabled = State(initialValue: configService.settings.audioEnabled)
        self._hapticsEnabled = State(initialValue: configService.settings.hapticsEnabled)
        self._selectedRoutineId = State(initialValue: configService.settings.defaultRoutineId)
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 15) {
                // App title at the top
                HStack {
                    Image(systemName: "figure.run")
                        .foregroundColor(.blue)
                    Text("Warmup Settings")
                        .font(.headline)
                        .foregroundColor(.white)
                }
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.bottom, 5)
                
                Divider()
                    .background(Color.gray.opacity(0.3))
                
                Group {
                    Toggle("Audio Instructions", isOn: $audioEnabled)
                        .onChange(of: audioEnabled) { _, newValue in
                            configService.settings.audioEnabled = newValue
                        }
                    
                    Toggle("Haptic Feedback", isOn: $hapticsEnabled)
                        .onChange(of: hapticsEnabled) { _, newValue in
                            configService.settings.hapticsEnabled = newValue
                        }
                }
                .tint(.blue)
                
                Text("Default Warmup")
                    .font(.subheadline)
                    .foregroundColor(.white)
                    .padding(.top, 5)
                
                Picker("Select Routine", selection: $selectedRoutineId) {
                    ForEach(configService.warmupRoutines) { routine in
                        Text(routine.name)
                            .tag(routine.id as String?)
                    }
                }
                .pickerStyle(WheelPickerStyle())
                .frame(height: 100)
                .onChange(of: selectedRoutineId) { _, newValue in
                    configService.settings.defaultRoutineId = newValue
                }
                
                Text("Settings automatically saved")
                    .font(.caption2)
                    .foregroundColor(.gray)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.top, 5)
            }
            .padding()
        }
    }
}

#Preview {
    // Use the actual implemented services
    let config = ConfigService()
    let workout = WorkoutManager(configService: config)
    
    HomeView(configService: config, workoutManager: workout)
        .preferredColorScheme(.dark)
}