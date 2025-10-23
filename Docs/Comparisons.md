# Comparaisons Cross-Platform : SwiftUI vs React vs Jetpack Compose

## Introduction

Ce document compare les trois principaux frameworks déclaratifs pour le développement d'interfaces utilisateur :
- **SwiftUI** (Apple - iOS/macOS)
- **React** (Meta - Web/Mobile)
- **Jetpack Compose** (Google - Android)

Ces trois frameworks partagent une philosophie commune : une approche déclarative de l'UI avec une gestion réactive de l'état.

---

## 1. Gestion d'État (State Management)

### Tableau Comparatif

| Concept | SwiftUI | React | Jetpack Compose |
|---------|---------|-------|-----------------|
| **État local** | `@State` | `useState` | `remember` + `mutableStateOf` |
| **État partagé** | `@StateObject`, `@ObservedObject` | `useContext`, Redux | `ViewModel` + `StateFlow` |
| **Dérivation d'état** | `@Binding` | Props / callback | `derivedStateOf` |
| **Observation externe** | `@EnvironmentObject` | Context API | `CompositionLocal` |
| **Réactivité** | Automatic (Combine) | Virtual DOM diffing | Recomposition |

### Exemples de Code

#### SwiftUI
```swift
struct CounterView: View {
    @State private var count = 0
    
    var body: some View {
        VStack {
            Text("Count: \(count)")
            Button("Increment") {
                count += 1
            }
        }
    }
}
```

#### React
```jsx
function CounterView() {
    const [count, setCount] = useState(0);
    
    return (
        <div>
            <p>Count: {count}</p>
            <button onClick={() => setCount(count + 1)}>
                Increment
            </button>
        </div>
    );
}
```

#### Jetpack Compose
```kotlin
@Composable
fun CounterView() {
    var count by remember { mutableStateOf(0) }
    
    Column {
        Text("Count: $count")
        Button(onClick = { count++ }) {
            Text("Increment")
        }
    }
}
```

### Analyse

- **SwiftUI** : Utilise des property wrappers (`@State`, `@Binding`) pour une syntaxe concise
- **React** : Hooks fonctionnels (`useState`, `useEffect`) avec une logique explicite
- **Compose** : Délégation Kotlin (`by remember`) avec une API fonctionnelle

---

## 2. Navigation

### Tableau Comparatif

| Aspect | SwiftUI | React | Jetpack Compose |
|--------|---------|-------|-----------------|
| **Stack Navigation** | `NavigationStack` | React Navigation Stack | `NavHost` + `NavController` |
| **Tabs** | `TabView` | Tab Navigator | `Scaffold` + `BottomNavigation` |
| **Modal** | `.sheet()`, `.fullScreenCover()` | Modal Stack | `Dialog`, `BottomSheet` |
| **Deep Links** | `onOpenURL` | Linking API | Deep Links Intent |
| **Paramètres** | `NavigationLink(value:)` | Route params | Navigation arguments |
| **Type Safety** | ✅ Codable | ❌ String-based | ✅ Parcelable |

### Exemples de Code

#### SwiftUI
```swift
struct AppNavigation: View {
    var body: some View {
        NavigationStack {
            List {
                NavigationLink("Details", value: MoodItem())
            }
            .navigationDestination(for: MoodItem.self) { mood in
                MoodDetailView(mood: mood)
            }
        }
    }
}
```

#### React (React Navigation v6)
```jsx
import { NavigationContainer } from '@react-navigation/native';
import { createNativeStackNavigator } from '@react-navigation/native-stack';

const Stack = createNativeStackNavigator();

function AppNavigation() {
    return (
        <NavigationContainer>
            <Stack.Navigator>
                <Stack.Screen name="List" component={MoodListScreen} />
                <Stack.Screen name="Detail" component={MoodDetailScreen} />
            </Stack.Navigator>
        </NavigationContainer>
    );
}
```

#### Jetpack Compose
```kotlin
@Composable
fun AppNavigation() {
    val navController = rememberNavController()
    
    NavHost(navController, startDestination = "list") {
        composable("list") {
            MoodListScreen(
                onItemClick = { mood ->
                    navController.navigate("detail/${mood.id}")
                }
            )
        }
        composable("detail/{moodId}") { backStackEntry ->
            val moodId = backStackEntry.arguments?.getString("moodId")
            MoodDetailScreen(moodId)
        }
    }
}
```

### Analyse

- **SwiftUI** : Navigation typée avec `NavigationStack` (iOS 16+), excellent type safety
- **React** : Flexibilité maximale, mais navigation par strings (risque d'erreurs)
- **Compose** : API déclarative avec routes, type safety via Parcelable

---

## 3. Lifecycle et Effets de Bord

### Tableau Comparatif

| Événement | SwiftUI | React | Jetpack Compose |
|-----------|---------|-------|-----------------|
| **Montage** | `onAppear` | `useEffect(() => {}, [])` | `LaunchedEffect(Unit)` |
| **Démontage** | `onDisappear` | `useEffect(() => { return cleanup })` | `DisposableEffect` |
| **Changement d'état** | Automatic rerender | `useEffect(() => {}, [deps])` | `LaunchedEffect(key)` |
| **Tâches asynchrones** | `Task {}` | `async/await` in useEffect | `LaunchedEffect` + coroutines |
| **Nettoyage** | Implicit | Cleanup function | `onDispose {}` |

### Exemples de Code

#### SwiftUI
```swift
struct DataView: View {
    @State private var data: [Item] = []
    
    var body: some View {
        List(data) { item in
            Text(item.name)
        }
        .onAppear {
            Task {
                data = await fetchData()
            }
        }
        .onDisappear {
            cancelRequests()
        }
    }
}
```

#### React
```jsx
function DataView() {
    const [data, setData] = useState([]);
    
    useEffect(() => {
        let cancelled = false;
        
        fetchData().then(result => {
            if (!cancelled) {
                setData(result);
            }
        });
        
        return () => {
            cancelled = true;
            cancelRequests();
        };
    }, []); // Empty deps = mount only
    
    return (
        <ul>
            {data.map(item => <li key={item.id}>{item.name}</li>)}
        </ul>
    );
}
```

#### Jetpack Compose
```kotlin
@Composable
fun DataView() {
    var data by remember { mutableStateOf<List<Item>>(emptyList()) }
    
    LaunchedEffect(Unit) {
        data = fetchData()
    }
    
    DisposableEffect(Unit) {
        onDispose {
            cancelRequests()
        }
    }
    
    LazyColumn {
        items(data) { item ->
            Text(item.name)
        }
    }
}
```

### Analyse

- **SwiftUI** : API simple avec `onAppear`/`onDisappear`, intégration naturelle avec `async/await`
- **React** : `useEffect` puissant mais complexe, gestion manuelle du cleanup
- **Compose** : `LaunchedEffect` avec coroutines, séparation claire entre effets et disposal

---

## 4. Performance et Optimisation

### Tableau Comparatif

| Aspect | SwiftUI | React | Jetpack Compose |
|--------|---------|-------|-----------------|
| **Mécanisme** | Invalidation ciblée | Virtual DOM diffing | Recomposition intelligente |
| **Granularité** | Vue-level | Component-level | Composable-level |
| **Mémoïsation** | Automatic | `useMemo`, `useCallback` | `remember` |
| **Skip rerender** | `Equatable` | `React.memo` | `@Stable`, `@Immutable` |
| **Liste virtuelle** | `LazyVStack`, `LazyHStack` | `FlatList`, `VirtualizedList` | `LazyColumn`, `LazyRow` |
| **Profilage** | Instruments | React DevTools | Layout Inspector |

### Exemples d'Optimisation

#### SwiftUI
```swift
struct OptimizedRow: View, Equatable {
    let mood: Mood
    
    var body: some View {
        HStack {
            Text(mood.name)
            Spacer()
            Text(mood.emoji)
        }
    }
    
    static func == (lhs: OptimizedRow, rhs: OptimizedRow) -> Bool {
        lhs.mood.id == rhs.mood.id
    }
}

struct MoodList: View {
    let moods: [Mood]
    
    var body: some View {
        LazyVStack {
            ForEach(moods) { mood in
                OptimizedRow(mood: mood)
                    .equatable()
            }
        }
    }
}
```

#### React
```jsx
const OptimizedRow = React.memo(({ mood }) => {
    return (
        <div className="mood-row">
            <span>{mood.name}</span>
            <span>{mood.emoji}</span>
        </div>
    );
}, (prevProps, nextProps) => {
    return prevProps.mood.id === nextProps.mood.id;
});

function MoodList({ moods }) {
    const renderItem = useCallback(({ item }) => (
        <OptimizedRow mood={item} />
    ), []);
    
    return (
        <FlatList
            data={moods}
            renderItem={renderItem}
            keyExtractor={item => item.id}
        />
    );
}
```

#### Jetpack Compose
```kotlin
@Immutable
data class Mood(val id: String, val name: String, val emoji: String)

@Composable
fun OptimizedRow(mood: Mood) {
    Row(
        modifier = Modifier.fillMaxWidth(),
        horizontalArrangement = Arrangement.SpaceBetween
    ) {
        Text(mood.name)
        Text(mood.emoji)
    }
}

@Composable
fun MoodList(moods: List<Mood>) {
    LazyColumn {
        items(
            items = moods,
            key = { it.id }
        ) { mood ->
            OptimizedRow(mood)
        }
    }
}
```

### Analyse

- **SwiftUI** : Optimisations automatiques, `.equatable()` pour contrôle fin
- **React** : `React.memo` et hooks de mémoïsation essentiels pour la performance
- **Compose** : `@Stable`/`@Immutable` pour skip recomposition, très performant par défaut

---

## 5. Styling et Theming

### Tableau Comparatif

| Concept | SwiftUI | React | Jetpack Compose |
|---------|---------|-------|-----------------|
| **Approche** | Modifiers chainés | CSS / Styled Components | Modifiers chainés |
| **Thème** | `@Environment(\.colorScheme)` | Theme Provider / CSS vars | MaterialTheme |
| **Couleurs** | `Color.accentColor` | CSS colors / Theme | `MaterialTheme.colorScheme` |
| **Typographie** | `.font(.title)` | CSS / Typography | `MaterialTheme.typography` |
| **Espacement** | `.padding()`, `.spacing()` | CSS margin/padding | `Modifier.padding()` |
| **Responsive** | `@Environment(\.horizontalSizeClass)` | Media queries / Flexbox | Constraints / BoxWithConstraints |

### Exemples de Code

#### SwiftUI
```swift
struct StyledCard: View {
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Titre")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("Description")
                .font(.body)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(colorScheme == .dark ? Color.gray.opacity(0.2) : Color.white)
        )
        .shadow(radius: 4)
    }
}
```

#### React (Styled Components)
```jsx
import styled from 'styled-components';

const Card = styled.div`
    display: flex;
    flex-direction: column;
    gap: 12px;
    padding: 16px;
    background-color: ${props => props.theme.cardBackground};
    border-radius: 12px;
    box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
`;

const Title = styled.h2`
    font-size: 20px;
    font-weight: bold;
    margin: 0;
`;

const Description = styled.p`
    font-size: 16px;
    color: ${props => props.theme.secondaryText};
    margin: 0;
`;

function StyledCard() {
    return (
        <Card>
            <Title>Titre</Title>
            <Description>Description</Description>
        </Card>
    );
}
```

#### Jetpack Compose
```kotlin
@Composable
fun StyledCard() {
    val backgroundColor = if (isSystemInDarkTheme()) {
        MaterialTheme.colorScheme.surfaceVariant
    } else {
        MaterialTheme.colorScheme.surface
    }
    
    Card(
        modifier = Modifier
            .fillMaxWidth()
            .padding(16.dp),
        shape = RoundedCornerShape(12.dp),
        colors = CardDefaults.cardColors(containerColor = backgroundColor),
        elevation = CardDefaults.cardElevation(defaultElevation = 4.dp)
    ) {
        Column(
            modifier = Modifier.padding(16.dp),
            verticalArrangement = Arrangement.spacedBy(12.dp)
        ) {
            Text(
                "Titre",
                style = MaterialTheme.typography.titleLarge,
                fontWeight = FontWeight.Bold
            )
            Text(
                "Description",
                style = MaterialTheme.typography.bodyMedium,
                color = MaterialTheme.colorScheme.onSurfaceVariant
            )
        }
    }
}
```

### Analyse

- **SwiftUI** : Modifiers déclaratifs, excellente intégration système (Dynamic Type, Dark Mode)
- **React** : Flexibilité maximale (CSS, Styled Components, Tailwind), séparation style/logique
- **Compose** : Modifiers Kotlin, Material Design 3 intégré, theming cohérent

---

## 6. Architecture et Patterns

### Tableau Comparatif

| Pattern | SwiftUI | React | Jetpack Compose |
|---------|---------|-------|-----------------|
| **Architecture recommandée** | MVVM | Flux / Redux / Context | MVVM + UDF |
| **Injection de dépendances** | `@EnvironmentObject` | Context / Props | Hilt / Koin |
| **Tests** | XCTest + PreviewProvider | Jest + Testing Library | JUnit + Compose Test |
| **Réutilisabilité** | ViewModifiers | Higher-Order Components | Modifier extensions |

### Exemple MVVM

#### SwiftUI
```swift
// ViewModel
class MoodListViewModel: ObservableObject {
    @Published var moods: [Mood] = []
    @Published var isLoading = false
    
    func loadMoods() async {
        isLoading = true
        moods = await MoodStore.shared.fetchAll()
        isLoading = false
    }
}

// View
struct MoodListView: View {
    @StateObject private var viewModel = MoodListViewModel()
    
    var body: some View {
        List(viewModel.moods) { mood in
            MoodRow(mood: mood)
        }
        .task {
            await viewModel.loadMoods()
        }
    }
}
```

#### React (Hooks)
```jsx
// Custom Hook (ViewModel logic)
function useMoodList() {
    const [moods, setMoods] = useState([]);
    const [isLoading, setIsLoading] = useState(false);
    
    const loadMoods = useCallback(async () => {
        setIsLoading(true);
        const data = await MoodStore.fetchAll();
        setMoods(data);
        setIsLoading(false);
    }, []);
    
    useEffect(() => {
        loadMoods();
    }, [loadMoods]);
    
    return { moods, isLoading, loadMoods };
}

// View
function MoodListView() {
    const { moods, isLoading } = useMoodList();
    
    return (
        <ul>
            {moods.map(mood => (
                <MoodRow key={mood.id} mood={mood} />
            ))}
        </ul>
    );
}
```

#### Jetpack Compose
```kotlin
// ViewModel
class MoodListViewModel : ViewModel() {
    private val _moods = MutableStateFlow<List<Mood>>(emptyList())
    val moods = _moods.asStateFlow()
    
    private val _isLoading = MutableStateFlow(false)
    val isLoading = _isLoading.asStateFlow()
    
    fun loadMoods() {
        viewModelScope.launch {
            _isLoading.value = true
            _moods.value = MoodStore.fetchAll()
            _isLoading.value = false
        }
    }
}

// View
@Composable
fun MoodListView(viewModel: MoodListViewModel = hiltViewModel()) {
    val moods by viewModel.moods.collectAsState()
    
    LaunchedEffect(Unit) {
        viewModel.loadMoods()
    }
    
    LazyColumn {
        items(moods) { mood ->
            MoodRow(mood)
        }
    }
}
```

---

## 7. Interopérabilité

### SwiftUI ↔️ UIKit
```swift
// UIKit dans SwiftUI
struct UIKitMapView: UIViewRepresentable {
    func makeUIView(context: Context) -> MKMapView {
        MKMapView()
    }
    
    func updateUIView(_ uiView: MKMapView, context: Context) {
        // Update logic
    }
}

// SwiftUI dans UIKit
let hostingController = UIHostingController(rootView: MySwiftUIView())
```

### React ↔️ Native
```jsx
// React Native Bridge
import { NativeModules } from 'react-native';
const { CustomNativeModule } = NativeModules;

// Web interop (React)
import { createRoot } from 'react-dom/client';
```

### Compose ↔️ View System
```kotlin
// View Android dans Compose
@Composable
fun AndroidViewIntegration() {
    AndroidView(
        factory = { context -> MapView(context) },
        update = { view -> /* update */ }
    )
}

// Compose dans View
val composeView = ComposeView(context).apply {
    setContent {
        MaterialTheme {
            MyComposable()
        }
    }
}
```

---

## 8. Écosystème et Outillage

### Tableau Récapitulatif

| Outil | SwiftUI | React | Jetpack Compose |
|-------|---------|-------|-----------------|
| **IDE Principal** | Xcode | VS Code / WebStorm | Android Studio |
| **Preview/Hot Reload** | ✅ Canvas Previews | ✅ Fast Refresh | ✅ @Preview |
| **Débogage** | Instruments | React DevTools | Layout Inspector |
| **Package Manager** | Swift Package Manager | npm / yarn / pnpm | Gradle / Maven |
| **Communauté** | Moyenne | Très large | Grande |
| **Documentation** | Apple Docs | Très complète | Google Docs + Samples |

---

## 9. Synthèse : Forces et Faiblesses

### SwiftUI

#### ✅ Forces
- Intégration parfaite avec l'écosystème Apple
- Type safety excellent (Swift fort typage)
- Previews en temps réel dans Xcode
- Performances natives optimales
- API cohérente et élégante

#### ❌ Faiblesses
- Limité à iOS 13+ (contraintes de version)
- Écosystème plus petit que React
- Courbe d'apprentissage des Property Wrappers
- Documentation parfois lacunaire

### React

#### ✅ Forces
- Écosystème immense (bibliothèques, outils)
- Cross-platform (Web, Mobile, Desktop)
- Communauté très active
- Flexibilité maximale
- Documentation excellente

#### ❌ Faiblesses
- Performance dépendante de l'optimisation manuelle
- Complexité des hooks (`useEffect` difficile à maîtriser)
- Pas de type safety natif (nécessite TypeScript)
- Fragmentation de l'écosystème (trop de choix)

### Jetpack Compose

#### ✅ Forces
- API moderne et intuitive
- Performances excellentes (recomposition intelligente)
- Interopérabilité avec Views Android
- Material Design 3 intégré
- Kotlin moderne et expressif

#### ❌ Faiblesses
- Encore en évolution (breaking changes possibles)
- Limité à Android (pas de vrai cross-platform)
- Courbe d'apprentissage Kotlin
- Moins de ressources que React

---

## 10. Tableau de Décision

| Critère | Choix recommandé |
|---------|------------------|
| **iOS uniquement** | ✅ SwiftUI |
| **Android uniquement** | ✅ Jetpack Compose |
| **Cross-platform maximal** | ✅ React (React Native) |
| **Performance native** | SwiftUI / Compose |
| **Rapidité de développement** | React (écosystème riche) |
| **Type safety strict** | SwiftUI / Compose |
| **Prototypage rapide** | React |
| **Intégration système** | SwiftUI / Compose |

---

## Conclusion

Les trois frameworks partagent une **philosophie déclarative** similaire mais avec des approches spécifiques à leur plateforme :

- **SwiftUI** excelle dans l'intégration Apple et la simplicité élégante
- **React** domine en flexibilité et portée cross-platform
- **Jetpack Compose** combine modernité Kotlin et performances Android

Le choix dépend principalement de :
1. **La plateforme cible** (iOS, Android, Web, Multi-platform)
2. **L'équipe** (compétences Swift/Kotlin/JavaScript)
3. **Le projet** (besoin de performance native vs portée maximale)

Pour **MoodBoard**, SwiftUI est le choix optimal car :
- ✅ Application iOS native
- ✅ Intégration parfaite avec l'écosystème Apple
- ✅ Performances optimales
- ✅ Code élégant et maintenable

---

## Ressources

### SwiftUI
- [Documentation officielle Apple](https://developer.apple.com/documentation/swiftui/)
- [Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/)
- [SwiftUI by Example (Hacking with Swift)](https://www.hackingwithswift.com/quick-start/swiftui)

### React
- [Documentation React](https://react.dev/)
- [React Native Docs](https://reactnative.dev/)
- [React Patterns](https://reactpatterns.com/)

### Jetpack Compose
- [Documentation Compose](https://developer.android.com/jetpack/compose)
- [Compose Samples](https://github.com/android/compose-samples)
- [Material Design 3](https://m3.material.io/)

