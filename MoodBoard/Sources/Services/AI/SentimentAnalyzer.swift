//
//  SentimentAnalyzer.swift
//  MoodBoard
//
//  Feature 12: Apple Intelligence Integration
//  Automatic sentiment analysis using Natural Language framework
//

import Foundation
import NaturalLanguage

/// Privacy-first sentiment analysis using Apple's on-device NL Framework
///
/// **Educational Notes:**
/// - Runs entirely on-device (no cloud calls)
/// - Similar to: TensorFlow Lite (Android), transformers.js (Web)
/// - SwiftUI integration: Observable pattern for reactive updates
@Observable
final class SentimentAnalyzer {
    
    // MARK: - Types
    
    /// Sentiment classification result
    enum Sentiment: String, Codable, CaseIterable {
        case positive = "Positive"
        case neutral = "Neutral"
        case negative = "Negative"
        
        /// Confidence threshold for classification
        static let confidenceThreshold: Double = 0.1
        
        /// Associated emoji representation
        var emoji: String {
            switch self {
            case .positive: return "😊"
            case .neutral: return "😐"
            case .negative: return "😔"
            }
        }
        
        /// Associated color for UI
        var colorName: String {
            switch self {
            case .positive: return "green"
            case .neutral: return "gray"
            case .negative: return "orange"
            }
        }
    }
    
    /// Analysis result with confidence score
    struct AnalysisResult {
        let sentiment: Sentiment
        let confidence: Double
        let suggestedEmojis: [String]
        
        var isConfident: Bool {
            confidence >= 0.5
        }
    }
    
    // MARK: - Properties
    
    // Natural Language framework is available on all iOS 17+ devices
    // No need to check availability or initialize specific models
    
    // MARK: - Initialization
    
    init() {
        #if DEBUG
        print("🧠 SentimentAnalyzer initialized")
        #endif
    }
    
    // MARK: - Public API
    
    /// Analyze sentiment of given text
    /// - Parameter text: Text to analyze (mood title or description)
    /// - Returns: Analysis result with sentiment, confidence, and emoji suggestions
    func analyze(_ text: String) -> AnalysisResult {
        guard !text.isEmpty else {
            return AnalysisResult(sentiment: .neutral, confidence: 0.0, suggestedEmojis: [])
        }
        
        // Use NLTagger for sentiment detection
        let tagger = NLTagger(tagSchemes: [.sentimentScore])
        tagger.string = text
        
        // Get sentiment score (-1.0 to 1.0)
        let (sentiment, confidence) = detectSentiment(from: tagger, text: text)
        
        // Get emoji suggestions based on sentiment
        let emojis = suggestEmojis(for: sentiment, text: text)
        
        return AnalysisResult(
            sentiment: sentiment,
            confidence: confidence,
            suggestedEmojis: emojis
        )
    }
    
    /// Batch analyze multiple texts (useful for pattern detection)
    /// - Parameter texts: Array of texts to analyze
    /// - Returns: Array of analysis results
    func batchAnalyze(_ texts: [String]) -> [AnalysisResult] {
        texts.map { analyze($0) }
    }
    
    // MARK: - Private Helpers
    
    private func detectSentiment(from tagger: NLTagger, text: String) -> (Sentiment, Double) {
        let lowercased = text.lowercased()
        
        // Keyword-based sentiment detection (more reliable than NL scores for short texts)
        let positiveKeywords = [
            "happy", "excited", "great", "amazing", "wonderful", "fantastic", "love", "awesome",
            "excellent", "good", "better", "best", "joy", "joyful", "proud", "grateful",
            "blessed", "lucky", "perfect", "beautiful", "incredible", "thrilled", "pleased",
            "delighted", "cheerful", "optimistic", "hopeful", "confident", "energetic"
        ]
        
        let negativeKeywords = [
            "sad", "angry", "upset", "terrible", "awful", "horrible", "hate", "worst",
            "bad", "depressed", "anxious", "stressed", "worried", "frustrated", "annoyed",
            "disappointed", "hurt", "pain", "sick", "tired", "exhausted", "overwhelmed",
            "scared", "afraid", "lonely", "miserable", "unhappy", "devastated"
        ]
        
        // Count keyword matches
        let positiveCount = positiveKeywords.filter { lowercased.contains($0) }.count
        let negativeCount = negativeKeywords.filter { lowercased.contains($0) }.count
        
        // If clear keyword match, use that
        if positiveCount > negativeCount && positiveCount > 0 {
            let confidence = min(Double(positiveCount) * 0.3 + 0.6, 1.0)
            return (.positive, confidence)
        } else if negativeCount > positiveCount && negativeCount > 0 {
            let confidence = min(Double(negativeCount) * 0.3 + 0.6, 1.0)
            return (.negative, confidence)
        }
        
        // Fallback to NL framework for ambiguous cases
        var sentimentScore: Double = 0.0
        var tokenCount = 0
        
        tagger.enumerateTags(
            in: text.startIndex..<text.endIndex,
            unit: .paragraph,
            scheme: .sentimentScore
        ) { tag, _ in
            if let tag = tag,
               let score = Double(tag.rawValue) {
                sentimentScore += score
                tokenCount += 1
            }
            return true
        }
        
        let averageScore = tokenCount > 0 ? sentimentScore / Double(tokenCount) : 0.0
        let confidence = abs(averageScore)
        
        // Classify sentiment based on score
        let sentiment: Sentiment
        if averageScore > Sentiment.confidenceThreshold {
            sentiment = .positive
        } else if averageScore < -Sentiment.confidenceThreshold {
            sentiment = .negative
        } else {
            sentiment = .neutral
        }
        
        return (sentiment, max(confidence, 0.5))
    }
    
    private func suggestEmojis(for sentiment: Sentiment, text: String) -> [String] {
        // Context-aware emoji suggestions based on keywords
        let lowercased = text.lowercased()
        
        var emojis: [String] = []
        
        switch sentiment {
        case .positive:
            if lowercased.contains("excit") || lowercased.contains("amaz") {
                emojis = ["🎉", "⭐", "🚀", "💫", "✨"]
            } else if lowercased.contains("love") || lowercased.contains("happ") {
                emojis = ["❤️", "😊", "🥰", "💕", "😍"]
            } else if lowercased.contains("proud") || lowercased.contains("achiev") {
                emojis = ["🏆", "💪", "👏", "🎯", "⭐"]
            } else {
                emojis = ["😊", "🙂", "😄", "🌟", "✅"]
            }
            
        case .negative:
            if lowercased.contains("stress") || lowercased.contains("anxious") {
                emojis = ["😰", "😟", "😓", "💭", "🌧️"]
            } else if lowercased.contains("sad") || lowercased.contains("depress") {
                emojis = ["😢", "😔", "💔", "🌧️", "😞"]
            } else if lowercased.contains("angry") || lowercased.contains("frustrat") {
                emojis = ["😤", "😠", "💢", "🔥", "😡"]
            } else if lowercased.contains("tired") || lowercased.contains("exhaust") {
                emojis = ["😴", "💤", "😩", "🥱", "😓"]
            } else {
                emojis = ["😔", "😕", "😞", "😢", "🌧️"]
            }
            
        case .neutral:
            if lowercased.contains("work") || lowercased.contains("meet") {
                emojis = ["💼", "📊", "💻", "📝", "🗓️"]
            } else if lowercased.contains("think") || lowercased.contains("wonder") {
                emojis = ["🤔", "💭", "🧠", "❓", "💡"]
            } else {
                emojis = ["😐", "🙂", "📝", "💭", "⚪"]
            }
        }
        
        return emojis
    }
}

// MARK: - Preview Helper

#if DEBUG
extension SentimentAnalyzer {
    /// Mock analyzer for previews (instant results, no ML processing)
    static var mock: SentimentAnalyzer {
        SentimentAnalyzer()
    }
}
#endif

