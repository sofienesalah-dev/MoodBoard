//
//  MoodPatternDetector.swift
//  MoodBoard
//
//  Feature 12: Apple Intelligence Integration
//  Detect patterns in mood history using temporal analysis
//

import Foundation
import SwiftData

/// Detect temporal and contextual patterns in mood history
///
/// **Educational Notes:**
/// - Uses statistical analysis (no ML model required for v1)
/// - Analyzes: day-of-week patterns, time-of-day patterns, keyword correlations
/// - Future: Can be enhanced with Core ML for predictive insights
@Observable
final class MoodPatternDetector {
    
    // MARK: - Types
    
    /// Pattern insight with confidence score
    struct Pattern {
        let type: PatternType
        let description: String
        let confidence: Double
        let dataPoints: Int
        let recommendation: String?
        
        var isSignificant: Bool {
            confidence >= 0.6 && dataPoints >= 5
        }
    }
    
    enum PatternType: String {
        case dayOfWeek = "Day of Week"
        case timeOfDay = "Time of Day"
        case keywordCorrelation = "Keyword"
        case sentimentTrend = "Sentiment Trend"
        case frequency = "Frequency"
    }
    
    /// Weekly mood summary
    struct WeeklySummary {
        let patterns: [Pattern]
        let dominantSentiment: SentimentAnalyzer.Sentiment
        let totalMoods: Int
        let averagePerDay: Double
        let topEmojis: [String]
        let insights: [String]
    }
    
    // MARK: - Properties
    
    private let sentimentAnalyzer: SentimentAnalyzer
    private let calendar: Calendar
    
    // MARK: - Initialization
    
    init(sentimentAnalyzer: SentimentAnalyzer = SentimentAnalyzer()) {
        self.sentimentAnalyzer = sentimentAnalyzer
        self.calendar = Calendar.current
        
        #if DEBUG
        print("📊 MoodPatternDetector initialized")
        #endif
    }
    
    // MARK: - Public API
    
    /// Analyze mood patterns from the last 30 days
    /// - Parameter moods: Array of mood entries to analyze
    /// - Returns: Detected patterns with insights
    func analyzePatterns(from moods: [Mood]) -> [Pattern] {
        guard moods.count >= 5 else {
            return [] // Not enough data
        }
        
        var patterns: [Pattern] = []
        
        // 1. Day of week patterns
        patterns.append(contentsOf: detectDayOfWeekPatterns(in: moods))
        
        // 2. Time of day patterns
        patterns.append(contentsOf: detectTimeOfDayPatterns(in: moods))
        
        // 3. Sentiment trends
        patterns.append(contentsOf: detectSentimentTrends(in: moods))
        
        // 4. Keyword correlations
        patterns.append(contentsOf: detectKeywordPatterns(in: moods))
        
        // 5. Frequency patterns
        patterns.append(contentsOf: detectFrequencyPatterns(in: moods))
        
        return patterns.filter { $0.isSignificant }
            .sorted { $0.confidence > $1.confidence }
    }
    
    /// Generate weekly mood summary with insights
    /// - Parameter moods: Mood entries from the last 7 days
    /// - Returns: Comprehensive weekly summary
    func generateWeeklySummary(from moods: [Mood]) -> WeeklySummary {
        let patterns = analyzePatterns(from: moods)
        
        // Calculate dominant sentiment
        let sentiments = moods.map { sentimentAnalyzer.analyze($0.label).sentiment }
        let dominantSentiment = sentiments.mostFrequent() ?? SentimentAnalyzer.Sentiment.neutral
        
        // Calculate statistics
        let totalMoods = moods.count
        let averagePerDay = Double(totalMoods) / 7.0
        
        // Top emojis
        let topEmojis = moods.map { $0.emoji }
            .reduce(into: [String: Int]()) { $0[$1, default: 0] += 1 }
            .sorted { $0.value > $1.value }
            .prefix(5)
            .map { $0.key }
        
        // Generate insights
        let insights = generateInsights(from: patterns, moods: moods, dominantSentiment: dominantSentiment)
        
        return WeeklySummary(
            patterns: patterns,
            dominantSentiment: dominantSentiment,
            totalMoods: totalMoods,
            averagePerDay: averagePerDay,
            topEmojis: topEmojis,
            insights: insights
        )
    }
    
    // MARK: - Pattern Detection Methods
    
    private func detectDayOfWeekPatterns(in moods: [Mood]) -> [Pattern] {
        var patterns: [Pattern] = []
        
        // Group by day of week
        let moodsByDay = Dictionary(grouping: moods) { mood in
            calendar.component(.weekday, from: mood.timestamp)
        }
        
        // Analyze sentiment by day
        for (weekday, dayMoods) in moodsByDay where dayMoods.count >= 2 {
            let sentiments = dayMoods.map { sentimentAnalyzer.analyze($0.label).sentiment }
            let negativeProportion = Double(sentiments.filter { $0 == SentimentAnalyzer.Sentiment.negative }.count) / Double(sentiments.count)
            let positiveProportion = Double(sentiments.filter { $0 == SentimentAnalyzer.Sentiment.positive }.count) / Double(sentiments.count)
            
            let dayName = calendar.weekdaySymbols[weekday - 1]
            
            if negativeProportion > 0.6 {
                patterns.append(Pattern(
                    type: .dayOfWeek,
                    description: "You tend to feel more stressed on \(dayName)s",
                    confidence: negativeProportion,
                    dataPoints: dayMoods.count,
                    recommendation: "Consider scheduling self-care activities on \(dayName)s"
                ))
            } else if positiveProportion > 0.6 {
                patterns.append(Pattern(
                    type: .dayOfWeek,
                    description: "You're usually happier on \(dayName)s",
                    confidence: positiveProportion,
                    dataPoints: dayMoods.count,
                    recommendation: "Great! Keep up what you're doing on \(dayName)s"
                ))
            }
        }
        
        return patterns
    }
    
    private func detectTimeOfDayPatterns(in moods: [Mood]) -> [Pattern] {
        var patterns: [Pattern] = []
        
        // Group by time of day (morning, afternoon, evening, night)
        let moodsByTime = Dictionary(grouping: moods) { mood -> String in
            let hour = calendar.component(.hour, from: mood.timestamp)
            switch hour {
            case 5..<12: return "morning"
            case 12..<17: return "afternoon"
            case 17..<22: return "evening"
            default: return "night"
            }
        }
        
        for (timeOfDay, timeMoods) in moodsByTime where timeMoods.count >= 3 {
            let sentiments = timeMoods.map { sentimentAnalyzer.analyze($0.label).sentiment }
            let negativeProportion = Double(sentiments.filter { $0 == SentimentAnalyzer.Sentiment.negative }.count) / Double(sentiments.count)
            
            if negativeProportion > 0.6 {
                patterns.append(Pattern(
                    type: .timeOfDay,
                    description: "You often feel down in the \(timeOfDay)",
                    confidence: negativeProportion,
                    dataPoints: timeMoods.count,
                    recommendation: "Try scheduling energizing activities in the \(timeOfDay)"
                ))
            }
        }
        
        return patterns
    }
    
    private func detectSentimentTrends(in moods: [Mood]) -> [Pattern] {
        var patterns: [Pattern] = []
        
        guard moods.count >= 7 else { return patterns }
        
        // Sort by date
        let sortedMoods = moods.sorted { $0.timestamp < $1.timestamp }
        
        // Split into two halves and compare
        let midpoint = sortedMoods.count / 2
        let firstHalf = sortedMoods[..<midpoint]
        let secondHalf = sortedMoods[midpoint...]
        
        let firstHalfPositive = firstHalf.filter {
            sentimentAnalyzer.analyze($0.label).sentiment == SentimentAnalyzer.Sentiment.positive
        }.count
        let secondHalfPositive = secondHalf.filter {
            sentimentAnalyzer.analyze($0.label).sentiment == SentimentAnalyzer.Sentiment.positive
        }.count
        
        let firstRatio = Double(firstHalfPositive) / Double(firstHalf.count)
        let secondRatio = Double(secondHalfPositive) / Double(secondHalf.count)
        let improvement = secondRatio - firstRatio
        
        if improvement > 0.2 {
            patterns.append(Pattern(
                type: .sentimentTrend,
                description: "Your mood has been improving recently 📈",
                confidence: improvement,
                dataPoints: moods.count,
                recommendation: "Keep doing what you're doing!"
            ))
        } else if improvement < -0.2 {
            patterns.append(Pattern(
                type: .sentimentTrend,
                description: "You've been feeling more down lately",
                confidence: abs(improvement),
                dataPoints: moods.count,
                recommendation: "Consider talking to someone or trying stress-relief activities"
            ))
        }
        
        return patterns
    }
    
    private func detectKeywordPatterns(in moods: [Mood]) -> [Pattern] {
        var patterns: [Pattern] = []
        
        // Common stress keywords
        let stressKeywords = ["stress", "anxious", "overwhelm", "pressure", "worry", "deadline"]
        let workKeywords = ["work", "meeting", "project", "boss", "deadline", "office"]
        
        let stressCount = moods.filter { mood in
            let text = mood.label.lowercased()
            return stressKeywords.contains { text.contains($0) }
        }.count
        
        let workCount = moods.filter { mood in
            let text = mood.label.lowercased()
            return workKeywords.contains { text.contains($0) }
        }.count
        
        if Double(stressCount) / Double(moods.count) > 0.4 {
            patterns.append(Pattern(
                type: .keywordCorrelation,
                description: "Stress-related words appear frequently in your moods",
                confidence: Double(stressCount) / Double(moods.count),
                dataPoints: stressCount,
                recommendation: "Consider stress management techniques or mindfulness"
            ))
        }
        
        if Double(workCount) / Double(moods.count) > 0.5 {
            patterns.append(Pattern(
                type: .keywordCorrelation,
                description: "Work seems to be a major factor in your moods",
                confidence: Double(workCount) / Double(moods.count),
                dataPoints: workCount,
                recommendation: "Try to maintain work-life balance"
            ))
        }
        
        return patterns
    }
    
    private func detectFrequencyPatterns(in moods: [Mood]) -> [Pattern] {
        var patterns: [Pattern] = []
        
        // Check if user is tracking moods regularly
        guard let lastMood = moods.last, let firstMood = moods.first else { return patterns }
        let dayRange = calendar.dateComponents([.day], from: lastMood.timestamp, to: firstMood.timestamp).day ?? 0
        let averagePerDay = Double(moods.count) / Double(max(dayRange, 1))
        
        if averagePerDay >= 2.0 {
            patterns.append(Pattern(
                type: .frequency,
                description: "You're tracking your moods regularly ⭐",
                confidence: min(averagePerDay / 3.0, 1.0),
                dataPoints: moods.count,
                recommendation: "Consistent tracking helps identify patterns"
            ))
        }
        
        return patterns
    }
    
    private func generateInsights(from patterns: [Pattern], moods: [Mood], dominantSentiment: SentimentAnalyzer.Sentiment) -> [String] {
        var insights: [String] = []
        
        // Dominant sentiment insight
        switch dominantSentiment {
        case .positive:
            insights.append("Overall, you've had a positive week 😊")
        case .negative:
            insights.append("This week has been challenging. Remember, tough times are temporary.")
        case .neutral:
            insights.append("Your week has been balanced emotionally.")
        }
        
        // Pattern-based insights
        for pattern in patterns.prefix(3) {
            if let recommendation = pattern.recommendation {
                insights.append(recommendation)
            }
        }
        
        // Encouragement
        if moods.count >= 7 {
            insights.append("Great job tracking your moods daily!")
        }
        
        return insights
    }
}

// MARK: - Helper Extensions

private extension Array where Element: Hashable {
    func mostFrequent() -> Element? {
        let counts = reduce(into: [Element: Int]()) { $0[$1, default: 0] += 1 }
        return counts.max(by: { $0.value < $1.value })?.key
    }
}

// MARK: - Preview Helper

#if DEBUG
extension MoodPatternDetector {
    /// Mock detector for previews
    static var mock: MoodPatternDetector {
        MoodPatternDetector()
    }
}
#endif

