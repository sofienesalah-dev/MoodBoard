//
//  CRUDMoodRowView.swift
//  MoodBoard
//
//  Created by Prompt-Driven Development on 2025-10-19
//  Feature 04: List CRUD - Reusable row component for mood display
//

import SwiftUI

/// Reusable row view for displaying a single mood entry
///
/// **Key Concepts:**
/// - **Component Reusability**: Single responsibility (display only)
/// - **Accessibility**: Proper labels and hints for VoiceOver
/// - **Visual Hierarchy**: Clear information structure
///
/// **Design Principles:**
/// - Clean and minimal UI
/// - Clear visual feedback
/// - Consistent spacing and typography
/// - Support for light and dark modes
///
/// **Comparison with other frameworks:**
/// - Android: ViewHolder in RecyclerView
/// - React: Functional component for list items
/// - Flutter: ListTile widget
struct CRUDMoodRowView: View {
    
    // MARK: - Properties
    
    /// The mood to display
    let mood: Mood
    
    // MARK: - Body
    
    var body: some View {
        HStack(spacing: 16) {
            // Emoji indicator
            emojiView
            
            // Mood information
            moodInfoView
            
            Spacer()
            
            // Chevron indicator (tap to edit)
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundStyle(.tertiary)
                .accessibilityHidden(true)
        }
        .padding(.vertical, 8)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(mood.label) mood")
        .accessibilityValue("Emoji: \(mood.emoji), recorded \(mood.timestamp.formatted(.relative(presentation: .named)))")
        .accessibilityHint("Double tap to edit")
    }
    
    // MARK: - Subviews
    
    /// Emoji display with circular background
    private var emojiView: some View {
        ZStack {
            Circle()
                .fill(Color.accentColor.opacity(0.1))
                .frame(width: 56, height: 56)
            
            Text(mood.emoji)
                .font(.system(size: 32))
        }
        .accessibilityHidden(true) // Emoji is decorative, label provides context
    }
    
    /// Mood label and timestamp
    private var moodInfoView: some View {
        VStack(alignment: .leading, spacing: 4) {
            // Mood label
            Text(mood.label)
                .font(.headline)
                .foregroundStyle(.primary)
            
            // Timestamp (relative)
            Text(mood.timestamp, style: .relative)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }
}

// MARK: - Previews

#Preview("Mood Row") {
    List {
        CRUDMoodRowView(mood: Mood.samples[0])
        CRUDMoodRowView(mood: Mood.samples[1])
        CRUDMoodRowView(mood: Mood.samples[2])
    }
}

#Preview("Mood Row - Dark Mode") {
    List {
        CRUDMoodRowView(mood: Mood.samples[0])
        CRUDMoodRowView(mood: Mood.samples[1])
        CRUDMoodRowView(mood: Mood.samples[2])
    }
    .preferredColorScheme(.dark)
}

