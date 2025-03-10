//
//  Styles.swift
//  Warmup for Runners Watch App
//
//  Created by Neil Sanghrajka on 04/03/25.
//

import SwiftUI

// This is a compatibility file that forwards to AppStyles.swift
// We're keeping this file to maintain any existing imports in the project
// but moving the actual style definitions to AppStyles.swift

// MARK: - Type Aliases

typealias AppColorsImpl = SwiftUI.Color
typealias AppTextStyleImpl = SwiftUI.Font
typealias CircularButtonStyleImpl = SwiftUI.PrimitiveButtonStyle
typealias StatusDisplayModifierImpl = SwiftUI.ViewModifier

// MARK: - Helper Methods

extension View {
    func statusDisplayCompat(backgroundColor: Color) -> some View {
        self.padding(.horizontal, 6)
            .padding(.vertical, 3)
            .background(backgroundColor.opacity(0.2))
            .cornerRadius(8)
    }
}