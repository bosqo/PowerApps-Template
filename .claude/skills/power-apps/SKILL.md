---
name: power-apps
description: Canvas Apps und Model-Driven Apps Entwicklung mit Power Fx. Nutze diesen Skill fuer UI-Design, Formeln, Datenanbindung und Performance-Optimierung.
---

# Power Apps Entwicklung

## Canvas Apps

### App-Struktur
```
App
├── Formulas         # Named Formulas + UDFs (recommended, declarative)
├── OnStart          # Mutable state + collections (imperative, minimal)
├── StartScreen      # Initial screen (replaces Navigate() in OnStart)
├── Screens/
│   ├── HomeScreen
│   ├── DetailScreen
│   └── SettingsScreen
└── Components/
    ├── HeaderComponent
    └── NavigationComponent
```

### Power Fx Grundlagen

#### State Management (Mutable Variables)

**Global variables with Set() -- used in App.OnStart or behavior properties:**
```powerfx
// Consolidated state records (recommended pattern)
Set(AppState, {
    IsLoading: false,
    IsInitializing: true,
    CurrentScreen: "Home",
    ErrorMessage: ""
});

// Update single field
Set(AppState, Patch(AppState, {IsLoading: true}));

// Access: AppState.IsLoading, AppState.CurrentScreen
```

**Screen-local context variables:**
```powerfx
UpdateContext({
    SelectedItem: ThisItem,
    IsEditing: false,
    FormMode: FormMode.View
});

// Access: SelectedItem, IsEditing, FormMode
```

**Collections (mutable tables):**
```powerfx
// Load data at startup
ClearCollect(CachedDepartments, Filter(Departments, Status = "Active"));

// Add items
Collect(MyItems, { Name: "New Item", Status: "Active" });

// Access: CachedDepartments, MyItems
```

#### Named Formulas (Declarative, in App.Formulas)

```powerfx
// Constants (no type annotation, immutable, auto-reactive)
ThemeColors = {
    Primary: ColorValue("#0078D4"),
    Success: ColorValue("#107C10"),
    Error: ColorValue("#D13438")
};

// Computed values (recalculate when dependencies change)
UserEmail = User().Email;

// Configuration
AppConfig = {
    ItemsPerPage: 50,
    CacheExpiryMinutes: 5
};
```

#### User Defined Functions (UDFs, in App.Formulas)

```powerfx
// Pure function: FunctionName(Param: Type): ReturnType = Expression;
IsValidEmail(email: Text): Boolean =
    !IsBlank(email) && CountRows(Split(email, "@")) = 2;

// Behavior function (side effects): returns Void, uses { }
NotifySuccess(message: Text): Void = {
    Notify(message, NotificationType.Success)
};

// No-parameter UDF (empty parentheses required)
GetUserScope(): Text =
    If(UserPermissions.CanViewAll, Blank(), User().Email);
```

**CRITICAL: `App` is a reserved system object. Never use `Set(App, {...})`.**

#### Navigation
```powerfx
// Simple navigation
Navigate(DetailScreen, ScreenTransition.Fade);

// With context
Navigate(
    DetailScreen,
    ScreenTransition.None,
    { SelectedRecord: ThisItem, ViewMode: "Edit" }
);

// Use App.StartScreen instead of Navigate() in App.OnStart
// App.StartScreen = If(condition, Screen1, Screen2);

// Back navigation
Back();
```

#### Datenoperationen
```powerfx
// Read
LookUp(Customers, ID = selectedId);
Filter(Orders, Status = "Open" && Customer.Email = User().Email);
Sort(Products, Name, SortOrder.Ascending);

// Write
Patch(
    Customers,
    Defaults(Customers),
    { Name: txt_Name.Text, Email: txt_Email.Text }
);

// Delete
Remove(Customers, LookUp(Customers, ID = selectedId));

// Bulk update
ForAll(
    selectedItems,
    Patch(Orders, ThisRecord, { Status: "Processed" })
);
```

### Delegation

#### Delegierbare Funktionen

| Function | SharePoint | Dataverse | SQL |
|----------|-----------|-----------|-----|
| Filter | Ja | Ja | Ja |
| Search | **Nein** | Ja | Ja |
| LookUp | Ja | Ja | Ja |
| Sort/SortByColumns | Ja (1 Spalte) | Ja | Ja |
| StartsWith | Ja (Text) | Ja | Ja |
| CountRows | **Nein** | Ja | Ja |

#### NICHT delegierbar
- `Search()` mit SharePoint
- `in` Operator mit SharePoint: `Status in ["A", "B"]`
- `IsBlank(Column)` in SharePoint Filter (stattdessen `Column = Blank()`)
- UDFs innerhalb von `Filter()` (nie delegierbar)
- `CountRows` auf SharePoint Filter
- `Trim`, `Len`, `Lower`, `Upper` innerhalb Filter
- `Not` (!) mit SharePoint

#### Delegierbare Muster
```powerfx
// Text search (SharePoint-delegierbar)
Filter(Items, StartsWith(Title, searchTerm))

// Status filter (delegierbar)
Filter(Items, IsBlank(selectedStatus) || Status = selectedStatus)

// Multi-Status OHNE 'in' Operator (SharePoint-delegierbar)
Filter(Items, Status = "Active" || Status = "Pending" || Status = "Open")

// Pagination fuer grosse Datenmengen
FirstN(
    Skip(
        Sort(Filter(Items, Status = "Active"), 'Created On', SortOrder.Descending),
        (currentPage - 1) * pageSize
    ),
    pageSize
)
```

### Performance-Optimierung

1. **Concurrent fuer parallele Aufrufe**
```powerfx
// In App.OnStart: Paralleles Laden unabhaengiger Daten
Concurrent(
    ClearCollect(CachedDepartments, Filter(Departments, Status = "Active")),
    ClearCollect(CachedCategories, Filter(Categories, Status = "Active")),
    ClearCollect(CachedStatuses, Table({Value: "Active"}, {Value: "Pending"}))
);
```

2. **Named Formulas statt OnStart (Lazy Loading)**
```powerfx
// In App.Formulas: Wird erst bei Bedarf ausgewertet
UserProfile = {
    Email: User().Email,
    DisplayName: Coalesce(User().FullName, Text(User().Email))
};
```

3. **Caching mit Collections**
```powerfx
// In App.OnStart: Einmalig laden, Session-weit verwenden
ClearCollect(
    CachedDepartments,
    IfError(
        Sort(Filter(Departments, Status = "Active"), Name, SortOrder.Ascending),
        Table()  // Leere Tabelle als Fallback
    )
);
```

### Theme-System (Named Formulas)

```powerfx
// In App.Formulas (deklarativ, unveraenderlich)
ThemeColors = {
    Primary: ColorValue("#0078D4"),
    Secondary: ColorValue("#50E6FF"),
    Success: ColorValue("#107C10"),
    Warning: ColorValue("#FFB900"),
    Error: ColorValue("#D13438"),
    Text: ColorValue("#201F1E"),
    Background: ColorValue("#F3F2F1")
};

// State-Farben mit ColorFade (Microsoft-dokumentierte Funktion)
// ColorFade(color, amount): -1 = schwarz, 0 = unveraendert, 1 = weiss
GetHoverColor(baseColor: Color): Color = ColorFade(baseColor, -0.20);
GetPressedColor(baseColor: Color): Color = ColorFade(baseColor, -0.30);
GetDisabledColor(baseColor: Color): Color = ColorFade(baseColor, 0.60);

// Verwendung in Controls
// btn_Submit.Fill: ThemeColors.Primary
// btn_Submit.HoverFill: GetHoverColor(ThemeColors.Primary)
// btn_Submit.PressedFill: GetPressedColor(ThemeColors.Primary)
```

### Komponenten erstellen

```powerfx
// Custom Property (Input)
cmp_Header.Title: Text

// Custom Property (Output)
cmp_Header.OnSelect: Behavior

// Verwendung in Komponente
Fill: ThemeColors.Primary
Text: cmp_Header.Title
OnSelect: cmp_Header.OnSelect()
```

## Model-Driven Apps

### Formular-Anpassungen
```javascript
// Form OnLoad
function onFormLoad(executionContext) {
    const formContext = executionContext.getFormContext();
    formContext.getControl("fieldname").setVisible(false);
    formContext.getAttribute("fieldname").setRequiredLevel("required");
}

// OnChange
function onFieldChange(executionContext) {
    const formContext = executionContext.getFormContext();
    const value = formContext.getAttribute("fieldname").getValue();
    if (value > 1000) {
        formContext.ui.setFormNotification(
            "Hoher Wert - Genehmigung erforderlich",
            "WARNING",
            "highvalue"
        );
    }
}
```

### Business Rules vs JavaScript
| Business Rules | JavaScript |
|----------------|------------|
| Einfache Logik | Komplexe Logik |
| Kein Code noetig | Flexibler |
| Nur aktuelle Entitaet | API-Zugriff moeglich |

## Haeufige Fehler & Loesungen

| Problem | Ursache | Loesung |
|---------|---------|---------|
| Delegation Warning | Nicht-delegierbare Funktion | Inline delegierbare Operatoren verwenden |
| Langsame App | Zu viel in OnStart | Named Formulas (lazy) + Concurrent() |
| UDF nicht delegierbar | UDF in Filter() | Logik inline schreiben fuer >2000 Datensaetze |
| `Search()` Fehler | Erster Parameter muss Table sein | `Search(Table, term, "Col1", "Col2")` |
| `Ceiling()` Fehler | Existiert nicht in Power Fx | `RoundUp(value, 0)` verwenden |
| `in` nicht delegierbar | SharePoint Limitation | `Status = "A" \|\| Status = "B"` |
| Timezone-Fehler | SharePoint speichert UTC | `DateAdd()` fuer CET-Konvertierung |
| `Set(App, ...)` Fehler | App ist reserviertes Objekt | Eigene Variable: `Set(AppState, {...})` |
