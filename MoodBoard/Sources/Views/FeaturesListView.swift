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
struct FeaturesListView: View {
    
    // MARK: - Body
    
    var body: some View {
        NavigationStack {
            List {
                // Feature 01: Intro State
                Section {
                    NavigationLink {
                        IntroStateView()
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
                    NavigationLink {
                        MoodListView()
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
                
                // Future features will be added here
                // Feature 03: @Binding
                // Feature 04: @Environment
                // etc.
            }
            .navigationTitle("MoodBoard Features")
            .navigationBarTitleDisplayMode(.large)
        }
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

