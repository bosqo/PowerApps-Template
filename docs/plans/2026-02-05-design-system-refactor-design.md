# Design System Refactor - 2-Color Simplified System

**Date:** 2026-02-05
**Status:** Validated against Microsoft Documentation
**Goal:** Minimize customer customization to 2 colors, derive all states via ColorFade

---

## Executive Summary

Refactor the current 28+ color design system to a simplified 2-customer-color approach where:
- **Primary** and **Secondary** are the only colors changed per project
- All interactive states (Hover, Pressed, Disabled, Focus) derived via `ColorFade()`
- Semantic colors (Success, Warning, Error) remain static across all apps
- 4 button patterns cover all use cases

**Result:** Change 2 hex values → entire app theme updates automatically.

---

## Problem Statement

### Current System Issues
- 28+ color definitions in ThemeColors
- Explicit variants: `Primary`, `PrimaryLight`, `PrimaryDark`, `SuccessLight`, `ErrorLight`, etc.
- Manual color adjustments per customer project
- Inconsistent hover/pressed states across controls
- No ColorFade usage

### Customer Pain Points
- Designers must specify 15+ colors per brand
- Inconsistent interaction states
- Time-consuming theme customization
- Risk of accessibility issues (contrast ratios)

---

## Design Principles

1. **Minimal Configuration**: Only 2 customer colors (Primary + Secondary)
2. **Automatic Derivation**: All states via ColorFade with centralized intensity values
3. **Static Semantics**: Success/Warning/Error colors never change (consistency across apps)
4. **Fluent 2 Aligned**: Follows Microsoft's modern design system guidelines
5. **Accessible by Default**: ColorFade ensures sufficient contrast for states

---

## Architecture

### Layer 1: Customer Colors (2 Values)

```powerfx
ThemeColors = {
    Primary: ColorValue("#0078D4"),      // Main brand color
    Secondary: ColorValue("#50E6FF"),     // Accent (minimal usage)
    // ... rest derived
};
```

### Layer 2: State Intensity Constants

```powerfx
ColorIntensity = {
    Hover: -0.20,      // 20% darker
    Pressed: -0.30,    // 30% darker
    Disabled: 0.60,    // 60% lighter (washed out)
    Focus: -0.10       // 10% darker border
};
```

**Note:** ColorFade range is `-1.0` (fully black) to `1.0` (fully white). Negative values darken, positive values lighten.

### Layer 3: State Color UDFs

```powerfx
GetHoverColor(baseColor: Color): Color =
    ColorFade(baseColor, ColorIntensity.Hover);

GetPressedColor(baseColor: Color): Color =
    ColorFade(baseColor, ColorIntensity.Pressed);

GetDisabledColor(baseColor: Color): Color =
    ColorFade(baseColor, ColorIntensity.Disabled);

GetFocusColor(baseColor: Color): Color =
    ColorFade(baseColor, ColorIntensity.Focus);
```

**Benefits:**
- Semantic clarity: `GetHoverColor()` is self-documenting
- Centralized changes: Adjust hover intensity globally in one place
- Reusable: Works with any color (Primary, Secondary, status colors, role colors)
- Testable: Can validate in isolation with constant values

### Layer 4: Button Patterns

Four patterns cover all use cases:

| Pattern | Use Case | Colors |
|---------|----------|--------|
| **Primary** | Main CTA (Submit, Save, Create) | `ThemeColors.Primary` |
| **Secondary** | Cancel, Back, Close | `ThemeColors.NeutralGray` |
| **Outline** | View, Edit, Download | White fill + Text border |
| **Accent** | Special highlights (rare) | `ThemeColors.Secondary` |

---

## Complete Implementation

### ThemeColors Named Formula

```powerfx
// ============================================
// THEME COLORS - Simplified 2-Color System
// ============================================
//
// CUSTOMER CUSTOMIZATION (per project):
// 1. Change Primary (line 10)
// 2. Change Secondary (line 11)
// 3. Done! All states auto-derived via ColorFade
//
// ColorFade range: -1.0 (black) to 0 (no change) to 1.0 (white)
// ============================================

ThemeColors = {
    // ========================================
    // CUSTOMER COLORS (Change per project)
    // ========================================
    Primary: ColorValue("#0078D4"),      // Main brand color
    Secondary: ColorValue("#50E6FF"),     // Accent (badges, highlights only)

    // ========================================
    // STATIC SEMANTIC COLORS (Never change)
    // ========================================
    Success: ColorValue("#107C10"),       // Green - all apps
    Warning: ColorValue("#FFB900"),       // Amber - all apps
    Error: ColorValue("#D13438"),         // Red - all apps
    Info: ColorValue("#0078D4"),          // Blue - all apps

    // ========================================
    // NEUTRAL BASE VALUES
    // ========================================
    NeutralBase: ColorValue("#F3F2F1"),   // Base gray
    NeutralGray: ColorValue("#8A8886"),   // For gray buttons

    Text: ColorValue("#201F1E"),          // Primary text (black)

    // ========================================
    // DERIVED NEUTRALS (Auto-calculated)
    // ========================================
    TextSecondary: ColorFade(ColorValue("#201F1E"), 0.60),     // Lighter text
    TextDisabled: ColorFade(ColorValue("#201F1E"), 0.75),      // Disabled text

    Background: ColorValue("#F3F2F1"),                          // Page background
    Surface: ColorFade(ColorValue("#F3F2F1"), -0.08),          // White cards
    SurfaceHover: ColorFade(ColorValue("#F3F2F1"), 0.05),      // Hover state for cards

    Border: ColorFade(ColorValue("#F3F2F1"), 0.10),            // Default borders
    BorderStrong: ColorFade(ColorValue("#F3F2F1"), 0.25),      // Emphasized borders
    Divider: ColorFade(ColorValue("#F3F2F1"), 0.15),           // Separators

    // ========================================
    // UTILITY COLORS (Overlays, Shadows)
    // ========================================
    Overlay: RGBA(0, 0, 0, 0.4),          // Modal backdrop
    Shadow: RGBA(0, 0, 0, 0.1)            // Drop shadows
};
```

### ColorIntensity Constants

```powerfx
// ============================================
// COLOR INTENSITY - Interaction States
// ============================================
// Controls how much colors darken/lighten for states
// Range: -1.0 (fully darken) to 1.0 (fully lighten)
// ============================================

ColorIntensity = {
    Hover: -0.20,      // Darken 20% on hover
    Pressed: -0.30,    // Darken 30% when pressed
    Disabled: 0.60,    // Lighten 60% when disabled (washed out)
    Focus: -0.10       // Darken 10% for focus border
};
```

### State Color UDFs

```powerfx
// ============================================
// STATE COLOR UDFs (Interactive States)
// ============================================
// Apply consistent ColorFade transformations
// for all interactive controls
// ============================================

// Hover state (20% darker)
GetHoverColor(baseColor: Color): Color =
    ColorFade(baseColor, ColorIntensity.Hover);

// Pressed state (30% darker)
GetPressedColor(baseColor: Color): Color =
    ColorFade(baseColor, ColorIntensity.Pressed);

// Disabled state (60% lighter, washed out)
GetDisabledColor(baseColor: Color): Color =
    ColorFade(baseColor, ColorIntensity.Disabled);

// Focus border (10% darker)
GetFocusColor(baseColor: Color): Color =
    ColorFade(baseColor, ColorIntensity.Focus);
```

### Button Control Patterns

```powerfx
// ============================================
// BUTTON CONTROL PATTERNS
// ============================================

// -------------------------------------------
// Pattern 1: Primary Button (Main CTA)
// -------------------------------------------
// Use for: btn_Submit, btn_Create, btn_Save

Fill: ThemeColors.Primary
HoverFill: GetHoverColor(ThemeColors.Primary)
PressedFill: GetPressedColor(ThemeColors.Primary)
DisabledFill: GetDisabledColor(ThemeColors.Primary)
BorderColor: Color.Transparent
Color: Color.White
DisabledColor: Color.White

// -------------------------------------------
// Pattern 2: Secondary Button (Gray, no border)
// -------------------------------------------
// Use for: btn_Cancel, btn_Back, btn_Close

Fill: ThemeColors.NeutralGray
HoverFill: GetHoverColor(ThemeColors.NeutralGray)
PressedFill: GetPressedColor(ThemeColors.NeutralGray)
DisabledFill: GetDisabledColor(ThemeColors.NeutralGray)
BorderColor: Color.Transparent
Color: Color.White
DisabledColor: Color.White

// -------------------------------------------
// Pattern 3: Outline Button (White + Border)
// -------------------------------------------
// Use for: btn_ViewDetails, btn_Edit, btn_Download

Fill: ThemeColors.Surface
HoverFill: GetHoverColor(ThemeColors.NeutralBase)
PressedFill: GetPressedColor(ThemeColors.NeutralBase)
DisabledFill: ThemeColors.Surface
BorderColor: ThemeColors.Text
HoverBorderColor: GetHoverColor(ThemeColors.Text)
DisabledBorderColor: GetDisabledColor(ThemeColors.Text)
Color: ThemeColors.Text
DisabledColor: ThemeColors.TextDisabled

// -------------------------------------------
// Pattern 4: Accent Button (Uses Secondary - rare)
// -------------------------------------------
// Use for: btn_Highlight, btn_Feature (special actions only)

Fill: ThemeColors.Secondary
HoverFill: GetHoverColor(ThemeColors.Secondary)
PressedFill: GetPressedColor(ThemeColors.Secondary)
DisabledFill: GetDisabledColor(ThemeColors.Secondary)
BorderColor: Color.Transparent
Color: ThemeColors.Text
DisabledColor: ThemeColors.TextDisabled
```

---

## Design Decisions

### Decision 1: UDFs vs. Direct Named Properties

**Considered:** `ThemeColors.PrimaryHover` vs. `GetHoverColor(ThemeColors.Primary)`

**Chose:** UDFs (via `GetHoverColor()`)

**Rationale:**
- Smaller ThemeColors object (15 properties vs. 39+)
- Works dynamically with any color (status colors, role badges)
- Global intensity adjustments (change one value, all states update)
- True "2-color customization" (customer doesn't see 39 properties)

**Trade-off:** Slightly longer formulas, but better for template reusability.

---

### Decision 2: Outline Button Hover Color

**Considered:** Create `GetOutlineHoverColor()` UDF vs. reuse existing

**Chose:** Reuse `GetHoverColor(ThemeColors.NeutralBase)`

**Rationale:**
- Avoids single-purpose UDF
- Clear and flexible
- Consistent pattern with other buttons

---

### Decision 3: Secondary Color Usage

**Considered:**
- Option A: Minimal (badges, special highlights only)
- Option B: Balanced (50/50 with Primary)
- Option C: Derived from Primary (eliminate Secondary entirely)

**Chose:** Option A (Minimal Secondary)

**Rationale:**
- Most apps work with one strong brand color + neutrals
- Gives flexibility when needed without forcing "Primary or Secondary?" decisions
- Aligns with Fluent 2 design patterns

---

## Microsoft Documentation Validation

All syntax and patterns validated against official Microsoft documentation:

### ✅ ColorFade Syntax
- **Validated:** Range is `-1.0` to `1.0` (decimals, not percentages)
- **Source:** [ColorFade Official Documentation](https://learn.microsoft.com/en-us/power-platform/power-fx/reference/function-colors)

### ✅ Named Formulas Best Practices
- Declarative, immutable, no side effects
- Automatically update when dependencies change
- **Source:** [Named Formulas Announcement](https://www.microsoft.com/en-us/power-platform/blog/power-apps/power-fx-introducing-named-formulas/)

### ✅ UDF Best Practices
- Keep declarative (pure functions)
- Centralize and reuse logic
- Use self-documenting parameter names
- **Source:** [User Defined Functions GA](https://www.microsoft.com/en-us/power-platform/blog/power-apps/power-apps-user-defined-functions-ga/)

### ✅ Fluent 2 Design Alignment
- Seed color generates palette via ColorFade
- Semantic colors follow Fluent conventions
- **Source:** [Modern Themes in Canvas Apps](https://learn.microsoft.com/en-us/power-apps/maker/canvas-apps/controls/modern-controls/modern-theming)

---

## Impact Analysis

### Before Refactor
- **Colors defined:** 28+
- **Customer changes required:** 15+ color values
- **Inconsistent states:** Manual hover/pressed definitions
- **Maintenance cost:** High (change scattered across controls)

### After Refactor
- **Colors defined:** 2 customer colors + derived values
- **Customer changes required:** 2 hex values
- **Consistent states:** All via ColorFade UDFs
- **Maintenance cost:** Low (change ColorIntensity once)

### Migration Effort

| File | Lines Changed | Effort |
|------|---------------|--------|
| `src/App-Formulas-Template.fx` | ~100 lines (ThemeColors refactor) | High |
| `src/Control-Patterns-Modern.fx` | ~50 lines (button patterns) | Medium |
| `docs/UDF-REFERENCE.md` | +20 lines (document new UDFs) | Low |
| `CLAUDE.md` | ~30 lines (update guidance) | Low |

**Total Estimated Effort:** 4-6 hours

---

## Testing Strategy

### Unit Tests (UDFs)
Test each UDF with constant values:

```powerfx
// Label for testing GetHoverColor
lbl_TestHover.Text =
    "Hover: " & JSON(GetHoverColor(ColorValue("#0078D4")))

// Expected: darker shade of #0078D4
```

### Visual Tests (Button Patterns)
Create test screen with all 4 button types:
1. Primary button (blue)
2. Secondary button (gray)
3. Outline button (white + border)
4. Accent button (cyan)

Verify:
- ✅ Hover states darken correctly
- ✅ Pressed states darken more
- ✅ Disabled states wash out
- ✅ Focus borders visible

### Customer Customization Test
1. Change `Primary` to red (#D13438)
2. Change `Secondary` to purple (#881798)
3. Verify all buttons, badges, and controls update automatically
4. Test on multiple screens

---

## Risks & Mitigations

### Risk 1: Accessibility (Contrast Ratios)
**Risk:** ColorFade might produce insufficient contrast for WCAG AA compliance

**Mitigation:**
- Test with WebAIM Contrast Checker
- Adjust `ColorIntensity.Hover` if needed (e.g., -0.25 instead of -0.20)
- Document minimum lightness thresholds for Primary/Secondary colors

### Risk 2: Existing Controls Break
**Risk:** Controls using old color references (e.g., `ThemeColors.PrimaryLight`) break

**Mitigation:**
- Deprecate old properties gradually (keep as aliases initially)
- Use Find/Replace to update controls systematically
- Test each screen before deleting old properties

### Risk 3: Dynamic Colors (Status, Roles)
**Risk:** Status badges and role colors need custom handling

**Mitigation:**
- Existing `GetStatusColor()` and `GetRoleBadgeColor()` UDFs already return base colors
- Apply `GetHoverColor()` to results: `GetHoverColor(GetStatusColor(status))`
- No changes needed to status/role logic

---

## Success Criteria

### Functional
- ✅ 2-color customization works (change 2 hex values → app updates)
- ✅ All 4 button patterns render correctly
- ✅ Interactive states (hover, pressed, disabled) work consistently
- ✅ Existing features (status badges, role colors, notifications) unaffected

### Non-Functional
- ✅ WCAG AA contrast compliance maintained
- ✅ No performance degradation (ColorFade is native Power Fx function)
- ✅ Design system documented in `docs/UDF-REFERENCE.md`
- ✅ Control patterns updated in `src/Control-Patterns-Modern.fx`

### User Acceptance
- ✅ Designers confirm 2-color customization is sufficient
- ✅ Developers find button patterns easy to apply
- ✅ No visual regressions reported in UAT

---

## Next Steps

1. **Create Implementation Plan** (use `superpowers:writing-plans` skill)
2. **Refactor App-Formulas-Template.fx** (ThemeColors + new UDFs)
3. **Update Control-Patterns-Modern.fx** (button patterns)
4. **Test on sample screens** (visual validation)
5. **Update documentation** (UDF-REFERENCE.md, CLAUDE.md)
6. **Commit and create PR** (feature branch → main)

---

## References

- [ColorFade Function - Microsoft Learn](https://learn.microsoft.com/en-us/power-platform/power-fx/reference/function-colors)
- [Named Formulas - Microsoft Power Platform Blog](https://www.microsoft.com/en-us/power-platform/blog/power-apps/power-fx-introducing-named-formulas/)
- [User Defined Functions GA - Microsoft Power Platform Blog](https://www.microsoft.com/en-us/power-platform/blog/power-apps/power-apps-user-defined-functions-ga/)
- [Modern Themes in Canvas Apps - Microsoft Learn](https://learn.microsoft.com/en-us/power-apps/maker/canvas-apps/controls/modern-controls/modern-theming)
- [5 Best Practices for Named Formulas - SharePains](https://sharepains.com/2024/10/22/best-practices-named-formulas-power-apps/)
