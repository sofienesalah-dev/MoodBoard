//
//  IntroStateView.swift
//  MoodBoard
//
//  Created by Prompt-Driven Development on 2025-10-19
//  Feature: feature-01-intro-state
//

import SwiftUI

/// Introduction view demonstrating SwiftUI's declarative paradigm via @State
///
/// This view demonstrates the fundamental concept of state management in SwiftUI.
/// The @State property wrapper allows SwiftUI to monitor changes
/// and automatically recalculate the user interface.
///
/// # Parallels with other frameworks:
/// - **React**: @State ≈ useState() hook
/// - **Jetpack Compose**: @State ≈ remember { mutableStateOf() }
///
/// # Declarative Paradigm:
/// Instead of saying "how" to modify the UI (imperative),
/// we describe "what" the UI should display (declarative).
/// SwiftUI automatically handles the updates.
struct IntroStateView: View {
    
    // MARK: - State
    
    /// Local counter managed by SwiftUI
    ///
    /// The @State wrapper tells SwiftUI that this property is a "source of truth"
    /// When counter changes, SwiftUI automatically invalidates and redraws the view
    @State private var counter: Int = 0
    
    // MARK: - Body
    
    var body: some View {
        VStack(spacing: 24) {
            
            // Header
            VStack(spacing: 8) {
                Image(systemName: "sparkles")
                    .font(.system(size: 50))
                    .foregroundStyle(.blue.gradient)
                
                Text("Intro @State")
                    .font(.title)
                    .fontWeight(.bold)
                
                Text("SwiftUI Declarative Paradigm")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .padding(.top, 40)
            
            Spacer()
            
            // Counter Display
            VStack(spacing: 12) {
                Text("Current Value")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .textCase(.uppercase)
                
                // Animated counter display
                Text("\(counter)")
                    .font(.system(size: 72, weight: .bold, design: .rounded))
                    .foregroundStyle(.blue)
                    .contentTransition(.numericText())
            }
            .padding()
            .background {
                RoundedRectangle(cornerRadius: 20)
                    .fill(.blue.opacity(0.1))
            }
            
            Spacer()
            
            // Increment Button
            Button {
                // State modification → SwiftUI automatically redraws
                withAnimation(.spring(response: 0.3)) {
                    counter += 1
                }
            } label: {
                HStack {
                    Image(systemName: "plus.circle.fill")
                        .font(.title2)
                    Text("Increment")
                        .fontWeight(.semibold)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background {
                    RoundedRectangle(cornerRadius: 16)
                        .fill(.blue.gradient)
                }
                .foregroundStyle(.white)
            }
            .padding(.horizontal)
            
            // Reset Button (conditional)
            if counter > 0 {
                Button {
                    withAnimation(.spring(response: 0.3)) {
                        counter = 0
                    }
                } label: {
                    Text("Reset")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .transition(.opacity.combined(with: .scale))
            }
            
            Spacer()
            
            // Info Footer
            VStack(spacing: 4) {
                Label("Counter managed by @State", systemImage: "info.circle")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                
                Text("Each modification triggers an automatic render")
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }
            .padding(.bottom, 20)
        }
        .padding()
    }
}

// MARK: - Previews

#Preview("Initial State") {
    IntroStateView()
}

#Preview("Dark Mode") {
    IntroStateView()
        .preferredColorScheme(.dark)
}

