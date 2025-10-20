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
            
        case .moodDetail(let mood):
            MoodDetailView(mood: mood)
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(.preview)
}
