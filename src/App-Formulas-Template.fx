// ============================================================
// APP.FORMULAS - Modern Power Fx 2025 Template
// Canvas App Template with Named Formulas and UDFs
// ============================================================
//
// USAGE:
// Copy this entire content to your Canvas App's App.Formulas property
// (Settings > Display > App.Formulas)
//
// CONFIGURATION REQUIRED:
// 1. Replace YOUR-ADMIN-GROUP-ID with your Azure AD Admin group GUID
// 2. Replace YOUR-MANAGER-GROUP-ID with your Azure AD Manager group GUID
// 3. Replace @yourcompany.com with your organization's email domain
// 4. Adjust department names (Sales, Finance, IT) to match your org
//
// ============================================================
//
// NAMING CONVENTIONS IN THIS TEMPLATE
// ============================================================
//
// NAMED FORMULAS: PascalCase (e.g., ThemeColors, UserProfile, DateRanges)
// - Static configurations and computed values
// - No verb prefix (these are nouns representing data)
//
// USER-DEFINED FUNCTIONS (UDFs): PascalCase with verb prefix
// - Boolean checks: Has*, Can*, Is* (e.g., HasRole, CanAccessRecord, IsValidEmail)
// - Retrieval: Get* (e.g., GetUserScope, GetThemeColor)
// - Formatting: Format* (e.g., FormatDateShort, FormatCurrency)
// - Actions (Behavior): Notify*, Show*, Update* (e.g., NotifySuccess)
//
// Examples:
// - HasRole("Admin") → Boolean check
// - GetUserScope() → Retrieval function
// - FormatDateShort(date) → Formatting function
// - NotifySuccess("Saved") → Behavior function (Void return)
//
// ============================================================


// ============================================================
// SECTION 1: STATIC NAMED FORMULAS
// These are constant values that never change during app session
// ============================================================
//
// Depends on: Nothing (static constants)
// Used by: Control Fill, Color, and BorderColor properties throughout app
//
// Dependency order: Static formulas have no dependencies on each other or user formulas

// Theme Colors - Microsoft Fluent Design System
ThemeColors = {
    // Brand Colors
    Primary: ColorValue("#0078D4"),          // Microsoft Blue
    PrimaryLight: ColorValue("#2B88D8"),     // Lighter blue for hover
    PrimaryDark: ColorValue("#005A9E"),      // Darker blue for pressed
    Secondary: ColorValue("#50E6FF"),         // Accent cyan

    // Semantic Colors
    Success: ColorValue("#107C10"),           // Green - confirmations
    SuccessLight: ColorValue("#DFF6DD"),      // Light green background
    Warning: ColorValue("#FFB900"),           // Amber - caution
    WarningLight: ColorValue("#FFF4CE"),      // Light amber background
    Error: ColorValue("#D13438"),             // Red - errors
    ErrorLight: ColorValue("#FDE7E9"),        // Light red background
    Info: ColorValue("#0078D4"),              // Blue - information

    // Neutrals
    Background: ColorValue("#F3F2F1"),        // Page background
    Surface: ColorValue("#FFFFFF"),           // Card/panel background
    SurfaceHover: ColorValue("#F5F5F5"),      // Hover state
    Text: ColorValue("#201F1E"),              // Primary text
    TextSecondary: ColorValue("#605E5C"),     // Secondary text
    TextDisabled: ColorValue("#A19F9D"),      // Disabled text
    Border: ColorValue("#EDEBE9"),            // Standard border
    BorderStrong: ColorValue("#8A8886"),      // Emphasized border
    Divider: ColorValue("#E1DFDD"),           // Divider lines

    // Overlay
    Overlay: ColorValue("#00000066"),         // Modal backdrop (40% black)
    Shadow: ColorValue("#00000029")           // Drop shadow (16% black)
};

// Typography Sizes (for reference in controls)
Typography = {
    // Font Sizes
    SizeXS: 10,
    SizeSM: 12,
    SizeMD: 14,
    SizeLG: 16,
    SizeXL: 20,
    Size2XL: 24,
    Size3XL: 32,

    // Font Weights (use in Font property)
    Font: Font.'Segoe UI',

    // Line Heights
    LineHeightTight: 1.25,
    LineHeightNormal: 1.5,
    LineHeightRelaxed: 1.75
};

// Spacing Scale
Spacing = {
    XS: 4,
    SM: 8,
    MD: 16,
    LG: 24,
    XL: 32,
    XXL: 48
};

// Border Radius
BorderRadius = {
    None: 0,
    SM: 2,
    MD: 4,
    LG: 8,
    XL: 12,
    Round: 9999
};

// Application Configuration
AppConfig = {
    // Environment Detection
    Environment: If(
        Param("environment") = "prod",
        "Production",
        "Development"
    ),
    IsProduction: Lower(Coalesce(Param("environment"), "")) = "prod",
    IsDevelopment: Lower(Coalesce(Param("environment"), "")) <> "prod",

    // Data Settings
    ItemsPerPage: 50,
    MaxSearchResults: 500,
    CacheExpiryMinutes: 5,
    AutoRefreshEnabled: true,
    AutoRefreshIntervalSeconds: 300,

    // Feature Limits
    MaxFileUploadMB: 10,
    MaxBulkOperationItems: 100
};

// ============================================================
// SECTION 1A: CACHE STRATEGY & INVALIDATION
// ============================================================
//
// CACHE SCOPE: Session-scoped (cleared on app close/restart)
// CACHE TTL: 5 minutes (AppConfig.CacheExpiryMinutes)
// CACHE STORAGE: Collections (CachedRolesCache)
//
// CRITICAL DATA CACHE:
// - UserProfile: Uses built-in User() function (no caching needed, instant)
// - UserRoles: Cached from Office365Groups membership checks
// - UserPermissions: Derived from UserRoles (no cache needed, no API calls)
//
// NOTE: UserProfile was simplified to use only User().Email and User().FullName
// which are built-in Power Apps functions requiring no API calls or caching.
//
// CACHE INVALIDATION TRIGGERS:
// 1. Session end: User closes app → cache cleared (new session starts)
// 2. TTL expiry: After 5 minutes of session time → can manually refresh
// 3. Explicit refresh: User clicks "Refresh" button → manually re-fetch data
// 4. Role change: If user's Azure AD groups change → not auto-detected
//
// CACHE COLLECTION SCHEMA
//
// CachedRolesCache: Record (user roles)
// Schema: {
//   IsAdmin: Boolean,
//   IsManager: Boolean,
//   IsHR: Boolean,
//   IsGF: Boolean,
//   IsSachbearbeiter: Boolean,
//   IsUser: Boolean
// }
// Size: <1KB per user
// Updated: Once per session (or on explicit refresh)
//
// CACHING BEST PRACTICES
//
// DO:
// ✓ Cache static or slow-changing data (roles)
// ✓ Cache data that comes from expensive APIs (Office365Groups)
// ✓ Use built-in functions when available (User().Email, User().FullName)
//
// DON'T:
// ✗ Cache frequently changing data (current time, temporary form values)
// ✗ Cache data without TTL (stale data risk)
// ✗ Cache sensitive data that changes outside the app (e.g., Azure AD role changes)

// Date Range Calculations - Auto-refresh when date changes
//
// Depends on:
// - Today() function (built-in Power Apps date function)
// - No user-specific dependencies (purely temporal calculations)
//
// Used by:
// - Date filter UDFs (IsDateInRange, IsNotPastDate)
// - Date range filter patterns in Gallery.Items
// - DateRangeFilter in ActiveFilters (ThisWeek, ThisMonth, etc.)
//
DateRanges = {
    // Today and Yesterday
    Today: Today(),
    Yesterday: Today() - 1,
    Tomorrow: Today() + 1,

    // Week Calculations
    StartOfWeek: Today() - Weekday(Today()) + 1,
    EndOfWeek: Today() - Weekday(Today()) + 7,
    StartOfLastWeek: Today() - Weekday(Today()) + 1 - 7,
    EndOfLastWeek: Today() - Weekday(Today()) + 7 - 7,

    // Month Calculations
    StartOfMonth: Date(Year(Today()), Month(Today()), 1),
    EndOfMonth: Date(Year(Today()), Month(Today()) + 1, 1) - 1,
    StartOfLastMonth: Date(Year(Today()), Month(Today()) - 1, 1),
    EndOfLastMonth: Date(Year(Today()), Month(Today()), 1) - 1,

    // Year Calculations
    StartOfYear: Date(Year(Today()), 1, 1),
    EndOfYear: Date(Year(Today()) + 1, 1, 1) - 1,

    // Relative Ranges
    Last7Days: Today() - 7,
    Last30Days: Today() - 30,
    Last90Days: Today() - 90
};


// ============================================================
// SECTION 2: COMPUTED NAMED FORMULAS
// These auto-refresh when their dependencies change
// ============================================================

// User Profile - Simplified (no API calls, no caching)
// Uses built-in User() function only - instant evaluation, zero network calls
//
// Depends on:
// - User() function (built-in Power Apps identity)
//
// Used by:
// - GetUserScope() UDF
// - Control bindings that display user profile info
//
// Fields:
// - Email: User's email from built-in User().Email
// - DisplayName: User's full name with email fallback
// - Initials: Computed from full name (e.g., "MM" for "Max Mustermann")
//
UserProfile = {
    Email: User().Email,
    DisplayName: Coalesce(User().FullName, Text(User().Email)),
    Initials: Upper(
        Left(User().FullName, 1) &
        Mid(
            User().FullName,
            Find(" ", User().FullName & " ") + 1,
            1
        )
    )
};

// User Roles - Determined from Security Groups (with caching)
// Cached results from Office365Groups membership checks
//
// Depends on:
// - CachedRolesCache collection (initialized in App.OnStart critical path)
// - Office365Groups.CheckMembershipAsync() connector (called once per role on cache miss)
// - UserProfile (for email in group checks)
//
// Used by:
// - UserPermissions (derives permissions from role booleans)
// - Permission check UDFs (HasRole, HasAnyRole)
// - UI visibility checks (role-based feature access)
// - RoleColor and RoleBadgeText Named Formulas
//
// IMPORTANT CONFIGURATION REQUIRED:
// Replace GROUP_ID placeholders with your actual Azure AD Security Group IDs:
// 1. AdminGroupId = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
// 2. ManagerGroupId = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
// 3. HRGroupId = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
// 4. GFGroupId = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
// 5. SachbearbeiterGroupId = "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
//
// Cache Strategy:
// - First call (App.OnStart critical path): Calls Office365Groups for each role, caches result
// - Subsequent calls: Returns cached roles (no API calls) until cache expires (5 minutes)
// - Session scope: Cache cleared when app closes
//
UserRoles = If(
    // Cache miss: CachedRolesCache is empty or first evaluation
    IsBlank(CachedRolesCache),
    // FIRST CALL: Populate cache by checking each role via Office365Groups
    {
        // Administrator - Full system access
        // Replace "YOUR_ADMIN_GROUP_ID" with actual Azure AD Security Group ID
        IsAdmin: false,
        /*
        Office365Groups.CheckMembershipAsync(
            "YOUR_ADMIN_GROUP_ID",
            User().Email
        ).value
        */

        // Manager - Team/department management
        // Replace "YOUR_MANAGER_GROUP_ID" with actual Azure AD Security Group ID
        IsManager: false,
        /*
        Office365Groups.CheckMembershipAsync(
            "YOUR_MANAGER_GROUP_ID",
            User().Email
        ).value
        */

        // HR - Human Resources department
        // Replace "YOUR_HR_GROUP_ID" with actual Azure AD Security Group ID
        IsHR: false,
        /*
        Office365Groups.CheckMembershipAsync(
            "YOUR_HR_GROUP_ID",
            User().Email
        ).value
        */

        // GF - Geschäftsführung (Business Management)
        // Replace "YOUR_GF_GROUP_ID" with actual Azure AD Security Group ID
        IsGF: false,
        /*
        Office365Groups.CheckMembershipAsync(
            "YOUR_GF_GROUP_ID",
            User().Email
        ).value
        */

        // Sachbearbeiter - Operator/Administrator
        // Replace "YOUR_SACHBEARBEITER_GROUP_ID" with actual Azure AD Security Group ID
        IsSachbearbeiter: false,
        /*
        Office365Groups.CheckMembershipAsync(
            "YOUR_SACHBEARBEITER_GROUP_ID",
            User().Email
        ).value
        */

        // User - Default role for all authenticated users
        IsUser: true
    },
    // Cache hit: CachedRolesCache has data from previous call
    // Return cached roles (no API calls on subsequent accesses)
    First(CachedRolesCache)
);

// User Permissions - Derived from Cached Roles (NO API CALLS)
// Permissions are calculated from UserRoles without making any Office365 API requests
// Automatically updates when UserRoles changes
//
// Depends on:
// - UserRoles.IsAdmin, UserRoles.IsManager, UserRoles.IsHR, UserRoles.IsSachbearbeiter (role booleans)
// - Note: UserRoles comes from cache after critical path (no redundant API calls)
//
// Used by:
// - Permission check UDFs (HasPermission, CanAccessRecord, CanEditRecord, CanDeleteRecord)
// - Button visibility checks (CanCreate, CanEdit, CanDelete)
// - Filter initialization (GetUserScope, GetDepartmentScope)
// - All permission-dependent control bindings
//
// Cache Strategy:
// - Called once during App.OnStart critical path
// - Subsequent app operations read from cached UserRoles
// - No Office365 API calls (permissions are purely derived from cached roles)
// - TTL: 5 minutes (inherited from UserRoles cache)
//
UserPermissions = {
    // CRUD Permissions
    CanCreate: UserRoles.IsAdmin || UserRoles.IsManager || UserRoles.IsSachbearbeiter,
    CanRead: true,  // All users can read (filtered by scope)
    CanEdit: UserRoles.IsAdmin || UserRoles.IsManager || UserRoles.IsSachbearbeiter,
    CanDelete: UserRoles.IsAdmin,

    // Scope Permissions
    CanViewAll: UserRoles.IsAdmin || UserRoles.IsManager || UserRoles.IsHR,
    CanViewOwn: true,

    // Special Permissions
    CanApprove: UserRoles.IsAdmin || UserRoles.IsManager,
    CanReject: UserRoles.IsAdmin || UserRoles.IsManager,
    CanArchive: UserRoles.IsAdmin || UserRoles.IsManager
};

// Dynamic Role-Based Color
RoleColor = Switch(
    true,
    UserRoles.IsAdmin, ThemeColors.Error,        // Red for Admin
    UserRoles.IsGF, ThemeColors.PrimaryDark,     // Dark Blue for GF
    UserRoles.IsManager, ThemeColors.Primary,     // Blue for Manager
    UserRoles.IsHR, ThemeColors.Warning,          // Amber for HR
    UserRoles.IsSachbearbeiter, ThemeColors.Info, // Blue for Sachbearbeiter
    ThemeColors.Success                           // Green for User
);

// Role Badge Text
RoleBadgeText = Switch(
    true,
    UserRoles.IsAdmin, "Admin",
    UserRoles.IsGF, "GF",
    UserRoles.IsManager, "Manager",
    UserRoles.IsHR, "HR",
    UserRoles.IsSachbearbeiter, "Sachbearbeiter",
    "User"
);

// Feature Flags - Control feature availability
FeatureFlags = {
    // UI Features
    EnableKeyboardShortcuts: true,
    EnableNotifications: true,

    // Debug Features (Development only)
    ShowDebugInfo: Param("debug") = "true" && UserRoles.IsAdmin,
    ShowPerformanceMetrics: Param("perf") = "true" && UserRoles.IsAdmin,
    EnableMockData: Param("mock") = "true" && AppConfig.IsDevelopment
};

// Default Filter Configuration (reactive to permissions)
DefaultFilters = {
    UserScope: If(UserPermissions.CanViewAll, Blank(), User().Email),
    ActiveOnly: true,
    IncludeArchived: false
};


// ============================================================
// SECTION 3: USER DEFINED FUNCTIONS (UDFs)
// Reusable functions that can be called from any control
// ============================================================

// -----------------------------------------------------------
// Permission & Role Check Functions (Has*, Can*)
// Returns: Boolean
// -----------------------------------------------------------

// Check if user has a specific permission by name
HasPermission(permissionName: Text): Boolean =
    Switch(
        Lower(permissionName),
        "create", UserPermissions.CanCreate,
        "read", UserPermissions.CanRead,
        "edit", UserPermissions.CanEdit,
        "delete", UserPermissions.CanDelete,
        "viewall", UserPermissions.CanViewAll,
        "viewown", UserPermissions.CanViewOwn,
        "approve", UserPermissions.CanApprove,
        "reject", UserPermissions.CanReject,
        "archive", UserPermissions.CanArchive,
        false
    );

// Check if user has a specific role by name
HasRole(roleName: Text): Boolean =
    Switch(
        Lower(roleName),
        "admin", UserRoles.IsAdmin,
        "gf", UserRoles.IsGF,
        "manager", UserRoles.IsManager,
        "hr", UserRoles.IsHR,
        "sachbearbeiter", UserRoles.IsSachbearbeiter,
        "user", UserRoles.IsUser,
        false
    );

// Check if user has any of the specified roles (comma-separated, unlimited count)
// Example: HasAnyRole("Admin,Manager,HR") returns true if user has ANY of these roles
// Returns false for blank input without error
HasAnyRole(roleNames: Text): Boolean =
    !IsBlank(roleNames) &&
    CountRows(
        Filter(
            Split(roleNames, ","),
            HasRole(Trim(Value))
        )
    ) > 0;

// Check if user has ALL of the specified roles (comma-separated)
// Complement to HasAnyRole for AND logic
HasAllRoles(roleNames: Text): Boolean =
    CountRows(
        Filter(
            Split(roleNames, ","),
            !HasRole(Trim(Value))
        )
    ) = 0;

// Get user's highest role as display label
GetRoleLabel(): Text =
    Switch(
        true,
        UserRoles.IsAdmin, "Administrator",
        UserRoles.IsGF, "Geschäftsführer",
        UserRoles.IsManager, "Manager",
        UserRoles.IsHR, "HR",
        UserRoles.IsSachbearbeiter, "Sachbearbeiter",
        "Benutzer"
    );

// Get role badge color for display
GetRoleBadgeColor(): Color = RoleColor;

// Get role badge text (short form)
GetRoleBadge(): Text = RoleBadgeText;


// -----------------------------------------------------------
// Data Retrieval Functions (Get*)
// Returns: Various types (Text, Color, Number, Record)
// -----------------------------------------------------------

// Get effective user scope for datasource filtering
// Returns Blank() if user can see all, otherwise user's email
GetUserScope(): Text =
    If(UserPermissions.CanViewAll, Blank(), User().Email);

// Check if current user can access a specific record by owner
CanAccessRecord(ownerEmail: Text): Boolean =
    UserPermissions.CanViewAll ||
    IsBlank(ownerEmail) ||
    Lower(ownerEmail) = Lower(User().Email);

// Check if user can edit a specific record
CanEditRecord(ownerEmail: Text, status: Text): Boolean =
    UserPermissions.CanEdit &&
    CanAccessRecord(ownerEmail) &&
    !IsOneOf(Lower(status), "archived,closed,cancelled");

// Check if user can delete a specific record
CanDeleteRecord(ownerEmail: Text): Boolean =
    UserPermissions.CanDelete && CanAccessRecord(ownerEmail);


// -----------------------------------------------------------
// DELEGATION PATTERN: Filter UDFs for SharePoint >2000 records
// All 4 of these are delegation-safe and work with large datasets
// -----------------------------------------------------------

// FILT-01: Delegation-friendly filter for role-based data scoping
// Returns: true if user has ViewAll permission (can see all records)
// Returns: false if user lacks ViewAll permission (can only see Owner=CurrentUser)
// Delegation: SAFE (references Named Formula, no filtering)
// Use case: Filter(Items, CanViewAllData() || Owner = User().Email)
CanViewAllData: Boolean = UserPermissions.CanViewAll;

// FILT-02: Delegation-friendly text search UDF
// Parameters: field = Text field to search in (e.g., Title, Description)
//             term = Search term to match (case-insensitive substring)
// Returns: true if field contains term, false otherwise
// Delegation: SAFE via Search() function (delegable for SharePoint)
// Use case: Filter(Items, MatchesSearchTerm(Title, ActiveFilters.SearchTerm))
MatchesSearchTerm: Function(field As Text, term As Text): Boolean =
    If(
        IsBlank(term),
        true,  // Blank search term matches everything
        Not(IsBlank(Search(field, term)))  // Search() is delegable if term is constant
    );

// FILT-03: Delegation-friendly status filter UDF
// Parameters: statusValue = Status value to match (e.g., "Active", "Pending", "Completed")
// Returns: true if ThisItem.Status matches statusValue, false otherwise
// Delegation: SAFE via equality check (=), must be used in Filter() or Gallery context
// Usage: Filter(Items, MatchesStatusFilter("Active"))
MatchesStatusFilter: Function(statusValue As Text): Boolean =
    If(
        IsBlank(statusValue),
        true,  // Blank status = no filter applied
        ThisItem.Status = statusValue
    );

// FILT-04: Delegation-friendly user-based record filtering
// Parameters: ownerEmail = Owner email field from record (e.g., ThisItem.Owner)
// Returns: true if user has ViewAll permission OR owns record, false otherwise
// Delegation: SAFE via equality check and CanViewAllData reference
// Usage: Filter(Items, CanViewRecord(Owner))
// Security: Default-deny for blank owners (safe pattern)
CanViewRecord: Function(ownerEmail As Text): Boolean =
    If(
        IsBlank(ownerEmail),
        false,  // Blank owner = cannot determine access, deny access
        CanViewAllData() || ownerEmail = User().Email
    );


// -----------------------------------------------------------
// DELEGATION PATTERN: Filter Composition (FILT-05)
// Multi-layer filter combining all 4 filter UDFs
// -----------------------------------------------------------

// FILT-05: Delegation-friendly filter composition
// Combines status filter (FILT-03), role scoping (FILT-01), text search (FILT-02), and user filtering (FILT-04)
// Layer 1 (Status): MatchesStatusFilter(selectedStatus) — most restrictive, applied first for performance
// Layer 2 (Role + Ownership): CanViewRecord(Owner) — security filter
// Layer 3 (My Items): If(showMyItemsOnly, Owner = User().Email, true) — optional user-only restriction
// Layer 4 (Search): Or(...MatchesSearchTerm...) — most expensive, applied last
// Delegation: SAFE via composition of delegation-safe functions
// Returns: Table of Items meeting all 4 conditions (AND logic between layers)
FilteredGalleryData: Function(showMyItemsOnly As Logical, selectedStatus As Text, searchTerm As Text): Table =
  Filter(
    Items,
    // Layer 1: Status filtering (most restrictive - filters down dataset first)
    MatchesStatusFilter(selectedStatus),
    // Layer 2: Role-based scoping + ownership check
    CanViewRecord(Owner),
    // Layer 3: User-specific filtering (My Items toggle)
    If(showMyItemsOnly, Owner = User().Email, true),
    // Layer 4: Text search (most expensive operation - last)
    Or(
      MatchesSearchTerm(Title, searchTerm),
      MatchesSearchTerm(Description, searchTerm),
      MatchesSearchTerm(Owner, searchTerm)
    )
  );


// -----------------------------------------------------------
// Theme & Color Functions (Get*)
// Returns: Color
// -----------------------------------------------------------

// Get theme color by name
GetThemeColor(colorName: Text): Color =
    Switch(
        Lower(colorName),
        // Brand
        "primary", ThemeColors.Primary,
        "primarylight", ThemeColors.PrimaryLight,
        "primarydark", ThemeColors.PrimaryDark,
        "secondary", ThemeColors.Secondary,
        // Semantic
        "success", ThemeColors.Success,
        "successlight", ThemeColors.SuccessLight,
        "warning", ThemeColors.Warning,
        "warninglight", ThemeColors.WarningLight,
        "error", ThemeColors.Error,
        "errorlight", ThemeColors.ErrorLight,
        "info", ThemeColors.Info,
        // Neutrals
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

// Get semantic color for status values
GetStatusColor(status: Text): Color =
    Switch(
        Lower(status),
        // Active/Positive
        "active", ThemeColors.Success,
        "open", ThemeColors.Success,
        "approved", ThemeColors.Success,
        "genehmigt", ThemeColors.Success,         // German: approved
        "completed", ThemeColors.Success,
        "done", ThemeColors.Success,
        "published", ThemeColors.Success,
        "resolved", ThemeColors.Success,
        // In Progress
        "in progress", ThemeColors.Primary,
        "in bearbeitung", ThemeColors.Primary,    // German: in progress
        "processing", ThemeColors.Primary,
        "reviewing", ThemeColors.Primary,
        "pending review", ThemeColors.Primary,
        // Warning/Pending
        "pending", ThemeColors.Warning,
        "beantragt", ThemeColors.Warning,         // German: requested/applied
        "on hold", ThemeColors.Warning,
        "waiting", ThemeColors.Warning,
        "draft", ThemeColors.Warning,
        "submitted", ThemeColors.Warning,
        // Inactive/Neutral
        "closed", ThemeColors.TextSecondary,
        "archived", ThemeColors.TextSecondary,
        "inactive", ThemeColors.TextSecondary,
        "expired", ThemeColors.TextSecondary,
        // Error/Negative
        "cancelled", ThemeColors.Error,
        "rejected", ThemeColors.Error,
        "abgelehnt", ThemeColors.Error,           // German: rejected
        "failed", ThemeColors.Error,
        "error", ThemeColors.Error,
        "overdue", ThemeColors.Error,
        "blocked", ThemeColors.Error,
        // Default
        ThemeColors.Text
    );

// Get status icon name (for use with Icon control)
GetStatusIcon(status: Text): Text =
    Switch(
        Lower(status),
        "active", "builtinicon:Cancel",
        "completed", "builtinicon:Check",
        "genehmigt", "builtinicon:Check",
        "in bearbeitung", "builtinicon:Clock",
        "beantragt", "builtinicon:Clock",
        "gespeichert", "builtinicon:Edit",
        "abgebrochen", "builtinicon:Cancel",
        "abgelehnt", "builtinicon:Cancel",
        "builtinicon:CircleHollow"
    );

// Get priority color
GetPriorityColor(priority: Text): Color =
    Switch(
        Lower(priority),
        "critical", ThemeColors.Error,
        "high", ColorValue("#D83B01"),  // Orange-red
        "medium", ThemeColors.Warning,
        "low", ThemeColors.Success,
        "none", ThemeColors.TextSecondary,
        ThemeColors.Text
    );


// -----------------------------------------------------------
// Notification Functions (Notify*)
// Returns: Void (side effects only)
// NOTE: Behavior UDFs use curly braces and Void return type
// -----------------------------------------------------------

// ============================================================
// TOAST NOTIFICATION SYSTEM (NEW in Phase 4)
// ============================================================
// Layer 1: UDFs (NotifySuccess, NotifyError, etc.) - public API
// Layer 2: State (NotificationStack collection, AddToast/RemoveToast) - lifecycle
// Layer 3: UI (Control-Patterns-Modern.fx, cnt_NotificationStack) - rendering (04-02)
//
// Architecture:
// - Developers call NotifySuccess("message") or NotifyError("message")
// - These UDFs call AddToast() to update the NotificationStack collection
// - UI layer (04-02) renders toasts from NotificationStack collection
// - Auto-dismiss timers (UI layer) call RemoveToast() to remove old toasts
//
// Example flow:
// NotifySuccess("Record saved") → AddToast("Record saved", "Success", true, 5000)
// → NotificationStack updated with new toast {ID: 0, Message: "Record saved", Type: "Success", AutoClose: true, ...}
// → UI renders toast in top-right corner
// → After 5 seconds, auto-dismiss timer calls RemoveToast(0)
// → Toast removed from collection, UI automatically hides it
// ============================================================
// TOAST NOTIFICATION SYSTEM ARCHITECTURE (Phase 4)
// ============================================================
// Three-layer notification system for non-blocking, Fluent Design feedback.
//
// Layer 1: Trigger UDFs (this section)
//   - NotifySuccess(), NotifyError(), NotifyWarning(), NotifyInfo()
//   - NotifyPermissionDenied(), NotifyActionCompleted(), NotifyValidationError()
//   - Developers call these; never call Notify() or AddToast() directly
//   - Each UDF calls AddToast() to update NotificationStack collection
//
// Layer 2: State Management (this section + App.OnStart)
//   - ToastConfig: Configuration (durations, dimensions)
//   - AddToast/RemoveToast: Lifecycle UDFs
//   - NotificationStack: Collection holding active toasts (initialized in App.OnStart Section 7)
//   - NotificationCounter: ID generator for unique toast IDs
//
// Layer 3: UI Rendering (Control-Patterns-Modern.fx, Pattern 1.9)
//   - cnt_NotificationStack: Main container (top-right overlay, fixed position, ZIndex 1000)
//   - cnt_Toast: Individual toast tile (repeating child, one per row in collection)
//   - GetToast* helpers: Dynamic styling (colors, icons, borders per type)
//   - Auto-dismiss timer: Visible formula monitors elapsed time, fades at 4.7s, hides at 5.0s
//
// Example flow:
// NotifySuccess("Saved") → AddToast() → NotificationStack row → UI renders → 5s timeout → RemoveToast()
//
// For customization: Edit ToastConfig below for durations/widths
// For troubleshooting: See docs/TROUBLESHOOTING.md
// For detailed guide: See docs/TOAST-NOTIFICATION-GUIDE.md
// ============================================================

// Toast Configuration - Static settings for all notifications
ToastConfig = {
    Width: 350,               // Toast width in pixels (250-400 range)
    MaxWidth: 400,            // Maximum width for very long messages
    SuccessDuration: 5000,    // Auto-dismiss timeout in ms
    WarningDuration: 5000,    // Auto-dismiss timeout in ms
    InfoDuration: 5000,       // Auto-dismiss timeout in ms
    ErrorDuration: 0,         // Never auto-dismiss (user must close)
    AnimationDuration: 300    // Slide-in animation duration in ms
};

// Get toast background color by type
GetToastBackground(toastType: Text): Color =
    Switch(
        toastType,
        "Success", ThemeColors.SuccessLight,      // Light green
        "Error", ThemeColors.ErrorLight,          // Light red
        "Warning", ThemeColors.WarningLight,      // Light amber
        "Info", ColorValue("#E7F4FF"),            // Light blue
        ThemeColors.Surface                       // Default white
    );

// Get toast border color by type
GetToastBorderColor(toastType: Text): Color =
    Switch(
        toastType,
        "Success", ThemeColors.Success,           // Green
        "Error", ThemeColors.Error,               // Red
        "Warning", ThemeColors.Warning,           // Amber
        "Info", ThemeColors.Info,                 // Blue
        ThemeColors.Border                        // Default grey
    );

// Get toast icon by type
GetToastIcon(toastType: Text): Text =
    Switch(
        toastType,
        "Success", "✓",                           // Checkmark
        "Error", "✕",                             // X mark
        "Warning", "⚠",                           // Warning triangle
        "Info", "ℹ",                              // Info circle
        ""                                        // Default empty
    );

// Get toast icon color by type
GetToastIconColor(toastType: Text): Color =
    Switch(
        toastType,
        "Success", ThemeColors.Success,           // Green
        "Error", ThemeColors.Error,               // Red
        "Warning", ThemeColors.Warning,           // Amber
        "Info", ThemeColors.Info,                 // Blue
        ThemeColors.Text                          // Default text color
    );

// Standard success notification
NotifySuccess(message: Text): Void = {
    Notify(message, NotificationType.Success);
    AddToast(message, "Success", true, ToastConfig.SuccessDuration)
};

// Standard error notification
NotifyError(message: Text): Void = {
    Notify(message, NotificationType.Error);
    AddToast(message, "Error", false, ToastConfig.ErrorDuration)
};

// Standard warning notification
NotifyWarning(message: Text): Void = {
    Notify(message, NotificationType.Warning);
    AddToast(message, "Warning", true, ToastConfig.WarningDuration)
};

// Standard info notification
NotifyInfo(message: Text): Void = {
    Notify(message, NotificationType.Information);
    AddToast(message, "Info", true, ToastConfig.InfoDuration)
};

// Permission denied notification with action context
NotifyPermissionDenied(action: Text): Void = {
    Notify(
        "Permission denied: You do not have access to " & Lower(action),
        NotificationType.Error
    );
    AddToast(
        "Permission denied: You do not have access to " & Lower(action),
        "Error",
        false,
        ToastConfig.ErrorDuration
    )
};

// Action completed notification
NotifyActionCompleted(action: Text, itemName: Text): Void = {
    Notify(
        action & " completed: " & itemName,
        NotificationType.Success
    );
    AddToast(
        action & " completed: " & itemName,
        "Success",
        true,
        ToastConfig.SuccessDuration
    )
};

// Validation error notification
NotifyValidationError(fieldName: Text, message: Text): Void = {
    Notify(
        fieldName & ": " & message,
        NotificationType.Warning
    );
    AddToast(
        fieldName & ": " & message,
        "Warning",
        true,
        ToastConfig.WarningDuration
    )
};

// ============================================================
// NOTIFICATION LIFECYCLE: AddToast & RemoveToast
// ============================================================
// AddToast: Called by NotifySuccess/NotifyError/etc (Layer 1 → Layer 2)
//   → Adds row to NotificationStack (Layer 2 state)
//   → UI layer (Layer 3) automatically renders new row in cnt_NotificationStack
//
// RemoveToast: Called by UI close button or auto-dismiss timer (Layer 3 → Layer 2)
//   → Removes row from NotificationStack
//   → UI layer automatically updates (row no longer exists)
//
// Never call these directly in controls; they are implementation details.
// Always use NotifySuccess(), NotifyError(), etc. for user-facing notifications.
// ============================================================

// Add toast to notification stack
// Called by all Notify* UDFs to update the NotificationStack collection
// Parameters:
//   message: Text - Message to display
//   toastType: Text - Type of notification ("Success", "Error", "Warning", "Info")
//   shouldAutoClose: Boolean - Should auto-dismiss after duration (errors: false)
//   duration: Number - Duration in milliseconds before auto-dismiss (0 = never)
// Note: Auto-dismiss logic is handled by UI timer control in 04-02
AddToast(message: Text; toastType: Text; shouldAutoClose: Boolean; duration: Number): Void = {
    // Patch new toast into NotificationStack collection with schema:
    // ID (unique identifier), Message, Type, AutoClose, Duration, CreatedAt, IsVisible
    Patch(
        NotificationStack,
        Defaults(NotificationStack),
        {
            ID: NotificationCounter,
            Message: message,
            Type: toastType,
            AutoClose: shouldAutoClose,
            Duration: duration,
            CreatedAt: Now(),
            IsVisible: true
        }
    );
    // Increment counter for next toast to ensure unique IDs
    Set(NotificationCounter, NotificationCounter + 1)
};

// Remove toast from notification stack
// Called by toast close button (X) or auto-dismiss timer (UI layer)
// Parameters:
//   toastID: Number - ID of toast to remove (matches NotificationStack.ID field)
// Note: Silently ignores if toast already removed or doesn't exist
RemoveToast(toastID: Number): Void = {
    IfError(
        Remove(NotificationStack, LookUp(NotificationStack, ID = toastID)),
        // Silently ignore errors (toast already removed or ID doesn't match)
        Blank()
    )
};

// ============================================================
// REVERT-ENABLED TOAST SYSTEM (NEW in Phase 4 - Extended)
// ============================================================
// Extends basic toast system with optional Undo/Revert buttons
// Use for: Delete with Undo, Archive with Restore, Bulk actions with Undo
//
// Architecture:
// - AddToastWithRevert: Extended AddToast with revert parameters
// - HandleRevert: Execute revert action and restore state
// - NotifyWithRevert, NotifyDeleteWithUndo, NotifyArchiveWithUndo: High-level APIs
//
// Example flow:
// User clicks Delete → Remove(Items) → NotifyDeleteWithUndo() →
// User clicks "Undo" → HandleRevert() → Patch(Items, restore) → Success
// ============================================================

// Extended AddToast with revert support (NEW)
// Called by NotifyWithRevert and related functions
// Parameters:
//   message: Text - Message to display
//   toastType: Text - Type: "Success", "Error", "Warning", "Info"
//   shouldAutoClose: Boolean - Auto-dismiss after duration?
//   duration: Number - Auto-dismiss timeout in milliseconds
//   hasRevert: Boolean - Show revert button? (NEW)
//   revertLabel: Text - Revert button text (e.g., "Undo", "Restore") (NEW)
//   revertData: Record - Data needed to revert action (e.g., {ItemID: "123"}) (NEW)
//   revertCallbackID: Number - Callback handler ID (0=Delete, 1=Archive, 2=Custom) (NEW)
//
// Schema added to NotificationStack:
//   HasRevert: Boolean - whether toast shows revert button
//   RevertLabel: Text - button text
//   RevertData: Record - serialized data for revert
//   RevertCallbackID: Number - handler identifier
//   IsReverting: Boolean - revert in progress (loading state)
//   RevertError: Text - error message if revert fails
AddToastWithRevert(
    message: Text;
    toastType: Text;
    shouldAutoClose: Boolean;
    duration: Number;
    hasRevert: Boolean;
    revertLabel: Text;
    revertData: Record;
    revertCallbackID: Number
): Void = {
    Patch(
        NotificationStack,
        Defaults(NotificationStack),
        {
            ID: NotificationCounter,
            Message: message,
            Type: toastType,
            AutoClose: shouldAutoClose,
            Duration: duration,
            CreatedAt: Now(),
            IsVisible: true,
            // Revert fields
            HasRevert: hasRevert,
            RevertLabel: revertLabel,
            RevertData: revertData,
            RevertCallbackID: revertCallbackID,
            IsReverting: false,
            RevertError: Blank()
        }
    );
    Set(NotificationCounter, NotificationCounter + 1)
};

// Handle revert/undo action (NEW)
// Called when user clicks revert button on toast
// Executes appropriate callback based on ID and removes toast on success
// Parameters:
//   toastID: Number - Toast ID to revert
//   callbackID: Number - Callback type (0=Delete Undo, 1=Archive Undo, 2=Custom)
//   revertData: Record - Data for executing revert (e.g., {ItemID: "123"})
//
// Callback IDs:
//   0: DELETE_UNDO - Restore deleted item
//   1: ARCHIVE_UNDO - Unarchive item
//   2: CUSTOM - Custom revert handler (extend in app code)
HandleRevert(toastID: Number; callbackID: Number; revertData: Record): Void = {
    // Mark toast as reverting (shows loading spinner in UI)
    Patch(
        NotificationStack,
        LookUp(NotificationStack, ID = toastID),
        {IsReverting: true, RevertError: Blank()}
    );

    // Execute callback based on ID
    Switch(
        callbackID,
        // 0: DELETE_UNDO - Restore deleted item
        0,
        IfError(
            // Restore item from revertData
            Patch(Items, Defaults(Items), revertData);
            // Remove toast after successful restore
            RemoveToast(toastID);
            // Show success message
            NotifySuccess("Eintrag wiederhergestellt: " & revertData.ItemName),
            // Error handler: Show error in toast
            Patch(
                NotificationStack,
                LookUp(NotificationStack, ID = toastID),
                {
                    IsReverting: false,
                    RevertError: "Wiederherstellung fehlgeschlagen: " & Error.Message
                }
            )
        ),
        // 1: ARCHIVE_UNDO - Unarchive item
        1,
        IfError(
            // Reactivate item by setting status to Active
            Patch(Items, {ID: revertData.ItemID}, {Status: "Active"});
            // Remove toast after successful unarchive
            RemoveToast(toastID);
            // Show success message
            NotifySuccess("Eintrag reaktiviert: " & revertData.ItemName),
            // Error handler: Show error in toast
            Patch(
                NotificationStack,
                LookUp(NotificationStack, ID = toastID),
                {
                    IsReverting: false,
                    RevertError: "Reaktivierung fehlgeschlagen: " & Error.Message
                }
            )
        ),
        // 2+: CUSTOM - User-defined callbacks (extend as needed)
        // No-op: App code should extend this switch statement
        Patch(
            NotificationStack,
            LookUp(NotificationStack, ID = toastID),
            {IsReverting: false}
        )
    )
};

// Generic notification with optional revert (NEW)
NotifyWithRevert(
    message: Text;
    notificationType: Text;
    revertLabel: Text;
    revertData: Record;
    revertCallbackID: Number
): Void = {
    Notify(
        message,
        Switch(
            notificationType,
            "Success", NotificationType.Success,
            "Error", NotificationType.Error,
            "Warning", NotificationType.Warning,
            NotificationType.Information
        )
    );
    AddToastWithRevert(
        message,
        notificationType,
        notificationType <> "Error",  // Auto-close unless error
        Switch(
            notificationType,
            "Success", ToastConfig.SuccessDuration,
            "Warning", ToastConfig.WarningDuration,
            "Info", ToastConfig.InfoDuration,
            ToastConfig.ErrorDuration
        ),
        true,                          // HasRevert: true
        revertLabel,
        revertData,
        revertCallbackID
    )
};

// Success notification with revert button (NEW)
NotifySuccessWithRevert(
    message: Text;
    revertLabel: Text;
    revertData: Record;
    revertCallbackID: Number
): Void = {
    NotifyWithRevert(
        message,
        "Success",
        revertLabel,
        revertData,
        revertCallbackID
    )
};

// Delete success notification with undo button (NEW)
// Convenience function: pre-configured for delete/undo workflow
// Parameters:
//   itemName: Text - Name of deleted item (for message)
//   revertData: Record - Must contain: {ItemID, ItemName, [ItemData]}
NotifyDeleteWithUndo(itemName: Text; revertData: Record): Void = {
    NotifySuccessWithRevert(
        "Eintrag '" & itemName & "' gelöscht",
        "Rückgängig",
        revertData,
        0  // CallbackID: DELETE_UNDO
    )
};

// Archive success notification with restore button (NEW)
// Convenience function: pre-configured for archive/restore workflow
// Parameters:
//   itemName: Text - Name of archived item (for message)
//   revertData: Record - Must contain: {ItemID, ItemName}
NotifyArchiveWithUndo(itemName: Text; revertData: Record): Void = {
    NotifySuccessWithRevert(
        "Eintrag '" & itemName & "' archiviert",
        "Wiederherstellen",
        revertData,
        1  // CallbackID: ARCHIVE_UNDO
    )
};

// -----------------------------------------------------------
// Validation Functions (Is*)
// Returns: Boolean
// -----------------------------------------------------------

// Validate email format
// Rejects: multiple @, spaces, missing local/domain parts, invalid domain format
// Example valid: user@example.com, first.last@company.co.uk
// Example invalid: user@@example.com, user @domain.com, @example.com, user@
IsValidEmail(email: Text): Boolean =
    !IsBlank(email) &&
    // No spaces allowed
    !IsMatch(email, " ") &&
    // Exactly one @ symbol
    CountRows(Split(email, "@")) = 2 &&
    // Local part (before @) must be at least 1 character
    Len(First(Split(email, "@")).Value) >= 1 &&
    // Domain part (after @) must be at least 4 characters (a.bc minimum)
    Len(Last(Split(email, "@")).Value) >= 4 &&
    // Domain must contain at least one dot
    IsMatch(Last(Split(email, "@")).Value, "\.") &&
    // Domain must not start or end with dot
    !StartsWith(Last(Split(email, "@")).Value, ".") &&
    !EndsWith(Last(Split(email, "@")).Value, ".") &&
    // Domain must not start or end with hyphen
    !StartsWith(Last(Split(email, "@")).Value, "-") &&
    !EndsWith(Last(Split(email, "@")).Value, "-") &&
    // Local part must not start or end with dot
    !StartsWith(First(Split(email, "@")).Value, ".") &&
    !EndsWith(First(Split(email, "@")).Value, ".");

// Check if a value is in a set of allowed values (comma-separated)
// Example: IsOneOf("draft", "draft,pending,active") returns true
// Returns false for blank inputs or empty allowed list
IsOneOf(value: Text, allowedValues: Text): Boolean =
    !IsBlank(value) &&
    !IsBlank(allowedValues) &&
    CountRows(
        Filter(
            Split(allowedValues, ","),
            Lower(Trim(Value)) = Lower(Trim(value))
        )
    ) > 0;

// Check if text contains only alphanumeric characters
// Returns false for blank/empty input
IsAlphanumeric(input: Text): Boolean =
    !IsBlank(input) &&
    IsMatch(input, "^[a-zA-Z0-9]+$");

// Validate date is not in the past
// Returns false for blank input (graceful handling)
IsNotPastDate(inputDate: Date): Boolean =
    !IsBlank(inputDate) &&
    inputDate >= Today();

// Validate date is within acceptable range
// Returns false for any blank input
IsDateInRange(inputDate: Date, minDate: Date, maxDate: Date): Boolean =
    !IsBlank(inputDate) &&
    !IsBlank(minDate) &&
    !IsBlank(maxDate) &&
    inputDate >= minDate && inputDate <= maxDate;


// -----------------------------------------------------------
// Pagination Functions (Get*, Can*)
// Returns: Number (pages/counts) or Boolean (navigation checks)
// -----------------------------------------------------------

// Calculate total number of pages
GetTotalPages(totalItems: Number, pageSize: Number): Number =
    RoundUp(totalItems / Max(1, pageSize), 0);

// Calculate number of items to skip for current page
GetSkipCount(currentPage: Number, pageSize: Number): Number =
    (Max(1, currentPage) - 1) * pageSize;

// Check if can navigate to previous page
CanGoToPreviousPage(currentPage: Number): Boolean =
    currentPage > 1;

// Check if can navigate to next page
CanGoToNextPage(currentPage: Number, totalItems: Number, pageSize: Number): Boolean =
    currentPage < GetTotalPages(totalItems, pageSize);

// Get page range display text (e.g., "1-50 of 1234")
GetPageRangeText(currentPage: Number, pageSize: Number, totalItems: Number): Text =
    With(
        {
            startItem: GetSkipCount(currentPage, pageSize) + 1,
            endItem: Min(GetSkipCount(currentPage, pageSize) + pageSize, totalItems)
        },
        Text(startItem) & "-" & Text(endItem) & " of " & Text(totalItems)
    );


// -----------------------------------------------------------
// Timezone Conversion Functions (Convert*, Get*, Is*)
// Returns: DateTime, Date, or Boolean
// CET = Central European Time (Standard: UTC+1, Daylight: UTC+2)
// SharePoint stores dates in UTC, convert to CET timezone (CET/CEST)
// -----------------------------------------------------------

// Check if given date is in daylight saving time (CEST)
// Germany: Last Sunday of March to Last Sunday of October
IsDaylightSavingTime(checkDate: Date): Boolean =
    And(
        checkDate >= Date(Year(checkDate), 3, 31 - Weekday(Date(Year(checkDate), 3, 31), StartOfWeek.Sunday)),
        checkDate < Date(Year(checkDate), 10, 31 - Weekday(Date(Year(checkDate), 10, 31), StartOfWeek.Sunday))
    );

// Convert UTC DateTime to MEZ time (CET/CEST)
ConvertUTCToCET(utcDateTime: DateTime): DateTime =
    If(
        IsBlank(utcDateTime),
        Blank(),
        // UTC+1 (CET) or UTC+2 (CEST during daylight saving)
        DateAdd(
            utcDateTime,
            1 + If(IsDaylightSavingTime(DateValue(utcDateTime)), 1, 0),
            TimeUnit.Hours
        )
    );

// Convert CET/CEST time to UTC DateTime
ConvertCETToUTC(mezDateTime: DateTime): DateTime =
    If(
        IsBlank(mezDateTime),
        Blank(),
        // Subtract CET offset (1 or 2 hours depending on DST)
        DateAdd(
            mezDateTime,
            -(1 + If(IsDaylightSavingTime(DateValue(mezDateTime)), 1, 0)),
            TimeUnit.Hours
        )
    );

// Get current time in CET timezone
GetCETTime(): DateTime =
    ConvertUTCToCET(Now());

// Get today's date in CET timezone
GetCETToday(): Date =
    DateValue(GetCETTime());


// -----------------------------------------------------------
// Date & Time Formatting Functions (Format*)
// Returns: Text (formatted output)
// German Format (d.m.yyyy), CET Timezone
// -----------------------------------------------------------

// Format date as short format (e.g., "15.1.2025")
FormatDateShort(inputDate: Date): Text =
    If(IsBlank(inputDate), "", Text(inputDate, "d.m.yyyy"));

// Format date as long format (e.g., "15. Januar 2025")
FormatDateLong(inputDate: Date): Text =
    If(IsBlank(inputDate), "", Text(inputDate, "d. mmmm yyyy"));

// Format date and time together (e.g., "15.1.2025 14:30")
// For UTC datetimes from SharePoint, use FormatDateTimeCET instead
FormatDateTime(inputDateTime: DateTime): Text =
    If(
        IsBlank(inputDateTime),
        "",
        Text(inputDateTime, "d.m.yyyy hh:mm")
    );

// Format UTC datetime from SharePoint in CET timezone
// Example: SharePoint 'Modified' field (UTC) -> CET time
FormatDateTimeCET(utcDateTime: DateTime): Text =
    If(
        IsBlank(utcDateTime),
        "",
        Text(
            ConvertUTCToCET(utcDateTime),
            "d.m.yyyy hh:mm"
        )
    );

// Format date as relative time (e.g., "vor 2 Tagen", "in 3 Tagen")
// Uses CET timezone for comparison
FormatDateRelative(inputDate: Date): Text =
    If(
        IsBlank(inputDate),
        "",
        If(
            inputDate = GetCETToday(),
            "Heute",
            If(
                inputDate = GetCETToday() - 1,
                "Gestern",
                If(
                    inputDate = GetCETToday() + 1,
                    "Morgen",
                    If(
                        inputDate < GetCETToday(),
                        "vor " & Text(GetCETToday() - inputDate) & " Tagen",
                        "in " & Text(inputDate - GetCETToday()) & " Tagen"
                    )
                )
            )
        )
    );


// -----------------------------------------------------------
// Text Formatting Functions (Format*, Get*)
// Returns: Text (formatted output)
// -----------------------------------------------------------

// Format number as currency
FormatCurrency(amount: Number, currencySymbol: Text): Text =
    Coalesce(currencySymbol, "$") & Text(amount, "#,##0.00");

// Format number as percentage
FormatPercent(value: Number, decimals: Number): Text =
    Text(value * 100, "#,##0." & Left("000000", decimals)) & "%";

// Get initials from full name
GetInitials(fullName: Text): Text =
    Upper(
        Left(Coalesce(fullName, "?"), 1) &
        If(
            IsMatch(fullName, " "),
            Mid(fullName, Find(" ", fullName) + 1, 1),
            ""
        )
    );

// ============================================================
// SECTION 4: ERROR MESSAGE LOCALIZATION (German)
// User-friendly error messages without technical jargon
// ============================================================
//
// Depends on: Nothing (static message templates)
// Used by: App.OnStart error handlers, Phase 3+ features (delete, patch, approve)
//
// Design Principle:
// - All error messages are user-friendly German text
// - No technical error codes, stack traces, or API details
// - Include remediation hints where possible ("check network", "retry later")
// - Never show to user: "Office365Users Connector Timeout", "HTTP 401", "Error Code: -2147024809"
//

// Profile loading errors - critical path (blocks app)
ErrorMessage_ProfileLoadFailed(connectorName: Text): Text =
    Switch(connectorName,
        "Office365Users", "Ihre Profilinformationen konnten nicht geladen werden. Bitte überprüfen Sie Ihre Internetverbindung.",
        "Office365Groups", "Ihre Berechtigungen konnten nicht überprüft werden. Bitte versuchen Sie später erneut.",
        "Generic", "Ein Fehler ist aufgetreten. Bitte aktualisieren Sie die App und versuchen Sie erneut."
    );

// Data refresh/operation errors
ErrorMessage_DataRefreshFailed(operationType: Text): Text =
    Switch(operationType,
        "save", "Speichern fehlgeschlagen. Bitte überprüfen Sie Ihre Eingabe und versuchen Sie erneut.",
        "delete", "Löschen fehlgeschlagen. Sie haben möglicherweise keine Berechtigung.",
        "load", "Daten konnten nicht geladen werden. Bitte überprüfen Sie Ihre Internetverbindung.",
        "patch", "Änderungen konnten nicht gespeichert werden. Bitte versuchen Sie später erneut.",
        "approve", "Genehmigung fehlgeschlagen. Sie haben möglicherweise keine Berechtigung.",
        "reject", "Ablehnung fehlgeschlagen. Bitte versuchen Sie später erneut.",
        "Generic", "Vorgang fehlgeschlagen. Bitte versuchen Sie später erneut."
    );

// Permission denied errors - user action blocked
ErrorMessage_PermissionDenied(actionName: Text): Text =
    "Sie haben keine Berechtigung zum Ausführen dieser Aktion: " & actionName;

// Generic error fallback
ErrorMessage_Generic: Text = "Ein Fehler ist aufgetreten. Bitte versuchen Sie später erneut.";

// Validation error messages
ErrorMessage_ValidationFailed(fieldName: Text, reason: Text): Text =
    "Validierung fehlgeschlagen für " & fieldName & ": " & reason;

// Network/connection errors
ErrorMessage_NetworkError: Text = "Verbindung fehlgeschlagen. Bitte überprüfen Sie Ihr Netzwerk und versuchen Sie erneut.";

// Timeout errors
ErrorMessage_TimeoutError: Text = "Die Anfrage hat zu lange gedauert. Bitte versuchen Sie später erneut.";

// Not found errors
ErrorMessage_NotFound(itemType: Text): Text =
    itemType & " nicht gefunden. Möglicherweise wurde es gelöscht oder Sie haben keinen Zugriff.";


// ============================================================
// SECTION 5: ERROR HANDLING PATTERNS FOR PHASES 3+
// ============================================================
//
// Depends on: ErrorMessage_* UDFs (defined above)
// Used by: Phase 3+ features that perform operations (delete, patch, approve)
//
// PATTERN GUIDELINES:
//
// Pattern 1: Critical Path Error (blocks app startup)
// Use when user MUST have this data to continue the app
// Example: User profile loading fails during App.OnStart
// Result: Show German error message, keep app locked (IsInitializing: true), require user action
//
// Pattern 2: Non-Critical Error (graceful degradation)
// Use when app can function without this data
// Example: Department lookup fails to load (shows empty in dropdown)
// Result: Use empty fallback, silently continue startup, no error dialog
//
// Pattern 3: User Action Error (notify, don't block app)
// Use when user performs action that fails (save, delete, approve)
// Example: Patch/Remove/Create fails due to permissions or validation
// Result: Show German error message, keep form open, user can retry
//
// Example implementations:
//
// --- CRITICAL PATH ERROR (Phase 2 - App.OnStart) ---
// When critical data fails:
//   If(
//     IsError(Office365Users.MyProfileV2()),
//     Set(AppState, Patch(AppState, {
//       ShowErrorDialog: true,
//       ErrorMessage: ErrorMessage_ProfileLoadFailed("Office365Users"),
//       IsInitializing: true  // Keep app locked
//     }))
//   );
//
// --- NON-CRITICAL ERROR (Phase 2 - Background data) ---
// When lookup data fails:
//   ClearCollect(
//     CachedDepartments,
//     IfError(
//       Filter(Departments, Status = "Active"),
//       IfError(..., Table())  // Empty fallback, silent degradation
//     )
//   );
//
// --- USER ACTION ERROR (Phase 3 - Delete) ---
// When user performs delete:
//   IfError(
//     Remove(Items, Gallery.Selected),
//     Set(AppState, Patch(AppState, {
//       ShowErrorDialog: true,
//       ErrorMessage: ErrorMessage_DataRefreshFailed("delete")
//     }))
//   );
//
// --- USER ACTION ERROR (Phase 4 - Form submit) ---
// When user saves form:
//   IfError(
//     SubmitForm(EditForm),
//     Set(AppState, Patch(AppState, {
//       ShowErrorDialog: true,
//       ErrorMessage: ErrorMessage_DataRefreshFailed("save")
//     }))
//   );
//


// ============================================================
// END OF APP.FORMULAS
// ============================================================
