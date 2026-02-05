# Claude Code Projekt-Konfiguration

## Projekt-Übersicht

Dieses Projekt ist ein **PowerApps Canvas App Template** mit moderner Power Fx 2025 Architektur.

| Aspekt | Details |
|--------|---------|
| **Status** | Production-Ready (45/45 Requirements Complete) |
| **Architektur** | Deklarativ-Funktional (App.Formulas + UDFs) |
| **Sprachen** | Power Fx, JSON, YAML |
| **Daten** | Microsoft Dataverse / SharePoint Lists |
| **Lokalisierung** | Deutsch (CET Zeitzone, d.m.yyyy Datumsformat) |
| **Tooling** | VS Code mit Power Platform CLI (`pac`) |
| **UDFs** | 35+ wiederverwendbare User-Defined Functions |
| **Performance** | App.OnStart <2 Sekunden (60% schneller als Legacy) |

### Projekt-Status

Das Template ist **vollständig** und produktionsreif:

- **Phase 1** (Code Cleanup): 15/15 Requirements
- **Phase 2** (Performance): 8/8 Requirements
- **Phase 3** (Filtering): 8/8 Requirements
- **Phase 4** (UX/Docs): 13/13 Requirements

Siehe `.planning/STATE.md` für vollständige Projekthistorie.

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

## UDF Quick Reference (35+ Funktionen)

Vollständige Dokumentation: `docs/UDF-REFERENCE.md`

### Permission & Role (7 UDFs)
| UDF | Returns | Beschreibung |
|-----|---------|-------------|
| `HasPermission(name)` | Boolean | Berechtigung prüfen (create, read, edit, delete, viewall, approve) |
| `HasRole(name)` | Boolean | Rolle prüfen (admin, gf, manager, hr, sachbearbeiter, user) |
| `HasAnyRole(names)` | Boolean | Eine von mehreren Rollen (komma-separiert) |
| `HasAllRoles(names)` | Boolean | Alle angegebenen Rollen erforderlich |
| `GetRoleLabel()` | Text | Höchste Rolle als Anzeige-Label (Deutsch) |
| `GetRoleBadgeColor()` | Color | Theme-Farbe für Rollen-Badge |
| `GetRoleBadge()` | Text | Kurzer Badge-Text (Admin, GF, Manager, etc.) |

### Data Access (7 UDFs)
| UDF | Returns | Beschreibung |
|-----|---------|-------------|
| `GetUserScope()` | Text | User-Email für Filterung, oder Blank() bei ViewAll |
| `GetDepartmentScope()` | Text | Abteilung für Filterung, oder Blank() bei Admin |
| `CanAccessRecord(email)` | Boolean | Zugriff auf Record via Owner-Email |
| `CanAccessDepartment(dept)` | Boolean | Zugriff auf Abteilungs-Records |
| `CanAccessItem(email, dept)` | Boolean | Kombinierter Owner + Department Check |
| `CanEditRecord(email, status)` | Boolean | Edit erlaubt (berücksichtigt Status) |
| `CanDeleteRecord(email)` | Boolean | Delete erlaubt |

### Delegation-Safe Filter (5 UDFs)
| UDF | Returns | Beschreibung |
|-----|---------|-------------|
| `CanViewAllData()` | Boolean | User hat ViewAll-Berechtigung |
| `MatchesSearchTerm(field, term)` | Boolean | Delegation-safe Textsuche |
| `MatchesStatusFilter(status)` | Boolean | Delegation-safe Status-Filter |
| `CanViewRecord(email)` | Boolean | ViewAll OR Ownership |
| `FilteredGalleryData(my, status, search)` | Table | Kombiniert alle Filter |

### Validation (7 UDFs)
| UDF | Returns | Beschreibung |
|-----|---------|-------------|
| `IsValidEmail(text)` | Boolean | E-Mail validieren (20+ Regeln) |
| `IsNotPastDate(date)` | Boolean | Datum nicht in Vergangenheit |
| `IsDateInRange(date, start, end)` | Boolean | Datum innerhalb Bereich |
| `IsAlphanumeric(text)` | Boolean | Nur Buchstaben und Zahlen |
| `IsOneOf(value, options)` | Boolean | Wert in komma-separierter Liste |
| `HasMaxLength(text, max)` | Boolean | Text unter Maximallänge |
| `IsBlank(value)` | Boolean | Wert ist leer/null |

### Notification (7 UDFs)
| UDF | Type | Beschreibung |
|-----|------|-------------|
| `NotifySuccess(msg)` | Success | Erfolg (grün, 5s auto-dismiss) |
| `NotifyError(msg)` | Error | Fehler (rot, manuell schließen) |
| `NotifyWarning(msg)` | Warning | Warnung (amber, 5s auto-dismiss) |
| `NotifyInfo(msg)` | Info | Info (blau, 5s auto-dismiss) |
| `NotifyPermissionDenied(action)` | Error | Keine Berechtigung für Aktion |
| `NotifyActionCompleted(action, name)` | Success | Aktion abgeschlossen |
| `NotifyValidationError(field, msg)` | Warning | Validierungsfehler |

### Date & Time (8 UDFs)
| UDF | Returns | Beschreibung |
|-----|---------|-------------|
| `GetCETToday()` | Date | Heutiges Datum in CET (nicht UTC!) |
| `ConvertUTCToCET(datetime)` | DateTime | UTC nach CET konvertieren |
| `GetCETOffset()` | Number | Aktuelle CET/CEST Offset (-1 oder -2) |
| `FormatDateShort(date)` | Text | "15.1.2025" |
| `FormatDateLong(date)` | Text | "15. Januar 2025" |
| `FormatDateRelative(date)` | Text | "Heute", "Gestern", "vor 3 Tagen" |
| `FormatDateTimeCET(datetime)` | Text | "15.1.2025 14:30" |
| `FormatTime(datetime)` | Text | "14:30" |

### Text & Number (3 UDFs)
| UDF | Returns | Beschreibung |
|-----|---------|-------------|
| `FormatCurrency(amount)` | Text | "1.234,56 €" |
| `FormatNumber(value)` | Text | "1.234" mit Tausender-Trennung |
| `Slugify(text)` | Text | URL-freundlicher Text |

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

## Delegation Patterns (>2000 Records)

SharePoint und Dataverse begrenzen Queries auf **2000 Records** (Delegation Limit). Diese UDFs arbeiten delegation-safe:

### Delegation-Safe Filter UDFs

| UDF | Parameter | Beschreibung |
|-----|-----------|-------------|
| `CanViewAllData()` | none | Prüft ob User ViewAll-Berechtigung hat |
| `MatchesSearchTerm(field, term)` | field, term | Delegation-safe Textsuche mit Search() |
| `MatchesStatusFilter(statusValue)` | statusValue | Delegation-safe Status-Gleichheitsprüfung |
| `CanViewRecord(ownerEmail)` | ownerEmail | ViewAll OR Ownership Check |
| `FilteredGalleryData(...)` | 3 params | Kombiniert alle Filter-Layer |

### Beispiel: Delegation-Safe Gallery

```powerfx
// Gallery.Items - alle 4 Filter kombiniert
glr_Items.Items = FilteredGalleryData(
    tog_MyItemsOnly.Value,           // Boolean: nur eigene Items?
    drp_StatusFilter.Selected.Value, // Text: Status-Filter
    txt_Search.Text                  // Text: Suchbegriff
)
```

### Was ist delegable?

| Operation | Delegable | Beispiel |
|-----------|-----------|----------|
| `=` Gleichheit | Ja | `Status = "Active"` |
| `Search()` | Ja | `Search(Title, "term")` |
| `&&`, `\|\|` | Ja | `A && B \|\| C` |
| `<`, `>`, `<=`, `>=` | Ja | `Date < Today()` |
| `CountRows()` | **Nein** | Nutze FirstN/Skip stattdessen |
| `Filter()` mit UDF | **Nein** | UDF muss inline evaluiert werden |
| `in` Operator | **Nein** | Nutze OR-Kette stattdessen |

### Pagination für große Datasets

```powerfx
// FirstN + Skip Pattern für >2000 Records
FirstN(
    Skip(
        FilteredGalleryData(...),
        (AppState.CurrentPage - 1) * 50  // 50 = PageSize
    ),
    50
)
```

Siehe `docs/DELEGATION-PATTERNS.md` für vollständige Dokumentation.

---

## Naming Conventions

### Power Platform Komponenten
- **Solutions**: `[Publisher]_[Projektname]_[Typ]` (z.B. `contoso_CRM_Core`)
- **Tabellen**: PascalCase, Singular (z.B. `Customer`, `OrderItem`)
- **Spalten**: camelCase mit Präfix (z.B. `cust_firstName`)
- **Flows**: `[App]-[Aktion]-[Trigger]` (z.B. `CRM-SendEmail-OnCreate`)
- **Canvas Apps**: `[Bereich]_[Funktion]_App` (z.B. `Sales_OrderEntry_App`)

### Power Fx Code

**Named Formulas:** PascalCase (keine Verben, repräsentieren Daten)
- ✓ `ThemeColors` - Statische Farbkonfiguration
- ✓ `UserProfile` - Benutzerprofil-Daten
- ✓ `DateRanges` - Berechnete Datumsbereiche
- ✗ `getUserProfile` - camelCase nicht verwenden
- ✗ `theme_colors` - Underscores nicht verwenden

**UDFs (User-Defined Functions):** PascalCase mit Verb-Präfix
- Boolean Checks: `Has*`, `Can*`, `Is*`
  - ✓ `HasRole("Admin")` - Rollenprüfung
  - ✓ `CanAccessRecord(email)` - Zugriffsprüfung
  - ✓ `IsValidEmail(text)` - Validierung
- Datenabfrage: `Get*`
  - ✓ `GetUserScope()` - Scope abrufen
  - ✓ `GetThemeColor(name)` - Farbe abrufen
- Formatierung: `Format*`
  - ✓ `FormatDateShort(date)` - Datum formatieren
  - ✓ `FormatCurrency(amount)` - Währung formatieren
- Aktionen (Behavior): `Notify*`, `Show*`, `Update*`
  - ✓ `NotifySuccess(message)` - Erfolgsmeldung
  - ✓ `ShowErrorDialog(error)` - Fehlerdialog

**State-Variablen:** PascalCase (keine Präfixe)
- ✓ `AppState` - Anwendungsstatus
- ✓ `ActiveFilters` - Aktive Filter
- ✓ `UIState` - UI-Zustand
- ✗ `varAppState` - "var" Präfix nicht verwenden
- ✗ `gActiveFilters` - "g" (global) Präfix nicht verwenden

**Collections:** PascalCase mit beschreibendem Präfix
- `Cached*` - Statische Lookup-Daten (z.B. `CachedDepartments`, `CachedStatuses`)
- `My*` - Benutzerbezogene Daten (z.B. `MyRecentItems`, `MyPendingTasks`)
- `Filter*` - Gefilterte Ansichten (z.B. `FilteredOrders`)

**Controls:** Abgekürzter Typ-Präfix + Name
- `glr_` = Gallery → `glr_Orders`, `glr_RecentItems`
- `btn_` = Button → `btn_Submit`, `btn_Delete`, `btn_Cancel`
- `lbl_` = Label → `lbl_Title`, `lbl_ErrorMessage`
- `txt_` = TextInput → `txt_Search`, `txt_Email`
- `img_` = Image → `img_Logo`, `img_Avatar`
- `form_` = Form → `form_EditItem`, `form_NewRecord`
- `drp_` = Dropdown → `drp_Status`, `drp_Category`
- `ico_` = Icon → `ico_Delete`, `ico_Warning`
- `cnt_` = Container → `cnt_Header`, `cnt_Sidebar`
- `tog_` = Toggle → `tog_ActiveOnly`, `tog_ShowArchived`
- `chk_` = Checkbox → `chk_Terms`, `chk_SelectAll`
- `dat_` = DatePicker → `dat_StartDate`, `dat_DueDate`

**Vorteile der Namenskonventionen:**
- Typ sofort erkennbar (glr = Gallery, btn = Button)
- Einfacher zu tippen (3 Zeichen statt 6-10)
- Konsistente Länge für Autocomplete-Ausrichtung
- PascalCase folgt Power Fx Konventionen
- Keine Verwechslung mit Variablen (haben keine Präfixe)

**Legacy-Muster vermeiden:**
- ❌ `Gallery_Items` - Voller Typname zu lang
- ❌ `Button1`, `Button2` - Auto-generierte Namen nicht beschreibend
- ❌ `submitBtn` - camelCase inkonsistent mit Power Fx

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

### Behobene Fehler (Phase 1-4)

| Datum | Fehler | Status | Lösung |
|-------|--------|--------|--------|
| 2025-01-12 | Notification UDFs fehlen | **BEHOBEN** | 7 NotifyX() UDFs implementiert (Phase 4) |
| 2025-01-12 | FormatNumber() undefined | **BEHOBEN** | UDF implementiert in App-Formulas-Template.fx |
| 2025-01-12 | GetStatusIcon Typo | **BEHOBEN** | Korrigiert zu "builtinicon" |
| 2025-01-18 | HasAnyRole() 3-Rollen-Limit | **BEHOBEN** | Unbegrenzte Rollen via Split() |
| 2025-01-18 | IsOneOf() falscher `in` Operator | **BEHOBEN** | Korrektes Filter/CountRows Pattern |
| 2025-01-18 | IsValidEmail() zu schwach | **BEHOBEN** | 20+ Validierungsregeln hinzugefügt |
| 2025-01-18 | IsNotPastDate() gab TRUE für Blank | **BEHOBEN** | Sicherheitsfix: gibt jetzt FALSE |

### Bekannte Einschränkungen

| Bereich | Einschränkung | Workaround |
|---------|---------------|------------|
| Delegation | UDFs innerhalb Filter() nicht delegable | Nutze FilteredGalleryData() |
| Caching | Rollenänderungen nicht automatisch erkannt | Manuelles Refresh bei Azure AD-Updates |
| Offline | Keine Offline-Unterstützung | Netzwerkverbindung erforderlich |

---

## Performance Best Practices

### App.OnStart Startup Time Target: <2 Seconds

**Warum:** App muss schnell laden, um responsives Benutzererlebnis zu bieten. Langsamer Start (>5s) führt zu Benutzerunzufriedenheit und Authentifizierungs-Timeouts.

**So erreichen wir <2s:**

| Technik | Nutzen | Implementierung |
|---------|--------|-----------------|
| Sequenzielle Critical Path | Abhängigkeiten respektieren | User → Rollen → Berechtigungen (sequenziell) |
| Hintergrund-Parallelisierung | Unkritische Daten laden gleichzeitig | Concurrent() für Departments, Categories |
| API-Caching | Eliminiert redundante Office365-Aufrufe | Collections mit 5-Minuten-TTL |
| Fehlertolerante Degradation | App läuft weiter bei nicht-kritischen Fehlern | Fallback zu "Unbekannt" für fehlende Daten |

**Startup-Aufschlüsselung (erwartete Timing):**
```
Section 0 (Critical path): 500-800ms
  ├─ Office365Users.MyProfileV2(): ~300ms
  ├─ Office365Groups role checks (6 roles): ~400ms
  └─ Permission calculation: ~50ms

Section 4 (Background parallel): 300-500ms
  ├─ Departments load: ~200ms
  ├─ Categories load: ~200ms
  ├─ Statuses load: ~50ms
  └─ Priorities load: ~50ms

Section 5 (User-scoped): 200-300ms
  ├─ Recent items: ~200ms
  └─ Pending tasks: ~100ms

Sections 1-3, 6 (Config, finalize): <100ms

TOTAL: ~1050-1850ms (well under 2000ms target)
```

### API Call Reduction via Caching

**Problem:** Office365Users und Office365Groups connectors werden mehrfach pro Sitzung aufgerufen, was zu unnötigem API-Overhead führt und den Startup verlangsamt.

**Lösung:** Ergebnisse cachen und für die ganze Sitzung wiederverwenden.

**Caching-Strategie:**
- **Scope:** Session-basiert (gelöscht beim App-Schließen)
- **TTL:** 5 Minuten (Balance zwischen Aktualität und Effizienz)
- **Speicher:** Collections (CachedProfileCache, CachedRolesCache)
- **API-Aufrufe pro Sitzung:**
  - Kalter Start (erste Lade): 7 Aufrufe (1 × MyProfileV2, 6 × Office365Groups)
  - Warmer Start (Cache Hit): 0 Aufrufe
  - Ergebnis: 100% Cache-Hit-Rate nach erstem Load

**Cache-Invalidierungs-Trigger:**
1. Sitzungsende (App schließen) → neue Sitzung startet mit leerem Cache
2. TTL-Ablauf (>5 Minuten) → kann manuell aktualisiert werden
3. Explizite Aktualisierung (Benutzer klickt "Refresh") → Daten neu abrufen
4. Rollenänderung (Azure AD-Update) → NICHT automatisch erkannt (zukünftige Verbesserung)

**Wann Daten cachen:**
- ✓ CACHE: Statische oder langsam ändernde Daten (user profile, roles, departments)
- ✓ CACHE: Daten aus teuren APIs (Office365, Dataverse komplexe Abfragen)
- ✗ CACHE NICHT: Häufig ändernde Daten (aktuelle Zeit, Formularstatus)
- ✗ CACHE NICHT: Sensible Daten, die außerhalb der App ändern (z.B. Berechtigungsentzug)

**Caching für Produktion skalieren:**
- **Phase 2 (aktuell):** In-Memory Collections, gut für <10.000 gleichzeitige Sitzungen
- **Phase 4+:** Migration zu Dataverse Cache-Tabelle für 100.000+ Sitzungen
- **Phase 4+:** Service Principal Cache in Backend Flow für Multi-Tenant-Szenarien

### Concurrent() für paralleles Laden

**Prinzip:** Wenn mehrere Datenladungen KEINE Abhängigkeiten voneinander haben, laden Sie sie gleichzeitig mit Concurrent().

**Critical Path (SEQUENZIELL):**
```powerfx
// Muss in Reihenfolge geladen werden: Profile → Roles → Permissions
ClearCollect(CachedProfileCache, Office365Users.MyProfileV2());
Set(AppState, Patch(AppState, {UserRoles: UserRoles}));  // Aus Cache lesen
Set(AppState, Patch(AppState, {UserPermissions: UserPermissions}));
```

**Background Path (PARALLEL):**
```powerfx
// Können gleichzeitig geladen werden: unabhängige Collections
Concurrent(
  ClearCollect(CachedDepartments, Filter(Departments, Status = "Active")),
  ClearCollect(CachedCategories, Filter(Categories, Status = "Active")),
  ClearCollect(CachedStatuses, /* static table */),
  ClearCollect(CachedPriorities, /* static table */)
);
```

**Timing-Verbesserung:**
- Sequenziell: 300 + 200 + 200 + 50 + 50 = 800ms
- Parallel: max(300, 200, 200, 50, 50) = 300ms
- Einsparung: ~500ms (62% schneller)

### Error Handling: Critical vs Non-Critical

**Critical Data Errors:**
- Benutzerprofilladung fehlgeschlagen → APP BLOCKIEREN, Fehler anzeigen, Wiederholung erforderlich
- Pattern: IfError(call, fallback, show_error_dialog)
- Benutzer sieht: German error message mit Lösungshinweis

**Non-Critical Errors:**
- Department-Lookup fehlgeschlagen → STILLES FALLBACK, App lädt weiter
- Pattern: IfError(call, empty_fallback, no_dialog)
- Benutzer sieht: Leere Dropdown oder "Unbekannt"-Option

**Error Message Guidelines:**
- Alle Meldungen auf Deutsch (Sprache des Benutzers)
- Keine Fehlercodes, keine Stack Traces, keine technische Jargon
- Remediation-Hinweis einschließen (z.B. "Netzwerk überprüfen", "später erneut versuchen")
- Beispiele:
  - ✓ "Ihre Profilinformationen konnten nicht geladen werden. Bitte überprüfen Sie Ihre Internetverbindung."
  - ✗ "Office365Users Connector Timeout: Error -2147024809"

### Startup-Performance überwachen

**Tool:** Power Apps Monitor (eingebaut)

**Schritte:**
1. Power Apps Studio öffnen
2. Einstellungen → Zukünftige Features → Monitor-Tool (aktivieren)
3. App neu laden (Ctrl+Shift+F5)
4. Monitor-Tool öffnen (F12 oder Einstellungen → Monitor)
5. Netzwerk-Tab filtern: "OnStart" suchen
6. Gesamtdauer überprüfen (sollte <2000ms sein)

**Zu überwachende Metriken:**
- OnStart Gesamtzeit: <2000ms (Ziel)
- Office365Users Anzahl der Aufrufe: 1 (erste Lade), 0 (warmer Start)
- Office365Groups Anzahl der Aufrufe: 6 (erste Lade), 0 (warmer Start)
- Concurrent() Block-Zeit: 300-500ms (Hintergrunddaten)

**Regressions-Test:**
Nach Änderungen an App.OnStart:
1. Baseline messen (vor Änderungen)
2. Code-Änderungen durchführen
3. Neu messen (nach Änderungen)
4. Keine Performance-Regression überprüfen (sollte <2000ms bleiben)
5. Wenn Regression erkannt: Revertieren oder weiter optimieren

---

## Notification System (Phase 4)

Toast notifications provide non-blocking, Fluent Design-compliant feedback for user actions. Use notifications for form submissions, validation errors, approval actions, and success confirmations.

### Notification UDFs - Public API

All notification UDFs are defined in `App-Formulas-Template.fx` (lines 950-1000+). Never call `Notify()` directly; always use these UDFs instead for consistent styling and state management:

| UDF | Type | Usage | Auto-Dismiss | Example |
|-----|------|-------|--------------|---------|
| `NotifySuccess(msg)` | Success | Record saved, action completed | 5s | `NotifySuccess("Record saved successfully")` |
| `NotifyError(msg)` | Error | Save failed, permission denied | Manual (X button) | `NotifyError("Save failed: Check network")` |
| `NotifyWarning(msg)` | Warning | Validation failure, confirmation needed | 5s | `NotifyWarning("Email format invalid")` |
| `NotifyInfo(msg)` | Info | Status updates, informational messages | 5s | `NotifyInfo("Loading data...")` |
| `NotifyPermissionDenied(action)` | Error | User lacks permission for action | Manual | `NotifyPermissionDenied("approve records")` |
| `NotifyActionCompleted(action, name)` | Success | Action finished | 5s | `NotifyActionCompleted("Delete", "Item 1")` |
| `NotifyValidationError(field, msg)` | Warning | Form field validation failed | 5s | `NotifyValidationError("Email", "Invalid format")` |

Each UDF internally calls `AddToast()` to update the `NotificationStack` collection and display the toast in the UI.

### Toast Lifecycle

1. Call `NotifySuccess()` or related UDF (Layer 1 - Trigger)
2. UDF calls `AddToast()` internally (Layer 2 - State)
3. `AddToast()` adds row to `NotificationStack` collection
4. UI layer (`cnt_NotificationStack` container) automatically renders toast
5. If `AutoClose=true`: Toast fades and disappears after configured duration (default 5s)
6. If `AutoClose=false`: Toast persists until user clicks X button or app closes

See `Control-Patterns-Modern.fx` (Pattern 1.9) for container implementation.

### Code Examples

**Example 1: Form submission success**
```powerfx
btn_SaveRecord.OnSelect =
If(
    IsValid(form_EditRecord),
    Patch(Items, ThisItem, form_EditRecord.Updates);
    NotifySuccess("Record saved successfully"),
    NotifyValidationError("Form", "Please complete all required fields")
)
```

**Example 2: Delete with confirmation**
```powerfx
btn_DeleteRecord.OnSelect =
If(
    Confirm("Delete this record permanently?"),
    IfError(
        Remove(Items, ThisItem);
        NotifyActionCompleted("Delete", ThisItem.Name),
        NotifyError("Failed to delete: " & Error.Message)
    )
)
```

**Example 3: Custom notification with specific timing**
```powerfx
// If you need custom message, type, or duration:
AddToast("Custom notification", "Info", true, 8000)
// Parameters: message, type ("Success"/"Error"/"Warning"/"Info"), autoClose (true/false), duration(ms)
```

### Configuration

Toast behavior is configured in `ToastConfig` Named Formula in `App-Formulas-Template.fx` (around line 885):

```powerfx
ToastConfig = {
    Width: 350,              // Toast width in pixels
    MaxWidth: 400,           // Maximum width on large screens
    SuccessDuration: 5000,   // Auto-dismiss after 5 seconds
    WarningDuration: 5000,   // Auto-dismiss after 5 seconds
    InfoDuration: 5000,      // Auto-dismiss after 5 seconds
    ErrorDuration: 0,        // Never auto-dismiss errors (0 = manual only)
    AnimationDuration: 300   // Fade-in/fade-out animation speed (ms)
}
```

**How to customize:**

- **Change auto-dismiss timeout:** Edit `SuccessDuration`, `WarningDuration`, `InfoDuration` in `ToastConfig`
- **Change toast colors:** Edit `GetToastBackground()` UDF (lines 920-930) to return different `ThemeColors` values
- **Change icons:** Edit `GetToastIcon()` UDF (lines 935-945) to use different Unicode characters (e.g., "👍" instead of "✓")
- **Add custom notification type:** Add case to `GetToastBackground()`, `GetToastIcon()`, `GetToastIconColor()` UDFs, then create new UDF like `NotifyDebug(msg) = AddToast(msg, "Debug", true, 5000)`

Example: To make errors auto-dismiss after 10 seconds:
```powerfx
ErrorDuration: 10000  // Change in ToastConfig
```

### Best Practices

- Always use specific UDF (`NotifySuccess` vs `NotifyError`) for correct styling and behavior
- Errors should describe both problem and solution: "Failed to save: Check network connection"
- Keep messages brief (one sentence, <80 characters ideally)
- Avoid showing sensitive information in toasts (user emails, database IDs, system errors)
- For long operations (>5s), disable button during operation and show progress indicator
- Group related notifications (don't spam 10 toasts for single action)
- Error toasts never auto-dismiss; user must acknowledge with X button
- Test notifications in Power Apps Monitor (F12) to verify they appear in `NotificationStack` collection

### Common Issues & Quick Fixes

| Issue | Cause | Solution |
|-------|-------|----------|
| Toasts don't appear | `NotificationStack` not initialized | Check App.OnStart Section 7 for `ClearCollect(NotificationStack, Table())` |
| Toast blocks content | `cnt_NotificationStack` ZIndex too low | Set `ZIndex = 1000` on notification container |
| Toasts overlap | Container `Spacing` property wrong | Set `cnt_NotificationStack` property: `Spacing: 12` |
| Error auto-dismisses | `ErrorDuration` in `ToastConfig` not 0 | Change `ErrorDuration: 0` in `ToastConfig` |
| Collection grows unbounded | Old toasts not being removed | Verify `RemoveToast()` called on close button, auto-dismiss formula working |

See [docs/TROUBLESHOOTING.md](docs/TROUBLESHOOTING.md) for detailed diagnosis of these and other issues.

### Toast Revert/Undo System

Erweiterte Toast-Funktionalität für Aktionen mit Undo-Möglichkeit:

| UDF | Parameter | Beschreibung |
|-----|-----------|-------------|
| `AddToUndo(data)` | Record-Daten | Speichert Daten für späteres Revert |
| `RevertLastAction()` | none | Führt Undo der letzten Aktion aus |

**Beispiel: Delete mit Undo**
```powerfx
btn_Delete.OnSelect =
With(
    {itemToDelete: ThisItem},
    // Speichere Item für Undo
    AddToUndo({
        ItemID: itemToDelete.ID,
        ItemData: itemToDelete,
        ActionType: "Delete"
    });
    // Lösche Item
    Remove(Items, itemToDelete);
    // Toast mit Undo-Button
    NotifySuccessWithRevert(
        "Item gelöscht",
        "Rückgängig",
        {ItemID: itemToDelete.ID}
    )
)
```

**Revert Callbacks:**
| Callback ID | Aktion | Beschreibung |
|-------------|--------|-------------|
| 0 | DELETE_UNDO | Gelöschtes Item wiederherstellen |
| 1 | ARCHIVE_UNDO | Archiviertes Item reaktivieren |
| 2 | CUSTOM | Benutzerdefinierte Undo-Aktion |

Siehe `docs/TOAST-REVERT-DESIGN.md` für vollständige Architektur-Dokumentation.

---

## Deployment & ALM

### Automatisierte Deployment-Scripts

Dieses Projekt enthält vollständige Deployment-Automation für den ALM-Lifecycle:
**DEV** → **Git** → **TEST** → **PROD**

**Quick Commands:**
```powershell
# DEV → Git (täglich nach Entwicklung)
.\deploy-dev.bat YourSolutionName

# Git → TEST (wöchentlich für UAT)
.\deploy-test.bat YourSolutionName

# Git → PROD (nach Approval)
.\deploy-prod.bat YourSolutionName
```

**Deployment-Dokumentation:**

| Dokument | Wann nutzen? |
|----------|--------------|
| **[QUICK-START.md](QUICK-START.md)** | ⚡ Schnellreferenz (eine Seite zum Ausdrucken) |
| **[DEPLOYMENT-INSTRUCTIONS.md](DEPLOYMENT-INSTRUCTIONS.md)** | 📖 Vollständige Schritt-für-Schritt Anleitung |
| **[DEPLOYMENT-WORKFLOW.md](DEPLOYMENT-WORKFLOW.md)** | 🔄 Visuelle Workflows und Decision Trees |
| **[DEPLOYMENT-CHEATSHEET.md](DEPLOYMENT-CHEATSHEET.md)** | 🎯 Command-Referenz für häufige Tasks |
| **[README-DEPLOYMENT.md](README-DEPLOYMENT.md)** | 📦 Übersicht über alle Deployment-Dateien |
| **[docs/DEPLOYMENT-GUIDE.md](docs/DEPLOYMENT-GUIDE.md)** | 🔧 Technisches Handbuch mit CI/CD |

**Wichtig:** Siehe [DEPLOYMENT-INSTRUCTIONS.md](DEPLOYMENT-INSTRUCTIONS.md) für erstmalige Einrichtung (PAC CLI Installation, Environment-Authentifizierung).

### PAC CLI Befehle (Manuell)

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

## Wichtige Dateien & Dokumentation

### Source Code (4,131 Zeilen Power Fx)

| Datei | Zeilen | Beschreibung |
|-------|--------|-------------|
| `src/App-Formulas-Template.fx` | 1,664 | Named Formulas + 35+ UDFs |
| `src/App-OnStart-Minimal.fx` | 952 | State-Variablen, Caching, Initialisierung |
| `src/Control-Patterns-Modern.fx` | 1,515 | Fertige Control-Formeln für Gallery, Form, Toast |

### Dokumentation (19 Dateien)

**Architektur & Design:**
| Datei | Beschreibung |
|-------|-------------|
| `docs/App-Formulas-Design.md` | Architektur-Dokumentation, Layer-Konzept |
| `docs/UDF-REFERENCE.md` | **Vollständige API-Referenz aller 35+ UDFs** |
| `docs/UI-DESIGN-REFERENCE.md` | Fluent Design Implementation Guide |
| `docs/POWER-PLATFORM-BEST-PRACTICES.md` | Platform-weite Best Practices |

**Filtering & Delegation:**
| Datei | Beschreibung |
|-------|-------------|
| `docs/DELEGATION-PATTERNS.md` | 4 delegation-safe UDFs für >2000 Records |
| `docs/FILTER-COMPOSITION-GUIDE.md` | Filter kombinieren (Role + Search + Status) |
| `docs/GALLERY-PERFORMANCE.md` | FirstN/Skip Pagination für große Datasets |

**Toast Notifications:**
| Datei | Beschreibung |
|-------|-------------|
| `docs/TOAST-NOTIFICATION-GUIDE.md` | Vollständige Toast-Dokumentation |
| `docs/TOAST-NOTIFICATION-SETUP.md` | Setup-Anleitung für neue Apps |
| `docs/TOAST-REVERT-DESIGN.md` | Undo/Revert Architektur |
| `docs/TOAST-REVERT-IMPLEMENTATION.md` | Revert-System Implementation |
| `docs/TOAST-REVERT-EXAMPLES.md` | Copy-Paste Beispiele für Revert |

**Deployment & Migration:**
| Datei | Beschreibung |
|-------|-------------|
| `docs/DEPLOYMENT-GUIDE.md` | Technisches Handbuch mit CI/CD |
| `docs/MIGRATION-GUIDE.md` | Legacy zu Modern Migration |
| `docs/TROUBLESHOOTING.md` | Symptom-basierte Problemdiagnose |
| `docs/DATAVERSE-ITEM-SCHEMA.md` | Dataverse Tabellen-Schema |

### Projekt-Planung

| Datei | Beschreibung |
|-------|-------------|
| `.planning/PROJECT.md` | Projektzweck und Value Proposition |
| `.planning/REQUIREMENTS.md` | 45 v1 Requirements (alle complete) |
| `.planning/ROADMAP.md` | 4-Phasen Delivery Plan |
| `.planning/STATE.md` | Aktueller Projektstatus und Metriken |

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

## Claude Skills (.claude/skills/)

Domain-spezifische Anleitungen für Claude Code, die automatisch bei relevanten Tasks geladen werden.

### Verfügbare Skills

| Skill | Datei | Inhalt |
|-------|-------|--------|
| **Power Apps** | `.claude/skills/power-apps/SKILL.md` | Canvas & Model-Driven Apps, Power Fx Patterns |
| **Power Automate** | `.claude/skills/power-automate/SKILL.md` | Cloud Flows, Trigger, Aktionen |
| **Dataverse** | `.claude/skills/dataverse/SKILL.md` | Entity/Table Modeling, Relationships |
| **Power Platform** | `.claude/skills/power-platform/SKILL.md` | Platform-übergreifende Konzepte |
| **Error Learning** | `.claude/skills/error-learning/SKILL.md` | Fehlerbehandlungs-Patterns |

### Skill-Nutzung

Skills werden automatisch geladen wenn sie zum aktuellen Task passen. Du kannst Skills auch explizit anfordern:

```
"Nutze den power-apps skill für diese Aufgabe"
"Zeige mir den dataverse skill"
```

### Skill-Struktur

Jeder Skill enthält:
- **Kontext**: Wann der Skill anwendbar ist
- **Patterns**: Bewährte Code-Muster
- **Anti-Patterns**: Was vermieden werden sollte
- **Beispiele**: Copy-Paste-fähige Lösungen

---

## Code-Qualität

### Grundprinzipien

- Schreibe sauberen, lesbaren Power Fx Code
- Nutze UDFs für wiederverwendbare Logik (Single Responsibility)
- Vermeide Code-Duplizierung - nutze Named Formulas
- Kommentiere nur komplexe Logik, nicht offensichtlichen Code
- Validiere Eingaben früh (Fail Fast)
- Prüfe Berechtigungen VOR Aktionen (`HasPermission()`, `CanAccessRecord()`)

### Power Fx Best Practices (Microsoft-Compliant)

**Vollständige Dokumentation:** Siehe `docs/POWER-FX-BEST-PRACTICES.md` (755 Zeilen)

#### 1. Deklarativ vor Imperativ

> **Microsoft's Goldene Regel:** "Declarative is always best, so use this facility [behavior UDFs] only when you must."

```powerfx
// ✅ GUT: Deklarative Named Formula
ThemeColors = {
    Primary: ColorValue("#0078D4"),
    Success: ColorValue("#107C10")
};

// ✅ GUT: Einfache Behavior UDF (nur wenn nötig)
NotifySuccess(message: Text): Void = {
    Notify(message, NotificationType.Success);
    AddToast(message, "Success", true, 5000)
};

// ❌ OVER-ENGINEERED: Unnötige Abstraktion
_InternalHelper(msg, type) = With({...}, ...);
```

**Warum einfach besser ist:**
- Leichter zu debuggen (Fehler zeigen auf genaue Funktion)
- Selbst-dokumentierend (Funktionsname = Verhalten)
- Keine versteckte Indirektion
- Einzelne Typen änderbar ohne andere zu beeinflussen

#### 2. With() nur für berechnete Werte

```powerfx
// ✅ RICHTIG: Berechnung eines Wertes
With(
    {elapsed: Now() - ThisItem.CreatedAt},
    If(elapsed < TimeValue("0:0:0.3"),
       elapsed / TimeValue("0:0:0.3"),
       1)
)

// ❌ FALSCH: Seiteneffekte in With()
With(
    {enumType: Switch(...)},
    Notify(message, enumType);  // ❌ Seiteneffekt
    AddToast(...)               // ❌ Seiteneffekt
)
```

**Microsoft-Dokumentation:** [With Function Reference](https://learn.microsoft.com/en-us/power-platform/power-fx/reference/function-with)

#### 3. Magic Numbers eliminieren

```powerfx
// ❌ SCHLECHT: Was bedeutet 0, 1, 2?
HandleRevert(toastID, 0, data);  // Was ist 0?

// ✅ GUT: Named Constants Registry
RevertCallbackIDs = {
    DELETE_UNDO: 0,
    ARCHIVE_UNDO: 1,
    CUSTOM: 2
};

HandleRevert(toastID, RevertCallbackIDs.DELETE_UNDO, data);
```

**Vorteile:**
- Selbst-dokumentierender Code
- IntelliSense zeigt verfügbare Optionen
- Single Source of Truth
- Einfach erweiterbar

#### 4. State konsolidieren

```powerfx
// ❌ SCHLECHT: 4 separate globale Variablen
Set(NotificationCounter, 0);
Set(ToastToRemove, Blank());
Set(ToastAnimationStart, Blank());
Set(ToastReverting, Blank());

// ✅ GUT: Konsolidiertes Record
Set(ToastState, {
    Counter: 0,
    ToRemove: Blank(),
    AnimationStart: Blank(),
    Reverting: Blank()
});
```

**Vorteile:**
- Bessere Organisation
- Einfacher zu resetten
- Klare Zugehörigkeit
- Weniger globale Variablen

#### 5. Immer gegen Microsoft Docs validieren

**Vor jedem Refactoring:**
1. ✅ Offizielle Microsoft Power Fx Dokumentation prüfen
2. ✅ Best Practices von Microsoft befolgen
3. ✅ Keine "cleveren" Abstraktionen ohne klaren Nutzen
4. ✅ Einfachheit über Komplexität

**Wichtige Ressourcen:**
- [Power Fx Overview](https://learn.microsoft.com/en-us/power-platform/power-fx/overview)
- [Working with Formulas In-Depth](https://learn.microsoft.com/en-us/power-apps/maker/canvas-apps/working-with-formulas-in-depth)
- [UDFs General Availability](https://www.microsoft.com/en-us/power-platform/blog/power-apps/power-apps-user-defined-functions-ga/)

### Lessons Learned (Refactoring Sessions)

**Session 2025-02-05: Notification System Refactoring**

| Lektion | Erkenntnis |
|---------|-----------|
| **Docs First** | Immer zuerst gegen offizielle Microsoft-Dokumentation validieren |
| **Simplicity Wins** | Bestehende einfache Patterns oft besser als "clevere" Refactorings |
| **With() Misuse** | Häufiger Fehler: With() ist für berechnete Werte, NICHT für Seiteneffekte |
| **Magic Numbers** | Named Constants machen Code selbst-dokumentierend |
| **State Consolidation** | Records > mehrere separate Variablen für verwandten State |
| **Over-Engineering** | DRY-Prinzip kann zu Over-Abstraction führen - Balance wichtig |

**Ergebnis:** 4 gezielte Verbesserungen statt massivem Refactoring
- ✅ RevertCallbackIDs Registry (magic numbers eliminiert)
- ✅ Fade Animations implementiert (Microsoft-compliant With() Nutzung)
- ✅ Cleanup Timer (Memory Leak Prevention)
- ✅ ToastState konsolidiert (4 → 2 globale Variablen)

**Verworfene Idee:** Helper-Funktion zur Reduktion von Duplikation
- ❌ Würde unnötige Komplexität hinzufügen
- ❌ Verletzt Microsoft's "declarative first" Prinzip
- ❌ Macht Debugging schwieriger ohne klaren Nutzen

---

## Git Workflow

- **main**: Produktions-Branch (protected)
- **feature/**: Neue Features (`feature/add-approval-flow`)
- **fix/**: Bug Fixes (`fix/timezone-calculation`)
- Ein Commit = eine logische Änderung
- Aussagekräftige Commit-Messages (Was + Warum)
- Keine Secrets im Code (Credentials, API-Keys)
