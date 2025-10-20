//
//  MoodBoardApp.swift
//  MoodBoard
//
//  Created by ssalah on 19/10/2025.
//  Updated for Feature 03: SwiftData + Typed Navigation
//

import SwiftUI
import SwiftData

/// Main app entry point with SwiftData ModelContainer configuration
///
/// **Key Concept: SwiftData ModelContainer**
/// - Central storage for all SwiftData models
/// - Manages the persistence layer (like NSPersistentContainer in Core Data)
/// - Injected into the view hierarchy via .modelContainer() modifier
///
/// **Comparison with other frameworks:**
/// - Room (Android): Similar to Room.databaseBuilder()
/// - Core Data: Replaces NSPersistentContainer
/// - Realm: Similar to Realm.Configuration
///
/// **Configuration Options:**
/// - `isStoredInMemoryOnly: false` → Data persists between app launches
/// - `isStoredInMemoryOnly: true` → Volatile storage for previews/tests
@main
struct MoodBoardApp: App {
    
    // MARK: - SwiftData Configuration
    
    /// Shared ModelContainer for the app
    /// Configured with the Mood model and persistent storage
    ///
    /// **Migration Strategy:**
    /// - Attempts to create container with existing data
    /// - If schema migration fails, deletes old data and creates fresh container
    /// - This ensures app doesn't crash when model changes during development
    var sharedModelContainer: ModelContainer = {
        // Define the schema with all models
        let schema = Schema([
            Item.self,  // Legacy model (from template)
            Mood.self,  // Feature 05: Mood model with isFavorite
        ])
        
        // Configure storage (persistent by default, in-memory for previews)
        let modelConfiguration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false
        )

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            // Migration failed - delete old data and create fresh container
            print("⚠️ ModelContainer creation failed, attempting to reset data: \(error)")
            
            // Delete old persistent store
            let url = modelConfiguration.url
            try? FileManager.default.removeItem(at: url)
            
            // Try again with fresh data
            do {
                return try ModelContainer(for: schema, configurations: [modelConfiguration])
            } catch {
                fatalError("Could not create ModelContainer even after reset: \(error)")
            }
        }
    }()

    // MARK: - Scene
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(sharedModelContainer)
    }
}

// MARK: - Preview Helper

extension ModelContainer {
    /// Create an in-memory ModelContainer for previews
    /// - Returns: A ModelContainer configured for volatile storage
    static var preview: ModelContainer {
        let schema = Schema([
            Item.self,
            Mood.self,
        ])
        
        let modelConfiguration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: true  // Volatile memory for previews
        )
        
        do {
            let container = try ModelContainer(for: schema, configurations: [modelConfiguration])
            
            // Add sample data for previews
            Mood.insertSamples(into: container.mainContext)
            
            return container
        } catch {
            fatalError("Could not create preview ModelContainer: \(error)")
        }
    }
}
