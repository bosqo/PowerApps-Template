# Design Variables Review: Komponenten-Tauglichkeit

**Datum:** 13.02.2026
**Status:** Analyse & Empfehlung
**Scope:** ThemeColors, Typography, Spacing, BorderRadius, ColorIntensity, State-UDFs

---

## 1. Ist-Zustand: Aktuelle Design-Variablen

### 1.1 Struktur-Übersicht

| Variable | Typ | Zeilen | Felder | Zweck |
|----------|-----|--------|--------|-------|
| `ThemeColors` | Named Formula (Record) | 52-94 | 17 Farben | Master-Farbsystem |
| `ColorIntensity` | Named Formula (Record) | 99-104 | 4 Werte | Hover/Pressed/Disabled/Focus |
| `Typography` | Named Formula (Record) | 107-124 | 11 Werte | Schrift & Zeilenhöhe |
| `Spacing` | Named Formula (Record) | 127-134 | 6 Werte | Abstände |
| `BorderRadius` | Named Formula (Record) | 137-144 | 6 Werte | Eckenrundung |

### 1.2 Problem: Named Formulas sind in Komponenten NICHT verfügbar

**Kernproblem:** Power Apps Canvas Components haben keinen Zugriff auf Named Formulas der Host-App. `ThemeColors`, `Typography`, `Spacing` etc. existieren nur im Scope von `App.Formulas` -- Komponenten sehen sie nicht.

Das bedeutet:
- Eine Komponente kann `ThemeColors.Primary` nicht referenzieren
- UDFs wie `GetHoverColor()` sind in Komponenten nicht aufrufbar
- Jede Styling-Information muss explizit als **Custom Input Property** übergeben werden

### 1.3 Problem: Einzelne Record-Properties sind nicht als ein Property übergebbar

Power Apps Component Input Properties unterstützen folgende Typen:
- Text, Number, Boolean, Color, Date, DateTime, Screen, Table, Record
- **Record-Typ erfordert Schema-Definition** mit festen Feldern
- Man kann KEIN generisches `Record` ohne Schema übergeben

Das heißt: `ThemeColors` als ganzes Record an eine Komponente zu übergeben erfordert, dass die Komponente das exakte Schema (17 Felder) als Input Property definiert.

---

## 2. Analyse: Was muss sich ändern?

### 2.1 Strategie-Optionen

#### Option A: Flache Color-Properties (Einfach, aber verbos)
```
// Jede Farbe als einzelne Input Property
cmp_Button.PrimaryColor = ThemeColors.Primary
cmp_Button.HoverColor = GetHoverColor(ThemeColors.Primary)
cmp_Button.TextColor = Color.White
```
**Pro:** Maximale Flexibilität, kein Schema nötig
**Contra:** 5-10 Properties pro Komponente nur für Farben

#### Option B: Theme-Record als einzelne Input Property (Empfohlen)
```
// Ein Record mit allen benötigten Werten
cmp_Button.Theme = {
    Fill: ThemeColors.Primary,
    HoverFill: GetHoverColor(ThemeColors.Primary),
    PressedFill: GetPressedColor(ThemeColors.Primary),
    DisabledFill: GetDisabledColor(ThemeColors.Primary),
    TextColor: Color.White,
    BorderColor: Color.Transparent,
    BorderRadius: BorderRadius.MD,
    FontSize: Typography.SizeMD,
    PaddingH: Spacing.MD,
    PaddingV: Spacing.SM
}
```
**Pro:** Ein Property für alles Visuelle, saubere Trennung
**Contra:** Record-Schema muss in Komponente definiert werden

#### Option C: Vordefinierte Button-Style Records (Bester Kompromiss)
```powerfx
// In App.Formulas: Fertige Style-Records definieren
ButtonStylePrimary = {
    Fill: ThemeColors.Primary,
    HoverFill: GetHoverColor(ThemeColors.Primary),
    PressedFill: GetPressedColor(ThemeColors.Primary),
    DisabledFill: GetDisabledColor(ThemeColors.Primary),
    TextColor: Color.White,
    DisabledTextColor: Color.White,
    BorderColor: Color.Transparent,
    BorderRadius: BorderRadius.MD,
    FontSize: Typography.SizeMD,
    Height: 40,
    PaddingH: Spacing.MD
};

// Verwendung: Eine Zeile pro Instanz
cmp_Button.Style = ButtonStylePrimary
```
**Pro:** Wiederverwendbar, DRY, eine Zeile pro Instanz
**Contra:** Initiale Definition nötig

### 2.2 Empfehlung: Option C (Vordefinierte Style-Records)

Gründe:
1. **Konsistenz:** Alle Buttons eines Typs sehen identisch aus
2. **Wartbarkeit:** Änderung an einer Stelle wirkt überall
3. **Einfache Nutzung:** `cmp_Button.Style = ButtonStylePrimary` -- fertig
4. **Erweiterbar:** Neue Stile durch neue Records, kein Code-Umbau

---

## 3. Benötigte Änderungen an App-Formulas-Template.fx

### 3.1 Neue Named Formulas: Button Styles

```powerfx
// =========================================
// BUTTON STYLE RECORDS (für Komponenten)
// =========================================

ButtonStylePrimary = {
    Fill: ThemeColors.Primary,
    HoverFill: ColorFade(ThemeColors.Primary, ColorIntensity.Hover),
    PressedFill: ColorFade(ThemeColors.Primary, ColorIntensity.Pressed),
    DisabledFill: ColorFade(ThemeColors.Primary, ColorIntensity.Disabled),
    TextColor: Color.White,
    DisabledTextColor: Color.White,
    BorderColor: Color.Transparent,
    BorderWidth: 0,
    BorderRadius: BorderRadius.MD,
    FontSize: Typography.SizeMD,
    Font: Typography.Font,
    MinHeight: 36,
    PaddingX: Spacing.MD,
    PaddingY: Spacing.SM
};

ButtonStyleSecondary = {
    Fill: ThemeColors.NeutralGray,
    HoverFill: ColorFade(ThemeColors.NeutralGray, ColorIntensity.Hover),
    PressedFill: ColorFade(ThemeColors.NeutralGray, ColorIntensity.Pressed),
    DisabledFill: ColorFade(ThemeColors.NeutralGray, ColorIntensity.Disabled),
    TextColor: Color.White,
    DisabledTextColor: Color.White,
    BorderColor: Color.Transparent,
    BorderWidth: 0,
    BorderRadius: BorderRadius.MD,
    FontSize: Typography.SizeMD,
    Font: Typography.Font,
    MinHeight: 36,
    PaddingX: Spacing.MD,
    PaddingY: Spacing.SM
};

ButtonStyleOutline = {
    Fill: ThemeColors.Surface,
    HoverFill: ColorFade(ThemeColors.NeutralBase, ColorIntensity.Hover),
    PressedFill: ColorFade(ThemeColors.NeutralBase, ColorIntensity.Pressed),
    DisabledFill: ThemeColors.Surface,
    TextColor: ThemeColors.Text,
    DisabledTextColor: ThemeColors.TextDisabled,
    BorderColor: ThemeColors.Text,
    BorderWidth: 1,
    BorderRadius: BorderRadius.MD,
    FontSize: Typography.SizeMD,
    Font: Typography.Font,
    MinHeight: 36,
    PaddingX: Spacing.MD,
    PaddingY: Spacing.SM
};

ButtonStyleDanger = {
    Fill: ThemeColors.Error,
    HoverFill: ColorFade(ThemeColors.Error, ColorIntensity.Hover),
    PressedFill: ColorFade(ThemeColors.Error, ColorIntensity.Pressed),
    DisabledFill: ColorFade(ThemeColors.Error, ColorIntensity.Disabled),
    TextColor: Color.White,
    DisabledTextColor: Color.White,
    BorderColor: Color.Transparent,
    BorderWidth: 0,
    BorderRadius: BorderRadius.MD,
    FontSize: Typography.SizeMD,
    Font: Typography.Font,
    MinHeight: 36,
    PaddingX: Spacing.MD,
    PaddingY: Spacing.SM
};
```

### 3.2 Neue Named Formulas: Input/TextInput Styles

```powerfx
InputStyleDefault = {
    Fill: Color.White,
    FocusFill: Color.White,
    DisabledFill: ThemeColors.NeutralBase,
    TextColor: ThemeColors.Text,
    PlaceholderColor: ThemeColors.TextSecondary,
    DisabledTextColor: ThemeColors.TextDisabled,
    BorderColor: ThemeColors.BorderStrong,
    FocusBorderColor: ThemeColors.Primary,
    ErrorBorderColor: ThemeColors.Error,
    BorderWidth: 1,
    FocusBorderWidth: 2,
    BorderRadius: BorderRadius.MD,
    FontSize: Typography.SizeMD,
    Font: Typography.Font,
    Height: 36,
    PaddingX: Spacing.SM,
    PaddingY: Spacing.XS,
    LabelColor: ThemeColors.Text,
    LabelFontSize: Typography.SizeSM,
    ErrorColor: ThemeColors.Error,
    ErrorFontSize: Typography.SizeSM
};
```

### 3.3 Neue Named Formulas: Card/Container Styles

```powerfx
CardStyleDefault = {
    Fill: ThemeColors.Surface,
    HoverFill: ThemeColors.SurfaceHover,
    BorderColor: ThemeColors.Border,
    BorderWidth: 1,
    BorderRadius: BorderRadius.LG,
    ShadowColor: ThemeColors.Shadow,
    PaddingX: Spacing.MD,
    PaddingY: Spacing.MD,
    Gap: Spacing.SM,
    HeaderFontSize: Typography.SizeLG,
    HeaderColor: ThemeColors.Text,
    BodyFontSize: Typography.SizeMD,
    BodyColor: ThemeColors.Text
};

CardStyleElevated = {
    Fill: ThemeColors.Surface,
    HoverFill: ThemeColors.SurfaceHover,
    BorderColor: Color.Transparent,
    BorderWidth: 0,
    BorderRadius: BorderRadius.LG,
    ShadowColor: ThemeColors.Shadow,
    PaddingX: Spacing.LG,
    PaddingY: Spacing.LG,
    Gap: Spacing.MD,
    HeaderFontSize: Typography.SizeLG,
    HeaderColor: ThemeColors.Text,
    BodyFontSize: Typography.SizeMD,
    BodyColor: ThemeColors.Text
};
```

### 3.4 Neue Named Formulas: Badge/Status Styles

```powerfx
BadgeStyleDefault = {
    FontSize: Typography.SizeXS,
    Font: Typography.Font,
    PaddingX: Spacing.SM,
    PaddingY: Spacing.XS,
    BorderRadius: BorderRadius.Round,
    Height: 24,
    TextColor: Color.White
};
```

---

## 4. Input & Output Properties pro Komponenten-Typ

### 4.1 cmp_Button (Fluent Button Komponente)

#### Input Properties

| Property | Typ | Default | Beschreibung |
|----------|-----|---------|-------------|
| `Text` | Text | "" | Button-Label |
| `Style` | Record | `ButtonStylePrimary` | Komplettes Styling (siehe Schema unten) |
| `Icon` | Text | "" | Icon-Name (optional) |
| `IsDisabled` | Boolean | false | Deaktiviert-Zustand |
| `Width` | Number | 0 (auto) | Breite (0 = auto) |
| `Tooltip` | Text | "" | Tooltip-Text |

#### Style-Record Schema (Input)
```
{
    Fill: Color,
    HoverFill: Color,
    PressedFill: Color,
    DisabledFill: Color,
    TextColor: Color,
    DisabledTextColor: Color,
    BorderColor: Color,
    BorderWidth: Number,
    BorderRadius: Number,
    FontSize: Number,
    Font: Font,
    MinHeight: Number,
    PaddingX: Number,
    PaddingY: Number
}
```

#### Output Properties

| Property | Typ | Beschreibung |
|----------|-----|-------------|
| `IsPressed` | Boolean | Button wurde geklickt |
| `IsHovered` | Boolean | Maus über Button |

#### Interne Formeln der Komponente
```powerfx
// btn_Internal.Fill
If(
    Self.IsDisabled, Style.DisabledFill,
    Self.Pressed, Style.PressedFill,
    Self.HoverFill, Style.HoverFill,
    Style.Fill
)

// btn_Internal.Color
If(Self.IsDisabled, Style.DisabledTextColor, Style.TextColor)

// btn_Internal.BorderColor
If(Self.IsDisabled, Style.DisabledFill, Style.BorderColor)

// btn_Internal.RadiusTopLeft (etc.)
Style.BorderRadius

// btn_Internal.Size
Style.FontSize

// btn_Internal.Font
Style.Font
```

#### Verwendung in der App
```powerfx
// Primary Button
cmp_Button_1.Text = "Speichern"
cmp_Button_1.Style = ButtonStylePrimary
cmp_Button_1.OnSelect = SubmitForm(form_Edit)

// Danger Button
cmp_Button_2.Text = "Löschen"
cmp_Button_2.Style = ButtonStyleDanger
cmp_Button_2.OnSelect = Remove(Items, ThisItem)

// Outline Button (Custom Override)
cmp_Button_3.Text = "Exportieren"
cmp_Button_3.Style = Patch(ButtonStyleOutline, {FontSize: Typography.SizeLG})
```

---

### 4.2 cmp_TextInput (Fluent TextInput Komponente)

#### Input Properties

| Property | Typ | Default | Beschreibung |
|----------|-----|---------|-------------|
| `Label` | Text | "" | Feld-Bezeichnung über dem Input |
| `Value` | Text | "" | Aktueller Wert (Two-Way) |
| `Placeholder` | Text | "" | Platzhalter-Text |
| `Style` | Record | `InputStyleDefault` | Styling |
| `IsRequired` | Boolean | false | Pflichtfeld |
| `IsDisabled` | Boolean | false | Deaktiviert |
| `ErrorMessage` | Text | "" | Fehlermeldung (zeigt Error-State) |
| `MaxLength` | Number | 0 | Max. Zeichenlänge (0 = unbegrenzt) |
| `Mode` | Text | "text" | "text", "email", "number", "multiline" |

#### Output Properties

| Property | Typ | Beschreibung |
|----------|-----|-------------|
| `Value` | Text | Aktueller Text-Wert |
| `IsFocused` | Boolean | Hat Fokus |
| `IsValid` | Boolean | Validierung bestanden |
| `HasChanged` | Boolean | Wert wurde geändert |

#### Interne Formeln
```powerfx
// txt_Internal.BorderColor
If(
    !IsBlank(ErrorMessage), Style.ErrorBorderColor,
    Self.Focused, Style.FocusBorderColor,
    Style.BorderColor
)

// txt_Internal.BorderThickness
If(Self.Focused, Style.FocusBorderWidth, Style.BorderWidth)

// lbl_Label.Color
If(!IsBlank(ErrorMessage), Style.ErrorColor, Style.LabelColor)

// lbl_Error.Visible
!IsBlank(ErrorMessage)

// lbl_Error.Text
ErrorMessage
```

---

### 4.3 cmp_Card (Container/Karten-Komponente)

#### Input Properties

| Property | Typ | Default | Beschreibung |
|----------|-----|---------|-------------|
| `Title` | Text | "" | Karten-Titel |
| `Subtitle` | Text | "" | Untertitel |
| `Style` | Record | `CardStyleDefault` | Styling |
| `IsClickable` | Boolean | false | Klickbar (zeigt Hover) |
| `ShowDivider` | Boolean | false | Trennlinie unter Header |
| `ContentHeight` | Number | 200 | Höhe des Content-Bereichs |

#### Output Properties

| Property | Typ | Beschreibung |
|----------|-----|-------------|
| `IsClicked` | Boolean | Karte wurde geklickt |
| `ContentWidth` | Number | Verfügbare Content-Breite |

---

### 4.4 cmp_Badge (Status-Badge Komponente)

#### Input Properties

| Property | Typ | Default | Beschreibung |
|----------|-----|---------|-------------|
| `Text` | Text | "" | Badge-Text |
| `Color` | Color | ThemeColors.Primary | Hintergrundfarbe |
| `Style` | Record | `BadgeStyleDefault` | Layout-Styling |
| `Variant` | Text | "filled" | "filled", "outline", "subtle" |

#### Output Properties

| Property | Typ | Beschreibung |
|----------|-----|-------------|
| `Width` | Number | Berechnete Breite |

#### Verwendung
```powerfx
// Status-Badge mit dynamischer Farbe
cmp_Badge_1.Text = ThisItem.Status
cmp_Badge_1.Color = GetStatusColor(ThisItem.Status)

// Rollen-Badge
cmp_Badge_2.Text = GetRoleBadge()
cmp_Badge_2.Color = GetRoleBadgeColor()
```

---

### 4.5 cmp_Dropdown (Styled Dropdown)

#### Input Properties

| Property | Typ | Default | Beschreibung |
|----------|-----|---------|-------------|
| `Label` | Text | "" | Feld-Bezeichnung |
| `Items` | Table | [] | Dropdown-Einträge |
| `ValueField` | Text | "Value" | Wert-Spalte |
| `DisplayField` | Text | "Value" | Anzeige-Spalte |
| `DefaultValue` | Text | "" | Vorausgewählter Wert |
| `Style` | Record | `InputStyleDefault` | Styling (gleich wie TextInput) |
| `IsRequired` | Boolean | false | Pflichtfeld |
| `IsDisabled` | Boolean | false | Deaktiviert |
| `Placeholder` | Text | "Auswählen..." | Platzhalter |

#### Output Properties

| Property | Typ | Beschreibung |
|----------|-----|-------------|
| `SelectedValue` | Text | Gewählter Wert |
| `SelectedItem` | Record | Ganzer Datensatz |
| `HasSelection` | Boolean | Auswahl getroffen |

---

### 4.6 cmp_GalleryRow (Gallery-Zeile Komponente)

#### Input Properties

| Property | Typ | Default | Beschreibung |
|----------|-----|---------|-------------|
| `IsSelected` | Boolean | false | Zeile ausgewählt |
| `IsAlternate` | Boolean | false | Alternierende Zeile |
| `Style` | Record | (siehe unten) | Styling |

#### Row Style Record
```powerfx
GalleryRowStyleDefault = {
    Fill: Color.Transparent,
    SelectedFill: ColorFade(ThemeColors.Primary, 0.85),
    AlternateFill: ColorFade(ThemeColors.NeutralBase, 0.50),
    HoverFill: ThemeColors.SurfaceHover,
    TextColor: ThemeColors.Text,
    SecondaryTextColor: ThemeColors.TextSecondary,
    DividerColor: ThemeColors.Divider,
    Height: 48,
    PaddingX: Spacing.MD,
    FontSize: Typography.SizeMD,
    SecondaryFontSize: Typography.SizeSM
};
```

---

## 5. Best Practice: Styling übergeben

### 5.1 Ein Style-Record pro Komponente (Empfohlen)

```
┌─────────────────────────────────────────────────┐
│ App.Formulas                                     │
│                                                  │
│  ThemeColors ──┐                                 │
│  Typography ───┤                                 │
│  Spacing ──────┼──► ButtonStylePrimary (Record)  │
│  BorderRadius ─┤    ButtonStyleSecondary         │
│  ColorIntensity┘    ButtonStyleOutline            │
│                     ButtonStyleDanger             │
│                     InputStyleDefault             │
│                     CardStyleDefault              │
│                     ...                           │
│                                                  │
│  ┌──────────────────────────────────────┐        │
│  │ Screen                               │        │
│  │                                      │        │
│  │  cmp_Button.Style = ButtonStylePrimary│       │
│  │  cmp_Input.Style = InputStyleDefault  │       │
│  │  cmp_Card.Style = CardStyleDefault    │       │
│  │                                      │        │
│  └──────────────────────────────────────┘        │
└─────────────────────────────────────────────────┘
```

### 5.2 Override-Pattern mit Patch()

Wenn ein Button 90% wie Primary aussehen soll, aber grösser:
```powerfx
cmp_Button.Style = Patch(ButtonStylePrimary, {
    FontSize: Typography.SizeLG,
    MinHeight: 48
})
```

Wenn ein Input einen Error-State hat:
```powerfx
cmp_TextInput.Style = InputStyleDefault  // Style bleibt gleich
cmp_TextInput.ErrorMessage = "Ungültige E-Mail"  // Error über separate Property
```

### 5.3 Anti-Patterns (vermeiden)

```powerfx
// ❌ SCHLECHT: Zu viele einzelne Properties
cmp_Button.Fill = ThemeColors.Primary
cmp_Button.HoverFill = GetHoverColor(ThemeColors.Primary)
cmp_Button.PressedFill = GetPressedColor(ThemeColors.Primary)
cmp_Button.TextColor = Color.White
cmp_Button.FontSize = 14
cmp_Button.BorderRadius = 4
// → 6+ Zeilen pro Button-Instanz

// ❌ SCHLECHT: Gesamtes ThemeColors übergeben
cmp_Button.Theme = ThemeColors
// → Komponente muss alles kennen, keine Separation of Concerns

// ❌ SCHLECHT: Inline-Berechnung bei jeder Instanz
cmp_Button.HoverFill = ColorFade(ThemeColors.Primary, -0.20)
// → Magic Numbers, nicht wartbar, dupliziert

// ✅ GUT: Vordefinierter Style
cmp_Button.Style = ButtonStylePrimary
// → 1 Zeile, konsistent, wartbar
```

---

## 6. Zusammenfassung der Änderungen

### 6.1 Neue Named Formulas in App-Formulas-Template.fx

| Named Formula | Felder | Für Komponente |
|---------------|--------|---------------|
| `ButtonStylePrimary` | 14 | cmp_Button |
| `ButtonStyleSecondary` | 14 | cmp_Button |
| `ButtonStyleOutline` | 14 | cmp_Button |
| `ButtonStyleDanger` | 14 | cmp_Button |
| `InputStyleDefault` | 22 | cmp_TextInput, cmp_Dropdown |
| `CardStyleDefault` | 13 | cmp_Card |
| `CardStyleElevated` | 13 | cmp_Card |
| `BadgeStyleDefault` | 7 | cmp_Badge |
| `GalleryRowStyleDefault` | 11 | cmp_GalleryRow |

### 6.2 Bestehende Variablen: Keine Änderung nötig

`ThemeColors`, `ColorIntensity`, `Typography`, `Spacing`, `BorderRadius` bleiben unverändert. Sie dienen als **Quelle** für die Style-Records.

### 6.3 Bestehende UDFs: Werden intern verwendet

`GetHoverColor()`, `GetPressedColor()` etc. werden weiterhin in den Style-Record-Definitionen verwendet, aber nicht mehr direkt an Komponenten übergeben.

### 6.4 Control-Patterns-Modern.fx: Ergänzen

Die bestehenden Button-Pattern-Kommentare (Pattern 3.4, Zeilen 536-652) werden um Komponenten-Beispiele ergänzt.

---

## 7. Migrations-Strategie

### Phase 1: Style-Records definieren
- Neue Named Formulas in `App-Formulas-Template.fx` hinzufügen
- Basierend auf bestehenden ThemeColors + UDFs

### Phase 2: Komponenten erstellen
- Component Library mit cmp_Button, cmp_TextInput, cmp_Badge
- Input Property `Style` mit Record-Schema
- Interne Logik referenziert `Style.*`

### Phase 3: Bestehende Controls migrieren
- Schritt für Schritt Controls durch Komponenten ersetzen
- `ButtonStylePrimary` statt Copy-Paste der 8 Properties

### Phase 4: Control-Patterns-Modern.fx aktualisieren
- Komponenten-Verwendung dokumentieren
- Alte Pattern-Kommentare als Legacy markieren
