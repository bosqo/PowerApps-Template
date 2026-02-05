# Claude Code Projekt-Konfiguration

**PowerApps Canvas App Template** | Power Fx 2025 | Production-Ready (45/45 Requirements) | Deutsch (CET, d.m.yyyy)

| Status | Architektur | Daten | UDFs | Performance |
|--------|------------|-------|------|-------------|
| ✅ Live | Deklarativ-Funktional | Dataverse/SharePoint | 35+ | App.OnStart <2s |

---

## Quick Start

### Source Files (4,131 lines Power Fx)

| File | Size | Purpose |
|------|------|---------|
| `src/App-Formulas-Template.fx` | 1,664 | Named Formulas + UDFs |
| `src/App-OnStart-Minimal.fx` | 952 | State variables + Initialization |
| `src/Control-Patterns-Modern.fx` | 1,515 | Control formulas (Gallery, Form, Toast) |

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

Modern approach replaces legacy `App.*` pattern (pre-2023):
- Lazy evaluation vs eager startup execution
- Auto-reactive vs manual refresh
- Named Formulas + UDFs vs copy-paste duplication

---

## Roles & Permissions (6 Roles)

| Role | Permissions |
|------|-------------|
| Admin | Full access (ViewAll, Approve, Delete) |
| GF (CEO) | ViewAll, Approve |
| Manager | ViewAll, Edit, Approve |
| HR | ViewAll (employees only) |
| Sachbearbeiter (Processor) | Create, Edit (own records) |
| User | Read (own records) |

**Setup:** Configure Azure AD group IDs in `App-Formulas-Template.fx:186-217`

### Permission UDFs

```powerfx
HasRole("Admin")                    // Check role
HasPermission("Delete")             // Check permission
HasAnyRole("Admin,Manager")         // One of several roles
CanAccessRecord(email)              // Record access
CanEditRecord(email, status)        // Edit with status check
CanDeleteRecord(email)              // Delete allowed
```

---

## 35+ UDFs Reference

**Full docs:** See `docs/reference/UDF-REFERENCE.md`

### Permission & Role (7)
| UDF | Returns | Use |
|-----|---------|-----|
| `HasPermission(name)` | Boolean | Validate permission (create/read/edit/delete/viewall/approve) |
| `HasRole(name)` | Boolean | Validate role (admin/gf/manager/hr/sachbearbeiter/user) |
| `HasAnyRole(names)` | Boolean | Comma-separated list: one required |
| `HasAllRoles(names)` | Boolean | All roles required |
| `GetRoleLabel()` | Text | Display label (German) |
| `GetRoleBadgeColor()` | Color | Theme color for badge |
| `GetRoleBadge()` | Text | Short badge text |

### Data Access (7)
| UDF | Returns | Use |
|-----|---------|-----|
| `GetUserScope()` | Text | User email or Blank() if ViewAll |
| `GetDepartmentScope()` | Text | Department or Blank() if Admin |
| `CanAccessRecord(email)` | Boolean | Owner-based access |
| `CanAccessDepartment(dept)` | Boolean | Department-based access |
| `CanAccessItem(email, dept)` | Boolean | Combined Owner + Department |
| `CanEditRecord(email, status)` | Boolean | Edit allowed (status-aware) |
| `CanDeleteRecord(email)` | Boolean | Delete allowed |

### Delegation-Safe Filtering (5)
| UDF | Use |
|-----|-----|
| `CanViewAllData()` | User has ViewAll |
| `MatchesSearchTerm(field, term)` | Text search (delegation-safe) |
| `MatchesStatusFilter(status)` | Status equality (delegation-safe) |
| `CanViewRecord(email)` | ViewAll OR Ownership |
| `FilteredGalleryData(my, status, search)` | Combined filter layer |

**Gallery formula:**
```powerfx
glr_Items.Items = FilteredGalleryData(
    tog_MyItemsOnly.Value,
    drp_StatusFilter.Selected.Value,
    txt_Search.Text
)
```

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

SharePoint/Dataverse limit queries to **2000 records**. Use delegation-safe patterns:

**Delegable operations:**
- `=` equality, `Search()`, `&&`/`||`, comparison operators
- Use `FirstN(Skip())` for pagination

**Non-delegable (avoid):**
- `CountRows()`, UDFs in `Filter()`, `in` operator

**Large dataset pagination:**
```powerfx
FirstN(
    Skip(
        FilteredGalleryData(...),
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
- `Cached*` - Lookup data (e.g., `CachedDepartments`)
- `My*` - User-scoped (e.g., `MyRecentItems`)
- `Filter*` - Filtered views (e.g., `FilteredOrders`)

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
| Delegation failures (>2000 records) | Non-delegable functions used | Use `Filter()` with simple conditions, `Search()` for text, `FirstN(Skip())` for pagination |
| Timezone bugs | `Today()` vs SharePoint UTC dates | Always use `GetCETToday()` |
| API timeouts | Redundant Office365 calls | Cache results in collections (session-scoped, 5-min TTL) |
| Empty roles | Azure AD groups not configured | Update `App-Formulas-Template.fx:186-217` |
| Flow timeouts | Flows break after 30 days | Use Child-Flows |
| License limits | API quota exceeded | Implement batch operations + throttling |

**Fixed Issues (Phase 1-4):** See `docs/` for notification UDFs, email validation, role limits, datetime fixes.

---

## Performance Best Practices

### Target: App.OnStart <2 Seconds

**Techniques:**
- Sequential critical path: User → Roles → Permissions
- Parallel background: `Concurrent()` for independent data
- API caching: Collections with 5-min TTL (100% cache-hit after first load)
- Error tolerance: Graceful fallback for non-critical errors

**Expected timing breakdown:**
```
Critical path (sequential):  500-800ms   (Office365 profile + roles)
Background (concurrent):    300-500ms   (Departments, Categories, Statuses, Priorities)
User-scoped data:           200-300ms   (Recent items, pending tasks)
Config + finalize:          <100ms

TOTAL: ~1050-1850ms (under 2000ms target)
```

**Monitor:** Power Apps Monitor (F12) → Network tab → Filter "OnStart"
- OnStart total: <2000ms ✅
- Office365Users calls: 1 (cold), 0 (warm) ✅
- Office365Groups calls: 6 (cold), 0 (warm) ✅

### Concurrent() for Parallel Loading

**Critical path (sequential):**
```powerfx
ClearCollect(CachedProfileCache, Office365Users.MyProfileV2());
Set(AppState, Patch(AppState, {UserRoles: UserRoles}));
Set(AppState, Patch(AppState, {UserPermissions: UserPermissions}));
```

**Background path (parallel):**
```powerfx
Concurrent(
  ClearCollect(CachedDepartments, Filter(Departments, Status = "Active")),
  ClearCollect(CachedCategories, Filter(Categories, Status = "Active")),
  ClearCollect(CachedStatuses, {...}),
  ClearCollect(CachedPriorities, {...})
);
```

**Improvement:** Parallel max(300, 200, 50) = 300ms vs sequential 500ms = ~60% faster.

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

- Write clean, readable Power Fx code
- Use UDFs for reusable logic (Single Responsibility)
- Avoid duplication → Named Formulas
- Comment only complex logic, not obvious code
- Validate inputs early (Fail Fast)
- Check permissions BEFORE actions

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
| **Code Size** | 4,131 lines Power Fx |
| **Localization** | German (CET timezone, d.m.yyyy format) |
| **Last Updated** | Phase 4 Complete (2025-02-05) |
| **Phases** | 4 complete (Code, Performance, Filtering, UX) |

---

## Project History

All phases (PLAN + SUMMARY) archived in `.planning/` and `_archive/planning/phases/`.

For historical context, see:
- `.planning/STATE.md` - Phase transitions, metrics, decisions
- `_archive/log/` - Audit reports, code reviews
