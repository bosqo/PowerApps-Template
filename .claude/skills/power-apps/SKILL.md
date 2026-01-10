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

#### Variablen (Dot Notation)

**App-weite Variablen mit hierarchischer Struktur:**
```powerfx
// OnStart - App-Struktur initialisieren
Set(App, {
    User: {
        Info: User(),
        Email: User().Email,
        IsAdmin: false
    },
    State: {
        IsLoading: false,
        CurrentScreen: "Home"
    },
    Config: {
        DebugMode: false,
        ApiUrl: LookUp('Environment Variables', Name = "ApiEndpoint").Value
    }
});

// Zugriff: App.User.Email, App.State.IsLoading, App.Config.DebugMode
```

**Screen-lokale Kontext-Variablen:**
```powerfx
// Kontext-Variable mit Dot Notation
UpdateContext({
    Screen: {
        State: {
            SelectedItem: ThisItem,
            IsEditing: false
        }
    }
});

// Zugriff: Screen.State.SelectedItem, Screen.State.IsEditing
```

**Daten-Collections:**
```powerfx
// Daten-Cache mit Dot Notation
Set(Data, {
    Cache: {
        Orders: Filter(Orders, Status = "Open"),
        Customers: Customers,
        Products: Products
    }
});

// Zugriff: Data.Cache.Orders, Data.Cache.Customers
```

#### Navigation
```powerfx
// Einfache Navigation
Navigate(DetailScreen, ScreenTransition.Fade);

// Mit Kontext (Dot Notation)
Navigate(
    DetailScreen,
    ScreenTransition.None,
    {
        Screen: {
            State: {
                Record: ThisItem,
                Mode: "View"
            }
        }
    }
);

// Zurück
Back();
```

#### Datenoperationen
```powerfx
// Lesen mit Dot Notation
LookUp(Customers, ID = Screen.State.SelectedId);
Filter(Orders, Customer.ID = Screen.State.CustomerId && Status = "Open");
Sort(Data.Cache.Products, Name, SortOrder.Ascending);

// Schreiben
Patch(
    Customers,
    Defaults(Customers),
    {
        Name: Form.Fields.Name,
        Email: Form.Fields.Email
    }
);

// Löschen
Remove(Customers, LookUp(Customers, ID = Screen.State.SelectedId));

// Mehrere Datensätze mit gecachten Daten
ForAll(
    Data.Cache.SelectedItems,
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
// Paralleles Laden mit Dot Notation
Concurrent(
    Set(Data, {
        Cache: {
            Customers: Customers,
            Products: Products,
            Orders: Filter(Orders, Status = "Open")
        }
    })
);
```

2. **Lazy Loading**
```powerfx
// In Gallery: nur laden was sichtbar ist
Items: ShowColumns(
    FirstN(Filter(Data.Cache.Products, Category = Screen.State.Category), 50),
    "Name", "Price", "Image"
)
```

3. **Caching**
```powerfx
// OnStart - einmalig laden
If(
    IsBlank(App.Config),
    Set(App, {
        Config: {
            Settings: LookUp('App Configuration', Key = "Settings"),
            FeatureFlags: LookUp('App Configuration', Key = "Features")
        }
    })
);
```

### App.Themes - Theming-Struktur

```powerfx
// OnStart - Theme-Struktur initialisieren
Set(App, {
    Themes: {
        // Primärfarben
        Primary: ColorValue("#0078D4"),
        PrimaryLight: ColorValue("#4DA6FF"),
        PrimaryDark: ColorValue("#004578"),

        // Sekundärfarben
        Secondary: ColorValue("#2B88D8"),
        Accent: ColorValue("#FFB900"),

        // Hintergrundfarben
        Background: ColorValue("#FFFFFF"),
        BackgroundAlt: ColorValue("#F3F2F1"),
        Surface: ColorValue("#FAFAFA"),

        // Textfarben
        TextPrimary: ColorValue("#323130"),
        TextSecondary: ColorValue("#605E5C"),
        TextOnPrimary: ColorValue("#FFFFFF"),

        // Status-Farben
        Success: ColorValue("#107C10"),
        Warning: ColorValue("#FFB900"),
        Error: ColorValue("#D13438"),
        Info: ColorValue("#0078D4"),

        // Rahmen & Schatten
        Border: ColorValue("#EDEBE9"),
        Shadow: ColorValue("#00000020"),

        // Abstände
        Spacing: {
            XS: 4,
            SM: 8,
            MD: 16,
            LG: 24,
            XL: 32
        },

        // Radien
        BorderRadius: {
            SM: 2,
            MD: 4,
            LG: 8,
            Round: 9999
        }
    }
});

// Verwendung in Controls
Fill: App.Themes.Primary
Color: App.Themes.TextOnPrimary
BorderColor: App.Themes.Border
PaddingLeft: App.Themes.Spacing.MD
BorderRadius: App.Themes.BorderRadius.MD
```

### App.Fonts - Schrift-Struktur

```powerfx
// OnStart - Font-Struktur initialisieren
Set(App, {
    Fonts: {
        // Schriftfamilien
        Family: {
            Primary: Font.'Segoe UI',
            Secondary: Font.'Segoe UI Light',
            Mono: Font.'Courier New'
        },

        // Schriftgrößen
        Size: {
            XS: 10,
            SM: 12,
            MD: 14,
            LG: 18,
            XL: 24,
            XXL: 32,
            Display: 48
        },

        // Schriftgewichte
        Weight: {
            Light: FontWeight.Lighter,
            Normal: FontWeight.Normal,
            SemiBold: FontWeight.Semibold,
            Bold: FontWeight.Bold
        },

        // Vordefinierte Stile
        Styles: {
            Header: {
                Size: 24,
                Weight: FontWeight.Semibold,
                Family: Font.'Segoe UI'
            },
            SubHeader: {
                Size: 18,
                Weight: FontWeight.Semibold,
                Family: Font.'Segoe UI'
            },
            Body: {
                Size: 14,
                Weight: FontWeight.Normal,
                Family: Font.'Segoe UI'
            },
            Caption: {
                Size: 12,
                Weight: FontWeight.Normal,
                Family: Font.'Segoe UI'
            },
            Button: {
                Size: 14,
                Weight: FontWeight.Semibold,
                Family: Font.'Segoe UI'
            }
        }
    }
});

// Verwendung in Controls
Font: App.Fonts.Family.Primary
Size: App.Fonts.Size.LG
FontWeight: App.Fonts.Weight.Bold

// Oder mit vordefinierten Stilen
Size: App.Fonts.Styles.Header.Size
FontWeight: App.Fonts.Styles.Header.Weight
```

### Komponenten erstellen

```powerfx
// Custom Property (Input)
cmp_Header.Title: Text

// Custom Property (Output)
cmp_Header.OnSelect: Behavior

// Verwendung in Komponente mit App.Themes
Fill: App.Themes.Primary
Color: App.Themes.TextOnPrimary
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
