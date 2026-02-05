# Design System Refactor - 2-Color Simplified System

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Simplify design system to 2 customer colors (Primary + Secondary) with all interactive states derived via ColorFade UDFs.

**Architecture:** Replace 28+ explicit color definitions with 2 customer colors + derived neutrals. Add 4 state UDFs (GetHoverColor, GetPressedColor, GetDisabledColor, GetFocusColor) that apply consistent ColorFade transformations. Update button patterns to use new UDFs.

**Tech Stack:** Power Fx, Named Formulas, User-Defined Functions, ColorFade()

**Design Document:** `docs/plans/2026-02-05-design-system-refactor-design.md`

---

## Task 1: Backup and Add ColorIntensity Constants

**Files:**
- Modify: `src/App-Formulas-Template.fx:51-81`

**Goal:** Add ColorIntensity Named Formula after ThemeColors for centralized state intensity values.

**Step 1: Locate insertion point**

Find line 81 (after ThemeColors closing brace).

**Step 2: Add ColorIntensity Named Formula**

Insert after ThemeColors definition (around line 81):

```powerfx
// Color Intensity - State Transformations
// Controls how much colors darken/lighten for interactive states
// Range: -1.0 (fully darken) to 1.0 (fully lighten)
ColorIntensity = {
    Hover: -0.20,      // Darken 20% on hover
    Pressed: -0.30,    // Darken 30% when pressed
    Disabled: 0.60,    // Lighten 60% when disabled (washed out)
    Focus: -0.10       // Darken 10% for focus border
};
```

**Step 3: Verify syntax**

No runtime test yet (this is a constant). Visual inspection: ensure proper braces, semicolons, and decimal format.

**Step 4: Commit**

```bash
git add src/App-Formulas-Template.fx
git commit -m "feat(design): add ColorIntensity constants for state transformations"
```

---

## Task 2: Add GetHoverColor UDF

**Files:**
- Modify: `src/App-Formulas-Template.fx:~830` (after GetStatusIcon, before notification UDFs)

**Goal:** Add first state color UDF for hover states.

**Step 1: Locate insertion point**

Find the section after GetPriorityColor (around line 830). Insert before notification functions section.

**Step 2: Add GetHoverColor UDF**

```powerfx
// ============================================================
// STATE COLOR UDFs (Interactive States)
// ============================================================
// Apply consistent ColorFade transformations for interactive states

// Get hover state color (20% darker)
GetHoverColor(baseColor: Color): Color =
    ColorFade(baseColor, ColorIntensity.Hover);
```

**Step 3: Test in Power Apps Studio**

Create a test label:
- Add label `lbl_TestHover`
- Set `Fill` property: `GetHoverColor(ThemeColors.Primary)`
- Expected: Darker blue than Primary

**Step 4: Commit**

```bash
git add src/App-Formulas-Template.fx
git commit -m "feat(design): add GetHoverColor UDF for consistent hover states"
```

---

## Task 3: Add GetPressedColor UDF

**Files:**
- Modify: `src/App-Formulas-Template.fx:~838` (after GetHoverColor)

**Step 1: Add GetPressedColor UDF**

Insert immediately after GetHoverColor:

```powerfx
// Get pressed state color (30% darker)
GetPressedColor(baseColor: Color): Color =
    ColorFade(baseColor, ColorIntensity.Pressed);
```

**Step 2: Test in Power Apps Studio**

Update test label:
- Set `Fill` property: `GetPressedColor(ThemeColors.Primary)`
- Expected: Even darker blue than Hover (should be noticeably darker)

**Step 3: Commit**

```bash
git add src/App-Formulas-Template.fx
git commit -m "feat(design): add GetPressedColor UDF for consistent pressed states"
```

---

## Task 4: Add GetDisabledColor UDF

**Files:**
- Modify: `src/App-Formulas-Template.fx:~843` (after GetPressedColor)

**Step 1: Add GetDisabledColor UDF**

Insert immediately after GetPressedColor:

```powerfx
// Get disabled state color (60% lighter, washed out)
GetDisabledColor(baseColor: Color): Color =
    ColorFade(baseColor, ColorIntensity.Disabled);
```

**Step 2: Test in Power Apps Studio**

Update test label:
- Set `Fill` property: `GetDisabledColor(ThemeColors.Primary)`
- Expected: Very light, washed-out blue (low opacity appearance)

**Step 3: Commit**

```bash
git add src/App-Formulas-Template.fx
git commit -m "feat(design): add GetDisabledColor UDF for consistent disabled states"
```

---

## Task 5: Add GetFocusColor UDF

**Files:**
- Modify: `src/App-Formulas-Template.fx:~848` (after GetDisabledColor)

**Step 1: Add GetFocusColor UDF**

Insert immediately after GetDisabledColor:

```powerfx
// Get focus border color (10% darker)
GetFocusColor(baseColor: Color): Color =
    ColorFade(baseColor, ColorIntensity.Focus);
```

**Step 2: Test in Power Apps Studio**

Update test label:
- Set `Fill` property: `GetFocusColor(ThemeColors.Primary)`
- Expected: Slightly darker blue (subtle darkening for focus ring)

**Step 3: Commit**

```bash
git add src/App-Formulas-Template.fx
git commit -m "feat(design): add GetFocusColor UDF for consistent focus borders"
```

---

## Task 6: Refactor ThemeColors to 2-Color System

**Files:**
- Modify: `src/App-Formulas-Template.fx:51-81`

**Goal:** Replace explicit color variants (PrimaryLight, PrimaryDark, etc.) with derived neutrals using ColorFade.

**Step 1: Replace ThemeColors definition**

Replace lines 51-81 with:

```powerfx
// Theme Colors - Simplified 2-Color System
// CUSTOMER CUSTOMIZATION: Change Primary and Secondary only
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

**Step 2: Visual inspection**

Check:
- ✅ Removed: PrimaryLight, PrimaryDark, SuccessLight, WarningLight, ErrorLight
- ✅ Added: NeutralBase, NeutralGray
- ✅ Derived: TextSecondary, TextDisabled, Surface, SurfaceHover, Border, BorderStrong, Divider
- ✅ All ColorFade values are decimals (-1.0 to 1.0 range)

**Step 3: Test in Power Apps Studio**

Check that no errors appear in App.Formulas. Power Apps will show red underlines if syntax is wrong.

**Step 4: Commit**

```bash
git add src/App-Formulas-Template.fx
git commit -m "refactor(design): simplify ThemeColors to 2-color system with derived neutrals"
```

---

## Task 7: Update GetThemeColor UDF (Remove Deprecated References)

**Files:**
- Modify: `src/App-Formulas-Template.fx:747-779`

**Goal:** Remove references to deleted color properties (PrimaryLight, PrimaryDark, SuccessLight, etc.).

**Step 1: Locate GetThemeColor UDF**

Find GetThemeColor function (around line 747).

**Step 2: Replace with updated version**

Replace the Switch statement:

```powerfx
// Get theme color by name
GetThemeColor(colorName: Text): Color =
    Switch(
        Lower(colorName),
        // Brand
        "primary", ThemeColors.Primary,
        "secondary", ThemeColors.Secondary,
        // Semantic
        "success", ThemeColors.Success,
        "warning", ThemeColors.Warning,
        "error", ThemeColors.Error,
        "info", ThemeColors.Info,
        // Neutrals
        "neutralbase", ThemeColors.NeutralBase,
        "neutralgray", ThemeColors.NeutralGray,
        "background", ThemeColors.Background,
        "surface", ThemeColors.Surface,
        "surfacehover", ThemeColors.SurfaceHover,
        "text", ThemeColors.Text,
        "textsecondary", ThemeColors.TextSecondary,
        "textdisabled", ThemeColors.TextDisabled,
        "border", ThemeColors.Border,
        "borderstrong", ThemeColors.BorderStrong,
        "divider", ThemeColors.Divider,
        // Special
        "role", RoleColor,
        "overlay", ThemeColors.Overlay,
        "shadow", ThemeColors.Shadow,
        // Default
        ThemeColors.Primary
    );
```

**Step 3: Verify removed references**

Removed:
- ❌ "primarylight"
- ❌ "primarydark"
- ❌ "successlight"
- ❌ "warninglight"
- ❌ "errorlight"

Added:
- ✅ "neutralbase"
- ✅ "neutralgray"

**Step 4: Commit**

```bash
git add src/App-Formulas-Template.fx
git commit -m "refactor(design): update GetThemeColor to use new color names"
```

---

## Task 8: Update Control-Patterns-Modern.fx Button Patterns

**Files:**
- Modify: `src/Control-Patterns-Modern.fx:513-537`

**Goal:** Replace old button patterns with new UDF-based patterns.

**Step 1: Locate button patterns section**

Find "Pattern 3.4: Theme Color References" section (around line 513).

**Step 2: Replace with new button patterns**

Replace lines 513-537 with:

```powerfx
// -----------------------------------------------------------
// Pattern 3.4: Button Control Patterns (2-Color System)
// -----------------------------------------------------------

// =========================================
// PRIMARY BUTTON (Main CTA)
// =========================================
// Use for: btn_Submit, btn_Create, btn_Save

// btn_Primary.Fill
ThemeColors.Primary

// btn_Primary.HoverFill
GetHoverColor(ThemeColors.Primary)

// btn_Primary.PressedFill
GetPressedColor(ThemeColors.Primary)

// btn_Primary.DisabledFill
GetDisabledColor(ThemeColors.Primary)

// btn_Primary.BorderColor
Color.Transparent

// btn_Primary.Color
Color.White

// btn_Primary.DisabledColor
Color.White


// =========================================
// SECONDARY BUTTON (Gray, no border)
// =========================================
// Use for: btn_Cancel, btn_Back, btn_Close

// btn_Secondary.Fill
ThemeColors.NeutralGray

// btn_Secondary.HoverFill
GetHoverColor(ThemeColors.NeutralGray)

// btn_Secondary.PressedFill
GetPressedColor(ThemeColors.NeutralGray)

// btn_Secondary.DisabledFill
GetDisabledColor(ThemeColors.NeutralGray)

// btn_Secondary.BorderColor
Color.Transparent

// btn_Secondary.Color
Color.White

// btn_Secondary.DisabledColor
Color.White


// =========================================
// OUTLINE BUTTON (White + Border)
// =========================================
// Use for: btn_ViewDetails, btn_Edit, btn_Download

// btn_Outline.Fill
ThemeColors.Surface

// btn_Outline.HoverFill
GetHoverColor(ThemeColors.NeutralBase)

// btn_Outline.PressedFill
GetPressedColor(ThemeColors.NeutralBase)

// btn_Outline.DisabledFill
ThemeColors.Surface

// btn_Outline.BorderColor
ThemeColors.Text

// btn_Outline.HoverBorderColor
GetHoverColor(ThemeColors.Text)

// btn_Outline.DisabledBorderColor
GetDisabledColor(ThemeColors.Text)

// btn_Outline.Color
ThemeColors.Text

// btn_Outline.DisabledColor
ThemeColors.TextDisabled


// =========================================
// ACCENT BUTTON (Uses Secondary - rare)
// =========================================
// Use for: btn_Highlight, btn_Feature (special actions only)

// btn_Accent.Fill
ThemeColors.Secondary

// btn_Accent.HoverFill
GetHoverColor(ThemeColors.Secondary)

// btn_Accent.PressedFill
GetPressedColor(ThemeColors.Secondary)

// btn_Accent.DisabledFill
GetDisabledColor(ThemeColors.Secondary)

// btn_Accent.BorderColor
Color.Transparent

// btn_Accent.Color
ThemeColors.Text

// btn_Accent.DisabledColor
ThemeColors.TextDisabled
```

**Step 3: Verify old pattern removed**

Removed:
- ❌ References to GetThemeColor("PrimaryLight")
- ❌ References to GetThemeColor("PrimaryDark")

Added:
- ✅ 4 button patterns with UDF-based states
- ✅ All patterns use GetHoverColor/GetPressedColor/GetDisabledColor

**Step 4: Commit**

```bash
git add src/Control-Patterns-Modern.fx
git commit -m "refactor(design): update button patterns to use state UDFs"
```

---

## Task 9: Update UDF-REFERENCE.md Documentation

**Files:**
- Modify: `docs/UDF-REFERENCE.md:133-169`

**Goal:** Add new State Color UDFs to Theme & Color Functions section.

**Step 1: Locate Theme & Color Functions section**

Find "## 4. Theme & Color Functions" (around line 133).

**Step 2: Add new UDFs to table**

Replace lines 137-146 with expanded table:

```markdown
| UDF | Parameters | Returns | Description |
|-----|------------|---------|-------------|
| `GetThemeColor` | `colorName: Text` | `Color` | Returns a named color from ThemeColors (primary, success, error, etc.) |
| `GetStatusColor` | `status: Text` | `Color` | Returns semantic color for status values (active=green, pending=amber, etc.) |
| `GetStatusIcon` | `status: Text` | `Text` | Returns built-in icon name for status values |
| `GetPriorityColor` | `priority: Text` | `Color` | Returns color for priority levels (critical=red, high=orange, etc.) |
| `GetHoverColor` | `baseColor: Color` | `Color` | Returns hover state color (20% darker via ColorFade) |
| `GetPressedColor` | `baseColor: Color` | `Color` | Returns pressed state color (30% darker via ColorFade) |
| `GetDisabledColor` | `baseColor: Color` | `Color` | Returns disabled state color (60% lighter via ColorFade) |
| `GetFocusColor` | `baseColor: Color` | `Color` | Returns focus border color (10% darker via ColorFade) |
| `GetToastBackground` | `toastType: Text` | `Color` | Returns background color for toast notifications |
| `GetToastBorderColor` | `toastType: Text` | `Color` | Returns border color for toast notifications |
| `GetToastIcon` | `toastType: Text` | `Text` | Returns icon character for toast notifications |
| `GetToastIconColor` | `toastType: Text` | `Color` | Returns icon color for toast notifications |
```

**Step 3: Add usage examples for state UDFs**

Replace lines 155-167 with updated examples:

```markdown
### Usage Examples

```powerfx
// Status badge color
lbl_StatusBadge.Fill = GetStatusColor(ThisItem.Status)

// Priority indicator
ico_Priority.Color = GetPriorityColor(ThisItem.Priority)

// Primary button with automatic states
btn_Submit.Fill = ThemeColors.Primary
btn_Submit.HoverFill = GetHoverColor(ThemeColors.Primary)
btn_Submit.PressedFill = GetPressedColor(ThemeColors.Primary)
btn_Submit.DisabledFill = GetDisabledColor(ThemeColors.Primary)

// Dynamic status button with hover
btn_StatusAction.Fill = GetStatusColor(ThisItem.Status)
btn_StatusAction.HoverFill = GetHoverColor(GetStatusColor(ThisItem.Status))
```
```

**Step 4: Commit**

```bash
git add docs/UDF-REFERENCE.md
git commit -m "docs: add state color UDFs to UDF reference"
```

---

## Task 10: Update CLAUDE.md Design System Section

**Files:**
- Modify: `CLAUDE.md:~50` (locate design system section)

**Goal:** Document new 2-color customization approach in project documentation.

**Step 1: Locate design system documentation**

Search for "ThemeColors" or "Design System" section in CLAUDE.md.

**Step 2: Add new design system summary**

Insert after Architektur-Prinzipien section (around line 50):

```markdown
### Design System (2-Color Simplified)

**Customer Customization:** Only 2 colors need changing per project
- `ThemeColors.Primary` - Main brand color
- `ThemeColors.Secondary` - Accent color (minimal usage)

**All interactive states auto-derived via ColorFade:**
```powerfx
ColorIntensity = {
    Hover: -0.20,      // 20% darker
    Pressed: -0.30,    // 30% darker
    Disabled: 0.60,    // 60% lighter (washed out)
    Focus: -0.10       // 10% darker border
};
```

**State UDFs:**
- `GetHoverColor(baseColor)` - 20% darker for hover states
- `GetPressedColor(baseColor)` - 30% darker for pressed states
- `GetDisabledColor(baseColor)` - 60% lighter for disabled states
- `GetFocusColor(baseColor)` - 10% darker for focus borders

**Button Patterns (4 types):**
| Type | Usage | Base Color |
|------|-------|------------|
| Primary | Submit, Save, Create | `ThemeColors.Primary` |
| Secondary | Cancel, Back, Close | `ThemeColors.NeutralGray` |
| Outline | View, Edit, Download | White + Text border |
| Accent | Special highlights (rare) | `ThemeColors.Secondary` |

**Semantic colors static across all apps:**
- Success: Green (#107C10)
- Warning: Amber (#FFB900)
- Error: Red (#D13438)
- Info: Blue (#0078D4)

See `docs/plans/2026-02-05-design-system-refactor-design.md` for full architecture.
```

**Step 3: Update UDF Quick Reference**

Locate UDF Quick Reference section and add to "Theme & Color" category:

```markdown
### Theme & Color (12 UDFs)
| UDF | Returns | Beschreibung |
|-----|---------|-------------|
| `GetThemeColor(name)` | Color | Theme-Farbe abrufen (primary, success, error, etc.) |
| `GetStatusColor(status)` | Color | Farbe für Status-Wert (active=grün, pending=amber, etc.) |
| `GetPriorityColor(priority)` | Color | Farbe für Priorität (critical=rot, high=orange, etc.) |
| `GetHoverColor(baseColor)` | Color | Hover-Zustand (20% dunkler) |
| `GetPressedColor(baseColor)` | Color | Pressed-Zustand (30% dunkler) |
| `GetDisabledColor(baseColor)` | Color | Disabled-Zustand (60% heller) |
| `GetFocusColor(baseColor)` | Color | Focus-Border (10% dunkler) |
```

**Step 4: Commit**

```bash
git add CLAUDE.md
git commit -m "docs: update CLAUDE.md with 2-color design system"
```

---

## Task 11: Visual Testing

**Files:**
- Test in Power Apps Studio (no file changes)

**Goal:** Verify all button patterns render correctly with new UDFs.

**Step 1: Create test screen**

In Power Apps Studio:
1. Insert new blank screen: `scr_DesignSystemTest`
2. Add 4 buttons vertically:
   - `btn_TestPrimary` (Primary pattern)
   - `btn_TestSecondary` (Secondary pattern)
   - `btn_TestOutline` (Outline pattern)
   - `btn_TestAccent` (Accent pattern)

**Step 2: Apply button patterns**

For each button, copy properties from Control-Patterns-Modern.fx:

Primary button:
```powerfx
Fill: ThemeColors.Primary
HoverFill: GetHoverColor(ThemeColors.Primary)
PressedFill: GetPressedColor(ThemeColors.Primary)
DisabledFill: GetDisabledColor(ThemeColors.Primary)
Color: Color.White
```

Secondary button:
```powerfx
Fill: ThemeColors.NeutralGray
HoverFill: GetHoverColor(ThemeColors.NeutralGray)
PressedFill: GetPressedColor(ThemeColors.NeutralGray)
DisabledFill: GetDisabledColor(ThemeColors.NeutralGray)
Color: Color.White
```

Outline button:
```powerfx
Fill: ThemeColors.Surface
HoverFill: GetHoverColor(ThemeColors.NeutralBase)
PressedFill: GetPressedColor(ThemeColors.NeutralBase)
BorderColor: ThemeColors.Text
HoverBorderColor: GetHoverColor(ThemeColors.Text)
Color: ThemeColors.Text
```

Accent button:
```powerfx
Fill: ThemeColors.Secondary
HoverFill: GetHoverColor(ThemeColors.Secondary)
PressedFill: GetPressedColor(ThemeColors.Secondary)
DisabledFill: GetDisabledColor(ThemeColors.Secondary)
Color: ThemeColors.Text
```

**Step 3: Manual interaction testing**

Test each button:
- ✅ Default state renders correctly
- ✅ Hover darkens appropriately
- ✅ Pressed darkens more
- ✅ Disabled washes out (toggle `DisplayMode: DisplayMode.Disabled`)

**Step 4: Test customer color change**

In App.Formulas, change:
```powerfx
Primary: ColorValue("#D13438")  // Red instead of blue
```

Verify all Primary buttons update to red automatically.

Change back to blue:
```powerfx
Primary: ColorValue("#0078D4")
```

**Step 5: Document test results**

No commit needed (test screen can be deleted or kept for future reference).

---

## Task 12: Clean Up Test Screen (Optional)

**Files:**
- Delete test screen in Power Apps Studio (no file changes)

**Step 1: Delete test screen**

If keeping for reference: Rename to `scr_DesignSystemReference`

If removing: Delete `scr_DesignSystemTest`

**Step 2: Save and publish**

Save app in Power Apps Studio.

---

## Task 13: Final Summary Commit

**Files:**
- All modified files

**Goal:** Create summary of changes for PR.

**Step 1: Review git log**

```bash
git log --oneline -15
```

Expected commits:
- feat(design): add ColorIntensity constants
- feat(design): add GetHoverColor UDF
- feat(design): add GetPressedColor UDF
- feat(design): add GetDisabledColor UDF
- feat(design): add GetFocusColor UDF
- refactor(design): simplify ThemeColors to 2-color system
- refactor(design): update GetThemeColor to use new color names
- refactor(design): update button patterns to use state UDFs
- docs: add state color UDFs to UDF reference
- docs: update CLAUDE.md with 2-color design system

**Step 2: Create comprehensive summary**

Add summary note to commit history:

```bash
git commit --allow-empty -m "chore: design system refactor complete

SUMMARY:
- Simplified from 28+ colors to 2 customer colors (Primary + Secondary)
- Added 4 state UDFs: GetHoverColor, GetPressedColor, GetDisabledColor, GetFocusColor
- All interactive states now derived via ColorFade with centralized ColorIntensity
- Updated 4 button patterns: Primary, Secondary, Outline, Accent
- Removed deprecated color references (PrimaryLight, PrimaryDark, etc.)
- Updated documentation: UDF-REFERENCE.md, CLAUDE.md

TESTING:
- Visual testing completed on all 4 button types
- Customer color change verified (Primary red → all buttons update)
- No errors in App.Formulas

IMPACT:
- Customer customization reduced from 15+ colors to 2 hex values
- Consistent interactive states across all controls
- Easier maintenance (change ColorIntensity once → all states update)

See docs/plans/2026-02-05-design-system-refactor-design.md for full design."
```

**Step 3: Push to branch**

```bash
git push -u origin claude/refactor-design-system-3wcO2
```

Expected: Push succeeds to feature branch.

---

## Success Criteria Checklist

After completing all tasks, verify:

### Functional
- ✅ `ColorIntensity` Named Formula added with correct decimal values
- ✅ 4 state UDFs added: GetHoverColor, GetPressedColor, GetDisabledColor, GetFocusColor
- ✅ `ThemeColors` refactored to 2-color system with derived neutrals
- ✅ `GetThemeColor` updated to remove deprecated references
- ✅ Button patterns in Control-Patterns-Modern.fx use new UDFs
- ✅ No Power Fx syntax errors in App.Formulas

### Testing
- ✅ All 4 button types render correctly (Primary, Secondary, Outline, Accent)
- ✅ Hover states darken appropriately
- ✅ Pressed states darken more than hover
- ✅ Disabled states wash out (light, low opacity)
- ✅ Customer color change (Primary) updates all buttons automatically

### Documentation
- ✅ UDF-REFERENCE.md updated with 4 new state UDFs
- ✅ CLAUDE.md updated with design system summary
- ✅ Control-Patterns-Modern.fx has copy-paste-ready button patterns

### Git
- ✅ 10+ commits with clear messages
- ✅ All changes pushed to feature branch
- ✅ Branch ready for PR to main

---

## Troubleshooting

### Issue: ColorFade not working as expected

**Symptom:** Colors not darkening/lightening correctly

**Cause:** ColorFade values might be wrong format (integers instead of decimals)

**Solution:**
```powerfx
// WRONG:
ColorIntensity = { Hover: -20 };

// CORRECT:
ColorIntensity = { Hover: -0.20 };
```

Range: -1.0 (black) to 1.0 (white). Decimals required.

---

### Issue: GetThemeColor errors after refactor

**Symptom:** Controls using GetThemeColor("primarylight") show errors

**Cause:** Old color names removed from ThemeColors

**Solution:** Search codebase for deprecated references and update:
```powerfx
// OLD:
GetThemeColor("primarylight")

// NEW (Option 1 - use state UDF):
GetHoverColor(ThemeColors.Primary)

// NEW (Option 2 - direct reference):
ThemeColors.Primary
```

---

### Issue: Buttons too dark/too light on hover

**Symptom:** Hover intensity doesn't match design

**Solution:** Adjust ColorIntensity values:
```powerfx
// Lighter hover (15% instead of 20%):
ColorIntensity = { Hover: -0.15, ... };

// Darker hover (25% instead of 20%):
ColorIntensity = { Hover: -0.25, ... };
```

---

## Next Steps After Implementation

1. **Create Pull Request**
   - Use `gh pr create` with summary from Task 13
   - Reference design doc: `docs/plans/2026-02-05-design-system-refactor-design.md`
   - Request review from team

2. **Migration Guide for Existing Apps**
   - Create `docs/MIGRATION-DESIGN-SYSTEM.md` with step-by-step guide
   - Document breaking changes (removed color names)
   - Provide find/replace patterns

3. **Accessibility Audit**
   - Test contrast ratios with WebAIM Contrast Checker
   - Verify WCAG AA compliance for all button states
   - Document minimum lightness thresholds for Primary/Secondary

4. **Customer Onboarding Template**
   - Create `CUSTOMIZATION-GUIDE.md` for customers
   - Step-by-step: "Change these 2 hex values to match your brand"
   - Include color picker recommendations

---

## Estimated Time

| Task | Time |
|------|------|
| Tasks 1-5 (Add UDFs) | 15 min |
| Task 6 (Refactor ThemeColors) | 10 min |
| Task 7 (Update GetThemeColor) | 5 min |
| Task 8 (Update button patterns) | 10 min |
| Tasks 9-10 (Documentation) | 15 min |
| Task 11 (Visual testing) | 15 min |
| Tasks 12-13 (Cleanup, summary) | 10 min |
| **Total** | **80 min (~1.5 hours)** |

---

## References

- Design Document: `docs/plans/2026-02-05-design-system-refactor-design.md`
- ColorFade Documentation: https://learn.microsoft.com/en-us/power-platform/power-fx/reference/function-colors
- Named Formulas: https://www.microsoft.com/en-us/power-platform/blog/power-apps/power-fx-introducing-named-formulas/
- UDFs: https://www.microsoft.com/en-us/power-platform/blog/power-apps/power-apps-user-defined-functions-ga/
