# Toast Notification System - Setup-Anleitung

## Übersicht

Diese Anleitung zeigt, wie du das Toast-Notification-System in deiner PowerApp implementierst. Das System besteht aus drei Layern, die bereits größtenteils vorbereitet sind:

- ✅ **Layer 1 (UDFs)**: Bereits definiert in `src/App-Formulas-Template.fx`
- ✅ **Layer 2 (State)**: Bereits definiert in `src/App-OnStart-Minimal.fx`
- ❌ **Layer 3 (UI)**: **Muss manuell erstellt werden** (diese Anleitung)

**Zeitaufwand**: ~15-20 Minuten
**Schwierigkeit**: Mittel
**Voraussetzungen**: Power Apps Studio, Template bereits importiert

---

## Voraussetzungen prüfen

Bevor du startest, stelle sicher dass:

1. **App.Formulas geladen**: Öffne Power Apps Studio → Formeln → Prüfe ob `NotifySuccess` existiert
2. **App.OnStart ausgeführt**: Formeln → App.OnStart → Prüfe ob `NotificationStack` Collection definiert ist
3. **Hauptscreen vorhanden**: Du hast einen Hauptscreen (z.B. `HomeScreen` oder `MainScreen`)

---

## Schritt 1: Haupt-Container erstellen (cnt_NotificationStack)

### 1.1 Control hinzufügen

1. Öffne Power Apps Studio
2. Wähle deinen **Hauptscreen** aus (z.B. `HomeScreen`)
3. Klicke auf **Einfügen** → **Layout** → **Vertikaler Container**
4. Benenne das Control um in: `cnt_NotificationStack`

### 1.2 Properties konfigurieren

Wähle `cnt_NotificationStack` aus und setze folgende Properties im rechten Panel:

#### **Items Property** (wichtigste Einstellung!)

```powerfx
NotificationStack
```

> **Erklärung**: Bindet den Container an die NotificationStack Collection aus App.OnStart

---

#### **Position Properties**

| Property | Wert | Erklärung |
|----------|------|-----------|
| **X** | `Parent.Width - 400` | Rechter Bildschirmrand (350px Breite + 50px Padding) |
| **Y** | `16` | 16px vom oberen Rand (Fluent Design Spacing) |
| **Width** | `If(CountRows(NotificationStack) > 0, 380, 0)` | 380px wenn Toasts vorhanden, sonst 0 (versteckt) |
| **Height** | `Parent.Height - 32` | Volle Höhe minus Top/Bottom Padding |

---

#### **Layout Properties**

| Property | Wert | Erklärung |
|----------|------|-----------|
| **LayoutMode** | `LayoutMode.Vertical` | Toasts stapeln vertikal |
| **LayoutDirection** | `LayoutDirection.Vertical` | Von oben nach unten |
| **LayoutAlignItems** | `LayoutAlignItems.End` | Rechtsbündig ausrichten |
| **Spacing** | `12` | 12px Abstand zwischen Toasts |
| **Padding** | `8` | 8px Innenabstand |

---

#### **Styling Properties**

| Property | Wert | Erklärung |
|----------|------|-----------|
| **Fill** | `RGBA(0, 0, 0, 0)` | Transparent (nur Toasts haben Hintergrund) |
| **ZIndex** | `1000` | Über allem anderen rendern |
| **Visible** | `CountRows(NotificationStack) > 0` | Nur sichtbar wenn Toasts vorhanden |
| **ClipContents** | `false` | Animationen dürfen überlaufen |

---

### 1.3 Verifizierung

Nach der Konfiguration sollte `cnt_NotificationStack`:
- Rechts oben auf dem Screen positioniert sein
- Aktuell unsichtbar sein (da NotificationStack leer ist)
- Im Tree View als Child des Hauptscreens erscheinen

---

## Schritt 2: Toast-Tile erstellen (cnt_Toast)

### 2.1 Control hinzufügen

1. Wähle `cnt_NotificationStack` im Tree View aus (wichtig!)
2. Klicke auf **Einfügen** → **Layout** → **Horizontaler Container**
3. Benenne das Control um in: `cnt_Toast`

> **Wichtig**: `cnt_Toast` MUSS ein **Child** von `cnt_NotificationStack` sein!

### 2.2 Properties konfigurieren

#### **Layout Properties**

| Property | Wert | Erklärung |
|----------|------|-----------|
| **LayoutMode** | `LayoutMode.Horizontal` | Icon, Message, Button horizontal |
| **LayoutAlignItems** | `LayoutAlignItems.Center` | Vertikal zentriert |
| **LayoutGap** | `12` | 12px Abstand zwischen Elementen |
| **Padding** | `16` | 16px Innenabstand |

---

#### **Styling Properties**

| Property | Wert | Erklärung |
|----------|------|-----------|
| **Fill** | `GetToastBackground(ThisItem.Type)` | Dynamische Farbe je Toast-Typ |
| **BorderColor** | `GetToastBorderColor(ThisItem.Type)` | Farbiger Akzent-Rand |
| **BorderThickness** | `2` | 2px sichtbarer Rand |
| **BorderStyle** | `BorderStyle.Solid` | Durchgezogener Rand |
| **CornerRadius** | `4` | Abgerundete Ecken (Fluent Design) |
| **DropShadow** | `DropShadow.Semibold` | Schatten für Tiefe |

---

#### **Sizing Properties**

| Property | Wert | Erklärung |
|----------|------|-----------|
| **Width** | `ToastConfig.Width` | 350px (aus ToastConfig Named Formula) |
| **Height** | `Auto` | Automatisch an Inhalt anpassen |

---

#### **Visibility & Animation Properties**

| Property | Wert | Erklärung |
|----------|------|-----------|
| **Visible** | Siehe unten | Auto-Dismiss nach 5 Sekunden |
| **Opacity** | Siehe unten | Fade-out Animation |

**Visible Formula** (kopiere vollständig):

```powerfx
If(
    ThisItem.AutoClose && Now() - ThisItem.CreatedAt > TimeValue("0:0:5"),
    false,
    true
)
```

**Opacity Formula** (kopiere vollständig):

```powerfx
If(
    ThisItem.AutoClose && Now() - ThisItem.CreatedAt > TimeValue("0:0:4.7"),
    Max(0, 1 - ((Now() - ThisItem.CreatedAt - TimeValue("0:0:4.7")) / TimeValue("0:0:0.3"))),
    1
)
```

> **Erklärung**:
> - Nach 4.7 Sekunden beginnt Fade-out (0.3s Dauer)
> - Nach 5.0 Sekunden wird Toast unsichtbar
> - Error-Toasts (AutoClose=false) bleiben immer sichtbar

---

## Schritt 3: Icon hinzufügen (lbl_ToastIcon)

### 3.1 Control hinzufügen

1. Wähle `cnt_Toast` im Tree View aus
2. Klicke auf **Einfügen** → **Text** → **Label**
3. Benenne das Control um in: `lbl_ToastIcon`

### 3.2 Properties konfigurieren

| Property | Wert | Erklärung |
|----------|------|-----------|
| **Text** | `GetToastIcon(ThisItem.Type)` | ✓ ✕ ⚠ ℹ je nach Typ |
| **Color** | `GetToastIconColor(ThisItem.Type)` | Grün/Rot/Gelb/Blau |
| **FontSize** | `24` | Große, sichtbare Icons |
| **FontWeight** | `FontWeight.Bold` | Fett für Sichtbarkeit |
| **Align** | `Align.Center` | Horizontal zentriert |
| **VerticalAlign** | `VerticalAlign.Middle` | Vertikal zentriert |
| **Width** | `32` | Feste Breite |
| **Height** | `32` | Feste Höhe |
| **AccessibleLabel** | `ThisItem.Type & " notification icon"` | Screenreader-Text |

---

## Schritt 4: Message Label hinzufügen (lbl_ToastMessage)

### 4.1 Control hinzufügen

1. Wähle `cnt_Toast` im Tree View aus
2. Klicke auf **Einfügen** → **Text** → **Label**
3. Benenne das Control um in: `lbl_ToastMessage`

### 4.2 Properties konfigurieren

| Property | Wert | Erklärung |
|----------|------|-----------|
| **Text** | `ThisItem.Message` | Nachricht aus NotificationStack |
| **FontSize** | `14` | Standard-Textgröße |
| **Color** | `ThemeColors.Text` | Dunkler Text (Theme) |
| **Font** | `Font.'Segoe UI'` | Fluent Design Font |
| **WordWrap** | `true` | Text umbrechen bei langen Nachrichten |
| **AutoHeight** | `true` | Höhe an Text anpassen |
| **Width** | `Fill` | Restlichen Platz ausfüllen |
| **Align** | `Align.Left` | Linksbündig |
| **VerticalAlign** | `VerticalAlign.Middle` | Vertikal zentriert |

---

## Schritt 5: Close Button hinzufügen (btn_CloseToast)

### 5.1 Control hinzufügen

1. Wähle `cnt_Toast` im Tree View aus
2. Klicke auf **Einfügen** → **Button**
3. Benenne das Control um in: `btn_CloseToast`

### 5.2 Properties konfigurieren

#### **Behavior Properties**

| Property | Wert | Erklärung |
|----------|------|-----------|
| **Text** | `"✕"` | Unicode X-Symbol |
| **OnSelect** | `RemoveToast(ThisItem.ID)` | Entfernt Toast aus Collection |
| **DisplayMode** | `DisplayMode.Edit` | Immer klickbar |

---

#### **Styling Properties**

| Property | Wert | Erklärung |
|----------|------|-----------|
| **Fill** | `RGBA(0, 0, 0, 0)` | Transparenter Hintergrund |
| **HoverFill** | `ThemeColors.SurfaceHover` | Grauer Hover-Effekt |
| **PressedFill** | `ThemeColors.Border` | Dunkler Pressed-Effekt |
| **Color** | `ThemeColors.TextSecondary` | Grauer Text |
| **HoverColor** | `ThemeColors.Text` | Schwarzer Text bei Hover |
| **BorderThickness** | `0` | Kein Rahmen |
| **FontSize** | `18` | Große, klickbare Fläche |
| **FontWeight** | `FontWeight.Semibold` | Halbfett |

---

#### **Sizing Properties**

| Property | Wert | Erklärung |
|----------|------|-----------|
| **Width** | `32` | Touch-freundliche Größe |
| **Height** | `32` | Touch-freundliche Größe |

---

#### **Accessibility Properties**

| Property | Wert | Erklärung |
|----------|------|-----------|
| **AccessibleLabel** | `"Close " & ThisItem.Type & " notification"` | "Close error notification" etc. |

---

## Schritt 6: Control-Hierarchie verifizieren

Deine Tree View sollte jetzt so aussehen:

```
📱 HomeScreen (oder dein Hauptscreen)
└── 📦 cnt_NotificationStack (Vertical Container)
    └── 📦 cnt_Toast (Horizontal Container) [Template]
        ├── 🏷️ lbl_ToastIcon (Label)
        ├── 🏷️ lbl_ToastMessage (Label)
        └── 🔘 btn_CloseToast (Button)
```

**Wichtig**:
- `cnt_Toast` ist **Child** von `cnt_NotificationStack`
- `lbl_ToastIcon`, `lbl_ToastMessage`, `btn_CloseToast` sind **Children** von `cnt_Toast`

---

## Schritt 7: Testen

### 7.1 Test-Button erstellen (optional)

Erstelle einen Test-Button zum Auslösen von Notifications:

1. Füge einen Button auf dem Screen hinzu
2. Benenne ihn: `btn_TestToast`
3. **OnSelect**:

```powerfx
NotifySuccess("Success - verschwindet nach 5 Sekunden");
NotifyError("Error - bleibt bis X geklickt wird");
NotifyWarning("Warning - verschwindet nach 5 Sekunden");
NotifyInfo("Info - verschwindet nach 5 Sekunden")
```

### 7.2 App starten

1. Klicke auf **Play** (▶️) oben rechts
2. Klicke auf `btn_TestToast`
3. Erwartetes Verhalten:
   - 4 Toasts erscheinen rechts oben
   - Success/Warning/Info verschwinden nach ~5 Sekunden
   - Error bleibt sichtbar bis X geklickt wird
   - Fade-out Animation in den letzten 0.3 Sekunden

### 7.3 Test-Checkliste

- [ ] **Position**: Toasts erscheinen rechts oben
- [ ] **Farben**: Success=Grün, Error=Rot, Warning=Gelb, Info=Blau
- [ ] **Icons**: ✓ ✕ ⚠ ℹ korrekt angezeigt
- [ ] **Auto-Dismiss**: Success/Warning/Info verschwinden nach 5s
- [ ] **Persist**: Error bleibt bis X geklickt wird
- [ ] **Fade-out**: Smooth Fade-Animation bei Auto-Dismiss
- [ ] **Close Button**: X entfernt einzelne Toasts sofort
- [ ] **Stacking**: Mehrere Toasts stapeln vertikal
- [ ] **Non-Blocking**: App bleibt interaktiv (Buttons klickbar)

---

## Schritt 8: Integration in bestehende App

### 8.1 Save-Button mit Notification

Beispiel: Formular-Speichern mit Feedback

```powerfx
// btn_SaveRecord.OnSelect
If(
    IsValid(form_EditRecord),
    // Erfolgreich
    Patch(Items, ThisItem, form_EditRecord.Updates);
    NotifySuccess("Datensatz erfolgreich gespeichert"),
    // Fehler
    NotifyValidationError("Formular", "Bitte alle Pflichtfelder ausfüllen")
)
```

### 8.2 Delete-Button mit Confirmation

Beispiel: Löschen mit Bestätigung und Feedback

```powerfx
// btn_DeleteRecord.OnSelect
If(
    Confirm("Datensatz wirklich löschen?"),
    IfError(
        Remove(Items, ThisItem);
        NotifyActionCompleted("Löschen", ThisItem.Name),
        NotifyError("Fehler beim Löschen: " & Error.Message)
    )
)
```

### 8.3 Permission-Denied Feedback

Beispiel: Keine Berechtigung

```powerfx
// btn_AdminPanel.OnSelect
If(
    HasRole("Admin"),
    Navigate(AdminScreen),
    NotifyPermissionDenied("den Admin-Bereich")
)
```

---

## Häufige Probleme & Lösungen

### Problem 1: Toasts erscheinen nicht

**Symptom**: Klick auf Test-Button zeigt keine Toasts

**Lösungen**:

1. **NotificationStack nicht initialisiert**
   - Prüfe: Formeln → App.OnStart → Suche nach `ClearCollect(NotificationStack, Table())`
   - Wenn fehlt: Füge hinzu in App.OnStart Section 7

2. **cnt_NotificationStack.Items nicht gebunden**
   - Prüfe: Wähle `cnt_NotificationStack` → Items Property = `NotificationStack`

3. **Visible = false**
   - Prüfe: `cnt_NotificationStack.Visible` = `CountRows(NotificationStack) > 0`

4. **ZIndex zu niedrig**
   - Prüfe: `cnt_NotificationStack.ZIndex` = `1000`

---

### Problem 2: Toasts überlagern Content

**Symptom**: Toasts blockieren Buttons/Formulare

**Lösungen**:

1. **Container-Fill transparent**
   - Prüfe: `cnt_NotificationStack.Fill` = `RGBA(0, 0, 0, 0)`

2. **Position anpassen**
   - Aktuell: `X = Parent.Width - 400`
   - Alternative: `X = Parent.Width - 420` (mehr Abstand rechts)

---

### Problem 3: Error-Toasts verschwinden

**Symptom**: Fehler-Toasts verschwinden nach 5 Sekunden (sollten sie nicht)

**Lösung**:

1. **ToastConfig prüfen**
   - Öffne `src/App-Formulas-Template.fx`
   - Suche `ToastConfig`
   - Prüfe: `ErrorDuration: 0` (nicht 5000!)

2. **Visible-Formel prüfen**
   - `cnt_Toast.Visible` MUSS `ThisItem.AutoClose` prüfen
   - Errors haben `AutoClose = false`

---

### Problem 4: Keine Icons sichtbar

**Symptom**: Nur leerer Platz statt ✓ ✕ ⚠ ℹ

**Lösungen**:

1. **GetToastIcon UDF fehlt**
   - Prüfe: Formeln → Suche `GetToastIcon`
   - Wenn fehlt: Kopiere aus `src/App-Formulas-Template.fx:944-954`

2. **Font unterstützt keine Unicode-Zeichen**
   - Ändere `lbl_ToastIcon.Font` zu `Font.'Segoe UI'` oder `Font.'Segoe UI Symbol'`

---

### Problem 5: Toasts stapeln nicht

**Symptom**: Nur ein Toast sichtbar, andere verschwinden

**Lösung**:

1. **LayoutMode prüfen**
   - `cnt_NotificationStack.LayoutMode` = `LayoutMode.Vertical`

2. **Height prüfen**
   - `cnt_NotificationStack.Height` = `Parent.Height - 32` (nicht feste Zahl!)

---

## Performance-Optimierung

### 1. Collection Cleanup

Wenn deine App lange läuft, kann NotificationStack wachsen. Füge Cleanup hinzu:

```powerfx
// In App.OnStart oder Timer (alle 5 Minuten)
If(
    CountRows(NotificationStack) > 100,
    ClearCollect(
        NotificationStack,
        FirstN(NotificationStack, 50)  // Behalte nur 50 neueste
    )
)
```

### 2. Animation deaktivieren (Low-End Devices)

Wenn Performance-Probleme auftreten:

```powerfx
// cnt_Toast.Opacity
1  // Statt Animation-Formel
```

### 3. Maximale Toast-Anzahl begrenzen

In `src/App-Formulas-Template.fx` → `AddToast()`:

```powerfx
// Vor Collect, füge hinzu:
If(
    CountRows(NotificationStack) > 10,
    Remove(NotificationStack, First(NotificationStack))  // Ältesten entfernen
);
```

---

## Anpassungen

### Toast-Position ändern

**Links statt rechts**:

```powerfx
// cnt_NotificationStack.X
20  // Statt: Parent.Width - 400
```

**Unten statt oben**:

```powerfx
// cnt_NotificationStack.Y
Parent.Height - 200  // Statt: 16

// cnt_NotificationStack.LayoutDirection
LayoutDirection.Vertical  // Neueste unten
```

---

### Toast-Größe ändern

**Breitere Toasts (450px statt 350px)**:

In `src/App-Formulas-Template.fx` → `ToastConfig`:

```powerfx
ToastConfig = {
    Width: 450,  // Statt 350
    ...
}
```

Dann aktualisiere:

```powerfx
// cnt_NotificationStack.X
Parent.Width - 500  // Statt 400 (450 + 50 Padding)
```

---

### Auto-Dismiss-Zeit ändern

In `src/App-Formulas-Template.fx` → `ToastConfig`:

```powerfx
ToastConfig = {
    SuccessDuration: 3000,    // 3 Sekunden (statt 5)
    WarningDuration: 7000,    // 7 Sekunden (statt 5)
    InfoDuration: 5000,       // Unverändert
    ErrorDuration: 0,         // Niemals
    AnimationDuration: 300    // Unverändert
}
```

Dann aktualisiere Formeln in `cnt_Toast`:

```powerfx
// Visible (ersetze "0:0:5" mit neuer Dauer)
If(
    ThisItem.AutoClose && Now() - ThisItem.CreatedAt > TimeValue("0:0:3"),
    false,
    true
)

// Opacity (ersetze "0:0:4.7" = 3s - 0.3s Animation)
If(
    ThisItem.AutoClose && Now() - ThisItem.CreatedAt > TimeValue("0:0:2.7"),
    Max(0, 1 - ((Now() - ThisItem.CreatedAt - TimeValue("0:0:2.7")) / TimeValue("0:0:0.3"))),
    1
)
```

---

### Farben anpassen

In `src/App-Formulas-Template.fx`:

```powerfx
// GetToastBackground()
GetToastBackground(toastType: Text): Color =
    Switch(
        toastType,
        "Success", ColorValue("#E7F7E7"),    // Eigenes Hellgrün
        "Error", ColorValue("#FFE5E5"),       // Eigenes Hellrot
        "Warning", ColorValue("#FFF4E0"),     // Eigenes Hellgelb
        "Info", ColorValue("#E3F2FD"),        // Eigenes Hellblau
        ColorValue("#F5F5F5")                 // Default Grau
    );

// GetToastBorderColor()
GetToastBorderColor(toastType: Text): Color =
    Switch(
        toastType,
        "Success", ColorValue("#28A745"),    // Dunkelgrün
        "Error", ColorValue("#DC3545"),       // Dunkelrot
        "Warning", ColorValue("#FFC107"),     // Dunkelgelb
        "Info", ColorValue("#007BFF"),        // Dunkelblau
        ColorValue("#6C757D")                 // Default Grau
    );
```

---

## Nächste Schritte

Nach erfolgreicher Implementierung:

1. **Dokumentation lesen**:
   - `docs/notifications/TOAST-NOTIFICATION-GUIDE.md` - Vollständige API-Referenz
   - `docs/troubleshooting/TROUBLESHOOTING.md` - Erweiterte Fehlerbehebung

2. **Weitere Patterns implementieren**:
   - `src/Control-Patterns-Modern.fx` - Alle Control-Patterns mit Notifications

3. **Testing**:
   - Teste auf Desktop, Tablet, Mobile
   - Teste mit Screenreader (Accessibility)

4. **Production Deployment**:
   - Siehe `_archive/deployment/DEPLOYMENT-INSTRUCTIONS.md` für ALM-Workflow

---

## Support

Bei Fragen oder Problemen:

1. **Dokumentation prüfen**:
   - `CLAUDE.md` - Hauptdokumentation
   - `docs/troubleshooting/TROUBLESHOOTING.md` - Häufige Fehler

2. **GitHub Issues**:
   - Erstelle Issue mit:
     - Fehlerbeschreibung
     - Screenshots
     - Power Apps Version
     - Verwendete Formeln

3. **Community**:
   - Power Platform Community Forum
   - Stack Overflow (Tag: `powerapps`)

---

## Checkliste: Fertig?

Vor dem Abschluss prüfe:

- [ ] Alle 5 Controls erstellt (cnt_NotificationStack, cnt_Toast, lbl_ToastIcon, lbl_ToastMessage, btn_CloseToast)
- [ ] Hierarchie korrekt (cnt_Toast ist Child von cnt_NotificationStack)
- [ ] Alle Formeln aus Anleitung kopiert (Items, Fill, Visible, Opacity, OnSelect)
- [ ] Test-Button funktioniert (4 Toasts erscheinen)
- [ ] Auto-Dismiss funktioniert (Success/Warning/Info verschwinden nach 5s)
- [ ] Error-Toast bleibt (verschwindet nicht automatisch)
- [ ] Close-Button funktioniert (X entfernt Toast)
- [ ] Fade-out Animation sichtbar (letzte 0.3 Sekunden)
- [ ] Toasts blockieren nicht (App bleibt interaktiv)
- [ ] Integration in bestehende Buttons (Save/Delete/etc.)

**Herzlichen Glückwunsch! Dein Toast-System ist fertig.**

---

*Letzte Aktualisierung: 2025-01-22 | Version: 1.0 | Phase 4 Complete*
