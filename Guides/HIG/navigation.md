# Navigation - Human Interface Guidelines

## SwiftUI Navigation Best Practices

- **Use NavigationStack** for hierarchical navigation (iOS 16+)
- **Provide clear back navigation** - Users should always know how to return
- **Use TabView for top-level navigation** - Limit to 5 tabs maximum
- **Avoid deep navigation hierarchies** - Keep it under 3-4 levels
- **Use .navigationTitle()** to provide context at each level
- **Consider NavigationSplitView** for iPad and large screens
- **Make navigation predictable** - Users should anticipate where they'll go
- **Test navigation with VoiceOver** - Ensure screen readers can navigate effectively

## Common Patterns
* NavigationStack + NavigationLink for push navigation
* Sheet/fullScreenCover for modal presentations
* TabView for parallel information spaces

