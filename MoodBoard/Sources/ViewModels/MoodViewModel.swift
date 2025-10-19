//
//  MoodViewModel.swift
//  MoodBoard
//
//  Created by Prompt-Driven Development on 2025-10-19
//  Feature 03: Architecture - ViewModel for MVVM pattern
//

import SwiftUI
import SwiftData

/// ViewModel managing mood business logic and data operations
///
/// **Key Concept: ViewModel in MVVM**
/// - Separates business logic from UI (View)
/// - Handles data operations (CRUD)
/// - Communicates with Model layer (SwiftData)
/// - Makes Views dumb and testable
///
/// **Comparison with other frameworks:**
/// - Android: Similar to ViewModel with LiveData/Flow
/// - React: Similar to custom hooks with state management
/// - Vue.js: Similar to Composition API with reactive refs
///
/// **Why @Observable?**
/// - iOS 17+ modern observation framework
/// - Automatic UI updates when properties change
/// - Replaces @ObservableObject + @Published
@Observable
final class MoodViewModel {
    
    // MARK: - Properties
    
    /// Selected emoji for new mood
    var selectedEmoji: String = "😊"
    
    /// Label text for new mood
    var moodLabel: String = ""
    
    /// Available emojis for selection
    let availableEmojis = ["😊", "😢", "😡", "😴", "🤔", "🎉", "😱", "🥰", "😎", "🤯"]
    
    /// Reference to SwiftData context for persistence operations
    private let modelContext: ModelContext
    
    // MARK: - Initialization
    
    /// Initialize ViewModel with SwiftData context
    /// - Parameter modelContext: The ModelContext for persistence operations
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    // MARK: - Actions (Business Logic)
    
    /// Add a new mood to persistent storage
    ///
    /// **Business Rule**: Label cannot be empty
    /// **Side Effects**: Resets form after successful creation
    func addMood() {
        // Validation
        guard !moodLabel.isEmpty else { return }
        
        // Create model
        let newMood = Mood(emoji: selectedEmoji, label: moodLabel)
        
        // Persist via SwiftData
        modelContext.insert(newMood)
        
        // Reset form (UI state management)
        moodLabel = ""
        
        // Explicit save (SwiftData auto-saves, but we ensure it)
        do {
            try modelContext.save()
        } catch {
            print("⚠️ Failed to save new mood: \(error.localizedDescription)")
        }
    }
    
    /// Delete moods at specific indices
    /// - Parameters:
    ///   - offsets: IndexSet of moods to delete
    ///   - moods: Array of all moods (from @Query)
    func deleteMoods(at offsets: IndexSet, from moods: [Mood]) {
        for index in offsets {
            let mood = moods[index]
            modelContext.delete(mood)
        }
    }
    
    /// Clear all moods from storage
    /// - Parameter moods: Array of all moods (from @Query)
    func clearAllMoods(_ moods: [Mood]) {
        moods.forEach { mood in
            modelContext.delete(mood)
        }
    }
    
    /// Select an emoji (updates UI state)
    /// - Parameter emoji: The emoji to select
    func selectEmoji(_ emoji: String) {
        selectedEmoji = emoji
    }
    
    // MARK: - Computed Properties
    
    /// Check if the form is valid for submission
    var canAddMood: Bool {
        !moodLabel.isEmpty
    }
}

