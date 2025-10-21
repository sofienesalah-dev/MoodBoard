# Prompt Archive — Navigation Refactor

**Date:** 2025-10-20  
**Type:** Architecture Refactor  
**Triggered By:** Feature 05 navigation bugs

---

# 🧩 CONTEXT

This project illustrates a **Prompt-Driven Development** approach.
Each feature must produce:
- **clear and executable code** (Swift 6, SwiftUI),
- **concise pedagogical documentation**,
- and a **complete prompt archive** for traceability and sharing.

**Problem Statement:**
After implementing Feature 05 (Detail + Favorite), navigation was buggy:
- Tapping moods didn't navigate to detail view
- Back button caused unexpected behavior
- Blank screens appeared intermittently
- Console errors: "Failed to create 1206x0 image slot"

**Root Cause:**
Multiple nested `NavigationStack`s interfering with each other:
- `FeaturesListView` had its own NavigationStack
- `MoodListView` had its own NavigationStack
- `CRUDListView` used `.navigationDestination` but was inside another NavigationStack
- Result: Navigation events got lost or duplicated

---

# 🎯 OBJECTIVE

Refactor navigation architecture to use a **centralized Router pattern** with a single `NavigationStack` at the app root.

Demonstrate:
- Single source of truth for navigation state
- Type-safe routing with `Route` enum
- Programmatic navigation via `Router` class
- Elimination of nested NavigationStack conflicts
- Clean separation: views render content, Router handles navigation

---

# 🧱 FILES TO CREATE OR MODIFY

1. **MoodBoard/Sources/Navigation/Router.swift** - Update Route enum with all routes
2. **MoodBoard/ContentView.swift** - Add root NavigationStack with Router
3. **MoodBoard/Sources/Views/FeaturesListView.swift** - Remove NavigationStack, use Router
4. **MoodBoard/Sources/Views/CRUDListView.swift** - Remove .navigationDestination, use Router
5. **MoodBoard/Sources/Views/MoodListView.swift** - Remove NavigationStack
6. **Docs/NAVIGATION-ARCHITECTURE.md** - Complete navigation documentation

---

# 📜 TECHNICAL SPECIFICATIONS

## Router.swift (Update)

**Purpose:** Define all navigation routes and Router class

**Requirements:**

1. **Update Route enum to include all destinations:**
   ```swift
   enum Route: Hashable {
       case introState
       case observation
       case architecture
       case crudList  // ✨ NEW
       case moodDetail(mood: Mood)  // ✨ NEW - passes full object
   }
   ```

2. **Keep existing Router class:**
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

**Why Mood instead of String ID?**
- `Mood` is `Hashable` (automatic with `@Model`)
- Avoids ID serialization/deserialization
- Direct object access in destination view
- Type-safe: compiler ensures Mood exists

## ContentView.swift (Major Refactor)

**Purpose:** Create single NavigationStack for entire app

**Requirements:**

1. **Create Router at root:**
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

2. **Register all navigation destinations:**
   ```swift
   @ViewBuilder
   private func destinationView(for route: Route) -> some View {
       switch route {
       case .introState:
           IntroStateView()
       case .observation:
           MoodListView()
       case .architecture:
           ArchitectureView()
       case .crudList:
           CRUDListView()
       case .moodDetail(let mood):
           MoodDetailView(mood: mood)
       }
   }
   ```

**Key Points:**
- `NavigationStack(path: $router.path)` binds stack to router
- `.navigationDestination(for: Route.self)` handles ALL navigation
- `.environment(router)` makes router available everywhere
- Only ONE NavigationStack for entire app

## FeaturesListView.swift (Refactor)

**Purpose:** Remove NavigationStack, use Router for navigation

**Requirements:**

1. **Remove NavigationStack wrapper:**
   ```swift
   // ❌ REMOVE:
   var body: some View {
       NavigationStack {  // DELETE THIS
           List { ... }
       }
   }
   
   // ✅ REPLACE WITH:
   var body: some View {
       List { ... }  // Just content, no stack
           .navigationTitle(...)  // Keep modifiers
   }
   ```

2. **Inject Router:**
   ```swift
   @Environment(Router.self) private var router
   ```

3. **Replace NavigationLink with Button + router.navigate():**
   ```swift
   // ❌ OLD:
   NavigationLink {
       CRUDListView()
   } label: {
       FeatureRowView(...)
   }
   
   // ✅ NEW:
   Button {
       router.navigate(to: .crudList)
   } label: {
       FeatureRowView(...)
   }
   ```

4. **Consolidate Features 04 & 05:**
   ```swift
   Button {
       router.navigate(to: .crudList)
   } label: {
       FeatureRowView(
           number: "04-05",
           title: "CRUD + Detail",
           description: "Complete CRUD with navigation to detail view & favorites",
           icon: "list.bullet.clipboard",
           color: .green
       )
   }
   ```

## CRUDListView.swift (Refactor)

**Purpose:** Remove local navigation, use centralized Router

**Requirements:**

1. **Inject Router:**
   ```swift
   @Environment(Router.self) private var router
   ```

2. **Remove .navigationDestination:**
   ```swift
   // ❌ REMOVE:
   .navigationDestination(for: Mood.self) { mood in
       MoodDetailView(mood: mood)
   }
   // Navigation now handled by ContentView's destinationView()
   ```

3. **Replace NavigationLink with Button + router.navigate():**
   ```swift
   // ❌ OLD:
   NavigationLink(value: mood) {
       CRUDMoodRowView(mood: mood)
   }
   
   // ✅ NEW:
   Button {
       router.navigate(to: .moodDetail(mood: mood))
   } label: {
       CRUDMoodRowView(mood: mood)
   }
   ```

4. **Keep swipe actions unchanged:**
   ```swift
   .swipeActions(edge: .trailing) { /* Delete */ }
   .swipeActions(edge: .leading) { /* Edit - opens sheet */ }
   ```

## MoodListView.swift (Refactor)

**Purpose:** Remove NavigationStack wrapper

**Requirements:**

1. **Remove NavigationStack:**
   ```swift
   // ❌ REMOVE:
   var body: some View {
       NavigationStack {  // DELETE THIS
           ZStack { ... }
       }
   }
   
   // ✅ REPLACE WITH:
   var body: some View {
       ZStack { ... }  // Just content
           .navigationTitle(...)
   }
   ```

2. **Keep all other functionality:**
   - Toolbar buttons
   - Sheet presentation
   - Empty state
   - List content

**Note:** This view doesn't need Router (no navigation buttons)

## AddMoodSheetView.swift (Keep As-Is)

**Purpose:** Modal sheet with its own navigation

**No Changes Required:**
- Sheets can have their own NavigationStack
- Not part of main navigation hierarchy
- Keep existing structure:
  ```swift
  NavigationStack {  // ✅ OK for sheets
      Form { ... }
  }
  ```

---

# 📋 DOCUMENTATION REQUIREMENTS

## Docs/NAVIGATION-ARCHITECTURE.md

**Structure:**
```markdown
# Navigation Architecture — Centralized Router

## Architecture Overview
- Before/After diagrams
- Problems with nested stacks
- Benefits of centralized router

## Key Components
- Route enum
- Router class
- ContentView NavigationStack
- Child views (consumers)

## Navigation Flows
- Features → CRUD List
- CRUD List → Mood Detail
- Back navigation

## Migration Guide
- NavigationLink → Button + router.navigate()
- Nested NavigationStack → plain content

## Testing Navigation
- Manual test scenarios
- Expected behaviors

## Troubleshooting
- Common issues & solutions
- Debug tips

## Code Changes Summary
- Files modified
- Lines changed

## Future Enhancements
- Deep linking
- Analytics
- Navigation guards
- State restoration
```

---

# 🎨 STYLE GUIDE

## Code Style
- Use Swift 6 syntax
- `@Observable` for Router (not ObservableObject)
- `@Environment(Router.self)` for injection
- Clear MARK comments for organization
- Comprehensive documentation comments

## Navigation Pattern
```swift
// ✅ Correct pattern:
@Environment(Router.self) private var router

Button {
    router.navigate(to: .someRoute)
} label: {
    // UI content
}

// ❌ Avoid:
NavigationLink(value: ...) { }  // Use router instead
NavigationStack { }  // Only in ContentView
```

## Comments Style
```swift
/// Brief description
///
/// **Navigation:** Uses centralized Router
///
/// **Changes from original:**
/// - Removed NavigationStack
/// - Replaced NavigationLink with router.navigate()
```

---

# ✅ ACCEPTANCE CRITERIA

## Functional Requirements
- [ ] Single NavigationStack at root (ContentView)
- [ ] Router created and injected via environment
- [ ] All routes defined in Route enum
- [ ] All destinations registered in ContentView.destinationView()
- [ ] FeaturesListView uses router.navigate() for all features
- [ ] CRUDListView uses router.navigate() for detail navigation
- [ ] MoodListView has no NavigationStack
- [ ] AddMoodSheetView keeps its NavigationStack (modal exception)
- [ ] No navigation bugs (blank screens, wrong destinations)
- [ ] Back button works correctly everywhere

## Code Quality
- [ ] All files compile without warnings
- [ ] No nested NavigationStacks (except sheets)
- [ ] Consistent navigation pattern across all views
- [ ] Clear comments explaining Router pattern
- [ ] Documentation matches actual implementation

## Documentation
- [ ] Docs/NAVIGATION-ARCHITECTURE.md is complete
- [ ] Before/after architecture diagrams
- [ ] Migration guide for developers
- [ ] Manual test scenarios documented
- [ ] Troubleshooting guide included

## Testing
- [ ] Navigate from features to detail works
- [ ] Back navigation works correctly
- [ ] Multiple navigations in sequence work
- [ ] No console errors about navigation
- [ ] Favorite toggle persists correctly
- [ ] Swipe actions still work

---

# 📊 SUCCESS METRICS

**Navigation must:**
1. ✅ Features → CRUD List → works
2. ✅ CRUD List → Mood Detail → works
3. ✅ Back button → always works
4. ✅ No blank screens
5. ✅ No navigation errors in console
6. ✅ Favorite toggle persists
7. ✅ Swipe actions unchanged

**Architecture improvements:**
1. ✅ Single source of truth for navigation
2. ✅ No nested NavigationStack conflicts
3. ✅ Type-safe routing
4. ✅ Programmatic navigation available
5. ✅ Easy to add analytics/logging later
6. ✅ Foundation for deep linking

**Developer experience:**
1. ✅ Clear navigation pattern
2. ✅ Easy to add new routes
3. ✅ Simple to debug navigation issues
4. ✅ Comprehensive documentation
5. ✅ Code is maintainable

---

# 🔗 RELATED FEATURES

**Triggered By:**
- Feature 05: Detail + Favorite (navigation bugs)

**Affects:**
- All features with navigation
- Feature 01: IntroStateView
- Feature 02: MoodListView (observation)
- Feature 03: ArchitectureView
- Feature 04-05: CRUDListView + MoodDetailView

**Enables:**
- Feature 06+: Easy to add new routes
- Future: Deep linking support
- Future: Navigation analytics
- Future: Navigation guards/middleware

---

# 📝 IMPLEMENTATION NOTES

## Problem Timeline

1. **Initial Implementation (Feature 05):**
   - Used `NavigationLink(value: mood)`
   - Added `.navigationDestination(for: Mood.self)`
   - Seemed correct based on SwiftUI patterns

2. **Bug Discovery:**
   - User reported: "tapping mood goes to blank screen"
   - Console errors: "Failed to create 1206x0 image slot"
   - Back button behavior was erratic

3. **Root Cause Analysis:**
   - Multiple NavigationStacks detected
   - FeaturesListView had NavigationStack
   - CRUDListView tried to add destination to parent stack
   - NavigationLink events got lost/duplicated

4. **Solution Decision:**
   - Centralized Router pattern chosen
   - Single NavigationStack at root
   - All navigation via router.navigate()
   - Type-safe Route enum

5. **Implementation:**
   - Updated Router.swift with new routes
   - Refactored ContentView as navigation root
   - Removed all nested NavigationStacks
   - Replaced NavigationLinks with router.navigate()

6. **Result:**
   - All navigation works correctly
   - No more blank screens
   - Back button reliable
   - Foundation for future enhancements

## Design Decisions

### Decision 1: Route.moodDetail(mood: Mood) vs Route.moodDetail(id: String)

**Chosen:** `Route.moodDetail(mood: Mood)`

**Reasons:**
- Mood is already Hashable (via @Model)
- No need to serialize/deserialize IDs
- Direct object access in destination
- Type-safe at compile time
- Simpler code

**Trade-off:**
- Mood object in navigation path (larger memory footprint)
- But: iOS handles this efficiently
- But: Path serialization for state restoration might need adjustment later

### Decision 2: Centralized Router vs Coordinator Pattern

**Chosen:** Centralized Router with @Observable

**Reasons:**
- Simpler than full Coordinator pattern
- Leverages SwiftUI's NavigationStack
- @Observable provides reactivity
- Easy to understand and maintain
- Sufficient for app's current complexity

**Trade-off:**
- Less separation than Coordinator
- But: App doesn't need that level yet
- Can refactor to Coordinator if app grows significantly

### Decision 3: Button + router.navigate() vs Custom NavigationLink

**Chosen:** Button + router.navigate()

**Reasons:**
- Consistent pattern everywhere
- Easy to add logging/analytics
- Programmatic navigation possible
- No "magic" NavigationLink behavior
- Easier to debug

**Trade-off:**
- Slightly more verbose
- But: More explicit and predictable

---

# 🔍 DEBUGGING TIPS

## If navigation doesn't work:

1. **Check Router injection:**
   ```swift
   // In ContentView:
   .environment(router)  // Must be present
   
   // In child view:
   @Environment(Router.self) private var router  // Correct type
   ```

2. **Verify route registration:**
   ```swift
   // In ContentView.destinationView():
   case .yourRoute:  // Must have a case for each route
       YourView()
   ```

3. **Check for nested NavigationStacks:**
   ```bash
   grep -r "NavigationStack" Sources/Views/
   # Should only see in ContentView and AddMoodSheetView
   ```

4. **Enable navigation logging:**
   ```swift
   func navigate(to route: Route) {
       print("🔵 [Router] Navigating to: \(route)")
       path.append(route)
   }
   ```

5. **Inspect navigation path:**
   ```swift
   // In any view:
   @Environment(Router.self) private var router
   Text("Path: \(router.path.count) routes")  // Debug display
   ```

---

# 📚 REFERENCES

- [NavigationStack Documentation](https://developer.apple.com/documentation/swiftui/navigationstack)
- [iOS 16+ Navigation Patterns (WWDC)](https://developer.apple.com/videos/play/wwdc2022/10054/)
- [@Observable Framework](https://developer.apple.com/documentation/observation)
- [Type-Safe Routing in SwiftUI](https://www.swiftbysundell.com/articles/type-safe-routing-swiftui/)

---

## ✅ Verification Checklist

**Architecture:**
- [x] Single NavigationStack at root (ContentView)
- [x] Router created with @State
- [x] Router injected via .environment()
- [x] All routes in Route enum
- [x] All destinations in ContentView.destinationView()

**Code Changes:**
- [x] Router.swift updated with new routes
- [x] ContentView refactored as navigation root
- [x] FeaturesListView: NavigationStack removed
- [x] FeaturesListView: NavigationLinks → router.navigate()
- [x] CRUDListView: .navigationDestination removed
- [x] CRUDListView: NavigationLink → router.navigate()
- [x] MoodListView: NavigationStack removed
- [x] AddMoodSheetView: Kept as-is (modal)

**Functionality:**
- [x] Features → CRUD navigation works
- [x] CRUD → Detail navigation works
- [x] Back button works everywhere
- [x] No blank screens
- [x] No console navigation errors
- [x] Favorite toggle persists
- [x] Swipe actions work

**Documentation:**
- [x] NAVIGATION-ARCHITECTURE.md created
- [x] 05-DetailFavorite.md updated
- [x] PROMPT.md (this file) created
- [x] Migration guide documented
- [x] Test scenarios documented

---

**Refactor Complete** ✅  
**All Tests Passing** ✅  
**Documentation Complete** ✅  
**Ready for Production** ✅

