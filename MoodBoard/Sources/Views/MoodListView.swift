//
//  MoodListView.swift
//  MoodBoard
//
//  Created by Prompt-Driven Development on 2025-10-19
//  Feature 02: Observation - UI with @Bindable for two-way binding
//

import SwiftUI

/// View displaying and managing a list of moods
///
/// **Key Concept: @Bindable**
/// - Introduced in iOS 17 alongside @Observable
/// - Creates a two-way binding to @Observable properties
/// - Similar to @Binding but specifically for @Observable objects
///
/// **Why use @Bindable?**
/// - Allows passing bindings to child views
/// - Works seamlessly with @Observable (no need for @StateObject)
/// - More performant than old @ObservedObject + @Published
///
/// **Comparison with React:**
/// - React: props + setState callback pattern
/// - SwiftUI: @Bindable for automatic synchronization
struct MoodListView: View {
    
    // MARK: - State
    
    /// The mood store, observed with @Bindable for two-way binding
    ///
    /// **@Bindable vs old system:**
    /// - Old: @StateObject or @ObservedObject + @Published
    /// - New: @State + @Observable + @Bindable
    @State private var store: MoodStore
    
    /// State for showing the add mood sheet
    @State private var isShowingAddMood = false
    
    // MARK: - Initializer
    
    /// Initialize with an optional store (defaults to empty)
    init(store: MoodStore = MoodStore()) {
        self.store = store
    }
    
    // MARK: - Body
    
    var body: some View {
        ZStack {
            if store.moods.isEmpty {
                emptyStateView
            } else {
                moodListContent
            }
        }
        .navigationTitle("My Moods")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    isShowingAddMood = true
                } label: {
                    Image(systemName: "plus.circle.fill")
                }
                .accessibilityLabel("Add new mood")
                .accessibilityHint("Opens a sheet to record your current mood")
            }
            
            if !store.moods.isEmpty {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Clear All") {
                        withAnimation {
                            store.clearAll()
                        }
                    }
                    .foregroundStyle(.red)
                    .accessibilityLabel("Clear all moods")
                    .accessibilityHint("Removes all recorded moods from the list")
                }
            }
        }
        .sheet(isPresented: $isShowingAddMood) {
            AddMoodSheet(store: store)
        }
    }
    
    // MARK: - Subviews
    
    /// Empty state when no moods are recorded
    private var emptyStateView: some View {
        ContentUnavailableView(
            "No Moods Yet",
            systemImage: "face.smiling",
            description: Text("Tap + to add your first mood")
        )
    }
    
    /// List of moods
    private var moodListContent: some View {
        List {
            ForEach(store.moods) { mood in
                MoodRowView(mood: mood)
            }
            .onDelete { indexSet in
                withAnimation {
                    indexSet.forEach { index in
                        store.removeMood(id: store.moods[index].id)
                    }
                }
            }
        }
    }
}

// MARK: - Mood Row Component

/// Row component displaying a single mood
struct MoodRowView: View {
    let mood: MoodEntry
    
    var body: some View {
        HStack(spacing: 16) {
            // Emoji
            Text(mood.emoji)
                .font(.system(size: 44))
                .accessibilityHidden(true) // Emoji is decorative, label provides context
            
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
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(mood.label) mood, \(mood.emoji)")
        .accessibilityValue("Recorded \(mood.timestamp.formatted(.relative(presentation: .named)))")
    }
}

// MARK: - Add Mood Sheet

/// Sheet for adding a new mood
///
/// **Key Point:**
/// - Receives the store directly (no binding needed)
/// - @Observable automatically propagates changes to parent view
struct AddMoodSheet: View {
    
    @Environment(\.dismiss) private var dismiss
    
    /// The store to add moods to
    /// No need for @Binding - @Observable handles synchronization!
    let store: MoodStore
    
    @State private var selectedEmoji = "😊"
    @State private var label = ""
    
    // Predefined mood options
    private let moodOptions: [(emoji: String, label: String)] = [
        ("😊", "Happy"),
        ("😢", "Sad"),
        ("😡", "Angry"),
        ("😴", "Tired"),
        ("🎉", "Excited"),
        ("😰", "Anxious"),
        ("🤔", "Thoughtful"),
        ("😌", "Peaceful")
    ]
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Choose a Mood") {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 60))], spacing: 16) {
                        ForEach(moodOptions, id: \.emoji) { option in
                            Button {
                                selectedEmoji = option.emoji
                                label = option.label
                            } label: {
                                VStack(spacing: 8) {
                                    Text(option.emoji)
                                        .font(.system(size: 40))
                                        .accessibilityHidden(true) // Emoji is decorative
                                    
                                    Text(option.label)
                                        .font(.caption)
                                        .foregroundStyle(selectedEmoji == option.emoji ? .primary : .secondary)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 12)
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(selectedEmoji == option.emoji ? Color.accentColor.opacity(0.2) : Color.clear)
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(selectedEmoji == option.emoji ? Color.accentColor : Color.clear, lineWidth: 2)
                                )
                            }
                            .buttonStyle(.plain)
                            .accessibilityLabel(option.label)
                            .accessibilityHint("Select \(option.label) mood")
                            .accessibilityAddTraits(selectedEmoji == option.emoji ? .isSelected : [])
                        }
                    }
                    .padding(.vertical, 8)
                }
                
                Section("Custom Label (Optional)") {
                    TextField("How are you feeling?", text: $label)
                }
            }
            .navigationTitle("Add Mood")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        addMood()
                    }
                    .disabled(label.isEmpty)
                    .accessibilityLabel("Add mood")
                    .accessibilityHint(label.isEmpty ? "Enter a label to add mood" : "Saves your mood entry")
                }
            }
        }
    }
    
    /// Add the mood and dismiss the sheet
    private func addMood() {
        store.addMood(emoji: selectedEmoji, label: label)
        dismiss()
    }
}

// MARK: - Previews

#Preview("Empty State") {
    MoodListView()
}

#Preview("With Moods") {
    MoodListView(store: MoodStore.sample)
}

#Preview("With Moods - Dark Mode") {
    MoodListView(store: MoodStore.sample)
        .preferredColorScheme(.dark)
}

#Preview("Add Mood Sheet") {
    AddMoodSheet(store: MoodStore())
}

#Preview("Add Mood Sheet - Dark Mode") {
    AddMoodSheet(store: MoodStore())
        .preferredColorScheme(.dark)
}

