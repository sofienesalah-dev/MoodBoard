# 🏗️ Feature 03: Architecture — MVVM + SwiftData + Typed Navigation

> **Objective**: Implement a lightweight MVVM architecture with SwiftData for persistence and typed navigation using NavigationStack.

---

## 📚 Table of Contents

1. [Overview](#overview)
2. [Architecture Components](#architecture-components)
3. [SwiftData Concepts](#swiftdata-concepts)
4. [Typed Navigation](#typed-navigation)
5. [MVVM Pattern](#mvvm-pattern)
6. [Code Examples](#code-examples)
7. [Comparison with Other Frameworks](#comparison-with-other-frameworks)

---

## Overview

This feature demonstrates a **modern iOS architecture** combining:

- **MVVM pattern**: Separation of concerns between Model, View, and ViewModel
- **SwiftData**: Apple's declarative data persistence framework (iOS 17+)
- **Typed Navigation**: Type-safe routing with NavigationStack
- **Reactive State**: @Observable for in-memory state, @Model for persistent data

### Key Files

| File | Purpose |
|------|---------|
| `Mood.swift` | SwiftData model with @Model |
| `Router.swift` | Typed navigation routes |
| `MoodBoardApp.swift` | ModelContainer configuration |
| `ArchitectureView.swift` | Demo view showcasing the architecture |

---

## Architecture Components

### 1. **Model Layer** — `Mood.swift`

```swift
@Model
final class Mood {
    var emoji: String
    var label: String
    var timestamp: Date
    
    init(emoji: String, label: String, timestamp: Date = Date()) {
        self.emoji = emoji
        self.label = label
        self.timestamp = timestamp
    }
}
```

**Key Points:**
- `@Model` macro provides automatic persistence
- No need for NSManagedObject or CoreData boilerplate
- Type-safe properties (String, Date, etc.)

### 2. **View Layer** — `ArchitectureView.swift`

```swift
struct ArchitectureView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Mood.timestamp, order: .reverse) private var moods: [Mood]
    
    var body: some View {
        List(moods) { mood in
            MoodRowView(mood: mood)
        }
    }
}
```

**Key Points:**
- `@Query` provides reactive data fetching
- `@Environment(\.modelContext)` accesses SwiftData context
- UI updates automatically when data changes

### 3. **Navigation Layer** — `Router.swift`

```swift
enum Route: Hashable {
    case introState
    case observation
    case architecture
    case moodDetail(id: PersistentIdentifier)
}

@Observable
final class Router {
    var path: [Route] = []
    
    func navigate(to route: Route) {
        path.append(route)
    }
}
```

**Key Points:**
- Type-safe routes (compile-time errors for wrong routes)
- Centralized navigation logic
- Supports deep linking and state restoration

### 4. **Storage Layer** — `MoodBoardApp.swift`

```swift
var sharedModelContainer: ModelContainer = {
    let schema = Schema([Mood.self])
    let modelConfiguration = ModelConfiguration(
        schema: schema,
        isStoredInMemoryOnly: false
    )
    return try! ModelContainer(for: schema, configurations: [modelConfiguration])
}()
```

**Key Points:**
- `ModelContainer` manages persistence
- `isStoredInMemoryOnly: false` → data survives app restarts
- `isStoredInMemoryOnly: true` → volatile storage for previews/tests

---

## SwiftData Concepts

### What is SwiftData?

SwiftData is Apple's **declarative data persistence framework** introduced at WWDC 2023 (iOS 17+).

**Key Features:**
- ✅ Pure Swift (no Objective-C)
- ✅ Declarative syntax using macros
- ✅ Automatic schema generation
- ✅ Type-safe queries
- ✅ Relationships and migrations

### @Model vs @Observable

| Feature | @Model (SwiftData) | @Observable |
|---------|-------------------|-------------|
| **Purpose** | Persistent data | In-memory state |
| **Survival** | Survives app restarts | Lost on app termination |
| **Use Case** | Domain data (users, moods, etc.) | UI state (selections, toggles, etc.) |
| **Storage** | Disk (SQLite backend) | RAM |

### @Query vs @FetchRequest

| Feature | @Query (SwiftData) | @FetchRequest (CoreData) |
|---------|-------------------|-------------------------|
| **Syntax** | `@Query(sort: \.timestamp)` | `@FetchRequest(sortDescriptors: [NSSortDescriptor(...)])` |
| **Type Safety** | ✅ Full Swift type safety | ⚠️ Requires casting |
| **Boilerplate** | ✅ Minimal | ⚠️ Verbose |
| **Reactivity** | ✅ Automatic | ✅ Automatic |

---

## Typed Navigation

### What is Typed Navigation?

Typed navigation uses **enum routes** instead of string-based paths.

**Benefits:**
- ✅ Compile-time safety (wrong route = compile error)
- ✅ Refactoring support (Xcode renames routes automatically)
- ✅ Deep linking integration
- ✅ Testability (routes can be unit tested)

### Example: String-Based vs Typed

**❌ String-Based (Legacy)**
```swift
NavigationLink(destination: Text("Detail"), tag: "detail", selection: $selection) {
    Text("Go to Detail")
}
// Risk: Typo in "detail" causes runtime crash
```

**✅ Typed Navigation (Modern)**
```swift
NavigationLink(value: Route.moodDetail(id: moodId)) {
    Text("Go to Detail")
}
// Compile error if Route.moodDetail doesn't exist
```

---

## MVVM Pattern

### What is MVVM?

**MVVM** (Model-View-ViewModel) is an architectural pattern that separates concerns:

```
┌─────────────┐
│   View      │  ← SwiftUI views (UI only)
└─────────────┘
       ↕
┌─────────────┐
│ ViewModel   │  ← Router, @Observable classes (logic)
└─────────────┘
       ↕
┌─────────────┐
│   Model     │  ← @Model classes (data)
└─────────────┘
```

### In SwiftUI Context

- **Model**: `@Model` classes (Mood, User, etc.)
- **View**: SwiftUI views (ArchitectureView, MoodRowView, etc.)
- **ViewModel**: `@Observable` classes (Router, MoodStore, etc.) + SwiftData `@Environment(\.modelContext)`

### Why MVVM?

- ✅ Testability (ViewModels can be unit tested)
- ✅ Reusability (ViewModels can be shared)
- ✅ Separation of concerns (UI logic vs business logic)
- ✅ Scalability (easier to add features)

---

## Code Examples

### Creating a Mood

```swift
func addMood() {
    let newMood = Mood(emoji: "😊", label: "Happy")
    modelContext.insert(newMood)  // SwiftData persists automatically
}
```

### Querying Moods

```swift
@Query(sort: \Mood.timestamp, order: .reverse)
private var moods: [Mood]
```

### Deleting a Mood

```swift
func deleteMood(_ mood: Mood) {
    modelContext.delete(mood)
}
```

### Navigating to a Route

```swift
@Environment(Router.self) private var router

Button("Go to Architecture") {
    router.navigate(to: .architecture)
}
```

---

## Comparison with Other Frameworks

### SwiftData vs Room (Android)

| Feature | SwiftData | Room |
|---------|-----------|------|
| **Annotation** | `@Model` | `@Entity` |
| **Query** | `@Query` | `@Dao` with `@Query("SELECT...")` |
| **Migration** | Automatic | Manual |
| **Boilerplate** | ✅ Minimal | ⚠️ Verbose |

### SwiftData vs Core Data

| Feature | SwiftData | Core Data |
|---------|-----------|-----------|
| **Language** | Pure Swift | Objective-C + Swift |
| **Syntax** | Declarative | Imperative |
| **Type Safety** | ✅ Full | ⚠️ Partial |
| **Learning Curve** | ✅ Easy | ⚠️ Steep |

### Typed Navigation vs React Router

| Feature | SwiftUI Router | React Router |
|---------|---------------|--------------|
| **Route Definition** | `enum Route` | `<Route path="...">` |
| **Type Safety** | ✅ Full | ⚠️ Requires TypeScript |
| **Compile-Time Checks** | ✅ Yes | ⚠️ Only with TypeScript |
| **Deep Linking** | ✅ Easy | ✅ Easy |

---

## Summary

This feature demonstrates:

1. ✅ **SwiftData** for declarative persistence
2. ✅ **@Model** for domain models
3. ✅ **@Query** for reactive data fetching
4. ✅ **Typed navigation** with Router
5. ✅ **MVVM pattern** for separation of concerns
6. ✅ **In-memory storage** for previews (isStoredInMemoryOnly)

**Next Steps:**
- Feature 04: @Binding (parent-child communication)
- Feature 05: @Environment (dependency injection)
- Feature 06: Relationships in SwiftData

---

**Project**: MoodBoard  
**Feature**: 03-arch-swiftdata-navstack  
**Date**: 2025-10-19

