//
//  AddMoodSheetView.swift
//  MoodBoard
//
//  Created by Prompt-Driven Development on 2025-10-19
//  Feature 04: List CRUD - Sheet for adding/editing moods
//

import SwiftUI
import SwiftData

/// Sheet view for adding or editing a mood
///
/// **Key Concepts:**
/// - **Context-Aware UI**: Same sheet for add and edit (determined by ViewModel state)
/// - **Form Validation**: Submit button disabled until form is valid
/// - **@Observable Integration**: Seamless two-way binding with ViewModel
///
/// **Comparison with other frameworks:**
/// - Android: DialogFragment or BottomSheet
/// - React: Modal component with controlled inputs
/// - Web: Dialog element with form validation
struct AddMoodSheetView: View {
    
    // MARK: - Dependencies
    
    /// ViewModel managing business logic
    /// Injected from parent view
    /// @Bindable enables direct $ syntax for two-way bindings
    @Bindable var viewModel: CRUDViewModel
    
    /// Environment dismiss action
    @Environment(\.dismiss) private var dismiss
    
    // MARK: - Body
    
    var body: some View {
        NavigationStack {
            Form {
                emojiPickerSection
                labelInputSection
            }
            .navigationTitle(viewModel.isEditing ? "Edit Mood" : "Add Mood")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                toolbarContent
            }
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
    }
    
    // MARK: - Sections
    
    /// Emoji picker section
    private var emojiPickerSection: some View {
        Section {
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 60))], spacing: 12) {
                ForEach(viewModel.availableEmojis, id: \.self) { emoji in
                    emojiButton(emoji)
                }
            }
            .padding(.vertical, 8)
        } header: {
            Text("Choose an Emoji")
        }
    }
    
    /// Emoji selection button
    private func emojiButton(_ emoji: String) -> some View {
        Button {
            viewModel.selectEmoji(emoji)
        } label: {
            VStack(spacing: 6) {
                Text(emoji)
                    .font(.system(size: 36))
            }
            .frame(maxWidth: .infinity)
            .frame(height: 60)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(viewModel.selectedEmoji == emoji ? Color.accentColor.opacity(0.2) : Color(.systemGray6))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(viewModel.selectedEmoji == emoji ? Color.accentColor : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Emoji \(emoji)")
        .accessibilityAddTraits(viewModel.selectedEmoji == emoji ? [.isSelected] : [])
    }
    
    /// Label input section
    private var labelInputSection: some View {
        Section {
            TextField("How are you feeling?", text: $viewModel.moodLabel)
                .textInputAutocapitalization(.sentences)
                .accessibilityLabel("Mood label")
        } header: {
            Text("Label")
        } footer: {
            if !viewModel.isFormValid {
                Text("Please enter a label for your mood")
                    .foregroundStyle(.secondary)
            }
        }
    }
    
    /// Toolbar content
    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        // Cancel button
        ToolbarItem(placement: .cancellationAction) {
            Button("Cancel") {
                viewModel.cancelEdit()
                dismiss()
            }
        }
        
        // Submit button (Add or Update)
        ToolbarItem(placement: .confirmationAction) {
            Button(viewModel.submitButtonTitle) {
                if viewModel.isEditing {
                    viewModel.saveEdit()
                } else {
                    viewModel.addMood()
                }
                dismiss()
            }
            .disabled(!viewModel.isFormValid)
            .fontWeight(.semibold)
        }
    }
}

// MARK: - Previews

#Preview("Add Mood") {
    let container = ModelContainer.preview
    let viewModel = CRUDViewModel(modelContext: container.mainContext)
    
    AddMoodSheetView(viewModel: viewModel)
}

#Preview("Edit Mood") {
    let container = ModelContainer.preview
    let viewModel = CRUDViewModel(modelContext: container.mainContext)
    
    // Simulate editing by starting with first sample mood
    let _ = Mood.samples.first.map { viewModel.startEditing($0) }
    
    AddMoodSheetView(viewModel: viewModel)
}

#Preview("Add Mood - Dark Mode") {
    let container = ModelContainer.preview
    let viewModel = CRUDViewModel(modelContext: container.mainContext)
    
    AddMoodSheetView(viewModel: viewModel)
        .preferredColorScheme(.dark)
}

