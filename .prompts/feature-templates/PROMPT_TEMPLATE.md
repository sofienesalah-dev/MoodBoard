# 🎯 Prompt Template — Feature SwiftUI

> **Template universel** pour générer une feature SwiftUI complète avec documentation et archivage automatique.

## ⚠️ IMPORTANT RULES

- **Language**: ALL in English (code, comments, documentation)
- **Archiving**: NO file duplication in output/ (only metadata.json + feature-notes.md)
- **Comments**: All Swift comments in English
- **Documentation**: Complete documentation in English in Docs/

---

## 📋 VARIABLES DE FEATURE

```json
{
  "FEATURE_SLUG": "feature-XX-nom-court",
  "FEATURE_TITLE": "Titre de la Feature",
  "FEATURE_DATE": "{{DATE}}",
  "FEATURE_OBJECTIVE": "Objectif pédagogique de cette feature",
  "FEATURE_FILES": [
    "MoodBoard/Sources/Views/VueExemple.swift",
    "Docs/XX-Documentation.md"
  ],
  "FEATURE_SPECIFICATIONS": "Description technique détaillée",
  "FEATURE_ACCEPTANCE": [
    "Critère d'acceptation 1",
    "Critère d'acceptation 2",
    "Critère d'acceptation 3"
  ]
}
```

---

## 🧩 CONTEXTE

- **Projet** : MoodBoard
- **Stack** : iOS 17+, Swift 6, SwiftUI
- **But** : Démonstration de Prompt-Driven Development
- **Méthode** : Une feature = un prompt = une branche Git

---

## 🎯 OBJECTIF

{{FEATURE_OBJECTIVE}}

---

## 📝 SPÉCIFICATIONS TECHNIQUES

{{FEATURE_SPECIFICATIONS}}

### Fichiers à Générer

{{FEATURE_FILES}}

### Critères d'Acceptation

{{FEATURE_ACCEPTANCE}}

---

## 🧱 INSTRUCTIONS DE GÉNÉRATION

### 1️⃣ Code SwiftUI

Crée les fichiers Swift suivants avec :
- Architecture SwiftUI moderne (iOS 17+)
- Best practices Swift 6
- Documentation inline claire
- Previews fonctionnels

### 2️⃣ Documentation

Crée la documentation pédagogique dans `Docs/` avec :
- Explication du concept SwiftUI
- Code commenté
- Diagrammes si nécessaire
- Références Apple

### 3️⃣ Navigation Integration

**IMPORTANT**: Add the new view to the navigation system:
- Open `MoodBoard/Sources/Views/FeaturesListView.swift`
- Add a new `NavigationLink` in the appropriate section
- Use the `FeatureRowView` component with:
  - Feature number
  - Title
  - Description
  - Icon (SF Symbol name)
  - Color

Example:
```swift
NavigationLink {
    YourNewView()
} label: {
    FeatureRowView(
        number: "02",
        title: "Your Feature",
        description: "Brief description",
        icon: "symbol.name",
        color: .green
    )
}
```

### 4️⃣ Tests (if applicable)

Add unit or UI tests if relevant.

### 5️⃣ Archivage Automatique

À la fin de la génération :
1. Crée `.prompts/{{FEATURE_SLUG}}/output/metadata.json` avec les métadonnées
2. Crée `.prompts/{{FEATURE_SLUG}}/feature-notes.md` avec :
   - Résumé de ce qui a été généré
   - Difficultés rencontrées
   - Améliorations possibles
3. **NE PAS** dupliquer les fichiers source (ils sont déjà dans Sources/ et Docs/)
4. Vérifie que tous les critères d'acceptation sont remplis

---

## ✅ VALIDATION

Avant de terminer, vérifie :

- [ ] Tous les fichiers listés dans `FEATURE_FILES` sont créés
- [ ] Le code compile sans erreur
- [ ] Les Previews fonctionnent dans Xcode
- [ ] La documentation est claire et pédagogique
- [ ] L'archivage est complet dans `.prompts/{{FEATURE_SLUG}}/output/`
- [ ] Tous les critères d'acceptation sont remplis

---

## 🚀 COMMANDES FINALES

```bash
# Vérifier la structure
tree .prompts/{{FEATURE_SLUG}}/

# Compiler le projet
xcodebuild -project MoodBoard.xcodeproj -scheme MoodBoard build

# Créer la branche Git (si nécessaire)
git checkout -b feature/{{FEATURE_SLUG}}
```

---

**Exécute ces instructions maintenant.**  
Génère le code, la documentation, et archive tout dans `.prompts/{{FEATURE_SLUG}}/output/`.  
Termine par un résumé de ce qui a été créé et validé.

