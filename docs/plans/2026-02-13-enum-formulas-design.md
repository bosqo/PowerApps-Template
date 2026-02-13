# Enum Formulas Component Design

**Date:** 2026-02-13
**Status:** Implemented
**Approach:** Separate source file with Named Formula table literals

---

## Overview

Centralizes all enumeration data into a dedicated file (`src/Enum-Formulas.fx`) to keep the main `App-Formulas-Template.fx` focused on business logic and UDFs. The enumerations are implemented as **Named Formulas** (declarative, lazy-evaluated) — not `ClearCollect` — consistent with the project's architecture.

### Problem

Three useful enumeration datasets (140 web colors, 31 error kinds, 178 icons) would add ~3,400 lines to `App-Formulas-Template.fx`, making it difficult to navigate and maintain.

### Solution

Separate file in source control. In Power Apps, all content is pasted into `App.Formulas` together, but in the repository they remain distinct files for readability.

---

## Architecture

```
src/
├── App-Formulas-Template.fx    (1,630 lines) - Business logic, UDFs, theme
├── App-OnStart-Minimal.fx      (565 lines)   - State initialization
├── Control-Patterns-Modern.fx  (1,637 lines) - UI control formulas
└── Enum-Formulas.fx            (3,503 lines) - Enumeration lookup tables  ← NEW
```

### Named Formulas (3 enumerations)

| Formula | Records | Purpose |
|---------|---------|---------|
| `fxWebColors` | 140 | All standard web colors with RGB, hex, categories, tags |
| `fxErrorKinds` | 31 | Power Apps ErrorKind enum as searchable table |
| `fxIcons` | 178 | All canvas app icons with descriptions, tags, categories |

### Naming Convention

All enumerations use the `fx` prefix (from the source snippets), which distinguishes them from business Named Formulas (`ThemeColors`, `UserProfile`, etc.).

---

## Enumerations Detail

### fxWebColors (140 records)

**Fields:** ID, Name, HexCode, Value, Red, Green, Blue, Category, Tags, ComplementaryHex, AccentHex, Alpha

**Categories:** Whites, Beiges, Reds, Pinks, Oranges, Yellows, Greens, Blues, Cyan/Aqua, Purples, Browns, Grays

```powerfx
// Get a color value by name
LookUp(fxWebColors, Name = "CornflowerBlue").Value

// Filter by category
Filter(fxWebColors, Category = "Blues")

// Get hex code
LookUp(fxWebColors, Name = "Tomato").HexCode

// Find warm colors
Filter(fxWebColors, "warm" in Tags)
```

### fxErrorKinds (31 records)

**Fields:** KindNumber, KindName, Category

**Categories:** General, Data, Calculation, System

Converted from the original `ClearCollect` pattern to a Named Formula table literal. The `KindNumber` values are sequential (0-30) for unique identification — the original source had duplicate `KindNumber` values.

```powerfx
// Look up an error kind
LookUp(fxErrorKinds, KindName = "Timeout")

// Filter by category
Filter(fxErrorKinds, Category = "Data")

// Use in error handling
IfError(
    SomeOperation(),
    With(
        {errInfo: LookUp(fxErrorKinds, KindName = Text(FirstError.Kind))},
        NotifyError("Error: " & errInfo.KindName & " (" & errInfo.Category & ")")
    )
)
```

### fxIcons (178 records)

**Fields:** Sequence, Name, Icon, Description, Tags, Category

**Categories:** Actions, Navigation, Media, Communication, Files, Notifications, Shopping, Design, Technology, Social, etc.

Pre-sorted by `Sequence` using `Sort(..., SortOrder.Ascending)`.

```powerfx
// Get an icon by name
LookUp(fxIcons, Name = "Home").Icon

// Filter by category
Filter(fxIcons, Category = "Navigation")

// Search icons by text
Search(fxIcons, "edit", "Name", "Description")

// Use in a gallery for icon picker
glr_IconPicker.Items = Filter(fxIcons, Category = drp_IconCategory.Selected.Value)
```

---

## Integration with App.Formulas

In Power Apps Studio, paste the content of `Enum-Formulas.fx` into `App.Formulas` alongside the content of `App-Formulas-Template.fx`. Order does not matter — Named Formulas are lazy-evaluated and have no ordering dependency.

```
App.Formulas = [
    // Content from App-Formulas-Template.fx (business logic, UDFs)
    // + Content from Enum-Formulas.fx (enumeration tables)
]
```

### UDF Examples Using Enumerations

```powerfx
// Color picker UDF
GetWebColor(name: Text): Color =
    LookUp(fxWebColors, Name = name).Value;

// Error category lookup
GetErrorCategory(kindName: Text): Text =
    LookUp(fxErrorKinds, KindName = kindName).Category;

// Icon search helper
GetIconByName(name: Text): Record =
    LookUp(fxIcons, Name = name);
```

These UDFs would go in `App-Formulas-Template.fx` if needed, keeping the separation clean.

---

## Performance Considerations

- **Lazy evaluation:** Named Formula tables are only loaded when first accessed, not at app startup
- **No impact on OnStart:** These formulas add zero milliseconds to `App.OnStart`
- **Memory:** Tables are in-memory but only materialized when referenced
- **Delegation:** `LookUp()` and `Filter()` on local Named Formula tables are always local (no delegation concern since data is already client-side)

---

## Sources

Based on [PowerAppsDarren/PowerFxSnippets](https://github.com/PowerAppsDarren/PowerFxSnippets) (MIT License):
- `color-enum-in-named-formula.md` — 140 web colors
- `error-kinds.md` — Error kinds (converted from `ClearCollect` to Named Formula)
- `icons-as-collection.md` — 178 icons with metadata
