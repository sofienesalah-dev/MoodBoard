# 🚀 Quick Start Guide — Prompt-Driven Development

## 📋 Initial Setup

The environment is now configured with:

- ✅ Global variables defined in `project-config.json`
- ✅ `.prompts/` folder structure created
- ✅ Universal prompt template available
- ✅ Feature 01 (Intro State) ready to execute
- ✅ Automatic archiving script configured

## 🎯 Next Steps

### 1. Execute the First Feature

Open the file `.prompts/feature-01-intro-state/PROMPT.md` in Cursor and execute it:

```
📁 .prompts/feature-01-intro-state/PROMPT.md
```

This prompt will generate:
- `MoodBoard/Sources/Views/IntroStateView.swift`
- `Docs/01-IntroState.md`
- Automatic archiving in `output/`

### 2. Verify Results

```bash
# View generated structure
find .prompts/feature-01-intro-state -type f

# Compile the project
xcodebuild -project MoodBoard.xcodeproj -scheme MoodBoard build

# Open in Xcode
open MoodBoard.xcodeproj
```

### 3. Archive the Feature

```bash
# Automatic archiving
./scripts/archive_prompt.sh feature-01-intro-state

# Verify archiving
ls -la .prompts/feature-01-intro-state/output/
```

## 📚 Create a New Feature

### Quick Method

```bash
# 1. Create structure
FEATURE_NUM=02
FEATURE_NAME="binding"
mkdir -p .prompts/feature-${FEATURE_NUM}-${FEATURE_NAME}/output

# 2. Copy template
cp .prompts/feature-templates/PROMPT_TEMPLATE.md \
   .prompts/feature-${FEATURE_NUM}-${FEATURE_NAME}/PROMPT.md

# 3. Edit variables in project-config.json

# 4. Adapt prompt and execute in Cursor
```

### Variables to Define

Before executing a new prompt, update `project-config.json` with:

```json
{
  "current_feature": {
    "FEATURE_SLUG": "feature-02-name",
    "FEATURE_TITLE": "Title",
    "FEATURE_DATE": "{{date}}",
    "FEATURE_OBJECTIVE": "...",
    "FEATURE_FILES": [...],
    "FEATURE_SPECIFICATIONS": "...",
    "FEATURE_ACCEPTANCE": [...]
  }
}
```

## 🔄 Complete Workflow

```
┌─────────────────────────────────────┐
│ 1. Create folder feature-XX-name/   │
└──────────────┬──────────────────────┘
               │
┌──────────────▼──────────────────────┐
│ 2. Copy & adapt PROMPT.md           │
└──────────────┬──────────────────────┘
               │
┌──────────────▼──────────────────────┐
│ 3. Execute prompt in Cursor          │
└──────────────┬──────────────────────┘
               │
┌──────────────▼──────────────────────┐
│ 4. Add to FeaturesListView          │
└──────────────┬──────────────────────┘
               │
┌──────────────▼──────────────────────┐
│ 5. Commit + Push on Git branch      │
└─────────────────────────────────────┘
```

## 📁 Final Structure

```
MoodBoard/
├── .prompts/
│   ├── project-config.json           # Global variables
│   ├── README.md                     # Documentation
│   ├── QUICKSTART.md                 # This file
│   ├── feature-templates/
│   │   └── PROMPT_TEMPLATE.md       # Universal template
│   └── feature-01-intro-state/      # First feature
│       ├── PROMPT.md                # Executable prompt
│       ├── feature-notes.md         # Notes (generated)
│       └── output/                  # Archiving (generated)
├── scripts/
│   └── archive_prompt.sh            # Archiving script
├── MoodBoard/
│   └── Sources/
│       └── Views/                   # Generated SwiftUI views
└── Docs/                            # Generated documentation
```

## 💡 Tips

### In Cursor

- Use `@.prompts/project-config.json` to reference variables
- Use `@.prompts/feature-templates/PROMPT_TEMPLATE.md` to create new features
- Enable "Long Context" mode for complex features

### Useful Scripts

```bash
# List all features
ls -la .prompts/ | grep feature-

# Count archived files
find .prompts -name "output" -type d -exec du -sh {} \;

# Search in prompts
grep -r "FEATURE_TITLE" .prompts/

# Clean archives (with caution!)
# rm -rf .prompts/feature-*/output/*
```

## 📖 Documentation

- **README**: `.prompts/README.md`
- **Template**: `.prompts/feature-templates/PROMPT_TEMPLATE.md`
- **Config**: `.prompts/project-config.json`

## 🆘 Support

In case of issues:

1. Verify structure exists: `ls -la .prompts/`
2. Verify permissions: `ls -la scripts/archive_prompt.sh`
3. Verify config: `cat .prompts/project-config.json`

---

**Ready to start?** 🚀  
Open `.prompts/feature-01-intro-state/PROMPT.md` and launch generation!
