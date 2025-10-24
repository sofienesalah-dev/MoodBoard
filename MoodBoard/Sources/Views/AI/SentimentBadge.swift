//
//  SentimentBadge.swift
//  MoodBoard
//
//  Feature 12: Apple Intelligence Integration
//  Visual indicator for sentiment analysis results
//

import SwiftUI

/// Badge displaying sentiment with confidence indicator
struct SentimentBadge: View {
    let sentiment: SentimentAnalyzer.Sentiment
    let confidence: Double
    let showConfidence: Bool
    
    init(
        sentiment: SentimentAnalyzer.Sentiment,
        confidence: Double,
        showConfidence: Bool = false
    ) {
        self.sentiment = sentiment
        self.confidence = confidence
        self.showConfidence = showConfidence
    }
    
    var body: some View {
        HStack(spacing: 6) {
            // Emoji indicator
            Text(sentiment.emoji)
                .font(.caption)
            
            // Sentiment label
            Text(sentiment.rawValue)
                .font(.caption.weight(.medium))
            
            // Confidence indicator
            if showConfidence {
                Text("(\(Int(confidence * 100))%)")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background {
            Capsule()
                .fill(sentimentColor.opacity(0.2))
        }
        .overlay {
            Capsule()
                .stroke(sentimentColor, lineWidth: 1)
        }
    }
    
    private var sentimentColor: Color {
        switch sentiment {
        case .positive: return .green
        case .neutral: return .gray
        case .negative: return .orange
        }
    }
}

// MARK: - Preview

#Preview("All Sentiments") {
    VStack(spacing: 16) {
        SentimentBadge(sentiment: .positive, confidence: 0.85)
        SentimentBadge(sentiment: .neutral, confidence: 0.60)
        SentimentBadge(sentiment: .negative, confidence: 0.75)
        
        Divider()
        
        SentimentBadge(sentiment: .positive, confidence: 0.85, showConfidence: true)
        SentimentBadge(sentiment: .neutral, confidence: 0.60, showConfidence: true)
        SentimentBadge(sentiment: .negative, confidence: 0.75, showConfidence: true)
    }
    .padding()
}

