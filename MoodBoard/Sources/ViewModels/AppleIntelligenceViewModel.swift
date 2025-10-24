//
//  AppleIntelligenceViewModel.swift
//  MoodBoard
//
//  Feature 12: Apple Intelligence Integration
//  ViewModel for Apple Intelligence features
//
//  **MVVM Pattern:**
//  - View: Displays UI and handles user interaction
//  - ViewModel: Business logic, state management, coordination
//  - Services: AI processing (SentimentAnalyzer, EmojiPredictor, etc.)
//

import Foundation
import SwiftData
import Observation

/// ViewModel coordinating all Apple Intelligence features
///
/// **Educational Notes:**
/// - @Observable replaces @Published (iOS 17+ observation framework)
/// - Dependency Injection: All services injected, not created internally
/// - Similar patterns: ViewModel (Android), Controller (React), Presenter (MVP)
@Observable
final class AppleIntelligenceViewModel {
    
    // MARK: - Properties
    
    // AI Services (injected dependencies)
    let sentimentAnalyzer: SentimentAnalyzer
    let emojiPredictor: EmojiPredictor
    let patternDetector: MoodPatternDetector
    let smartSuggestions: SmartSuggestions
    
    // State
    var currentMoodText: String = "" {
        didSet {
            updateRealTimePredictions()
        }
    }
    
    var selectedMood: Mood?
    var patterns: [MoodPatternDetector.Pattern] = []
    var weeklySummary: MoodPatternDetector.WeeklySummary?
    var emojiSuggestions: [EmojiPredictor.Suggestion] = []
    var currentSentiment: SentimentAnalyzer.AnalysisResult?
    
    // UI State
    var isAnalyzing: Bool = false
    var isLoadingPatterns: Bool = false
    var errorMessage: String?
    
    // Settings
    var isAIEnabled: Bool = true
    var showConfidenceScores: Bool = false
    
    // MARK: - Initialization
    
    /// Initialize with dependency injection
    /// - Parameters:
    ///   - sentimentAnalyzer: Sentiment analysis service
    ///   - emojiPredictor: Emoji prediction service
    ///   - patternDetector: Pattern detection service
    ///   - smartSuggestions: Smart suggestions service
    init(
        sentimentAnalyzer: SentimentAnalyzer = SentimentAnalyzer(),
        emojiPredictor: EmojiPredictor = EmojiPredictor(),
        patternDetector: MoodPatternDetector = MoodPatternDetector(),
        smartSuggestions: SmartSuggestions = SmartSuggestions()
    ) {
        self.sentimentAnalyzer = sentimentAnalyzer
        self.emojiPredictor = emojiPredictor
        self.patternDetector = patternDetector
        self.smartSuggestions = smartSuggestions
        
        #if DEBUG
        print("🧠 AppleIntelligenceViewModel initialized")
        #endif
    }
    
    // MARK: - Public API
    
    /// Analyze mood text and provide AI insights
    /// - Parameter text: Mood text to analyze
    func analyzeMood(_ text: String) {
        guard isAIEnabled, !text.isEmpty else { return }
        
        isAnalyzing = true
        errorMessage = nil
        
        // Sentiment analysis
        currentSentiment = sentimentAnalyzer.analyze(text)
        
        // Emoji predictions
        emojiSuggestions = emojiPredictor.predict(for: text)
        
        isAnalyzing = false
        
        #if DEBUG
        print("🔍 Analyzed: \(text) → \(currentSentiment?.sentiment.rawValue ?? "N/A")")
        #endif
    }
    
    /// Load patterns from mood history
    /// - Parameter moods: Array of historical moods
    func loadPatterns(from moods: [Mood]) {
        guard isAIEnabled else { return }
        
        isLoadingPatterns = true
        errorMessage = nil
        
        // Analyze patterns in background
        Task { @MainActor in
            patterns = patternDetector.analyzePatterns(from: moods)
            
            // Generate weekly summary if we have recent data
            let recentMoods = moods.filter {
                $0.timestamp >= Calendar.current.date(byAdding: .day, value: -7, to: Date())!
            }
            
            if !recentMoods.isEmpty {
                weeklySummary = patternDetector.generateWeeklySummary(from: recentMoods)
            }
            
            isLoadingPatterns = false
            
            #if DEBUG
            print("📊 Loaded \(patterns.count) patterns from \(moods.count) moods")
            #endif
        }
    }
    
    /// Enhance text with AI suggestions
    /// - Parameters:
    ///   - text: Original text
    ///   - type: Enhancement type
    /// - Returns: Enhanced text result
    func enhanceText(_ text: String, with type: SmartSuggestions.EnhancementType) async -> SmartSuggestions.SuggestionResult {
        guard isAIEnabled else {
            return SmartSuggestions.SuggestionResult(
                originalText: text,
                enhancedText: text,
                changes: ["AI features disabled"],
                processingTime: 0
            )
        }
        
        return await smartSuggestions.enhance(text, with: type)
    }
    
    /// Record emoji usage for personalization
    /// - Parameter emoji: Selected emoji
    func recordEmojiUsage(_ emoji: String) {
        emojiPredictor.recordUsage(of: emoji)
    }
    
    /// Get writing prompts based on current mood text
    /// - Returns: Array of prompt suggestions
    func getWritingPrompts() -> [String] {
        guard !currentMoodText.isEmpty else {
            return [
                "How am I really feeling?",
                "What happened today?",
                "What do I need right now?"
            ]
        }
        
        return smartSuggestions.generatePrompts(for: currentMoodText)
    }
    
    /// Reset all AI personalization data
    func resetPersonalization() {
        emojiPredictor.resetPersonalization()
        
        #if DEBUG
        print("🔄 AI personalization reset")
        #endif
    }
    
    /// Toggle AI features on/off
    func toggleAI() {
        isAIEnabled.toggle()
        
        if !isAIEnabled {
            // Clear current AI data
            currentSentiment = nil
            emojiSuggestions = []
            patterns = []
            weeklySummary = nil
        }
        
        #if DEBUG
        print("🔧 AI features \(isAIEnabled ? "enabled" : "disabled")")
        #endif
    }
    
    // MARK: - Private Helpers
    
    private func updateRealTimePredictions() {
        guard isAIEnabled else { return }
        
        // Real-time emoji predictions as user types
        emojiSuggestions = emojiPredictor.predict(for: currentMoodText)
        
        // Update sentiment if text is substantial
        if currentMoodText.count > 3 {
            currentSentiment = sentimentAnalyzer.analyze(currentMoodText)
        }
    }
}

// MARK: - Preview Helper

#if DEBUG
extension AppleIntelligenceViewModel {
    /// Mock ViewModel for previews
    static var preview: AppleIntelligenceViewModel {
        let vm = AppleIntelligenceViewModel()
        vm.currentMoodText = "Feeling excited about the new project!"
        vm.currentSentiment = SentimentAnalyzer.AnalysisResult(
            sentiment: .positive,
            confidence: 0.85,
            suggestedEmojis: ["🎉", "⭐", "🚀", "💫", "✨"]
        )
        vm.emojiSuggestions = [
            EmojiPredictor.Suggestion(emoji: "🎉", relevance: 0.9, reason: "Matches 'excited'"),
            EmojiPredictor.Suggestion(emoji: "⭐", relevance: 0.85, reason: "Positive context"),
            EmojiPredictor.Suggestion(emoji: "🚀", relevance: 0.8, reason: "Matches 'project'")
        ]
        vm.patterns = [
            MoodPatternDetector.Pattern(
                type: .sentimentTrend,
                description: "Your mood has been improving recently 📈",
                confidence: 0.75,
                dataPoints: 15,
                recommendation: "Keep doing what you're doing!"
            ),
            MoodPatternDetector.Pattern(
                type: .dayOfWeek,
                description: "You're usually happier on Fridays",
                confidence: 0.68,
                dataPoints: 8,
                recommendation: "Great! Keep up what you're doing on Fridays"
            )
        ]
        return vm
    }
}
#endif

