//
//  Mood.swift
//  MoodBoard
//
//  Created by Prompt-Driven Development on 2025-10-19
//  Feature 03: Architecture - SwiftData model with @Model
//

import SwiftUI
import SwiftData

/// SwiftData model representing a mood entry with persistence
///
/// **Key Concept: @Model (SwiftData)**
/// - Introduced in iOS 17 / WWDC 2023
/// - Declarative data modeling using Swift macros
/// - Automatic persistence without CoreData boilerplate
/// - Type-safe queries and relationships
///
/// **Comparison with other frameworks:**
/// - Room (Android): Similar to @Entity annotation
/// - Core Data: Replaces NSManagedObject with pure Swift structs
/// - Realm: Similar declarative model, but SwiftData is Apple's native solution
/// - TypeORM: Similar to entity decorators in TypeScript
///
/// **Why SwiftData over @Observable?**
/// - @Observable: In-memory state management (session scope)
/// - @Model: Persistent data (survives app restarts)
/// - Use @Observable for UI state, @Model for domain data
@Model
final class Mood {
    
    // MARK: - Properties
    
    /// The emoji representing the mood
    /// SwiftData automatically persists this property
    var emoji: String
    
    /// A text description of the mood
    var label: String
    
    /// When the mood was recorded
    /// SwiftData handles Date serialization automatically
    var timestamp: Date
    
    // MARK: - Initialization
    
    /// Create a new mood entry
    /// - Parameters:
    ///   - emoji: The emoji representing the mood (e.g., "😊")
    ///   - label: A text description (e.g., "Happy")
    ///   - timestamp: When the mood was recorded (defaults to now)
    init(emoji: String, label: String, timestamp: Date = Date()) {
        self.emoji = emoji
        self.label = label
        self.timestamp = timestamp
    }
}

// MARK: - Sample Data

extension Mood {
    /// Create sample moods for previews and testing
    /// Returns an array of Mood instances
    static var samples: [Mood] {
        [
            Mood(emoji: "😊", label: "Happy", timestamp: Date().addingTimeInterval(-3600)),
            Mood(emoji: "🎉", label: "Excited", timestamp: Date().addingTimeInterval(-7200)),
            Mood(emoji: "😴", label: "Tired", timestamp: Date().addingTimeInterval(-10800)),
            Mood(emoji: "🤔", label: "Thoughtful", timestamp: Date().addingTimeInterval(-14400))
        ]
    }
    
    /// Insert sample moods into a given ModelContext
    /// - Parameter context: The ModelContext to insert sample data into
    static func insertSamples(into context: ModelContext) {
        let sampleMoods = [
            Mood(emoji: "😊", label: "Happy", timestamp: Date().addingTimeInterval(-3600)),
            Mood(emoji: "🎉", label: "Excited", timestamp: Date().addingTimeInterval(-7200)),
            Mood(emoji: "😴", label: "Tired", timestamp: Date().addingTimeInterval(-10800)),
            Mood(emoji: "🤔", label: "Thoughtful", timestamp: Date().addingTimeInterval(-14400))
        ]
        
        for mood in sampleMoods {
            context.insert(mood)
        }
    }
}

