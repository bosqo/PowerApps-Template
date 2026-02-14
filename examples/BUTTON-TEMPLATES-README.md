# Button Templates - YAML Format

**Power Apps Canvas App Button Components** using the design system from `App-Formulas-Template.fx`

---

## 📁 Available Templates

| File | Type | Use Case | Base Color |
|------|------|----------|------------|
| `btn_Primary_Submit.yaml` | **Primary** | Submit, Save, Create (Main CTA) | `ThemeColors.Primary` |
| `btn_Secondary_Cancel.yaml` | **Secondary** | Cancel, Back, Close | `ThemeColors.NeutralGray` |
| `btn_Outline_View.yaml` | **Outline** | View, Edit, Download | White + Border |
| `btn_Accent_Highlight.yaml` | **Accent** | Special highlights (rare) | `ThemeColors.Secondary` |

---

## 🎨 Design System Variables Used

All buttons use variables from `App-Formulas-Template.fx`:

### Colors
- **ThemeColors.Primary** - Main brand color (#0078D4)
- **ThemeColors.Secondary** - Accent color (#50E6FF)
- **ThemeColors.NeutralGray** - Gray (#8A8886)
- **ThemeColors.Surface** - White/light background
- **ThemeColors.Text** - Primary text color

### State Functions (Auto-derived)
- **GetHoverColor(baseColor)** - 20% darker for hover state
- **GetPressedColor(baseColor)** - 30% darker for pressed state
- **GetDisabledColor(baseColor)** - 60% lighter for disabled state
- **GetFocusColor(baseColor)** - 10% darker for focus border

### Spacing & Typography
- **Spacing.SM** = 8px (padding)
- **Spacing.MD** = 16px (padding)
- **Spacing.LG** = 24px (padding, margins)
- **Typography.Font** = Segoe UI
- **Typography.SizeMD** = 14px
- **BorderRadius.MD** = 4px (rounded corners)

---

## 🚀 How to Use These Templates

### Option 1: Copy Properties to Power Apps Studio

1. Open your Canvas App in Power Apps Studio
2. Add a new **Button** control
3. Copy the property values from the YAML file
4. Paste into the corresponding properties in the formula bar

**Example:**
```yaml
# From YAML file:
Fill: =ThemeColors.Primary

# In Power Apps Studio:
# Select button → Fill property → Paste: ThemeColors.Primary
```

### Option 2: Import via PAC CLI (Advanced)

If you're using the Power Apps CLI to pack/unpack apps:

1. Add the button YAML to your unpacked app's `Src/` folder
2. Run `pac canvas pack --sources ./src --msapp YourApp.msapp`
3. Import the `.msapp` file into Power Apps

---

## 📋 Quick Copy-Paste Formulas

### Primary Button (Submit/Save)

```powerfx
// Fill Colors
Fill = ThemeColors.Primary
HoverFill = GetHoverColor(ThemeColors.Primary)
PressedFill = GetPressedColor(ThemeColors.Primary)
DisabledFill = GetDisabledColor(ThemeColors.Primary)

// Text Colors
Color = Color.White
DisabledColor = Color.White

// Border
BorderColor = Color.Transparent
FocusedBorderColor = GetFocusColor(ThemeColors.Primary)
FocusedBorderThickness = 3

// Sizing
Height = 44
RadiusTopLeft = BorderRadius.MD
RadiusTopRight = BorderRadius.MD
RadiusBottomLeft = BorderRadius.MD
RadiusBottomRight = BorderRadius.MD
```

### Secondary Button (Cancel/Back)

```powerfx
// Fill Colors
Fill = ThemeColors.NeutralGray
HoverFill = GetHoverColor(ThemeColors.NeutralGray)
PressedFill = GetPressedColor(ThemeColors.NeutralGray)
DisabledFill = GetDisabledColor(ThemeColors.NeutralGray)

// Text Colors (same as primary)
Color = Color.White
```

### Outline Button (View/Edit)

```powerfx
// Fill Colors (white/light background)
Fill = ThemeColors.Surface
HoverFill = GetHoverColor(ThemeColors.NeutralBase)
PressedFill = GetPressedColor(ThemeColors.NeutralBase)
DisabledFill = ThemeColors.Surface

// Text Colors (dark text on light background)
Color = ThemeColors.Text
DisabledColor = ThemeColors.TextDisabled

// Border (visible border for outline style)
BorderColor = ThemeColors.Text
BorderThickness = 2
BorderStyle = BorderStyle.Solid
HoverBorderColor = GetHoverColor(ThemeColors.Text)
DisabledBorderColor = GetDisabledColor(ThemeColors.Text)
```

### Accent Button (Special Actions)

```powerfx
// Fill Colors
Fill = ThemeColors.Secondary
HoverFill = GetHoverColor(ThemeColors.Secondary)
PressedFill = GetPressedColor(ThemeColors.Secondary)
DisabledFill = GetDisabledColor(ThemeColors.Secondary)

// Text Colors (dark text on light accent)
Color = ThemeColors.Text
DisabledColor = ThemeColors.TextDisabled

// Font Weight (bold for emphasis)
FontWeight = FontWeight.Bold
```

---

## 🎯 Common OnSelect Patterns

### Save Button with Permission Check

```powerfx
If(
    HasPermission("Create"),
    // Success path
    SubmitForm(form_Details);
    NotifySuccess("Eintrag erfolgreich gespeichert"),
    // Permission denied
    NotifyPermissionDenied("create records")
)
```

### Cancel Button (Reset & Navigate Back)

```powerfx
ResetForm(form_Details);
Set(UIState, Patch(UIState, {FormMode: FormMode.View, UnsavedChanges: false}));
Back()
```

### View Details Button with Access Check

```powerfx
If(
    HasPermission("Read") && CanAccessRecord(Gallery.Selected.Owner.Email),
    // Navigate to details
    Set(UIState, Patch(UIState, {SelectedItem: Gallery.Selected}));
    Navigate(DetailsScreen, ScreenTransition.Fade),
    // Permission denied
    NotifyPermissionDenied("view this record")
)
```

---

## ♿ Accessibility Properties

All button templates include:

```powerfx
// Keyboard Navigation
TabIndex = 0  // (or 1, 2, 3 for sequence)

// Screen Reader Labels
AccessibleLabel = "Button name - Description of action"
Tooltip = "Short description"

// Focus Indicator
FocusedBorderThickness = 3
FocusedBorderColor = GetFocusColor(baseColor)
```

**Example:**
```powerfx
btn_Submit.AccessibleLabel = "Speichern Button - Erstellt neuen Eintrag"
btn_Submit.Tooltip = "Neuen Eintrag speichern"
btn_Submit.TabIndex = 0
```

---

## 🔄 Conditional Display Modes

### Based on Permissions

```powerfx
// Show button only if user has permission
btn_Delete.Visible = HasPermission("Delete")

// Enable button only if user can edit
btn_Edit.DisplayMode = If(
    CanEditRecord(Gallery.Selected.Owner.Email, Gallery.Selected.Status),
    DisplayMode.Edit,
    DisplayMode.Disabled
)
```

### Based on Form State

```powerfx
// Save button enabled only when form is valid
btn_Save.DisplayMode = If(
    form_Details.Valid,
    DisplayMode.Edit,
    DisplayMode.Disabled
)

// Cancel button always enabled
btn_Cancel.DisplayMode = DisplayMode.Edit
```

### Based on Selection

```powerfx
// View button visible only when item is selected
btn_ViewDetails.Visible = !IsBlank(Gallery.Selected)
```

---

## 🎨 Customization Guide

### Change Button Size

```powerfx
// Small button (32px height)
Height = 32
PaddingLeft = Spacing.MD  // 16px
PaddingRight = Spacing.MD

// Medium button (44px - default)
Height = 44
PaddingLeft = Spacing.LG  // 24px
PaddingRight = Spacing.LG

// Large button (56px)
Height = 56
PaddingLeft = Spacing.XL  // 32px
PaddingRight = Spacing.XL
```

### Change Border Radius

```powerfx
// Sharp corners
RadiusTopLeft = BorderRadius.None  // 0px

// Medium corners (default)
RadiusTopLeft = BorderRadius.MD  // 4px

// Rounded corners
RadiusTopLeft = BorderRadius.LG  // 8px

// Pill shape (fully rounded)
RadiusTopLeft = BorderRadius.Round  // 9999px
```

### Add Icon to Button

```powerfx
// Add an icon control next to the button text
// (Power Apps doesn't support built-in button icons in YAML format)

// Instead, use a Container with:
// - Icon control (left)
// - Button control (right)
// - Horizontal layout
```

---

## 📚 Related Documentation

- **Design System:** `docs/plans/2026-02-05-design-system-refactor-design.md`
- **UDF Reference:** `docs/reference/UDF-REFERENCE.md`
- **Control Patterns:** `src/Control-Patterns-Modern.fx` (Section 3.4)
- **App Formulas:** `src/App-Formulas-Template.fx` (Lines 50-871)

---

## ✅ Implementation Checklist

Before using these button templates:

- [ ] `App-Formulas-Template.fx` copied to your app's **App.Formulas** property
- [ ] **ThemeColors** Named Formula configured (Primary & Secondary colors)
- [ ] **ColorIntensity** Named Formula present (Hover, Pressed, Disabled, Focus)
- [ ] **Typography** Named Formula configured
- [ ] **Spacing** Named Formula configured
- [ ] **BorderRadius** Named Formula configured
- [ ] State color UDFs present: `GetHoverColor()`, `GetPressedColor()`, `GetDisabledColor()`, `GetFocusColor()`
- [ ] Permission UDFs present: `HasPermission()`, `CanAccessRecord()`, `CanEditRecord()`
- [ ] Notification UDFs present: `NotifySuccess()`, `NotifyError()`, `NotifyPermissionDenied()`

---

## 🎓 Best Practices

### Button Hierarchy

1. **One Primary button per screen** (main action)
2. **One or more Secondary buttons** (cancel, back)
3. **Outline buttons** for less important actions
4. **Accent buttons** only for special highlights (rare)

### Positioning

- **Left-to-right:** Primary → Secondary → Outline
- **Form buttons:** Right-aligned (Primary right, Cancel left)
- **Gallery buttons:** Inside gallery template or toolbar

### Touch Targets

- **Minimum height:** 44px (touch-friendly)
- **Minimum width:** 80px
- **Spacing between buttons:** 8-12px (`Spacing.SM` or `Spacing.MD`)

### Naming Convention

- Use `btn_` prefix: `btn_Submit`, `btn_Cancel`, `btn_ViewDetails`
- Descriptive names (not `Button1`, `Button2`)
- PascalCase after prefix: `btn_SaveAndClose`

---

**Last Updated:** 2026-02-14
**Template Version:** Phase 4 Complete (Production-Ready)
**Compatibility:** Power Apps Canvas Apps (2025+)
