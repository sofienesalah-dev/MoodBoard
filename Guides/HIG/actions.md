# Actions - Human Interface Guidelines

## Button and Action Design

- **Use clear, action-oriented labels** - "Save", "Delete", not "OK", "Cancel"
- **Provide visual feedback** - Buttons should respond to touch immediately
- **Size tap targets appropriately** - Minimum 44x44 points
- **Use SF Symbols for common actions** - Consistency with system conventions
- **Place primary actions prominently** - Bottom-right or leading position
- **Use Button roles** (.destructive, .cancel) for semantic meaning
- **Disable unavailable actions** - Don't hide, disable with context
- **Confirm destructive actions** - Use .confirmationDialog() for irreversible operations
- **Support keyboard shortcuts** - .keyboardShortcut() for power users

## Button Styles
* .borderedProminent for primary actions
* .bordered for secondary actions  
* .plain or .borderless for tertiary actions

