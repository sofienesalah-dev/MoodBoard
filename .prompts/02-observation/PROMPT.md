# Prompt Archive — Observation

**Date**: 2025-10-19  
**Feature**: 02-observation

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
Introduce modern state management with @Observable and @Bindable for managing a mood store (iOS 17+)

---

# 🧱 FILES TO CREATE OR MODIFY
1) MoodBoard/Sources/Models/MoodStore.swift
2) MoodBoard/Sources/Views/MoodListView.swift
3) Docs/02-Observation.md

---

# 📜 TECHNICAL SPECIFICATIONS

## MoodStore.swift
- Create a `Mood` struct (Identifiable) with:
  - id: UUID
  - emoji: String
  - label: String
  - timestamp: Date
  
- Create a `MoodStore` class with @Observable macro:
  - Property: `moods: [Mood]`
  - Method: `addMood(emoji:label:)`
  - Method: `removeMood(id:)`
  - Method: `clearAll()`
  - Static property: `sample` for previews

## MoodListView.swift
- Main view using @State for store ownership
- Display list of moods with ForEach
- Swipe to delete functionality
- Add mood button in toolbar
- Clear all button (when list not empty)
- Empty state with ContentUnavailableView
- Sheet for adding new mood with:
  - Grid layout for emoji selection (8 predefined moods)
  - TextField for custom label
  - Form validation

## Documentation (02-Observation.md)
- Explain @Observable vs old @ObservableObject system
- Explain @Bindable for two-way binding
- Show migration path from old to new
- Compare with React, Jetpack Compose, Vue.js
- Data flow diagram
- Best practices and anti-patterns
- Performance comparison table

Add **pedagogical comments** in the code explaining conceptual parallels:
- SwiftUI @Observable ↔ React Context API
- SwiftUI @Bindable ↔ React useState with callbacks
- SwiftUI @Observable ↔ Jetpack Compose ViewModel

---

# ✅ ACCEPTANCE CRITERIA
- [x] MoodStore uses @Observable (iOS 17+)
- [x] View uses @State (not @StateObject)
- [x] Add mood with emoji selection works
- [x] Delete mood by swipe works
- [x] Clear all functionality works
- [x] Previews work with sample data
- [x] Documentation explains old vs new system
- [x] Code compiles without errors
- [x] Navigation integrated in FeaturesListView

---

# 🎨 CONVENTIONS
- Target: iOS 17+
- Language: Swift 6
- Framework: SwiftUI
- No external dependencies
- Code: minimal, readable, commented (in English)
- Documentation: concise (1 page max, in English)
- **Navigation**: Add the feature to FeaturesListView

---

# 🧭 NAVIGATION INTEGRATION
**IMPORTANT**: Add the new view to the navigation system:

1. Open `MoodBoard/Sources/Views/FeaturesListView.swift`
2. Add a new `NavigationLink` in the appropriate section
3. Use the `FeatureRowView` component with:
   - number: "02"
   - title: "Observation"
   - description: "Modern state management with @Observable & @Bindable"
   - icon: "brain.head.profile"
   - color: .purple

Example:
```swift
NavigationLink {
    MoodListView()
} label: {
    FeatureRowView(
        number: "02",
        title: "Observation",
        description: "Modern state management with @Observable & @Bindable",
        icon: "brain.head.profile",
        color: .purple
    )
}
```

---

# 📦 AUTOMATIC PROMPT ARCHIVING
Also create the following archive files under `.prompts/02-observation/`:

## A) `.prompts/02-observation/PROMPT.md`
- Contains **this complete prompt**, reproduced *verbatim*.
- Add a header with date, feature, ticket reference

## B) `.prompts/02-observation/feature-notes.md`
- Summarize:
  - **Objective**
  - **Deliverables**
  - **Acceptance Criteria**
  - **PR Checklist**
  - **Development Notes**

## C) `.prompts/02-observation/output/metadata.json`
- Create metadata file with feature info
- **DO NOT** duplicate source files (they are already in Sources/ and Docs/)

---

# 🧾 EXPECTED OUTPUT
Respond with:
1️⃣ A clear summary of created files (tree structure)
2️⃣ Complete content of each file in separate code blocks:
   - Swift files
   - `.md` documentation
   - archives under `.prompts/...`
3️⃣ A mini "demo checklist" to test the feature in Xcode
4️⃣ A meta reminder in comment:
   - `feature: 02-observation`
   - `date: 2025-10-19`

---

# 🚀 FINAL INSTRUCTIONS
Generate the above files, create their archives under `.prompts/02-observation/`,
add navigation integration in FeaturesListView,
and ensure everything compiles and runs without external dependencies.

---

# 🔄 PR WORKFLOW
After code generation:

1. **Create Feature Branch**
   ```bash
   git checkout -b feature/02-observation
   ```

2. **Commit Changes**
   ```bash
   git add -A
   git commit -m "feat(02-observation): Observation with @Observable & @Bindable"
   git push origin feature/02-observation
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

