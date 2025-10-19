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
/// - **Model**: Mood (@Model with SwiftData) — Data structure
/// - **View**: This view (ArchitectureView) — UI only, no business logic
/// - **ViewModel**: MoodViewModel (@Observable) — Business logic & data operations
///
/// **Clear Separation of Concerns:**
/// 1. **Model Layer**: Mood.swift (@Model) — What data looks like
/// 2. **View Layer**: This file — How data is displayed
/// 3. **ViewModel Layer**: MoodViewModel.swift — How data is manipulated
/// 4. **Storage Layer**: ModelContainer + ModelContext — Where data is saved
///
/// **Comparison with other frameworks:**
/// - Android MVVM: View → ViewModel → Repository → Room (same pattern!)
/// - React: Component → Custom Hook → Context/Redux → API
/// - Vue.js: Template → Composition API → Store → Backend
struct ArchitectureView: View {
    
    // MARK: - Dependencies
    
    /// SwiftData environment context (injected by SwiftUI)
    /// Passed to ViewModel for persistence operations
    @Environment(\.modelContext) private var modelContext
    
    /// Query all moods from SwiftData (sorted by timestamp)
    /// @Query is reactive: UI updates automatically when data changes
    ///
    /// **This is the "R" in CRUD** (Read)
    @Query(sort: \Mood.timestamp, order: .reverse)
    private var moods: [Mood]
    
    // MARK: - ViewModel
    
    /// ViewModel managing business logic
    /// All actions (Create, Delete, etc.) go through this ViewModel
    /// **This separates UI from business logic!**
    /// Uses @State to maintain a single instance throughout view lifecycle
    @State private var viewModel: MoodViewModel?
    
    // MARK: - Body
    
    var body: some View {
        VStack(spacing: 0) {
            // Header explaining the architecture
            headerSection
            
            Divider()
            
            // Form to add new moods
            if let viewModel {
                addMoodSection(viewModel: viewModel)
            }
            
            Divider()
            
            // List of persisted moods
            if let viewModel {
                moodsListSection(viewModel: viewModel)
            }
        }
        .navigationTitle("Architecture")
        .navigationBarTitleDisplayMode(.large)
        .task {
            // Initialize ViewModel with ModelContext
            // .task runs once per view lifecycle (no need for nil check)
            viewModel = MoodViewModel(modelContext: modelContext)
        }
    }
    
    // MARK: - Subviews
    
    /// Header explaining the architecture concepts
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Title and main explanation
            VStack(alignment: .leading, spacing: 4) {
                Text("🏗️ Architecture Demo")
                    .font(.title3)
                    .fontWeight(.bold)
                
                Text("What you'll see:")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(.secondary)
                
                VStack(alignment: .leading, spacing: 3) {
                    bulletPoint("Data persists (SwiftData)")
                    bulletPoint("CRUD: Create, Read, Delete")
                    bulletPoint("Reactive UI (@Query)")
                }
                .font(.caption)
                .padding(.leading, 4)
            }
            
            Divider()
            
            // Architecture layers explanation
            VStack(alignment: .leading, spacing: 4) {
                Text("Architecture Layers")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(.secondary)
                
                VStack(alignment: .leading, spacing: 2) {
                    architectureRow(icon: "cube", title: "Model", detail: "Mood.swift — @Model")
                    architectureRow(icon: "brain", title: "ViewModel", detail: "Business logic")
                    architectureRow(icon: "eye", title: "View", detail: "UI only")
                    architectureRow(icon: "cylinder", title: "Storage", detail: "Persistence")
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal)
        .padding(.vertical, 12)
        .background(
            LinearGradient(
                colors: [Color.blue.opacity(0.15), Color.blue.opacity(0.05)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
    }
    
    /// Helper to create bullet points
    private func bulletPoint(_ text: String) -> some View {
        HStack(alignment: .top, spacing: 6) {
            Text("•")
                .foregroundStyle(.blue)
                .fontWeight(.bold)
                .font(.caption2)
            Text(text)
                .foregroundStyle(.secondary)
        }
    }
    
    /// Individual architecture layer row
    private func architectureRow(icon: String, title: String, detail: String) -> some View {
        HStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(Color.blue.opacity(0.1))
                    .frame(width: 24, height: 24)
                
                Image(systemName: icon)
                    .foregroundStyle(.blue)
                    .font(.system(size: 11, weight: .semibold))
                    .accessibilityLabel(title)
            }
            
            VStack(alignment: .leading, spacing: 0) {
                Text(title)
                    .font(.caption2)
                    .fontWeight(.semibold)
                    .foregroundStyle(.primary)
                
                Text(detail)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
        }
        .padding(.vertical, 2)
        .accessibilityElement(children: .combine)
    }
    
    /// Form to add new moods
    /// - Parameter viewModel: The ViewModel managing business logic
    private func addMoodSection(viewModel: MoodViewModel) -> some View {
        VStack(spacing: 16) {
            Text("Add a Mood")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            // Emoji picker
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(viewModel.availableEmojis, id: \.self) { emoji in
                        Button {
                            viewModel.selectEmoji(emoji)  // ViewModel action
                        } label: {
                            Text(emoji)
                                .font(.system(size: 40))
                                .frame(width: 60, height: 60)
                                .background(
                                    Circle()
                                        .fill(viewModel.selectedEmoji == emoji ? Color.blue.opacity(0.2) : Color.gray.opacity(0.1))
                                )
                                .overlay(
                                    Circle()
                                        .stroke(viewModel.selectedEmoji == emoji ? Color.blue : Color.clear, lineWidth: 2)
                                )
                        }
                        .accessibilityLabel("Select \(emoji) emoji")
                        .accessibilityAddTraits(viewModel.selectedEmoji == emoji ? [.isSelected] : [])
                    }
                }
            }
            .accessibilityLabel("Emoji picker")
            
            // Label text field
            HStack {
                TextField("Mood label (e.g., Happy)", text: Binding(
                    get: { viewModel.moodLabel },
                    set: { viewModel.moodLabel = $0 }
                ))
                    .textFieldStyle(.roundedBorder)
                
                Button {
                    viewModel.addMood()  // ViewModel action (business logic)
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.title2)
                        .foregroundStyle(.blue)
                }
                .disabled(!viewModel.canAddMood)  // ViewModel validation
                .accessibilityLabel("Add mood")
                .accessibilityHint("Adds the mood to the list")
            }
        }
        .padding()
    }
    
    /// List of persisted moods from SwiftData
    /// - Parameter viewModel: The ViewModel managing business logic
    private func moodsListSection(viewModel: MoodViewModel) -> some View {
        List {
            Section {
                if moods.isEmpty {
                    emptyStateView
                } else {
                    ForEach(moods) { mood in
                        ArchitectureMoodRow(mood: mood)
                    }
                    .onDelete { offsets in
                        viewModel.deleteMoods(at: offsets, from: moods)  // ViewModel action
                    }
                }
            } header: {
                HStack {
                    Text("Persisted Moods (\(moods.count))")
                    Spacer()
                    if !moods.isEmpty {
                        Button("Clear All") {
                            viewModel.clearAllMoods(moods)  // ViewModel action
                        }
                        .font(.caption)
                        .foregroundStyle(.red)
                        .accessibilityLabel("Clear all moods")
                        .accessibilityHint("Deletes all moods from the list")
                    }
                }
            } footer: {
                VStack(alignment: .leading, spacing: 4) {
                    Text("💡 Try this:")
                        .font(.caption)
                        .fontWeight(.semibold)
                    Text("Add a mood, close the app (⌘Q), relaunch it. Your data will still be here!")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
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
    
    // MARK: - Note
    
    /// ⚠️ NO BUSINESS LOGIC IN THE VIEW!
    /// All actions (add, delete, clear) are delegated to the ViewModel
    /// This makes the View:
    /// - Easier to test (mock the ViewModel)
    /// - Easier to maintain (logic changes don't touch UI)
    /// - Reusable (same ViewModel, different Views)
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

