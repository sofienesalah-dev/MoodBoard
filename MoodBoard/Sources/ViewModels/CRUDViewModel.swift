//
//  CRUDViewModel.swift
//  MoodBoard
//
//  Created by Prompt-Driven Development on 2025-10-19
//  Feature 04: List CRUD - ViewModel managing complete CRUD operations
//

import SwiftUI
import SwiftData

/// ViewModel managing complete CRUD operations for moods
///
/// **Key Concept: Complete CRUD in MVVM**
/// - **C**reate: Add new moods with validation
/// - **R**ead: Query handled by @Query in View
/// - **U**pdate: Edit existing mood properties
/// - **D**elete: Remove moods individually or in batch
///
/// **Business Logic Separation:**
/// - All data operations live in ViewModel
/// - Views are purely presentational
/// - Makes testing easier (mock the ViewModel)
///
/// **Comparison with other frameworks:**
/// - Android: ViewModel + Repository pattern
/// - React: Custom hooks + Context API
/// - Vue.js: Composition API with reactive state
@Observable
final class CRUDViewModel {
    
    // MARK: - Properties
    
    /// Selected emoji for new/edited mood
    var selectedEmoji: String = "😊"
    
    /// Label text for new/edited mood
    var moodLabel: String = ""
    
    /// Currently edited mood (nil when adding new)
    var editingMood: Mood?
    
    /// Available emojis for selection
    let availableEmojis = ["😊", "😢", "😡", "😴", "🤔", "🎉", "😱", "🥰", "😎", "🤯", "😌", "🥳", "😭", "🤗"]
    
    /// Reference to SwiftData context for persistence operations
    private let modelContext: ModelContext
    
    // MARK: - Initialization
    
    /// Initialize ViewModel with SwiftData context
    /// - Parameter modelContext: The ModelContext for persistence operations
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    // MARK: - CRUD Actions
    
    // CREATE
    
    /// Add a new mood to persistent storage
    ///
    /// **Business Rule**: Label cannot be empty or whitespace-only
    /// **Side Effects**: Resets form after successful creation
    func addMood() {
        // Validation (consistent with isFormValid)
        guard isFormValid else { return }
        
        // Create model with trimmed label
        let trimmedLabel = moodLabel.trimmingCharacters(in: .whitespacesAndNewlines)
        let newMood = Mood(emoji: selectedEmoji, label: trimmedLabel)
        
        // Persist via SwiftData
        modelContext.insert(newMood)
        
        // Save explicitly
        saveContext()
        
        // Reset form (UI state management)
        resetForm()
    }
    
    // UPDATE
    
    /// Start editing an existing mood
    /// - Parameter mood: The mood to edit
    func startEditing(_ mood: Mood) {
        editingMood = mood
        selectedEmoji = mood.emoji
        moodLabel = mood.label
    }
    
    /// Save changes to the currently edited mood
    func saveEdit() {
        let trimmedLabel = moodLabel.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let mood = editingMood, !trimmedLabel.isEmpty else { return }
        
        // Update model properties with trimmed label
        mood.emoji = selectedEmoji
        mood.label = trimmedLabel
        mood.timestamp = Date() // Update timestamp to reflect edit
        
        // SwiftData tracks changes automatically
        saveContext()
        
        // Reset editing state
        resetForm()
    }
    
    /// Cancel editing and reset form
    func cancelEdit() {
        resetForm()
    }
    
    // DELETE
    
    /// Delete a specific mood
    /// - Parameter mood: The mood to delete
    func deleteMood(_ mood: Mood) {
        modelContext.delete(mood)
        saveContext()
    }
    
    /// Delete moods at specific indices
    /// - Parameters:
    ///   - offsets: IndexSet of moods to delete
    ///   - moods: Array of all moods (from @Query)
    func deleteMoods(at offsets: IndexSet, from moods: [Mood]) {
        let moodsToDelete = offsets.map { moods[$0] }
        deleteMoods(moodsToDelete)
    }
    
    /// Clear all moods from storage
    /// - Parameter moods: Array of all moods (from @Query)
    func clearAllMoods(_ moods: [Mood]) {
        deleteMoods(moods)
    }
    
    /// Delete a sequence of moods (helper to avoid duplication)
    /// - Parameter moods: Moods to delete
    private func deleteMoods(_ moods: some Sequence<Mood>) {
        moods.forEach { modelContext.delete($0) }
        saveContext()
    }
    
    // MARK: - Helper Methods
    
    /// Select an emoji (updates UI state)
    /// - Parameter emoji: The emoji to select
    func selectEmoji(_ emoji: String) {
        selectedEmoji = emoji
    }
    
    /// Reset form to initial state
    private func resetForm() {
        selectedEmoji = "😊"
        moodLabel = ""
        editingMood = nil
    }
    
    /// Save ModelContext with error handling
    private func saveContext() {
        do {
            try modelContext.save()
        } catch {
            // TODO: Replace with proper logging framework in production (e.g., OSLog)
            #if DEBUG
            print("⚠️ [CRUDViewModel] Failed to save context: \(error.localizedDescription)")
            #endif
            // In production, consider: Logger.shared.error("Failed to save context", error: error)
        }
    }
    
    // MARK: - Computed Properties
    
    /// Check if the form is valid for submission
    /// Trims whitespace to ensure labels with only spaces are invalid
    var isFormValid: Bool {
        !moodLabel.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    /// Check if currently in editing mode
    var isEditing: Bool {
        editingMood != nil
    }
    
    /// Title for the submit button (context-aware)
    var submitButtonTitle: String {
        isEditing ? "Update" : "Add"
    }
}

