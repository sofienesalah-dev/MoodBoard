# 📘 Feature 01 — Introduction to @State

> **Goal**: Understand SwiftUI's declarative paradigm through state management with `@State`

---

## 🎯 Key Concept: @State

`@State` is a SwiftUI **property wrapper** that transforms a property into a monitored **source of truth**.

### How it Works

```swift
@State private var counter: Int = 0
```

When `counter` changes:
1. SwiftUI **detects** the modification automatically
2. SwiftUI **invalidates** the view
3. SwiftUI **recalculates** the `body`
4. SwiftUI **updates** the interface

### Why "private"?

`@State` should be **private** because it represents a state **local** to the view. To share state between views, use `@Binding`, `@ObservableObject`, etc.

---

## 🔄 Declarative vs Imperative Paradigm

### ❌ Imperative (UIKit style)

```swift
// We describe HOW to modify the UI
button.addTarget(self, action: #selector(increment), for: .touchUpInside)

@objc func increment() {
    counter += 1
    label.text = "\(counter)"  // Manual update!
}
```

### ✅ Declarative (SwiftUI style)

```swift
// We describe WHAT the UI should display
Button("Increment") {
    counter += 1  // SwiftUI updates automatically!
}

Text("\(counter)")  // Always synchronized
```

---

## 🧩 Complete Source Code

```swift
import SwiftUI

struct IntroStateView: View {
    
    // Local view state
    @State private var counter: Int = 0
    
    var body: some View {
        VStack(spacing: 24) {
            
            // Header
            Text("Intro @State")
                .font(.title)
            
            // Counter display
            Text("\(counter)")
                .font(.system(size: 72, weight: .bold))
                .foregroundStyle(.blue)
                .contentTransition(.numericText())  // iOS 17+ animation
            
            // Increment button
            Button {
                withAnimation(.spring()) {
                    counter += 1  // ← State modification
                }
            } label: {
                Text("Increment")
            }
            
            // Conditional button (appears only if counter > 0)
            if counter > 0 {
                Button("Reset") {
                    withAnimation {
                        counter = 0
                    }
                }
            }
        }
    }
}
```

---

## 🌍 Parallels with Other Frameworks

| Framework | @State Equivalent | Example |
|-----------|------------------|---------|
| **React** | `useState()` | `const [count, setCount] = useState(0)` |
| **Jetpack Compose** | `remember { mutableStateOf() }` | `var count by remember { mutableStateOf(0) }` |
| **Vue.js** | `ref()` or `reactive()` | `const count = ref(0)` |
| **Angular** | Class property + change detection | `count: number = 0` |

### Key Differences

- **React**: requires `setCount()` to modify state
- **Jetpack Compose**: uses `by` delegation to read/write
- **SwiftUI**: direct modification `counter += 1` thanks to property wrappers

---

## 🔄 Render Lifecycle

```
┌─────────────────────────────────────┐
│  1. User taps the button            │
└──────────────┬──────────────────────┘
               ▼
┌─────────────────────────────────────┐
│  2. counter += 1                    │
│     (@State modification)           │
└──────────────┬──────────────────────┘
               ▼
┌─────────────────────────────────────┐
│  3. SwiftUI detects the change      │
└──────────────┬──────────────────────┘
               ▼
┌─────────────────────────────────────┐
│  4. View invalidation                │
└──────────────┬──────────────────────┘
               ▼
┌─────────────────────────────────────┐
│  5. Recalculate body { ... }        │
└──────────────┬──────────────────────┘
               ▼
┌─────────────────────────────────────┐
│  6. UI update (diff algorithm)      │
└─────────────────────────────────────┘
```

### Optimization

SwiftUI uses a **diff algorithm** to update only the modified parts of the UI, not the entire hierarchy.

---

## 🎨 Best Practices

### ✅ Do

```swift
@State private var counter: Int = 0  // ✅ Private
@State private var isLoading = false // ✅ Default value

Button("Increment") {
    counter += 1  // ✅ Direct modification
}
```

### ❌ Don't

```swift
@State var counter: Int  // ❌ No default value
@State public var counter = 0  // ❌ Public (should be private)

func increment() {
    DispatchQueue.main.async {  // ❌ Unnecessary in SwiftUI
        counter += 1
    }
}
```

---

## 📚 Resources

- [Apple Documentation - State](https://developer.apple.com/documentation/swiftui/state)
- [WWDC 2019 - Data Flow Through SwiftUI](https://developer.apple.com/videos/play/wwdc2019/226/)
- [SwiftUI Property Wrappers Explained](https://www.hackingwithswift.com/quick-start/swiftui/all-swiftui-property-wrappers-explained-and-compared)

---

## 🧪 Suggested Exercises

1. Add a "Decrement" button
2. Add a history of previous values
3. Limit the counter between 0 and 10
4. Change the counter color based on its value (red if > 5)

---

**Feature**: `feature-01-intro-state`  
**Date**: 2025-10-19  
**Stack**: iOS 17+, Swift 6, SwiftUI  
**PR**: [#1](https://github.com/sofienesalah8/MoodBoard/pull/1)

