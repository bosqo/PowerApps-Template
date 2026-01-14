# Migration Guide: Modern Template Architecture

## Übersicht

Dieser Guide erklärt die neue **Core + Modules** Architektur und wie man sie in neuen oder bestehenden PowerApps Apps verwendet.

### Neue Architektur

```
Core Bootstrap (PAC)          Optional Modules (Copy-Paste)
├─ App-Formulas-Core.fx       ├─ Notifications-Module.fx
├─ App-OnStart-Core.fx        ├─ Filtering-Module.fx
└─ Essenzielle UDFs           ├─ AuditLog-Module.fx
                              ├─ Export-Module.fx
                              └─ Forms-Module.fx
```

---

## Quick Start: Neue App erstellen

### Schritt 1: Core Bootstrap mit PAC CLI deployen

```bash
# Login zu Ihrem Environment
pac auth select --index 1

# Core Bootstrap in Ihre neue App deployen
# (Future: PAC deployment script)
# Aktuell: Manuell kopieren (siehe Schritt 2)
```

### Schritt 2: Core Bootstrap (Copy-Paste)

**In Power Apps Studio:**

1. **App.Formulas** öffnen (Settings → Display → App.Formulas)
2. Gesamten Inhalt aus `src/core/App-Formulas-Core.fx` kopieren
3. Einfügen

**In App.OnStart:**

1. **App.OnStart** öffnen
2. Gesamten Inhalt aus `src/core/App-OnStart-Core.fx` kopieren
3. Einfügen
4. Datenquellen anpassen (Items, Tasks, etc.)

### Schritt 3: Optional Modules hinzufügen

Je nach Anforderung Module aus `src/modules/` kopieren:

```powerfx
// MODULE: [Name] - OPTIONAL: kann gelöscht werden
// In App.Formulas oder App.OnStart einfügen
// Siehe Modul-Dokumentation für Nutzung
```

---

## Module Auswählen

### Notifications Module (OPTIONAL)

**Wann brauchen Sie es?**
- Toast-Nachrichten für Benutzer anzeigen
- Error-Dialoge mit Details
- Bestätigungsdialoge

**Wann NICHT nötig?**
- Sie nutzen nur die native `Notify()` Funktion
- Keine Custom Error Handling nötig

**UDFs:**
```powerfx
ShowSuccess(message)           // Grüne Toast
ShowError(message)             // Rote Toast
ShowConfirm(message, onYes)    // Bestigung
```

---

### Filtering Module (OPTIONAL)

**Wann brauchen Sie es?**
- Multi-field Suche & Filterung
- Saved Filter Kombinationen
- Pagination mit Search

**Wann NICHT nötig?**
- Nur einfache Gallery mit Filter()
- Keine Advanced Search nötig

**UDFs:**
```powerfx
GetFilteredItems(filter)       // Gefilterte Items
ApplyFilter(field, value)      // Filter aktualisieren
ResetFilters()                 // Alle Filter zurücksetzen
```

---

### Audit Log Module (OPTIONAL)

**Wann brauchen Sie es?**
- Benutzer-Aktionen tracken (Create, Edit, Delete)
- Compliance/Audit Requirements
- Änderungshistorie anzeigen

**Wann NICHT nötig?**
- Keine Audit Requirements
- Keine Änderungshistorie nötig

**UDFs:**
```powerfx
LogAction(action, details)     // Aktion protokollieren
GetAuditLog(itemId)            // Änderungshistorie abrufen
```

---

### Export Module (OPTIONAL)

**Wann brauchen Sie es?**
- CSV/Excel Export Funktionalität
- Daten exportieren & herunterladen

**Wann NICHT nötig?**
- Kein Export nötig
- Power Automate Flow reicht aus

**UDFs:**
```powerfx
ExportToCSV(collection)        // CSV generieren
ExportToExcel(collection)      // Excel-Format
```

---

### Forms Module (OPTIONAL)

**Wann brauchen Sie es?**
- Komplexe Form-Validierung
- Multi-Step Wizards
- Calculated Fields mit Abhängigkeiten

**Wann NICHT nötig?**
- Einfache Form mit Basic Validation
- Keine Wizards nötig

**UDFs:**
```powerfx
ValidateForm(form)             // Form-Validierung
IsFormValid()                   // Ist Form ok?
ShowNextStep()                 // Wizard Schritt
```

---

## Schritt-für-Schritt: Module hinzufügen

### Beispiel: Notifications Module

1. **Datei öffnen**: `src/modules/Notifications-Module.fx`

2. **Code kopieren**: Alle Formulas zwischen den Markern
   ```powerfx
   // ============================================================
   // MODULE: Notifications
   // OPTIONAL: Can be safely deleted
   // ============================================================
   ```

3. **In Power Apps einfügen**:
   - Unter `App.Formulas` (für UDFs) einfügen
   - ODER unter `App.OnStart` (für Set/Collections)

4. **Im Control nutzen**:
   ```powerfx
   // Button.OnSelect
   If(HasPermission("Delete"),
       Remove(Items, Gallery.Selected);
       ShowSuccess("Gelöscht"),
       ShowError("Keine Berechtigung", "")
   )
   ```

5. **Test**: App starten & testen

---

## Module Entfernen

**Module sind sicher löschbar!** Einfach den gesamten Block löschen:

```powerfx
// Vor dem Löschen:
// ============================================================
// MODULE: [Name]
// OPTIONAL: Can be safely deleted
// ============================================================
// [100+ lines of code]

// Nach dem Löschen:
// (nichts - einfach gelöscht)
```

**Wichtig**: Stellen Sie sicher, dass der Code nicht mehr aufgerufen wird:
```powerfx
// Suchen nach: ShowSuccess(
// Suchen nach: ShowError(
// Usw.
```

---

## Häufige Fragen

### F: Kann ich mehrere Module kombinieren?

**A**: Ja! Module sind unabhängig. Sie können beliebig kombinieren:
- Notifications + Filtering + Audit Log (alles zusammen)
- Nur Notifications
- Nur Export
- Keine Module (nur Core)

### F: Wie aktualisiere ich ein Modul später?

**A**:
1. Altes Modul-Code löschen (kompletten Block)
2. Neuen Code aus `src/modules/` kopieren
3. Wieder einfügen

### F: Was ist der Unterschied zu einem Power App Component?

**A**:
- **Modules** = Copy-Paste Code (schnell, einfach, portabel)
- **Components** = Reusable UI Elements (komplexer, aber wiederverwendbar)

Für einfache Feature wie Notifications: Modules besser.
Für UI-Komponenten mit Wiederverwendung: Components besser.

### F: Kann ich ein Modul anpassen?

**A**: Ja! Nach dem Kopieren können Sie:
- Variable-Namen ändern
- Funktionen erweitern
- Mit anderen Modulen kombinieren
- UI-Text (German) ändern

---

## Häufige Fehler

### Fehler 1: Modul zeigt "undefined"

**Ursache**: Code nicht vollständig kopiert

**Lösung**:
1. Gesamten Block (von `//` bis zum Ende) kopieren
2. Alle Dependencies prüfen (Listed im Modul-Header)
3. Datenquellen prüfen (Items, Tasks, etc.)

### Fehler 2: Modul-Funktionen funktionieren nicht

**Ursache**: Abhängigkeit nicht vorhanden

**Jedes Modul benötigt**: Core Bootstrap
- `ThemeColors`, `Permission`, etc. (aus App.Formulas)
- `AppState`, `Filter`, `UI` (aus App.OnStart)

**Lösung**:
1. Core Bootstrap prüfen (vollständig kopiert?)
2. Dependencies am Anfang des Moduls lesen
3. Fehlende Teile nachkopieren

### Fehler 3: Konflikte zwischen Modulen

**Ursache**: Zwei Module mit gleicher Funktion

**Beispiel**:
```powerfx
// Modul A: ShowError(message)
// Modul B: ShowError(message) <- Konflikt!
```

**Lösung**:
1. Eine Funktion löschen (oder umbenennen)
2. Code anpassen, der alte Funktion aufruft

---

## Checkliste: Neue App Setup

- [ ] Core Bootstrap (`App.Formulas` + `App.OnStart`) kopiert
- [ ] Datenquellen verbunden (Items, Tasks)
- [ ] Azure AD Gruppen-IDs eingegeben
- [ ] Optionale Module ausgewählt & kopiert
- [ ] Module getestet (Test mit Testkonto)
- [ ] Display Text auf Deutsch prüfen
- [ ] Alle Controls angepasst
- [ ] App publishiert

---

## Dateien Referenz

| Datei | Inhalt | Deployment |
|-------|--------|-----------|
| `src/core/App-Formulas-Core.fx` | Core Named Formulas + UDFs | Copy-Paste |
| `src/core/App-OnStart-Core.fx` | State + Data Loading | Copy-Paste |
| `src/modules/Notifications-Module.fx` | OPTIONAL | Copy-Paste wenn nötig |
| `src/modules/Filtering-Module.fx` | OPTIONAL | Copy-Paste wenn nötig |
| `src/modules/AuditLog-Module.fx` | OPTIONAL | Copy-Paste wenn nötig |
| `src/modules/Export-Module.fx` | OPTIONAL | Copy-Paste wenn nötig |
| `src/modules/Forms-Module.fx` | OPTIONAL | Copy-Paste wenn nötig |
| `docs/MODULE-CHECKLIST.md` | Module Selection Guide | Dokumentation |

---

## Next Steps

1. **Neue App**: Core Bootstrap deployen + Module nach Bedarf
2. **Bestehende App**: Schrittweise auf neue Architektur migrieren
3. **Team**: Dokumentieren & trainieren
4. **Feedback**: Erfahrungen teilen & verbessern

---

## Support

- Für Fehler: CLAUDE.md → "Häufige Fallstricke" Sektion prüfen
- Für Module: Modul-Header lesen (Dependencies, Nutzung)
- Für Architektur: `MODERNIZATION-DESIGN.md` lesen
