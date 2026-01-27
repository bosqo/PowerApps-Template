# Toast Revert Button - UI Implementation Guide

## Overview

Diese Anleitung zeigt, wie du den **Revert/Undo-Button** zu deinem bestehenden Toast-System hinzufügst.

**Voraussetzungen**:
- ✅ Toast-System bereits implementiert (siehe `TOAST-NOTIFICATION-SETUP.md`)
- ✅ App-Formulas mit Revert UDFs geladen
- ✅ App.OnStart mit ToastReverting Variable konfiguriert

**Zeitaufwand**: ~10 Minuten (3 neue Controls hinzufügen)
**Komplexität**: Einfach

---

## Step 1: Revert Button Container hinzufügen

### 1.1 Neuen Container erstellen

1. Wähle `cnt_Toast` im Tree View aus
2. Klicke auf **Einfügen** → **Layout** → **Horizontaler Container**
3. Benenne das Control um in: `cnt_RevertAction`

> **Position im Tree**: cnt_RevertAction sollte NEBEN (nicht nested in) `lbl_ToastMessage` sein, aber VOR `btn_CloseToast`

### 1.2 Container Properties konfigurieren

| Property | Wert | Erklärung |
|----------|------|-----------|
| **Visible** | `ThisItem.HasRevert && !ThisItem.IsReverting` | Nur wenn Revert-Button aktiv UND nicht gerade reverting |
| **LayoutMode** | `LayoutMode.Horizontal` | Button und Optional-Elemente nebeneinander |
| **LayoutGap** | `8` | 8px Abstand zwischen Elementen |
| **Padding** | `0` | Kein zusätzliches Padding |
| **Fill** | `RGBA(0, 0, 0, 0)` | Transparent |
| **Width** | `Auto` | Automatische Breite basierend auf Inhalt |
| **Height** | `32` | Match mit Revert-Button Höhe |

---

## Step 2: Revert Button hinzufügen

### 2.1 Button-Control erstellen

1. Wähle `cnt_RevertAction` im Tree View aus (WICHTIG!)
2. Klicke auf **Einfügen** → **Button**
3. Benenne das Control um in: `btn_RevertAction`

### 2.2 Button Properties konfigurieren

#### **Behavior Properties**

| Property | Wert | Erklärung |
|----------|------|-----------|
| **Text** | `ThisItem.RevertLabel` | Zeigt "Undo", "Restore", etc. |
| **OnSelect** | `HandleRevert(ThisItem.ID, ThisItem.RevertCallbackID, ThisItem.RevertData)` | Ruft Revert-Handler auf |
| **DisplayMode** | `DisplayMode.Edit` | Immer interaktiv |

#### **Styling Properties**

| Property | Wert | Erklärung |
|----------|------|-----------|
| **Fill** | `RGBA(0, 0, 0, 0)` | Transparenter Hintergrund |
| **HoverFill** | `ThemeColors.SurfaceHover` | Heller Hover-Effekt |
| **PressedFill** | `ThemeColors.Border` | Dunkler Pressed-Effekt |
| **Color** | `ThemeColors.Info` | Blauer Text (Aktion) |
| **HoverColor** | `ThemeColors.Primary` | Dunkelblau bei Hover |
| **BorderThickness** | `1` | Dünner Rand |
| **BorderColor** | `ThemeColors.Info` | Blauer Rand |
| **BorderStyle** | `BorderStyle.Solid` | Durchgezogener Rand |
| **CornerRadius** | `2` | Leicht abgerundete Ecken |

#### **Typography Properties**

| Property | Wert | Erklärung |
|----------|------|-----------|
| **FontSize** | `12` | Kleine Schrift (Sub-Action) |
| **FontWeight** | `FontWeight.Semibold` | Halbfett für Sichtbarkeit |

#### **Sizing Properties**

| Property | Wert | Erklärung |
|----------|------|-----------|
| **Width** | `Auto` | Automatisch an Text anpassen |
| **Height** | `32` | Touch-friendly Größe |
| **Padding** | `8` | 8px Text-Padding |

#### **Accessibility**

| Property | Wert | Erklärung |
|----------|------|-----------|
| **AccessibleLabel** | `ThisItem.RevertLabel & ": " & ThisItem.Message` | "Undo: Item deleted" |

---

## Step 3: Loading-Spinner hinzufügen (Optional)

### 3.1 Label für Spinner-Icon erstellen

1. Wähle `cnt_RevertAction` aus
2. Klicke auf **Einfügen** → **Text** → **Label**
3. Benenne das Control um in: `lbl_RevertLoading`

### 3.2 Properties konfigurieren

| Property | Wert | Erklärung |
|----------|------|-----------|
| **Text** | `"⟳"` | Spinner-Symbol (Unicode) |
| **Visible** | `ThisItem.IsReverting` | Nur während Revert-Aktion |
| **Color** | `ThemeColors.Info` | Blau (Aktion) |
| **FontSize** | `14` | Sichtbar aber klein |
| **Width** | `20` | Kleine Fläche |
| **Height** | `20` | Kleine Fläche |
| **Align** | `Align.Center` | Zentriert |
| **VerticalAlign** | `VerticalAlign.Middle` | Vertikal zentriert |
| **Rotation** | `(Now() - ThisItem.CreatedAt) * 360 / TimeValue("0:0:2")` | Dreht sich 1x pro 2 Sekunden |

---

## Step 4: Fehler-Message hinzufügen (Optional)

### 4.1 Fehler-Label erstellen

1. Wähle `cnt_RevertAction` aus
2. Klicke auf **Einfügen** → **Text** → **Label**
3. Benenne das Control um in: `lbl_RevertError`

### 4.2 Properties konfigurieren

| Property | Wert | Erklärung |
|----------|------|-----------|
| **Text** | `ThisItem.RevertError` | Fehlertext aus Toast-Daten |
| **Visible** | `!IsBlank(ThisItem.RevertError)` | Nur wenn Fehler vorhanden |
| **Color** | `ThemeColors.Error` | Rot (Fehler) |
| **FontSize** | `12` | Kleine Schrift |
| **FontStyle** | `FontStyle.Italic` | Kursiv (Feedback) |
| **Width** | `Fill` | Füllt verfügbaren Platz |
| **Height** | `Auto` | Automatische Höhe |
| **AutoHeight** | `true` | Passt sich an Inhalt an |

---

## Step 5: Control-Hierarchie prüfen

Nach der Implementierung sollte dein Tree View so aussehen:

```
📱 HomeScreen (Hauptscreen)
├── 📦 cnt_NotificationStack (Vertical Container)
│   └── 📦 cnt_Toast (Horizontal Container) [Template]
│       ├── 🏷️ lbl_ToastIcon (Label)
│       ├── 🏷️ lbl_ToastMessage (Label)
│       ├── 📦 cnt_RevertAction (Horizontal Container) [NEW]
│       │   ├── 🔘 btn_RevertAction (Button) [NEW]
│       │   ├── 🏷️ lbl_RevertLoading (Label - Optional)
│       │   └── 🏷️ lbl_RevertError (Label - Optional)
│       └── 🔘 btn_CloseToast (Button)
```

**Wichtig**:
- `cnt_RevertAction` ist Child von `cnt_Toast` (nicht nested tiefer)
- Reihenfolge: Icon → Message → RevertAction → CloseToast

---

## Step 6: Bestehenden Code anpassen

Falls deine cnt_Toast einen festgelegten LayoutMode hat, überprüfe:

```powerfx
// cnt_Toast.LayoutMode
LayoutMode.Horizontal  // ✓ Sollte horizontal sein

// Falls vertikal:
// Ändere zu Horizontal, damit Icon, Message, RevertAction, CloseToast nebeneinander sind
```

Falls deine btn_CloseToast ganz rechts sein soll, nutze:

```powerfx
// Alternative: Verwende FlexLayout (Power Apps 2024+)
// Oder: Erstelle Spacer Label mit Width = Fill zwischen RevertAction und CloseToast
```

---

## Step 7: Testen

### 7.1 Test-Button erstellen

```powerfx
// btn_TestRevert.OnSelect
NotifyDeleteWithUndo(
    "Test Item",
    {
        ItemID: "123",
        ItemName: "Test Item",
        Status: "Active"
    }
)
```

### 7.2 Funktionalität testen

1. App starten
2. Klick auf Test-Button
3. Success Toast mit "Rückgängig" Button erscheint
4. **Test 1**: Klick "Rückgängig"
   - ✅ Loading-Spinner dreht sich
   - ✅ Nach kurzer Zeit: Success "Item restored"
   - ✅ Toast verschwindet

5. **Test 2**: Erstelle neue Toast → Warte 5 Sekunden
   - ✅ Toast fades und verschwindet
   - ✅ "Rückgängig" Button wird zugleich unsichtbar

6. **Test 3**: Mehrere Toasts
   - Erstelle 3 Toasts
   - Klick "Rückgängig" auf mittlerem Toast
   - ✅ Nur mittleres Toast wird verarbeitet
   - ✅ Andere 2 Toasts bleiben unverändert

---

## Integration in bestehende App

### Pattern 1: Delete mit Undo

```powerfx
// btn_DeleteRecord.OnSelect
If(
    Confirm("Wirklich löschen?"),
    IfError(
        // Speichere gelöschtes Item für Restore
        Set(DeletedItem, Gallery.Selected);

        // Lösche Item
        Remove(Items, Gallery.Selected);

        // Zeige Toast mit Undo-Button
        NotifyDeleteWithUndo(
            Gallery.Selected.Name,
            {
                ItemID: Gallery.Selected.ID,
                ItemName: Gallery.Selected.Name,
                // Alle Felder für Restore
                Status: DeletedItem.Status,
                Description: DeletedItem.Description,
                Owner: DeletedItem.Owner
            }
        ),
        // Fehlerbehandlung
        NotifyError("Fehler: " & Error.Message)
    )
)
```

### Pattern 2: Archive mit Restore

```powerfx
// btn_ArchiveRecord.OnSelect
If(
    HasPermission("Archive"),
    IfError(
        Patch(Items, Gallery.Selected, {Status: "Archived"});
        NotifyArchiveWithUndo(
            Gallery.Selected.Name,
            {
                ItemID: Gallery.Selected.ID,
                ItemName: Gallery.Selected.Name
            }
        ),
        NotifyError("Fehler: " & Error.Message)
    ),
    NotifyPermissionDenied("Archive")
)
```

### Pattern 3: Bulk-Action mit Undo

```powerfx
// btn_BulkArchive.OnSelect
If(
    CountRows(SelectedItems) > 0,
    IfError(
        ForAll(SelectedItems, Patch(Items, @Value, {Status: "Archived"}));
        NotifyWithRevert(
            "Archiviert: " & Text(CountRows(SelectedItems)) & " Einträge",
            "Success",
            "Rückgängig",
            {
                Count: CountRows(SelectedItems),
                Items: SelectedItems
            },
            2  // CustomCallback - siehe HandleRevert
        ),
        NotifyError("Fehler: " & Error.Message)
    )
)
```

---

## Custom Revert Handler (Advanced)

Falls du einen Custom Callback brauchst (CallbackID = 2):

### In App-Formulas: HandleRevert erweitern

```powerfx
// In HandleRevert() - füge neue Case hinzu nach ARCHIVE_UNDO:

// 2: CUSTOM - Bulk undo
2,
IfError(
    // Reactivate all items
    ForAll(
        revertData.Items,
        Patch(Items, @Value, {Status: "Active"})
    );
    RemoveToast(toastID);
    NotifySuccess("Aktion rückgängig gemacht: " & revertData.Count & " Einträge"),
    Patch(
        NotificationStack,
        LookUp(NotificationStack, ID = toastID),
        {
            IsReverting: false,
            RevertError: "Fehler: " & Error.Message
        }
    )
),
```

---

## Anpassungen

### Position des Revert-Buttons

**Rechts statt neben Message** (besser bei langen Nachrichten):

```powerfx
// Alternative Hierarchie:
cnt_Toast (LayoutMode.Horizontal)
├── lbl_ToastIcon
├── lbl_ToastMessage (Width = Fill)
├── cnt_RevertAction (Width = Auto)
└── btn_CloseToast
```

### Revert-Button Styling ändern

**Weniger sichtbar** (Subtle):

```powerfx
// btn_RevertAction
Fill = RGBA(0, 0, 0, 0)
Color = ThemeColors.TextSecondary  // Grau statt Blau
BorderThickness = 0  // Kein Rand
```

**Auffälliger** (Prominent):

```powerfx
// btn_RevertAction
Fill = ThemeColors.Info  // Blauer Hintergrund
Color = ThemeColors.Surface  # Weißer Text
BorderThickness = 0
```

### Revert-Label anpassen

```powerfx
// Statt "Rückgängig" für Delete, verwende "Wiederherstellen":
NotifyDeleteWithUndo(
    itemName,
    revertData,
    "Wiederherstellen"  // Custom label
)

// Hinweis: Die vordefinierte Funktion nutzt "Rückgängig"
// Für Custom Label verwende NotifySuccessWithRevert direkt
```

---

## Häufige Probleme

### Problem 1: Revert-Button erscheint nicht

**Symptom**: Toast ohne Revert-Button sichtbar

**Lösungen**:

1. **HasRevert nicht gesetzt**
   - Prüfe: btn_TestRevert.OnSelect nutzt NotifyDeleteWithUndo?
   - Oder: NotifyWithRevert mit HasRevert=true?

2. **cnt_RevertAction.Visible = false**
   - Prüfe: `ThisItem.HasRevert && !ThisItem.IsReverting`
   - Falls ThisItem.HasRevert nicht existiert: AddToastWithRevert nicht verwendet

3. **Container-Layout Problem**
   - Prüfe: cnt_RevertAction ist Child von cnt_Toast?
   - Prüfe: cnt_Toast.LayoutMode = LayoutMode.Horizontal?

---

### Problem 2: Klick auf Revert-Button macht nichts

**Symptom**: Button klickbar aber keine Aktion

**Lösungen**:

1. **HandleRevert nicht definiert**
   - Prüfe: Formeln → Suche "HandleRevert"
   - Wenn fehlt: Copy aus App-Formulas-Template.fx

2. **Formel in OnSelect falsch**
   - Prüfe: btn_RevertAction.OnSelect = `HandleRevert(ThisItem.ID, ThisItem.RevertCallbackID, ThisItem.RevertData)`

3. **Datenbank-Änderung fehlgeschlagen**
   - Öffne Power Apps Monitor (F12)
   - Suche Error im Revert-Handler
   - Prüfe: Berechtigungen, Feldtypen, Validierungen

---

### Problem 3: Loading-Spinner dreht sich nicht

**Symptom**: Revert-Aktion läuft aber kein Spinner sichtbar

**Lösungen**:

1. **IsReverting nicht aktualisiert**
   - Prüfe: HandleRevert setzt `IsReverting: true` am Anfang
   - Prüfe: HandleRevert setzt `IsReverting: false` am Ende (IfError)

2. **Rotation-Formel falsch**
   - Prüfe: `lbl_RevertLoading.Rotation = (Now() - ThisItem.CreatedAt) * 360 / TimeValue("0:0:2")`
   - Power Apps muss Continuous Update haben

3. **Label nicht sichtbar**
   - Prüfe: lbl_RevertLoading.Visible = `ThisItem.IsReverting`
   - Prüfe: Text = "⟳" und FontSize groß genug (14px)

---

### Problem 4: Fehler-Message überlagert Button

**Symptom**: lbl_RevertError verdeckt btn_RevertAction

**Lösung**: Nutze Vertical Layout für Fehler:

```powerfx
// Erstelle neue Struktur:
cnt_Toast (Auto Layout)
├── cnt_TopRow (Horizontal - Icon + Message + Revert + Close)
└── lbl_RevertError (Full Width - Error message below)
```

---

## Performance-Tipps

### 1. Cleanup alte Revert-Daten

```powerfx
// In App.OnStart oder Timer (z.B. alle 5 Minuten):
If(
    CountRows(
        Filter(NotificationStack,
            HasRevert = true && Now() - CreatedAt > TimeValue("0:5:0")
        )
    ) > 10,
    ForAll(
        FirstN(
            Filter(NotificationStack,
                HasRevert = true && Now() - CreatedAt > TimeValue("0:5:0")
            ),
            CountRows(...) - 10
        ),
        Remove(NotificationStack, @Value)
    )
)
```

### 2. Revert-Daten minimieren

```powerfx
// ✓ GUT: Nur Essentielles
{ItemID: "123", ItemName: "Foo"}

// ✗ SCHLECHT: Ganze Records
{Item: Gallery.Selected}  // Zu groß!
```

---

## Checkliste: Fertig?

- [ ] 3 neue Controls erstellt (cnt_RevertAction, btn_RevertAction, lbl_RevertLoading/Error)
- [ ] Alle Formeln aus Anleitung kopiert
- [ ] App.Formulas mit HandleRevert und NotifyDeleteWithUndo
- [ ] App.OnStart mit ToastReverting variable
- [ ] Test-Button funktioniert (Revert-Button sichtbar)
- [ ] Klick auf Revert-Button triggert Aktion
- [ ] Loading-Spinner sichtbar während Revert
- [ ] Success-Toast nach erfolgreichem Revert
- [ ] Integration in Delete/Archive Buttons
- [ ] Fehlerbehandlung funktioniert

✅ **Alles erledigt! Dein Toast-Revert-System ist fertig.**

---

## Nächste Schritte

1. **Integration testen**: Delete-, Archive-, Bulk-Buttons
2. **Fehlerbehandlung**: Was passiert bei Permission Denied?
3. **UX-Refinement**: Animation verbessern, Texte übersetzen
4. **Production**: Testing auf mobilen Geräten

---

*Letzte Aktualisierung: 2025-01-22 | Phase 4 Extended*
