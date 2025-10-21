//
//  FeaturesListView.swift
//  MoodBoard
//
//  Created by Prompt-Driven Development on 2025-10-19
//  Main navigation view to explore all features
//

import SwiftUI

/// Main view listing all available features for demonstration
///
/// This view serves as the entry point to navigate through all
/// implemented features in the MoodBoard project.
///
/// **Navigation:** Uses centralized Router instead of local NavigationLinks
struct FeaturesListView: View {
    
    // MARK: - Navigation
    
    @Environment(Router.self) private var router
    
    // MARK: - Body
    
    var body: some View {
        List {
            // Feature 01: Intro State
            Section {
                Button {
                    router.navigate(to: .introState)
                } label: {
                    FeatureRowView(
                        number: "01",
                        title: "Intro @State",
                        description: "Declarative paradigm & local state management",
                        icon: "sparkles",
                        color: .blue
                    )
                }
            } header: {
                Text("SwiftUI Fundamentals")
            }
            
            // Feature 02: @Observable
            Section {
                Button {
                    router.navigate(to: .observation)
                } label: {
                    FeatureRowView(
                        number: "02",
                        title: "Observation",
                        description: "Modern state management with @Observable & @Bindable",
                        icon: "brain.head.profile",
                        color: .purple
                    )
                }
            } header: {
                Text("State Management")
            }
            
            // Feature 03: Architecture
            Section {
                Button {
                    router.navigate(to: .architecture)
                } label: {
                    FeatureRowView(
                        number: "03",
                        title: "Architecture",
                        description: "MVVM + SwiftData persistence + Typed navigation",
                        icon: "building.columns",
                        color: .orange
                    )
                }
            } header: {
                Text("Architecture & Navigation")
            }
            
            // Feature 04 & 05: List CRUD + Detail
            Section {
                Button {
                    router.navigate(to: .crudList)
                } label: {
                    FeatureRowView(
                        number: "04-05",
                        title: "CRUD + Detail",
                        description: "Complete CRUD with navigation to detail view & favorites",
                        icon: "list.bullet.clipboard",
                        color: .green
                    )
                }
            } header: {
                Text("Data Operations & Navigation")
            } footer: {
                Text("💡 Tap on a mood in the list to see its details and toggle favorite status")
                    .font(.caption2)
            }
            
            // Future features will be added here
            // Feature 06: @Environment
            // Feature 07: Animations
            // etc.
        }
        .navigationTitle("MoodBoard Features")
        .navigationBarTitleDisplayMode(.large)
    }
}

// MARK: - Feature Row Component

/// Reusable row component for feature listing
struct FeatureRowView: View {
    let number: String
    let title: String
    let description: String
    let icon: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 16) {
            // Feature icon
            ZStack {
                Circle()
                    .fill(color.gradient)
                    .frame(width: 50, height: 50)
                
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundStyle(.white)
            }
            
            // Feature info
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text("Feature \(number)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    
                    Spacer()
                }
                
                Text(title)
                    .font(.headline)
                
                Text(description)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Previews

#Preview {
    FeaturesListView()
}

