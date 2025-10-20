# Feature 05: Detail + Favorite

**Date:** 2025-10-20  
**Status:** ✅ Completed

## 🎯 Objective

Implement a **detail view** with **favorite toggle** functionality, demonstrating type-safe navigation, reusable components, and persistent state management with SwiftData.

## 📚 What You'll Learn

- **Type-Safe Navigation**: NavigationStack with value-based destinations
- **@Bindable**: Two-way binding for model mutations
- **Reusable Components**: Building composable UI elements
- **Persistent Favorites**: State that survives app restarts
- **Detail Views**: Rich information display with interactions
- **Share Functionality**: iOS native sharing capabilities

## 🏗️ Architecture

### Navigation Flow

```
┌──────────────────────────────────────────────────────┐
│                 CRUDListView                         │
│  • @Query fetches all moods                         │
│  • NavigationLink(value: mood)                      │
└────────────────┬─────────────────────────────────────┘
                 │ Taps mood
                 ▼
┌──────────────────────────────────────────────────────┐
│             NavigationDestination                    │
│  .navigationDestination(for: Mood.self)             │
└────────────────┬─────────────────────────────────────┘
                 │ Presents
                 ▼
┌──────────────────────────────────────────────────────┐
│              MoodDetailView                          │
│  • @Bindable var mood: Mood                         │
│  • Large emoji display                               │
│  • FavoriteButton in toolbar                        │
│  • Share functionality                               │
│  • Info cards for metadata                          │
└────────────────┬─────────────────────────────────────┘
                 │ Uses
                 ▼
┌──────────────────────────────────────────────────────┐
│              FavoriteButton                          │
│  • @Binding var isFavorite: Bool                    │
│  • Animated heart icon                               │
│  • Haptic feedback                                   │
└──────────────────────────────────────────────────────┘
```

### Data Flow

```
User Taps Heart
    ↓
FavoriteButton toggles @Binding
    ↓
@Bindable propagates change to Mood object
    ↓
SwiftData automatically persists change
    ↓
@Query in list reflects update
```

## 🧱 Components

### 1. **Mood.swift** (Updated)
**Purpose:** Data model with favorite support  

**Changes:**
```swift
@Model
final class Mood {
    var emoji: String
    var label: String
    var timestamp: Date
    var isFavorite: Bool  // ✨ NEW property
    
    init(emoji: String, label: String, 
         timestamp: Date = Date(), 
         isFavorite: Bool = false) {  // ✨ Default to false
        self.emoji = emoji
        self.label = label
        self.timestamp = timestamp
        self.isFavorite = isFavorite
    }
}
```

**Key Concepts:**
- **Schema Evolution**: Adding new properties to existing `@Model`
- **Default Values**: `isFavorite: Bool = false` ensures backward compatibility
- **Automatic Persistence**: SwiftData tracks changes to all properties

**Migration Strategy:**
- For development: Automatic data reset in `MoodBoardApp.swift`
- For production: Would use SwiftData migration plan

### 2. **FavoriteButton.swift**
**Purpose:** Reusable favorite toggle component  

**Signature:**
```swift
struct FavoriteButton: View {
    @Binding var isFavorite: Bool
    var onToggle: (() -> Void)? = nil
    
    var body: some View {
        Button { /* ... */ } label: {
            Image(systemName: isFavorite ? "heart.fill" : "heart")
                .foregroundStyle(isFavorite ? .red : .gray)
                // Animations...
        }
    }
}
```

**Features:**
- **@Binding**: Two-way data flow with parent
- **Animated Transitions**: 
  - Spring animation on toggle
  - Scale effect (1.0 → 1.1)
  - Rotation (0° → 360°)
- **Haptic Feedback**: `UIImpactFeedbackGenerator` on iOS
- **Optional Callback**: `onToggle` for side effects (analytics, etc.)
- **Accessibility**: Dynamic labels and hints

**Comparison with Other Frameworks:**
```typescript
// React equivalent
const FavoriteButton = ({ isFavorite, onChange }) => {
  return (
    <button onClick={() => onChange(!isFavorite)}>
      {isFavorite ? '❤️' : '🤍'}
    </button>
  );
};

// Android equivalent (Compose)
@Composable
fun FavoriteButton(isFavorite: Boolean, onToggle: () -> Unit) {
    IconButton(onClick = onToggle) {
        Icon(
            imageVector = if (isFavorite) Icons.Filled.Favorite else Icons.Outlined.FavoriteBorder,
            tint = if (isFavorite) Color.Red else Color.Gray
        )
    }
}
```

### 3. **MoodDetailView.swift**
**Purpose:** Rich detail view for a single mood  

**Key Properties:**
```swift
struct MoodDetailView: View {
    @Bindable var mood: Mood  // ✨ Two-way binding for mutations
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ScrollView {
            // Hero emoji
            // Mood info
            // Metadata cards
            // Actions
        }
        .toolbar {
            FavoriteButton(isFavorite: $mood.isFavorite)
        }
    }
}
```

**UI Sections:**

1. **Hero Emoji**
   - Large emoji (100pt)
   - Gradient circle background
   - Decorative accessibility

2. **Mood Info**
   - Label (largeTitle)
   - Relative timestamp ("2 hours ago")

3. **Metadata Cards** (Reusable `InfoCard` component)
   - Recorded timestamp (absolute)
   - Favorite status

4. **Actions**
   - Share button (native iOS sharing)
   - Instructional hints

**Share Functionality:**
```swift
private func shareMood() {
    let text = "\(mood.emoji) \(mood.label)\nRecorded \(mood.timestamp.formatted(.relative(presentation: .named)))"
    
    let activityVC = UIActivityViewController(
        activityItems: [text],
        applicationActivities: nil
    )
    // Present from root view controller
}
```

### 4. **CRUDListView.swift** (Updated)
**Purpose:** Add navigation to detail view  

**Changes:**

1. **Router-Based Navigation (Centralized)**
   ```swift
   // Inject Router from environment
   @Environment(Router.self) private var router
   
   // Use Button instead of NavigationLink
   Button {
       router.navigate(to: .moodDetail(mood: mood))
   } label: {
       CRUDMoodRowView(mood: mood)
   }
   // Swipe right to edit still available
   ```

2. **No Local Navigation Destination**
   ```swift
   // ❌ OLD (removed):
   .navigationDestination(for: Mood.self) { mood in
       MoodDetailView(mood: mood)
   }
   
   // ✅ NEW: Navigation handled by ContentView's centralized router
   // All destinations registered in one place
   ```

3. **Updated Footer Instructions**
   ```swift
   Text("• **Detail**: Tap a mood to view details & toggle favorite ❤️")
   ```

**Note:** Navigation architecture was refactored to use a centralized Router pattern. See `Docs/NAVIGATION-ARCHITECTURE.md` for details.

## 🔄 Key Concepts

### Type-Safe Navigation

**Traditional (String-based):**
```swift
// ❌ Prone to errors
NavigationLink(destination: DetailView(id: "123"))
```

**Modern (Centralized Router with PersistentIdentifier):**
```swift
// ✅ Type-safe with centralized routing
@Environment(Router.self) private var router

Button {
    // Navigate by PersistentIdentifier (Hashable & Codable)
    router.navigate(to: .moodDetail(id: mood.persistentModelID))
} label: {
    MoodRowView(mood: mood)
}

// In ContentView (root):
.navigationDestination(for: Route.self) { route in
    switch route {
    case .moodDetail(let id):
        // Resolve Mood from PersistentIdentifier using SwiftData
        if let mood = modelContext.model(for: id) as? Mood {
            MoodDetailView(mood: mood)
        } else {
            ContentUnavailableView("Mood Not Found", ...)
        }
    // ... other routes
    }
}
```

**Benefits:**
- ✅ Compile-time safety (Route enum)
- ✅ Single source of truth (centralized)
- ✅ **ID-based navigation** (PersistentIdentifier is Hashable & Codable)
- ✅ **Handles deleted objects gracefully** (shows error view)
- ✅ Programmatic navigation from anywhere
- ✅ Easy to add analytics, logging, deep links
- ✅ Navigation state can be saved/restored
- ✅ Clean SwiftData integration - no string parsing

**Requirements:**
- `Route` enum must be `Hashable`
- `Mood` must be `Hashable` (automatic with `@Model`)

**See Also:** `Docs/NAVIGATION-ARCHITECTURE.md` for complete navigation refactor documentation.

### @Bindable vs @Binding

| Feature | @Binding | @Bindable |
|---------|----------|-----------|
| **Purpose** | Two-way binding to primitive value | Two-way binding to `@Observable` object |
| **Usage** | `@Binding var count: Int` | `@Bindable var mood: Mood` |
| **$ Syntax** | Source provides `$count` | `@Bindable` enables `$mood.property` |
| **Mutations** | Updates parent's value | Mutates object properties directly |
| **Persistence** | Manual save needed | SwiftData auto-tracks changes |

**Example:**
```swift
// @Binding - for simple values
struct ToggleView: View {
    @Binding var isOn: Bool  // Parent owns the value
}

// @Bindable - for @Observable objects
struct DetailView: View {
    @Bindable var mood: Mood  // Direct object mutation
    
    var body: some View {
        Toggle("Favorite", isOn: $mood.isFavorite)  // ✨ $mood syntax
        TextField("Label", text: $mood.label)
    }
}
```

### Reusable Components

**FavoriteButton** demonstrates key principles:

1. **Single Responsibility**: Only handles favorite toggle
2. **Composition**: Can be used anywhere
3. **Flexible API**: Required `@Binding` + optional callback
4. **Self-Contained**: Includes its own styling and animations
5. **Testable**: Easy to preview and test in isolation

**Usage Examples:**
```swift
// In toolbar
.toolbar {
    FavoriteButton(isFavorite: $mood.isFavorite)
}

// In list row
HStack {
    MoodRowView(mood: mood)
    FavoriteButton(isFavorite: $mood.isFavorite)
}

// With analytics
FavoriteButton(isFavorite: $mood.isFavorite) {
    Analytics.log("favorite_toggled", mood.id)
}
```

## 📊 Data Persistence

### How Favorites Persist

```swift
// 1. User taps heart in FavoriteButton
Button {
    isFavorite.toggle()  // @Binding updates source
}

// 2. @Bindable propagates to Mood object
@Bindable var mood: Mood
FavoriteButton(isFavorite: $mood.isFavorite)  // Direct binding

// 3. SwiftData automatically tracks change
// No explicit save() needed!
// mood.isFavorite mutation is observed by ModelContext

// 4. @Query in list automatically updates
@Query(sort: \Mood.timestamp, order: .reverse)
private var moods: [Mood]
// UI reflects new favorite status immediately
```

**Why This Works:**
- `@Model` objects are observable by SwiftData
- `ModelContext` tracks all property changes
- Changes auto-save on context commit
- `@Query` reactively updates views

## 🎨 UI/UX Enhancements

### Animations

**FavoriteButton Animations:**
```swift
.scaleEffect(isFavorite ? 1.1 : 1.0)  // Slight grow
.rotationEffect(.degrees(isFavorite ? 360 : 0))  // Full rotation
.animation(.spring(response: 0.3, dampingFraction: 0.6), value: isFavorite)
```

**Spring Parameters:**
- `response: 0.3` - Animation duration (fast)
- `dampingFraction: 0.6` - Bounciness (moderate)

### Haptic Feedback

```swift
#if os(iOS)
let impact = UIImpactFeedbackGenerator(style: .light)
impact.impactOccurred()
#endif
```

**Styles:**
- `.light` - Subtle feedback (perfect for toggles)
- `.medium` - Standard feedback
- `.heavy` - Strong feedback (destructive actions)

### Info Cards

Reusable component for displaying metadata:
```swift
InfoCard(
    icon: "clock",
    title: "Recorded",
    value: mood.timestamp.formatted(date: .long, time: .shortened),
    color: .blue
)
```

**Design:**
- Colored icon in circle
- Title + value layout
- Rounded rectangle with shadow
- Combined accessibility element

## 🧪 Testing

### Preview Strategies

**1. Different States**
```swift
#Preview("Not Favorite") {
    NavigationStack {
        MoodDetailView(mood: Mood.samples[1])  // isFavorite = false
    }
}

#Preview("Favorite") {
    NavigationStack {
        MoodDetailView(mood: Mood.samples[0])  // isFavorite = true
    }
}
```

**2. Dark Mode**
```swift
#Preview("Dark Mode") {
    NavigationStack {
        MoodDetailView(mood: Mood.samples[0])
    }
    .preferredColorScheme(.dark)
}
```

**3. Interactive Components**
```swift
#Preview("Interactive") {
    @Previewable @State var isFavorite = false
    
    FavoriteButton(isFavorite: $isFavorite) {
        print("Toggled: \(isFavorite)")
    }
}
```

## 📱 User Flow

1. **Browse List**
   - User sees moods in `CRUDListView`
   - Each row is tappable (NavigationLink)

2. **Tap Mood**
   - Navigation pushes `MoodDetailView`
   - Large emoji and details appear
   - Heart button visible in toolbar

3. **Toggle Favorite**
   - Tap heart icon
   - Animated scale + rotation
   - Haptic feedback
   - Color changes (gray → red)
   - Change persists immediately

4. **Navigate Back**
   - Swipe back or tap back button
   - List shows updated favorite status
   - No manual refresh needed

5. **Share (Optional)**
   - Tap "Share Mood" button
   - iOS share sheet appears
   - Can share to Messages, Notes, etc.

## 🔍 Common Patterns

### Pattern 1: Master-Detail

```swift
// List (Master)
List {
    ForEach(items) { item in
        NavigationLink(value: item) {
            RowView(item: item)
        }
    }
}
.navigationDestination(for: Item.self) { item in
    DetailView(item: item)  // Detail
}
```

### Pattern 2: Reusable Toggle Button

```swift
struct ReusableToggleButton: View {
    @Binding var isOn: Bool
    let onIcon: String
    let offIcon: String
    let onColor: Color
    let offColor: Color
    
    var body: some View {
        Button {
            withAnimation {
                isOn.toggle()
            }
        } label: {
            Image(systemName: isOn ? onIcon : offIcon)
                .foregroundStyle(isOn ? onColor : offColor)
        }
    }
}
```

### Pattern 3: Model Mutation with Persistence

```swift
struct EditView: View {
    @Bindable var item: Item  // SwiftData @Model
    
    var body: some View {
        Form {
            TextField("Name", text: $item.name)  // Auto-persists
            Toggle("Enabled", isOn: $item.isEnabled)  // Auto-persists
            DatePicker("Date", selection: $item.date)  // Auto-persists
        }
        // No save button needed!
    }
}
```

## 💡 Best Practices

### 1. Component Reusability
✅ **DO:**
```swift
// Generic, reusable
struct FavoriteButton: View {
    @Binding var isFavorite: Bool
}
```

❌ **DON'T:**
```swift
// Tightly coupled
struct MoodFavoriteButton: View {
    let mood: Mood  // Now only works with Mood
}
```

### 2. Navigation
✅ **DO:**
```swift
// Value-based, type-safe
NavigationLink(value: mood) {
    MoodRow(mood: mood)
}
```

❌ **DON'T:**
```swift
// String-based, error-prone
NavigationLink(destination: DetailView(id: mood.id.uuidString))
```

### 3. Animations
✅ **DO:**
```swift
// Explicit animation trigger
.animation(.spring(), value: isFavorite)
```

❌ **DON'T:**
```swift
// Implicit animations (deprecated in iOS 15+)
.animation(.spring())
```

### 4. Accessibility
✅ **DO:**
```swift
Button("Favorite") { }
    .accessibilityLabel(isFavorite ? "Remove from favorites" : "Add to favorites")
    .accessibilityHint("Double tap to toggle")
```

❌ **DON'T:**
```swift
// No accessibility support
Image(systemName: "heart")
```

## 🐛 Common Issues

### Issue 1: Changes Not Persisting

**Symptom:** Favorite status resets after app restart

**Cause:** Not using `@Bindable` or using `let` instead of `var`

**Solution:**
```swift
// ❌ Wrong
let mood: Mood
FavoriteButton(isFavorite: $mood.isFavorite)  // Compiler error

// ✅ Correct
@Bindable var mood: Mood
FavoriteButton(isFavorite: $mood.isFavorite)  // Mutations persist
```

### Issue 2: Navigation Not Working

**Symptom:** Tapping mood does nothing

**Cause:** Missing `.navigationDestination` modifier

**Solution:**
```swift
NavigationStack {
    List {
        NavigationLink(value: mood) { }
    }
    .navigationDestination(for: Mood.self) { mood in  // ✨ Don't forget this!
        DetailView(mood: mood)
    }
}
```

### Issue 3: @Query Not Updating

**Symptom:** List doesn't reflect favorite changes

**Cause:** Using different `ModelContext` instances

**Solution:**
```swift
// Ensure same context
@Environment(\.modelContext) private var modelContext

// ViewModel uses same context
CRUDViewModel(modelContext: modelContext)
```

## 📚 Further Reading

- [SwiftData Documentation](https://developer.apple.com/documentation/swiftdata)
- [NavigationStack](https://developer.apple.com/documentation/swiftui/navigationstack)
- [@Bindable Documentation](https://developer.apple.com/documentation/swiftui/bindable)
- [Haptic Feedback Guidelines](https://developer.apple.com/design/human-interface-guidelines/playing-haptics)

## ✅ Checklist

Feature 05 Implementation:

- [x] Add `isFavorite` property to `Mood` model
- [x] Update sample data with favorite states
- [x] Handle schema migration in `MoodBoardApp`
- [x] Create `FavoriteButton` reusable component
- [x] Implement animations and haptics
- [x] Create `MoodDetailView` with rich UI
- [x] Add info cards for metadata
- [x] Implement share functionality
- [x] Update `CRUDListView` with NavigationLink
- [x] Add `.navigationDestination` handler
- [x] Update footer instructions
- [x] Add Feature 05 to `FeaturesListView`
- [x] Test favorite persistence
- [x] Test navigation flow
- [x] Verify accessibility
- [x] Create comprehensive documentation

---

## 🔄 Navigation Refactor (Post-Implementation)

**Date:** 2025-10-20 (same day as Feature 05)

After implementing Feature 05, navigation was experiencing bugs (detail view not showing, blank screens, back button issues). This was due to **multiple nested NavigationStacks** interfering with each other.

**Solution:** Complete navigation architecture refactor to use a **centralized Router pattern**.

**Key Changes:**
- Single `NavigationStack` at root (`ContentView`)
- Centralized `Router` class managing navigation state
- All views use `router.navigate(to:)` instead of `NavigationLink`
- Type-safe `Route` enum for all destinations
- No more nested NavigationStacks (except modal sheets)

**Documentation:** See `Docs/NAVIGATION-ARCHITECTURE.md` for complete details.

**Prompt Archive:** See `.prompts/navigation-refactor/PROMPT.md`

---

**Next Steps:** Feature 06 could explore `@Environment` for app-wide settings, theme management, or custom environment values.

