//
//  AddMoodIntent.swift
//  MoodBoard
//
//  Created by Prompt-Driven Development on 2025-10-23
//  Feature 07: App Intents - Add moods via Siri and Shortcuts
//

import AppIntents
import SwiftData
import Foundation

/// App Intent to add a new mood via Siri or Shortcuts
///
/// **Key Concept: App Intents (iOS 16+)**
/// - New framework replacing SiriKit Intents (deprecated)
/// - Pure Swift API (no more .intentdefinition XML files!)
/// - Type-safe parameters and results
/// - Seamless integration with Shortcuts, Siri, and Spotlight
///
/// **Comparison with other frameworks:**
/// - Android: Similar to App Actions / Google Assistant integration
/// - Web: Similar to Web Share API or PWA shortcuts
/// - Alexa Skills: Similar concept but for Amazon Alexa
///
/// **Why App Intents over SiriKit?**
/// - No .intentdefinition file needed (pure Swift!)
/// - Better type safety and compiler checks
/// - Easier testing and debugging
/// - Modern Swift concurrency support (async/await)
struct AddMoodIntent: AppIntent {
    
    // MARK: - Intent Metadata
    
    /// Human-readable title shown in Shortcuts app
    static var title: LocalizedStringResource = "Add Mood"
    
    /// Description explaining what this intent does
    static var description = IntentDescription("Add a new mood to your MoodBoard")
    
    /// Icon shown in Shortcuts app (SF Symbol)
    static var openAppWhenRun: Bool = false
    
    // MARK: - Parameters
    
    /// The title/label of the mood to add
    /// This parameter will be prompted in Siri if not provided
    @Parameter(title: "Mood Title", description: "The name of your mood (e.g., Happy, Tired)")
    var title: String
    
    /// Optional emoji to represent the mood
    /// If not provided, a default emoji will be selected
    @Parameter(title: "Emoji", description: "An emoji representing the mood (optional)", default: "😊")
    var emoji: String?
    
    // MARK: - Intent Execution
    
    /// Main execution logic of the intent
    /// Called when Siri or Shortcuts runs this intent
    /// - Returns: IntentResult with success/failure status
    @MainActor
    func perform() async throws -> some IntentResult & ProvidesDialog {
        
        // Validate input
        guard !title.trimmingCharacters(in: .whitespaces).isEmpty else {
            throw IntentError.invalidInput("Mood title cannot be empty")
        }
        
        // Get the emoji or use default
        let moodEmoji = emoji ?? selectDefaultEmoji(for: title)
        
        // Create ModelContainer for SwiftData persistence
        // Note: We need to create a separate container for background execution
        guard let modelContainer = try? ModelContainer(for: Mood.self) else {
            throw IntentError.databaseError("Failed to initialize database")
        }
        
        let context = ModelContext(modelContainer)
        
        // Create the new mood
        let newMood = Mood(
            emoji: moodEmoji,
            label: title,
            timestamp: Date(),
            isFavorite: false
        )
        
        // Insert into SwiftData
        context.insert(newMood)
        
        // Save changes
        do {
            try context.save()
            #if DEBUG
            print("✅ [AddMoodIntent] Mood saved: \(title) \(moodEmoji)")
            // TODO: Replace with proper logging framework in production
            #endif
        } catch {
            #if DEBUG
            print("❌ [AddMoodIntent] Failed to save: \(error)")
            #endif
            throw IntentError.databaseError("Failed to save mood: \(error.localizedDescription)")
        }
        
        // Return success dialog
        return .result(
            dialog: "Added '\(moodEmoji) \(title)' to your MoodBoard!"
        )
    }
    
    // MARK: - Helper Methods
    
    /// Select a default emoji based on mood keywords
    /// - Parameter title: The mood title
    /// - Returns: An appropriate emoji
    private func selectDefaultEmoji(for title: String) -> String {
        let lowercased = title.lowercased()
        
        // Simple keyword matching
        if lowercased.contains("happy") || lowercased.contains("joy") {
            return "😊"
        } else if lowercased.contains("sad") || lowercased.contains("down") {
            return "😢"
        } else if lowercased.contains("excited") || lowercased.contains("great") {
            return "🎉"
        } else if lowercased.contains("tired") || lowercased.contains("sleepy") {
            return "😴"
        } else if lowercased.contains("angry") || lowercased.contains("mad") {
            return "😡"
        } else if lowercased.contains("love") || lowercased.contains("heart") {
            return "❤️"
        } else if lowercased.contains("think") || lowercased.contains("wonder") {
            return "🤔"
        } else if lowercased.contains("cool") || lowercased.contains("chill") {
            return "😎"
        } else {
            return "😊" // Default fallback
        }
    }
}

// MARK: - App Shortcuts

/// Define app shortcuts that appear in Spotlight and Shortcuts app
/// These are pre-configured intents that users can run quickly
struct MoodBoardShortcuts: AppShortcutsProvider {
    
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: AddMoodIntent(),
            phrases: [
                "Add a mood in \(.applicationName)",
                "Log my mood in \(.applicationName)",
                "Record how I feel in \(.applicationName)"
            ],
            shortTitle: "Add Mood",
            systemImageName: "face.smiling"
        )
    }
}

// MARK: - Custom Errors

/// Custom errors for the AddMoodIntent
enum IntentError: Error, CustomLocalizedStringResourceConvertible {
    case invalidInput(String)
    case databaseError(String)
    
    var localizedStringResource: LocalizedStringResource {
        switch self {
        case .invalidInput(let message):
            return "Invalid Input: \(message)"
        case .databaseError(let message):
            return "Database Error: \(message)"
        }
    }
}

