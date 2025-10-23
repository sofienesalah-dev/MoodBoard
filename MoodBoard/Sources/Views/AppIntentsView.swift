//
//  AppIntentsView.swift
//  MoodBoard
//
//  Created by Prompt-Driven Development on 2025-10-23
//  Feature 07: App Intents - Demo view showing how to use App Intents
//

import SwiftUI
import SwiftData

/// View demonstrating App Intents integration with Siri and Shortcuts
///
/// This view provides:
/// - Explanation of what App Intents are
/// - Instructions for testing via Siri, Shortcuts, and Spotlight
/// - Quick test button for programmatic intent execution
/// - List of recent moods added (to verify intent works)
struct AppIntentsView: View {
    
    // MARK: - SwiftData Context
    
    @Environment(\.modelContext) private var modelContext
    
    @Query(
        sort: \Mood.timestamp,
        order: .reverse
    )
    private var recentMoods: [Mood]
    
    // MARK: - State
    
    @State private var showingTestSheet = false
    @State private var testTitle = ""
    @State private var testEmoji = "😊"
    @State private var testResult: String?
    @State private var isTestingIntent = false
    
    // MARK: - Body
    
    var body: some View {
        List {
            // Header Section
            Section {
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Image(systemName: "wand.and.stars")
                            .font(.title)
                            .foregroundStyle(.purple)
                        
                        VStack(alignment: .leading) {
                            Text("App Intents")
                                .font(.title2)
                                .fontWeight(.bold)
                            
                            Text("Add moods via Siri & Shortcuts")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                    }
                    
                    Text("Use Siri, Shortcuts, or Spotlight to add moods without opening the app!")
                        .font(.callout)
                        .foregroundStyle(.secondary)
                }
                .padding(.vertical, 8)
            }
            
            // Testing Options Section
            Section("Test App Intents") {
                // Test via Siri
                InstructionRow(
                    icon: "mic.fill",
                    iconColor: .purple,
                    title: "Test with Siri",
                    description: "Say: \"Hey Siri, add a happy mood in MoodBoard\""
                )
                
                // Test via Shortcuts
                InstructionRow(
                    icon: "square.stack.3d.up.fill",
                    iconColor: .orange,
                    title: "Test with Shortcuts",
                    description: "Open Shortcuts app → Create New → Search \"Add Mood\""
                )
                
                // Test via Spotlight
                InstructionRow(
                    icon: "magnifyingglass",
                    iconColor: .blue,
                    title: "Test with Spotlight",
                    description: "Swipe down on Home Screen → Type \"Add Mood\""
                )
                
                // Programmatic Test
                Button {
                    showingTestSheet = true
                } label: {
                    HStack {
                        Image(systemName: "hammer.fill")
                            .foregroundStyle(.green)
                        
                        VStack(alignment: .leading) {
                            Text("Test Programmatically")
                                .font(.body)
                                .foregroundStyle(.primary)
                            
                            Text("Debug intent execution in-app")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundStyle(.tertiary)
                    }
                }
            }
            
            // Recent Moods Section
            Section {
                if recentMoods.isEmpty {
                    ContentUnavailableView(
                        "No Moods Yet",
                        systemImage: "face.dashed",
                        description: Text("Add your first mood using Siri or Shortcuts!")
                    )
                } else {
                    ForEach(recentMoods.prefix(5)) { mood in
                        HStack {
                            Text(mood.emoji)
                                .font(.title2)
                            
                            VStack(alignment: .leading) {
                                Text(mood.label)
                                    .font(.body)
                                
                                Text(mood.timestamp.formatted(date: .abbreviated, time: .shortened))
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            
                            Spacer()
                            
                            if mood.isFavorite {
                                Image(systemName: "star.fill")
                                    .foregroundStyle(.yellow)
                                    .font(.caption)
                            }
                        }
                    }
                }
            } header: {
                Text("Recent Moods")
            } footer: {
                Text("Moods added via intents will appear here automatically.")
            }
            
            // Documentation Section
            Section("Learn More") {
                Link(destination: URL(string: "https://developer.apple.com/documentation/appintents")!) {
                    HStack {
                        Image(systemName: "book.fill")
                            .foregroundStyle(.blue)
                        
                        Text("App Intents Documentation")
                        
                        Spacer()
                        
                        Image(systemName: "arrow.up.right")
                            .font(.caption)
                            .foregroundStyle(.tertiary)
                    }
                }
                
                NavigationLink {
                    DocumentationDetailView()
                } label: {
                    HStack {
                        Image(systemName: "doc.text.fill")
                            .foregroundStyle(.green)
                        
                        Text("View Implementation Details")
                    }
                }
            }
        }
        .navigationTitle("App Intents")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showingTestSheet) {
            NavigationStack {
                intentTestForm
            }
        }
    }
    
    // MARK: - Intent Test Form
    
    private var intentTestForm: some View {
        Form {
            Section("Test Parameters") {
                TextField("Mood Title", text: $testTitle)
                    .autocorrectionDisabled()
                
                HStack {
                    Text("Emoji")
                    Spacer()
                    TextField("", text: $testEmoji)
                        .multilineTextAlignment(.trailing)
                        .frame(width: 60)
                }
            }
            
            Section {
                Button {
                    executeTestIntent()
                } label: {
                    HStack {
                        if isTestingIntent {
                            ProgressView()
                        } else {
                            Image(systemName: "play.fill")
                        }
                        Text("Execute Intent")
                    }
                    .frame(maxWidth: .infinity)
                }
                .disabled(testTitle.isEmpty || isTestingIntent)
            }
            
            if let result = testResult {
                Section("Result") {
                    Text(result)
                        .font(.callout)
                }
            }
        }
        .navigationTitle("Test Intent")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Done") {
                    showingTestSheet = false
                    testResult = nil
                }
            }
        }
    }
    
    // MARK: - Actions
    
    /// Execute the AddMoodIntent programmatically for testing
    private func executeTestIntent() {
        isTestingIntent = true
        testResult = nil
        
        Task {
            let intent = AddMoodIntent()
            intent.title = testTitle
            intent.emoji = testEmoji.isEmpty ? nil : testEmoji
            
            do {
                let result = try await intent.perform()
                
                await MainActor.run {
                    testResult = "✅ Success! Mood added."
                    isTestingIntent = false
                    
                    #if DEBUG
                    print("✅ [AppIntentsView] Intent executed successfully")
                    #endif
                }
            } catch {
                await MainActor.run {
                    testResult = "❌ Error: \(error.localizedDescription)"
                    isTestingIntent = false
                    
                    #if DEBUG
                    print("❌ [AppIntentsView] Intent failed: \(error)")
                    #endif
                }
            }
        }
    }
}

// MARK: - Supporting Views

/// Reusable instruction row component
struct InstructionRow: View {
    let icon: String
    let iconColor: Color
    let title: String
    let description: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .foregroundStyle(iconColor)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.body)
                    .foregroundStyle(.primary)
                
                Text(description)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}

/// Detailed documentation view
struct DocumentationDetailView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // What Are App Intents
                DocumentationSection(
                    title: "What Are App Intents?",
                    icon: "lightbulb.fill",
                    color: .yellow
                ) {
                    Text("App Intents is Apple's modern framework (iOS 16+) for exposing app functionality to the system.")
                    
                    VStack(alignment: .leading, spacing: 8) {
                        BulletPoint(text: "**Siri**: Voice commands")
                        BulletPoint(text: "**Shortcuts**: Custom workflows")
                        BulletPoint(text: "**Spotlight**: Quick actions")
                        BulletPoint(text: "**Focus Filters**: Context-aware features")
                    }
                }
                
                // Key Benefits
                DocumentationSection(
                    title: "Key Benefits",
                    icon: "checkmark.seal.fill",
                    color: .green
                ) {
                    VStack(alignment: .leading, spacing: 8) {
                        BulletPoint(text: "✅ Pure Swift API (no XML files!)")
                        BulletPoint(text: "✅ Type-safe parameters")
                        BulletPoint(text: "✅ Modern async/await support")
                        BulletPoint(text: "✅ Easier testing & debugging")
                    }
                }
                
                // How It Works
                DocumentationSection(
                    title: "How It Works",
                    icon: "gearshape.fill",
                    color: .blue
                ) {
                    Text("1. User triggers intent (Siri/Shortcuts/Spotlight)")
                    Text("2. iOS launches intent in background process")
                    Text("3. Intent creates ModelContainer for SwiftData")
                    Text("4. Mood is saved to persistent storage")
                    Text("5. Confirmation dialog shown to user")
                }
                
                // Example Code
                DocumentationSection(
                    title: "Example Code",
                    icon: "chevron.left.forwardslash.chevron.right",
                    color: .purple
                ) {
                    Text("""
                    struct AddMoodIntent: AppIntent {
                        @Parameter(title: "Mood Title")
                        var title: String
                        
                        func perform() async throws -> IntentResult {
                            // Add mood logic
                            return .result(dialog: "Mood added!")
                        }
                    }
                    """)
                    .font(.system(.caption, design: .monospaced))
                    .padding()
                    .background(Color(.systemGray6))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                }
            }
            .padding()
        }
        .navigationTitle("Documentation")
        .navigationBarTitleDisplayMode(.inline)
    }
}

/// Documentation section component
struct DocumentationSection<Content: View>: View {
    let title: String
    let icon: String
    let color: Color
    @ViewBuilder let content: Content
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .foregroundStyle(color)
                
                Text(title)
                    .font(.headline)
            }
            
            content
                .font(.callout)
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
}

/// Bullet point component
struct BulletPoint: View {
    let text: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Text("•")
                .foregroundStyle(.secondary)
            
            Text(LocalizedStringKey(text))
                .foregroundStyle(.primary)
        }
    }
}

// MARK: - Previews

#Preview("App Intents View") {
    NavigationStack {
        AppIntentsView()
            .modelContainer(for: Mood.self, inMemory: true)
    }
}

#Preview("App Intents View - Dark Mode") {
    NavigationStack {
        AppIntentsView()
            .modelContainer(for: Mood.self, inMemory: true)
    }
    .preferredColorScheme(.dark)
}

#Preview("App Intents View - With Data") {
    NavigationStack {
        AppIntentsView()
            .modelContainer(for: Mood.self, inMemory: true) { result in
                if case .success(let container) = result {
                    Mood.insertSamples(into: container.mainContext)
                }
            }
    }
}

