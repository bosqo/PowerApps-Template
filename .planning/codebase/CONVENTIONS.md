# Coding Conventions

**Analysis Date:** 2026-01-18

## Naming Patterns

**Files:**
- Power Fx source files: `App-{Purpose}-{Variant}.fx` (e.g., `App-Formulas-Template.fx`, `App-OnStart-Minimal.fx`)
- Pattern/example files: `{Component}-Patterns-{Variant}.fx` (e.g., `Control-Patterns-Modern.fx`, `Datasource-Filter-Patterns.fx`)
- PowerShell scripts: `deploy-{target}.ps1` or `{action}-{target}.bat` (e.g., `deploy-solution.ps1`, `deploy-dev.bat`)
- Documentation: UPPERCASE.md for guides (e.g., `DEPLOYMENT-INSTRUCTIONS.md`, `QUICK-START.md`), lowercase with hyphens for technical docs in `docs/` (e.g., `docs/App-Formulas-Design.md`)

**Functions (Power Fx UDFs):**
- PascalCase with verb prefix: `HasRole()`, `GetUserScope()`, `CanAccessRecord()`, `FormatDateShort()`
- Behavior functions (Void return): `NotifySuccess()`, `NotifyError()`, `NotifyPermissionDenied()`
- Boolean check functions: Start with `Has`, `Can`, or `Is` (e.g., `HasPermission()`, `CanEditRecord()`, `IsValidEmail()`)
- Get/retrieve functions: Start with `Get` (e.g., `GetThemeColor()`, `GetTotalPages()`)
- Format functions: Start with `Format` (e.g., `FormatCurrency()`, `FormatDateLong()`)

**Named Formulas:**
- PascalCase for static/computed values: `ThemeColors`, `UserProfile`, `DateRanges`, `AppConfig`
- Record structures for grouping: `UserRoles`, `UserPermissions`, `FeatureFlags`, `DefaultFilters`

**State Variables:**
- PascalCase: `AppState`, `ActiveFilters`, `UIState`, `DashboardCounts`
- Grouped as records with nested properties: `AppState.IsLoading`, `ActiveFilters.SearchTerm`, `UIState.SelectedItem`

**Collections:**
- PascalCase with prefix: `Cached{EntityPlural}` for lookup data (e.g., `CachedDepartments`, `CachedCategories`, `CachedStatuses`)
- User-scoped: `My{EntityPlural}` (e.g., `MyRecentItems`, `MyPendingTasks`)

**Controls:**
- Format: `{Type}_{Name}` (e.g., `Gallery_Orders`, `Button_Submit`, `Label_Status`, `TextInput_Search`)
- Singular names for single-value controls, plural for collections

## Code Style

**Formatting:**
- Indentation: 4 spaces (no tabs)
- Line comments: `//` with space after slashes
- Block comments: Multi-line `/* */` for long explanations or commented-out code examples
- Section headers: Use ASCII art separators with `//` for major sections

**Section Separators (Power Fx):**
```powerfx
// ============================================================
// SECTION TITLE
// ============================================================
```

**Sub-section Separators:**
```powerfx
// -----------------------------------------------------------
// Sub-section Title
// -----------------------------------------------------------
```

**Linting:**
- No automated linter for Power Fx
- PowerShell scripts follow standard PSScriptAnalyzer recommendations (validated manually)

**String Formatting:**
- Power Fx: Use `Text()` function for number formatting, `&` for concatenation
- German locale: Date format `"d.m.yyyy"`, time format `"hh:mm"`, combined `"d.m.yyyy hh:mm"`
- Color values: Always use `ColorValue("#RRGGBB")` with 6-digit hex codes

## Import Organization

**Not applicable** - Power Fx does not have import/module system

**Data Source Connections:**
- Must be manually connected in Power Apps Studio before use
- Required connections documented in file headers (e.g., lines 19-24 in `src/App-OnStart-Minimal.fx`)
- Standard connectors: `Office365Users`, `Office365Groups`, Dataverse tables, SharePoint lists

## Error Handling

**Patterns:**
- **Validation before action**: Check permissions/conditions with `If()` before executing operations
- **Notify on errors**: Use `NotifyError()` or `Notify(..., NotificationType.Error)` for user feedback
- **Permission-guarded actions**: Wrap dangerous operations in `If(HasPermission(...), [action], NotifyPermissionDenied(...))`
- **Graceful degradation**: Use `Coalesce()` for null/blank handling, `IsBlank()` checks before operations
- **State tracking**: Set `AppState.LastError`, `AppState.ErrorMessage` for debugging

**Example Pattern:**
```powerfx
// Button_Delete.OnSelect
If(
    HasPermission("Delete") && CanDeleteRecord(Gallery.Selected.Owner.Email),
    Remove(Items, Gallery.Selected);
    NotifyActionCompleted("Delete", Gallery.Selected.Name),
    NotifyPermissionDenied("delete this item")
)
```

**No try-catch** - Power Fx does not support exception handling. Use defensive coding instead.

## Logging

**Framework:** `Notify()` function (built-in Power Apps notification system)

**Patterns:**
- Success: `NotifySuccess(message)` or `Notify(message, NotificationType.Success)`
- Errors: `NotifyError(message)` or `Notify(message, NotificationType.Error)`
- Warnings: `NotifyWarning(message)` or `Notify(message, NotificationType.Warning)`
- Info: `NotifyInfo(message)` or `Notify(message, NotificationType.Information)`
- Action tracking: Use `AppState.LastAction` and `AppState.LastRefresh` for state history

**No console logging** - Power Apps does not have console access. Debug via Monitor tool in Power Apps Studio.

## Comments

**When to Comment:**
- **File headers**: Always include purpose, usage instructions, prerequisites (lines 1-16 in `src/App-Formulas-Template.fx`)
- **Configuration placeholders**: Mark required customization (lines 10-14 in `src/App-Formulas-Template.fx`)
- **Complex logic**: Explain timezone conversions, delegation workarounds, business rules
- **Section boundaries**: Use separator comments to organize large files into logical sections
- **Deprecation notices**: Mark legacy patterns with warnings (lines 6-24 in `src/Datasource-Filter-Patterns.fx`)

**What NOT to comment:**
- Self-explanatory function names (e.g., `HasRole("Admin")` doesn't need explanation)
- Simple assignments
- Standard Power Fx patterns

**JSDoc/TSDoc:**
- Not applicable for Power Fx
- PowerShell functions use standard PowerShell comment-based help with `param()` documentation

## Function Design

**Size:**
- UDFs: Single responsibility, typically 5-15 lines
- Complex UDFs with nested conditionals: Up to 40 lines (e.g., `ConvertUTCToCET()` at lines 642-652 in `src/App-Formulas-Template.fx`)
- Screen formulas: Break into multiple UDF calls rather than inline long formulas

**Parameters:**
- Explicit type annotations: `functionName(paramName: Type): ReturnType`
- Common types: `Text`, `Number`, `Boolean`, `Date`, `DateTime`, `Color`
- Record types: Use anonymous records `{ field: Type }` for structured inputs
- Default values: Use `Coalesce()` inside function body, not in signature

**Return Values:**
- Explicit return type annotation required for UDFs
- Boolean functions: Return `true`/`false` directly, no ternary
- Behavior functions: Must use `Void` return type and curly braces `{ statement; }`
- Text functions: Return empty string `""` for blank inputs, not `Blank()`

**Example:**
```powerfx
// Good: Explicit types, clear return
HasRole(roleName: Text): Boolean =
    Switch(
        Lower(roleName),
        "admin", UserRoles.IsAdmin,
        "manager", UserRoles.IsManager,
        false
    );

// Good: Behavior UDF with Void return
NotifySuccess(message: Text): Void = {
    Notify(message, NotificationType.Success);
};
```

## Module Design

**Not applicable** - Power Fx does not support modules. All code exists in three formula properties:
- `App.Formulas` - Named Formulas and UDFs (`src/App-Formulas-Template.fx`)
- `App.OnStart` - Initialization logic (`src/App-OnStart-Minimal.fx`)
- Control properties - Individual control formulas (patterns in `src/Control-Patterns-Modern.fx`)

**Exports:**
- Named Formulas are automatically available throughout the app
- UDFs are globally callable from any control
- State variables set via `Set()` are global

**Barrel Files:**
- Not applicable

## Power Fx Specific Conventions

**Delegation:**
- Use delegation-friendly functions on large data sources: `Filter()`, `Search()`, `Sort()`, `Lookup()`
- Avoid non-delegable operations: `CountRows()` on unfiltered tables, `FirstN()` beyond 500 without pagination
- Use `FirstN(Skip(...), pageSize)` pattern for pagination (lines 164-178 in `src/Control-Patterns-Modern.fx`)

**Timezone Handling (CRITICAL):**
- **NEVER** use `Today()` to compare with SharePoint DateTime fields (stored in UTC)
- **ALWAYS** use `GetCETToday()` for CET timezone comparisons
- Convert UTC to CET: `ConvertUTCToCET(utcDateTime)`
- Format UTC datetime: `FormatDateTimeCET(utcDateTime)`
- Lines 627-674 in `src/App-Formulas-Template.fx` contain canonical timezone functions

**With() Scoping:**
- Use `With()` to cache expensive operations (e.g., `Office365Users.MyProfileV2()` at line 157 in `src/App-Formulas-Template.fx`)
- Improves readability and performance for repeated calculations

**Reactive Updates:**
- Named Formulas auto-update when dependencies change (e.g., `DateRanges.Today` recalculates daily)
- State variables do not auto-update; use `Set()` or `Patch()` to modify

---

*Convention analysis: 2026-01-18*
