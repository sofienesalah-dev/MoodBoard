# Prompt Archive — Architecture (MVVM + SwiftData + Typed Navigation)

Date: 2025-10-19  
Feature: 03-arch-swiftdata-navstack  
Jira Ticket: MOOD-3

---

## Original Prompt

You are my SwiftUI development assistant.
Your mission: generate ONLY the feature described below for an iOS 17+ project (Swift 6, SwiftUI), without modifying the rest of the existing code.

# 🧩 CONTEXT

This project illustrates a **Prompt-Driven Development** approach.
Each feature must produce:
- **clear and executable code** (Swift 6, SwiftUI),
- **concise pedagogical documentation**,
- and a **complete prompt archive** for traceability and sharing.

---

# 🎯 OBJECTIVE

Set up lightweight MVVM architecture with SwiftData for persistence and typed navigation using NavigationStack.

---

# 🧱 FILES TO CREATE OR MODIFY

1) `MoodBoard/Sources/Models/Mood.swift` — SwiftData model with @Model
2) `MoodBoard/Sources/Navigation/Router.swift` — Typed navigation routes
3) `MoodBoard/MoodBoardApp.swift` — SwiftData ModelContainer configuration
4) `MoodBoard/Sources/Views/ArchitectureView.swift` — Demo view showcasing architecture
5) `MoodBoard/Sources/Views/FeaturesListView.swift` — Add navigation to Feature 03
6) `Docs/03-Architecture.md` — MVVM + SwiftData architecture documentation

---

# 📜 TECHNICAL SPECIFICATIONS

## 1. Mood.swift — SwiftData Model

**⚠️ IMPORTANT**: First, rename the existing `Mood` struct in `MoodStore.swift` to `MoodEntry` to avoid naming conflicts:
- Feature 02 uses in-memory `struct MoodEntry` (with @Observable)
- Feature 03 uses persistent `@Model class Mood` (with SwiftData)

Create a SwiftData model with:
- `@Model` macro for automatic persistence
- Properties: `emoji: String`, `label: String`, `timestamp: Date`
- Initializer with default timestamp
- Sample data for previews:
  - `static var samples: [Mood]` — Returns array of sample moods
  - `static func insertSamples(into context: ModelContext)` — Helper to insert samples into context

**Important**: For SwiftData @Model classes, create a dedicated helper function to insert samples:
```swift
static func insertSamples(into context: ModelContext) {
    let sampleMoods = [
        Mood(emoji: "😊", label: "Happy", timestamp: Date().addingTimeInterval(-3600)),
        // ... more samples
    ]
    for mood in sampleMoods {
        context.insert(mood)
    }
}
```

**Pedagogical comments** explaining:
- What is @Model and how it compares to @Observable
- Comparison with Room (Android), Core Data, Realm
- When to use @Model vs @Observable

## 2. Router.swift — Typed Navigation

**⚠️ IMPORTANT**: Add `import SwiftData` for PersistentIdentifier type.

Create a typed navigation router with:
- `Route` enum with cases: `.introState`, `.observation`, `.architecture`, `.moodDetail(idString:)`
  - Use `String` for mood ID (URIRepresentation) instead of `PersistentIdentifier` for Hashable conformance
- `Router` class with `@Observable` and navigation methods:
  - `navigate(to:)` — push route to stack
  - `goBack()` — pop from stack
  - `goBackToRoot()` — clear stack
  - `replace(with:)` — replace current route

**Pedagogical comments** explaining:
- Type-safe navigation vs string-based
- Comparison with React Router, Jetpack Compose Navigation
- Benefits: compile-time safety, refactoring support, deep linking

## 3. MoodBoardApp.swift — ModelContainer Configuration

Update `MoodBoardApp` to:
- Add `Mood.self` to the Schema
- Configure `ModelContainer` with persistent storage
- Add preview helper: `ModelContainer.preview` (in-memory, with sample data)

**Important**: Use the helper function to insert sample data:
```swift
// ✅ Correct - Use dedicated helper
Mood.insertSamples(into: container.mainContext)

// ❌ Avoid - Type inference issues with @Model classes
for mood in Mood.samples {
    context.insert(mood)
}
```

This approach avoids Swift compiler type inference issues when working with SwiftData @Model classes.

**Pedagogical comments** explaining:
- What is ModelContainer
- Persistent vs in-memory storage
- Comparison with Room, Core Data, Realm

## 4. ArchitectureView.swift — Demo View

**⚠️ IMPORTANT**: 
- Use `ArchitectureMoodRow` for the row component (not `MoodRowView` to avoid conflict with Feature 02)
- **DO NOT** use `@Environment(Router.self)` in this view - Router is not yet injected in app environment (will cause crash)

Create a comprehensive demo view with:
- Header explaining MVVM architecture layers
- Form to add new moods (emoji picker + text field)
- List of persisted moods from SwiftData
- Empty state when no moods exist
- Delete and clear all actions

**Key SwiftUI features:**
- `@Environment(\.modelContext)` for SwiftData context
- `@Query(sort: \Mood.timestamp, order: .reverse)` for reactive querying
- `@State` for local form state
- Custom `ArchitectureMoodRow` component (to avoid name conflict)

**Pedagogical comments** explaining:
- MVVM layers: Model (@Model), View (SwiftUI), ViewModel (context)
- @Query for reactive data fetching
- Comparison with Room + ViewModel + NavHost (Android)

## 5. FeaturesListView.swift — Navigation Integration

Add new section "Architecture & Navigation" with:
- NavigationLink to `ArchitectureView()`
- FeatureRowView with:
  - number: "03"
  - title: "Architecture"
  - description: "MVVM + SwiftData persistence + Typed navigation"
  - icon: "building.columns"
  - color: .orange

## 6. Docs/03-Architecture.md — Documentation

Create comprehensive documentation with:
- Overview of architecture components
- SwiftData concepts (@Model, @Query, ModelContainer)
- Typed navigation concepts (Route enum, Router class)
- MVVM pattern explanation
- Code examples for CRUD operations
- Comparison tables with other frameworks (Room, Core Data, React Router)
- Summary and next steps

---

# ✅ ACCEPTANCE CRITERIA

- [x] View compiles and runs in Xcode (iOS 17+)
- [x] SwiftData ModelContainer configured with Mood model
- [x] Typed navigation with routes enum implemented
- [x] Previews work with in-memory storage (isStoredInMemoryOnly: true)
- [x] Previews tested in both light and dark mode
- [x] CRUD operations work (Create, Read, Delete moods)
- [x] Data persists between app restarts
- [x] Lightweight MVVM architecture documented
- [x] Clear View / ViewModel / Model separation
- [x] Pedagogical comments explain concepts
- [x] Dark mode support verified
- [x] Documentation is clear and readable

---

# 🎨 CONVENTIONS

- Target: iOS 17+
- Language: Swift 6
- Framework: SwiftUI
- Persistence: SwiftData
- No external dependencies
- Code: minimal, readable, commented (in English)
- Documentation: concise (1 page max, in English)
- **Navigation**: Add the feature to FeaturesListView
- **Dark Mode**: ALWAYS support dark mode (test with .preferredColorScheme(.dark))

---

# 🧭 NAVIGATION INTEGRATION

**IMPORTANT**: Add the new view to the navigation system:

1. Open `MoodBoard/Sources/Views/FeaturesListView.swift`
2. Add a new section "Architecture & Navigation"
3. Add a new `NavigationLink` with `FeatureRowView`:
   - number: "03"
   - title: "Architecture"
   - description: "MVVM + SwiftData persistence + Typed navigation"
   - icon: "building.columns"
   - color: .orange

---

# 📦 AUTOMATIC PROMPT ARCHIVING

Archive files created under `.prompts/03-arch-swiftdata-navstack/`:

## A) `.prompts/03-arch-swiftdata-navstack/PROMPT.md`
- Contains **this complete prompt**, reproduced *verbatim*.
- Header with feature info

## B) `.prompts/03-arch-swiftdata-navstack/feature-notes.md`
- Summarize:
  - **Objective**
  - **Deliverables**
  - **Acceptance Criteria**
  - **PR Checklist**
  - **Development Notes**

## C) `.prompts/03-arch-swiftdata-navstack/output/metadata.json`
- Create metadata file with feature info
- **DO NOT** duplicate source files (they are already in Sources/ and Docs/)

---

# 🧾 EXPECTED OUTPUT

1️⃣ A clear summary of created files (tree structure)
2️⃣ Complete content of each file in separate code blocks:
   - Swift files
   - `.md` documentation
   - archives under `.prompts/...`
3️⃣ A mini "demo checklist" to test the feature in Xcode
4️⃣ A meta reminder in comment:
   - `feature: 03-arch-swiftdata-navstack`
   - `date: 2025-10-19`

---

# 🚀 FINAL INSTRUCTIONS

Generate the above files, create their archives under `.prompts/03-arch-swiftdata-navstack/`,
add navigation integration in FeaturesListView,
and ensure everything compiles and runs without external dependencies.

---

# 🔄 PR WORKFLOW

After code generation:

1. **Create Feature Branch**
   ```bash
   git checkout -b feature/03-arch-swiftdata-navstack
   ```

2. **Commit Changes**
   ```bash
   git add -A
   git commit -m "feat(03-arch): MVVM + SwiftData + Typed Navigation"
   git push origin feature/03-arch-swiftdata-navstack
   ```

3. **Open Pull Request**
   - Go to GitHub repository
   - Click "New Pull Request"
   - Add clear description with:
     * Feature objective
     * Changes made
     * Testing steps

4. **Use Copilot Reviewer**
   - Comment on PR: `@copilot review`
   - Wait for automated review
   - Address feedback if any

5. **Merge to Main**
   - After approval and CI passes
   - Squash and merge
   - Delete feature branch

---

**Meta Information**
- feature: 03-arch-swiftdata-navstack
- date: 2025-10-19
- jira: MOOD-3

