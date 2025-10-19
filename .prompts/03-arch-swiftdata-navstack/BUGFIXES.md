# Bug Fixes — Feature 03: Architecture

**Feature**: 03-arch-swiftdata-navstack  
**Date**: 2025-10-19

---

## 🐛 Issues Encountered & Solutions

### 1. Type Inference Error with `Mood.samples`

**Error:**
```
Reference to member 'samples' cannot be resolved without a contextual type
```

**Location:** `MoodBoardApp.swift:85`

**Cause:**
Swift compiler has difficulty with type inference when using `.forEach` on `@Model` class static properties in SwiftData context.

**Solution:**
Created a dedicated helper function:
```swift
// ✅ Solution
static func insertSamples(into context: ModelContext) {
    let sampleMoods = [
        Mood(emoji: "😊", label: "Happy", timestamp: Date().addingTimeInterval(-3600)),
        // ...
    ]
    for mood in sampleMoods {
        context.insert(mood)
    }
}

// Usage in ModelContainer.preview
Mood.insertSamples(into: container.mainContext)
```

---

### 2. Naming Conflict: `Mood` Redeclaration

**Error:**
```
Invalid redeclaration of 'Mood'
'Mood' is ambiguous for type lookup in this context
```

**Location:** `Mood.swift:31`, `Mood.swift:62`, `Mood.swift:65`

**Cause:**
- Feature 02 (Observation) had `struct Mood` (in-memory, @Observable)
- Feature 03 (Architecture) needs `@Model class Mood` (persistent, SwiftData)

**Solution:**
Renamed Feature 02's model to avoid conflict:
```swift
// Feature 02 (MoodStore.swift)
struct MoodEntry: Identifiable {  // ✅ Renamed from Mood
    let id = UUID()
    var emoji: String
    var label: String
    var timestamp: Date = Date()
}

// Feature 03 (Mood.swift)
@Model
final class Mood {  // ✅ No conflict
    var emoji: String
    var label: String
    var timestamp: Date
}
```

**Files Modified:**
- `MoodStore.swift` → `struct Mood` → `struct MoodEntry`
- `MoodListView.swift` → `MoodRowView(mood: MoodEntry)`

---

### 3. `PersistentIdentifier` Not Hashable

**Error:**
```
Type 'Route' does not conform to protocol 'Equatable'
Type 'Route' does not conform to protocol 'Hashable'
Cannot find type 'PersistentIdentifier' in scope
```

**Location:** `Router.swift:30`, `Router.swift:47`

**Cause:**
- `PersistentIdentifier` from SwiftData is not `Hashable`
- Enum with associated values must be `Hashable` for NavigationStack
- Missing `import SwiftData`

**Solution:**
```swift
// ✅ Add import
import SwiftData

// ✅ Use String instead of PersistentIdentifier
enum Route: Hashable {
    case introState
    case observation
    case architecture
    case moodDetail(idString: String)  // Use String URIRepresentation
}
```

---

### 4. Router Environment Crash

**Error:**
```
Thread 1: Fatal error: No Observable object of type Router found
```

**Location:** App runtime when tapping "Architecture"

**Cause:**
`ArchitectureView` had:
```swift
@Environment(Router.self) private var router
```

But `Router` was never injected into the app's environment via `.environment(Router())`.

**Solution:**
Commented out the unused Router environment:
```swift
// MARK: - Navigation

/// Typed router for programmatic navigation
/// (For demonstration purposes, not used in this view)
/// Note: Commented out to avoid crash - Router not yet injected in app environment
// @Environment(Router.self) private var router
```

**Alternative (if Router is needed):**
Inject Router in `ContentView` or `MoodBoardApp`:
```swift
ContentView()
    .environment(Router())
```

---

### 5. `MoodRowView` Redeclaration

**Error:**
```
Invalid redeclaration of 'MoodRowView'
Cannot convert value of type 'Mood' to expected argument type 'MoodEntry'
```

**Location:** `ArchitectureView.swift:268`, `ArchitectureView.swift:187`

**Cause:**
- `MoodRowView` already existed in `MoodListView.swift` (Feature 02) expecting `MoodEntry`
- `ArchitectureView.swift` (Feature 03) needs a row view for `Mood` (SwiftData)

**Solution:**
Renamed the component in Feature 03:
```swift
// ArchitectureView.swift
private struct ArchitectureMoodRow: View {  // ✅ Unique name
    let mood: Mood  // SwiftData Mood
    // ...
}

// Usage
ForEach(moods) { mood in
    ArchitectureMoodRow(mood: mood)
}
```

---

## 📋 Summary of Changes

### Files Created
- `Mood.swift` — SwiftData @Model with `insertSamples(into:)` helper

### Files Modified
1. **MoodStore.swift**
   - `struct Mood` → `struct MoodEntry`
   - Updated all references

2. **MoodListView.swift**
   - `MoodRowView(mood: Mood)` → `MoodRowView(mood: MoodEntry)`

3. **MoodBoardApp.swift**
   - Added `Mood.self` to Schema
   - Uses `Mood.insertSamples(into:)` for preview data

4. **Router.swift**
   - Added `import SwiftData`
   - `case moodDetail(id: PersistentIdentifier)` → `case moodDetail(idString: String)`

5. **ArchitectureView.swift**
   - Commented out `@Environment(Router.self)`
   - `MoodRowView` → `ArchitectureMoodRow`
   - Removed `.environment(Router())` from previews

---

## 🎓 Lessons Learned

### 1. SwiftData Type Inference
When working with `@Model` classes, avoid direct array iteration in certain contexts. Create helper functions that encapsulate the creation and insertion logic.

### 2. Naming Conflicts in Multi-Feature Apps
When introducing new models that might conflict with existing names:
- Rename the less-central model (Feature 02's in-memory `Mood` → `MoodEntry`)
- Keep the more important model name (Feature 03's persistent `Mood`)
- Use descriptive suffixes (`Entry`, `DTO`, `Entity`) to clarify purpose

### 3. Environment Objects Must Be Injected
`@Environment(Router.self)` requires:
```swift
.environment(Router())
```
somewhere in the parent view hierarchy, or the app will crash.

### 4. PersistentIdentifier and Hashable
`PersistentIdentifier` is not `Hashable`. For navigation:
- Use `String` representation (URIRepresentation)
- Or use `UUID` if you add one to your models

### 5. Component Naming Best Practices
For reusable components across features:
- Use feature-specific prefixes (`ArchitectureMoodRow`, `IntroStateCard`)
- Or use private components per file
- Or use explicit namespacing

---

## ✅ Final State

All issues resolved. App compiles and runs without errors. Feature 03 fully functional:
- ✅ SwiftData persistence works
- ✅ CRUD operations functional
- ✅ No naming conflicts
- ✅ No runtime crashes
- ✅ Clean compilation

---

**Last Updated**: 2025-10-19  
**Status**: ✅ All bugs fixed

