# Power Apps Canvas App Modernization Plan

## Modern Power Fx Architecture using UDFs and Named Formulas

**Version:** 2.0
**Date:** 2026-01-10
**Target:** Power Fx 2025 Best Practices

---

## Executive Summary

This plan modernizes the existing Canvas App template by migrating from imperative `App.OnStart` patterns to declarative **Named Formulas** and **User Defined Functions (UDFs)** within `App.Formulas`. This approach delivers:

- **Better Performance**: Lazy evaluation - formulas only compute when accessed
- **Automatic Refresh**: Dependencies tracked automatically
- **Reduced Duplication**: Centralized, reusable logic
- **Improved Maintainability**: Single source of truth for business logic
- **Faster App Load**: Minimal OnStart processing

---

## Current vs. Modern Architecture

### Current Architecture (Pre-2024)

```
App.OnStart
├── Set(App.User, {...})           // Imperative initialization
├── Set(App.User, Patch(...))      // Permission derivation
├── Set(Data.Filter, {...})        // Filter configuration
├── Set(App.Config, {...})         // Feature flags
├── Set(App.Themes, {...})         // Static colors
├── Set(App.State, {...})          // App state
└── ClearCollect(Data.Cache.*, ...) // Data loading

Controls
├── Gallery.Items = Filter(Table, If(IsBlank(Data.Filter.UserScope), true, ...))
├── Button.Visible = App.User.Permissions.CanDelete
└── Label.Text = Switch(true, App.User.Roles.IsAdmin, "Admin", ...)
```

**Problems:**
- All initialization runs at startup (slow load)
- Repeated filter logic across controls
- No reusability for complex patterns
- Manual refresh required for derived values

### Modern Architecture (2025)

```
App.Formulas (Named Formulas + UDFs)
├── // Named Formulas (auto-refreshing computed values)
│   ├── UserProfile = ...           // Lazy-loaded user data
│   ├── UserRoles = ...             // Computed from profile
│   ├── UserPermissions = ...       // Derived from roles
│   ├── FilterConfig = ...          // Reactive filter settings
│   ├── ThemeColors = ...           // Static theme definition
│   └── DateRanges = ...            // Computed date boundaries
│
└── // User Defined Functions (reusable logic)
    ├── ApplyUserScope(items) = ... // Reusable filter function
    ├── ApplyFilters(items, ...) = ... // Multi-filter function
    ├── HasPermission(name) = ...   // Permission check
    ├── GetRoleLabel() = ...        // Role display text
    └── GetThemeColor(name) = ...   // Theme color accessor

App.OnStart
└── // Minimal - only imperative actions
    ├── ClearCollect(Data.Cache.*, ...) // Data loading
    └── Set(App.State, {...})           // Mutable state only

Controls
├── Gallery.Items = ApplyUserScope(Orders)   // Clean, reusable
├── Button.Visible = HasPermission("Delete")
└── Label.Text = GetRoleLabel()
```

**Benefits:**
- Formulas computed only when accessed
- Automatic dependency tracking and refresh
- Single definition, multiple uses
- Cleaner control properties
- Faster initial load

---

## Implementation Plan

### Phase 1: Named Formulas for Static & Computed Values

#### 1.1 Theme Colors (Static Named Formulas)

```powerfx
// App.Formulas
ThemeColors = {
    Primary: ColorValue("#0078D4"),
    Secondary: ColorValue("#50E6FF"),
    Success: ColorValue("#107C10"),
    Warning: ColorValue("#FFB900"),
    Error: ColorValue("#D13438"),
    Background: ColorValue("#F3F2F1"),
    Surface: ColorValue("#FFFFFF"),
    Text: ColorValue("#201F1E"),
    TextSecondary: ColorValue("#605E5C"),
    Border: ColorValue("#EDEBE9")
};
```

#### 1.2 Date Ranges (Computed Named Formulas)

```powerfx
// App.Formulas
DateRanges = {
    Today: Today(),
    ThisWeek: DateAdd(Today(), -Weekday(Today()) + 1, TimeUnit.Days),
    ThisMonth: Date(Year(Today()), Month(Today()), 1),
    ThisQuarter: Date(Year(Today()), (RoundUp(Month(Today())/3, 0) - 1) * 3 + 1, 1),
    ThisYear: Date(Year(Today()), 1, 1),
    Last7Days: DateAdd(Today(), -7, TimeUnit.Days),
    Last30Days: DateAdd(Today(), -30, TimeUnit.Days),
    Last90Days: DateAdd(Today(), -90, TimeUnit.Days),
    Last365Days: DateAdd(Today(), -365, TimeUnit.Days)
};
```

#### 1.3 User Profile (Lazy-Loaded Named Formula)

```powerfx
// App.Formulas
// This is computed ONCE when first accessed, then cached
UserProfile = With(
    { profile: Office365Users.MyProfileV2() },
    {
        Email: User().Email,
        FullName: User().FullName,
        JobTitle: Coalesce(profile.jobTitle, ""),
        Department: Coalesce(profile.department, ""),
        OfficeLocation: Coalesce(profile.officeLocation, ""),
        MobilePhone: Coalesce(profile.mobilePhone, "")
    }
);
```

#### 1.4 User Roles (Computed from Profile)

```powerfx
// App.Formulas
// Automatically recomputes if UserProfile changes
UserRoles = {
    // Security Group Membership (configure group IDs)
    IsAdmin: CountRows(
        Filter(
            Office365Groups.ListGroupMembers("YOUR-ADMIN-GROUP-ID"),
            mail = User().Email
        )
    ) > 0,
    IsManager: CountRows(
        Filter(
            Office365Groups.ListGroupMembers("YOUR-MANAGER-GROUP-ID"),
            mail = User().Email
        )
    ) > 0,
    IsUser: true,

    // Domain-based roles
    IsCorporate: EndsWith(Lower(User().Email), "@yourcompany.com"),
    IsExternal: !EndsWith(Lower(User().Email), "@yourcompany.com"),

    // Department-based roles
    IsSales: UserProfile.Department = "Sales",
    IsFinance: UserProfile.Department = "Finance",
    IsIT: UserProfile.Department = "IT"
};
```

#### 1.5 User Permissions (Derived from Roles)

```powerfx
// App.Formulas
// Automatically recomputes when UserRoles changes
UserPermissions = {
    CanCreate: UserRoles.IsAdmin || UserRoles.IsManager,
    CanEdit: UserRoles.IsAdmin || UserRoles.IsManager || UserRoles.IsUser,
    CanDelete: UserRoles.IsAdmin,
    CanExport: UserRoles.IsAdmin || UserRoles.IsManager,
    CanViewAll: UserRoles.IsAdmin || UserRoles.IsManager,
    CanViewOwn: true,
    CanBulkOperations: UserRoles.IsAdmin,
    CanViewAuditLog: UserRoles.IsAdmin
};
```

#### 1.6 Dynamic Role Color (Computed)

```powerfx
// App.Formulas
RoleColor = Switch(
    true,
    UserRoles.IsAdmin, ThemeColors.Error,
    UserRoles.IsManager, ThemeColors.Primary,
    ThemeColors.Success
);
```

#### 1.7 Feature Flags (Computed from Roles + Environment)

```powerfx
// App.Formulas
FeatureFlags = {
    EnableAdvancedSearch: UserRoles.IsAdmin || UserRoles.IsManager,
    EnableBulkOperations: UserRoles.IsAdmin,
    EnableExport: UserPermissions.CanExport,
    EnableAuditLog: UserRoles.IsAdmin,
    ShowDebugInfo: Param("debug") = "true" && UserRoles.IsAdmin,
    IsProduction: Param("environment") = "prod"
};
```

#### 1.8 Filter Configuration (Reactive)

```powerfx
// App.Formulas
// Base filter configuration derived from permissions
DefaultFilterConfig = {
    UserScope: If(UserPermissions.CanViewAll, Blank(), User().Email),
    DepartmentScope: If(UserRoles.IsAdmin, Blank(), UserProfile.Department),
    ActiveOnly: true,
    IncludeArchived: false
};
```

---

### Phase 2: User Defined Functions (UDFs)

#### 2.1 Permission and Role Check Functions

```powerfx
// App.Formulas

// Check if user has a specific permission
HasPermission(permissionName: Text): Boolean =
    Switch(
        Lower(permissionName),
        "create", UserPermissions.CanCreate,
        "edit", UserPermissions.CanEdit,
        "delete", UserPermissions.CanDelete,
        "export", UserPermissions.CanExport,
        "viewall", UserPermissions.CanViewAll,
        "viewown", UserPermissions.CanViewOwn,
        "bulk", UserPermissions.CanBulkOperations,
        "audit", UserPermissions.CanViewAuditLog,
        false
    );

// Check if user has a specific role
HasRole(roleName: Text): Boolean =
    Switch(
        Lower(roleName),
        "admin", UserRoles.IsAdmin,
        "manager", UserRoles.IsManager,
        "user", UserRoles.IsUser,
        "sales", UserRoles.IsSales,
        "finance", UserRoles.IsFinance,
        "it", UserRoles.IsIT,
        "corporate", UserRoles.IsCorporate,
        "external", UserRoles.IsExternal,
        false
    );

// Get user's highest role as display label
GetRoleLabel(): Text =
    Switch(
        true,
        UserRoles.IsAdmin, "Administrator",
        UserRoles.IsManager, "Manager",
        UserRoles.IsSales, "Sales Representative",
        UserRoles.IsFinance, "Finance Analyst",
        UserRoles.IsIT, "IT Specialist",
        "User"
    );

// Get role badge color
GetRoleBadgeColor(): Color = RoleColor;
```

#### 2.2 Theme Accessor Functions

```powerfx
// App.Formulas

// Get theme color by name (type-safe alternative to direct access)
GetThemeColor(colorName: Text): Color =
    Switch(
        Lower(colorName),
        "primary", ThemeColors.Primary,
        "secondary", ThemeColors.Secondary,
        "success", ThemeColors.Success,
        "warning", ThemeColors.Warning,
        "error", ThemeColors.Error,
        "background", ThemeColors.Background,
        "surface", ThemeColors.Surface,
        "text", ThemeColors.Text,
        "textsecondary", ThemeColors.TextSecondary,
        "border", ThemeColors.Border,
        "role", RoleColor,
        ThemeColors.Primary // default
    );

// Get semantic color for status values
GetStatusColor(status: Text): Color =
    Switch(
        Lower(status),
        "active", ThemeColors.Success,
        "open", ThemeColors.Success,
        "in progress", ThemeColors.Primary,
        "pending", ThemeColors.Warning,
        "on hold", ThemeColors.Warning,
        "closed", ThemeColors.TextSecondary,
        "completed", ThemeColors.Success,
        "cancelled", ThemeColors.Error,
        "archived", ThemeColors.TextSecondary,
        "error", ThemeColors.Error,
        "failed", ThemeColors.Error,
        ThemeColors.Text // default
    );
```

#### 2.3 Date Range Functions

```powerfx
// App.Formulas

// Get date range start by name
GetDateRangeStart(rangeName: Text): Date =
    Switch(
        Lower(rangeName),
        "today", DateRanges.Today,
        "thisweek", DateRanges.ThisWeek,
        "thismonth", DateRanges.ThisMonth,
        "thisquarter", DateRanges.ThisQuarter,
        "thisyear", DateRanges.ThisYear,
        "last7days", DateRanges.Last7Days,
        "last30days", DateRanges.Last30Days,
        "last90days", DateRanges.Last90Days,
        "last365days", DateRanges.Last365Days,
        DateRanges.ThisMonth // default
    );

// Check if a date is within a named range
IsWithinDateRange(checkDate: Date, rangeName: Text): Boolean =
    checkDate >= GetDateRangeStart(rangeName) && checkDate <= Today();

// Format date for display
FormatDateRelative(inputDate: DateTime): Text =
    With(
        { daysDiff: DateDiff(DateValue(inputDate), Today(), TimeUnit.Days) },
        Switch(
            true,
            daysDiff = 0, "Today",
            daysDiff = 1, "Yesterday",
            daysDiff < 7, Text(daysDiff) & " days ago",
            daysDiff < 30, Text(RoundDown(daysDiff / 7, 0)) & " weeks ago",
            daysDiff < 365, Text(RoundDown(daysDiff / 30, 0)) & " months ago",
            Text(inputDate, "[$-en-US]mmm d, yyyy")
        )
    );
```

#### 2.4 Filter Scope Functions

```powerfx
// App.Formulas

// Get effective user scope for filtering
// Returns Blank() if user can see all, otherwise user's email
GetUserScope(): Text =
    If(UserPermissions.CanViewAll, Blank(), User().Email);

// Get effective department scope for filtering
GetDepartmentScope(): Text =
    If(UserRoles.IsAdmin, Blank(), UserProfile.Department);

// Check if user can access a specific record (by owner email)
CanAccessRecord(ownerEmail: Text): Boolean =
    UserPermissions.CanViewAll || Lower(ownerEmail) = Lower(User().Email);

// Check if user can access record in specific department
CanAccessDepartment(recordDepartment: Text): Boolean =
    UserRoles.IsAdmin || recordDepartment = UserProfile.Department;

// Combined access check
CanAccessItem(ownerEmail: Text, department: Text): Boolean =
    CanAccessRecord(ownerEmail) && CanAccessDepartment(department);
```

#### 2.5 Validation Functions

```powerfx
// App.Formulas

// Validate email format
IsValidEmail(email: Text): Boolean =
    !IsBlank(email) &&
    CountRows(Split(email, "@")) = 2 &&
    Len(Last(Split(email, "@")).Value) > 3;

// Check if text is within length limits
IsValidLength(input: Text, minLen: Number, maxLen: Number): Boolean =
    Len(input) >= minLen && Len(input) <= maxLen;

// Check if a value is in a set of allowed values
IsOneOf(value: Text, allowedValues: Text): Boolean =
    value in Split(allowedValues, ",");
```

#### 2.6 Notification Helper Functions

```powerfx
// App.Formulas

// Standardized success notification
NotifySuccess(message: Text): Boolean =
    Notify(message, NotificationType.Success);

// Standardized error notification
NotifyError(message: Text): Boolean =
    Notify(message, NotificationType.Error);

// Standardized warning notification
NotifyWarning(message: Text): Boolean =
    Notify(message, NotificationType.Warning);

// Standardized info notification
NotifyInfo(message: Text): Boolean =
    Notify(message, NotificationType.Information);

// Permission denied notification
NotifyPermissionDenied(action: Text): Boolean =
    Notify("Permission denied: You do not have access to " & action, NotificationType.Error);
```

---

### Phase 3: Minimal App.OnStart

After moving computed values to Named Formulas, `App.OnStart` becomes minimal:

```powerfx
// App.OnStart - Now minimal!

// 1. Initialize mutable application state
Set(AppState, {
    IsLoading: false,
    CurrentScreen: "Home",
    LastRefresh: Now(),
    SessionStart: Now(),
    IsOnline: Connection.Connected,
    LastError: Blank(),
    ShowError: false
});

// 2. Initialize mutable filter state (can be modified by user)
Set(ActiveFilters, {
    UserScope: GetUserScope(),
    DepartmentScope: GetDepartmentScope(),
    DateRangeStart: DateRanges.ThisMonth,
    DateRangeEnd: Today(),
    ActiveOnly: true,
    SearchTerm: "",
    StatusFilter: Blank(),
    CategoryFilter: Blank()
});

// 3. Load initial data cache (imperative - must be in OnStart)
ClearCollect(
    CachedDepartments,
    Filter(Departments, Status = "Active")
);

ClearCollect(
    CachedCategories,
    Filter(Categories, Status = "Active")
);

// 4. Load user-scoped data
ClearCollect(
    MyItems,
    Filter(
        Items,
        CanAccessRecord(Owner.Email),
        Status <> "Archived",
        'Created On' >= DateRanges.Last90Days
    )
);
```

---

### Phase 4: Modernized Control Patterns

#### Gallery with UDFs

**Before (repetitive inline logic):**
```powerfx
// Gallery.Items
Filter(
    Orders,
    If(IsBlank(Data.Filter.UserScope), true, Owner.Email = Data.Filter.UserScope),
    If(IsBlank(Data.Filter.DepartmentScope), true, Department = Data.Filter.DepartmentScope),
    If(Data.Filter.ActiveOnly, Status <> "Archived", true)
)
```

**After (clean UDF calls):**
```powerfx
// Gallery.Items
Filter(
    Orders,
    CanAccessItem(Owner.Email, Department),
    If(ActiveFilters.ActiveOnly, Status <> "Archived", true),
    IsWithinDateRange('Created On', "last90days")
)
```

#### Button Visibility

**Before:**
```powerfx
// Button.Visible
App.User.Permissions.CanDelete
```

**After:**
```powerfx
// Button.Visible
HasPermission("Delete")
```

#### Role Badge

**Before:**
```powerfx
// Label.Text
Switch(true,
    App.User.Roles.IsAdmin, "Administrator",
    App.User.Roles.IsManager, "Manager",
    "User"
)

// Label.Color
App.Themes.RoleColor
```

**After:**
```powerfx
// Label.Text
GetRoleLabel()

// Label.Color
GetRoleBadgeColor()
```

#### Status Indicator Color

**Before:**
```powerfx
// Icon.Color
Switch(ThisItem.Status,
    "Active", App.Themes.Success,
    "Pending", App.Themes.Warning,
    "Error", App.Themes.Error,
    App.Themes.Text
)
```

**After:**
```powerfx
// Icon.Color
GetStatusColor(ThisItem.Status)
```

#### Date Display

**Before:**
```powerfx
// Label.Text
Text(ThisItem.'Created On', "mmm d, yyyy")
```

**After:**
```powerfx
// Label.Text
FormatDateRelative(ThisItem.'Created On')
```

#### Permission-Guarded Actions

**Before:**
```powerfx
// Button.OnSelect
If(
    App.User.Permissions.CanDelete,
    Remove(Items, Gallery.Selected);
    Notify("Deleted successfully", NotificationType.Success),
    Notify("No permission to delete", NotificationType.Error)
)
```

**After:**
```powerfx
// Button.OnSelect
If(
    HasPermission("Delete"),
    Remove(Items, Gallery.Selected);
    NotifySuccess("Item deleted successfully"),
    NotifyPermissionDenied("delete items")
)
```

---

## Complete App.Formulas Template

```powerfx
// ============================================================
// APP.FORMULAS - Modern Power Fx 2025 Template
// Using Named Formulas and User Defined Functions
// ============================================================

// ============================================================
// SECTION 1: STATIC NAMED FORMULAS
// ============================================================

// Theme Colors (Fluent Design)
ThemeColors = {
    Primary: ColorValue("#0078D4"),
    Secondary: ColorValue("#50E6FF"),
    Success: ColorValue("#107C10"),
    Warning: ColorValue("#FFB900"),
    Error: ColorValue("#D13438"),
    Background: ColorValue("#F3F2F1"),
    Surface: ColorValue("#FFFFFF"),
    Text: ColorValue("#201F1E"),
    TextSecondary: ColorValue("#605E5C"),
    Border: ColorValue("#EDEBE9")
};

// Application Configuration
AppConfig = {
    Environment: If(Param("environment") = "prod", "Production", "Development"),
    ApiBaseUrl: If(Param("environment") = "prod",
        "https://api.company.com/prod",
        "https://api.company.com/dev"),
    ItemsPerPage: 50,
    MaxSearchResults: 500,
    CacheExpiryMinutes: 5
};

// ============================================================
// SECTION 2: COMPUTED NAMED FORMULAS (Auto-refresh)
// ============================================================

// Date Range Calculations
DateRanges = {
    Today: Today(),
    ThisWeek: DateAdd(Today(), -Weekday(Today()) + 1, TimeUnit.Days),
    ThisMonth: Date(Year(Today()), Month(Today()), 1),
    ThisQuarter: Date(Year(Today()), (RoundUp(Month(Today())/3, 0) - 1) * 3 + 1, 1),
    ThisYear: Date(Year(Today()), 1, 1),
    Last7Days: DateAdd(Today(), -7, TimeUnit.Days),
    Last30Days: DateAdd(Today(), -30, TimeUnit.Days),
    Last90Days: DateAdd(Today(), -90, TimeUnit.Days),
    Last365Days: DateAdd(Today(), -365, TimeUnit.Days)
};

// User Profile (Lazy-loaded, cached)
UserProfile = With(
    { profile: Office365Users.MyProfileV2() },
    {
        Email: User().Email,
        FullName: User().FullName,
        JobTitle: Coalesce(profile.jobTitle, ""),
        Department: Coalesce(profile.department, ""),
        OfficeLocation: Coalesce(profile.officeLocation, ""),
        MobilePhone: Coalesce(profile.mobilePhone, "")
    }
);

// User Roles (Computed from profile + security groups)
UserRoles = {
    IsAdmin: CountRows(Filter(Office365Groups.ListGroupMembers("YOUR-ADMIN-GROUP-ID"), mail = User().Email)) > 0,
    IsManager: CountRows(Filter(Office365Groups.ListGroupMembers("YOUR-MANAGER-GROUP-ID"), mail = User().Email)) > 0,
    IsUser: true,
    IsCorporate: EndsWith(Lower(User().Email), "@yourcompany.com"),
    IsExternal: !EndsWith(Lower(User().Email), "@yourcompany.com"),
    IsSales: UserProfile.Department = "Sales",
    IsFinance: UserProfile.Department = "Finance",
    IsIT: UserProfile.Department = "IT"
};

// User Permissions (Derived from roles)
UserPermissions = {
    CanCreate: UserRoles.IsAdmin || UserRoles.IsManager,
    CanEdit: UserRoles.IsAdmin || UserRoles.IsManager || UserRoles.IsUser,
    CanDelete: UserRoles.IsAdmin,
    CanExport: UserRoles.IsAdmin || UserRoles.IsManager,
    CanViewAll: UserRoles.IsAdmin || UserRoles.IsManager,
    CanViewOwn: true,
    CanBulkOperations: UserRoles.IsAdmin,
    CanViewAuditLog: UserRoles.IsAdmin
};

// Dynamic Role Color
RoleColor = Switch(true, UserRoles.IsAdmin, ThemeColors.Error, UserRoles.IsManager, ThemeColors.Primary, ThemeColors.Success);

// Feature Flags
FeatureFlags = {
    EnableAdvancedSearch: UserRoles.IsAdmin || UserRoles.IsManager,
    EnableBulkOperations: UserRoles.IsAdmin,
    EnableExport: UserPermissions.CanExport,
    EnableAuditLog: UserRoles.IsAdmin,
    ShowDebugInfo: Param("debug") = "true" && UserRoles.IsAdmin
};

// ============================================================
// SECTION 3: USER DEFINED FUNCTIONS
// ============================================================

// --- Permission & Role Functions ---

HasPermission(permissionName: Text): Boolean =
    Switch(Lower(permissionName),
        "create", UserPermissions.CanCreate,
        "edit", UserPermissions.CanEdit,
        "delete", UserPermissions.CanDelete,
        "export", UserPermissions.CanExport,
        "viewall", UserPermissions.CanViewAll,
        "viewown", UserPermissions.CanViewOwn,
        "bulk", UserPermissions.CanBulkOperations,
        "audit", UserPermissions.CanViewAuditLog,
        false
    );

HasRole(roleName: Text): Boolean =
    Switch(Lower(roleName),
        "admin", UserRoles.IsAdmin,
        "manager", UserRoles.IsManager,
        "user", UserRoles.IsUser,
        "sales", UserRoles.IsSales,
        "finance", UserRoles.IsFinance,
        "it", UserRoles.IsIT,
        false
    );

GetRoleLabel(): Text =
    Switch(true, UserRoles.IsAdmin, "Administrator", UserRoles.IsManager, "Manager", "User");

GetRoleBadgeColor(): Color = RoleColor;

// --- Access Control Functions ---

GetUserScope(): Text = If(UserPermissions.CanViewAll, Blank(), User().Email);

GetDepartmentScope(): Text = If(UserRoles.IsAdmin, Blank(), UserProfile.Department);

CanAccessRecord(ownerEmail: Text): Boolean =
    UserPermissions.CanViewAll || Lower(ownerEmail) = Lower(User().Email);

CanAccessDepartment(recordDepartment: Text): Boolean =
    UserRoles.IsAdmin || recordDepartment = UserProfile.Department;

CanAccessItem(ownerEmail: Text, department: Text): Boolean =
    CanAccessRecord(ownerEmail) && CanAccessDepartment(department);

// --- Theme Functions ---

GetThemeColor(colorName: Text): Color =
    Switch(Lower(colorName),
        "primary", ThemeColors.Primary,
        "secondary", ThemeColors.Secondary,
        "success", ThemeColors.Success,
        "warning", ThemeColors.Warning,
        "error", ThemeColors.Error,
        "background", ThemeColors.Background,
        "surface", ThemeColors.Surface,
        "text", ThemeColors.Text,
        "textsecondary", ThemeColors.TextSecondary,
        "border", ThemeColors.Border,
        "role", RoleColor,
        ThemeColors.Primary
    );

GetStatusColor(status: Text): Color =
    Switch(Lower(status),
        "active", ThemeColors.Success,
        "open", ThemeColors.Success,
        "in progress", ThemeColors.Primary,
        "pending", ThemeColors.Warning,
        "on hold", ThemeColors.Warning,
        "closed", ThemeColors.TextSecondary,
        "completed", ThemeColors.Success,
        "cancelled", ThemeColors.Error,
        "archived", ThemeColors.TextSecondary,
        "error", ThemeColors.Error,
        ThemeColors.Text
    );

// --- Date Functions ---

GetDateRangeStart(rangeName: Text): Date =
    Switch(Lower(rangeName),
        "today", DateRanges.Today,
        "thisweek", DateRanges.ThisWeek,
        "thismonth", DateRanges.ThisMonth,
        "thisquarter", DateRanges.ThisQuarter,
        "thisyear", DateRanges.ThisYear,
        "last7days", DateRanges.Last7Days,
        "last30days", DateRanges.Last30Days,
        "last90days", DateRanges.Last90Days,
        "last365days", DateRanges.Last365Days,
        DateRanges.ThisMonth
    );

IsWithinDateRange(checkDate: Date, rangeName: Text): Boolean =
    checkDate >= GetDateRangeStart(rangeName) && checkDate <= Today();

FormatDateRelative(inputDate: DateTime): Text =
    With({ daysDiff: DateDiff(DateValue(inputDate), Today(), TimeUnit.Days) },
        Switch(true,
            daysDiff = 0, "Today",
            daysDiff = 1, "Yesterday",
            daysDiff < 7, Text(daysDiff) & " days ago",
            daysDiff < 30, Text(RoundDown(daysDiff / 7, 0)) & " weeks ago",
            daysDiff < 365, Text(RoundDown(daysDiff / 30, 0)) & " months ago",
            Text(inputDate, "[$-en-US]mmm d, yyyy")
        )
    );

// --- Notification Functions ---

NotifySuccess(message: Text): Boolean = Notify(message, NotificationType.Success);
NotifyError(message: Text): Boolean = Notify(message, NotificationType.Error);
NotifyWarning(message: Text): Boolean = Notify(message, NotificationType.Warning);
NotifyInfo(message: Text): Boolean = Notify(message, NotificationType.Information);
NotifyPermissionDenied(action: Text): Boolean =
    Notify("Permission denied: You do not have access to " & action, NotificationType.Error);

// --- Validation Functions ---

IsValidEmail(email: Text): Boolean =
    !IsBlank(email) && CountRows(Split(email, "@")) = 2 && Len(Last(Split(email, "@")).Value) > 3;

IsValidLength(input: Text, minLen: Number, maxLen: Number): Boolean =
    Len(input) >= minLen && Len(input) <= maxLen;

// ============================================================
// END OF APP.FORMULAS
// ============================================================
```

---

## Migration Checklist

### Step 1: Copy Named Formulas and UDFs
- [ ] Copy the App.Formulas template to your Canvas App
- [ ] Replace `YOUR-ADMIN-GROUP-ID` with actual Azure AD group ID
- [ ] Replace `YOUR-MANAGER-GROUP-ID` with actual Azure AD group ID
- [ ] Update `@yourcompany.com` domain patterns
- [ ] Add additional department roles as needed

### Step 2: Simplify App.OnStart
- [ ] Remove all static value definitions (themes, date ranges)
- [ ] Remove permission derivation logic
- [ ] Keep only: mutable state, initial data loading
- [ ] Update filter state to use UDFs

### Step 3: Update Control Properties
- [ ] Replace inline permission checks with `HasPermission()`
- [ ] Replace inline role checks with `HasRole()`
- [ ] Replace inline color lookups with `GetThemeColor()`
- [ ] Replace status color logic with `GetStatusColor()`
- [ ] Replace date formatting with `FormatDateRelative()`
- [ ] Update filter patterns to use `CanAccessRecord()` / `CanAccessItem()`

### Step 4: Test & Validate
- [ ] Test with Admin user
- [ ] Test with Manager user
- [ ] Test with Regular user
- [ ] Test with External user
- [ ] Verify all permissions work correctly
- [ ] Verify all filters apply correctly

---

## Performance Comparison

| Metric | Before (OnStart) | After (App.Formulas) |
|--------|-----------------|---------------------|
| Initial Load | All computed upfront | Lazy evaluation |
| Permission Check | Cached once | Computed on access |
| Theme Colors | Variable lookup | Named Formula |
| Date Ranges | Computed once | Fresh on access |
| API Calls | All in OnStart | On-demand |
| Memory Usage | All variables loaded | Minimal footprint |
| Refresh Behavior | Manual via Set() | Auto on dependency change |

---

## File Deliverables

After implementing this plan, the following files will be updated/created:

| File | Purpose |
|------|---------|
| `App-Formulas-Template.fx` | Complete App.Formulas implementation |
| `App-OnStart-Minimal.fx` | Simplified App.OnStart |
| `Control-Patterns-Modern.fx` | Updated control formula patterns |
| `MODERNIZATION-PLAN.md` | This planning document |
| `MIGRATION-GUIDE.md` | Step-by-step migration instructions |

---

## Summary

This modernization transforms the Canvas App template from an imperative, OnStart-heavy approach to a declarative, formula-driven architecture. Key benefits:

1. **Performance**: Lazy evaluation reduces startup time
2. **Maintainability**: Centralized logic in App.Formulas
3. **Reusability**: UDFs eliminate code duplication
4. **Reactivity**: Named Formulas auto-refresh on dependency changes
5. **Readability**: Clean control properties using semantic function names
6. **Best Practices**: Aligns with 2025 Power Fx recommendations

The migration path is incremental - existing apps can adopt these patterns gradually while maintaining backward compatibility.
