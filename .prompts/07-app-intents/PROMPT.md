# Prompt Archive — App Intents
Date: 2025-10-23
Feature: 07-app-intents

---

# SwiftUI Feature Prompt: App Intents

You are my SwiftUI development assistant.
Your mission: generate ONLY the feature described below for an iOS 17+ project (Swift 6, SwiftUI), without modifying the rest of the existing code.

## 🧩 CONTEXT

This project illustrates a **Prompt-Driven Development** approach.
Each feature must produce:
- **clear and executable code** (Swift 6, SwiftUI),
- **concise pedagogical documentation**,
- and a **complete prompt archive** for traceability and sharing.

---

## 🎯 OBJECTIVE

Implement **App Intents** to allow users to add moods via **Siri**, **Shortcuts**, and **Spotlight** without opening the app.

**Key Learning:**
- Modern App Intents framework (iOS 16+) vs legacy SiriKit
- Pure Swift API (no .intentdefinition XML files!)
- Background execution with SwiftData
- Type-safe parameters and results

---

## 🧱 FILES TO CREATE OR MODIFY

1. `MoodBoard/Sources/Intents/AddMoodIntent.swift`
   - App Intent definition with parameters
   - SwiftData integration for background persistence
   - Error handling and validation

2. `MoodBoard/Sources/Views/AppIntentsView.swift`
   - Demo view showing how to use App Intents
   - Instructions for testing via Siri/Shortcuts/Spotlight
   - In-app programmatic test interface

3. `Docs/07-AppIntents.md`
   - Comprehensive documentation
   - Comparison with Android App Actions
   - Structured prompts for AI integration
   - Testing and debugging guide

4. Navigation integration:
   - Add `.appIntents` case to `Router.swift`
   - Add destination in `ContentView.swift`
   - Add feature row in `FeaturesListView.swift`

---

## 📜 TECHNICAL SPECIFICATIONS

### AddMoodIntent.swift

**Requirements:**
- Conform to `AppIntent` protocol
- `@Parameter` for title (required) and emoji (optional)
- `@MainActor` async perform() method
- Create separate `ModelContainer` for background execution
- Return `IntentResult & ProvidesDialog` with confirmation message
- Smart emoji selection based on mood keywords
- Custom error handling with `CustomLocalizedStringResourceConvertible`

**App Shortcuts:**
- Define `MoodBoardShortcuts: AppShortcutsProvider`
- Add natural language phrases for Siri discovery
- System image name for Shortcuts app UI

**Pedagogical Comments:**
- Compare with Android App Actions
- Explain background execution context
- Note SwiftData persistence requirements
- Document Siri phrase recognition

### AppIntentsView.swift

**Requirements:**
- Instruction sections for Siri, Shortcuts, Spotlight
- Programmatic test interface with form
- Display recent moods from SwiftData (@Query)
- Link to detailed documentation view
- Dark mode support
- Empty state with ContentUnavailableView

**Components:**
- `InstructionRow`: Reusable instruction display
- `DocumentationDetailView`: In-depth explanation
- `DocumentationSection`: Formatted documentation blocks
- Test form with title/emoji inputs and execution button

### Documentation (07-AppIntents.md)

**Sections:**
1. What Are App Intents?
2. Architecture (Intent + App Shortcuts)
3. Implementation Details (Background execution, SwiftData, Errors)
4. Testing Guide (Siri, Shortcuts, Spotlight, Programmatic)
5. Comparison with Android & Web
6. Structured Prompts for AI Integration
7. Advanced Use Cases (Focus Filters, Disambiguation)
8. Privacy & Permissions
9. Debugging Tips & Performance Best Practices

---

## ✅ ACCEPTANCE CRITERIA

- [x] AddMoodIntent with String title parameter
- [x] Optional emoji parameter with smart defaults
- [x] Mood persistence in SwiftData from Intent
- [x] Result return with confirmation message
- [x] Intent testable via Shortcuts app
- [x] Siri phrase recognition working
- [x] AppIntentsView with testing instructions
- [x] Programmatic test interface
- [x] Recent moods display with @Query
- [x] Documentation on structured prompts and App Intents
- [x] Comparison with Android App Actions
- [x] Appropriate error handling
- [x] Dark mode support verified
- [x] Navigation integration complete
- [x] All code compiles in Xcode

---

## 🎨 CONVENTIONS

- Target: iOS 17+ (App Intents available from iOS 16+)
- Language: Swift 6
- Framework: SwiftUI + App Intents + SwiftData
- No external dependencies
- Code: minimal, readable, commented (in English)
- Documentation: comprehensive (in English)
- **Navigation**: Router-based typed navigation
- **Dark Mode**: ALWAYS support (test with .preferredColorScheme(.dark))
- **SwiftData**: Separate ModelContainer for background execution
- **MVVM**: Separate business logic (though intents are inherently self-contained)
- **Logging**: Use #if DEBUG for print statements
- **Lifecycle**: Use .task for async initialization

---

## 🧭 NAVIGATION INTEGRATION

1. Add `case appIntents` to `Route` enum in `Router.swift`
2. Add destination in `ContentView.destinationView(for:)`:
   ```swift
   case .appIntents:
       AppIntentsView()
   ```
3. Add feature row in `FeaturesListView`:
   ```swift
   Button {
       router.navigate(to: .appIntents)
   } label: {
       FeatureRowView(
           number: "07",
           title: "App Intents",
           description: "Add moods via Siri, Shortcuts & Spotlight",
           icon: "wand.and.stars",
           color: .purple
       )
   }
   ```

---

## 📦 PROMPT ARCHIVING

Archive files created under `.prompts/07-app-intents/`:

### A) `.prompts/07-app-intents/PROMPT.md`
- This complete prompt, reproduced verbatim
- Header with date and feature info

### B) `.prompts/07-app-intents/feature-notes.md`
- Objective summary
- Deliverables list
- Acceptance criteria
- Development notes and learnings

### C) `.prompts/07-app-intents/output/metadata.json`
- Feature metadata (name, date, files, status)
- DO NOT duplicate source files (already in Sources/ and Docs/)

---

## 🧾 EXPECTED OUTPUT

1️⃣ File tree structure of created/modified files
2️⃣ Complete content of each file in code blocks
3️⃣ Demo checklist for testing in Xcode and with Siri
4️⃣ Meta reminder:
   - feature: 07-app-intents
   - date: 2025-10-23

---

## 🚀 TESTING CHECKLIST

After implementation:

1. **Build App**
   - Open project in Xcode
   - Build and run on device (Simulator for basic testing)
   - Verify no compilation errors

2. **Test Shortcuts App**
   - Open Shortcuts app
   - Create new shortcut
   - Search "Add Mood"
   - Configure parameters
   - Run shortcut
   - Verify mood appears in AppIntentsView

3. **Test Siri**
   - Say "Hey Siri, add a happy mood in MoodBoard"
   - Verify Siri recognizes the command
   - Check mood is saved

4. **Test Spotlight**
   - Swipe down on Home Screen
   - Type "Add Mood"
   - Tap action
   - Verify execution

5. **Test Programmatic**
   - Navigate to AppIntentsView
   - Tap "Test Programmatically"
   - Enter title and emoji
   - Execute intent
   - Verify success message

6. **Dark Mode**
   - Enable dark mode in Settings
   - Verify AppIntentsView renders correctly

---

## 🔄 PR WORKFLOW

1. **Create Feature Branch**
   ```bash
   git checkout -b feature/07-app-intents
   ```

2. **Commit Changes**
   ```bash
   git add -A
   git commit -m "feat(app-intents): Add Siri and Shortcuts integration"
   git push origin feature/07-app-intents
   ```

3. **Open Pull Request**
   - Clear description with objectives
   - Testing steps included
   - Screenshots of Shortcuts configuration

4. **Code Review**
   - Use Copilot Reviewer: `@copilot review`
   - Address feedback

5. **Merge to Main**
   - Squash and merge
   - Delete feature branch

---

**Feature:** 07-app-intents  
**Date:** 2025-10-23  
**Status:** ✅ Complete

