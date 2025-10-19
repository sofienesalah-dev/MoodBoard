# Prompt Archive — List CRUD

**Date:** 2025-10-19  
**Feature:** 04-list-crud  
**JIRA:** MOOD-4

---

# 🧩 CONTEXT

This project illustrates a **Prompt-Driven Development** approach.
Each feature must produce:
- **clear and executable code** (Swift 6, SwiftUI),
- **concise pedagogical documentation**,
- and a **complete prompt archive** for traceability and sharing.

---

# 🎯 OBJECTIVE

Implement the complete CRUD list of moods with SwiftData persistence using MVVM pattern.

Demonstrate:
- Full CRUD operations (Create, Read, Update, Delete)
- SwiftData with @Query for reactive data
- MVVM architecture with clear separation of concerns
- Form validation and error handling
- Sheet presentation for add/edit operations
- Swipe actions and tap gestures

---

# 🧱 FILES TO CREATE OR MODIFY

1. **MoodBoard/Sources/ViewModels/CRUDViewModel.swift** - Business logic for CRUD operations
2. **MoodBoard/Sources/Views/CRUDListView.swift** - Main list view with @Query
3. **MoodBoard/Sources/Views/AddMoodSheetView.swift** - Sheet for adding/editing moods
4. **MoodBoard/Sources/Views/CRUDMoodRowView.swift** - Reusable row component
5. **Docs/04-ListCRUD.md** - CRUD patterns documentation
6. **MoodBoard/Sources/Views/FeaturesListView.swift** - Add Feature 04 navigation

---

# 📜 TECHNICAL SPECIFICATIONS

## CRUDViewModel.swift

**Purpose:** Centralize all business logic for CRUD operations

**Requirements:**
- Use `@Observable` for modern state management
- Inject `ModelContext` for SwiftData operations
- Implement all CRUD methods:
  - `addMood()` - Create new mood with validation
  - `startEditing()` / `saveEdit()` - Update existing mood
  - `deleteMood()` - Delete single mood
  - `deleteMoods(at:from:)` - Batch delete with IndexSet
  - `clearAllMoods()` - Delete all moods
- Form state management: `selectedEmoji`, `moodLabel`, `editingMood`
- Computed properties: `isFormValid`, `isEditing`, `submitButtonTitle`
- Error handling with try-catch and conditional compilation

**Pedagogical comments:**
- Explain MVVM separation of concerns
- Compare with Android ViewModel + Repository
- Compare with React custom hooks
- Explain why business logic should NOT be in Views

## CRUDListView.swift

**Purpose:** Main view displaying list of moods with @Query

**Requirements:**
- Use `@Query(sort: \Mood.timestamp, order: .reverse)` for reactive data
- Initialize ViewModel in `.task` lifecycle with ModelContext
- Display empty state with `ContentUnavailableView`
- List with sections, header, and instructional footer
- Toolbar with Add (+) and Clear All buttons
- Sheet presentation for add/edit
- Swipe actions:
  - Swipe right: Edit (blue)
  - Swipe left: Delete (red)
- Tap gesture on row to open edit sheet

**Pedagogical comments:**
- Explain @Query reactivity
- Compare with Room's @Query in Android
- Explain MVVM in practice (View delegates to ViewModel)
- Explain sheet presentation and dismissal

## AddMoodSheetView.swift

**Purpose:** Modal form for adding or editing moods

**Requirements:**
- Context-aware: Same sheet for add and edit (determined by ViewModel)
- Emoji picker in LazyVGrid with visual selection state
- Text field for mood label
- Form validation: Disable submit button until valid
- Toolbar with Cancel and Submit buttons
- Adaptive title: "Add Mood" vs "Edit Mood"
- Presentation detents: `.medium` and `.large`
- On dismiss: cancel pending edit

**Pedagogical comments:**
- Explain modal presentations
- Explain context-aware UI
- Compare with Android DialogFragment
- Explain form validation patterns

## CRUDMoodRowView.swift

**Purpose:** Reusable component for displaying a mood row

**Requirements:**
- Display emoji in circular background
- Show mood label (headline) and timestamp (relative)
- Chevron indicator for edit affordance
- Full accessibility support (labels, hints, values)
- Support light and dark mode

**Pedagogical comments:**
- Explain component reusability
- Compare with Android ViewHolder
- Compare with React functional components
- Explain accessibility best practices

---

# ✅ ACCEPTANCE CRITERIA

- [x] All CRUD operations functional (Create, Read, Update, Delete)
- [x] SwiftData persistence tested (data survives app restart)
- [x] Swipe actions work (edit right, delete left)
- [x] Tap row opens edit sheet with pre-filled data
- [x] Form validation prevents empty submissions
- [x] Empty state displays ContentUnavailableView
- [x] Clear All button removes all moods
- [x] Dark mode support verified
- [x] Previews work for all components
- [x] Accessibility labels for all interactive elements
- [x] Documentation is clear and comprehensive

---

# 🎨 CONVENTIONS

- Target: iOS 17+
- Language: Swift 6
- Framework: SwiftUI
- No external dependencies
- Code: minimal, readable, commented (in English)
- Documentation: concise (in English)
- **Navigation**: Add Feature 04 to FeaturesListView
- **⚠️ IMPORTANT**: NO Jira links or private URLs (public repository)
- **🎨 Dark Mode**: ALWAYS support dark mode
- **🗄️ SwiftData**: Use @Query for reactive queries
- **⚠️ Naming**: Unique component names (CRUD prefix to avoid conflicts)
- **🧠 MVVM**: Separate business logic into ViewModels (NO logic in Views!)
- **💉 DI**: Inject dependencies (ModelContext) into ViewModels
- **📋 Logging**: Use conditional compilation (#if DEBUG) for print statements
- **⏱️ Lifecycle**: Use .task instead of .onAppear for async initialization

---

# 🧭 NAVIGATION INTEGRATION

Added to `FeaturesListView.swift`:

```swift
// Feature 04: List CRUD
Section {
    NavigationLink {
        CRUDListView()
    } label: {
        FeatureRowView(
            number: "04",
            title: "List CRUD",
            description: "Complete CRUD operations with SwiftData & MVVM",
            icon: "list.bullet.clipboard",
            color: .green
        )
    }
} header: {
    Text("Data Operations")
}
```

---

# 🧾 EXPECTED OUTPUT

1️⃣ **File Structure:**
```
MoodBoard/Sources/
├── ViewModels/
│   └── CRUDViewModel.swift
└── Views/
    ├── CRUDListView.swift
    ├── AddMoodSheetView.swift
    └── CRUDMoodRowView.swift

Docs/
└── 04-ListCRUD.md

.prompts/04-list-crud/
├── PROMPT.md
├── feature-notes.md
└── output/
    └── metadata.json
```

2️⃣ **All files created with:**
- Complete implementation
- Pedagogical comments
- Accessibility support
- Preview providers
- Dark mode support

3️⃣ **Demo Checklist:**
- [ ] Build succeeds without errors
- [ ] All previews render correctly
- [ ] Create new mood works
- [ ] Edit mood works
- [ ] Delete mood works
- [ ] Clear all works
- [ ] Data persists after app restart
- [ ] Dark mode looks good

---

# 🚀 FINAL INSTRUCTIONS

Generate the above files, create their archives under `.prompts/04-list-crud/`, add navigation integration in FeaturesListView, and ensure everything compiles and runs without external dependencies.

**Feature:** `04-list-crud`  
**Date:** 2025-10-19

