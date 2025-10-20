//
//  Router.swift
//  MoodBoard
//
//  Created by Prompt-Driven Development on 2025-10-19
//  Feature 03: Architecture - Typed navigation with NavigationStack
//

import SwiftUI
import SwiftData

/// Typed navigation routes for the MoodBoard app
///
/// **Key Concept: Type-Safe Navigation**
/// - Introduced with NavigationStack in iOS 16+
/// - Replaces NavigationView's string-based navigation
/// - Compile-time safety (no runtime crashes from wrong paths)
/// - Programmatic navigation with full control
///
/// **Comparison with other frameworks:**
/// - React Router: Similar to route definitions with TypeScript types
/// - Jetpack Compose: Similar to NavHost with typed routes
/// - Flutter: Similar to named routes with type-safe arguments
/// - SwiftUI Legacy: Replaces NavigationView + NavigationLink with tag/selection
///
/// **Benefits:**
/// - Type safety: Wrong route = compile error
/// - Deep linking: Easy URL scheme integration
/// - State preservation: Navigation state can be saved/restored
/// - Testability: Routes can be tested independently
enum Route: Hashable {
    
    // MARK: - Feature Routes
    
    /// Feature 01: Introduction to @State
    case introState
    
    /// Feature 02: Observation with @Observable
    case observation
    
    /// Feature 03: Architecture demo
    case architecture
    
    /// Feature 04 & 05: CRUD List with detail navigation
    case crudList
    
    // MARK: - Detail Routes
    
    /// Detail view for a specific mood (by ID)
    /// PersistentIdentifier is Hashable (enabling navigation), but not Codable by default.
    /// If you need to serialize this (e.g., for state restoration or deep linking), additional work is required.
    case moodDetail(id: PersistentIdentifier)
    
    // Future routes can be added here
    // case settings
    // case profile(userId: UUID)
    // case moodEditor(moodId: UUID?)
}

/// Router class managing navigation state
///
/// **Key Concept: MVVM Navigation Pattern**
/// - Router is the "ViewModel" for navigation
/// - Centralizes navigation logic
/// - Separates navigation concerns from UI
/// - Enables programmatic navigation from anywhere
///
/// **Usage:**
/// ```swift
/// @Environment(Router.self) private var router
/// 
/// Button("Go to Detail") {
///     router.navigate(to: .moodDetail(id: moodId))
/// }
/// ```
@Observable
final class Router {
    
    // MARK: - Properties
    
    /// Navigation path (stack of routes)
    /// @Observable makes this reactive (UI updates when path changes)
    var path: [Route] = []
    
    // MARK: - Navigation Actions
    
    /// Navigate to a new route (pushes to stack)
    /// - Parameter route: The destination route
    func navigate(to route: Route) {
        path.append(route)
    }
    
    /// Go back one level (pops from stack)
    func goBack() {
        guard !path.isEmpty else { return }
        path.removeLast()
    }
    
    /// Go back to root (clears entire stack)
    func goBackToRoot() {
        path.removeAll()
    }
    
    /// Replace current route with a new one
    /// - Parameter route: The new route
    func replace(with route: Route) {
        guard !path.isEmpty else {
            navigate(to: route)
            return
        }
        path[path.count - 1] = route
    }
}

// MARK: - View Extension for Routing

extension View {
    /// Setup typed navigation with Router
    ///
    /// **Usage:**
    /// ```swift
    /// NavigationStack {
    ///     ContentView()
    /// }
    /// .withTypedNavigation()
    /// ```
    func withTypedNavigation() -> some View {
        let router = Router()
        return self
            .environment(router)
    }
}

