# 📘 Feature 02 — Observation with @Observable

> **Goal**: Master modern state management with `@Observable` and `@Bindable` (iOS 17+)

---

## 🎯 Key Concepts

### @Observable (iOS 17+)

`@Observable` is a **macro** introduced in iOS 17 that transforms a class into an observable object.

```swift
@Observable
class MoodStore {
    var moods: [Mood] = []  // ✨ Automatically observed!
}
```

#### How it Works

1. **Automatic observation**: ALL properties are tracked (no need for `@Published`)
2. **Fine-grained updates**: Only observing views are invalidated
3. **Better performance**: More efficient than the old system
4. **Type-safe**: Compile-time checking

### @Bindable

`@Bindable` creates a two-way binding to an `@Observable` object's properties.

```swift
@State private var store = MoodStore()

// In child view:
TextField("Label", text: $store.someProperty)
                              ↑
                        @Bindable enables this
```

---

## 🔄 Evolution: Old vs New System

### ❌ Old System (iOS 13-16)

```swift
// 1. Class must conform to ObservableObject
class MoodStore: ObservableObject {
    // 2. Each property needs @Published
    @Published var moods: [Mood] = []
    @Published var isLoading = false  // Must be explicit!
}

// 3. In view, must use @StateObject or @ObservedObject
struct MoodListView: View {
    @StateObject private var store = MoodStore()
    // ...
}
```

**Problems:**
- ❌ Boilerplate code (`@Published` everywhere)
- ❌ Performance issues (whole object observed)
- ❌ Easy to forget `@Published`
- ❌ Complex lifetime management (@StateObject vs @ObservedObject)

### ✅ New System (iOS 17+)

```swift
// 1. Simple @Observable macro
@Observable
class MoodStore {
    // 2. All properties automatically observed!
    var moods: [Mood] = []
    var isLoading = false  // No @Published needed!
}

// 3. Simple @State in view
struct MoodListView: View {
    @State private var store = MoodStore()
    // ...
}
```

**Advantages:**
- ✅ Less boilerplate
- ✅ Better performance (fine-grained)
- ✅ Simpler to understand
- ✅ Unified lifetime management with @State

---

## 🧩 Architecture: MoodStore

```swift
@Observable
class MoodStore {
    var moods: [Mood] = []
    
    func addMood(emoji: String, label: String) {
        moods.append(Mood(emoji: emoji, label: label))
        // SwiftUI automatically updates observing views! 🎉
    }
    
    func removeMood(id: UUID) {
        moods.removeAll { $0.id == id }
    }
}
```

### Why a Class and Not a Struct?

- **Classes** = reference type = shared state
- **Structs** = value type = copied on each assignment
- For a store, we want ONE shared instance → class

---

## 🌍 Parallels with Other Frameworks

| Framework | @Observable Equivalent | Example |
|-----------|------------------------|---------|
| **React** | Context API + useState | `const [state, setState] = useState()` + Context |
| **Jetpack Compose** | ViewModel + mutableStateOf | `val moods = mutableStateListOf<Mood>()` |
| **Vue.js** | reactive() | `const store = reactive({ moods: [] })` |
| **Angular** | Service + BehaviorSubject | Injectable service with RxJS |

### Key Differences

- **React**: Requires Context Provider wrapper
- **Jetpack Compose**: Requires `by remember` delegation
- **SwiftUI**: Direct property access thanks to @Observable macro
- **Angular**: Requires subscription management

---

## 🔄 Data Flow

```
┌─────────────────────────────────────┐
│  1. User taps "Add Mood"            │
└──────────────┬──────────────────────┘
               ▼
┌─────────────────────────────────────┐
│  2. store.addMood(...)              │
│     (modifies moods array)          │
└──────────────┬──────────────────────┘
               ▼
┌─────────────────────────────────────┐
│  3. @Observable detects change      │
│     (macro-generated code)          │
└──────────────┬──────────────────────┘
               ▼
┌─────────────────────────────────────┐
│  4. SwiftUI invalidates only        │
│     MoodListView (fine-grained)     │
└──────────────┬──────────────────────┘
               ▼
┌─────────────────────────────────────┐
│  5. View recalculates body          │
└──────────────┬──────────────────────┘
               ▼
┌─────────────────────────────────────┐
│  6. UI updates (diff algorithm)     │
└─────────────────────────────────────┘
```

---

## 🎨 Best Practices

### ✅ Do

```swift
// ✅ Use @Observable for shared state
@Observable
class MoodStore {
    var moods: [Mood] = []
}

// ✅ Use @State to own the store
struct MoodListView: View {
    @State private var store = MoodStore()
}

// ✅ Pass store directly to child views
AddMoodSheet(store: store)
```

### ❌ Don't

```swift
// ❌ Don't mix old and new systems
@Observable
class Store: ObservableObject {  // ❌ Redundant!
    @Published var moods = []    // ❌ Not needed!
}

// ❌ Don't use @StateObject with @Observable
@StateObject var store = MoodStore()  // ❌ Use @State instead!

// ❌ Don't make ALL classes @Observable
@Observable  // ❌ Only for shared state!
struct Mood { }  // Should be a simple struct
```

---

## 🧪 Key Features Demonstrated

### 1. **Empty State**
- Uses `ContentUnavailableView` (iOS 17+)
- Clean UX when list is empty

### 2. **Add/Remove Operations**
- `addMood()`: Append to array
- `removeMood()`: Delete by ID
- `clearAll()`: Remove all items

### 3. **Swipe to Delete**
- `.onDelete` modifier
- Animated with `withAnimation`

### 4. **Sheet Presentation**
- `AddMoodSheet` for new mood entry
- Grid layout for mood selection
- Form validation (disabled button)

### 5. **Custom Components**
- `MoodRowView`: Reusable row
- Emoji + label + relative timestamp

---

## 🎭 UI Components Breakdown

### MoodListView
```swift
@State private var store = MoodStore()
```
- Main view
- Owns the store with @State
- Conditional rendering (empty vs list)
- Toolbar with actions

### AddMoodSheet
```swift
let store: MoodStore  // No @Binding needed!
```
- Modal sheet for adding moods
- Grid layout for emoji selection
- TextField for custom label
- Validation logic

### MoodRowView
```swift
let mood: Mood  // Simple immutable data
```
- Displays one mood
- Emoji + label + timestamp
- Reusable component

---

## 📊 Performance Comparison

| Metric | Old System | New System (@Observable) |
|--------|-----------|--------------------------|
| Boilerplate | High (@Published everywhere) | Low (one macro) |
| Update precision | Object-level | Property-level |
| Memory usage | Higher | Lower |
| Compile time | Slower | Faster |
| Learning curve | Steep | Gentle |

---

## 🚀 When to Use Each System

### Use @State (local state)
```swift
@State private var counter = 0  // ✅ Simple view-local state
```

### Use @Observable (shared state)
```swift
@Observable
class MoodStore {  // ✅ Shared across views
    var moods: [Mood] = []
}
```

### Use @Environment (dependency injection)
```swift
@Environment(\.dismiss) var dismiss  // ✅ System values
```

---

## 🔧 Migration Guide (Old → New)

### Before (iOS 13-16)
```swift
class Store: ObservableObject {
    @Published var items: [Item] = []
}

struct MyView: View {
    @StateObject private var store = Store()
}
```

### After (iOS 17+)
```swift
@Observable
class Store {
    var items: [Item] = []  // No @Published!
}

struct MyView: View {
    @State private var store = Store()  // No @StateObject!
}
```

**Migration steps:**
1. Remove `: ObservableObject` conformance
2. Replace `@Published` with nothing
3. Replace `@StateObject` with `@State`
4. Replace `@ObservedObject` with `var` (if passed from parent)

---

## 📚 Resources

- [Apple Documentation - Observable](https://developer.apple.com/documentation/observation/observable)
- [WWDC 2023 - Discover Observation in SwiftUI](https://developer.apple.com/videos/play/wwdc2023/10149/)
- [Swift Evolution Proposal SE-0395](https://github.com/apple/swift-evolution/blob/main/proposals/0395-observability.md)
- [Migration Guide from ObservableObject](https://developer.apple.com/documentation/swiftui/migrating-from-the-observable-object-protocol-to-the-observable-macro)

---

## 🧪 Suggested Exercises

1. Add a "favorite" toggle to each mood (boolean property)
2. Add filtering by emoji type
3. Persist moods with SwiftData or UserDefaults
4. Add mood statistics (count per emoji)
5. Add sorting (by date, by label)

---

## 🎯 Key Takeaways

1. **@Observable** replaces @ObservableObject (iOS 17+)
2. **@Bindable** enables two-way binding to @Observable properties
3. **Less boilerplate**, better performance
4. **Fine-grained observation** = only affected views update
5. **Simple @State ownership** instead of @StateObject/@ObservedObject

---

**Feature**: `02-observation`  
**Date**: 2025-10-19  
**Stack**: iOS 17+, Swift 6, SwiftUI

