//
//  MoodStore.swift
//  MoodBoard
//
//  Created by Prompt-Driven Development on 2025-10-19
//  Feature 02: Observation - Modern state management with @Observable
//

import SwiftUI

/// Model representing a mood entry
///
/// Simple struct to represent a user's mood at a given moment.
/// Conforms to Identifiable for use in SwiftUI ForEach loops.
struct Mood: Identifiable {
    let id = UUID()
    var emoji: String
    var label: String
    var timestamp: Date = Date()
}

/// Store managing the list of moods using @Observable (iOS 17+)
///
/// **Key Concept: @Observable**
/// - Introduced in iOS 17 / Swift 5.9
/// - Replaces the old @ObservableObject + @Published pattern
/// - Automatic observation of ALL properties (no need for @Published)
/// - Better performance (fine-grained observation)
///
/// **Comparison with other frameworks:**
/// - React: Similar to Context API + useState
/// - Jetpack Compose: Similar to ViewModel with mutableStateListOf
/// - Vue.js: Similar to reactive() for objects
@Observable
class MoodStore {
    
    // MARK: - Properties
    
    /// List of moods
    /// No need for @Published - @Observable tracks all properties automatically!
    var moods: [Mood] = []
    
    // MARK: - Actions
    
    /// Add a new mood to the list
    /// - Parameters:
    ///   - emoji: The emoji representing the mood
    ///   - label: A text description of the mood
    func addMood(emoji: String, label: String) {
        let newMood = Mood(emoji: emoji, label: label)
        moods.append(newMood)
    }
    
    /// Remove a mood by its ID
    /// - Parameter id: The UUID of the mood to remove
    func removeMood(id: UUID) {
        moods.removeAll { $0.id == id }
    }
    
    /// Clear all moods
    func clearAll() {
        moods.removeAll()
    }
    
    // MARK: - Sample Data
    
    /// Create a store with sample moods for testing
    static var sample: MoodStore {
        let store = MoodStore()
        store.moods = [
            Mood(emoji: "😊", label: "Happy"),
            Mood(emoji: "🎉", label: "Excited"),
            Mood(emoji: "😴", label: "Tired")
        ]
        return store
    }
}

