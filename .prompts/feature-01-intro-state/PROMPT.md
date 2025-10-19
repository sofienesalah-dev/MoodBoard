# 🎯 Feature 01 — Intro State

> Première feature du projet MoodBoard : introduction au paradigme déclaratif SwiftUI via `@State`.

## ⚠️ IMPORTANT RULES

- **Language**: ALL in English (code, comments, documentation)
- **Archiving**: NO file duplication in output/ (only metadata.json + feature-notes.md)
- **Comments**: All Swift comments in English
- **Documentation**: Complete documentation in English in Docs/

---

## 📋 VARIABLES DE FEATURE

```json
{
  "FEATURE_SLUG": "feature-01-intro-state",
  "FEATURE_TITLE": "Intro State",
  "FEATURE_DATE": "2025-10-19",
  "FEATURE_OBJECTIVE": "Introduire le paradigme déclaratif SwiftUI via @State pour gérer un compteur.",
  "FEATURE_FILES": [
    "MoodBoard/Sources/Views/IntroStateView.swift",
    "MoodBoard/Sources/Views/IntroStateView_Previews.swift",
    "Docs/01-IntroState.md"
  ],
  "FEATURE_SPECIFICATIONS": "Vue IntroStateView avec compteur @State et bouton Increment, documentation pédagogique associée.",
  "FEATURE_ACCEPTANCE": [
    "Le compteur démarre à 0",
    "Le bouton 'Increment' ajoute +1",
    "Previews fonctionnent dans Xcode",
    "Documentation claire sur le paradigme déclaratif"
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

Introduire le paradigme déclaratif SwiftUI via `@State` pour gérer un compteur simple.

Cette feature sert de base pédagogique pour comprendre :
- La gestion d'état avec `@State`
- Le rendu automatique de l'UI lors du changement d'état
- La structure d'une vue SwiftUI moderne

---

## 📝 SPÉCIFICATIONS TECHNIQUES

### Vue IntroStateView

Créer une vue SwiftUI simple avec :
- Un `@State private var counter: Int = 0`
- Un `Text` affichant la valeur du compteur
- Un `Button` "Increment" qui incrémente le compteur
- Un design moderne et épuré

### Previews

Fournir des Previews Xcode fonctionnels montrant :
- L'état initial (counter = 0)
- Un état avec plusieurs incréments

### Documentation

Créer `Docs/01-IntroState.md` expliquant :
- Le concept de `@State` en SwiftUI
- La différence entre programmation impérative et déclarative
- Le cycle de vie de la vue lors d'un changement d'état
- Code commenté et annoté

### Fichiers à Générer

1. `MoodBoard/Sources/Views/IntroStateView.swift`
2. `MoodBoard/Sources/Views/IntroStateView_Previews.swift` (ou intégré dans le fichier principal)
3. `Docs/01-IntroState.md`

### Critères d'Acceptation

- [x] Le compteur démarre à 0
- [x] Le bouton 'Increment' ajoute +1 à chaque clic
- [x] Previews fonctionnent dans Xcode
- [x] Documentation claire sur le paradigme déclaratif
- [x] Code suit les conventions Swift 6 et SwiftUI modernes

---

## 🧱 INSTRUCTIONS DE GÉNÉRATION

### 1️⃣ Code SwiftUI

Crée `IntroStateView.swift` avec :
- Import SwiftUI
- Struct `IntroStateView: View`
- Property wrapper `@State private var counter: Int = 0`
- Body avec VStack contenant Text et Button
- Design moderne (SF Symbols, couleurs système)
- Previews intégrés avec `#Preview`

### 2️⃣ Documentation

Crée `Docs/01-IntroState.md` avec :
- Introduction au concept de `@State`
- Explication du paradigme déclaratif
- Code source complet de la vue
- Diagramme du cycle de rendu (optionnel)
- Liens vers la documentation Apple

### 3️⃣ Navigation Integration

**DONE**: IntroStateView is already integrated in FeaturesListView
- Located in Section "SwiftUI Fundamentals"
- Feature 01 with blue color and sparkles icon

### 4️⃣ Integration Check

- Make sure the file is in `Sources/Views/`
- Verify the module compiles
- Test Previews in Xcode
- Verify navigation from FeaturesListView works

### 5️⃣ Archivage Automatique

À la fin de la génération :
1. Crée `.prompts/feature-01-intro-state/output/metadata.json` avec les métadonnées
2. Crée `.prompts/feature-01-intro-state/feature-notes.md` avec :
   - Résumé de ce qui a été généré
   - Difficultés rencontrées
   - Améliorations possibles
3. **NE PAS** dupliquer les fichiers source (ils sont déjà dans Sources/ et Docs/)
4. Vérifie que tous les critères d'acceptation sont remplis

---

## ✅ VALIDATION

Avant de terminer, vérifie :

- [ ] `IntroStateView.swift` est créé dans `Sources/Views/`
- [ ] Le code compile sans erreur
- [ ] Les Previews fonctionnent dans Xcode
- [ ] `Docs/01-IntroState.md` est créé et complet
- [ ] L'archivage est complet dans `.prompts/feature-01-intro-state/output/`
- [ ] Tous les critères d'acceptation sont cochés

---

## 🚀 COMMANDES FINALES

```bash
# Vérifier la structure
tree .prompts/feature-01-intro-state/

# Compiler le projet
xcodebuild -project MoodBoard.xcodeproj -scheme MoodBoard build

# Créer la branche Git (si nécessaire)
git checkout -b feature/01-intro-state
```

---

**Exécute ces instructions maintenant.**  
Génère le code SwiftUI, la documentation, et archive tout dans `.prompts/feature-01-intro-state/output/`.  
Termine par un résumé de ce qui a été créé et validé.

