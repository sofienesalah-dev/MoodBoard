//
//  ContentView.swift
//  MoodBoard
//
//  Created by Prompt-Driven Development on 2025-10-19
//  Main entry point with centralized Router-based navigation
//

import SwiftUI
import SwiftData

/// Main content view with centralized navigation
///
/// **Navigation Architecture:**
/// - Single NavigationStack at root level
/// - Router shared via @State and injected to environment
/// - All navigation goes through Router.navigate(to:)
/// - Type-safe routes defined in Route enum
struct ContentView: View {
    
    // MARK: - Navigation
    
    /// Centralized router for the entire app
    @State private var router = Router()
    
    // MARK: - Body
    
    var body: some View {
        NavigationStack(path: $router.path) {
            // Root view
            FeaturesListView()
                // Register all typed navigation destinations
                .navigationDestination(for: Route.self) { route in
                    destinationView(for: route)
                }
        }
        .environment(router)
    }
    
    // MARK: - Environment
    
    @Environment(\.modelContext) private var modelContext
    
    // MARK: - Destination Resolver
    
    /// Resolve route to corresponding view
    /// - Parameter route: The navigation route
    /// - Returns: The destination view
    @ViewBuilder
    private func destinationView(for route: Route) -> some View {
        switch route {
        case .introState:
            IntroStateView()
            
        case .observation:
            MoodListView()
            
        case .architecture:
            ArchitectureView()
            
        case .crudList:
            CRUDListView()
            
        case .appIntents:
            AppIntentsView()
            
        case .moodDetail(let id):
            // Resolve Mood from persistent identifier
            if let mood = modelContext.model(for: id) as? Mood {
                MoodDetailView(mood: mood)
            } else {
                ContentUnavailableView(
                    "Mood Not Found",
                    systemImage: "exclamationmark.triangle",
                    description: Text("This mood may have been deleted.")
                )
                .accessibilityLabel("Mood not found. This mood may have been deleted.")
            }
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(.preview)
}
