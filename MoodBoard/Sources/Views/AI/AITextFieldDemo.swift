//
//  AITextFieldDemo.swift
//  MoodBoard
//
//  Feature 12: Apple Intelligence Integration
//  Interactive demo of real-time AI analysis
//

import SwiftUI

/// Live demo of AI sentiment and emoji prediction
struct AITextFieldDemo: View {
    @Bindable var viewModel: AppleIntelligenceViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Text Input
            VStack(alignment: .leading, spacing: 8) {
                Text("Type your mood")
                    .font(.caption.weight(.medium))
                    .foregroundStyle(.secondary)
                
                TextField("How are you feeling?", text: $viewModel.currentMoodText, axis: .vertical)
                    .textFieldStyle(.roundedBorder)
                    .lineLimit(3...6)
                    .onChange(of: viewModel.currentMoodText) { _, newValue in
                        viewModel.analyzeMood(newValue)
                    }
            }
            
            // Real-time Analysis Results
            if !viewModel.currentMoodText.isEmpty {
                VStack(alignment: .leading, spacing: 12) {
                    // Sentiment Badge
                    if let sentiment = viewModel.currentSentiment {
                        HStack {
                            Text("Detected Sentiment:")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            
                            SentimentBadge(
                                sentiment: sentiment.sentiment,
                                confidence: sentiment.confidence,
                                showConfidence: viewModel.showConfidenceScores
                            )
                        }
                    }
                    
                    // Emoji Suggestions
                    if !viewModel.emojiSuggestions.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Suggested Emojis:")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 12) {
                                    ForEach(viewModel.emojiSuggestions.prefix(8), id: \.emoji) { suggestion in
                                        EmojiSuggestionButton(
                                            suggestion: suggestion,
                                            showReason: viewModel.showConfidenceScores
                                        ) {
                                            viewModel.recordEmojiUsage(suggestion.emoji)
                                            // In real app: add to text field or select
                                        }
                                    }
                                }
                            }
                        }
                    }
                    
                    // Writing Prompts
                    if viewModel.currentMoodText.count > 10 {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Writing Prompts:")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            
                            ForEach(viewModel.getWritingPrompts().prefix(3), id: \.self) { prompt in
                                Button {
                                    viewModel.currentMoodText += " \(prompt)"
                                } label: {
                                    HStack {
                                        Image(systemName: "lightbulb.fill")
                                            .font(.caption)
                                            .foregroundStyle(.yellow)
                                        
                                        Text(prompt)
                                            .font(.caption)
                                            .foregroundStyle(.primary)
                                        
                                        Spacer()
                                    }
                                    .padding(8)
                                    .background {
                                        RoundedRectangle(cornerRadius: 8)
                                            .fill(Color(.secondarySystemBackground))
                                    }
                                }
                            }
                        }
                    }
                }
                .padding(.top, 4)
            } else {
                // Placeholder
                HStack(spacing: 12) {
                    Image(systemName: "wand.and.stars")
                        .font(.title2)
                        .foregroundStyle(.blue)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("AI Analysis Ready")
                            .font(.subheadline.weight(.medium))
                        
                        Text("Start typing to see real-time insights")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                .background {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.blue.opacity(0.1))
                }
            }
        }
        .padding(20)
        .background {
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.1), radius: 8, y: 4)
        }
        .padding(.horizontal)
    }
}

/// Button for emoji suggestion
struct EmojiSuggestionButton: View {
    let suggestion: EmojiPredictor.Suggestion
    let showReason: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Text(suggestion.emoji)
                    .font(.title)
                
                if showReason {
                    Text(String(format: "%.0f%%", suggestion.relevance * 100))
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
            .frame(width: 60, height: 60)
            .background {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.secondarySystemBackground))
            }
            .overlay {
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.accentColor.opacity(0.3), lineWidth: 1)
            }
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Preview

#Preview {
    ScrollView {
        AITextFieldDemo(viewModel: AppleIntelligenceViewModel.preview)
    }
    .background(Color(.systemGroupedBackground))
}

