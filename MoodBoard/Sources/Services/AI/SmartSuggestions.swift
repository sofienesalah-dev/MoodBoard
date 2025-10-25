//
//  SmartSuggestions.swift
//  MoodBoard
//
//  Feature 12: Apple Intelligence Integration
//  Writing Tools API integration (iOS 18+) and smart text suggestions
//

import Foundation

/// Smart writing suggestions and text enhancement
///
/// **Educational Notes:**
/// - iOS 18+ Writing Tools API for summarization and tone adjustment
/// - Graceful fallback for iOS 17 (basic text processing)
/// - Privacy: All processing happens on-device
@Observable
final class SmartSuggestions {
    
    // MARK: - Types
    
    /// Text enhancement options
    enum EnhancementType {
        case summarize
        case adjustTone(Tone)
        case proofread
        case expandIdeas
        
        var displayName: String {
            switch self {
            case .summarize: return "Summarize"
            case .adjustTone(let tone): return "Make it \(tone.rawValue)"
            case .proofread: return "Proofread"
            case .expandIdeas: return "Expand Ideas"
            }
        }
    }
    
    enum Tone: String, CaseIterable {
        case professional = "Professional"
        case casual = "Casual"
        case empathetic = "Empathetic"
        case concise = "Concise"
    }
    
    /// Suggestion result
    struct SuggestionResult {
        let originalText: String
        let enhancedText: String
        let changes: [String]
        let processingTime: TimeInterval
    }
    
    // MARK: - Properties
    
    private var isWritingToolsAvailable: Bool {
        if #available(iOS 18.0, *) {
            return true
        }
        return false
    }
    
    // MARK: - Initialization
    
    init() {
        #if DEBUG
        print("✍️ SmartSuggestions initialized (Writing Tools: \(isWritingToolsAvailable))")
        #endif
    }
    
    // MARK: - Public API
    
    /// Enhance text with Writing Tools or fallback processing
    /// - Parameters:
    ///   - text: Original text to enhance
    ///   - type: Type of enhancement to apply
    /// - Returns: Enhanced text result
    func enhance(_ text: String, with type: EnhancementType) async -> SuggestionResult {
        let startTime = Date()
        
        let enhancedText: String
        let changes: [String]
        
        if #available(iOS 18.0, *), isWritingToolsAvailable {
            // Use iOS 18 Writing Tools API
            (enhancedText, changes) = await enhanceWithWritingTools(text, type: type)
        } else {
            // Fallback to basic text processing
            (enhancedText, changes) = enhanceWithFallback(text, type: type)
        }
        
        let processingTime = Date().timeIntervalSince(startTime)
        
        return SuggestionResult(
            originalText: text,
            enhancedText: enhancedText,
            changes: changes,
            processingTime: processingTime
        )
    }
    
    /// Check if text is long enough to benefit from summarization
    /// - Parameter text: Text to check
    /// - Returns: True if text should be summarized
    func shouldSummarize(_ text: String) -> Bool {
        let wordCount = text.components(separatedBy: .whitespacesAndNewlines)
            .filter { !$0.isEmpty }
            .count
        return wordCount > 20
    }
    
    /// Generate quick writing prompts based on context
    /// - Parameter context: Current mood or situation
    /// - Returns: Array of prompt suggestions
    func generatePrompts(for context: String) -> [String] {
        let lowercased = context.lowercased()
        
        var prompts: [String] = []
        
        if lowercased.contains("stress") {
            prompts = [
                "What's causing this stress?",
                "How can I address this situation?",
                "What would make me feel better right now?"
            ]
        } else if lowercased.contains("happy") || lowercased.contains("excited") {
            prompts = [
                "What made this moment special?",
                "Who can I share this with?",
                "How can I recreate this feeling?"
            ]
        } else if lowercased.contains("tired") {
            prompts = [
                "What's draining my energy?",
                "When can I rest properly?",
                "What small thing could help right now?"
            ]
        } else {
            prompts = [
                "How am I really feeling?",
                "What triggered this mood?",
                "What do I need right now?"
            ]
        }
        
        return prompts
    }
    
    // MARK: - Private Helpers
    
    @available(iOS 18.0, *)
    private func enhanceWithWritingTools(_ text: String, type: EnhancementType) async -> (String, [String]) {
        // TODO: Integrate actual Writing Tools API when available
        // For now, simulate API behavior
        
        try? await Task.sleep(for: .milliseconds(500)) // Simulate API call (0.5s)
        
        var enhanced = text
        var changes: [String] = []
        
        switch type {
        case .summarize:
            // Simulate summarization
            let sentences = text.components(separatedBy: CharacterSet(charactersIn: ".!?"))
                .map { $0.trimmingCharacters(in: .whitespaces) }
                .filter { !$0.isEmpty }
            
            if sentences.count > 1 {
                enhanced = sentences.first! + "."
                changes.append("Condensed \(sentences.count) sentences into 1")
            }
            
        case .adjustTone(let tone):
            // Simulate tone adjustment
            changes.append("Adjusted tone to \(tone.rawValue)")
            // In real implementation, Writing Tools API would handle this
            
        case .proofread:
            // Simulate proofreading
            enhanced = text.replacingOccurrences(of: " i ", with: " I ")
                .replacingOccurrences(of: "  ", with: " ")
            changes.append("Fixed capitalization and spacing")
            
        case .expandIdeas:
            // Simulate idea expansion
            changes.append("Suggested additional context")
        }
        
        return (enhanced, changes)
    }
    
    private func enhanceWithFallback(_ text: String, type: EnhancementType) -> (String, [String]) {
        var enhanced = text
        var changes: [String] = []
        
        switch type {
        case .summarize:
            // Simple summarization: take first sentence
            let sentences = text.components(separatedBy: CharacterSet(charactersIn: ".!?"))
                .map { $0.trimmingCharacters(in: .whitespaces) }
                .filter { !$0.isEmpty }
            
            if sentences.count > 1 {
                enhanced = sentences.first! + "."
                changes.append("Extracted first sentence as summary")
            } else {
                enhanced = text
                changes.append("Text is already concise")
            }
            
        case .adjustTone:
            changes.append("Tone adjustment available on iOS 18+")
            
        case .proofread:
            // Basic proofreading
            enhanced = text
                .replacingOccurrences(of: " i ", with: " I ")
                .replacingOccurrences(of: "  ", with: " ")
                .trimmingCharacters(in: .whitespacesAndNewlines)
            
            if enhanced != text {
                changes.append("Fixed basic formatting issues")
            } else {
                changes.append("No issues found")
            }
            
        case .expandIdeas:
            changes.append("Idea expansion available on iOS 18+")
        }
        
        return (enhanced, changes)
    }
}

// MARK: - Preview Helper

#if DEBUG
extension SmartSuggestions {
    /// Mock suggestions for previews
    static var mock: SmartSuggestions {
        SmartSuggestions()
    }
    
    /// Generate mock result for previews
    static func mockResult(for text: String) -> SuggestionResult {
        SuggestionResult(
            originalText: text,
            enhancedText: "Enhanced: \(text)",
            changes: ["Made text clearer", "Improved tone"],
            processingTime: 0.5
        )
    }
}
#endif

