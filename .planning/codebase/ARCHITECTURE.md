# Architecture

**Analysis Date:** 2026-01-18

## Pattern Overview

**Overall:** Declarative-Functional with Modern Power Fx 2025

**Key Characteristics:**
- Separation of declarative (Named Formulas) from imperative (App.OnStart) logic
- User-Defined Functions (UDFs) for reusable business logic
- Role-based access control through Azure AD Groups
- Lazy evaluation for computed values

## Layers

**Declarative Layer (App.Formulas):**
- Purpose: Pure, reactive computations and reusable functions
- Location: `src/App-Formulas-Template.fx`
- Contains: Named Formulas (static + computed), 30+ UDFs for validation/formatting/permissions
- Depends on: Office365Users connector, User() function
- Used by: All controls, App.OnStart, screens

**Imperative Layer (App.OnStart):**
- Purpose: Mutable state initialization and data loading
- Location: `src/App-OnStart-Minimal.fx`
- Contains: State variables (AppState, ActiveFilters, UIState), Collection initialization
- Depends on: App.Formulas UDFs (CanAccessRecord, GetUserScope, etc.)
- Used by: Screen navigation, data refresh operations

**Presentation Layer (Controls):**
- Purpose: UI bindings and user interactions
- Location: `src/Control-Patterns-Modern.fx`
- Contains: Gallery patterns, Button handlers, Form configurations
- Depends on: Both declarative (ThemeColors, UserPermissions) and imperative layers (ActiveFilters, UIState)
- Used by: Canvas App screens

**Data Access Layer:**
- Purpose: SharePoint/Dataverse data source filtering
- Location: `src/Datasource-Filter-Patterns.fx` (legacy, deprecated)
- Contains: Reusable filter patterns for delegation
- Depends on: ActiveFilters state, permission UDFs
- Used by: Gallery.Items, Search controls, aggregations

**Documentation Layer:**
- Purpose: Architecture guidance and migration patterns
- Location: `docs/`
- Contains: Design documents, migration guides, deployment instructions
- Depends on: Nothing (reference material)
- Used by: Developers and Claude instances

## Data Flow

**User Authentication Flow:**

1. User logs in → User().Email, User().FullName available
2. App.Formulas.UserProfile → Office365Users.MyProfileV2() fetched once (lazy)
3. App.Formulas.UserRoles → Azure AD Group membership checked (lazy)
4. App.Formulas.UserPermissions → Derived from UserRoles (reactive)
5. App.OnStart.ActiveFilters → Initialized with GetUserScope() UDF
6. Gallery.Items → Filters applied using CanAccessRecord() UDF

**Data Modification Flow:**

1. User clicks Button → OnSelect checks HasPermission() UDF
2. If authorized → Patch()/Remove() executed on datasource
3. Success → NotifySuccess() UDF displays confirmation
4. State updated → Set(UIState, Patch(...))
5. Gallery auto-refreshes → Filter re-evaluates with new data

**Theme/Color Flow:**

1. ThemeColors Named Formula → Static color definitions (Fluent Design)
2. GetStatusColor() UDF → Maps status text to semantic colors
3. Control.Fill → Binds to GetStatusColor(ThisItem.Status)
4. Auto-updates when ThisItem.Status changes (reactive)

**State Management:**
- Immutable: Named Formulas (ThemeColors, DateRanges, UserPermissions)
- Mutable: Variables (AppState, ActiveFilters, UIState)
- Collections: Cached lookup data (CachedDepartments, MyRecentItems)

## Key Abstractions

**UserProfile:**
- Purpose: Centralized user identity and profile data
- Examples: `src/App-Formulas-Template.fx:155-182`
- Pattern: Named Formula with With() for API call caching

**UserRoles:**
- Purpose: Role determination from Azure AD Groups
- Examples: `src/App-Formulas-Template.fx:184-217`
- Pattern: Named Formula with Office365Groups.ListGroupMembers()

**UserPermissions:**
- Purpose: Derived permissions from roles (CRUD operations)
- Examples: `src/App-Formulas-Template.fx:219-236`
- Pattern: Named Formula with boolean expressions

**ThemeColors:**
- Purpose: Fluent Design color system
- Examples: `src/App-Formulas-Template.fx:25-55`
- Pattern: Named Formula with record of ColorValue()

**DateRanges:**
- Purpose: Reactive date calculations for filters
- Examples: `src/App-Formulas-Template.fx:120-147`
- Pattern: Named Formula with Today() dependencies

**Permission UDFs:**
- Purpose: Reusable access control checks
- Examples: `HasPermission()` at `src/App-Formulas-Template.fx:295-308`, `CanAccessRecord()` at `src/App-Formulas-Template.fx:375-378`
- Pattern: Switch() or boolean expressions returning Boolean

**Timezone UDFs:**
- Purpose: UTC to CET/CEST conversion (SharePoint compatibility)
- Examples: `ConvertUTCToCET()` at `src/App-Formulas-Template.fx:642-652`, `GetCETToday()` at `src/App-Formulas-Template.fx:672-673`
- Pattern: DateAdd() with DST detection logic

**Notification Behavior UDFs:**
- Purpose: Standardized user feedback
- Examples: `NotifySuccess()` at `src/App-Formulas-Template.fx:517-519`, `NotifyPermissionDenied()` at `src/App-Formulas-Template.fx:537-542`
- Pattern: Void return type with curly braces (Power Fx 2025 Behavior UDFs)

## Entry Points

**App.Formulas:**
- Location: `src/App-Formulas-Template.fx`
- Triggers: First access of any Named Formula or UDF call
- Responsibilities: Define pure functions, static configs, computed values

**App.OnStart:**
- Location: `src/App-OnStart-Minimal.fx`
- Triggers: App initialization
- Responsibilities: Set mutable state (AppState, ActiveFilters, UIState), ClearCollect lookup data, load user-scoped collections

**Screen.OnVisible:**
- Location: `src/Control-Patterns-Modern.fx:743-778`
- Triggers: Screen navigation
- Responsibilities: Set screen context, validate permissions, refresh screen-specific data

**Control.OnSelect:**
- Location: `src/Control-Patterns-Modern.fx:550-657`
- Triggers: User interactions (Button, Toggle)
- Responsibilities: Execute actions with permission checks, update filters, navigate screens

## Error Handling

**Strategy:** Defensive with fallback values and user notifications

**Patterns:**
- Coalesce() for null handling: `Coalesce(profile.department, "")` at `src/App-Formulas-Template.fx:166`
- IsBlank() checks before operations: `If(IsBlank(utcDateTime), Blank(), ...)` at `src/App-Formulas-Template.fx:644-651`
- Permission guards before actions: `If(HasPermission("Delete"), Remove(...), NotifyPermissionDenied(...))` at `src/Control-Patterns-Modern.fx:551-556`
- Validation UDFs for input: `IsValidEmail()` at `src/App-Formulas-Template.fx:564-572`
- Behavior UDFs for consistent notifications: `NotifyError()`, `NotifyPermissionDenied()`

## Cross-Cutting Concerns

**Logging:** Console-style with Notify() for user-facing messages, NotifyInfo() UDF for non-critical updates

**Validation:** Dedicated UDFs (IsValidEmail, IsOneOf, IsAlphanumeric, IsNotPastDate) in `src/App-Formulas-Template.fx:560-594`

**Authentication:** Office365Users connector for profile, Office365Groups for role determination, User() function for identity

**Timezone Handling:** Critical concern - SharePoint stores UTC, all date comparisons use GetCETToday() and ConvertUTCToCET() UDFs to handle CET/CEST (Germany timezone)

**Delegation:** Patterns use Filter() with simple conditions first, Search() for text, FirstN(Skip()) for pagination to stay within 2000 record limits

**Performance:** With() statements cache API calls, Concurrent() in App.OnStart for parallel data loading, Named Formulas for lazy evaluation

---

*Architecture analysis: 2026-01-18*
