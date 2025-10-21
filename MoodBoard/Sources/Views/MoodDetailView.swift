//
//  MoodDetailView.swift
//  MoodBoard
//
//  Created by Prompt-Driven Development on 2025-10-20
//  Feature 05: Detail + Favorite - Complete detail view for moods
//

import SwiftUI
import SwiftData

/// Detail view displaying complete information about a mood
///
/// **Key Concepts:**
/// - **Type-Safe Navigation**: Receives Mood object directly
/// - **MVVM Pattern**: Business logic separated into ViewModel (if needed)
/// - **@Bindable**: Two-way binding for favorite toggle
/// - **Persistence**: Changes automatically saved to SwiftData
///
/// **Features:**
/// - Large emoji display
/// - All mood properties (label, timestamp, favorite status)
/// - Favorite toggle with animation
/// - Formatted timestamp (relative + absolute)
/// - Share functionality
/// - Edit button (navigates back to edit)
///
/// **Comparison with other frameworks:**
/// - Android: Detail Activity/Fragment with ViewModel
/// - React: Detail component with useParams hook
/// - Flutter: Detail screen with Hero animation
struct MoodDetailView: View {
    
    // MARK: - Dependencies
    
    /// The mood to display
    /// @Bindable allows two-way binding for changes (like favorite)
    @Bindable var mood: Mood
    
    /// Environment for dismissal
    @Environment(\.dismiss) private var dismiss
    
    // MARK: - Body
    
    var body: some View {
        ScrollView {
            VStack(spacing: 32) {
                // Hero emoji
                emojiHeader
                
                // Mood information
                moodInfoSection
                
                // Metadata
                metadataSection
                
                // Actions
                actionsSection
            }
            .frame(maxWidth: .infinity)
            .padding()
        }
        .navigationTitle("Mood Details")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            toolbarContent
        }
    }
    
    // MARK: - Subviews
    
    /// Large emoji display with gradient background
    private var emojiHeader: some View {
        ZStack {
            Circle()
                .fill(
                    LinearGradient(
                        colors: [.blue.opacity(0.2), .purple.opacity(0.1)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(width: 200, height: 200)
            
            Text(mood.emoji)
                .font(.system(size: 100))
        }
        .accessibilityHidden(true) // Decorative, label provides context
    }
    
    /// Mood label and favorite button
    private var moodInfoSection: some View {
        VStack(spacing: 12) {
            Text(mood.label)
                .font(.largeTitle)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
            
            HStack(spacing: 8) {
                Image(systemName: "calendar")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                
                Text(mood.timestamp, style: .relative)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .accessibilityLabel("Recorded \(mood.timestamp.formatted(.relative(presentation: .named)))")
        }
    }
    
    /// Metadata section with cards
    private var metadataSection: some View {
        VStack(spacing: 16) {
            // Timestamp card
            InfoCard(
                icon: "clock",
                title: "Recorded",
                value: mood.timestamp.formatted(date: .long, time: .shortened),
                color: .blue
            )
            
            // Favorite status card
            InfoCard(
                icon: mood.isFavorite ? "heart.fill" : "heart",
                title: "Favorite",
                value: mood.isFavorite ? "Yes" : "No",
                color: mood.isFavorite ? .red : .gray
            )
        }
    }
    
    /// Action buttons
    private var actionsSection: some View {
        VStack(spacing: 12) {
            // Share button
            Button {
                shareMood()
            } label: {
                Label("Share Mood", systemImage: "square.and.arrow.up")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
            .accessibilityHint("Share this mood")
            
            // Additional info
            Text("💡 Tap the heart in the toolbar to favorite")
                .font(.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
    }
    
    /// Toolbar with favorite button
    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            FavoriteButton(isFavorite: $mood.isFavorite) {
                // Optional: Add haptic feedback or analytics
                print("Favorite toggled: \(mood.isFavorite)")
            }
        }
    }
    
    // MARK: - Actions
    
    /// Share the mood information
    private func shareMood() {
        let text = "\(mood.emoji) \(mood.label)\nRecorded \(mood.timestamp.formatted(.relative(presentation: .named)))"
        
        #if os(iOS)
        let activityVC = UIActivityViewController(
            activityItems: [text],
            applicationActivities: nil
        )
        
        // Present from root view controller
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootViewController = windowScene.windows.first?.rootViewController {
            rootViewController.present(activityVC, animated: true)
        }
        #endif
    }
}

// MARK: - Info Card Component

/// Reusable info card for metadata display
private struct InfoCard: View {
    let icon: String
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 16) {
            // Icon
            ZStack {
                Circle()
                    .fill(color.opacity(0.2))
                    .frame(width: 44, height: 44)
                
                Image(systemName: icon)
                    .foregroundStyle(color)
                    .font(.title3)
            }
            
            // Content
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                
                Text(value)
                    .font(.body)
                    .fontWeight(.medium)
            }
            
            Spacer()
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(title): \(value)")
    }
}

// MARK: - Previews

#Preview("Happy Mood") {
    NavigationStack {
        MoodDetailView(mood: Mood.samples[0])
    }
    .modelContainer(.preview)
}

#Preview("Excited Mood - Not Favorite") {
    NavigationStack {
        MoodDetailView(mood: Mood.samples[1])
    }
    .modelContainer(.preview)
}

#Preview("Dark Mode") {
    NavigationStack {
        MoodDetailView(mood: Mood.samples[0])
    }
    .modelContainer(.preview)
    .preferredColorScheme(.dark)
}

