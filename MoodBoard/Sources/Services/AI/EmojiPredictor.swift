//
//  EmojiPredictor.swift
//  MoodBoard
//
//  Feature 12: Apple Intelligence Integration
//  Real-time emoji prediction based on text input
//

import Foundation
import NaturalLanguage

/// Real-time emoji prediction using NL Framework and keyword matching
///
/// **Educational Notes:**
/// - On-device prediction (privacy-first)
/// - Hybrid approach: ML + rule-based for better accuracy
/// - Similar patterns: Predictive text (Android), emoji keyboard (iOS system)
@Observable
final class EmojiPredictor {
    
    // MARK: - Types
    
    /// Emoji suggestion with relevance score
    struct Suggestion {
        let emoji: String
        let relevance: Double
        let reason: String
    }
    
    // MARK: - Properties
    
    /// Common emoji categories for mood tracking
    private let emojiCategories: [String: [String]] = [
        // Emotions - Positive
        "happy": ["😊", "😄", "😁", "🙂", "😃", "🥰", "😍"],
        "excited": ["🎉", "🚀", "⭐", "💫", "✨", "🔥", "⚡"],
        "love": ["❤️", "💕", "💖", "💗", "💝", "😍", "🥰"],
        "proud": ["🏆", "💪", "👏", "🎯", "⭐", "🌟", "✅"],
        "grateful": ["🙏", "💚", "✨", "🌟", "😊", "💛"],
        "peaceful": ["🌸", "🌺", "☮️", "🕊️", "🧘", "🌿", "💆"],
        
        // Emotions - Negative
        "sad": ["😢", "😔", "😞", "💔", "🌧️", "😿", "😥"],
        "stressed": ["😰", "😓", "💭", "🌧️", "😫", "😩", "💢"],
        "angry": ["😤", "😠", "💢", "🔥", "😡", "👿", "💥"],
        "anxious": ["😰", "😟", "😨", "💭", "🌪️", "😬", "😧"],
        "tired": ["😴", "💤", "😩", "🥱", "😓", "🛌", "💤"],
        "confused": ["🤔", "😕", "😵", "❓", "🤷", "😐", "🧐"],
        
        // Activities
        "work": ["💼", "💻", "📊", "📝", "🗓️", "⚙️", "🏢"],
        "study": ["📚", "✏️", "📖", "🎓", "📝", "🧠", "💡"],
        "exercise": ["🏃", "🏋️", "🚴", "⚽", "🏊", "🧘", "💪"],
        "relax": ["🛀", "🧘", "☕", "📺", "🎮", "🎵", "😌"],
        "social": ["👥", "🗣️", "🤝", "🎊", "🍻", "🎤", "🎭"],
        
        // Context
        "morning": ["🌅", "☀️", "🌄", "☕", "🌞", "🐓"],
        "night": ["🌙", "⭐", "🌃", "💤", "🛌", "🌌"],
        "food": ["🍽️", "🍕", "🍔", "☕", "🍰", "🥗", "🍜"],
        "nature": ["🌳", "🌲", "🌺", "🌸", "🌿", "🏔️", "🌊"],
        "weather": ["☀️", "🌧️", "⛈️", "🌈", "☁️", "❄️", "🌤️"]
    ]
    
    /// Emoji frequency cache (learns from user patterns)
    private var frequencyCache: [String: Int] = [:]
    
    // MARK: - Public API
    
    /// Get real-time emoji predictions as user types
    /// - Parameter text: Current input text
    /// - Returns: Array of emoji suggestions sorted by relevance
    func predict(for text: String) -> [Suggestion] {
        guard !text.isEmpty else {
            return defaultSuggestions()
        }
        
        let lowercased = text.lowercased()
        var suggestions: [Suggestion] = []
        
        // 1. Keyword-based matching
        for (keyword, emojis) in emojiCategories {
            if lowercased.contains(keyword) {
                let relevance = calculateRelevance(keyword: keyword, in: lowercased)
                suggestions.append(contentsOf: emojis.map {
                    Suggestion(
                        emoji: $0,
                        relevance: relevance,
                        reason: "Matches '\(keyword)'"
                    )
                })
            }
        }
        
        // 2. Use NL tagger for part-of-speech analysis
        let nlSuggestions = predictWithNaturalLanguage(text: text)
        suggestions.append(contentsOf: nlSuggestions)
        
        // 3. Apply frequency boost (personalization)
        suggestions = applyFrequencyBoost(to: suggestions)
        
        // 4. Remove duplicates and sort by relevance
        let uniqueSuggestions = Dictionary(grouping: suggestions, by: { $0.emoji })
            .mapValues { $0.max(by: { $0.relevance < $1.relevance })! }
            .values
            .sorted { $0.relevance > $1.relevance }
        
        // Return top 8 suggestions
        return Array(uniqueSuggestions.prefix(8))
    }
    
    /// Record emoji usage to improve future predictions
    /// - Parameter emoji: Emoji that user selected
    func recordUsage(of emoji: String) {
        frequencyCache[emoji, default: 0] += 1
        
        #if DEBUG
        print("📊 Emoji usage recorded: \(emoji) (total: \(frequencyCache[emoji]!))")
        #endif
    }
    
    /// Reset personalization data
    func resetPersonalization() {
        frequencyCache.removeAll()
    }
    
    // MARK: - Private Helpers
    
    private func defaultSuggestions() -> [Suggestion] {
        // Most common mood emojis when no text is entered
        let defaults = ["😊", "😔", "😐", "😴", "🎉", "😰", "💪", "🤔"]
        return defaults.map {
            Suggestion(emoji: $0, relevance: 0.5, reason: "Common mood emoji")
        }
    }
    
    private func calculateRelevance(keyword: String, in text: String) -> Double {
        // Higher relevance if keyword appears earlier or multiple times
        let occurrences = text.components(separatedBy: keyword).count - 1
        let firstIndex = text.range(of: keyword)?.lowerBound
        
        var relevance = 0.7 + (Double(occurrences) * 0.1)
        
        if let firstIndex = firstIndex {
            let position = Double(text.distance(from: text.startIndex, to: firstIndex))
            let textLength = Double(text.count)
            let positionFactor = 1.0 - (position / textLength) * 0.3
            relevance *= positionFactor
        }
        
        return min(relevance, 1.0)
    }
    
    private func predictWithNaturalLanguage(text: String) -> [Suggestion] {
        let tagger = NLTagger(tagSchemes: [.lexicalClass])
        tagger.string = text
        
        var suggestions: [Suggestion] = []
        
        tagger.enumerateTags(
            in: text.startIndex..<text.endIndex,
            unit: .word,
            scheme: .lexicalClass
        ) { tag, tokenRange in
            guard let tag = tag else { return true }
            
            let word = String(text[tokenRange]).lowercased()
            
            // Suggest based on word type
            switch tag {
            case .adjective:
                // Adjectives often describe emotions
                if let emojis = emojiCategories[word] {
                    suggestions.append(contentsOf: emojis.prefix(3).map {
                        Suggestion(emoji: $0, relevance: 0.8, reason: "Describes emotion")
                    })
                }
            case .verb:
                // Action verbs suggest activities
                if word.contains("work") || word.contains("study") {
                    suggestions.append(Suggestion(emoji: "💼", relevance: 0.7, reason: "Activity"))
                }
            default:
                break
            }
            
            return true
        }
        
        return suggestions
    }
    
    private func applyFrequencyBoost(to suggestions: [Suggestion]) -> [Suggestion] {
        guard !frequencyCache.isEmpty else { return suggestions }
        
        return suggestions.map { suggestion in
            let frequency = frequencyCache[suggestion.emoji] ?? 0
            let boost = min(Double(frequency) * 0.05, 0.3) // Max 30% boost
            
            return Suggestion(
                emoji: suggestion.emoji,
                relevance: min(suggestion.relevance + boost, 1.0),
                reason: frequency > 0 ? "You use this often" : suggestion.reason
            )
        }
    }
}

// MARK: - Preview Helper

#if DEBUG
extension EmojiPredictor {
    /// Mock predictor for previews
    static var mock: EmojiPredictor {
        EmojiPredictor()
    }
}
#endif

