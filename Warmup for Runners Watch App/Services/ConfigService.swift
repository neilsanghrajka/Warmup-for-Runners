//
//  ConfigService.swift
//  Warmup for Runners Watch App
//
//  Created by Neil Sanghrajka on 04/03/25.
//

import Foundation
import Combine
import SwiftUI

// Ensure we're using the model definitions from Models.swift
@_exported import Foundation

class ConfigService: ObservableObject {
    @Published var warmupRoutines: [WarmupRoutine] = []
    @Published var settings: AppSettings = AppSettings()
    @Published var isLoading: Bool = false
    @Published var loadingError: String? = nil
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        loadLocalConfig()
    }
    
    // MARK: - Config Loading
    
    func loadLocalConfig() {
        isLoading = true
        loadingError = nil
        
        // Add built-in default warmup routines
        let basicRoutine = createDefaultWarmupRoutine()
        let quickRoutine = createQuickWarmupRoutine()
        let advancedRoutine = createAdvancedWarmupRoutine()
        warmupRoutines = [quickRoutine, basicRoutine, advancedRoutine]
        
        isLoading = false
    }
    
    func loadRemoteConfig() {
        // Placeholder for remote config loading
    }
    
    // MARK: - Helper Methods
    
    func getWarmupRoutine(id: String) -> WarmupRoutine? {
        return warmupRoutines.first(where: { $0.id == id })
    }
    
    func getDefaultRoutine() -> WarmupRoutine? {
        if let defaultId = settings.defaultRoutineId,
           let routine = getWarmupRoutine(id: defaultId) {
            return routine
        }
        return warmupRoutines.first
    }
    
    // MARK: - Default Routines
    
    // Made public for preview usage
    func createDefaultWarmupRoutine() -> WarmupRoutine {
        return WarmupRoutine(
            id: "basic_warmup",
            name: "Basic Warmup",
            description: "A standard warmup routine for runners",
            exercises: [
                Exercise.defaultExercise()
            ],
            restDurationSeconds: 15,
            autoStartRunAfterCompletion: false
        )
    }
    
    // Made public for preview usage
    func createQuickWarmupRoutine() -> WarmupRoutine {
        return WarmupRoutine(
            id: "quick_warmup",
            name: "Quick Warmup",
            description: "A quick warmup for when you're short on time",
            exercises: [
                Exercise.defaultExercise()
            ],
            restDurationSeconds: 10,
            autoStartRunAfterCompletion: true
        )
    }
    
    // Made public for preview usage
    func createAdvancedWarmupRoutine() -> WarmupRoutine {
        return WarmupRoutine(
            id: "advanced_warmup",
            name: "Advanced Warmup",
            description: "A comprehensive warmup for serious runners",
            exercises: [
                Exercise.defaultExercise(),
                Exercise.defaultExercise()
            ],
            restDurationSeconds: 20,
            autoStartRunAfterCompletion: false
        )
    }
}