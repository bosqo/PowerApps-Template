# Claude Code Projekt-Konfiguration

## Projekt-Übersicht

Dieses Projekt ist ein **PowerApps Canvas App Template** mit moderner Power Fx 2025 Architektur.

- **Architektur**: Deklarativ-Funktional (App.Formulas + UDFs)
- **Sprachen**: Power Fx, JSON, YAML
- **Daten**: Microsoft Dataverse / SharePoint Lists
- **Lokalisierung**: Deutsch (CET Zeitzone, d.m.yyyy Datumsformat)
- **Tooling**: VS Code mit Power Platform CLI (`pac`)

---

## Architektur-Prinzipien

### Trennung: Deklarativ vs. Imperativ

| Bereich | Datei | Inhalt |
|---------|-------|--------|
| **App.Formulas** | `App-Formulas-Template.fx` | Named Formulas, 30+ UDFs, Computed Values |
| **App.OnStart** | `App-OnStart-Minimal.fx` | State-Variablen, ClearCollect, Initialisierung |
| **Controls** | `Control-Patterns-Modern.fx` | Fertige Formeln für Gallery, Button, Form etc. |

### App.Formulas enthält (DEKLARATIV)
- `ThemeColors` - Fluent Design Farbschema
- `UserProfile` - Benutzerinfo (lazy-loaded via Office365Users)
- `UserRoles` - Rollenzugehörigkeit (Azure AD Gruppen)
- `UserPermissions` - Abgeleitete Berechtigungen
- `DateRanges` - Auto-aktualisierte Datumsbereiche
- 30+ UDFs für Validierung, Formatierung, Pagination, Zeitzonen

### App.OnStart enthält (IMPERATIV)
- `AppState` - Ladezustand, Navigation, Fehler
- `ActiveFilters` - Benutzer-Filter (Search, Status, Page)
- `UIState` - Auswahl, Dialoge, Formulare
- `Concurrent(ClearCollect(...))` - Paralleles Laden von Lookup-Daten

### Warum nicht "App.User", "App.Themes" etc.?

Das `App.*` Pattern war ein **Workaround vor Named Formulas** (Pre-2023):

```powerfx
// ALT (Legacy) - Imperativ, läuft bei Startup, blockiert App
Set(App.User, { IsAdmin: ... });

// NEU (Modern) - Deklarativ, lazy-evaluated, reaktiv
UserRoles = { IsAdmin: ... };
HasRole(roleName: Text): Boolean = ...;
```

| Aspekt | App.* (Legacy) | Named Formulas (Modern) |
|--------|---------------|------------------------|
| Auswertung | Eager (Startup) | Lazy (bei Bedarf) |
| Reaktivität | Manuelles Refresh | Auto-Update |
| Wiederverwendung | Copy/Paste | UDF-Aufruf |
| Ort | App.OnStart | App.Formulas |

---

## Rollen-System (6 Rollen)

| Rolle | Deutsch | Berechtigungen |
|-------|---------|----------------|
| Admin | Administrator | Vollzugriff, ViewAll, Approve, Delete |
| GF | Geschäftsführer | ViewAll, Approve |
| Manager | Manager | ViewAll, Edit, Approve |
| HR | HR | ViewAll (Mitarbeiter) |
| Sachbearbeiter | Sachbearbeiter | Create, Edit (eigene) |
| User | Benutzer | Read (eigene) |

**Konfiguration erforderlich**: Azure AD Gruppen-IDs in `App-Formulas-Template.fx:186-217` eintragen.

### UDFs für Zugriffskontrolle
```powerfx
HasRole("Admin")                      // Rolle prüfen
HasPermission("Delete")               // Berechtigung prüfen
HasAnyRole("Admin,Manager")           // Eine von mehreren Rollen
CanAccessRecord(Owner.Email)          // Datensatz-Zugriff
CanEditRecord(Owner.Email, Status)    // Edit mit Status-Check
CanDeleteRecord(Owner.Email)          // Löschen erlaubt?
```

---

## Zeitzone & Lokalisierung (KRITISCH)

### CET/CEST Zeitzone
SharePoint speichert alle DateTime-Felder in **UTC**. Für deutsche Apps:

```powerfx
// NIEMALS Today() mit SharePoint-Datetimes verwenden!
// IMMER GetCETToday() nutzen:
If(ThisItem.'Due Date' < GetCETToday(), "Überfällig", "OK")

// UTC zu CET konvertieren:
FormatDateTimeCET(ThisItem.'Modified')  // "15.1.2025 14:30"

// Direkte Konvertierung:
ConvertUTCToCET(ThisItem.'Created On')
```

### Deutsches Datumsformat
```powerfx
FormatDateShort(date)      // "15.1.2025"
FormatDateLong(date)       // "15. Januar 2025"
FormatDateRelative(date)   // "Heute", "Gestern", "vor 3 Tagen"
```

---

## Naming Conventions

### Power Platform Komponenten
- **Solutions**: `[Publisher]_[Projektname]_[Typ]` (z.B. `contoso_CRM_Core`)
- **Tabellen**: PascalCase, Singular (z.B. `Customer`, `OrderItem`)
- **Spalten**: camelCase mit Präfix (z.B. `cust_firstName`)
- **Flows**: `[App]-[Aktion]-[Trigger]` (z.B. `CRM-SendEmail-OnCreate`)
- **Canvas Apps**: `[Bereich]_[Funktion]_App` (z.B. `Sales_OrderEntry_App`)

### Power Fx Code
- **Named Formulas**: PascalCase (`ThemeColors`, `UserProfile`, `DateRanges`)
- **UDFs**: PascalCase mit Verb (`HasRole()`, `GetUserScope()`, `FormatDateShort()`)
- **State-Variablen**: PascalCase (`AppState`, `ActiveFilters`, `UIState`)
- **Collections**: PascalCase (`CachedDepartments`, `MyRecentItems`)
- **Controls**: `[Typ]_[Name]` (`Gallery_Items`, `Button_Submit`, `Label_Error`)

---

## Erforderliche Datenquellen

Vor Verwendung von App.OnStart diese Tabellen verbinden:

1. **Departments** - Spalten: `Name`, `Status`
2. **Categories** - Spalten: `Name`, `Status`
3. **Items** - Spalten: `Owner`, `Status`, `'Modified On'`
4. **Tasks** - Spalten: `'Assigned To'`, `Status`, `'Due Date'`

---

## Häufige Fallstricke

| Problem | Ursache | Lösung |
|---------|---------|--------|
| **Delegation** | Nicht-delegierbare Funktionen auf >2000 Records | `Filter()` mit einfachen Bedingungen, `Search()` für Text, Pagination mit `FirstN(Skip())` |
| **Zeitzone** | `Today()` mit SharePoint UTC-Daten verglichen | Immer `GetCETToday()` verwenden |
| **API-Limits** | `Office365Users.MyProfileV2()` mehrfach aufgerufen | Mit `With()` cachen oder Named Formula |
| **Rollen leer** | Azure AD Gruppen nicht konfiguriert | `UserRoles` in App-Formulas-Template.fx anpassen |
| **Flow-Timeouts** | Flows brechen nach 30 Tagen ab | Child-Flows verwenden |
| **Lizenz-Limits** | API-Limits überschritten | Batch-Operationen, Throttling |

---

## Dokumentierte Fehler & Lösungen

| Datum | Fehler | Ursache | Lösung |
|-------|--------|---------|--------|
| 2025-01-12 | Notification UDFs fehlen | Auskommentiert in Template | Inline `Notify()` verwenden |
| 2025-01-12 | FormatNumber() undefined | UDF nicht definiert | `Text(value, "#,##0")` nutzen |
| 2025-01-12 | GetStatusIcon Typo | "buildinicon" statt "builtinicon" | Typo korrigiert |

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

# Testing
pac test run --config-file testconfig.json
```

---

## GitHub CLI (gh) Befehle

Mit `gh` können Pull Requests, Issues und Branches direkt vom Terminal verwaltet werden.

### Authentifizierung & Status
```bash
# Login (einmalig)
gh auth login

# Aktuellen User prüfen
gh auth status

# Token aktualisieren
gh auth refresh
```

### Issues verwalten
```bash
# Issues auflisten
gh issue list                          # Alle offenen Issues
gh issue list --state all             # Alle Issues (offen + geschlossen)
gh issue list --assignee @me          # Mir zugewiesene Issues
gh issue list --label "bug"           # Issues mit Tag "bug"

# Issue anzeigen
gh issue view 42                       # Issue #42 anzeigen
gh issue view 42 --comments           # Mit Kommentaren

# Issue erstellen
gh issue create --title "Bug Title" --body "Description"
gh issue create --title "Fix timezone" --label "bug,urgent"

# Issue bearbeiten
gh issue edit 42 --title "New Title"
gh issue edit 42 --state closed       # Schließen

# Kommentare
gh issue comment 42 --body "This is a comment"
```

### Pull Requests erstellen & verwalten
```bash
# PR erstellen
gh pr create --title "Feature Title" --body "Description"
gh pr create --title "Add UDFs" --draft                    # Als Draft
gh pr create --title "Fix bug" --assignee @me --label "fix"

# PRs auflisten
gh pr list                             # Alle offenen PRs
gh pr list --state all                # Alle PRs
gh pr list --author @me               # Meine PRs
gh pr list --draft                    # Draft PRs

# PR anzeigen
gh pr view 15                          # PR #15 anzeigen
gh pr view 15 --comments              # Mit Kommentaren

# PR bearbeiten
gh pr edit 15 --title "New Title"
gh pr edit 15 --state closed          # Schließen

# PR checken & mergen
gh pr checks 15                        # Status von Checks prüfen
gh pr merge 15                         # Mergen (interaktiv)
gh pr merge 15 --squash               # Mit Squash mergen
gh pr merge 15 --auto                 # Auto-merge wenn alle Checks passen

# Kommentare
gh pr comment 15 --body "Great PR!"
gh pr comment 15 --edit                # Letzten Kommentar bearbeiten
```

### Branches verwalten
```bash
# Branch erstellen & wechseln
gh repo clone owner/repo               # Repository klonen
git checkout -b feature/my-feature     # Branch erstellen

# Branch mit PR verknüpfen
gh pr create --head feature/my-feature --base main

# Remote Branch löschen
gh pr delete 15                        # PR löschen (auch Branch)
```

### Workflow-Beispiele

**Beispiel 1: Feature Branch + PR erstellen**
```bash
# Feature Branch erstellen
git checkout -b feature/add-validation

# Änderungen machen...
git add .
git commit -m "Add email validation UDF"
git push origin feature/add-validation

# PR erstellen
gh pr create --title "Add email validation" \
  --body "Adds IsValidEmail() UDF for form validation" \
  --label "feature" \
  --assignee @me
```

**Beispiel 2: Bug Hotfix**
```bash
# Hotfix Branch
git checkout -b fix/timezone-bug

# Änderungen + Commit
git add src/App-Formulas-Template.fx
git commit -m "fix: Correct CET timezone offset calculation"
git push origin fix/timezone-bug

# PR als URGENT markieren
gh pr create --title "URGENT: Fix timezone bug" \
  --body "Fixes off-by-one error in CET conversion" \
  --label "bug,urgent" \
  --assignee @me
```

**Beispiel 3: PR Review & Merge**
```bash
# PRs mit Review-Anfrage anzeigen
gh pr list --review-requested @me

# Konkrete PR prüfen
gh pr view 42 --comments

# Nach Review mergen
gh pr merge 42 --squash --auto

# PR in lokales main integrieren
git checkout main
git pull origin main
```

### Nützliche Flags
```bash
--draft              # PR als Draft erstellen
--state open|closed  # Status filtern
--assignee @me      # Mir selbst zuweisen
--label "bug"       # Label setzen
--body-file FILE    # Body aus Datei lesen
--template TEMPLATE # PR-Template verwenden
--squash            # Mit Squash mergen
--auto              # Auto-merge aktivieren
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
| `src/App-Formulas-Template.fx` | Named Formulas + 30+ UDFs |
| `src/App-OnStart-Minimal.fx` | Modernes OnStart mit State + Datenladung |
| `src/Control-Patterns-Modern.fx` | Fertige Control-Formeln |
| `docs/MIGRATION-GUIDE.md` | Legacy zu Modern Migration |
| `docs/App-Formulas-Design.md` | Architektur-Dokumentation |

---

## Claude Commands (.claude/commands/)

Custom Slash-Commands für spezifische Workflows in diesem Projekt:

### /reflect - Session Reflection

Analysiert die aktuelle Claude-Sitzung und erstellt eine strukturierte Reflection über Techniken, Muster und Lerneffekte.

**Zweck**: Dokumentation von "WIE" die Arbeit gemacht wurde, nicht "WAS" gebaut wurde

**Nutzung**:
```
/reflect                          # Vollständige Reflection
/reflect --focus tools            # Nur Tool-Nutzung analysieren
/reflect --focus patterns         # Nur Problem-Solving Patterns
/reflect --name code-review       # Custom Dateiname
```

**Output**: Datei in `.claude/reflections/YYYY-MM-DD-slug.md` mit:
- What Went Well (effektive Techniken)
- What Went Wrong (Ineffizienzen, False Starts)
- Lessons Learned (actionable Insights)
- Action Items (konkrete Verbesserungen)
- Tips & Tricks (für zukünftige Sessions)

**Beispiel-Reflection**:
```
# Session Reflection: PowerApp Code Analysis

Date: 2025-01-12
Session Goal: Analyze template patterns and identify code inconsistencies

## What Went Well
- Parallel Agent Exploration: 3 Explore agents gleichzeitig statt sequenziell
- Direct File Reading: Source-Code gelesen statt nur Dokumentation
- Issue Tracking: Strukturierte Tabelle für Fehler + Prioritäten

## Action Items
- [ ] Parallel Agents als Default für Code-Analyse nutzen (Priority: High)
- [ ] Immer 2-3 Source-Files früh lesen (Priority: High)
```

**Archivierung**: Alle Reflections unter `.claude/reflections/` für persönliche Knowledge Base

---

## Code-Qualität

- Schreibe sauberen, lesbaren Power Fx Code
- Nutze UDFs für wiederverwendbare Logik (Single Responsibility)
- Vermeide Code-Duplizierung - nutze Named Formulas
- Kommentiere nur komplexe Logik, nicht offensichtlichen Code
- Validiere Eingaben früh (Fail Fast)
- Prüfe Berechtigungen VOR Aktionen (`HasPermission()`, `CanAccessRecord()`)

---

## Git Workflow

- **main**: Produktions-Branch (protected)
- **feature/**: Neue Features (`feature/add-approval-flow`)
- **fix/**: Bug Fixes (`fix/timezone-calculation`)
- Ein Commit = eine logische Änderung
- Aussagekräftige Commit-Messages (Was + Warum)
- Keine Secrets im Code (Credentials, API-Keys)
