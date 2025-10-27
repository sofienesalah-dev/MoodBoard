# MoodBoard

MoodBoard is a teaching-first SwiftUI app that walks through the process of building a modern mood-tracking experience. The repository showcases SwiftData persistence, MVVM architecture, type-safe navigation, and multiple Apple Intelligence integrations designed for iOS 26.0 and newer.

## Highlights

- **Intro @State (Feature 01)**: SwiftUI fundamentals and local state management.
- **Observation (Feature 02)**: Modern reactive model powered by `@Observable` and `@Bindable`.
- **Architecture (Feature 03)**: Clean MVVM layering with SwiftData and an enum-driven router.
- **CRUD + Detail (Features 04-05)**: Persistent mood list, detail screen, favorites, and sharing.
- **App Intents (Feature 07)**: Log and query moods via Siri, Shortcuts, and Spotlight.
- **Apple Intelligence (Feature 12)**: On-device sentiment analysis, pattern detection, and coaching tips.

## Architecture at a Glance

- **Centralized navigation**: `ContentView` owns a shared `Router` and a single `NavigationStack` (see `MoodBoard/ContentView.swift` and `MoodBoard/Sources/Navigation/Router.swift`).
- **SwiftData persistence**: `MoodBoardApp` configures a shared `ModelContainer` for `Mood` and legacy `Item` models.
- **ViewModel layer**: `@Observable` view models (`MoodViewModel`, `CRUDViewModel`, `AppleIntelligenceViewModel`) orchestrate business logic and state.
- **Modular AI services**: `SentimentAnalyzer`, `EmojiPredictor`, `MoodPatternDetector`, and `SmartSuggestions` encapsulate all machine-learning style processing.
- **App Intents and extensions**: `MoodBoard/Sources/Intents` exposes Apple Intelligence-friendly commands.

## Prerequisites

- macOS 14.4 or newer.
- Xcode 16.0 or newer (iOS 26.0 toolchain).
- iOS simulator or device running iOS 26.0+.

## Getting Started

1. Clone the repository: `git clone https://github.com/<your-handle>/MoodBoard.git`
2. Open the project: `open MoodBoard.xcodeproj`
3. Select the `MoodBoard` target and run (`Cmd+R`) on an iOS 26.0+ simulator or device.
4. Browse the experiences from the `FeaturesListView` landing page.

### Quick Preview Tour

- Each feature view ships with a ready-to-use `#Preview`.
- Previews rely on `ModelContainer.preview` to inject sample data via `Mood.insertSamples`.

## Testing

- In Xcode: `Product ▸ Test` (shortcut `Cmd+U`).
- From the command line:

```bash
xcodebuild test \
  -project MoodBoard.xcodeproj \
  -scheme MoodBoard \
  -destination 'platform=iOS Simulator,name=iPhone 17,OS=26.0'
```

Test targets `MoodBoardTests` and `MoodBoardUITests` cover critical components and core flows.

## Project Structure

- `MoodBoard/`: Application target (app entry point, ContentView, resources).
- `MoodBoard/Sources/Models/`: SwiftData models (`Mood`, `MoodStore`).
- `MoodBoard/Sources/ViewModels/`: MVVM coordination logic.
- `MoodBoard/Sources/Views/`: SwiftUI screens for each feature, CRUD, detail, and AI experiences.
- `MoodBoard/Sources/Services/AI/`: AI-style analysis and suggestion services.
- `MoodBoard/Sources/Navigation/`: Router, route definitions, and helpers.
- `MoodBoard/Sources/Intents/`: App Intents for Apple Intelligence and system integrations.
- `Docs/`: Feature briefs and architecture notes.
- `Guides/`: UI and navigation references inspired by the Human Interface Guidelines.

## On-Device Intelligence and Privacy

- **Sentiment analysis**: `SentimentAnalyzer` returns tone, score, and follow-up guidance.
- **Emoji predictions**: `EmojiPredictor` suggests relevant emojis and adapts to user choices.
- **Pattern detection**: `MoodPatternDetector` surfaces trends, weekly summaries, and alerts.
- **Writing suggestions**: `SmartSuggestions` offers light-touch rewrites and prompts.
- All AI processing is performed on-device; no mood data leaves the user’s hardware.

## Helpful Internal Docs

- `Docs/NAVIGATION-ARCHITECTURE.md`: Deep dive on the centralized routing approach.
- `Docs/05-DetailFavorite.md`: Blueprint for the detail screen and favorite toggle.
- `.prompts/`: Prompt-driven development history used during internal training.

## Roadmap

- Bring Feature 06 (cross-platform comparison) into the live app.
- Add an animation showcase for Feature 08.
- Explore widgets and Live Activity support for ongoing mood tracking.

---

Questions or ideas for improvements? Open an issue or reach out to the MoodBoard team.
