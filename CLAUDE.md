# Claude Code Projekt-Konfiguration

## Projekt-Übersicht

Dieses Projekt ist ein **PowerApps Canvas App Template** mit moderner Power Fx 2025 Architektur.

- **Architektur**: Modular (Core Bootstrap + Optional Modules)
- **Sprachen**: Power Fx, JSON, YAML
- **Daten**: Microsoft Dataverse / SharePoint Lists
- **Lokalisierung**: Deutsch (CET Zeitzone, d.m.yyyy Datumsformat)
- **Tooling**: VS Code mit Power Platform CLI (`pac`)

---

## Architektur-Prinzipien

### Core + Modules Pattern

| Bereich | Ort | Inhalt | Deployment |
|---------|-----|--------|-----------|
| **Core Formulas** | `src/core/App-Formulas-Core.fx` | Named Formulas, UDFs (Permissions, Timezone) | PAC CLI |
| **Core OnStart** | `src/core/App-OnStart-Core.fx` | State Variables, Data Loading (ClearCollect) | PAC CLI |
| **Optional Modules** | `src/modules/*.fx` | Feature-spezifische Code-Abschnitte | Copy-Paste |

### App.Formulas enthält (DEKLARATIV)
- `ThemeColors` - Fluent Design Farbschema
- `AppConfig` - Environment, Feature Flags, Pagination
- `Permission` - Rollen-zu-Permissions Mapping
- `DateRange` - Auto-aktualisierte Datumsbereiche (CET-aware)
- **UDFs**: `HasRole()`, `CanAccess()`, `GetCETToday()`, `FormatDateCET()`, Validierung, Formatierung

### App.OnStart enthält (IMPERATIV)
- `AppState` - Ladezustand, Navigation, Fehler
- `Filter` - Benutzer-Filter (Search, Status, Pagination)
- `UI` - Auswahl, Dialoge, Formulare
- `Concurrent(ClearCollect(...))` - Paralleles Laden von Items, Tasks, Lookups

### Modulare Struktur

**Core Bootstrap** (CORE - nicht löschbar):
- Essenzielle UDFs (Permissions, Timezone, Validation)
- Basis Named Formulas (Theme, Config, DateRange)
- Minimales App.OnStart

**Optional Modules** (OPTIONAL - nach Bedarf löschbar):
- Notifications Module - Toasts, Dialogs, Error Handling
- Filtering Module - Advanced Search, Multi-field Filters
- Audit Log Module - Action Tracking
- Export Module - CSV/Excel Export
- Forms Module - Validation, Wizards, Calculated Fields

---

## Rollen-System (4 Rollen)

| Code | Deutsch (UI) | Berechtigungen |
|------|--------------|----------------|
| `Admin` | Administrator | Vollzugriff, ViewAll, Edit, Delete |
| `Manager` | Manager | ViewAll, Edit, Approve |
| `HR` | HR | ViewAll (Mitarbeiter) |
| `Processor` | Sachbearbeiter | Create, Edit (eigene), Read (eigene) |

**Konfiguration**: Azure AD Gruppen-IDs in `src/core/App-Formulas-Core.fx` eintragen.

### UDFs für Zugriffskontrolle

```powerfx
HasRole("Admin")                    // Rolle prüfen
CanAccess(ownerEmail)               // Datensatz-Zugriff
CanEdit(ownerEmail, status)         // Edit mit Status-Check
CanDelete(ownerEmail)               // Löschen erlaubt?
```

---

## Zeitzone & Lokalisierung (KRITISCH)

### CET/CEST Zeitzone

SharePoint speichert alle DateTime-Felder in **UTC**. Für deutsche Apps immer CET-aware Funktionen nutzen:

```powerfx
// ❌ FALSCH: Vergleicht UTC mit lokaler Zeit
If(ThisItem.'Due Date' < Today(), "Überfällig", "OK")

// ✅ RICHTIG: Nutzt CET-aware Funktion
If(ThisItem.'Due Date' < GetCETToday(), "Überfällig", "OK")
```

### Verfügbare Datum-UDFs

```powerfx
GetCETToday()                       // Heutiges Datum in CET
ConvertUTCToCET(utcDate)            // UTC zu CET konvertieren
FormatDateShort(date)               // "15.1.2025"
FormatDateLong(date)                // "15. Januar 2025"
FormatDateRelative(date)            // "Heute", "Gestern", "vor 3 Tagen"
```

---

## Naming Conventions

### Power Fx Code (ENGLISH CODE, GERMAN UI)

#### Named Formulas (App.Formulas)
- PascalCase, kurz, English-only
- Beispiele: `ThemeColors`, `AppConfig`, `Permission`, `DateRange`

#### User-Defined Functions (UDFs)
- PascalCase + Verb (Has/Is/Get/Can/Format/Validate)
- Beispiele: `HasRole()`, `CanAccess()`, `FormatDateCET()`, `GetCETToday()`

#### State Variables (App.OnStart)
- PascalCase, kurz, English
- Beispiele: `AppState`, `Filter`, `UI`

#### Collections
- PascalCase, kurz, English
- Beispiele: `Items`, `Tasks`, `Lookups`

#### Controls
- `[Type]_[Name]` Format
- Beispiele: `Gallery_Items`, `Button_Submit`, `Label_Error`

#### Display Text (User-Facing)
- **IMMER Deutsch**
- Rollen: `"Administrator"`, `"Manager"`, `"Sachbearbeiter"`
- Status: `"Aktiv"`, `"Genehmigt"`, `"Überfällig"`
- Buttons: `"Speichern"`, `"Löschen"`, `"Abbrechen"`

---

## Erforderliche Datenquellen

Vor Verwendung von App.OnStart verbinden:

1. **Items** - Spalten: `Owner`, `Status`, `'Modified On'`
2. **Tasks** - Spalten: `'Assigned To'`, `Status`, `'Due Date'`
3. **Optional**: Weitere Lookup-Tabellen je nach Anwendungsfall

**Wichtig**: Departments werden über EntraID Gruppen gesteuert (nicht als separate Sammlung).

---

## Häufige Fallstricke

| Problem | Ursache | Lösung |
|---------|---------|--------|
| **Delegation** | Nicht-delegierbare Funktionen auf >2000 Records | `Filter()` mit einfachen Bedingungen, `Search()` für Text, Pagination |
| **Zeitzone** | `Today()` mit SharePoint UTC-Daten verglichen | Immer `GetCETToday()` verwenden |
| **API-Limits** | `Office365Users.MyProfileV2()` mehrfach aufgerufen | Mit `With()` cachen oder Named Formula |
| **Rollen nicht erkannt** | Azure AD Gruppen nicht konfiguriert | Gruppen-IDs in `App-Formulas-Core.fx` prüfen |
| **Flow-Timeouts** | Flows brechen nach 30 Tagen ab | Child-Flows verwenden |

---

## Dokumentierte Fehler & Lösungen

| Datum | Fehler | Ursache | Lösung |
|-------|--------|---------|--------|
| 2025-01-14 | Departments-Sammlung nicht nötig | EntraID-gesteuerte Org | Entfernt aus Core OnStart |
| 2025-01-12 | Notification UDFs fehlten | Auskommentiert in Template | Optional Module nutzen |
| 2025-01-12 | FormatNumber() undefined | UDF nicht definiert | `Text(value, "#,##0")` nutzen |

---

## PAC CLI Befehle

```bash
# Authentifizierung
pac auth list                    # Environments auflisten
pac auth select --index 1        # Environment wechseln
pac org who                      # Aktuelles Org anzeigen

# Solutions
pac solution list                # Solutions auflisten
pac solution export --name MySolution --path ./exports
pac solution import --path ./MySolution.zip
pac solution unpack --zipfile ./sol.zip --folder ./src
pac solution pack --folder ./src --zipfile ./sol.zip

# Canvas Apps
pac canvas download --name "MyApp" --file MyApp.msapp
pac canvas unpack --msapp MyApp.msapp --sources ./src
pac canvas pack --sources ./src --msapp MyApp.msapp
```

---

## GitHub CLI (gh) Befehle

Mit `gh` können Pull Requests, Issues und Branches direkt vom Terminal verwaltet werden.

### Authentifizierung & Status
```bash
gh auth login          # Login (einmalig)
gh auth status         # Aktuellen User prüfen
gh auth refresh        # Token aktualisieren
```

### Issues verwalten
```bash
gh issue list                          # Alle offenen Issues
gh issue list --state all             # Alle Issues
gh issue list --assignee @me          # Mir zugewiesene Issues
gh issue view 42                       # Issue #42 anzeigen
gh issue create --title "Bug Title" --body "Description"
```

### Pull Requests
```bash
gh pr create --title "Feature Title" --body "Description"
gh pr list                             # Alle offenen PRs
gh pr view 15                          # PR #15 anzeigen
gh pr merge 15 --squash               # Mit Squash mergen
```

---

## Environment Strategy

- **DEV**: Entwicklung und Tests (unmanaged Solutions)
- **TEST/UAT**: User Acceptance Testing (managed Solutions)
- **PROD**: Produktiv - nur managed Solutions, keine direkten Änderungen

---

## Wichtige Dateien

| Datei | Beschreibung |
|-------|-------------|
| `src/core/App-Formulas-Core.fx` | Core Named Formulas + UDFs |
| `src/core/App-OnStart-Core.fx` | Core State + Data Loading |
| `src/modules/*.fx` | Optional Feature Modules |
| `docs/MODERNIZATION-DESIGN.md` | Architecture & Design |
| `docs/MIGRATION-GUIDE.md` | Upgrade Path |
| `docs/MODULE-CHECKLIST.md` | Module Selection Guide |

---

## Code-Qualität

- ✅ Sauberen, lesbaren Power Fx Code schreiben
- ✅ UDFs für wiederverwendbare Logik (Single Responsibility)
- ✅ Code-Duplizierung vermeiden - Named Formulas nutzen
- ✅ Nur komplexe Logik kommentieren
- ✅ Eingaben früh validieren (Fail Fast)
- ✅ Berechtigungen VOR Aktionen prüfen
- ✅ Module mit `// CORE` oder `// OPTIONAL` markieren

---

## Git Workflow

- **main**: Produktions-Branch (protected)
- **feature/**: Neue Features (`feature/add-approval-flow`)
- **fix/**: Bug Fixes (`fix/timezone-calculation`)
- Ein Commit = eine logische Änderung
- Aussagekräftige Commit-Messages (Was + Warum)
- Keine Secrets im Code
