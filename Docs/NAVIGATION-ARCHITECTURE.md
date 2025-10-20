# Navigation Architecture — Centralized Router

**Date:** 2025-10-20  
**Status:** ✅ Implemented

---

## 📐 Architecture Overview

### Before: Multiple NavigationStacks (Nested)
```
FeaturesListView (NavigationStack)
├─ NavigationLink → IntroStateView
├─ NavigationLink → MoodListView (NavigationStack) ❌ Nested!
├─ NavigationLink → ArchitectureView
└─ NavigationLink → CRUDListView
    └─ NavigationLink → MoodDetailView ❌ Complex nesting!
```

**Problems:**
- Multiple NavigationStacks interfered with each other
- Navigation bugs (detail view not showing, back button issues)
- Difficult to maintain programmatic navigation
- No single source of truth for navigation state

### After: Single NavigationStack with Centralized Router
```
ContentView (NavigationStack + Router)
├─ FeaturesListView (root)
│  ├─ Button → router.navigate(.introState)
│  ├─ Button → router.navigate(.observation)
│  ├─ Button → router.navigate(.architecture)
│  └─ Button → router.navigate(.crudList)
├─ .navigationDestination(for: Route.self)
│  ├─ .introState → IntroStateView
│  ├─ .observation → MoodListView
│  ├─ .architecture → ArchitectureView
│  ├─ .crudList → CRUDListView
│  └─ .moodDetail(mood) → MoodDetailView
```

**Benefits:**
- ✅ Single source of truth for navigation
- ✅ No NavigationStack nesting conflicts
- ✅ Type-safe routing via `Route` enum
- ✅ Programmatic navigation from anywhere
- ✅ Easy to test navigation flows
- ✅ Simple to add deep linking later

---

## 🏗️ Key Components

### 1. **Route Enum** (`Router.swift`)

Defines all possible navigation destinations:

```swift
enum Route: Hashable {
    case introState
    case observation
    case architecture
    case crudList
    case moodDetail(mood: Mood)  // ✨ Passes full object, not just ID
}
```

**Why Hashable?**
- Required by `NavigationStack(path:)`
- Enables navigation state serialization
- Allows route comparison and deduplication

### 2. **Router Class** (`Router.swift`)

Centralized navigation manager:

```swift
@Observable
final class Router {
    var path: [Route] = []
    
    func navigate(to route: Route)
    func goBack()
    func goBackToRoot()
    func replace(with route: Route)
}
```

**@Observable Pattern:**
- Reactive: UI updates when `path` changes
- No need for `@Published` or `ObservableObject`
- Modern iOS 17+ pattern

### 3. **ContentView** (Root NavigationStack)

Single NavigationStack for entire app:

```swift
struct ContentView: View {
    @State private var router = Router()
    
    var body: some View {
        NavigationStack(path: $router.path) {
            FeaturesListView()
                .navigationDestination(for: Route.self) { route in
                    destinationView(for: route)
                }
        }
        .environment(router)  // ✨ Inject to all children
    }
}
```

**Key Points:**
- Creates Router once at root
- Binds Router.path to NavigationStack
- Registers all navigation destinations
- Injects Router via environment

### 4. **Child Views** (Router Consumers)

Views use Router instead of NavigationLink:

```swift
struct FeaturesListView: View {
    @Environment(Router.self) private var router
    
    var body: some View {
        Button {
            router.navigate(to: .crudList)  // ✨ Programmatic navigation
        } label: {
            FeatureRowView(...)
        }
    }
}
```

**Benefits:**
- No `NavigationLink` needed
- Consistent button styling
- Easy to add analytics, logging, etc.
- Can navigate from anywhere (not just buttons)

---

## 🔄 Navigation Flows

### Flow 1: Features List → CRUD List

```swift
// 1. User taps "CRUD + Detail" button in FeaturesListView
Button {
    router.navigate(to: .crudList)
}

// 2. Router appends .crudList to path
router.path.append(.crudList)

// 3. NavigationStack matches .crudList in destinationView()
case .crudList:
    CRUDListView()

// 4. CRUDListView presented with slide-in animation
```

### Flow 2: CRUD List → Mood Detail

```swift
// 1. User taps mood row in CRUDListView
Button {
    router.navigate(to: .moodDetail(mood: mood))
}

// 2. Router appends .moodDetail(mood) to path
router.path.append(.moodDetail(mood: selectedMood))

// 3. NavigationStack matches .moodDetail in destinationView()
case .moodDetail(let mood):
    MoodDetailView(mood: mood)

// 4. MoodDetailView presented with mood object
```

### Flow 3: Back Navigation

```swift
// Option 1: System back button (automatic)
// - NavigationStack handles automatically
// - Pops last Route from path

// Option 2: Programmatic back
router.goBack()  // Removes last route from path

// Option 3: Back to root
router.goBackToRoot()  // Clears entire path
```

---

## 📝 Migration Guide

### Before (NavigationLink):
```swift
NavigationLink {
    MoodDetailView(mood: mood)
} label: {
    MoodRowView(mood: mood)
}
```

### After (Router Button):
```swift
Button {
    router.navigate(to: .moodDetail(mood: mood))
} label: {
    MoodRowView(mood: mood)
}
```

### Before (Nested NavigationStack):
```swift
struct CRUDListView: View {
    var body: some View {
        NavigationStack {  // ❌ Remove this
            List { ... }
        }
    }
}
```

### After (No NavigationStack):
```swift
struct CRUDListView: View {
    @Environment(Router.self) private var router
    
    var body: some View {
        List { ... }  // ✅ Just content, no stack
    }
}
```

---

## 🧪 Testing Navigation

### Manual Test Scenarios

#### Test 1: Basic Navigation
1. Launch app
2. Tap "CRUD + Detail" in features list
3. **Expected:** CRUDListView appears
4. Add a mood (tap + button)
5. Fill form and save
6. Tap the mood in the list
7. **Expected:** MoodDetailView appears with correct mood
8. **Expected:** Back button works correctly

#### Test 2: Deep Navigation Stack
1. Features → CRUD List → Mood Detail
2. Tap back → **Expected:** Returns to CRUD List
3. Tap back → **Expected:** Returns to Features
4. **Expected:** No blank screens or navigation bugs

#### Test 3: Favorite Toggle Persistence
1. Navigate to mood detail
2. Toggle favorite (heart button)
3. Navigate back to list
4. **Expected:** Favorite status reflected in list
5. Navigate to detail again
6. **Expected:** Favorite status persisted

#### Test 4: Sheet Navigation
1. In CRUD list, tap + to add mood
2. **Expected:** Sheet appears with its own NavigationStack (correct!)
3. Save or cancel
4. **Expected:** Back to CRUD list, no navigation issues

#### Test 5: Multiple Quick Navigations
1. Rapidly tap multiple features in quick succession
2. **Expected:** Navigation queue handled correctly
3. **Expected:** No crashes or stuck states

---

## 🐛 Troubleshooting

### Issue: "View not appearing"
**Cause:** Route not registered in `destinationView(for:)`  
**Solution:** Add case to switch in ContentView

### Issue: "Back button doesn't work"
**Cause:** Child view has its own NavigationStack  
**Solution:** Remove NavigationStack from child view

### Issue: "@Environment(Router.self) returns nil"
**Cause:** Router not injected at root  
**Solution:** Verify `.environment(router)` in ContentView

### Issue: "Navigation happens twice"
**Cause:** Both NavigationLink AND router.navigate() called  
**Solution:** Use only router.navigate(), remove NavigationLink

---

## 📊 Code Changes Summary

| File | Change | Lines Changed |
|------|--------|---------------|
| `Router.swift` | Added `.crudList` and `.moodDetail(mood:)` routes | +5 |
| `ContentView.swift` | Added NavigationStack + Router + destinations | +50 |
| `FeaturesListView.swift` | Replaced NavigationLink with router.navigate() | ~80 |
| `CRUDListView.swift` | Removed .navigationDestination, use router | ~30 |
| `MoodListView.swift` | Removed NavigationStack wrapper | -10 |

**Total:** ~155 lines changed across 5 files

---

## 🚀 Future Enhancements

### 1. Deep Linking
```swift
func handle(url: URL) {
    if url.path == "/mood/\(id)" {
        router.navigate(to: .moodDetail(mood: fetchMood(id)))
    }
}
```

### 2. Navigation Analytics
```swift
func navigate(to route: Route) {
    Analytics.log("navigation", route: route)
    path.append(route)
}
```

### 3. Navigation Guards
```swift
func navigate(to route: Route) {
    guard canNavigate(to: route) else { return }
    path.append(route)
}
```

### 4. State Restoration
```swift
func saveNavigationState() {
    UserDefaults.standard.set(encodedPath, forKey: "navPath")
}

func restoreNavigationState() {
    router.path = decodedPath
}
```

---

## 📚 References

- [NavigationStack Documentation](https://developer.apple.com/documentation/swiftui/navigationstack)
- [iOS 16+ Navigation Patterns](https://developer.apple.com/videos/play/wwdc2022/10054/)
- [@Observable Framework](https://developer.apple.com/documentation/observation)
- [Type-Safe Routing Best Practices](https://www.swiftbysundell.com/articles/type-safe-routing-swiftui/)

---

## ✅ Verification Checklist

- [x] Single NavigationStack at root (ContentView)
- [x] Router created and injected via environment
- [x] All routes defined in Route enum
- [x] All destinations registered in ContentView
- [x] FeaturesListView uses router.navigate()
- [x] CRUDListView uses router.navigate() for detail
- [x] No nested NavigationStacks (except modals)
- [x] Back navigation works correctly
- [x] No blank screens or navigation bugs
- [x] Favorite toggle persists correctly

---

**Migration Complete** ✅  
**All Tests Passing** ✅  
**Ready for Production** ✅

