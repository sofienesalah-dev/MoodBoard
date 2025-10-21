//
//  CRUDListView.swift
//  MoodBoard
//
//  Created by Prompt-Driven Development on 2025-10-19
//  Feature 04: List CRUD - Complete CRUD operations with SwiftData
//

import SwiftUI
import SwiftData

/// Main view demonstrating complete CRUD operations with SwiftData
///
/// **Key Concepts:**
/// - **@Query**: Reactive queries from SwiftData (auto-updates UI)
/// - **MVVM Pattern**: All business logic in CRUDViewModel
/// - **SwiftData Persistence**: Data survives app restarts
/// - **Sheet Presentation**: Modal form for adding/editing
/// - **Centralized Navigation**: Uses Router for navigation to detail
///
/// **CRUD Operations:**
/// - Create: Add new mood via sheet
/// - Read: Display all moods with @Query
/// - Update: Edit existing mood (swipe right)
/// - Delete: Swipe to delete or clear all
/// - Detail: Tap to view details & toggle favorite
///
/// **Comparison with other frameworks:**
/// - Android: RecyclerView + ViewModel + Room
/// - React: List components + useState + Context
/// - Vue.js: v-for + reactive refs + Pinia store
struct CRUDListView: View {
    
    // MARK: - Dependencies
    
    /// SwiftData environment context (injected by SwiftUI)
    @Environment(\.modelContext) private var modelContext
    
    /// Centralized router for navigation
    @Environment(Router.self) private var router
    
    /// Query all moods from SwiftData (sorted by timestamp, newest first)
    /// @Query is reactive: UI updates automatically when data changes
    @Query(sort: \Mood.timestamp, order: .reverse)
    private var moods: [Mood]
    
    // MARK: - ViewModel
    
    /// ViewModel managing all CRUD business logic
    /// Initialized in onAppear to use the correct environment context
    @State private var viewModel: CRUDViewModel?
    
    // MARK: - UI State
    
    /// Controls sheet presentation for add/edit
    @State private var isShowingSheet = false
    
    /// Controls confirmation dialog for clear all
    @State private var isShowingClearConfirmation = false
    
    // MARK: - Body
    
    var body: some View {
        Group {
            if let viewModel {
                contentView(viewModel: viewModel)
            } else {
                ProgressView()
            }
        }
        .onAppear {
            // Initialize with actual environment context (only once)
            if viewModel == nil {
                viewModel = CRUDViewModel(modelContext: modelContext)
            }
        }
    }
    
    // MARK: - Content View
    
    @ViewBuilder
    private func contentView(viewModel: CRUDViewModel) -> some View {
        ZStack {
            if moods.isEmpty {
                emptyStateView(viewModel: viewModel)
            } else {
                moodsList(viewModel: viewModel)
            }
        }
        .navigationTitle("CRUD Demo")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            toolbarContent(viewModel: viewModel)
        }
        .sheet(isPresented: $isShowingSheet) {
            // Sheet dismissed: cancel any pending edit
            viewModel.cancelEdit()
        } content: {
            AddMoodSheetView(viewModel: viewModel)
        }
        .confirmationDialog(
            "Are you sure you want to delete all moods?",
            isPresented: $isShowingClearConfirmation,
            titleVisibility: .visible
        ) {
            Button("Delete All", role: .destructive) {
                withAnimation {
                    viewModel.clearAllMoods(moods)
                }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This action cannot be undone.")
        }
    }
    
    // MARK: - Subviews
    
    /// Toolbar buttons
    @ToolbarContentBuilder
    private func toolbarContent(viewModel: CRUDViewModel) -> some ToolbarContent {
        // Add button
        ToolbarItem(placement: .topBarTrailing) {
            Button {
                viewModel.cancelEdit() // Ensure clean state
                isShowingSheet = true
            } label: {
                Image(systemName: "plus.circle.fill")
            }
            .accessibilityLabel("Add new mood")
            .accessibilityHint("Opens a sheet to create a new mood entry")
        }
        
        // Clear all button (only when list is not empty)
        if !moods.isEmpty {
            ToolbarItem(placement: .topBarLeading) {
                Button(role: .destructive) {
                    isShowingClearConfirmation = true
                } label: {
                    Text("Clear All")
                }
                .accessibilityLabel("Clear all moods")
                .accessibilityHint("Deletes all mood entries from the list")
            }
        }
    }
    
    /// Empty state when no moods exist
    private func emptyStateView(viewModel: CRUDViewModel) -> some View {
        ContentUnavailableView {
            Label("No Moods Yet", systemImage: "face.smiling")
        } description: {
            Text("Tap **+** to add your first mood")
        } actions: {
            Button {
                viewModel.cancelEdit()
                isShowingSheet = true
            } label: {
                Text("Add Mood")
            }
            .buttonStyle(.borderedProminent)
        }
    }
    
    /// List of moods with swipe actions
    private func moodsList(viewModel: CRUDViewModel) -> some View {
        List {
            Section {
                ForEach(moods) { mood in
                    Button {
                        // Navigate to detail via Router (by PersistentIdentifier)
                        router.navigate(to: .moodDetail(id: mood.persistentModelID))
                    } label: {
                        CRUDMoodRowView(mood: mood)
                    }
                    .accessibilityLabel("View details for \(mood.label)")
                    .accessibilityHint("Double tap to view full mood details")
                    .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                        // Delete action (consolidated - single deletion path)
                        Button(role: .destructive) {
                            withAnimation {
                                viewModel.deleteMood(mood)
                            }
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
                    .swipeActions(edge: .leading, allowsFullSwipe: false) {
                        // Edit action
                        Button {
                            viewModel.startEditing(mood)
                            isShowingSheet = true
                        } label: {
                            Label("Edit", systemImage: "pencil")
                        }
                        .tint(.blue)
                    }
                }
            } header: {
                Text("My Moods (\(moods.count))")
            } footer: {
                VStack(alignment: .leading, spacing: 6) {
                    Text("💡 **CRUD Operations:**")
                        .font(.caption)
                        .fontWeight(.semibold)
                    
                    Group {
                        Text("• **Create**: Tap + to add new mood")
                        Text("• **Read**: All moods from SwiftData")
                        Text("• **Update**: Swipe right for quick edit")
                        Text("• **Delete**: Swipe left to delete")
                        Text("• **Detail**: Tap a mood to view details & toggle favorite ❤️")
                    }
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                }
                .padding(.top, 8)
            }
        }
        .listStyle(.insetGrouped)
    }
}

// MARK: - Previews

#Preview("Empty State") {
    NavigationStack {
        CRUDListView()
    }
    .modelContainer(.preview)
}

#Preview("With Moods") {
    NavigationStack {
        CRUDListView()
    }
    .modelContainer(.preview)
}

#Preview("With Moods - Dark Mode") {
    NavigationStack {
        CRUDListView()
    }
    .modelContainer(.preview)
    .preferredColorScheme(.dark)
}

