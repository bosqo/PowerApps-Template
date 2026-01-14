# Module Selection Checklist

Verwenden Sie diese Checkliste, um zu entscheiden, welche optionalen Module Sie für Ihre App benötigen.

---

## 1. Notifications Module

**Beschreibung**: Toast-Nachrichten, Error-Dialoge, Bestätigungen

| Frage | Ja | Nein |
|-------|----|----|
| Brauchen Sie Custom Toast-Nachrichten? | ✓ | |
| Sollen Errors mit Details angezeigt werden? | ✓ | |
| Brauchen Sie Bestätigungsdialoge? | ✓ | |
| Reicht `Notify()` aus? | | ✓ |

**Entscheidung:**
- ✅ **Kopieren Sie es**, wenn Sie 2+ Ja-Antworten haben
- ❌ **Überspringen Sie es**, wenn Sie nur `Notify()` brauchen

**Größe**: ~50 Zeilen Code

---

## 2. Filtering Module

**Beschreibung**: Advanced Search, Multi-Field Filters, Pagination

| Frage | Ja | Nein |
|-------|----|----|
| Brauchen Sie Multi-Field Suche? | ✓ | |
| Sollen Filter kombinierbar sein? | ✓ | |
| Brauchen Sie Pagination? | ✓ | |
| Reicht einfacher `Filter()` aus? | | ✓ |

**Entscheidung:**
- ✅ **Kopieren Sie es**, wenn Sie 2+ Ja-Antworten haben
- ❌ **Überspringen Sie es**, wenn nur einfache Gallery mit Filter()

**Größe**: ~100 Zeilen Code

---

## 3. Audit Log Module

**Beschreibung**: User-Aktionen tracken, Änderungshistorie

| Frage | Ja | Nein |
|-------|----|----|
| Brauchen Sie Compliance/Audit Trail? | ✓ | |
| Müssen Sie tracken, wer was geändert hat? | ✓ | |
| Ist Änderungshistorie nötig? | ✓ | |
| Ist keine Audit benötigt? | | ✓ |

**Entscheidung:**
- ✅ **Kopieren Sie es**, wenn Sie 1+ Ja-Antworten haben
- ❌ **Überspringen Sie es**, wenn keine Audit benötigt

**Größe**: ~80 Zeilen Code

**Vorsicht**: Benötigt zusätzliche Dataverse-Tabelle "AuditLog"

---

## 4. Export Module

**Beschreibung**: CSV/Excel Export für Daten

| Frage | Ja | Nein |
|-------|----|----|
| Brauchen Sie CSV Export? | ✓ | |
| Brauchen Sie Excel Export? | ✓ | |
| Sollen Benutzer Daten exportieren können? | ✓ | |
| Brauchen Sie keinen Export? | | ✓ |

**Entscheidung:**
- ✅ **Kopieren Sie es**, wenn Sie 1+ Ja-Antworten haben
- ❌ **Überspringen Sie es**, wenn Export nicht nötig

**Größe**: ~60 Zeilen Code

---

## 5. Forms Module

**Beschreibung**: Form Validation, Multi-Step Wizards, Calculated Fields

| Frage | Ja | Nein |
|-------|----|----|
| Brauchen Sie komplexe Validierung? | ✓ | |
| Brauchen Sie Multi-Step Wizards? | ✓ | |
| Haben Sie abhängige Felder (Calculated)? | ✓ | |
| Einfache Form mit Basic Validation? | | ✓ |

**Entscheidung:**
- ✅ **Kopieren Sie es**, wenn Sie 2+ Ja-Antworten haben
- ❌ **Überspringen Sie es**, wenn nur einfache Form

**Größe**: ~120 Zeilen Code

---

## Quick Recommendations

### Minimal App (Nur Core)
```
✅ Core Bootstrap
❌ Keine Module
```

**Für**: Read-only Apps, einfache Galleries ohne Edit

---

### Standard App (Core + Notifications)
```
✅ Core Bootstrap
✅ Notifications Module
❌ Weitere Module
```

**Für**: Standard CRUD Apps mit Benutzer-Feedback

---

### Advanced App (Core + mehrere Module)
```
✅ Core Bootstrap
✅ Notifications Module
✅ Filtering Module
✅ Audit Log Module (optional)
✅ Forms Module (optional)
```

**Für**: Komplexe Apps mit Search, Validation, Audit

---

### Enterprise App (Core + Alle Module)
```
✅ Core Bootstrap
✅ Notifications Module
✅ Filtering Module
✅ Audit Log Module
✅ Export Module
✅ Forms Module
```

**Für**: Große Unternehmen mit allen Features

---

## Gesamt Größe (Ungefähr)

| Komponente | Zeilen | Größe |
|-----------|--------|-------|
| Core Bootstrap | 200 | ~10 KB |
| Notifications | 50 | ~2 KB |
| Filtering | 100 | ~5 KB |
| Audit Log | 80 | ~4 KB |
| Export | 60 | ~3 KB |
| Forms | 120 | ~6 KB |
| **Zusammen (Minimal)** | **200** | **~10 KB** |
| **Zusammen (All)** | **610** | **~30 KB** |

---

## Entscheidungsbaum

```
Brauchen Sie einen App?
│
├─ JA → Core Bootstrap kopieren (PFLICHT)
│
├─ Brauchen Sie Custom Notifications?
│ ├─ JA → Notifications Module
│ └─ NEIN → ❌
│
├─ Brauchen Sie Advanced Search?
│ ├─ JA → Filtering Module
│ └─ NEIN → ❌
│
├─ Brauchen Sie Audit Trail?
│ ├─ JA → Audit Log Module
│ └─ NEIN → ❌
│
├─ Brauchen Sie Export?
│ ├─ JA → Export Module
│ └─ NEIN → ❌
│
└─ Brauchen Sie Complex Forms?
  ├─ JA → Forms Module
  └─ NEIN → ❌
```

---

## Step-by-Step: Welche Module?

### Schritt 1: Core Bootstrap wählen

**Entscheidung**: Alle Apps brauchen Core Bootstrap
- ✅ App-Formulas-Core.fx
- ✅ App-OnStart-Core.fx

---

### Schritt 2: Notifications?

**Ja-Antworten auf diese Fragen?**
- User sollen Toast-Nachrichten sehen
- Error-Handling mit Details nötig
- Custom Dialoge/Confirmations

**Wenn Ja**: Notifications Module kopieren
**Wenn Nein**: Überspringen

---

### Schritt 3: Filtering?

**Ja-Antworten auf diese Fragen?**
- Mehre Such-Felder kombinieren
- Filter speicherbar/wiederherstellbar
- Pagination mit Such-Integration

**Wenn Ja**: Filtering Module kopieren
**Wenn Nein**: Überspringen

---

### Schritt 4: Audit Log?

**Ja-Antworten auf diese Fragen?**
- Compliance-Anforderungen
- "Wer hat was gemacht" tracken
- Änderungshistorie anzeigen

**Wenn Ja**: Audit Log Module kopieren (+ Tabelle erstellen!)
**Wenn Nein**: Überspringen

---

### Schritt 5: Export?

**Ja-Antworten auf diese Fragen?**
- CSV Export nötig
- Excel Export nötig
- Benutzer sollen Daten exportieren

**Wenn Ja**: Export Module kopieren
**Wenn Nein**: Überspringen

---

### Schritt 6: Forms?

**Ja-Antworten auf diese Fragen?**
- Komplexe Validierung (mehrere Felder)
- Multi-Step Wizard nötig
- Felder mit Abhängigkeiten

**Wenn Ja**: Forms Module kopieren
**Wenn Nein**: Überspringen

---

## Nach der Auswahl

1. **Dateien öffnen**
   - `src/core/App-Formulas-Core.fx` - IMMER
   - `src/core/App-OnStart-Core.fx` - IMMER
   - `src/modules/[SelectedModule].fx` - Pro Modul

2. **In Power Apps Studio kopieren**
   - App.Formulas-Sektion
   - App.OnStart Sektion
   - Controls anpassen

3. **Testen**
   - Jedes Modul isoliert testen
   - Module zusammen testen
   - Error-Cases testen

4. **Go Live**
   - App publishieren
   - Benutzer trainieren
   - Feedback sammeln

---

## Häufig gestellte Fragen

**F: Kann ich Module später noch hinzufügen?**
A: Ja! Apps sind modular. Einfach neues Modul hinzufügen.

**F: Kann ich ein Modul wieder entfernen?**
A: Ja! Einfach den Code-Block löschen.

**F: Was kostet jedes Modul an Performance?**
A: Minimal (~1-2 KB pro Modul in der App-Datei).

**F: Kann ich zwei Module kombinieren, die konfligieren?**
A: Ja, aber müssen Funktionsnamen anpassen.

---

## Noch Unschlüssig?

**Regel**: Start mit Minimal, später erweitern
- Beginnen Sie mit **Core + Notifications**
- Fügen Sie weitere Module später hinzu
- Entfernen Sie ungenutzte Module

Das ist am effizientesten und leichtesten wartbar!
