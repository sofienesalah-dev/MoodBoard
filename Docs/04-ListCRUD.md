# Feature 04: List CRUD

**Date:** 2025-10-19  
**Status:** ✅ Completed

## 🎯 Objective

Demonstrate complete **CRUD** (Create, Read, Update, Delete) operations with SwiftData persistence using the MVVM architectural pattern.

## 📚 What You'll Learn

- **CRUD Operations**: Full lifecycle of data management
- **SwiftData Queries**: Reactive `@Query` for automatic UI updates
- **MVVM Separation**: Clear separation of concerns (Model-View-ViewModel)
- **Sheet Presentations**: Modal forms for data entry
- **Swipe Actions**: iOS-native gestures for edit/delete
- **Form Validation**: User input validation in ViewModel

## 🏗️ Architecture

### MVVM Components

```
┌─────────────────────────────────────────────────────┐
│                    CRUDListView                     │
│              (View - Presentation)                  │
│  • Displays UI                                      │
│  • Handles user interactions                        │
│  • NO business logic                                │
└────────────────┬────────────────────────────────────┘
                 │ Observes
                 ▼
┌─────────────────────────────────────────────────────┐
│                  CRUDViewModel                      │
│           (ViewModel - Business Logic)              │
│  • Validates input                                  │
│  • Manages CRUD operations                          │
│  • Handles form state                               │
└────────────────┬────────────────────────────────────┘
                 │ Operates on
                 ▼
┌─────────────────────────────────────────────────────┐
│                      Mood                           │
│              (Model - Data)                         │
│  • @Model (SwiftData)                              │
│  • Persistent storage                               │
│  • Type-safe queries                                │
└─────────────────────────────────────────────────────┘
```

## 🧱 Components

### 1. **CRUDViewModel.swift**
**Purpose:** Business logic and state management  

**Responsibilities:**
- Form state management (`selectedEmoji`, `moodLabel`, `editingMood`)
- CRUD operations:
  - `addMood()` - Create new mood
  - `startEditing()` / `saveEdit()` - Update existing mood
  - `deleteMood()` - Remove single mood
  - `clearAllMoods()` - Batch delete
- Input validation (`isFormValid`)
- Context-aware UI (`isEditing`, `submitButtonTitle`)

**Key Features:**
- Injected dependency: `ModelContext`
- `@Observable` for automatic UI updates
- Error handling with conditional compilation
- Clean state management

### 2. **CRUDListView.swift**
**Purpose:** Main list view with reactive data  

**Key Concepts:**
- **@Query**: Reactive SwiftData queries
  ```swift
  @Query(sort: \Mood.timestamp, order: .reverse)
  private var moods: [Mood]
  ```
- **Empty State**: ContentUnavailableView when no data
- **Swipe Actions**: Native iOS gestures
  - Swipe right: Edit (blue)
  - Swipe left: Delete (red)
- **Tap to Edit**: Full row tappable for editing

**UI Components:**
- Navigation toolbar with Add/Clear buttons
- Section with header and footer
- Instructional footer explaining CRUD

### 3. **AddMoodSheetView.swift**
**Purpose:** Modal form for add/edit operations  

**Features:**
- **Context-Aware**: Same sheet for add and edit
- **Emoji Picker**: Grid of selectable emojis
- **Form Validation**: Disabled submit until valid
- **Presentation Detents**: Medium/Large sizes
- **Adaptive Title**: "Add Mood" vs "Edit Mood"

**UI/UX:**
- Clear visual selection state
- Keyboard-friendly text input
- Cancel/Submit buttons in toolbar
- Accessibility labels for VoiceOver

### 4. **CRUDMoodRowView.swift**
**Purpose:** Reusable list row component  

**Design:**
- Emoji with circular background
- Label (headline) + Timestamp (relative)
- Chevron indicator for tap affordance
- Full accessibility support

## 📖 CRUD Operations Explained

### Create (C)
```swift
func addMood() {
    // Validate form (trim whitespace)
    guard isFormValid else { return }
    
    // Create model with trimmed label
    let trimmedLabel = moodLabel.trimmingCharacters(in: .whitespacesAndNewlines)
    let newMood = Mood(emoji: selectedEmoji, label: trimmedLabel)
    
    // Persist via SwiftData
    modelContext.insert(newMood)
    saveContext()
    resetForm()
}
```
**User Flow:** Tap + → Fill form → Tap Add → Mood appears in list

### Read (R)
```swift
@Query(sort: \Mood.timestamp, order: .reverse)
private var moods: [Mood]
```
**How it works:** SwiftData automatically queries database and updates UI when data changes (reactive)

### Update (U)
```swift
func saveEdit() {
    guard let mood = editingMood else { return }
    mood.emoji = selectedEmoji
    mood.label = moodLabel
    mood.timestamp = Date()
    saveContext()
}
```
**User Flow:** Tap mood → Edit in sheet → Tap Update → Changes saved

### Delete (D)
```swift
func deleteMood(_ mood: Mood) {
    modelContext.delete(mood)
    saveContext()
}
```
**User Flow:** Swipe left on mood → Tap Delete → Mood removed

## 🎨 Key SwiftUI Concepts

### @Query (SwiftData)
- **Purpose:** Reactive database queries
- **Behavior:** Auto-updates UI when data changes
- **Configuration:** Sort, filter, limit options
- **Comparison:** Similar to Room's `@Query` or Realm's `Results`

### @Observable (iOS 17+)
- **Purpose:** Modern state management
- **Replaces:** `@ObservableObject` + `@Published`
- **Benefit:** Automatic property observation using the `@Observable` macro
- **Performance:** Fine-grained observation (only re-renders what changed)

### Sheet Presentation
- **Modal UI:** Temporary overlay for focused tasks
- **Detents:** `.medium`, `.large`, or custom heights
- **Dismissal:** Swipe down or programmatic `dismiss()`

### Swipe Actions
- **Native Gesture:** iOS-standard interaction pattern
- **Edges:** Leading (left) and Trailing (right)
- **Full Swipe:** Optional quick action
- **Colors:** `.destructive` (red), `.tint()` (custom)

## 🧪 Testing the Feature

### Manual Test Checklist

- [ ] **Create**: Tap +, select emoji, enter label, tap Add
- [ ] **Read**: New mood appears in list immediately
- [ ] **Update**: Tap mood, change emoji/label, tap Update
- [ ] **Delete**: Swipe left, tap Delete
- [ ] **Batch Delete**: Tap "Clear All", all moods removed
- [ ] **Persistence**: Close app (⌘Q), relaunch → data persists
- [ ] **Validation**: Try submitting empty label → button disabled
- [ ] **Dark Mode**: Toggle appearance → UI adapts correctly
- [ ] **Accessibility**: Enable VoiceOver → all elements accessible

### Edge Cases

- [ ] Empty list shows ContentUnavailableView
- [ ] Cancel edit resets form state
- [ ] Swipe right shows Edit action (blue)
- [ ] Swipe left shows Delete action (red)
- [ ] Tap row opens edit sheet with pre-filled data

## 🌟 Best Practices Demonstrated

### 1. **MVVM Separation**
✅ **View**: Only UI and user interactions  
✅ **ViewModel**: All business logic and validation  
✅ **Model**: Data structure and persistence  

### 2. **Dependency Injection**
✅ `ModelContext` injected into ViewModel  
✅ ViewModel injected into Views  
✅ Makes testing easier (mock dependencies)  

### 3. **Accessibility**
✅ All interactive elements have labels  
✅ Custom accessibility hints  
✅ VoiceOver-friendly navigation  

### 4. **Error Handling**
✅ Try-catch for persistence operations  
✅ Conditional compilation for debug logs  
✅ Graceful failure (no crashes)  

### 5. **Code Reusability**
✅ `CRUDMoodRowView` is a standalone component  
✅ `AddMoodSheetView` handles both add and edit  
✅ ViewModel methods are small and focused  

## 🔄 Comparison with Other Frameworks

| Operation | SwiftUI/SwiftData | Android (Jetpack) | React | Flutter |
|-----------|-------------------|-------------------|-------|---------|
| **Create** | `modelContext.insert()` | `dao.insert()` | `setState()` | `collection.add()` |
| **Read** | `@Query` | `@Query` (Room) | `useQuery()` | `StreamBuilder` |
| **Update** | Modify + `save()` | `dao.update()` | `setState()` | `collection.doc().update()` |
| **Delete** | `modelContext.delete()` | `dao.delete()` | Filter + `setState()` | `collection.doc().delete()` |
| **State Management** | `@Observable` | `ViewModel` + `StateFlow` | `useState` / Context | `Provider` / `Riverpod` |

## 📦 Files Created

```
MoodBoard/Sources/
├── ViewModels/
│   └── CRUDViewModel.swift         # Business logic
└── Views/
    ├── CRUDListView.swift          # Main list view
    ├── AddMoodSheetView.swift      # Add/Edit sheet
    └── CRUDMoodRowView.swift       # Reusable row component

Docs/
└── 04-ListCRUD.md                  # This documentation
```

## 🚀 Next Steps

- **Feature 05**: Advanced queries with predicates
- **Feature 06**: Relationships between models
- **Feature 07**: Data migration and versioning
- **Feature 08**: Offline-first architecture

## 🎓 Key Takeaways

1. **@Query makes SwiftData reactive** - UI updates automatically when data changes
2. **MVVM keeps code maintainable** - Clear separation of concerns
3. **Dependency Injection enables testing** - Mock ModelContext for unit tests
4. **SwiftData is powerful** - Minimal boilerplate, maximum productivity
5. **Context-aware UI improves UX** - Same component for add/edit

---

**Feature:** `04-list-crud`  
**Date:** 2025-10-19  
**JIRA:** MOOD-4

