# Button Design System - Quick Reference

**All button types from App-Formulas-Template.fx design system**

---

## 📊 Button Type Comparison

| Type | File | Color | Border | Use Case | Visual |
|------|------|-------|--------|----------|--------|
| **Primary** | `btn_Primary_Submit.yaml` | Primary Blue | No | Submit, Save, Create | 🟦 White text |
| **Secondary** | `btn_Secondary_Cancel.yaml` | Neutral Gray | No | Cancel, Back, Close | ⬜ White text |
| **Outline** | `btn_Outline_View.yaml` | White/Surface | Yes (2px) | View, Edit, Download | ⬜ Dark text + border |
| **Accent** | `btn_Accent_Highlight.yaml` | Secondary Cyan | No | Special highlights | 🟦 Dark text |
| **Danger** | `btn_Delete_Danger.yaml` | Error Red | No | Delete, Remove | 🟥 White text |

---

## 🎨 Color Matrix

### Fill Colors (Default State)

```powerfx
Primary Button:   ThemeColors.Primary (#0078D4)
Secondary Button: ThemeColors.NeutralGray (#8A8886)
Outline Button:   ThemeColors.Surface (White/Light)
Accent Button:    ThemeColors.Secondary (#50E6FF)
Danger Button:    ThemeColors.Error (#D13438)
```

### Interactive States (All Buttons)

```powerfx
Hover State:    GetHoverColor(baseColor)    // 20% darker
Pressed State:  GetPressedColor(baseColor)  // 30% darker
Disabled State: GetDisabledColor(baseColor) // 60% lighter
Focus Border:   GetFocusColor(baseColor)    // 10% darker, 3px thick
```

---

## 🎯 Usage Hierarchy

### Screen Layout Example

```
┌────────────────────────────────────────┐
│  Form Header                           │
├────────────────────────────────────────┤
│  [Fields...]                           │
│                                        │
│  ┌──────────────┐  ┌──────────────┐  │
│  │   Speichern  │  │  Abbrechen   │  │  ← Primary + Secondary
│  └──────────────┘  └──────────────┘  │
│                                        │
│  ┌──────────────┐                     │
│  │   Löschen    │                     │  ← Danger (separated)
│  └──────────────┘                     │
└────────────────────────────────────────┘
```

### Gallery Action Bar Example

```
┌────────────────────────────────────────┐
│  [Gallery Items...]                    │
│                                        │
│  Selected Item Actions:                │
│  ┌──────────┐ ┌──────────┐ ┌────────┐│
│  │ Details  │ │ Bearbeiten│ │Löschen ││  ← Outline + Outline + Danger
│  └──────────┘ └──────────┘ └────────┘│
└────────────────────────────────────────┘
```

---

## 📐 Standard Dimensions

### Button Sizes

```powerfx
// Small (mobile secondary actions)
Height: 32, Width: 80-120, Padding: Spacing.SM (8px)

// Medium (default - recommended)
Height: 44, Width: 120-180, Padding: Spacing.LG (24px)

// Large (hero CTAs)
Height: 56, Width: 180-240, Padding: Spacing.XL (32px)
```

### Spacing Between Buttons

```powerfx
// Horizontal spacing
Gap: Spacing.SM (8px) to Spacing.MD (16px)

// Vertical spacing (stacked)
Gap: Spacing.SM (8px)
```

---

## ⚡ Quick Copy Templates

### Copy All 5 Button Types

**File Structure:**
```
examples/
├── btn_Primary_Submit.yaml       ← Main CTA (blue)
├── btn_Secondary_Cancel.yaml     ← Cancel action (gray)
├── btn_Outline_View.yaml         ← View/Edit (white + border)
├── btn_Accent_Highlight.yaml     ← Special action (cyan)
├── btn_Delete_Danger.yaml        ← Delete (red)
├── BUTTON-INDEX.md               ← This file
└── BUTTON-TEMPLATES-README.md    ← Full documentation
```

### Minimal Button Formula (Copy-Paste)

#### Primary Button
```powerfx
Fill = ThemeColors.Primary
HoverFill = GetHoverColor(ThemeColors.Primary)
PressedFill = GetPressedColor(ThemeColors.Primary)
DisabledFill = GetDisabledColor(ThemeColors.Primary)
Color = Color.White
BorderColor = Color.Transparent
```

#### Secondary Button
```powerfx
Fill = ThemeColors.NeutralGray
HoverFill = GetHoverColor(ThemeColors.NeutralGray)
PressedFill = GetPressedColor(ThemeColors.NeutralGray)
DisabledFill = GetDisabledColor(ThemeColors.NeutralGray)
Color = Color.White
BorderColor = Color.Transparent
```

#### Outline Button
```powerfx
Fill = ThemeColors.Surface
HoverFill = GetHoverColor(ThemeColors.NeutralBase)
PressedFill = GetPressedColor(ThemeColors.NeutralBase)
Color = ThemeColors.Text
BorderColor = ThemeColors.Text
BorderThickness = 2
```

#### Danger Button
```powerfx
Fill = ThemeColors.Error
HoverFill = GetHoverColor(ThemeColors.Error)
PressedFill = GetPressedColor(ThemeColors.Error)
DisabledFill = GetDisabledColor(ThemeColors.Error)
Color = Color.White
BorderColor = Color.Transparent
```

---

## 🔐 Permission-Based Visibility Patterns

### Show/Hide Based on Permission

```powerfx
// Primary button (Create)
btn_Create.Visible = HasPermission("Create")

// Delete button (Delete)
btn_Delete.Visible = HasPermission("Delete")

// Edit button (Edit + ownership check)
btn_Edit.Visible = HasPermission("Edit") &&
                   CanAccessRecord(Gallery.Selected.Owner.Email)
```

### Enable/Disable Based on State

```powerfx
// Save button (enabled only when form valid)
btn_Save.DisplayMode = If(form.Valid, DisplayMode.Edit, DisplayMode.Disabled)

// Delete button (disabled when item archived)
btn_Delete.DisplayMode = If(
    Gallery.Selected.Status = "Archived",
    DisplayMode.Disabled,
    DisplayMode.Edit
)
```

---

## 🎨 Visual Preview (Text-Based)

```
┌──────────────┐  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐
│  Speichern   │  │  Abbrechen   │  │   Details    │  │  Hervorheben │  │   Löschen    │
│   (Primary)  │  │ (Secondary)  │  │  (Outline)   │  │   (Accent)   │  │   (Danger)   │
└──────────────┘  └──────────────┘  └──────────────┘  └──────────────┘  └──────────────┘
    #0078D4          #8A8886          White+Border       #50E6FF          #D13438
   White text       White text        Dark text         Dark text        White text

     Hover             Hover             Hover             Hover             Hover
┌──────────────┐  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐
│  Speichern   │  │  Abbrechen   │  │   Details    │  │  Hervorheben │  │   Löschen    │
└──────────────┘  └──────────────┘  └──────────────┘  └──────────────┘  └──────────────┘
  20% darker       20% darker        Gray tint        20% darker       20% darker
```

---

## ♿ Accessibility Checklist

All button templates include:

- ✅ **TabIndex** (keyboard navigation order)
- ✅ **AccessibleLabel** (screen reader description)
- ✅ **Tooltip** (mouse hover hint)
- ✅ **FocusedBorderThickness: 3px** (visible focus indicator)
- ✅ **FocusedBorderColor** (contrasting focus color)
- ✅ **Minimum height: 44px** (touch-friendly target)
- ✅ **Color contrast** (WCAG AA compliant)

---

## 🔄 State Transitions

### Button State Flow

```
Default → Hover → Pressed → Default
   ↓
Disabled (grayed out, non-interactive)
   ↓
Focused (keyboard navigation, 3px border)
```

### Color Intensity Changes

```
Default:  100% color saturation
Hover:    120% (20% darker via ColorFade)
Pressed:  130% (30% darker via ColorFade)
Disabled: 40% (60% lighter via ColorFade)
Focus:    110% (10% darker border)
```

---

## 📚 Complete Documentation

- **Full Guide:** `BUTTON-TEMPLATES-README.md` (detailed usage + customization)
- **Design System:** `docs/plans/2026-02-05-design-system-refactor-design.md`
- **Control Patterns:** `src/Control-Patterns-Modern.fx` (Section 3.4, Lines 540-652)
- **App Formulas:** `src/App-Formulas-Template.fx` (ThemeColors, UDFs)

---

**Last Updated:** 2026-02-14
**Version:** Phase 4 Complete (Production-Ready)
**Compatibility:** Power Apps Canvas Apps 2025+
