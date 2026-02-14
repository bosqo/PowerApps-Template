# Claude Code Projekt-Konfiguration

**PowerApps Canvas App Template** | Power Fx 2025 | Production-Ready (45/45 Requirements) | Deutsch (CET, d.m.yyyy)

| Status | Architektur | Daten | UDFs | Performance |
|--------|------------|-------|------|-------------|
| ✅ Live | Deklarativ-Funktional | Dataverse/SharePoint | 35+ | App.OnStart <2s |

---

## Quick Start

### Source Files (7,634 lines Power Fx)

| File | Size | Purpose |
|------|------|---------|
| `src/App-Formulas-Template.fx` | 1,664 | Named Formulas + UDFs |
| `src/App-OnStart-Minimal.fx` | 952 | State variables + Initialization |
| `src/Control-Patterns-Modern.fx` | 1,515 | Control formulas (Gallery, Form, Toast) |
| `src/Enum-Formulas.fx` | 3,503 | Enumeration tables (Colors, ErrorKinds, Icons) |

### Architecture

**App.Formulas (Declarative):**
- `ThemeColors` - Fluent Design palette
- `UserProfile`, `UserRoles`, `UserPermissions` - User context (lazy-loaded)
- 35+ UDFs for validation, formatting, dates, notifications, access control

**App.OnStart (Imperative):**
- `AppState` - Load state, navigation, errors
- `ActiveFilters` - User filters (search, status, page)
- `UIState` - Selections, dialogs, forms
- `Concurrent(ClearCollect(...))` - Parallel data loading

Modern approach replaces legacy patterns (pre-2023):
- Lazy evaluation vs eager startup execution
- Auto-reactive vs manual refresh
- Named Formulas + UDFs vs copy-paste duplication

---

## Power Fx Syntax Rules (Microsoft-Verified)

**Full reference:** `.claude/skills/powerfx-syntax/SKILL.md`

Before writing or modifying any Power Fx code, verify against these rules:

### Named Formula Syntax
```powerfx
// CORRECT: No type annotation, ends with semicolon
ThemeColors = { Primary: ColorValue("#0078D4") };
UserEmail = User().Email;

// WRONG: Type annotations on Named Formulas
MyValue: Text = "hello";        // This is NOT valid Named Formula syntax
MyFlag: Boolean = true;         // Use UDF syntax if you need typed declarations
```

### UDF Syntax
```powerfx
// CORRECT: FunctionName(Param: Type): ReturnType = Expression;
HasRole(roleName: Text): Boolean = ActiveRole = roleName;

// CORRECT: No-parameter UDF (empty parentheses REQUIRED)
CanViewAllData(): Boolean = UserPermissions.CanViewAll;

// CORRECT: Behavior UDF (Void + curly braces)
NotifySuccess(message: Text): Void = { Notify(message, NotificationType.Success) };

// WRONG: Function() syntax with As keyword
MyFunc: Function(x As Text): Boolean = !IsBlank(x);

// WRONG: ThisItem inside UDFs (pass values as parameters instead)
CheckStatus: Function(s As Text): Boolean = ThisItem.Status = s;
```

### Functions That Don't Exist in Power Fx
- `Ceiling()` -- use `RoundUp(value, 0)`
- `Search(textValue, term)` -- `Search()` takes a TABLE as first argument: `Search(Table, term, "Col1")`

### Delegation-Critical Rules
- **UDFs inside Filter() are NEVER delegable** regardless of content
- **`in` operator is NOT delegable** with SharePoint: use `Status = "A" || Status = "B"`
- **`IsBlank(Column)` is NOT delegable** with SharePoint: use `Column = Blank()`
- **`Search()` is NOT delegable** with SharePoint: use `StartsWith()` instead
- **`CountRows(Filter(...))` is NOT delegable** with SharePoint
- For >2000 records, write delegable logic **inline** in `Filter()`, not via UDFs

### Reserved Names
- `App` is a reserved system object -- never use `Set(App, {...})`

---

## Design System (2-Color Simplified)

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

---

## Roles & Permissions (6 Roles) — Central Matrix System

All role permissions are defined in **3 central tables** in `App-Formulas-Template.fx`.
To change permissions: edit the table. To add a role: add a row.

**Setup:** Configure Azure AD group IDs in `RoleConfig` in `App-Formulas-Template.fx`

### PermissionMatrix (CRUD + Special Permissions)

| Permission   | Admin | GF | Manager | HR | Sachbearbeiter | User |
|-------------|-------|-----|---------|-----|---------------|------|
| CanCreate    |  ✓    |     |    ✓    |     |      ✓        |      |
| CanRead      |  ✓    |  ✓  |    ✓    |  ✓  |      ✓        |  ✓   |
| CanEdit      |  ✓    |     |    ✓    |     |      ✓        |      |
| CanDelete    |  ✓    |     |         |     |               |      |
| CanViewAll   |  ✓    |  ✓  |    ✓    |  ✓  |               |      |
| CanApprove   |  ✓    |  ✓  |    ✓    |     |               |      |
| CanArchive   |  ✓    |     |    ✓    |     |               |      |
| CanExport    |  ✓    |  ✓  |    ✓    |  ✓  |               |      |

**Usage:** `UserPermissions = LookUp(PermissionMatrix, Role = ActiveRole)`

### GalleryVisibility (Who Sees What)

| Role           | All Records | Own Records | Dept Records | Archived |
|----------------|-------------|-------------|--------------|----------|
| Admin          |      ✓      |      ✓      |       ✓      |     ✓    |
| GF             |      ✓      |      ✓      |       ✓      |          |
| Manager        |      ✓      |      ✓      |       ✓      |     ✓    |
| HR             |      ✓      |      ✓      |              |          |
| Sachbearbeiter |             |      ✓      |       ✓      |          |
| User           |             |      ✓      |              |          |

**Usage:** `UserGalleryAccess = LookUp(GalleryVisibility, Role = ActiveRole)`

### RoleMetadata (Display Configuration)

| Role           | Priority | DisplayLabel       | BadgeText | Color    |
|----------------|----------|--------------------|-----------|----------|
| Admin          | 1        | Administrator      | Admin     | Red      |
| GF             | 2        | Geschäftsführung   | GF        | DarkBlue |
| Manager        | 3        | Manager            | MGR       | Blue     |
| HR             | 4        | Personalwesen      | HR        | Amber    |
| Sachbearbeiter | 5        | Sachbearbeiter     | SB        | Teal     |
| User           | 6        | Benutzer           | User      | Gray     |

### Adding a New Role

1. `RoleConfig` — Add `NewRoleGroupId: "your-guid"`
2. `PermissionMatrix` — Add one row with all permission booleans
3. `RoleMetadata` — Add one row with display properties
4. `GalleryVisibility` — Add one row with visibility flags
5. `ActiveRole` — Add priority check in the `If()` chain
6. `UserRoles` — Add `IsNewRole: ActiveRole = "NewRole"`
7. `HasRole()` — Add `"newrole", UserRoles.IsNewRole` case

### Adding a New Permission

1. `PermissionMatrix` — Add new column (e.g., `CanImport: true/false`) to every row
2. `HasPermission()` — Add `"import", UserPermissions.CanImport` case

### Permission UDFs

```powerfx
HasRole("Admin")                    // Check role
HasPermission("Delete")             // Check permission
HasAnyRole("Admin,Manager")         // One of several roles
CanAccessRecord(email)              // Record access (uses GalleryVisibility)
CanAccessDepartment(dept)           // Department access (uses GalleryVisibility)
CanSeeArchived()                    // Archived visibility (uses GalleryVisibility)
CanEditRecord(email, status)        // Edit with status check
CanDeleteRecord(email)              // Delete allowed
```

**Design:** See `docs/plans/2026-02-13-role-permission-matrix-design.md`

---

## 35+ UDFs Reference

**Full docs:** See `docs/reference/UDF-REFERENCE.md`

### Permission & Role (7)
| UDF | Returns | Use |
|-----|---------|-----|
| `HasPermission(name)` | Boolean | Validate permission (create/read/edit/delete/viewall/approve/export) |
| `HasRole(name)` | Boolean | Validate role (admin/gf/manager/hr/sachbearbeiter/user) |
| `HasAnyRole(names)` | Boolean | Comma-separated list: one required |
| `HasAllRoles(names)` | Boolean | All roles required |
| `GetRoleLabel()` | Text | Display label from RoleMetadata (German) |
| `GetRoleBadgeColor()` | Color | Badge color from RoleMetadata |
| `GetRoleBadge()` | Text | Short badge text from RoleMetadata |

### Data Access (8)
| UDF | Returns | Use |
|-----|---------|-----|
| `GetUserScope()` | Text | User email or Blank() if ViewAll |
| `CanAccessRecord(email)` | Boolean | Owner-based access (uses GalleryVisibility) |
| `CanAccessDepartment(dept)` | Boolean | Department-based access (uses GalleryVisibility) |
| `CanSeeArchived()` | Boolean | Archived record visibility (uses GalleryVisibility) |
| `CanEditRecord(email, status)` | Boolean | Edit allowed (status-aware) |
| `CanDeleteRecord(email)` | Boolean | Delete allowed |
| `CanViewAllData()` | Boolean | Can see all records (delegation helper) |
| `CanViewRecord(ownerEmail)` | Boolean | Combined view check (delegation helper) |

### Filtering UDFs (5)
| UDF | Use |
|-----|-----|
| `CanViewAllData()` | User can see all records (uses GalleryVisibility.SeeAllRecords) |
| `CanSeeArchived()` | User can see archived records (uses GalleryVisibility.SeeArchived) |
| `MatchesSearchTerm(field, term)` | StartsWith text match (NOT delegable in Filter) |
| `MatchesStatusFilter(recordStatus, filterValue)` | Status equality check (NOT delegable in Filter) |
| `CanViewRecord(ownerEmail)` | ViewAll OR ownership check (NOT delegable in Filter) |

**DELEGATION WARNING:** These UDFs are NOT delegable when used inside `Filter()`.
For datasets >2000 records, use inline delegable expressions directly in Gallery.Items.

**Gallery formula (role-based visibility, <2000 records):**
```powerfx
glr_Items.Items = Filter(
    Items,
    CanAccessRecord(Owner.Email),
    If(!CanSeeArchived(), Status <> "Archived", true),
    MatchesStatusFilter(Status, ActiveFilters.SelectedStatus)
)
```

**Gallery formula (>2000 records, delegable):**
```powerfx
glr_Items.Items = Filter(
    Items,
    (IsBlank(drp_StatusFilter.Selected.Value) || Status = drp_StatusFilter.Selected.Value) &&
    (UserGalleryAccess.SeeAllRecords || Owner.Email = User().Email) &&
    StartsWith(Title, txt_Search.Text)
)
```

---

## Reactive Filter Pattern (Named Formulas)

**Pattern:** Dropdown changes → ActiveFilters state → FilteredItems recalculates → Gallery refreshes

**Architecture:**
```powerfx
// Layer 1: Base data (permission-filtered via GalleryVisibility matrix)
UserScopedItems = If(UserGalleryAccess.SeeAllRecords, Items, Filter(Items, Owner.Email = User().Email));

// Layer 2: Dynamic filter (reactive)
FilteredItems = Filter(
    UserScopedItems,
    (IsBlank(ActiveFilters.Status) || Status = ActiveFilters.Status) &&
    (IsBlank(ActiveFilters.Department) || Department = ActiveFilters.Department)
);

// Layer 3: UI binding
glr_Items.Items = FilteredItems  // Auto-refreshes when FilteredItems changes
```

**Dropdown setup:**
```powerfx
// Status dropdown OnChange
drp_Status.OnChange = Set(ActiveFilters, Patch(ActiveFilters, {Status: Self.Selected.Value}));

// Gallery items (no ClearCollect needed)
glr_Items.Items = FilteredItems
```

**Benefits:**
- ✅ Zero manual ClearCollect calls
- ✅ Instant reactivity (no "Apply Filters" button)
- ✅ Delegation-safe (all inline expressions)
- ✅ Single source of truth (FilteredItems formula)

**Reference:** See `docs/plans/2026-02-13-reactive-filter-system-design.md`

---

### Validation (7)
| UDF | Use |
|-----|-----|
| `IsValidEmail(text)` | Email (20+ rules) |
| `IsNotPastDate(date)` | Not in past |
| `IsDateInRange(date, start, end)` | Within range |
| `IsAlphanumeric(text)` | Letters + numbers only |
| `IsOneOf(value, options)` | Value in comma-separated list |
| `HasMaxLength(text, max)` | Under max length |
| `IsBlank(value)` | Empty/null |

### Entry Validation System (7 UDFs + Named Formulas)
| UDF | Use |
|-----|-----|
| `ValidateRule(value, rule, ruleParam, fieldLabel)` | Validate value against a named rule (error text or blank) |
| `ValidateRequired(value, fieldLabel)` | Check required field (error text or blank) |
| `ValidateField(value, isRequired, rule, ruleParam, fieldLabel)` | Full field validation (required + rule) |
| `GetFieldError(fieldName, fieldValue, registry)` | Look up field in registry and validate |
| `IsFormValid_NewItem()` | Check all NewItem form fields are valid |
| `GetFormErrors_NewItem()` | Collect all NewItem errors into summary text |
| `ResetForm_NewItem()` | Reset FormState, FormTouched, FormSubmitAttempted |

**Named Formulas:** `Error_NewItem_[Field]` (per-field auto-reactive error), `IsValid_NewItem` (form-level validity)
**State Variables:** `FormState_NewItem`, `FormTouched_NewItem`, `FormSubmitAttempted_NewItem`
**Rules:** `none`, `email`, `notpastdate`, `alphanumeric`, `maxlength`, `minlength`, `oneof`
**Design:** `docs/plans/2026-02-14-entry-validation-system-design.md`

### Notifications (7)
| UDF | Type | Auto-Dismiss |
|-----|------|--------------|
| `NotifySuccess(msg)` | Success | 5s |
| `NotifyError(msg)` | Error | Manual (X button) |
| `NotifyWarning(msg)` | Warning | 5s |
| `NotifyInfo(msg)` | Info | 5s |
| `NotifyPermissionDenied(action)` | Error | Manual |
| `NotifyActionCompleted(action, name)` | Success | 5s |
| `NotifyValidationError(field, msg)` | Warning | 5s |

**Setup:** Defined in `App-Formulas-Template.fx:950-1000+`. Never call `Notify()` directly.

### Theme & Color (8)
| UDF | Returns | Use |
|-----|---------|-----|
| `GetThemeColor(name)` | Color | Named color (primary, success, error, etc.) |
| `GetStatusColor(status)` | Color | Status color (active=green, pending=amber) |
| `GetPriorityColor(priority)` | Color | Priority color (critical=red, high=orange) |
| `GetHoverColor(baseColor)` | Color | Hover state (20% darker) |
| `GetPressedColor(baseColor)` | Color | Pressed state (30% darker) |
| `GetDisabledColor(baseColor)` | Color | Disabled state (60% lighter) |
| `GetFocusColor(baseColor)` | Color | Focus border (10% darker) |
| `GetStatusIcon(status)` | Text | Icon for status values |

**Usage:**
```powerfx
// Button with automatic states
btn_Submit.Fill = ThemeColors.Primary
btn_Submit.HoverFill = GetHoverColor(ThemeColors.Primary)
btn_Submit.PressedFill = GetPressedColor(ThemeColors.Primary)
```

### Date & Time (8)
| UDF | Returns | Example |
|-----|---------|---------|
| `GetCETToday()` | Date | Today (CET, not UTC) |
| `ConvertUTCToCET(datetime)` | DateTime | UTC → CET conversion |
| `GetCETOffset()` | Number | Current offset (-1 or -2) |
| `FormatDateShort(date)` | Text | "15.1.2025" |
| `FormatDateLong(date)` | Text | "15. Januar 2025" |
| `FormatDateRelative(date)` | Text | "Heute", "Gestern", "vor 3 Tagen" |
| `FormatDateTimeCET(datetime)` | Text | "15.1.2025 14:30" |
| `FormatTime(datetime)` | Text | "14:30" |

### Text & Numbers (3)
| UDF | Use |
|-----|-----|
| `FormatCurrency(amount)` | "1.234,56 €" |
| `FormatNumber(value)` | "1.234" (thousands separator) |
| `Slugify(text)` | URL-friendly text |

---

## Timezones & Localization (CRITICAL)

SharePoint stores all DateTime fields in **UTC**. Always use:

```powerfx
// ❌ WRONG: Never compare SharePoint dates with Today()
If(ThisItem.'Due Date' < Today(), "Overdue", "OK")

// ✅ CORRECT: Use GetCETToday()
If(ThisItem.'Due Date' < GetCETToday(), "Überfällig", "OK")

// Convert UTC to CET
FormatDateTimeCET(ThisItem.'Modified')  // "15.1.2025 14:30"
ConvertUTCToCET(ThisItem.'Created On')
```

---

## Delegation Patterns (>2000 Records)

SharePoint/Dataverse limit queries to **2000 records** (default 500, configurable up to 2000).

**Delegable with SharePoint:**
- `=`, `<>`, `<`, `>`, `<=`, `>=` operators
- `&&` (And), `||` (Or)
- `StartsWith()` (text fields only)
- `Filter()`, `LookUp()`, `Sort()`, `SortByColumns()`, `First()`

**NOT delegable with SharePoint (avoid for large datasets):**
- `Search()` -- use `StartsWith()` instead
- `CountRows()` on filtered data
- `in` operator -- use `Status = "A" || Status = "B"` instead
- `IsBlank(Column)` -- use `Column = Blank()` instead
- `Not` (!) operator
- **Any UDF inside Filter()** -- UDFs are never delegated
- `Trim`, `Len`, `Lower`, `Upper` inside Filter

**Large dataset pagination:**
```powerfx
// Use inline delegable expressions, not UDFs
FirstN(
    Skip(
        Sort(
            Filter(Items,
                (IsBlank(statusFilter) || Status = statusFilter) &&
                (UserPermissions.CanViewAll || Owner.Email = User().Email)
            ),
            'Created On', SortOrder.Descending
        ),
        (AppState.CurrentPage - 1) * 50
    ),
    50
)
```

See `docs/performance/DELEGATION-PATTERNS.md` for details.

---

## Naming Conventions

### Power Platform

- **Solutions:** `[Publisher]_[ProjectName]_[Type]` (e.g., `contoso_CRM_Core`)
- **Tables:** PascalCase, singular (e.g., `Customer`, `OrderItem`)
- **Canvas Apps:** `[Area]_[Function]_App` (e.g., `Sales_OrderEntry_App`)
- **Flows:** `[App]-[Action]-[Trigger]` (e.g., `CRM-SendEmail-OnCreate`)

### Power Fx

**Named Formulas:** PascalCase (data, not actions)
- ✅ `ThemeColors`, `UserProfile`, `DateRanges`
- ❌ `getUserProfile`, `theme_colors`

**UDFs:** PascalCase with verb prefix
- `Has*`, `Can*`, `Is*` - Boolean checks
- `Get*` - Data queries
- `Format*` - Formatting
- `Notify*`, `Show*`, `Update*` - Actions

**State Variables:** PascalCase, no prefix
- ✅ `AppState`, `ActiveFilters`, `UIState`
- ❌ `varAppState`, `gActiveFilters`

**Collections:** Prefix + PascalCase
- ~~`Cached*`~~ - REMOVED: No caching in OnStart (data accessed via Named Formulas)
- ~~`My*`~~ - REMOVED: No cached user data (accessed directly via Named Formulas)
- `Filter*` - Filtered views (if needed for complex filtering)

**Controls:** Type prefix + name (3-char prefix)

| Prefix | Type | Examples |
|--------|------|----------|
| `glr_` | Gallery | `glr_Orders`, `glr_Items` |
| `btn_` | Button | `btn_Submit`, `btn_Delete` |
| `txt_` | TextInput | `txt_Search`, `txt_Email` |
| `lbl_` | Label | `lbl_Title`, `lbl_Error` |
| `drp_` | Dropdown | `drp_Status`, `drp_Category` |
| `form_` | Form | `form_EditItem`, `form_NewRecord` |
| `tog_` | Toggle | `tog_ActiveOnly`, `tog_ShowArchived` |
| `chk_` | Checkbox | `chk_Terms`, `chk_SelectAll` |
| `dat_` | DatePicker | `dat_StartDate`, `dat_DueDate` |
| `img_`, `ico_`, `cnt_` | Image, Icon, Container | Self-explanatory |

**Why:** Type instantly recognizable, consistent length for autocomplete, follows Power Fx conventions.

---

## Required Data Sources

Connect these before using App.OnStart:

1. **Departments** - Columns: `Name`, `Status`
2. **Categories** - Columns: `Name`, `Status`
3. **Items** - Columns: `Owner`, `Status`, `'Modified On'`
4. **Tasks** - Columns: `'Assigned To'`, `Status`, `'Due Date'`

---

## Common Pitfalls & Solutions

| Problem | Cause | Solution |
|---------|-------|----------|
| Delegation failures (>2000 records) | Non-delegable functions used | Write inline delegable expressions, not UDFs, in `Filter()` |
| UDF not delegated | UDF used inside Filter() | UDFs are **never** delegated. Write logic inline for >2000 records |
| `in` operator warning | `Status in ["A","B"]` with SharePoint | Use `Status = "A" \|\| Status = "B"` instead |
| `Search()` not delegated | SharePoint doesn't delegate Search | Use `StartsWith()` for text search on SharePoint |
| `Ceiling()` error | Function doesn't exist in Power Fx | Use `RoundUp(value, 0)` |
| Timezone bugs | `Today()` vs SharePoint UTC dates | Always use `GetCETToday()` for SharePoint DateTime fields |
| API timeouts | Redundant Office365 calls | Optimize queries, use Named Formulas (evaluated on-demand) |
| Empty roles | Azure AD groups not configured | Update `App-Formulas-Template.fx:293-299` |
| Flow timeouts | Flows break after 30 days | Use Child-Flows |
| License limits | API quota exceeded | Implement batch operations + throttling |

**Fixed Issues (Phase 1-4):** See `docs/` for notification UDFs, email validation, role limits, datetime fixes.

---

## Performance Best Practices

### Target: App.OnStart <2 Seconds (NO CACHING)

**Simplified approach:**
- No caching in App.OnStart
- All data loaded on-demand via Named Formulas
- State variables initialization only
- Error tolerance: Graceful fallback for non-critical errors

**Expected timing breakdown (NO CACHING):**
```
State initialization:  50-150ms   (AppState, ActiveFilters, UIState)
Finalization:          50ms       (Mark as initialized)
Notification stack:    100ms      (Initialize toast system)

TOTAL: ~200-300ms (well under 2000ms target)
```

**Monitor:** Power Apps Monitor (F12) → Network tab → Filter "OnStart"
- OnStart total: ~200-300ms ✅ (much faster without caching)
- No Office365 calls during OnStart (role checks in Named Formulas)

### On-Demand Data Loading

**All data accessed via Named Formulas:**
```powerfx
// ActiveRole Named Formula checks Entra ID groups on-demand
ActiveRole = IfError(
  If(
    !IsEmpty(Filter(...Office365Groups...)), "Admin",
    !IsEmpty(Filter(...Office365Groups...)), "Teamleitung",
    "User"
  ),
  "User"
)

// FilteredItems Named Formula loads data reactively
FilteredItems = Filter(
  UserScopedItems,
  (IsBlank(ActiveFilters.Status) || Status = ActiveFilters.Status)
)
```

**Benefits:**
- Simpler code (no caching logic)
- Always fresh data (no cache invalidation needed)
- Faster startup (no data loading in OnStart)

### Error Handling Strategy

**Critical errors** (block app): Profile loading failed
```powerfx
IfError(Office365Users.MyProfileV2(),
    ErrorMessage("Your profile could not be loaded. Check your network."))
```

**Non-critical errors** (silent fallback): Department lookup failed
```powerfx
IfError(Filter(Departments, Status="Active"), Table())  // Empty table fallback
```

**Message guidelines:**
- German language (user context)
- No error codes, no stack traces
- Include remediation hint (e.g., "Check network", "Try again later")

---

## Notification System

### Toast UDFs

All defined in `App-Formulas-Template.fx:950-1000+`. Call these UDFs only (never `Notify()` directly):

**Usage examples:**
```powerfx
// Form save
NotifySuccess("Record saved")
NotifyValidationError("Email", "Invalid format")

// Permissions
NotifyPermissionDenied("approve records")

// Actions
NotifyActionCompleted("Delete", "Item 1")
NotifyError("Save failed: " & Error.Message)
```

### Configuration

Customize in `ToastConfig` Named Formula (`App-Formulas-Template.fx:885`):

```powerfx
ToastConfig = {
    Width: 350,              // Toast width (px)
    SuccessDuration: 5000,   // Auto-dismiss (5s)
    ErrorDuration: 0         // Errors: manual dismiss only
}
```

### Toast Stack Management

1. Call `NotifySuccess()` → UDF calls `AddToast()` internally
2. `AddToast()` adds row to `NotificationStack` collection
3. UI container (`cnt_NotificationStack`) auto-renders
4. Auto-close or manual (X button)

See `Control-Patterns-Modern.fx` (Pattern 1.9) for container implementation.

---

## Deployment & ALM

### Scripts (Automated Pipeline)

```powershell
.\deploy-dev.bat YourSolutionName    # DEV → Git (daily)
.\deploy-test.bat YourSolutionName   # Git → TEST (weekly UAT)
.\deploy-prod.bat YourSolutionName   # Git → PROD (approval)
```

**Environments:**
- **DEV** - Development (unmanaged solutions)
- **TEST/UAT** - User testing (managed solutions)
- **PROD** - Production (managed only, no direct changes)

### Documentation

| Doc | Purpose |
|-----|---------|
| `docs/deployment/DEPLOYMENT-GUIDE.md` | Technical handbook + CI/CD setup |
| `docs/deployment/QUICK-START.md` | Template quick reference |

**Setup required:** PAC CLI authentication, environment selection. See DEPLOYMENT-GUIDE.md.

### PAC CLI Quick Reference

```bash
pac auth list                          # List environments
pac solution list                      # List solutions
pac canvas download --name "MyApp" --file MyApp.msapp
pac canvas unpack --msapp MyApp.msapp --sources ./src
pac canvas pack --sources ./src --msapp MyApp.msapp
```

---

## GitHub CLI (gh) Quick Reference

```bash
# Authentication
gh auth login
gh auth status

# Issues
gh issue list                          # Open issues
gh issue create --title "Bug" --label "bug,urgent"
gh issue view 42 --comments

# Pull Requests
gh pr create --title "Feature" --body "Description"
gh pr list --state all
gh pr merge 42 --squash --auto
gh pr view 42 --comments

# Branches
git checkout -b feature/my-feature
git push origin feature/my-feature
gh pr create --head feature/my-feature --base main
```

---

## Code Quality

### Principles

- **Verify against Microsoft docs before writing Power Fx** (see `.claude/skills/powerfx-syntax/SKILL.md`)
- Write clean, readable Power Fx code
- Use UDFs for reusable logic (Single Responsibility)
- Avoid duplication → Named Formulas
- Comment only complex logic, not obvious code
- Validate inputs early (Fail Fast)
- Check permissions BEFORE actions
- Never use functions that don't exist in Power Fx (`Ceiling`, `Floor`, etc.)
- Test delegation with Monitor tool for datasets >500 records

### Power Fx Best Practices (Microsoft-Compliant)

**1. Declarative > Imperative** (Microsoft's golden rule)

```powerfx
// ✅ GOOD: Declarative Named Formula
ThemeColors = { Primary: ColorValue("#0078D4"), Success: ColorValue("#107C10") };

// ✅ GOOD: Simple behavior UDF (only when needed)
NotifySuccess(message: Text): Void = AddToast(message, "Success", true, 5000);

// ❌ OVER-ENGINEERED: Unnecessary abstraction
_InternalHelper(msg, type) = With({...}, ...);
```

**2. Use `With()` only for computed values, not side effects**

```powerfx
// ✅ CORRECT: Computation
With({elapsed: Now() - ThisItem.Created}, If(elapsed < 1, elapsed / 1, 1))

// ❌ WRONG: Side effects in With()
With({data: GetData()}, Notify(...); AddToast(...))
```

**3. Eliminate magic numbers with named constants**

```powerfx
// ✅ GOOD
RevertCallbackIDs = { DELETE_UNDO: 0, ARCHIVE_UNDO: 1, CUSTOM: 2 };
HandleRevert(toastID, RevertCallbackIDs.DELETE_UNDO, data);

// ❌ BAD
HandleRevert(toastID, 0, data);  // What does 0 mean?
```

**4. Consolidate related state**

```powerfx
// ✅ GOOD: Single record
Set(ToastState, { Counter: 0, ToRemove: Blank(), AnimationStart: Blank() });

// ❌ BAD: Multiple variables
Set(NotificationCounter, 0); Set(ToastToRemove, Blank()); Set(ToastAnimationStart, Blank());
```

**Key resources:**
- [Power Fx Overview](https://learn.microsoft.com/en-us/power-platform/power-fx/overview)
- [Working with Formulas In-Depth](https://learn.microsoft.com/en-us/power-apps/maker/canvas-apps/working-with-formulas-in-depth)

---

## Documentation Structure

### Architecture & Design
- `docs/architecture/App-Formulas-Design.md` - Architecture, layers
- `docs/architecture/App-Formulas-README.md` - Named Formulas guide
- `docs/architecture/UI-DESIGN-REFERENCE.md` - Fluent Design

### Reference & Best Practices
- `docs/reference/UDF-REFERENCE.md` - **Complete API (all 35+ UDFs)**
- `docs/reference/POWER-PLATFORM-BEST-PRACTICES.md` - Platform best practices
- `docs/reference/DATAVERSE-ITEM-SCHEMA.md` - Table schema

### Performance & Filtering
- `docs/performance/DELEGATION-PATTERNS.md` - Delegation-safe queries
- `docs/performance/FILTER-COMPOSITION-GUIDE.md` - Filter composition
- `docs/performance/GALLERY-PERFORMANCE.md` - Pagination with FirstN/Skip

### Notifications
- `docs/notifications/TOAST-NOTIFICATION-GUIDE.md` - Toast setup
- `docs/notifications/TOAST-REVERT-DESIGN.md` - Undo/Revert architecture
- `docs/notifications/TOAST-REVERT-EXAMPLES.md` - Copy-paste examples

### Troubleshooting
- `docs/troubleshooting/TROUBLESHOOTING.md` - Symptom-based diagnosis

### Enumerations
- `docs/plans/2026-02-13-enum-formulas-design.md` - Enum component design
- `src/Enum-Formulas.fx` - fxWebColors (140), fxErrorKinds (31), fxIcons (178)

### Project Planning
- `.planning/PROJECT.md` - Purpose & value proposition
- `.planning/REQUIREMENTS.md` - 45 requirements (all complete)
- `.planning/ROADMAP.md` - 4-phase delivery plan
- `.planning/STATE.md` - Current status & metrics

---

## Claude Tools & Commands

### /reflect - Session Reflection

Analyzes how work was done (techniques, patterns, lessons learned).

```bash
/reflect                    # Full reflection
/reflect --focus tools      # Tool usage only
/reflect --focus patterns   # Problem-solving patterns
/reflect --name code-review # Custom filename
```

**Output:** `.claude/reflections/YYYY-MM-DD-slug.md` with:
- What Went Well / What Went Wrong
- Lessons Learned & Action Items
- Tips & Tricks for future sessions

### Claude Skills

Domain-specific guides (auto-loaded when relevant):
- `.claude/skills/powerfx-syntax/SKILL.md` - **Power Fx syntax reference (Microsoft-verified)**
- `.claude/skills/power-apps/SKILL.md` - Canvas/Model-Driven apps
- `.claude/skills/power-automate/SKILL.md` - Cloud flows
- `.claude/skills/dataverse/SKILL.md` - Entity/Table modeling
- `.claude/skills/power-platform/SKILL.md` - Cross-platform concepts
- `.claude/skills/error-learning/SKILL.md` - Error handling patterns

---

## Git Workflow

- **main** - Production branch (protected)
- **feature/** - New features (e.g., `feature/add-approval-flow`)
- **fix/** - Bug fixes (e.g., `fix/timezone-calculation`)

**Commit guidelines:**
- One commit = one logical change
- Meaningful messages (what + why, not how)
- No secrets (credentials, API keys)

---

## Key Facts

| Aspect | Detail |
|--------|--------|
| **Status** | ✅ Production-Ready (45/45 requirements) |
| **Code Size** | 7,634 lines Power Fx |
| **Localization** | German (CET timezone, d.m.yyyy format) |
| **Last Updated** | Phase 4 Complete (2025-02-05) |
| **Phases** | 4 complete (Code, Performance, Filtering, UX) |

---

## Project History

All phases (PLAN + SUMMARY) archived in `.planning/` and `_archive/planning/phases/`.

For historical context, see:
- `.planning/STATE.md` - Phase transitions, metrics, decisions
- `_archive/log/` - Audit reports, code reviews
