# Feature 07: App Intents

## Objective

Implement **App Intents** to allow users to add moods via **Siri**, **Shortcuts**, and **Spotlight** without opening the app.

---

## What Are App Intents?

**App Intents** is Apple's modern framework (iOS 16+) for exposing app functionality to the system:
- **Siri**: "Hey Siri, add a happy mood in MoodBoard"
- **Shortcuts**: Create custom automation workflows
- **Spotlight**: Quick actions from search results
- **Focus Filters**: Conditional app behavior based on Focus modes

### Key Benefits
- ✅ **Pure Swift API** (no .intentdefinition XML files!)
- ✅ **Type-safe parameters** with compile-time checks
- ✅ **Modern async/await** support
- ✅ **Easier testing** compared to legacy SiriKit

---

## Architecture

### 1. Intent Definition

```swift
struct AddMoodIntent: AppIntent {
    static var title: LocalizedStringResource = "Add Mood"
    static var description = IntentDescription("Add a new mood to your MoodBoard")
    
    @Parameter(title: "Mood Title")
    var title: String
    
    @Parameter(title: "Emoji", default: "😊")
    var emoji: String?
    
    @MainActor
    func perform() async throws -> some IntentResult & ProvidesDialog {
        // Intent logic here
    }
}
```

### 2. App Shortcuts (Discovery)

```swift
struct MoodBoardShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: AddMoodIntent(),
            phrases: [
                "Add a mood in \(.applicationName)",
                "Log my mood in \(.applicationName)"
            ],
            shortTitle: "Add Mood",
            systemImageName: "face.smiling"
        )
    }
}
```

---

## Implementation Details

### Background Execution

App Intents run in a **separate process** from your main app:
- ✅ Can execute when app is closed
- ⚠️ Need separate `ModelContainer` for SwiftData
- ⚠️ Cannot access `@Environment` objects from app

### SwiftData Integration

```swift
@MainActor
func perform() async throws -> some IntentResult {
    // Create separate container for background context
    guard let container = try? ModelContainer(for: Mood.self) else {
        throw IntentError.databaseError("Failed to initialize database")
    }
    
    let context = ModelContext(container)
    
    // Insert and save
    let mood = Mood(emoji: emoji, label: title)
    context.insert(mood)
    try context.save()
    
    return .result(dialog: "Mood added!")
}
```

### Error Handling

Custom errors must conform to `CustomLocalizedStringResourceConvertible`:

```swift
enum IntentError: Error, CustomLocalizedStringResourceConvertible {
    case invalidInput(String)
    case databaseError(String)
    
    var localizedStringResource: LocalizedStringResource {
        switch self {
        case .invalidInput(let msg):
            return "Invalid Input: \(msg)"
        case .databaseError(let msg):
            return "Database Error: \(msg)"
        }
    }
}
```

---

## Testing App Intents

### 1. Via Shortcuts App

1. Open **Shortcuts** app on iOS
2. Tap **+** to create new shortcut
3. Search for "Add Mood"
4. Configure parameters (title, emoji)
5. Run the shortcut

### 2. Via Siri

Say: *"Hey Siri, add a happy mood in MoodBoard"*

Siri will:
1. Recognize the phrase from `AppShortcut.phrases`
2. Extract parameters from natural language
3. Prompt for missing required parameters
4. Execute the intent
5. Display the confirmation dialog

### 3. Via Spotlight

1. Swipe down on Home Screen
2. Type "Add Mood"
3. Tap the "Add Mood in MoodBoard" action
4. Enter parameters
5. Run

### 4. Programmatic Testing (Debug)

```swift
Task {
    let intent = AddMoodIntent()
    intent.title = "Test Mood"
    intent.emoji = "🧪"
    
    do {
        let result = try await intent.perform()
        print("✅ Intent executed: \(result)")
    } catch {
        print("❌ Intent failed: \(error)")
    }
}
```

---

## Comparison with Other Frameworks

### Android: App Actions & Slices

```kotlin
// Android App Actions (similar concept)
class AddMoodAction : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        val title = intent.getStringExtra("title")
        // Add mood logic
    }
}
```

**Similarities:**
- Voice assistant integration (Google Assistant)
- System-level shortcuts
- Background execution

**Differences:**
- Android uses XML configuration (BII - Built-in Intents)
- SwiftUI has better type safety
- iOS has unified API for Siri/Shortcuts/Spotlight

### Web: Web Share Target API

```javascript
// Web App Manifest (share target)
{
  "share_target": {
    "action": "/add-mood",
    "method": "POST",
    "params": {
      "title": "mood_title",
      "text": "mood_description"
    }
  }
}
```

**Similarities:**
- Allow system-level actions to trigger app functionality
- No need to open app UI

**Differences:**
- Web Share is limited to sharing content
- App Intents offer much broader system integration

---

## Structured Prompts for AI Integration

App Intents can be enhanced with **structured prompts** for better AI understanding:

### Example: Mood Analysis with LLM

```swift
struct AnalyzeMoodIntent: AppIntent {
    static var title: LocalizedStringResource = "Analyze My Moods"
    
    @MainActor
    func perform() async throws -> some IntentResult & ProvidesDialog {
        let container = try ModelContainer(for: Mood.self)
        let context = ModelContext(container)
        
        // Fetch recent moods
        let descriptor = FetchDescriptor<Mood>(
            sortBy: [SortDescriptor(\.timestamp, order: .reverse)]
        )
        let moods = try context.fetch(descriptor).prefix(10)
        
        // Create structured prompt for LLM
        let prompt = """
        Analyze these recent moods and provide insights:
        \(moods.map { "\($0.emoji) \($0.label) - \($0.timestamp.formatted())" }.joined(separator: "\n"))
        
        Provide:
        1. Overall emotional trend
        2. Patterns or triggers
        3. Suggestions for well-being
        """
        
        // TODO: Send to OpenAI/Claude API
        // let analysis = await analyzeMoods(prompt: prompt)
        
        return .result(dialog: "Analysis complete!")
    }
}
```

### Prompt Engineering Best Practices

1. **Be Specific**: Clearly define expected output format
2. **Provide Context**: Include relevant mood history
3. **Structure Data**: Use consistent formatting (JSON, CSV, etc.)
4. **Handle Errors**: Gracefully handle API failures

---

## Advanced Use Cases

### 1. Conditional Shortcuts (Focus Filters)

Allow users to filter moods based on current Focus mode:

```swift
struct GetCurrentMoodIntent: AppIntent {
    static var title: LocalizedStringResource = "Get Current Mood"
    
    func perform() async throws -> some IntentResult & ReturnsValue<String> {
        // Check current Focus mode
        // Return mood suggestions based on context
        return .result(value: "😊 Happy")
    }
}
```

### 2. Siri Disambiguation

Handle ambiguous user input:

```swift
@Parameter(title: "Mood Category")
var category: MoodCategory
```

```swift
enum MoodCategory: String, AppEnum {
    case happy = "Happy"
    case sad = "Sad"
    case energetic = "Energetic"
    
    static var typeDisplayRepresentation = TypeDisplayRepresentation(name: "Mood Category")
    static var caseDisplayRepresentations: [Self: DisplayRepresentation] = [
        .happy: "😊 Happy",
        .sad: "😢 Sad",
        .energetic: "⚡ Energetic"
    ]
}
```

### 3. Background Refresh Integration

Combine with Background Tasks for proactive suggestions:

```swift
// Suggest mood check based on time of day
func scheduleProactiveSuggestion() {
    let request = BGAppRefreshTaskRequest(identifier: "com.moodboard.suggest")
    request.earliestBeginDate = Date(timeIntervalSinceNow: 3600) // 1 hour
    
    try? BGTaskScheduler.shared.submit(request)
}
```

---

## Privacy & Permissions

### Required Entitlements

No special entitlements needed for basic App Intents!

### Privacy Considerations

- ❌ **No PHPickerViewController** needed (unlike Photos intents)
- ❌ **No location permissions** (unless intent uses location)
- ✅ **Sandboxed execution** (cannot access arbitrary files)

### User Consent

- First time: iOS prompts "Allow MoodBoard to use Shortcuts?"
- Users can revoke access in Settings > Shortcuts > MoodBoard

---

## Debugging Tips

### 1. Enable Intent Logging

```swift
#if DEBUG
print("🔍 [AddMoodIntent] perform() called")
print("  - title: \(title)")
print("  - emoji: \(emoji ?? "nil")")
#endif
```

### 2. Test with Shortcuts Console

1. Open Shortcuts app
2. Run shortcut
3. Check **Details** panel for errors
4. View execution timeline

### 3. Xcode Console Filtering

Filter by process name:
```
process:com.apple.shortcuts
```

### 4. Common Issues

| Issue | Solution |
|-------|----------|
| Intent not appearing in Shortcuts | Rebuild app, wait 30s for indexing |
| "No response" from Siri | Check `ProvidesDialog` conformance |
| Database errors | Ensure separate `ModelContainer` created |
| Parameters not extracted | Verify `@Parameter` configuration |

---

## Performance Best Practices

### 1. Keep Intents Fast

- ⚠️ Timeout after **10 seconds** (iOS will kill process)
- ✅ Use background tasks for long operations
- ✅ Cache frequently accessed data

### 2. Minimize Dependencies

- ❌ Avoid importing large frameworks
- ✅ Use `@preconcurrency import` for legacy code
- ✅ Keep intent logic in separate module if needed

### 3. Optimize SwiftData Queries

```swift
// ❌ Slow: Fetch all then filter
let allMoods = try context.fetch(FetchDescriptor<Mood>())
let favorites = allMoods.filter { $0.isFavorite }

// ✅ Fast: Filter in database
var descriptor = FetchDescriptor<Mood>(
    predicate: #Predicate { $0.isFavorite == true }
)
let favorites = try context.fetch(descriptor)
```

---

## Next Steps

### Feature Enhancements

1. **Mood Categories**: Add enum parameter for better categorization
2. **Recurring Shortcuts**: Schedule daily mood check-ins
3. **Widgets Integration**: Show recent moods from intents
4. **Watch App**: Add moods from Apple Watch via intents

### Learning Resources

- [App Intents Documentation](https://developer.apple.com/documentation/appintents)
- [WWDC 2022: Dive into App Intents](https://developer.apple.com/videos/play/wwdc2022/10032/)
- [WWDC 2023: Explore enhancements to App Intents](https://developer.apple.com/videos/play/wwdc2023/10103/)

---

## Summary

✅ **What We Built:**
- `AddMoodIntent` with title and emoji parameters
- `MoodBoardShortcuts` for Siri phrase recognition
- SwiftData integration for background persistence
- Custom error handling

✅ **What Users Can Do:**
- "Hey Siri, add a happy mood in MoodBoard"
- Create custom Shortcuts workflows
- Quick actions from Spotlight

✅ **Key Takeaways:**
- App Intents are modern, type-safe, and pure Swift
- Background execution requires separate `ModelContainer`
- Excellent for AI integration (structured prompts)
- Great user experience (no need to open app)

---

**Date**: 2025-10-23  
**Feature**: 07-app-intents  
**iOS Version**: 16.0+  
**Framework**: App Intents, SwiftData

