# 📋 .prompts/ — Feature Prompt Management

This folder centralizes all **feature prompts** for the **MoodBoard** project.

## 🎯 Objective

Demonstrate **Prompt-Driven Development**: each feature is developed via a dedicated, archived, and versioned prompt.

## 📁 Structure

```
.prompts/
├── project-config.json          # Global configuration and feature variables
├── README.md                     # This file
├── feature-templates/            # Reusable templates
│   └── PROMPT_TEMPLATE.md       # Universal prompt template
└── feature-XX-name/              # One folder per feature
    ├── PROMPT.md                # Executed prompt for this feature
    ├── feature-notes.md         # Development notes
    └── output/                  # Generated results (metadata only)
        └── metadata.json        # Feature metadata
```

## 🔄 Workflow

1. **Initialization**: Create `.prompts/feature-XX-name/` folder
2. **Prompt**: Copy template and adapt it in `PROMPT.md`
3. **Execution**: Run the prompt in Cursor
4. **Archiving**: Metadata is created in `output/`
5. **Commit**: Version the prompt and results

## 🧩 Global Variables

Feature variables are defined in `project-config.json`:

- `FEATURE_SLUG`: unique identifier (e.g., `feature-01-intro-state`)
- `FEATURE_TITLE`: short title
- `FEATURE_OBJECTIVE`: pedagogical objective
- `FEATURE_FILES`: list of files to generate
- `FEATURE_SPECIFICATIONS`: technical description
- `FEATURE_ACCEPTANCE`: acceptance criteria

## 🚀 Usage

To start a new feature:

```bash
# 1. Create structure
mkdir -p .prompts/feature-XX-name/output

# 2. Copy template
cp .prompts/feature-templates/PROMPT_TEMPLATE.md .prompts/feature-XX-name/PROMPT.md

# 3. Adapt variables in project-config.json

# 4. Execute prompt in Cursor
```

## 📚 Naming Convention

- Features: `feature-XX-short-name` (e.g., `feature-01-intro-state`)
- Git branches: `feature/XX-short-name`
- Documentation: `Docs/XX-ShortName.md`

---

**Project**: MoodBoard  
**Stack**: iOS 17+, Swift 6, SwiftUI  
**Method**: Prompt-Driven Development
