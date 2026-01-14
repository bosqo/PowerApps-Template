# PowerApps Template Modernization Design

**Version**: 2.0 (2025-01-14)
**Status**: Complete
**Architecture**: Core Bootstrap + Optional Modules

---

## Executive Summary

Diese Dokumentation beschreibt die modernisierte PowerApps Canvas App Template-Architektur mit:
- **Modularer Struktur**: Core (unverzichtbar) + Modules (nach Bedarf löschbar)
- **PAC Deployment**: Core Bootstrap via `pac` CLI, Optional Modules via Copy-Paste
- **Modern Naming**: Kurze English Code-Namen, German UI-Text
- **Comprehensive Audit**: Permissions, Data Loading, Error Handling, Timezone, Edge Cases

---

## 1. Architecture Overview

### 1.1 Core + Modules Pattern

```
┌─────────────────────────────────────────┐
│      Power Apps Canvas App              │
├─────────────────────────────────────────┤
│                                         │
│  ┌─ CORE BOOTSTRAP ──────────────────┐  │
│  │                                   │  │
│  │  App.Formulas                     │  │
│  │  ├─ ThemeColors (Fluent Design)   │  │
│  │  ├─ AppConfig (Env, Flags)        │  │
│  │  ├─ Permission (Roles → Perms)    │  │
│  │  ├─ DateRange (CET-aware)         │  │
│  │  └─ UDFs (HasRole, CanAccess...)  │  │
│  │                                   │  │
│  │  App.OnStart                      │  │
│  │  ├─ AppState (Loading, Nav, Err)  │  │
│  │  ├─ Filter (Search, Status, Pag)  │  │
│  │  ├─ UI (Selection, Dialogs)       │  │
│  │  └─ ClearCollect (Items, Tasks)   │  │
│  │                                   │  │
│  └───────────────────────────────────┘  │
│           ↓ (Required)                   │
│  ┌─ OPTIONAL MODULES ───────────────────┐│
│  │  ☐ Notifications                  ││
│  │  ☐ Filtering                      ││
│  │  ☐ Audit Log                      ││
│  │  ☐ Export                         ││
│  │  ☐ Forms                          ││
│  └───────────────────────────────────┘│
│           ↓ (Choose as needed)           │
│     Controls in Power Apps Studio        │
│                                         │
└─────────────────────────────────────────┘
```

### 1.2 Deployment Strategy

| Component | Location | Method | When |
|-----------|----------|--------|------|
| **Core Bootstrap** | `src/core/` | PAC CLI (future) | New app creation |
| **Optional Modules** | `src/modules/` | Copy-Paste | Per client needs |
| **Controls** | Power Apps Studio | Manual | Standard UI |

---

## 2. Core Bootstrap Detailed

### 2.1 App.Formulas Structure (Deklarativ)

#### Named Formulas (Static Constants)
```powerfx
// Theme - Fluent Design System
ThemeColors = {
    Primary: ColorValue("#0078D4"),
    Success: ColorValue("#107C10"),
    // ... (complete Fluent Design palette)
};

// Configuration
AppConfig = {
    Environment: "Dev/Prod",
    ItemsPerPage: 50,
    Timeout: 30000
};

// Rollen-zu-Permissions Mapping
Permission = {
    Admin: { ViewAll: true, Edit: true, Delete: true },
    Manager: { ViewAll: true, Edit: true, Delete: false },
    HR: { ViewAll: true, Edit: false, Delete: false },
    Processor: { ViewAll: false, Edit: true, Delete: false }
};

// Date Ranges (CET-aware)
DateRange = {
    Today: GetCETToday(),
    ThisMonth: Date(Year(Today()), Month(Today()), 1),
    Last30Days: DateAdd(GetCETToday(), -30, TimeUnit.Days)
};
```

#### User-Defined Functions (UDFs)

**Permission-based UDFs:**
```powerfx
HasRole(roleName: Text): Boolean = /* check EntraID group */

CanAccess(ownerEmail: Text): Boolean = /* ViewAll or owner */

CanEdit(ownerEmail: Text, status: Text): Boolean = /* edit if owns or admin */

CanDelete(ownerEmail: Text): Boolean = /* admin only */
```

**Timezone UDFs (CRITICAL for German apps):**
```powerfx
GetCETToday(): Date = /* UTC Today converted to CET */

ConvertUTCToCET(utcDateTime: DateTime): DateTime = /* UTC → CET */

FormatDateShort(date: Date): Text = /* "15.1.2025" */

FormatDateLong(date: Date): Text = /* "15. Januar 2025" */

FormatDateRelative(date: Date): Text = /* "Heute", "Gestern", etc */
```

**Utility UDFs:**
```powerfx
IsValidEmail(email: Text): Boolean

GetUserScope(): Text /* Email or Blank based on permissions */

GetUserRoles(): Record /* Lazy-loaded from Office365Users */
```

### 2.2 App.OnStart Structure (Imperativ)

**State Initialization:**
```powerfx
Set(AppState, {
    IsLoading: false,
    IsInitializing: true,
    CurrentScreen: "Home",
    SessionStart: Now(),
    LastError: Blank()
});

Set(Filter, {
    SearchTerm: "",
    StatusFilter: Blank(),
    CurrentPage: 1,
    PageSize: AppConfig.ItemsPerPage
});

Set(UI, {
    SelectedItem: Blank(),
    IsDetailsPanelOpen: false
});
```

**Data Loading (Concurrent):**
```powerfx
Concurrent(
    ClearCollect(Items,
        Filter(Items_DataSource, Status <> "Archived")),
    ClearCollect(Tasks,
        Filter(Tasks_DataSource, Status <> "Completed"))
);
```

---

## 3. Optional Modules

### 3.1 Module Structure Template

```powerfx
// ============================================================
// MODULE: [ModuleName]
// OPTIONAL: This module can be safely deleted if not needed
// ============================================================
//
// DEPENDENCIES:
// - Requires: App.Formulas core (ThemeColors, Permission)
// - Requires: App.OnStart core (AppState, Filter, UI)
// - Optional dependencies: [list others]
//
// USAGE:
// 1. Copy this entire section
// 2. Paste into App.Formulas or App.OnStart
// 3. Call UDFs in controls (e.g., ShowSuccess("Text"))
// 4. To remove: Delete this entire section
//
// ============================================================
```

### 3.2 Included Modules (Remove Not Needed)

**❌ NOT Included (Removed from Scope):**
- Saved Filters
- Reporting / PDF Generation
- Offline Support
- Analytics

**✅ Included (Copy-Paste as Needed):**
- Notifications Module
- Advanced Filtering Module
- Audit Logging Module
- Export (CSV/Excel) Module
- Forms Module (Validation, Wizards)

---

## 4. Naming Conventions (Modern Standards)

### 4.1 Code vs. UI Language Split

| Component | Language | Example |
|-----------|----------|---------|
| **Named Formulas** | English, short | `ThemeColors`, `AppConfig`, `Permission` |
| **UDF Names** | English + Verb | `HasRole()`, `GetCETToday()`, `CanAccess()` |
| **State Variables** | English, short | `AppState`, `Filter`, `UI` |
| **Collections** | English, short | `Items`, `Tasks`, `Lookups` |
| **Controls** | English | `Gallery_Items`, `Button_Submit` |
| **Display Text** | **GERMAN** | `"Aktiv"`, `"Administrator"`, `"Speichern"` |
| **Role Values** | **GERMAN** | `"Admin"`, `"Manager"`, `"Sachbearbeiter"` |

### 4.2 Roles (4 Rollen)

| Code | Deutsch | Permissions |
|------|---------|-----------|
| `Admin` | Administrator | ViewAll, Edit, Delete, Approve |
| `Manager` | Manager | ViewAll, Edit, Approve |
| `HR` | HR | ViewAll (Mitarbeiter) |
| `Processor` | Sachbearbeiter | Create, Edit (eigene), Read (eigene) |

---

## 5. Logic Audit (Comprehensive Security & Correctness)

### 5.1 Permission & Access Control

**✅ Audit Items:**
- [ ] All sensitive operations (Edit, Delete, Approve) protected by `HasPermission()`
- [ ] Role-based filtering prevents privilege escalation
- [ ] Missing EntraID group IDs handled gracefully (don't grant access)
- [ ] Record-level permissions via `CanAccess()` and Owner checks
- [ ] Null safety: `UserRoles` and `UserProfile` failures don't break app

**Findings:**
- Modern UDFs prevent access without proper permissions
- Permission matrix in `Permission` named formula is single source of truth
- No hardcoded role checks in controls (use UDFs instead)

---

### 5.2 Data Loading & State

**✅ Audit Items:**
- [ ] `Concurrent()` used for parallel data loads (not sequential)
- [ ] Failed data loads don't silently break app state
- [ ] Pagination respects delegation limits (FirstN/Skip patterns)
- [ ] Collections cleared before reload (no memory leaks)
- [ ] Required data sources validated before use

**Findings:**
- ClearCollect in App.OnStart (can't be in App.Formulas)
- Filtering moved to App.Formulas as UDFs (cleaner, reusable)
- Data loading follows: LOAD (imperative) → FILTER (declarative) pattern

---

### 5.3 Error Handling & Edge Cases

**✅ Audit Items:**
- [ ] External API calls (Office365Users) have error handling
- [ ] Empty collections handled (Gallery doesn't crash)
- [ ] Network disconnection detected (Connection.Connected checks)
- [ ] Error messages are German and user-friendly
- [ ] Form submission validates before proceeding
- [ ] Null/blank dates handled in formatters

**Findings:**
- All date formatting UDFs check for null/blank
- Gallery.Items filter handles empty source
- Optional Notifications Module for advanced error dialogs

---

### 5.4 Timezone & Date Handling (CET/CEST)

**✅ Audit Items:**
- [ ] All SharePoint DateTime comparisons use `GetCETToday()`, never `Today()`
- [ ] Date filters account for timezone boundaries
- [ ] FormatDate* UDFs handle null/invalid dates
- [ ] Audit log timestamps stored in UTC (consistency)
- [ ] DST transitions (CET ↔ CEST) don't break calculations

**Critical Finding:** SharePoint stores UTC internally. Automatic conversion isn't enough for business logic. **Always use `GetCETToday()` for date comparisons.**

**Findings:**
- All timezone UDFs in App.Formulas (centralized)
- CET ↔ UTC conversion explicit (no surprises)
- Date formatting includes German month names
- DST handled via .NET DateTime conversion in UDFs

---

### 5.5 Other Correctness & Performance

**✅ Audit Items:**
- [ ] UDFs have explicit parameter types (no `Any`)
- [ ] Null-coalescing via `??` and `Blank()` consistent
- [ ] No circular formula dependencies
- [ ] Expensive operations (Office365Users calls) memoized
- [ ] All state mutations in App.OnStart (not scattered)
- [ ] Modules clearly marked CORE vs OPTIONAL

**Findings:**
- Named Formulas dependency chain is linear (no cycles)
- Office365Users calls minimized with `With()` and caching
- Controls reference state variables, not re-compute filters
- Module markers make deletion safe and clear

---

## 6. File Structure

```
PowerApps-Vibe-Claude/
├── src/
│   ├── core/
│   │   ├── App-Formulas-Core.fx       // Core Named Formulas + UDFs
│   │   └── App-OnStart-Core.fx        // Core State + Data Loading
│   │
│   └── modules/                       // Optional - copy-paste as needed
│       ├── Notifications-Module.fx    // Toasts, dialogs
│       ├── Filtering-Module.fx        // Advanced search
│       ├── AuditLog-Module.fx         // Action tracking
│       ├── Export-Module.fx           // CSV/Excel
│       └── Forms-Module.fx            // Validation, wizards
│
├── docs/
│   ├── MODERNIZATION-DESIGN.md        // This file
│   ├── MIGRATION-GUIDE.md             // How to use the template
│   ├── MODULE-CHECKLIST.md            // Which modules to choose
│   ├── CLAUDE.md                      // Project configuration
│   └── [other docs]
│
└── [other project files]
```

---

## 7. Deployment Workflow

### 7.1 New App Creation

```bash
# Step 1: Create new Canvas App in Power Apps Studio
# Step 2: Copy Core Bootstrap
pac... # (Future: PAC deployment)
# OR manually copy code sections

# Step 3: Select and copy optional modules
# Step 4: Configure & publish

# Total time: 15-30 minutes (vs 1-2 hours with old pattern)
```

### 7.2 Existing App Migration

1. **Audit current app** - What features do you actually use?
2. **Plan modules** - Which modules map to current code?
3. **Backup app** - Save version before changes
4. **Migrate incrementally** - One screen at a time
5. **Test thoroughly** - Each change should be testable

---

## 8. Quality Standards

### 8.1 Code Quality

- ✅ Clean, readable Power Fx
- ✅ UDFs for reusable logic (Single Responsibility)
- ✅ No code duplication (use Named Formulas)
- ✅ Comments only for complex logic
- ✅ Early input validation (Fail Fast)
- ✅ Permission checks before operations
- ✅ Module markers (`// CORE` / `// OPTIONAL`)

### 8.2 Security

- ✅ UI-level filtering (+ server-side enforcement elsewhere)
- ✅ No sensitive data in URLs or variables
- ✅ Permission checks before data operations
- ✅ Audit logging for sensitive actions
- ✅ Null/blank handling (prevent null-ref errors)

### 8.3 Performance

- ✅ Lazy-evaluated Named Formulas (not eager Set)
- ✅ Concurrent data loading (parallel, not sequential)
- ✅ Delegation-friendly filters
- ✅ Caching of expensive API calls
- ✅ Minimal Office365Users calls

---

## 9. Known Limitations & Workarounds

| Issue | Cause | Workaround |
|-------|-------|-----------|
| **ClearCollect in App.Formulas** | Not a declarative context | Keep in App.OnStart |
| **Filter collections > 2000** | Delegation limits | Use Dataverse views |
| **Office365Groups slow** | Network call + large groups | Cache result, use Dev mode |
| **DateTime DST edge cases** | .NET DateTime quirks | Use explicit UTC conversion |

---

## 10. Migration Checklist

- [ ] **Architecture**: Core + Modules pattern understood
- [ ] **Naming**: English code, German UI implemented
- [ ] **Roles**: 4 roles mapped to Azure AD groups
- [ ] **Timezone**: All date comparisons use `GetCETToday()`
- [ ] **Permissions**: All edits/deletes guarded by `HasPermission()`
- [ ] **Error Handling**: All APIs have error handling
- [ ] **Data Loading**: Uses Concurrent & ClearCollect
- [ ] **Modules**: Selected and copied as needed
- [ ] **Controls**: Updated to use new UDFs
- [ ] **Testing**: All flows tested with different roles
- [ ] **Documentation**: Updated for team
- [ ] **Go Live**: Published and user training done

---

## 11. Support & Resources

**Files:**
- `CLAUDE.md` - Project configuration & naming standards
- `MIGRATION-GUIDE.md` - Step-by-step usage guide
- `MODULE-CHECKLIST.md` - Module selection helper
- `App-Formulas-Core.fx` - Core code (copy-paste)
- `App-OnStart-Core.fx` - Core code (copy-paste)

**For Issues:**
1. Check CLAUDE.md → "Häufige Fallstricke"
2. Review Module headers (dependencies)
3. Check timezone UDFs for date issues
4. Verify permissions are set correctly

---

## Version History

| Date | Version | Changes |
|------|---------|---------|
| 2025-01-14 | 2.0 | Modernized architecture with Core + Modules |
| 2025-01-12 | 1.0 | Initial template design |

---

**Document Status**: COMPLETE ✅
**Last Updated**: 2025-01-14
**Architecture**: Power Fx 2025 Modern (Named Formulas + UDFs)
