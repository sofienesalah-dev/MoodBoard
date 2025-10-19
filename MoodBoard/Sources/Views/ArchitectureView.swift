//
//  ArchitectureView.swift
//  MoodBoard
//
//  Created by Prompt-Driven Development on 2025-10-19
//  Feature 03: Architecture - MVVM + SwiftData + Typed Navigation Demo
//

import SwiftUI
import SwiftData

/// Demo view showcasing MVVM architecture with SwiftData and typed navigation
///
/// **Key Concept: MVVM in SwiftUI**
/// - Model: Mood (@Model with SwiftData)
/// - View: This view (ArchitectureView)
/// - ViewModel: Router (@Observable) + SwiftData Context
///
/// **Architecture Layers:**
/// 1. **Model Layer**: Mood.swift (SwiftData @Model)
/// 2. **View Layer**: This file (SwiftUI views)
/// 3. **Navigation**: Router.swift (typed routes)
/// 4. **Storage**: ModelContainer (SwiftData persistence)
///
/// **Comparison with other frameworks:**
/// - React: Similar to Container component with Context + Hooks
/// - Jetpack Compose: Similar to ViewModel + Room + NavHost
/// - MVVM (Android): Similar structure but SwiftData replaces Room/LiveData
struct ArchitectureView: View {
    
    // MARK: - SwiftData Environment
    
    /// SwiftData environment context (automatically injected)
    /// Used to query and manipulate persistent data
    @Environment(\.modelContext) private var modelContext
    
    /// Query all moods from SwiftData, sorted by timestamp (newest first)
    /// @Query is reactive: UI updates automatically when data changes
    ///
    /// **Comparison:**
    /// - Room: Similar to @Query with Flow<List<Entity>>
    /// - Core Data: Replaces @FetchRequest
    /// - Realm: Similar to @ObservedResults
    @Query(sort: \Mood.timestamp, order: .reverse)
    private var moods: [Mood]
    
    // MARK: - Navigation
    
    /// Typed router for programmatic navigation
    /// (For demonstration purposes, not used in this view)
    /// Note: Commented out to avoid crash - Router not yet injected in app environment
    // @Environment(Router.self) private var router
    
    // MARK: - Local State
    
    /// Emoji picker state
    @State private var selectedEmoji = "😊"
    
    /// Mood label text field
    @State private var moodLabel = ""
    
    /// Available mood emojis
    private let availableEmojis = ["😊", "😢", "😡", "😴", "🤔", "🎉", "😱", "🥰", "😎", "🤯"]
    
    // MARK: - Body
    
    var body: some View {
        VStack(spacing: 0) {
            // Header explaining the architecture
            headerSection
            
            Divider()
            
            // Form to add new moods
            addMoodSection
            
            Divider()
            
            // List of persisted moods
            moodsListSection
        }
        .navigationTitle("Architecture")
        .navigationBarTitleDisplayMode(.large)
    }
    
    // MARK: - Subviews
    
    /// Header explaining the architecture concepts
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("MVVM + SwiftData")
                .font(.headline)
                .foregroundStyle(.primary)
            
            Text("This demo showcases a lightweight MVVM architecture with SwiftData for persistence and typed navigation.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            
            // Architecture layers
            VStack(alignment: .leading, spacing: 8) {
                architectureRow(icon: "cube", title: "Model", detail: "@Model (SwiftData)")
                architectureRow(icon: "eye", title: "View", detail: "SwiftUI + @Query")
                architectureRow(icon: "arrow.triangle.branch", title: "Navigation", detail: "Router (typed routes)")
                architectureRow(icon: "cylinder", title: "Storage", detail: "ModelContainer")
            }
            .padding(.top, 8)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color.blue.opacity(0.1))
    }
    
    /// Individual architecture layer row
    private func architectureRow(icon: String, title: String, detail: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundStyle(.blue)
                .frame(width: 24)
                .accessibilityLabel(title)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.caption)
                    .fontWeight(.medium)
                
                Text(detail)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
        .accessibilityElement(children: .combine)
    }
    
    /// Form to add new moods
    private var addMoodSection: some View {
        VStack(spacing: 16) {
            Text("Add a Mood")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            // Emoji picker
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(availableEmojis, id: \.self) { emoji in
                        Button {
                            selectedEmoji = emoji
                        } label: {
                            Text(emoji)
                                .font(.system(size: 40))
                                .frame(width: 60, height: 60)
                                .background(
                                    Circle()
                                        .fill(selectedEmoji == emoji ? Color.blue.opacity(0.2) : Color.gray.opacity(0.1))
                                )
                                .overlay(
                                    Circle()
                                        .stroke(selectedEmoji == emoji ? Color.blue : Color.clear, lineWidth: 2)
                                )
                        }
                        .accessibilityLabel("Select \(emoji) emoji")
                        .accessibilityAddTraits(selectedEmoji == emoji ? [.isSelected] : [])
                    }
                }
            }
            .accessibilityLabel("Emoji picker")
            
            // Label text field
            HStack {
                TextField("Mood label (e.g., Happy)", text: $moodLabel)
                    .textFieldStyle(.roundedBorder)
                
                Button {
                    addMood()
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.title2)
                        .foregroundStyle(.blue)
                }
                .disabled(moodLabel.isEmpty)
                .accessibilityLabel("Add mood")
                .accessibilityHint("Adds the mood to the list")
            }
        }
        .padding()
    }
    
    /// List of persisted moods from SwiftData
    private var moodsListSection: some View {
        List {
            Section {
                if moods.isEmpty {
                    emptyStateView
                } else {
                    ForEach(moods) { mood in
                        ArchitectureMoodRow(mood: mood)
                    }
                    .onDelete(perform: deleteMoods)
                }
            } header: {
                HStack {
                    Text("Persisted Moods (\(moods.count))")
                    Spacer()
                    if !moods.isEmpty {
                        Button("Clear All") {
                            clearAllMoods()
                        }
                        .font(.caption)
                        .foregroundStyle(.red)
                        .accessibilityLabel("Clear all moods")
                        .accessibilityHint("Deletes all moods from the list")
                    }
                }
            } footer: {
                Text("Data is persisted with SwiftData. Moods survive app restarts.")
                    .font(.caption)
            }
        }
        .listStyle(.plain)
    }
    
    /// Empty state when no moods exist
    private var emptyStateView: some View {
        VStack(spacing: 12) {
            Image(systemName: "face.smiling")
                .font(.system(size: 50))
                .foregroundStyle(.gray)
                .accessibilityLabel("Smiling face")
                .accessibilityHidden(true) // Decorative image
            
            Text("No moods yet")
                .font(.headline)
                .foregroundStyle(.secondary)
            
            Text("Add your first mood above!")
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 32)
        .accessibilityElement(children: .combine)
    }
    
    // MARK: - Actions
    
    /// Add a new mood to SwiftData
    private func addMood() {
        guard !moodLabel.isEmpty else { return }
        
        // Create new Mood model
        let newMood = Mood(emoji: selectedEmoji, label: moodLabel)
        
        // Insert into SwiftData context (persists automatically)
        modelContext.insert(newMood)
        
        // Reset form
        moodLabel = ""
        
        // Optional: Save explicitly (usually not needed, SwiftData auto-saves)
        try? modelContext.save()
    }
    
    /// Delete moods at given offsets
    private func deleteMoods(at offsets: IndexSet) {
        for index in offsets {
            let mood = moods[index]
            modelContext.delete(mood)
        }
    }
    
    /// Clear all moods from SwiftData
    private func clearAllMoods() {
        moods.forEach { mood in
            modelContext.delete(mood)
        }
    }
}

// MARK: - Mood Row Component

/// Reusable row view for displaying a mood (SwiftData version)
private struct ArchitectureMoodRow: View {
    let mood: Mood
    
    var body: some View {
        HStack(spacing: 16) {
            // Emoji
            Text(mood.emoji)
                .font(.system(size: 40))
            
            // Label and timestamp
            VStack(alignment: .leading, spacing: 4) {
                Text(mood.label)
                    .font(.headline)
                
                Text(mood.timestamp, style: .relative)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
        }
        .padding(.vertical, 8)
    }
}

// MARK: - Previews

#Preview("Architecture View") {
    NavigationStack {
        ArchitectureView()
    }
    .modelContainer(.preview)
}

#Preview("Architecture View - Dark Mode") {
    NavigationStack {
        ArchitectureView()
    }
    .modelContainer(.preview)
    .preferredColorScheme(.dark)
}

