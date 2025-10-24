//
//  AppleIntelligenceView.swift
//  MoodBoard
//
//  Feature 12: Apple Intelligence Integration
//  Main view demonstrating privacy-first AI capabilities
//

import SwiftUI
import SwiftData

/// Main view showcasing Apple Intelligence integration
///
/// **Educational Notes:**
/// - All AI processing happens on-device (privacy-first)
/// - Graceful degradation if AI unavailable
/// - User control: can disable AI features
struct AppleIntelligenceView: View {
    
    // MARK: - Environment
    
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Mood.timestamp, order: .reverse) private var moods: [Mood]
    
    // MARK: - State
    
    @State private var viewModel = AppleIntelligenceViewModel()
    @State private var selectedTab: Tab = .demo
    @State private var showSettings: Bool = false
    
    enum Tab: String, CaseIterable {
        case demo = "Demo"
        case insights = "Insights"
        case features = "Features"
        
        var icon: String {
            switch self {
            case .demo: return "wand.and.stars"
            case .insights: return "chart.line.uptrend.xyaxis"
            case .features: return "list.bullet"
            }
        }
    }
    
    // MARK: - Body
    
    var body: some View {
        VStack(spacing: 0) {
            // Custom Tab Bar
            tabBar
            
            // Content
            TabView(selection: $selectedTab) {
                demoTab
                    .tag(Tab.demo)
                
                insightsTab
                    .tag(Tab.insights)
                
                featuresTab
                    .tag(Tab.features)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
        }
        .navigationTitle("Apple Intelligence")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showSettings = true
                } label: {
                    Image(systemName: "gear")
                }
            }
        }
        .sheet(isPresented: $showSettings) {
            settingsSheet
        }
        .task {
            // Load patterns on appear
            viewModel.loadPatterns(from: moods)
        }
    }
    
    // MARK: - Tab Bar
    
    private var tabBar: some View {
        HStack(spacing: 0) {
            ForEach(Tab.allCases, id: \.self) { tab in
                Button {
                    withAnimation(.spring(response: 0.3)) {
                        selectedTab = tab
                    }
                } label: {
                    VStack(spacing: 4) {
                        Image(systemName: tab.icon)
                            .font(.system(size: 20))
                        
                        Text(tab.rawValue)
                            .font(.caption)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .foregroundStyle(selectedTab == tab ? Color.accentColor : .secondary)
                    .background {
                        if selectedTab == tab {
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.accentColor.opacity(0.1))
                                .matchedGeometryEffect(id: "tab", in: tabNamespace)
                        }
                    }
                }
            }
        }
        .padding(.horizontal)
        .background(.ultraThinMaterial)
    }
    
    @Namespace private var tabNamespace
    
    // MARK: - Demo Tab
    
    private var demoTab: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Header
                VStack(alignment: .leading, spacing: 8) {
                    Text("Try It Out")
                        .font(.title2.bold())
                    
                    Text("Type a mood and watch AI analyze it in real-time")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .padding(.horizontal)
                
                // Live Demo Card
                AITextFieldDemo(viewModel: viewModel)
                
                // Quick Examples
                VStack(alignment: .leading, spacing: 12) {
                    Text("Quick Examples")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    ForEach(exampleTexts, id: \.self) { example in
                        Button {
                            viewModel.currentMoodText = example
                            viewModel.analyzeMood(example)
                        } label: {
                            HStack {
                                Text(example)
                                    .font(.subheadline)
                                    .foregroundStyle(.primary)
                                
                                Spacer()
                                
                                Image(systemName: "arrow.right.circle.fill")
                                    .foregroundStyle(.secondary)
                            }
                            .padding()
                            .background {
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color(.systemBackground))
                            }
                            .overlay {
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color(.systemGray4), lineWidth: 1)
                            }
                        }
                        .padding(.horizontal)
                    }
                }
            }
            .padding(.vertical)
        }
    }
    
    private let exampleTexts = [
        "Feeling excited about my new project!",
        "Stressed about tomorrow's deadline",
        "Just had an amazing workout 💪",
        "Anxious but trying to stay positive"
    ]
    
    // MARK: - Insights Tab
    
    private var insightsTab: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Weekly Summary
                if let summary = viewModel.weeklySummary {
                    WeeklySummaryCard(summary: summary)
                        .padding(.horizontal)
                }
                
                // Patterns
                if !viewModel.patterns.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Detected Patterns")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        ForEach(viewModel.patterns.prefix(5), id: \.description) { pattern in
                            PatternCard(pattern: pattern)
                                .padding(.horizontal)
                        }
                    }
                } else if moods.count < 5 {
                    ContentUnavailableView(
                        "Not Enough Data",
                        systemImage: "chart.line.uptrend.xyaxis",
                        description: Text("Track at least 5 moods to see patterns")
                    )
                } else if viewModel.isLoadingPatterns {
                    ProgressView("Analyzing patterns...")
                        .padding()
                }
            }
            .padding(.vertical)
        }
    }
    
    // MARK: - Features Tab
    
    private var featuresTab: some View {
        List {
            Section {
                FeatureRowItem(
                    icon: "brain.head.profile",
                    title: "Sentiment Analysis",
                    description: "Automatic emotion detection",
                    color: .blue
                )
                
                FeatureRowItem(
                    icon: "face.smiling",
                    title: "Smart Emoji Suggestions",
                    description: "Context-aware emoji predictions",
                    color: .orange
                )
                
                FeatureRowItem(
                    icon: "chart.xyaxis.line",
                    title: "Pattern Detection",
                    description: "Discover mood trends over time",
                    color: .purple
                )
                
                FeatureRowItem(
                    icon: "wand.and.stars",
                    title: "Writing Tools",
                    description: "AI-powered text enhancement (iOS 18+)",
                    color: .pink
                )
                
                FeatureRowItem(
                    icon: "mic.fill",
                    title: "Enhanced Siri",
                    description: "Natural language mood queries",
                    color: .green
                )
            } header: {
                Text("AI Features")
            } footer: {
                Text("All processing happens on your device. No data is sent to cloud servers.")
                    .font(.caption)
            }
            
            Section("Privacy") {
                HStack {
                    Image(systemName: "lock.shield.fill")
                        .foregroundStyle(.green)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("On-Device Processing")
                            .font(.headline)
                        Text("Your data never leaves your device")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                
                HStack {
                    Image(systemName: "hand.raised.fill")
                        .foregroundStyle(.blue)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("User Control")
                            .font(.headline)
                        Text("Disable AI features anytime")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
    }
    
    // MARK: - Settings Sheet
    
    private var settingsSheet: some View {
        NavigationStack {
            List {
                Section {
                    Toggle("Enable AI Features", isOn: Binding(
                        get: { viewModel.isAIEnabled },
                        set: { _ in viewModel.toggleAI() }
                    ))
                    
                    Toggle("Show Confidence Scores", isOn: $viewModel.showConfidenceScores)
                } header: {
                    Text("AI Settings")
                } footer: {
                    Text("AI features enhance your mood tracking with sentiment analysis and pattern detection.")
                }
                
                Section {
                    Button(role: .destructive) {
                        viewModel.resetPersonalization()
                    } label: {
                        Label("Reset AI Personalization", systemImage: "arrow.counterclockwise")
                    }
                } header: {
                    Text("Data")
                } footer: {
                    Text("This will reset learned emoji preferences and pattern history.")
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        showSettings = false
                    }
                }
            }
        }
    }
}

// MARK: - Supporting Views

private struct FeatureRowItem: View {
    let icon: String
    let title: String
    let description: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(color)
                .frame(width: 40)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                
                Text(description)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Preview

#Preview("Light Mode") {
    AppleIntelligenceView()
        .modelContainer(for: Mood.self, inMemory: true)
}

#Preview("Dark Mode") {
    AppleIntelligenceView()
        .modelContainer(for: Mood.self, inMemory: true)
        .preferredColorScheme(.dark)
}

