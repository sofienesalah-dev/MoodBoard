//
//  EnhancedMoodIntents.swift
//  MoodBoard
//
//  Feature 12: Apple Intelligence Integration
//  Enhanced Siri conversations with contextual understanding
//

import AppIntents
import SwiftData

/// Query mood history with natural language
///
/// **Examples:**
/// - "Hey Siri, how am I feeling this week?"
/// - "Hey Siri, show my stress patterns"
/// - "Hey Siri, what's my mood trend?"
@available(iOS 17.0, *)
struct QueryMoodHistoryIntent: AppIntent {
    static var title: LocalizedStringResource = "Query Mood History"
    static var description: IntentDescription = IntentDescription(
        "Ask about your mood patterns and history",
        categoryName: "Insights"
    )
    
    @Parameter(title: "Time Period")
    var timePeriod: TimePeriod
    
    @Parameter(title: "Query Type")
    var queryType: QueryType
    
    enum TimePeriod: String, AppEnum {
        case today = "Today"
        case thisWeek = "This Week"
        case thisMonth = "This Month"
        case lastSevenDays = "Last 7 Days"
        case lastThirtyDays = "Last 30 Days"
        
        static var typeDisplayRepresentation: TypeDisplayRepresentation = "Time Period"
        static var caseDisplayRepresentations: [TimePeriod: DisplayRepresentation] = [
            .today: "Today",
            .thisWeek: "This Week",
            .thisMonth: "This Month",
            .lastSevenDays: "Last 7 Days",
            .lastThirtyDays: "Last 30 Days"
        ]
    }
    
    enum QueryType: String, AppEnum {
        case summary = "Summary"
        case patterns = "Patterns"
        case sentiment = "Sentiment Analysis"
        case frequency = "Frequency"
        
        static var typeDisplayRepresentation: TypeDisplayRepresentation = "Query Type"
        static var caseDisplayRepresentations: [QueryType: DisplayRepresentation] = [
            .summary: "Summary",
            .patterns: "Patterns",
            .sentiment: "Sentiment Analysis",
            .frequency: "Tracking Frequency"
        ]
    }
    
    @MainActor
    func perform() async throws -> some IntentResult & ReturnsValue<String> {
        // Get ModelContext
        let modelContext = try getModelContext()
        
        // Fetch moods for the specified period
        let moods = try fetchMoods(for: timePeriod, from: modelContext)
        
        guard !moods.isEmpty else {
            return .result(value: "No moods recorded for \(timePeriod.rawValue.lowercased()). Start tracking to see insights!")
        }
        
        // Generate response based on query type
        let response = generateResponse(for: queryType, moods: moods, period: timePeriod)
        
        return .result(value: response)
    }
    
    // MARK: - Helpers
    
    private func getModelContext() throws -> ModelContext {
        let container = try ModelContainer(for: Mood.self)
        return ModelContext(container)
    }
    
    private func fetchMoods(for period: TimePeriod, from context: ModelContext) throws -> [Mood] {
        let calendar = Calendar.current
        let now = Date()
        
        let startDate: Date
        switch period {
        case .today:
            startDate = calendar.startOfDay(for: now)
        case .thisWeek:
            startDate = calendar.date(byAdding: .day, value: -7, to: now)!
        case .thisMonth:
            startDate = calendar.date(byAdding: .month, value: -1, to: now)!
        case .lastSevenDays:
            startDate = calendar.date(byAdding: .day, value: -7, to: now)!
        case .lastThirtyDays:
            startDate = calendar.date(byAdding: .day, value: -30, to: now)!
        }
        
        let descriptor = FetchDescriptor<Mood>(
            predicate: #Predicate { $0.timestamp >= startDate },
            sortBy: [SortDescriptor(\.timestamp, order: .reverse)]
        )
        
        return try context.fetch(descriptor)
    }
    
    private func generateResponse(for queryType: QueryType, moods: [Mood], period: TimePeriod) -> String {
        let analyzer = SentimentAnalyzer()
        let detector = MoodPatternDetector(sentimentAnalyzer: analyzer)
        
        switch queryType {
        case .summary:
            return generateSummary(moods: moods, period: period, analyzer: analyzer)
            
        case .patterns:
            let patterns = detector.analyzePatterns(from: moods)
            if patterns.isEmpty {
                return "Not enough data to detect patterns yet. Keep tracking!"
            }
            let topPattern = patterns.first!
            return "I noticed: \(topPattern.description). \(topPattern.recommendation ?? "")"
            
        case .sentiment:
            let sentiments = moods.map { analyzer.analyze($0.label).sentiment }
            let positive = sentiments.filter { $0 == SentimentAnalyzer.Sentiment.positive }.count
            let negative = sentiments.filter { $0 == SentimentAnalyzer.Sentiment.negative }.count
            let neutral = sentiments.filter { $0 == SentimentAnalyzer.Sentiment.neutral }.count
            
            let dominant = max(positive, negative, neutral)
            let dominantType: String
            if dominant == positive {
                dominantType = "positive 😊"
            } else if dominant == negative {
                dominantType = "challenging 💪"
            } else {
                dominantType = "balanced 😐"
            }
            
            return "Your moods have been mostly \(dominantType). \(positive) positive, \(neutral) neutral, \(negative) challenging moments."
            
        case .frequency:
            let days = Set(moods.map { Calendar.current.startOfDay(for: $0.timestamp) }).count
            let average = Double(moods.count) / Double(max(days, 1))
            return "You've logged \(moods.count) moods across \(days) days (avg. \(String(format: "%.1f", average)) per day). Great consistency!"
        }
    }
    
    private func generateSummary(moods: [Mood], period: TimePeriod, analyzer: SentimentAnalyzer) -> String {
        let count = moods.count
        let sentiments = moods.map { analyzer.analyze($0.label).sentiment }
        
        let positive = sentiments.filter { $0 == SentimentAnalyzer.Sentiment.positive }.count
        let negative = sentiments.filter { $0 == SentimentAnalyzer.Sentiment.negative }.count
        
        let trend: String
        if positive > negative * 2 {
            trend = "You've had a really positive \(period.rawValue.lowercased()) 🌟"
        } else if negative > positive * 2 {
            trend = "This \(period.rawValue.lowercased()) has been tough. Remember, you're doing your best 💪"
        } else {
            trend = "Your \(period.rawValue.lowercased()) has been balanced"
        }
        
        // Top emoji
        let topEmoji = moods.map { $0.emoji }
            .reduce(into: [String: Int]()) { $0[$1, default: 0] += 1 }
            .max(by: { $0.value < $1.value })?
            .key ?? "📊"
        
        return "\(trend). You logged \(count) moods, and \(topEmoji) was your most-used emoji."
    }
}

/// Add mood with smart context detection
///
/// **Examples:**
/// - "Hey Siri, add a mood: exhausted but proud"
/// - "Hey Siri, I'm feeling anxious about tomorrow"
@available(iOS 17.0, *)
struct AddMoodWithContextIntent: AppIntent {
    static var title: LocalizedStringResource = "Add Mood with Context"
    static var description: IntentDescription = IntentDescription(
        "Add a mood with automatic emotion and context detection",
        categoryName: "Quick Actions"
    )
    
    @Parameter(title: "How are you feeling?")
    var moodText: String
    
    @MainActor
    func perform() async throws -> some IntentResult & ReturnsValue<String> {
        // Analyze sentiment and get emoji suggestions
        let analyzer = SentimentAnalyzer()
        let analysis = analyzer.analyze(moodText)
        
        // Get suggested emoji
        let suggestedEmoji = analysis.suggestedEmojis.first ?? analysis.sentiment.emoji
        
        // Create mood
        let mood = Mood(
            emoji: suggestedEmoji,
            label: moodText,
            timestamp: Date(),
            isFavorite: false
        )
        
        // Save to ModelContext
        let modelContext = try getModelContext()
        modelContext.insert(mood)
        try modelContext.save()
        
        // Return confirmation
        let sentimentMessage: String
        switch analysis.sentiment {
        case .positive:
            sentimentMessage = "That sounds great!"
        case .negative:
            sentimentMessage = "I hear you. It's okay to feel this way."
        case .neutral:
            sentimentMessage = "Thanks for sharing."
        }
        
        return .result(value: "\(sentimentMessage) Mood saved with \(suggestedEmoji)")
    }
    
    private func getModelContext() throws -> ModelContext {
        let container = try ModelContainer(for: Mood.self)
        return ModelContext(container)
    }
}

/// Find moods matching specific criteria
///
/// **Examples:**
/// - "Hey Siri, show me happy moods"
/// - "Hey Siri, find stressed moods from this week"
@available(iOS 17.0, *)
struct FindMoodsIntent: AppIntent {
    static var title: LocalizedStringResource = "Find Moods"
    static var description: IntentDescription = IntentDescription(
        "Search moods by sentiment or keyword",
        categoryName: "Insights"
    )
    
    @Parameter(title: "Search For")
    var searchCriteria: SearchCriteria
    
    @Parameter(title: "Time Period")
    var timePeriod: QueryMoodHistoryIntent.TimePeriod
    
    enum SearchCriteria: String, AppEnum {
        case happy = "Happy Moods"
        case stressed = "Stressed Moods"
        case work = "Work-Related"
        case favorites = "Favorites"
        case all = "All Moods"
        
        static var typeDisplayRepresentation: TypeDisplayRepresentation = "Search Criteria"
        static var caseDisplayRepresentations: [SearchCriteria: DisplayRepresentation] = [
            .happy: "Happy Moods",
            .stressed: "Stressed Moods",
            .work: "Work-Related",
            .favorites: "Favorites",
            .all: "All Moods"
        ]
    }
    
    @MainActor
    func perform() async throws -> some IntentResult & ReturnsValue<String> {
        let modelContext = try getModelContext()
        let moods = try fetchMoods(for: timePeriod, from: modelContext)
        
        let filtered = filterMoods(moods, by: searchCriteria)
        
        if filtered.isEmpty {
            return .result(value: "No \(searchCriteria.rawValue.lowercased()) found for \(timePeriod.rawValue.lowercased()).")
        }
        
        let count = filtered.count
        let preview = filtered.prefix(3).map { $0.emoji + " " + $0.label }.joined(separator: ", ")
        
        return .result(value: "Found \(count) \(searchCriteria.rawValue.lowercased()): \(preview)\(count > 3 ? ", and more..." : "")")
    }
    
    private func getModelContext() throws -> ModelContext {
        let container = try ModelContainer(for: Mood.self)
        return ModelContext(container)
    }
    
    private func fetchMoods(for period: QueryMoodHistoryIntent.TimePeriod, from context: ModelContext) throws -> [Mood] {
        let calendar = Calendar.current
        let now = Date()
        
        let startDate: Date
        switch period {
        case .today:
            startDate = calendar.startOfDay(for: now)
        case .thisWeek:
            startDate = calendar.date(byAdding: .day, value: -7, to: now)!
        case .thisMonth:
            startDate = calendar.date(byAdding: .month, value: -1, to: now)!
        case .lastSevenDays:
            startDate = calendar.date(byAdding: .day, value: -7, to: now)!
        case .lastThirtyDays:
            startDate = calendar.date(byAdding: .day, value: -30, to: now)!
        }
        
        let descriptor = FetchDescriptor<Mood>(
            predicate: #Predicate { $0.timestamp >= startDate },
            sortBy: [SortDescriptor(\.timestamp, order: .reverse)]
        )
        
        return try context.fetch(descriptor)
    }
    
    private func filterMoods(_ moods: [Mood], by criteria: SearchCriteria) -> [Mood] {
        switch criteria {
        case .happy:
            let analyzer = SentimentAnalyzer()
            return moods.filter { analyzer.analyze($0.label).sentiment == SentimentAnalyzer.Sentiment.positive }
            
        case .stressed:
            let analyzer = SentimentAnalyzer()
            return moods.filter { analyzer.analyze($0.label).sentiment == SentimentAnalyzer.Sentiment.negative }
            
        case .work:
            return moods.filter { $0.label.lowercased().contains("work") }
            
        case .favorites:
            return moods.filter { $0.isFavorite }
            
        case .all:
            return moods
        }
    }
}

// MARK: - App Shortcuts
// Note: App shortcuts are registered in MoodBoardShortcuts (AddMoodIntent.swift)
// to avoid having multiple AppShortcutsProvider conformances

