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
///
/// **CRUD Operations:**
/// - Create: Add new mood via sheet
/// - Read: Display all moods with @Query
/// - Update: Edit existing mood (tap to edit)
/// - Delete: Swipe to delete or clear all
///
/// **Comparison with other frameworks:**
/// - Android: RecyclerView + ViewModel + Room
/// - React: List components + useState + Context
/// - Vue.js: v-for + reactive refs + Pinia store
struct CRUDListView: View {
    
    // MARK: - Dependencies
    
    /// SwiftData environment context (injected by SwiftUI)
    @Environment(\.modelContext) private var modelContext
    
    /// Query all moods from SwiftData (sorted by timestamp, newest first)
    /// @Query is reactive: UI updates automatically when data changes
    @Query(sort: \Mood.timestamp, order: .reverse)
    private var moods: [Mood]
    
    // MARK: - ViewModel
    
    /// ViewModel managing all CRUD business logic
    /// Initialized lazily in .task to ensure correct ModelContext
    @State private var viewModel: CRUDViewModel?
    
    // MARK: - UI State
    
    /// Controls sheet presentation for add/edit
    @State private var isShowingSheet = false
    
    // MARK: - Body
    
    var body: some View {
        ZStack {
            if moods.isEmpty {
                emptyStateView
            } else {
                moodsList
            }
        }
        .navigationTitle("CRUD Demo")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            toolbarContent
        }
        .sheet(isPresented: $isShowingSheet) {
            // Sheet dismissed: cancel any pending edit
            viewModel?.cancelEdit()
        } content: {
            if let viewModel {
                AddMoodSheetView(viewModel: viewModel)
            }
        }
        .task {
            // Initialize ViewModel with the actual ModelContext from environment
            // This ensures we use the correct persistence context
            if viewModel == nil {
                viewModel = CRUDViewModel(modelContext: modelContext)
            }
        }
    }
    
    // MARK: - Subviews
    
    /// Toolbar buttons
    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        // Add button
        ToolbarItem(placement: .topBarTrailing) {
            Button {
                viewModel?.cancelEdit() // Ensure clean state
                isShowingSheet = true
            } label: {
                Image(systemName: "plus.circle.fill")
            }
            .disabled(viewModel == nil) // Disable until ViewModel is ready
            .accessibilityLabel("Add new mood")
            .accessibilityHint("Opens a sheet to create a new mood entry")
        }
        
        // Clear all button (only when list is not empty)
        if !moods.isEmpty {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    withAnimation {
                        viewModel?.clearAllMoods(moods)
                    }
                } label: {
                    Text("Clear All")
                }
                .disabled(viewModel == nil) // Disable until ViewModel is ready
                .tint(.red)
                .accessibilityLabel("Clear all moods")
                .accessibilityHint("Deletes all mood entries from the list")
            }
        }
    }
    
    /// Empty state when no moods exist
    private var emptyStateView: some View {
        ContentUnavailableView {
            Label("No Moods Yet", systemImage: "face.smiling")
        } description: {
            Text("Tap **+** to add your first mood")
        } actions: {
            Button {
                guard let viewModel else { return }
                viewModel.cancelEdit()
                isShowingSheet = true
            } label: {
                Text("Add Mood")
            }
            .buttonStyle(.borderedProminent)
            .disabled(viewModel == nil)
        }
    }
    
    /// List of moods with swipe actions
    private var moodsList: some View {
        List {
            Section {
                ForEach(moods) { mood in
                    CRUDMoodRowView(mood: mood)
                        .contentShape(Rectangle()) // Make entire row tappable
                        .onTapGesture {
                            // Tap to edit (only if ViewModel is ready)
                            guard let viewModel else { return }
                            viewModel.startEditing(mood)
                            isShowingSheet = true
                        }
                        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                            // Delete action
                            Button(role: .destructive) {
                                withAnimation {
                                    viewModel?.deleteMood(mood)
                                }
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                            .disabled(viewModel == nil)
                        }
                        .swipeActions(edge: .leading, allowsFullSwipe: false) {
                            // Edit action
                            Button {
                                guard let viewModel else { return }
                                viewModel.startEditing(mood)
                                isShowingSheet = true
                            } label: {
                                Label("Edit", systemImage: "pencil")
                            }
                            .tint(.blue)
                            .disabled(viewModel == nil)
                        }
                }
                .onDelete { offsets in
                    withAnimation {
                        viewModel?.deleteMoods(at: offsets, from: moods)
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
                        Text("• **Update**: Tap a mood to edit it")
                        Text("• **Delete**: Swipe left or right")
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

