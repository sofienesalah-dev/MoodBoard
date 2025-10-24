//
//  PatternInsightsView.swift
//  MoodBoard
//
//  Feature 12: Apple Intelligence Integration
//  Detailed view of detected mood patterns
//

import SwiftUI

/// Detailed pattern insights with recommendations
struct PatternInsightsView: View {
    let patterns: [MoodPatternDetector.Pattern]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Header
                VStack(alignment: .leading, spacing: 8) {
                    Text("Your Patterns")
                        .font(.title.bold())
                    
                    Text("AI-detected insights from your mood history")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)
                
                // Patterns
                if patterns.isEmpty {
                    ContentUnavailableView(
                        "No Patterns Yet",
                        systemImage: "chart.xyaxis.line",
                        description: Text("Track more moods to discover patterns")
                    )
                    .padding(.top, 60)
                } else {
                    ForEach(patterns, id: \.description) { pattern in
                        PatternCard(pattern: pattern)
                            .padding(.horizontal)
                    }
                }
            }
            .padding(.vertical)
        }
        .navigationTitle("Pattern Insights")
        .navigationBarTitleDisplayMode(.inline)
    }
}

/// Card displaying a single pattern
struct PatternCard: View {
    let pattern: MoodPatternDetector.Pattern
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header with type badge
            HStack {
                Label(pattern.type.rawValue, systemImage: typeIcon)
                    .font(.caption.weight(.medium))
                    .foregroundStyle(.secondary)
                
                Spacer()
                
                // Confidence indicator
                ConfidenceIndicator(confidence: pattern.confidence)
            }
            
            // Description
            Text(pattern.description)
                .font(.body.weight(.medium))
            
            // Data points
            Text("\(pattern.dataPoints) data points")
                .font(.caption)
                .foregroundStyle(.secondary)
            
            // Recommendation
            if let recommendation = pattern.recommendation {
                HStack(spacing: 8) {
                    Image(systemName: "lightbulb.fill")
                        .font(.caption)
                        .foregroundStyle(.yellow)
                    
                    Text(recommendation)
                        .font(.caption)
                        .foregroundStyle(.primary)
                }
                .padding(10)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.yellow.opacity(0.1))
                }
            }
        }
        .padding(16)
        .background {
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.1), radius: 8, y: 4)
        }
    }
    
    private var typeIcon: String {
        switch pattern.type {
        case .dayOfWeek: return "calendar"
        case .timeOfDay: return "clock"
        case .keywordCorrelation: return "text.magnifyingglass"
        case .sentimentTrend: return "chart.line.uptrend.xyaxis"
        case .frequency: return "repeat"
        }
    }
}

/// Confidence level indicator
struct ConfidenceIndicator: View {
    let confidence: Double
    
    var body: some View {
        HStack(spacing: 4) {
            ForEach(0..<5) { index in
                Circle()
                    .fill(index < filledCircles ? color : Color.gray.opacity(0.2))
                    .frame(width: 6, height: 6)
            }
        }
    }
    
    private var filledCircles: Int {
        Int(confidence * 5)
    }
    
    private var color: Color {
        switch confidence {
        case 0.8...1.0: return .green
        case 0.6..<0.8: return .blue
        default: return .orange
        }
    }
}

/// Weekly summary card
struct WeeklySummaryCard: View {
    let summary: MoodPatternDetector.WeeklySummary
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("This Week")
                        .font(.headline)
                    
                    Text("\(summary.totalMoods) moods tracked")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                // Dominant sentiment emoji
                Text(summary.dominantSentiment.emoji)
                    .font(.system(size: 40))
            }
            
            // Stats Grid
            HStack(spacing: 12) {
                StatBox(
                    value: "\(summary.totalMoods)",
                    label: "Moods",
                    icon: "face.smiling"
                )
                
                StatBox(
                    value: String(format: "%.1f", summary.averagePerDay),
                    label: "Per Day",
                    icon: "calendar"
                )
                
                StatBox(
                    value: "\(summary.patterns.count)",
                    label: "Patterns",
                    icon: "chart.xyaxis.line"
                )
            }
            
            // Top Emojis
            if !summary.topEmojis.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Most Used")
                        .font(.caption.weight(.medium))
                        .foregroundStyle(.secondary)
                    
                    HStack(spacing: 8) {
                        ForEach(summary.topEmojis, id: \.self) { emoji in
                            Text(emoji)
                                .font(.title3)
                        }
                    }
                }
            }
            
            // Key Insights
            if !summary.insights.isEmpty {
                Divider()
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Key Insights")
                        .font(.caption.weight(.medium))
                        .foregroundStyle(.secondary)
                    
                    ForEach(summary.insights.prefix(3), id: \.self) { insight in
                        HStack(alignment: .top, spacing: 8) {
                            Image(systemName: "sparkles")
                                .font(.caption)
                                .foregroundStyle(.blue)
                            
                            Text(insight)
                                .font(.caption)
                        }
                    }
                }
            }
        }
        .padding(20)
        .background {
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.1), radius: 12, y: 6)
        }
    }
}

/// Small stat box
private struct StatBox: View {
    let value: String
    let label: String
    let icon: String
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundStyle(.blue)
            
            Text(value)
                .font(.title3.weight(.bold))
            
            Text(label)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background {
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.secondarySystemBackground))
        }
    }
}

// MARK: - Preview

#Preview("Pattern Insights") {
    NavigationStack {
        PatternInsightsView(patterns: [
            MoodPatternDetector.Pattern(
                type: .sentimentTrend,
                description: "Your mood has been improving recently 📈",
                confidence: 0.85,
                dataPoints: 15,
                recommendation: "Keep doing what you're doing!"
            ),
            MoodPatternDetector.Pattern(
                type: .dayOfWeek,
                description: "You tend to feel more stressed on Mondays",
                confidence: 0.72,
                dataPoints: 8,
                recommendation: "Consider scheduling self-care on Mondays"
            ),
            MoodPatternDetector.Pattern(
                type: .keywordCorrelation,
                description: "Work seems to be a major factor in your moods",
                confidence: 0.68,
                dataPoints: 12,
                recommendation: "Try to maintain work-life balance"
            )
        ])
    }
}

#Preview("Weekly Summary") {
    WeeklySummaryCard(summary: MoodPatternDetector.WeeklySummary(
        patterns: [],
        dominantSentiment: .positive,
        totalMoods: 18,
        averagePerDay: 2.6,
        topEmojis: ["😊", "💪", "🎉", "😴", "📊"],
        insights: [
            "Overall, you've had a positive week 😊",
            "Great job tracking your moods daily!",
            "Keep up what you're doing on Fridays"
        ]
    ))
    .padding()
    .background(Color(.systemGroupedBackground))
}

