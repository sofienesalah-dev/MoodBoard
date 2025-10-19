# 🏗️ Architecture — MoodBoard

> Architecture overview of the MoodBoard demo project

---

## 📁 Project Structure

```
MoodBoard/
├── MoodBoard/
│   ├── MoodBoardApp.swift          # App entry point
│   ├── ContentView.swift           # Main view (displays FeaturesListView)
│   ├── Sources/
│   │   └── Views/
│   │       ├── FeaturesListView.swift   # Navigation hub (lists all features)
│   │       ├── IntroStateView.swift     # Feature 01: @State
│   │       └── ...                      # Future features
│   └── Assets.xcassets/
├── Docs/
│   ├── 00-Architecture.md          # This file
│   ├── 01-IntroState.md            # Feature 01 documentation
│   └── ...                         # Future feature docs
└── .prompts/
    ├── feature-templates/          # Reusable prompt templates
    └── feature-XX-name/            # Per-feature prompts & metadata
```

---

## 🧩 Navigation Architecture

### Entry Point

```
MoodBoardApp
    └── ContentView
            └── FeaturesListView  ← Navigation hub
                    ├── Feature 01: IntroStateView
                    ├── Feature 02: ...
                    └── Feature XX: ...
```

### How It Works

1. **MoodBoardApp** launches **ContentView**
2. **ContentView** displays **FeaturesListView**
3. **FeaturesListView** provides a `NavigationStack` with:
   - Sections grouping related features
   - `NavigationLink` for each feature
   - `FeatureRowView` component for consistent UI

### Adding a New Feature

To add a new feature to the navigation:

1. Create your feature view in `Sources/Views/YourFeatureView.swift`
2. Open `FeaturesListView.swift`
3. Add a new `NavigationLink`:

```swift
NavigationLink {
    YourFeatureView()
} label: {
    FeatureRowView(
        number: "02",
        title: "Your Feature Title",
        description: "Brief description of what it demonstrates",
        icon: "icon.name",  // SF Symbol name
        color: .green
    )
}
```

---

## 🎨 UI Components

### FeaturesListView
- **Purpose**: Main navigation hub
- **Type**: `NavigationStack` with `List`
- **Sections**: Groups features by theme
- **Reusability**: Add new features easily

### FeatureRowView
- **Purpose**: Reusable row component
- **Parameters**:
  - `number`: Feature number (e.g., "01")
  - `title`: Feature title
  - `description`: Brief description
  - `icon`: SF Symbol name
  - `color`: Theme color
- **Design**: Icon + text with gradient background

---

## 📚 Documentation Strategy

Each feature has:

1. **Code**: `Sources/Views/FeatureName.swift`
2. **Documentation**: `Docs/XX-FeatureName.md`
3. **Prompt**: `.prompts/feature-XX-name/PROMPT.md`
4. **Metadata**: `.prompts/feature-XX-name/output/metadata.json`
5. **Notes**: `.prompts/feature-XX-name/feature-notes.md`

---

## 🚀 Development Workflow

### Adding a New Feature

1. **Create Branch**
   ```bash
   git checkout -b feature/02-name
   ```

2. **Create Prompt**
   ```bash
   mkdir -p .prompts/feature-02-name/output
   cp .prompts/feature-templates/PROMPT_TEMPLATE.md .prompts/feature-02-name/PROMPT.md
   ```

3. **Generate Code**
   - Fill prompt variables
   - Execute prompt in Cursor
   - Code is generated in `Sources/Views/`

4. **Add to Navigation**
   - Open `FeaturesListView.swift`
   - Add `NavigationLink` with `FeatureRowView`

5. **Test**
   - Build and run
   - Navigate to your feature
   - Test functionality

6. **Commit & Push**
   ```bash
   git add -A
   git commit -m "feat(feature-02): add YourFeature"
   git push origin feature/02-name
   ```

7. **Create Pull Request**
   - Open PR on GitHub
   - Use **Copilot Reviewer** for automated code review
   - Address feedback
   - Merge to main

---

## 🎯 Design Principles

### Modularity
- Each feature is independent
- Can be viewed in isolation (Previews)
- Can be accessed via navigation

### Discoverability
- All features listed in one place
- Clear descriptions
- Visual icons for quick identification

### Consistency
- Reusable components (`FeatureRowView`)
- Consistent color schemes
- Standard SF Symbols

---

## 📊 Current Features

| # | Feature | View | Status | PR |
|---|---------|------|--------|---|
| 01 | Intro @State | `IntroStateView` | 🚧 In Review | #1 |
| 02 | @Binding | - | 🚧 Planned | - |
| 03 | @ObservableObject | - | 🚧 Planned | - |

---

**Project**: MoodBoard  
**Architecture**: NavigationStack-based demo app  
**Pattern**: Feature-driven development with Prompt-Driven approach  
**Date**: 2025-10-19

