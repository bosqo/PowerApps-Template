# UI Design Reference

Complete reference of all design tokens and UI definitions used in this PowerApps Canvas App Template.

> **Source Files:**
> - `src/App-Formulas-Template.fx` - Named Formulas with design tokens
> - `src/Control-Patterns-Modern.fx` - Control implementation patterns

---

## Table of Contents

1. [Theme Colors](#1-theme-colors)
2. [Typography](#2-typography)
3. [Spacing Scale](#3-spacing-scale)
4. [Border Radius](#4-border-radius)
5. [Toast Notifications](#5-toast-notifications)
6. [Status Colors & Icons](#6-status-colors--icons)
7. [Priority Colors](#7-priority-colors)
8. [Role Colors](#8-role-colors)
9. [Control Naming Conventions](#9-control-naming-conventions)

---

## 1. Theme Colors

**Location:** `App-Formulas-Template.fx` (Lines 51-81)

### Brand Colors

| Token | Hex Value | RGB | Usage |
|-------|-----------|-----|-------|
| `ThemeColors.Primary` | `#0078D4` | `rgb(0, 120, 212)` | Primary actions, links, active states |
| `ThemeColors.PrimaryLight` | `#2B88D8` | `rgb(43, 136, 216)` | Hover states |
| `ThemeColors.PrimaryDark` | `#005A9E` | `rgb(0, 90, 158)` | Pressed states |
| `ThemeColors.Secondary` | `#50E6FF` | `rgb(80, 230, 255)` | Accent highlights |

### Semantic Colors

| Token | Hex Value | RGB | Usage |
|-------|-----------|-----|-------|
| `ThemeColors.Success` | `#107C10` | `rgb(16, 124, 16)` | Confirmations, completed |
| `ThemeColors.SuccessLight` | `#DFF6DD` | `rgb(223, 246, 221)` | Success backgrounds |
| `ThemeColors.Warning` | `#FFB900` | `rgb(255, 185, 0)` | Caution, pending |
| `ThemeColors.WarningLight` | `#FFF4CE` | `rgb(255, 244, 206)` | Warning backgrounds |
| `ThemeColors.Error` | `#D13438` | `rgb(209, 52, 56)` | Errors, destructive |
| `ThemeColors.ErrorLight` | `#FDE7E9` | `rgb(253, 231, 233)` | Error backgrounds |
| `ThemeColors.Info` | `#0078D4` | `rgb(0, 120, 212)` | Information messages |

### Neutral Colors

| Token | Hex Value | RGB | Usage |
|-------|-----------|-----|-------|
| `ThemeColors.Background` | `#F3F2F1` | `rgb(243, 242, 241)` | Page background |
| `ThemeColors.Surface` | `#FFFFFF` | `rgb(255, 255, 255)` | Cards, panels |
| `ThemeColors.SurfaceHover` | `#F5F5F5` | `rgb(245, 245, 245)` | Hover state on surfaces |
| `ThemeColors.Text` | `#201F1E` | `rgb(32, 31, 30)` | Primary text |
| `ThemeColors.TextSecondary` | `#605E5C` | `rgb(96, 94, 92)` | Secondary/muted text |
| `ThemeColors.TextDisabled` | `#A19F9D` | `rgb(161, 159, 157)` | Disabled text |
| `ThemeColors.Border` | `#EDEBE9` | `rgb(237, 235, 233)` | Standard borders |
| `ThemeColors.BorderStrong` | `#8A8886` | `rgb(138, 136, 134)` | Emphasized borders |
| `ThemeColors.Divider` | `#E1DFDD` | `rgb(225, 223, 221)` | Divider lines |

### Overlay Colors

| Token | Hex Value | Opacity | Usage |
|-------|-----------|---------|-------|
| `ThemeColors.Overlay` | `#000000` | 40% | Modal backdrop |
| `ThemeColors.Shadow` | `#000000` | 16% | Drop shadows |

---

## 2. Typography

**Location:** `App-Formulas-Template.fx` (Lines 84-101)

### Font Sizes

| Token | Value (px) | Usage |
|-------|------------|-------|
| `Typography.SizeXS` | 10 | Captions, fine print |
| `Typography.SizeSM` | 12 | Secondary text, labels |
| `Typography.SizeMD` | 14 | Body text (default) |
| `Typography.SizeLG` | 16 | Emphasized body |
| `Typography.SizeXL` | 20 | Subheadings |
| `Typography.Size2XL` | 24 | Headings |
| `Typography.Size3XL` | 32 | Page titles |

### Font Family

| Token | Value | Usage |
|-------|-------|-------|
| `Typography.Font` | `Font.'Segoe UI'` | All text elements |

### Line Heights

| Token | Value | Usage |
|-------|-------|-------|
| `Typography.LineHeightTight` | 1.25 | Headings, compact text |
| `Typography.LineHeightNormal` | 1.5 | Body text (default) |
| `Typography.LineHeightRelaxed` | 1.75 | Readable paragraphs |

---

## 3. Spacing Scale

**Location:** `App-Formulas-Template.fx` (Lines 104-111)

| Token | Value (px) | Usage |
|-------|------------|-------|
| `Spacing.XS` | 4 | Tight spacing, icon gaps |
| `Spacing.SM` | 8 | Small padding, form gaps |
| `Spacing.MD` | 16 | Standard padding |
| `Spacing.LG` | 24 | Section padding |
| `Spacing.XL` | 32 | Large section gaps |
| `Spacing.XXL` | 48 | Major section spacing |

### Common Patterns

| Context | Recommended Value |
|---------|-------------------|
| Container padding | `Spacing.SM` (8) to `Spacing.MD` (16) |
| Element spacing | `Spacing.SM` (8) to `Spacing.MD` (16) |
| Toast gap | 12 (between Spacing.SM and Spacing.MD) |
| Section spacing | `Spacing.LG` (24) to `Spacing.XL` (32) |

---

## 4. Border Radius

**Location:** `App-Formulas-Template.fx` (Lines 114-121)

| Token | Value (px) | Usage |
|-------|------------|-------|
| `BorderRadius.None` | 0 | Sharp corners |
| `BorderRadius.SM` | 2 | Subtle rounding |
| `BorderRadius.MD` | 4 | Standard controls (buttons, inputs, toasts) |
| `BorderRadius.LG` | 8 | Cards, panels |
| `BorderRadius.XL` | 12 | Prominent cards |
| `BorderRadius.Round` | 9999 | Pills, avatars, fully round |

### Fluent Design Alignment

| Element | Recommended Radius |
|---------|-------------------|
| Buttons | `BorderRadius.MD` (4) |
| Input fields | `BorderRadius.MD` (4) |
| Cards/Panels | `BorderRadius.LG` (8) |
| Toasts | `BorderRadius.MD` (4) |
| Avatars | `BorderRadius.Round` (9999) |
| Tags/Badges | `BorderRadius.SM` (2) |

---

## 5. Toast Notifications

**Location:** `App-Formulas-Template.fx` (Lines 909-961)

### Toast Configuration

| Property | Value | Description |
|----------|-------|-------------|
| `ToastConfig.Width` | 350 | Toast width in pixels |
| `ToastConfig.MaxWidth` | 400 | Maximum width for long messages |
| `ToastConfig.SuccessDuration` | 5000 | Auto-dismiss timeout (ms) |
| `ToastConfig.WarningDuration` | 5000 | Auto-dismiss timeout (ms) |
| `ToastConfig.InfoDuration` | 5000 | Auto-dismiss timeout (ms) |
| `ToastConfig.ErrorDuration` | 0 | Never auto-dismiss (user must close) |
| `ToastConfig.AnimationDuration` | 300 | Fade animation duration (ms) |

### Toast Type Styling

| Type | Background | Border | Icon | Icon Color |
|------|------------|--------|------|------------|
| Success | `ThemeColors.SuccessLight` | `ThemeColors.Success` | ✓ | `ThemeColors.Success` |
| Error | `ThemeColors.ErrorLight` | `ThemeColors.Error` | ✕ | `ThemeColors.Error` |
| Warning | `ThemeColors.WarningLight` | `ThemeColors.Warning` | ⚠ | `ThemeColors.Warning` |
| Info | `#E7F4FF` | `ThemeColors.Info` | ℹ | `ThemeColors.Info` |
| Default | `ThemeColors.Surface` | `ThemeColors.Border` | (none) | `ThemeColors.Text` |

### Toast Container Properties

| Property | Value | Description |
|----------|-------|-------------|
| Position X | `Parent.Width - 400` | Top-right corner |
| Position Y | 16 | Top padding |
| Width | 380 (when visible) | Container width |
| ZIndex | 1000 | Render on top |
| Padding | 8 | Container padding |
| Spacing | 12 | Gap between toasts |
| LayoutMode | `LayoutMode.Vertical` | Stack vertically |

### Individual Toast Tile

| Property | Value |
|----------|-------|
| Border Thickness | 2 |
| Corner Radius | 4 |
| Padding | 12 |
| Height | Auto (grows with content) |
| Width | `ToastConfig.Width` (350) |
| Icon Size | 24px |
| Message Font Size | 14px (`Typography.SizeMD`) |
| Close Button Size | 32 x 32 |

---

## 6. Status Colors & Icons

**Location:** `App-Formulas-Template.fx` (Lines 782-837)

### Status Color Mapping

| Status (EN) | Status (DE) | Color | Category |
|-------------|-------------|-------|----------|
| active | aktiv | `ThemeColors.Success` | Positive |
| open | offen | `ThemeColors.Success` | Positive |
| approved | genehmigt | `ThemeColors.Success` | Positive |
| completed | abgeschlossen | `ThemeColors.Success` | Positive |
| done | erledigt | `ThemeColors.Success` | Positive |
| published | veröffentlicht | `ThemeColors.Success` | Positive |
| resolved | gelöst | `ThemeColors.Success` | Positive |
| in progress | in bearbeitung | `ThemeColors.Primary` | In Progress |
| processing | verarbeitung | `ThemeColors.Primary` | In Progress |
| reviewing | prüfung | `ThemeColors.Primary` | In Progress |
| pending review | ausstehende prüfung | `ThemeColors.Primary` | In Progress |
| pending | ausstehend | `ThemeColors.Warning` | Warning |
| beantragt | beantragt | `ThemeColors.Warning` | Warning |
| on hold | pausiert | `ThemeColors.Warning` | Warning |
| waiting | wartend | `ThemeColors.Warning` | Warning |
| draft | entwurf | `ThemeColors.Warning` | Warning |
| submitted | eingereicht | `ThemeColors.Warning` | Warning |
| closed | geschlossen | `ThemeColors.TextSecondary` | Neutral |
| archived | archiviert | `ThemeColors.TextSecondary` | Neutral |
| inactive | inaktiv | `ThemeColors.TextSecondary` | Neutral |
| expired | abgelaufen | `ThemeColors.TextSecondary` | Neutral |
| cancelled | abgebrochen | `ThemeColors.Error` | Negative |
| rejected | abgelehnt | `ThemeColors.Error` | Negative |
| failed | fehlgeschlagen | `ThemeColors.Error` | Negative |
| error | fehler | `ThemeColors.Error` | Negative |
| overdue | überfällig | `ThemeColors.Error` | Negative |
| blocked | blockiert | `ThemeColors.Error` | Negative |

### Status Icons

| Status (DE) | Icon |
|-------------|------|
| active | `builtinicon:Cancel` |
| genehmigt | `builtinicon:Check` |
| in bearbeitung | `builtinicon:Clock` |
| beantragt | `builtinicon:Clock` |
| gespeichert | `builtinicon:Edit` |
| abgebrochen | `builtinicon:Cancel` |
| abgelehnt | `builtinicon:Cancel` |
| (default) | `builtinicon:CircleHollow` |

---

## 7. Priority Colors

**Location:** `App-Formulas-Template.fx` (Lines 840-849)

| Priority | Color | Hex Value |
|----------|-------|-----------|
| Critical | `ThemeColors.Error` | `#D13438` |
| High | Custom Orange-Red | `#D83B01` |
| Medium | `ThemeColors.Warning` | `#FFB900` |
| Low | `ThemeColors.Success` | `#107C10` |
| None | `ThemeColors.TextSecondary` | `#605E5C` |
| (default) | `ThemeColors.Text` | `#201F1E` |

---

## 8. Role Colors

**Location:** `App-Formulas-Template.fx` (Lines 492-500)

| Role | German | Color | Hex Value |
|------|--------|-------|-----------|
| Admin | Administrator | `ThemeColors.Error` | `#D13438` |
| GF | Geschäftsführer | `ThemeColors.PrimaryDark` | `#005A9E` |
| Manager | Manager | `ThemeColors.Primary` | `#0078D4` |
| HR | HR | `ThemeColors.Warning` | `#FFB900` |
| Sachbearbeiter | Sachbearbeiter | `ThemeColors.Info` | `#0078D4` |
| User | Benutzer | `ThemeColors.Success` | `#107C10` |

---

## 9. Control Naming Conventions

**Location:** `Control-Patterns-Modern.fx` (Lines 21-46)

### Control Prefixes

| Prefix | Control Type | Example |
|--------|--------------|---------|
| `glr_` | Gallery | `glr_Orders`, `glr_RecentItems` |
| `btn_` | Button | `btn_Submit`, `btn_Delete` |
| `lbl_` | Label | `lbl_Title`, `lbl_ErrorMessage` |
| `txt_` | TextInput | `txt_Search`, `txt_Email` |
| `img_` | Image | `img_Logo`, `img_Avatar` |
| `form_` | Form | `form_EditItem`, `form_NewRecord` |
| `drp_` | Dropdown | `drp_Status`, `drp_Category` |
| `ico_` | Icon | `ico_Delete`, `ico_Warning` |
| `cnt_` | Container | `cnt_Header`, `cnt_Sidebar` |
| `tog_` | Toggle | `tog_ActiveOnly`, `tog_ShowArchived` |
| `chk_` | Checkbox | `chk_Terms`, `chk_SelectAll` |
| `dat_` | DatePicker | `dat_StartDate`, `dat_DueDate` |

### Named Formula Conventions

| Type | Convention | Examples |
|------|------------|----------|
| Named Formulas | PascalCase (no verbs) | `ThemeColors`, `UserProfile`, `DateRanges` |
| Boolean UDFs | `Has*`, `Can*`, `Is*` | `HasRole()`, `CanAccessRecord()`, `IsValidEmail()` |
| Retrieval UDFs | `Get*` | `GetUserScope()`, `GetThemeColor()` |
| Format UDFs | `Format*` | `FormatDateShort()`, `FormatCurrency()` |
| Action UDFs | `Notify*`, `Show*`, `Update*` | `NotifySuccess()`, `ShowErrorDialog()` |

### State Variable Conventions

| Type | Convention | Examples |
|------|------------|----------|
| State Variables | PascalCase (no prefixes) | `AppState`, `ActiveFilters`, `UIState` |
| Cached Collections | `Cached*` | `CachedDepartments`, `CachedStatuses` |
| User Collections | `My*` | `MyRecentItems`, `MyPendingTasks` |
| Filtered Collections | `Filter*` | `FilteredOrders` |

---

## Quick Reference Card

### Most Used Tokens

```powerfx
// Colors
ThemeColors.Primary          // #0078D4 - Primary actions
ThemeColors.Success          // #107C10 - Success states
ThemeColors.Warning          // #FFB900 - Warning states
ThemeColors.Error            // #D13438 - Error states
ThemeColors.Text             // #201F1E - Primary text
ThemeColors.TextSecondary    // #605E5C - Secondary text
ThemeColors.Background       // #F3F2F1 - Page background
ThemeColors.Surface          // #FFFFFF - Card background

// Typography
Typography.SizeMD            // 14 - Body text
Typography.SizeLG            // 16 - Emphasized text
Typography.SizeXL            // 20 - Subheadings
Typography.Size2XL           // 24 - Headings

// Spacing
Spacing.SM                   // 8 - Small gaps
Spacing.MD                   // 16 - Standard padding
Spacing.LG                   // 24 - Section spacing

// Border Radius
BorderRadius.MD              // 4 - Standard controls
BorderRadius.LG              // 8 - Cards/panels
```

---

## Fluent Design Compliance

This template follows **Microsoft Fluent Design System** principles:

| Principle | Implementation |
|-----------|----------------|
| **Light** | Subtle shadows, light backgrounds |
| **Depth** | Z-index layering, shadow tokens |
| **Motion** | 300ms toast animations |
| **Material** | Translucent overlays (40% black) |
| **Scale** | Responsive spacing scale |

---

*Last updated: 2025-01-28*
