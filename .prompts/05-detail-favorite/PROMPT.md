# Prompt Archive — Detail + Favorite

**Date:** 2025-10-20  
**Feature:** 05-detail-favorite  
**JIRA:** MOOD-5

---

# 🧩 CONTEXT

This project illustrates a **Prompt-Driven Development** approach.
Each feature must produce:
- **clear and executable code** (Swift 6, SwiftUI),
- **concise pedagogical documentation**,
- and a **complete prompt archive** for traceability and sharing.

---

# 🎯 OBJECTIVE

Implement a detail view for moods with favorite toggle functionality, demonstrating type-safe navigation, reusable components, and persistent state management.

Demonstrate:
- Type-safe navigation with NavigationStack
- @Bindable for two-way binding to @Model objects
- Reusable UI components (FavoriteButton)
- Persistent favorite state with SwiftData
- Rich detail view with metadata and actions
- iOS native share functionality

---

# 🧱 FILES TO CREATE OR MODIFY

1. **MoodBoard/Sources/Models/Mood.swift** - Add isFavorite property
2. **MoodBoard/Sources/Views/FavoriteButton.swift** - Reusable favorite toggle component
3. **MoodBoard/Sources/Views/MoodDetailView.swift** - Complete detail view
4. **MoodBoard/Sources/Views/CRUDListView.swift** - Add navigation to detail
5. **MoodBoard/MoodBoardApp.swift** - Handle schema migration
6. **Docs/05-DetailFavorite.md** - Detail view patterns documentation
7. **MoodBoard/Sources/Views/FeaturesListView.swift** - Add Feature 05 navigation

---

# 📜 TECHNICAL SPECIFICATIONS

## Mood.swift (Update)

**Purpose:** Add favorite functionality to data model

**Requirements:**
- Add `var isFavorite: Bool` property to `@Model`
- Update initializer with `isFavorite: Bool = false` default
- Update `Mood.samples` with some favorite states:
  ```swift
  Mood(emoji: "😊", label: "Happy", timestamp: Date().addingTimeInterval(-3600), isFavorite: true),
  Mood(emoji: "🎉", label: "Excited", timestamp: Date().addingTimeInterval(-7200), isFavorite: false),
  // etc.
  ```
- Document schema evolution and migration strategy

**Pedagogical comments:**
- Explain SwiftData schema evolution
- Document migration strategy for production vs development
- Compare with Core Data migration plans

## MoodBoardApp.swift (Update)

**Purpose:** Handle schema migration gracefully

**Requirements:**
- Add error handling in `sharedModelContainer` initialization
- On migration failure:
  - Delete old persistent store file
  - Create fresh container
  - Log warning message
- Document this is development strategy (production would preserve data)

**Code pattern:**
```swift
do {
    return try ModelContainer(for: schema, configurations: [modelConfiguration])
} catch {
    print("⚠️ ModelContainer creation failed, attempting to reset data: \(error)")
    let url = modelConfiguration.url
    try? FileManager.default.removeItem(at: url)
    // Try again with fresh data
}
```

## FavoriteButton.swift

**Purpose:** Reusable, animated favorite toggle component

**Requirements:**
- Use `@Binding var isFavorite: Bool` for two-way data flow
- Optional callback: `var onToggle: (() -> Void)? = nil`
- Button with animated heart icon:
  - Filled red heart when favorite
  - Outline gray heart when not favorite
- Animations:
  - Spring animation on toggle
  - Scale effect: `1.0` → `1.1` when favorite
  - Rotation: `0°` → `360°` on transition
  - Use `.animation(.spring(response: 0.3, dampingFraction: 0.6), value: isFavorite)`
- Haptic feedback on iOS: `UIImpactFeedbackGenerator(style: .light)`
- Accessibility:
  - Dynamic label: "Add to favorites" / "Remove from favorites"
  - Hint: "Double tap to toggle favorite status"
  - Add `.isSelected` trait when favorite

**Pedagogical comments:**
- Explain @Binding for component reusability
- Compare with React controlled components
- Compare with Android Compose state hoisting
- Document animation parameters and their effects
- Explain haptic feedback best practices

**Preview requirements:**
- Preview "Not Favorite" state
- Preview "Favorite" state
- Preview "Interactive" with @Previewable @State

## MoodDetailView.swift

**Purpose:** Rich detail view for a single mood with favorite toggle

**Requirements:**
- Use `@Bindable var mood: Mood` to enable mutations
- Import SwiftData (needed for @Bindable with @Model)
- `@Environment(\.dismiss)` for navigation

**UI Structure:**
```
ScrollView
├─ Hero Emoji Section
│  └─ Large emoji (100pt) in gradient circle
├─ Mood Info Section
│  ├─ Label (largeTitle, bold)
│  └─ Relative timestamp (e.g., "2 hours ago")
├─ Metadata Section
│  ├─ InfoCard: Recorded timestamp (absolute)
│  └─ InfoCard: Favorite status (Yes/No)
└─ Actions Section
   ├─ Share button
   └─ Instructional hint
```

**Toolbar:**
- Place `FavoriteButton(isFavorite: $mood.isFavorite)` in `.topBarTrailing`
- Optional callback to log toggle events

**InfoCard Component:**
- Private reusable component in same file
- Parameters: `icon`, `title`, `value`, `color`
- Design:
  - HStack layout
  - Colored icon in circle (44x44)
  - VStack with title (caption, secondary) and value (body, medium weight)
  - Rounded rectangle background with shadow
  - Combined accessibility element

**Share Functionality:**
```swift
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
```

**Pedagogical comments:**
- Explain @Bindable vs @Binding differences
- Document why SwiftData auto-persists changes
- Explain iOS share sheet best practices
- Compare with Android Intent.ACTION_SEND
- Document ScrollView best practices for detail views

**Preview requirements:**
- Preview "Happy Mood" (favorite)
- Preview "Excited Mood - Not Favorite"
- Preview "Dark Mode" with `.preferredColorScheme(.dark)`

## CRUDListView.swift (Update)

**Purpose:** Add type-safe navigation to detail view

**Requirements:**
1. Replace `onTapGesture` with `NavigationLink(value:)`:
   ```swift
   // Before
   CRUDMoodRowView(mood: mood)
       .onTapGesture {
           viewModel.startEditing(mood)
           isShowingSheet = true
       }
   
   // After
   NavigationLink(value: mood) {
       CRUDMoodRowView(mood: mood)
   }
   ```

2. Keep swipe actions for edit/delete:
   - Swipe left: Delete (red, destructive)
   - Swipe right: Edit (blue) - opens sheet

3. Add navigation destination:
   ```swift
   .navigationDestination(for: Mood.self) { mood in
       MoodDetailView(mood: mood)
   }
   ```

4. Update footer instructions to mention detail navigation:
   ```swift
   Text("• **Detail**: Tap a mood to view details & toggle favorite ❤️")
   ```

**Pedagogical comments:**
- Explain type-safe navigation benefits
- Compare with string-based navigation
- Document why Mood must be Hashable (automatic with @Model)
- Explain separation of concerns: tap for detail, swipe for quick actions

## FeaturesListView.swift (Update)

**Purpose:** Add Feature 05 to main menu

**Requirements:**
- Add new NavigationLink in "Data Operations & Navigation" section:
  ```swift
  NavigationLink {
      CRUDListView()  // Same view, feature 05 adds detail navigation
  } label: {
      FeatureRowView(
          number: "05",
          title: "Detail + Favorite",
          description: "Navigation to detail view with favorite toggle & reusable components",
          icon: "heart.circle.fill",
          color: .red
      )
  }
  ```
- Update section header to: "Data Operations & Navigation"
- Add footer hint: "💡 Tap on a mood in the list to see its details and toggle favorite status"

---

# 📋 DOCUMENTATION REQUIREMENTS

## Docs/05-DetailFavorite.md

**Structure:**
```markdown
# Feature 05: Detail + Favorite

**Date:** 2025-10-20
**Status:** ✅ Completed

## 🎯 Objective
[What this feature demonstrates]

## 📚 What You'll Learn
[Key concepts: type-safe navigation, @Bindable, reusable components, persistence]

## 🏗️ Architecture
[Navigation flow diagram]
[Data flow diagram]

## 🧱 Components
[Detailed breakdown of each file]

### 1. Mood.swift (Updated)
- Schema evolution
- Migration strategy

### 2. FavoriteButton.swift
- @Binding pattern
- Animations
- Haptic feedback
- Accessibility

### 3. MoodDetailView.swift
- @Bindable usage
- UI sections
- Share functionality
- InfoCard component

### 4. CRUDListView.swift (Updated)
- NavigationLink
- Navigation destination
- Type-safe navigation

## 🔄 Key Concepts
- Type-Safe Navigation
- @Bindable vs @Binding comparison table
- Reusable Components principles

## 📊 Data Persistence
[How favorites persist through SwiftData]

## 🎨 UI/UX Enhancements
- Animations
- Haptic feedback
- Info cards design

## 🧪 Testing
- Preview strategies
- Different states
- Dark mode

## 📱 User Flow
[Step-by-step user journey]

## 🔍 Common Patterns
[Reusable code patterns with examples]

## 💡 Best Practices
[Do's and Don'ts]

## 🐛 Common Issues
[Troubleshooting guide]

## 📚 Further Reading
[Links to official documentation]

## ✅ Checklist
[Complete implementation checklist]
```

---

# 🎨 STYLE GUIDE

## Code Style
- Use Swift 6 syntax
- Prefer `@Observable` over ObservableObject
- Use `@Bindable` for mutable @Model objects
- Clear MARK comments for organization
- Comprehensive documentation comments
- Accessibility support on all interactive elements

## Comments Style
```swift
/// Brief description
///
/// **Key Concept:** Main idea explained
///
/// **Comparison with other frameworks:**
/// - React: [equivalent concept]
/// - Android: [equivalent concept]
///
/// **Example:**
/// ```swift
/// // Usage example
/// ```
```

## Naming Conventions
- ViewModels: `<Feature>ViewModel`
- Views: `<Feature>View` or `<Component>View`
- Reusable components: Descriptive names (e.g., `FavoriteButton`, `InfoCard`)
- Private helpers: Clear, action-oriented names

## Architecture Principles
- Single Responsibility: Each component has one clear purpose
- Composition over Inheritance: Build complex UIs from simple components
- Dependency Injection: Pass dependencies explicitly
- Separation of Concerns: Views present, ViewModels contain logic

---

# ✅ ACCEPTANCE CRITERIA

## Functional Requirements
- [ ] Mood model includes isFavorite property with default value
- [ ] FavoriteButton is reusable and works with any @Binding
- [ ] Tapping heart animates smoothly with haptic feedback
- [ ] Detail view shows all mood information
- [ ] Favorite status persists across app restarts
- [ ] Navigation from list to detail works correctly
- [ ] Share functionality opens iOS share sheet
- [ ] Swipe actions still work for quick edit/delete

## Code Quality
- [ ] All files compile without warnings
- [ ] Comprehensive documentation comments
- [ ] Pedagogical comparisons with other frameworks
- [ ] Multiple previews for different states
- [ ] Accessibility labels and hints
- [ ] Error handling for schema migration

## Documentation
- [ ] Docs/05-DetailFavorite.md is complete and accurate
- [ ] All code patterns are explained
- [ ] Architecture diagrams are clear
- [ ] Common issues section helps troubleshooting
- [ ] Checklist reflects all implemented features

## Archive
- [ ] PROMPT.md in .prompts/05-detail-favorite/
- [ ] feature-notes.md with development notes
- [ ] output/metadata.json with feature info

---

# 📊 SUCCESS METRICS

**User can:**
1. Tap any mood in the list to see its details
2. Toggle favorite status with animated heart button
3. See favorite status persist after app restart
4. Share mood information via iOS share sheet
5. Navigate back to list and see updated favorite status
6. Still use swipe actions for quick edit/delete

**Developer can:**
1. Understand type-safe navigation pattern
2. Reuse FavoriteButton in other contexts
3. Understand @Bindable vs @Binding differences
4. Implement similar detail views for other models
5. Handle schema migrations in SwiftData

**Code demonstrates:**
1. Clean separation between reusable and specific components
2. Proper use of SwiftData persistence
3. Modern SwiftUI navigation patterns
4. Accessibility best practices
5. Rich, interactive detail views

---

# 🔗 RELATED FEATURES

**Builds on:**
- Feature 03: Architecture (MVVM, SwiftData, Navigation)
- Feature 04: List CRUD (CRUDListView, Mood model)

**Enables:**
- Feature 06: Could add filtering by favorites
- Feature 07: Could add favorite statistics
- Future: Bulk favorite management

---

# 📝 NOTES

- Schema migration strategy is simplified for development (data reset)
- Production apps would use SwiftData migration plans to preserve user data
- FavoriteButton is intentionally generic for reuse in future features
- Navigation pattern is type-safe and works with any Hashable model
- @Bindable automatically enables $ syntax for @Model properties
- SwiftData auto-persists changes to @Model objects, no explicit save needed

