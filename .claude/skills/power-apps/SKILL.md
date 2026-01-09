---
name: power-apps
description: Canvas Apps und Model-Driven Apps Entwicklung mit Power Fx. Nutze diesen Skill für UI-Design, Formeln, Datenanbindung und Performance-Optimierung.
---

# Power Apps Entwicklung

## Canvas Apps

### App-Struktur
```
App
├── OnStart          # Initialisierung, Variablen setzen
├── Formulas         # Named Formulas (neue Methode)
├── Screens/
│   ├── HomeScreen
│   ├── DetailScreen
│   └── SettingsScreen
└── Components/
    ├── HeaderComponent
    └── NavigationComponent
```

### Power Fx Grundlagen

#### Variablen
```powerfx
// Globale Variable
Set(varCurrentUser, User());
Set(varIsAdmin, false);

// Kontext-Variable (nur auf aktuellem Screen)
UpdateContext({locSelectedItem: ThisItem});

// Collection
ClearCollect(colOrders, Filter(Orders, Status = "Open"));
```

#### Navigation
```powerfx
// Einfache Navigation
Navigate(DetailScreen, ScreenTransition.Fade);

// Mit Kontext
Navigate(
    DetailScreen,
    ScreenTransition.None,
    {locRecord: ThisItem}
);

// Zurück
Back();
```

#### Datenoperationen
```powerfx
// Lesen
LookUp(Customers, ID = varCustomerID);
Filter(Orders, Customer.ID = varCustomerID && Status = "Open");
Sort(Products, Name, SortOrder.Ascending);

// Schreiben
Patch(
    Customers,
    Defaults(Customers),
    {
        Name: txtName.Text,
        Email: txtEmail.Text
    }
);

// Löschen
Remove(Customers, LookUp(Customers, ID = varID));

// Mehrere Datensätze
ForAll(
    colSelectedItems,
    Patch(Orders, ThisRecord, {Status: "Processed"})
);
```

### Delegation

#### Delegierbare Funktionen (Dataverse)
- Filter, Sort, SortByColumns
- Search (nur Textfelder)
- LookUp, First
- =, <>, <, >, <=, >=
- And, Or, Not
- StartsWith (nur Textfelder)

#### NICHT delegierbar
- Last, FirstN, LastN
- CountRows, Sum, Average (auf Filter)
- Search auf Non-Text
- In, exactin
- Trim, Len, Lower, Upper

#### Lösung für große Datenmengen
```powerfx
// Schlecht - lädt alle Daten
CountRows(Filter(Orders, Status = "Open"))

// Gut - Dataverse View nutzen
CountRows('Active Orders View')

// Gut - serverseitige Aggregation
LookUp(
    'Order Statistics',
    Type = "OpenCount"
).Value
```

### Performance-Optimierung

1. **Concurrent für parallele Aufrufe**
```powerfx
Concurrent(
    ClearCollect(colCustomers, Customers),
    ClearCollect(colProducts, Products),
    ClearCollect(colOrders, Filter(Orders, Status = "Open"))
);
```

2. **Lazy Loading**
```powerfx
// In Gallery: nur laden was sichtbar ist
Items: ShowColumns(
    FirstN(Filter(Products, Category = varCategory), 50),
    "Name", "Price", "Image"
)
```

3. **Caching**
```powerfx
// OnStart - einmalig laden
If(
    IsBlank(colConfig),
    ClearCollect(colConfig, 'App Configuration')
);
```

### Komponenten erstellen

```powerfx
// Custom Property (Input)
cmp_Header.Title: Text

// Custom Property (Output)
cmp_Header.OnSelect: Behavior

// Verwendung in Komponente
Text: cmp_Header.Title
OnSelect: cmp_Header.OnSelect()
```

## Model-Driven Apps

### Formular-Anpassungen
```javascript
// Form OnLoad
function onFormLoad(executionContext) {
    const formContext = executionContext.getFormContext();

    // Feld ausblenden
    formContext.getControl("fieldname").setVisible(false);

    // Feld required machen
    formContext.getAttribute("fieldname")
        .setRequiredLevel("required");
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
| Kein Code nötig | Flexibler |
| Nur aktuelle Entität | API-Zugriff möglich |

## Häufige Fehler & Lösungen

| Problem | Lösung |
|---------|--------|
| Delegation Warning | Dataverse View oder serverseitige Logik |
| Langsame App | Concurrent(), weniger Controls |
| Formula Fehler | Typen prüfen, IsBlank() nutzen |
| Daten nicht aktuell | Refresh() nach Änderungen |
