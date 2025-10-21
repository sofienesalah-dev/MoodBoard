//
//  FavoriteButton.swift
//  MoodBoard
//
//  Created by Prompt-Driven Development on 2025-10-20
//  Feature 05: Detail + Favorite - Reusable favorite toggle component
//

import SwiftUI

/// Reusable button component for toggling favorite status
///
/// **Key Concepts:**
/// - **Reusable Component**: Can be used anywhere in the app
/// - **Bindable State**: Uses @Binding for two-way data flow
/// - **Animated Transitions**: Smooth scale and rotation effects
/// - **Accessibility**: Proper labels and hints
///
/// **Comparison with other frameworks:**
/// - React: Similar to a controlled component with useState
/// - Android: Custom View with state management
/// - Flutter: StatefulWidget with animation
struct FavoriteButton: View {
    
    // MARK: - Properties
    
    /// Binding to the favorite state
    /// Two-way binding allows parent to read and modify state
    @Binding var isFavorite: Bool
    
    /// Optional callback when favorite status changes
    /// Useful for triggering side effects (e.g., analytics, haptics)
    var onToggle: (() -> Void)?
    
    // MARK: - Body
    
    var body: some View {
        Button {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                isFavorite.toggle()
            }
            
            // Optional haptic feedback
            #if os(iOS)
            let impact = UIImpactFeedbackGenerator(style: .light)
            impact.impactOccurred()
            #endif
            
            // Call optional callback
            onToggle?()
        } label: {
            Image(systemName: isFavorite ? "heart.fill" : "heart")
                .font(.title2)
                .foregroundStyle(isFavorite ? .red : .gray)
                .scaleEffect(isFavorite ? 1.1 : 1.0)
                .rotationEffect(.degrees(isFavorite ? 360 : 0))
                .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isFavorite)
        }
        .accessibilityLabel(isFavorite ? "Remove from favorites" : "Add to favorites")
        .accessibilityHint("Double tap to toggle favorite status")
        .accessibilityAddTraits(isFavorite ? [.isSelected] : [])
    }
}

// MARK: - Previews

#Preview("Not Favorite") {
    @Previewable @State var isFavorite = false
    
    FavoriteButton(isFavorite: $isFavorite)
        .padding()
}

#Preview("Favorite") {
    @Previewable @State var isFavorite = true
    
    FavoriteButton(isFavorite: $isFavorite)
        .padding()
}

#Preview("Interactive") {
    @Previewable @State var isFavorite = false
    
    VStack(spacing: 20) {
        Text("Tap the heart!")
            .font(.headline)
        
        FavoriteButton(isFavorite: $isFavorite) {
            print("Favorite toggled: \(isFavorite)")
        }
        
        Text("Status: \(isFavorite ? "❤️ Favorite" : "🤍 Not favorite")")
            .font(.caption)
            .foregroundStyle(.secondary)
    }
    .padding()
}

