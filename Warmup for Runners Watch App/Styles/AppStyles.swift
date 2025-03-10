//
//  AppStyles.swift
//  Warmup for Runners Watch App
//
//  Created by Neil Sanghrajka on 04/03/25.
//

import SwiftUI

// MARK: - Color Schemes
struct AppColors {
    // Main theme colors
    static let primaryBackground = Color.black
    static let secondaryBackground = Color.black.opacity(0.8)
    
    // Workout intensity colors
    static let quickWorkout = Color.green
    static let basicWorkout = Color.blue
    static let advancedWorkout = Color.orange
    
    // UI element colors
    static let timerBackground = Color.blue.opacity(0.2)
    static let progressBackground = Color.green.opacity(0.2)
    static let textPrimary = Color.white
    static let textSecondary = Color.gray
    
    // Get color for workout type
    static func colorForWorkoutType(id: String) -> Color {
        if id.contains("quick") {
            return quickWorkout
        } else if id.contains("advanced") {
            return advancedWorkout
        } else {
            return basicWorkout
        }
    }
}

// MARK: - Text Styles
struct AppTextStyle {
    // Heading styles
    static func heading(_ content: Text) -> some View {
        content
            .font(.headline)
            .foregroundColor(AppColors.textPrimary)
    }
    
    // Subheading styles
    static func subheading(_ content: Text) -> some View {
        content
            .font(.subheadline)
            .foregroundColor(AppColors.textPrimary)
    }
    
    // Body text
    static func body(_ content: Text) -> some View {
        content
            .font(.body)
            .foregroundColor(AppColors.textPrimary)
    }
    
    // Caption text
    static func caption(_ content: Text) -> some View {
        content
            .font(.caption)
            .foregroundColor(AppColors.textSecondary)
    }
    
    // Timer text
    static func timer(_ content: Text) -> some View {
        content
            .font(.system(.title3, design: .monospaced))
            .foregroundColor(AppColors.textPrimary)
            .fontWeight(.semibold)
    }
}

// MARK: - Button Styles
struct CircularButtonStyle: ButtonStyle {
    var color: Color
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .background(AppColors.secondaryBackground)
            .clipShape(Circle())
            .overlay(
                Circle()
                    .stroke(color, lineWidth: 2)
                    .opacity(configuration.isPressed ? 0.5 : 1.0)
            )
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
    }
}

// MARK: - View Modifiers
struct StatusDisplayModifier: ViewModifier {
    var backgroundColor: Color
    
    func body(content: Content) -> some View {
        content
            .padding(.horizontal, 6)
            .padding(.vertical, 3)
            .background(backgroundColor.opacity(0.2))
            .cornerRadius(8)
    }
}

extension View {
    func statusDisplay(backgroundColor: Color) -> some View {
        self.modifier(StatusDisplayModifier(backgroundColor: backgroundColor))
    }
}