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

// Color Intensity - State Transformations
// Controls how much colors darken/lighten for interactive states
// Range: -1.0 (fully darken) to 1.0 (fully lighten)
ColorIntensity = {
    Hover: -0.20,      // Darken 20% on hover
    Pressed: -0.30,    // Darken 30% when pressed
    Disabled: 0.60,    // Lighten 60% when disabled (washed out)
    Focus: -0.10       // Darken 10% for focus border
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

    // Week Calculations (Monday = start of week for German locale)
    StartOfWeek: Today() - Weekday(Today(), StartOfWeek.Monday) + 1,
    EndOfWeek: Today() - Weekday(Today(), StartOfWeek.Monday) + 7,
    StartOfLastWeek: Today() - Weekday(Today(), StartOfWeek.Monday) + 1 - 7,
    EndOfLastWeek: Today() - Weekday(Today(), StartOfWeek.Monday) + 7 - 7,

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
    Last14Days: Today() - 14,
    Last30Days: Today() - 30,
    Last90Days: Today() - 90
};

// ============================================================================
// BASE DATA LAYERS (Permission-Filtered)
// ============================================================================
// Purpose: Reusable base layers for galleries and dashboards
// Depends on: UserPermissions.CanViewAll, User().Email
// Used by: FilteredItems, dashboard KPIs, multiple galleries

// All items visible to current user (respects ViewAll permission)
UserScopedItems = If(
    UserPermissions.CanViewAll,
    Items,
    Filter(Items, Owner.Email = User().Email)
);

// Active items only (Status = "Active")
ActiveItems = Filter(UserScopedItems, Status = "Active");

// Inactive items only (Status = "Inactive")
InactiveItems = Filter(UserScopedItems, Status = "Inactive");

// ============================================================================
// DYNAMIC FILTER LAYER (Reactive to ActiveFilters state)
// ============================================================================
// Purpose: Combines all dropdown filters - fully reactive
// Depends on: ActiveFilters state (Status, Department, DateRange, SearchTerm)
// Used by: Gallery.Items property
// Delegation: All filter expressions are delegable (no UDFs inside Filter)

FilteredItems = Filter(
    UserScopedItems,
    // Status dropdown (blank = show all)
    (IsBlank(ActiveFilters.Status) || Status = ActiveFilters.Status) &&

    // Department dropdown (blank = show all)
    (IsBlank(ActiveFilters.Department) || Department = ActiveFilters.Department) &&

    // Date range dropdown (blank = show all)
    (IsBlank(ActiveFilters.DateRange) ||
     'Modified On' >= DateRanges[ActiveFilters.DateRange].Start) &&

    // Display name search (blank = show all)
    (IsBlank(ActiveFilters.SearchTerm) ||
     StartsWith(Title, ActiveFilters.SearchTerm))
);

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

// ============================================================
// ROLE CONFIGURATION - Entra ID Security Group IDs
// ============================================================
//
// SETUP: Replace placeholder GUIDs with your Entra ID Security Group IDs
// Find your Group IDs: Entra Admin Center → Groups → Select group → Object ID
//
// Role Hierarchy (higher priority = more permissions):
//   Priority 1: Admin           → Full access (all CRUD, ViewAll, Approve, Delete)
//   Priority 2: GF              → Executive view (ViewAll, Approve, Export)
//   Priority 3: Manager         → Team management (Create, Edit, ViewAll, Approve, Archive)
//   Priority 4: HR              → Employee data (ViewAll employees, Read, Export)
//   Priority 5: Sachbearbeiter  → Case processing (Create, Edit own records)
//   Priority 6: User            → Default fallback (Read own records only)
//
// The "highest role wins" pattern means a user in both Admin and Manager
// groups will be assigned the Admin role (highest priority).
//
RoleConfig = {
    // ========================================
    // CONFIGURATION: Replace with your Entra ID Security Group Object IDs
    // ========================================
    AdminGroupId: "00000000-aaaa-bbbb-cccc-111111111111",
    GFGroupId: "00000000-aaaa-bbbb-cccc-222222222222",
    ManagerGroupId: "00000000-aaaa-bbbb-cccc-333333333333",
    HRGroupId: "00000000-aaaa-bbbb-cccc-444444444444",
    SachbearbeiterGroupId: "00000000-aaaa-bbbb-cccc-555555555555"
};

// ============================================================
// PERMISSION MATRIX - Central Definition of All Role Permissions
// ============================================================
//
// THIS IS THE SINGLE SOURCE OF TRUTH for role permissions.
// To change what a role can do: edit this table.
// To add a new role: add a row.
// To add a new permission: add a column to every row.
//
// ┌──────────────┬───────┬────┬─────────┬────┬───────────────┬──────┐
// │ Permission   │ Admin │ GF │ Manager │ HR │ Sachbearbeiter│ User │
// ├──────────────┼───────┼────┼─────────┼────┼───────────────┼──────┤
// │ CanCreate    │  ✓    │    │    ✓    │    │      ✓        │      │
// │ CanRead      │  ✓    │ ✓  │    ✓    │ ✓  │      ✓        │  ✓   │
// │ CanEdit      │  ✓    │    │    ✓    │    │      ✓        │      │
// │ CanDelete    │  ✓    │    │         │    │               │      │
// │ CanViewAll   │  ✓    │ ✓  │    ✓    │ ✓  │               │      │
// │ CanViewOwn   │  ✓    │ ✓  │    ✓    │ ✓  │      ✓        │  ✓   │
// │ CanApprove   │  ✓    │ ✓  │    ✓    │    │               │      │
// │ CanReject    │  ✓    │ ✓  │    ✓    │    │               │      │
// │ CanArchive   │  ✓    │    │    ✓    │    │               │      │
// │ CanExport    │  ✓    │ ✓  │    ✓    │ ✓  │               │      │
// └──────────────┴───────┴────┴─────────┴────┴───────────────┴──────┘
//
PermissionMatrix = Table(
    {Role: "Admin",          CanCreate: true,  CanRead: true,  CanEdit: true,  CanDelete: true,  CanViewAll: true,  CanViewOwn: true,  CanApprove: true,  CanReject: true,  CanArchive: true,  CanExport: true},
    {Role: "GF",             CanCreate: false, CanRead: true,  CanEdit: false, CanDelete: false, CanViewAll: true,  CanViewOwn: true,  CanApprove: true,  CanReject: true,  CanArchive: false, CanExport: true},
    {Role: "Manager",        CanCreate: true,  CanRead: true,  CanEdit: true,  CanDelete: false, CanViewAll: true,  CanViewOwn: true,  CanApprove: true,  CanReject: true,  CanArchive: true,  CanExport: true},
    {Role: "HR",             CanCreate: false, CanRead: true,  CanEdit: false, CanDelete: false, CanViewAll: true,  CanViewOwn: true,  CanApprove: false, CanReject: false, CanArchive: false, CanExport: true},
    {Role: "Sachbearbeiter", CanCreate: true,  CanRead: true,  CanEdit: true,  CanDelete: false, CanViewAll: false, CanViewOwn: true,  CanApprove: false, CanReject: false, CanArchive: false, CanExport: false},
    {Role: "User",           CanCreate: false, CanRead: true,  CanEdit: false, CanDelete: false, CanViewAll: false, CanViewOwn: true,  CanApprove: false, CanReject: false, CanArchive: false, CanExport: false}
);

// ============================================================
// ROLE METADATA - Central Display Configuration
// ============================================================
//
// Controls how each role appears in the UI (labels, badges, colors).
// To change a role's display: edit this table.
// To add a new role: add a row (must also add to PermissionMatrix above).
//
// Priority determines "highest role wins" ordering (lower number = higher priority).
//
RoleMetadata = Table(
    {Role: "Admin",          Priority: 1, DisplayLabel: "Administrator",    BadgeText: "Admin",  BadgeColor: RGBA(209, 52, 56, 1)},
    {Role: "GF",             Priority: 2, DisplayLabel: "Geschäftsführung", BadgeText: "GF",     BadgeColor: RGBA(0, 33, 71, 1)},
    {Role: "Manager",        Priority: 3, DisplayLabel: "Manager",          BadgeText: "MGR",    BadgeColor: RGBA(0, 120, 212, 1)},
    {Role: "HR",             Priority: 4, DisplayLabel: "Personalwesen",    BadgeText: "HR",     BadgeColor: RGBA(255, 185, 0, 1)},
    {Role: "Sachbearbeiter", Priority: 5, DisplayLabel: "Sachbearbeiter",   BadgeText: "SB",     BadgeColor: RGBA(0, 169, 157, 1)},
    {Role: "User",           Priority: 6, DisplayLabel: "Benutzer",         BadgeText: "User",   BadgeColor: RGBA(138, 136, 134, 1)}
);

// ============================================================
// GALLERY VISIBILITY MATRIX - Who Sees What in Galleries
// ============================================================
//
// Controls record visibility in galleries per role.
// SeeAllRecords: Can see records owned by anyone
// SeeOwnRecords: Can see records owned by themselves
// SeeDeptRecords: Can see records from their department
// SeeArchived:   Can see archived/closed records
//
// ┌───────────────┬─────────┬──────┬──────┬──────────┐
// │ Role          │ AllRec. │ Own  │ Dept │ Archived │
// ├───────────────┼─────────┼──────┼──────┼──────────┤
// │ Admin         │   ✓     │  ✓   │  ✓   │    ✓     │
// │ GF            │   ✓     │  ✓   │  ✓   │          │
// │ Manager       │   ✓     │  ✓   │  ✓   │    ✓     │
// │ HR            │   ✓     │  ✓   │      │          │
// │ Sachbearbeiter│         │  ✓   │  ✓   │          │
// │ User          │         │  ✓   │      │          │
// └───────────────┴─────────┴──────┴──────┴──────────┘
//
GalleryVisibility = Table(
    {Role: "Admin",          SeeAllRecords: true,  SeeOwnRecords: true, SeeDeptRecords: true,  SeeArchived: true},
    {Role: "GF",             SeeAllRecords: true,  SeeOwnRecords: true, SeeDeptRecords: true,  SeeArchived: false},
    {Role: "Manager",        SeeAllRecords: true,  SeeOwnRecords: true, SeeDeptRecords: true,  SeeArchived: true},
    {Role: "HR",             SeeAllRecords: true,  SeeOwnRecords: true, SeeDeptRecords: false, SeeArchived: false},
    {Role: "Sachbearbeiter", SeeAllRecords: false, SeeOwnRecords: true, SeeDeptRecords: true,  SeeArchived: false},
    {Role: "User",           SeeAllRecords: false, SeeOwnRecords: true, SeeDeptRecords: false, SeeArchived: false}
);

// Active Role - Single string representing the user's highest role
// Determined on-demand via Entra ID Security Group membership checks
// "Highest Role Wins" Pattern using If() short-circuit evaluation
// Falls back to "User" if group checks fail or user not in any group
//
// Depends on:
// - RoleConfig Named Formula (Entra ID Security Group IDs)
// - Office365Groups connector (or AzureAD for premium)
//
// Used by:
// - UserPermissions (derived from PermissionMatrix via LookUp)
// - UserRoles (derived boolean record for backward compatibility)
// - RoleColor, RoleBadgeText (derived from RoleMetadata via LookUp)
// - HasRole(), GetRoleLabel() UDFs
//
// NOTE: This Named Formula checks Entra ID groups on-demand (no caching).
// Activate by uncommenting group checks below and replacing 'false' placeholders.
//
// ADDING A NEW ROLE:
// 1. Add GroupId to RoleConfig
// 2. Add row to PermissionMatrix, RoleMetadata, GalleryVisibility
// 3. Add priority check below (higher priority = checked first)
// 4. Add boolean field to UserRoles
// 5. Add case to HasRole() Switch
//
ActiveRole = IfError(
    If(
        // ── Priority 1: Admin ──────────────────────────────────
        // ACTIVATE: Replace 'false' with group check:
        // !IsEmpty(Filter(Office365Groups.ListGroupMembers(RoleConfig.AdminGroupId).value, Lower(mail) = Lower(User().Email))),
        false,  // ← Placeholder: replace with group check
        "Admin",

        // ── Priority 2: GF (Geschäftsführung) ──────────────────
        // ACTIVATE: Replace 'false' with group check:
        // !IsEmpty(Filter(Office365Groups.ListGroupMembers(RoleConfig.GFGroupId).value, Lower(mail) = Lower(User().Email))),
        false,  // ← Placeholder: replace with group check
        "GF",

        // ── Priority 3: Manager ────────────────────────────────
        // ACTIVATE: Replace 'false' with group check:
        // !IsEmpty(Filter(Office365Groups.ListGroupMembers(RoleConfig.ManagerGroupId).value, Lower(mail) = Lower(User().Email))),
        false,  // ← Placeholder: replace with group check
        "Manager",

        // ── Priority 4: HR ─────────────────────────────────────
        // ACTIVATE: Replace 'false' with group check:
        // !IsEmpty(Filter(Office365Groups.ListGroupMembers(RoleConfig.HRGroupId).value, Lower(mail) = Lower(User().Email))),
        false,  // ← Placeholder: replace with group check
        "HR",

        // ── Priority 5: Sachbearbeiter ─────────────────────────
        // ACTIVATE: Replace 'false' with group check:
        // !IsEmpty(Filter(Office365Groups.ListGroupMembers(RoleConfig.SachbearbeiterGroupId).value, Lower(mail) = Lower(User().Email))),
        false,  // ← Placeholder: replace with group check
        "Sachbearbeiter",

        // ── Priority 6: User (Default) ─────────────────────────
        // No API call needed - all authenticated users get this role
        "User"
    ),
    // Error fallback: If any group check fails, default to "User" (least privilege)
    "User"
);

// User Roles - Derived from ActiveRole (backward-compatible boolean record)
// No API calls - purely computed from the ActiveRole string
//
// Depends on:
// - ActiveRole Named Formula
//
// Used by:
// - Permission check UDFs (HasRole, HasAnyRole)
// - FeatureFlags (admin-only debug features)
// - UI visibility checks (role-based feature access)
//
UserRoles = {
    IsAdmin: ActiveRole = "Admin",
    IsGF: ActiveRole = "GF",
    IsManager: ActiveRole = "Manager",
    IsHR: ActiveRole = "HR",
    IsSachbearbeiter: ActiveRole = "Sachbearbeiter",
    IsUser: true  // All authenticated users have base User role
};

// User Permissions - Derived from PermissionMatrix via LookUp (NO API CALLS)
// Automatically resolved from the centralized PermissionMatrix table.
// To change permissions: edit PermissionMatrix above (NOT this formula).
//
// Depends on:
// - ActiveRole Named Formula
// - PermissionMatrix Named Formula (the central permission table)
//
// Used by:
// - Permission check UDFs (HasPermission, CanAccessRecord, CanEditRecord, CanDeleteRecord)
// - Button visibility checks (CanCreate, CanEdit, CanDelete)
// - Filter initialization (GetUserScope)
// - All permission-dependent control bindings
//
UserPermissions = LookUp(PermissionMatrix, Role = ActiveRole);

// Dynamic Role-Based Color - Derived from RoleMetadata table
// To change a role's color: edit RoleMetadata above (NOT this formula).
RoleColor = LookUp(RoleMetadata, Role = ActiveRole, BadgeColor);

// Role Badge Text - Derived from RoleMetadata table
// To change a role's badge: edit RoleMetadata above (NOT this formula).
RoleBadgeText = LookUp(RoleMetadata, Role = ActiveRole, BadgeText);

// User Gallery Access - Derived from GalleryVisibility table
// To change what a role sees in galleries: edit GalleryVisibility above.
UserGalleryAccess = LookUp(GalleryVisibility, Role = ActiveRole);

// Feature Flags - Control feature availability
FeatureFlags = {
    // UI Features
    EnableKeyboardShortcuts: true,
    EnableNotifications: true,

    // Debug Features (Development only, Admin-restricted)
    ShowDebugInfo: Param("debug") = "true" && ActiveRole = "Admin",
    ShowPerformanceMetrics: Param("perf") = "true" && ActiveRole = "Admin",
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
// Valid names: "create", "read", "edit", "delete", "viewall", "viewown",
//              "approve", "reject", "archive", "export" (case-insensitive)
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
        "export", UserPermissions.CanExport,
        false
    );

// Check if user has a specific role by name
// Valid role names: "Admin", "GF", "Manager", "HR", "Sachbearbeiter", "User"
// (case-insensitive)
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

// Get user's active role as display label (German)
// Display labels are defined in RoleMetadata table.
GetRoleLabel(): Text =
    LookUp(RoleMetadata, Role = ActiveRole, DisplayLabel);

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
// Uses GalleryVisibility matrix: SeeAllRecords allows viewing any record,
// otherwise only own records are visible.
CanAccessRecord(ownerEmail: Text): Boolean =
    UserGalleryAccess.SeeAllRecords ||
    IsBlank(ownerEmail) ||
    Lower(ownerEmail) = Lower(User().Email);

// Check if current user can access records from a specific department
// Uses GalleryVisibility matrix: SeeDeptRecords allows department-scoped access.
CanAccessDepartment(recordDept: Text): Boolean =
    UserGalleryAccess.SeeAllRecords ||
    (UserGalleryAccess.SeeDeptRecords && recordDept = UserProfile.Department);

// Check if archived records should be visible for the current user
// Uses GalleryVisibility matrix: SeeArchived controls archived record visibility.
CanSeeArchived(): Boolean = UserGalleryAccess.SeeArchived;

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

// FILT-01: Delegation-friendly check for role-based data scoping
// Returns: true if user has ViewAll permission (can see all records)
// Returns: false if user lacks ViewAll permission (can only see Owner=CurrentUser)
// Delegation: SAFE (references Named Formula, no filtering)
// Use case: Filter(Items, CanViewAllData() || Owner = User().Email)
CanViewAllData(): Boolean = UserGalleryAccess.SeeAllRecords;

// FILT-02: Text search helper UDF
// Parameters: field = Text field value to search in (e.g., ThisItem.Title)
//             term = Search term to match (case-insensitive prefix match)
// Returns: true if field starts with term, false otherwise
// Delegation: NOTE - UDFs inside Filter() are NOT delegable per Microsoft docs.
//   For delegable text search, use StartsWith() directly in Filter():
//   Filter(Items, StartsWith(Title, searchTerm))
//   Or use Search() at the table level: Search(Items, searchTerm, "Title", "Description")
// Use case (non-delegable, <2000 records): Filter(Items, MatchesSearchTerm(Title, txt_Search.Text))
MatchesSearchTerm(field: Text, term: Text): Boolean =
    If(
        IsBlank(term),
        true,  // Blank search term matches everything
        StartsWith(Lower(field), Lower(term))
    );

// FILT-03: Status filter helper UDF
// Parameters: recordStatus = Status field value from the current record (e.g., ThisItem.Status)
//             filterValue = Status value to filter by (e.g., "Active", "Pending", "Completed")
// Returns: true if recordStatus matches filterValue, or if filterValue is blank (no filter)
// Delegation: NOTE - UDFs inside Filter() are NOT delegable per Microsoft docs.
//   For delegable status filtering, use equality directly:
//   Filter(Items, IsBlank(selectedStatus) || Status = selectedStatus)
// Usage: Filter(Items, MatchesStatusFilter(Status, ActiveFilters.SelectedStatus))
MatchesStatusFilter(recordStatus: Text, filterValue: Text): Boolean =
    If(
        IsBlank(filterValue),
        true,  // Blank filter = no filter applied (show all)
        recordStatus = filterValue
    );

// FILT-04: User-based record filtering UDF
// Parameters: ownerEmail = Owner email field value from the current record (e.g., ThisItem.Owner.Email)
// Returns: true if user has ViewAll permission OR owns record, false otherwise
// Delegation: NOTE - UDFs inside Filter() are NOT delegable per Microsoft docs.
//   For delegable owner filtering, use inline logic:
//   Filter(Items, UserPermissions.CanViewAll || Owner.Email = User().Email)
// Usage (non-delegable, <2000 records): Filter(Items, CanViewRecord(Owner.Email))
// Security: Default-deny for blank owners (safe pattern)
CanViewRecord(ownerEmail: Text): Boolean =
    If(
        IsBlank(ownerEmail),
        false,  // Blank owner = cannot determine access, deny access
        CanViewAllData() || ownerEmail = User().Email
    );


// -----------------------------------------------------------
// DELEGATION PATTERN: Filter Composition (FILT-05)
// Multi-layer filter combining all 4 filter UDFs
// -----------------------------------------------------------

// FILT-05: Multi-layer filter composition PATTERN
// Combines status filter, role scoping, text search, and user filtering
// Layer 1 (Status): Status equality check — most restrictive, applied first for performance
// Layer 2 (Role + Ownership): CanViewRecord(Owner.Email) — security filter
// Layer 3 (My Items): If(showMyItemsOnly, Owner = User().Email, true) — optional user-only restriction
// Layer 4 (Search): StartsWith text matching — most expensive, applied last
//
// NOTE: This is an INLINE PATTERN, not a UDF, because:
//   1. UDFs cannot return Table types without User Defined Types (UDTs)
//   2. UDFs inside Filter() are NEVER delegable (Microsoft docs)
//   For datasets <2000 records, copy this pattern directly into Gallery.Items.
//   For datasets >2000 records, use delegable inline expressions (see CLAUDE.md).
//
// USAGE: Copy directly into glr_Items.Items property:
//
// Filter(
//   Items,
//   // Layer 1: Status filtering
//   MatchesStatusFilter(Status, ActiveFilters.SelectedStatus),
//   // Layer 2: Role-based scoping + ownership check
//   CanViewRecord(Owner.Email),
//   // Layer 3: User-specific filtering (My Items toggle)
//   If(ActiveFilters.ShowMyItemsOnly, Owner.Email = User().Email, true),
//   // Layer 4: Text search (most expensive operation - last)
//   Or(
//     MatchesSearchTerm(Title, ActiveFilters.SearchTerm),
//     MatchesSearchTerm(Description, ActiveFilters.SearchTerm),
//     MatchesSearchTerm(Owner.DisplayName, ActiveFilters.SearchTerm)
//   )
// )


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

// ============================================================
// STATE COLOR UDFs (Interactive States)
// ============================================================
// Apply consistent ColorFade transformations for interactive states

// Get hover state color (20% darker)
GetHoverColor(baseColor: Color): Color =
    ColorFade(baseColor, ColorIntensity.Hover);

// Get pressed state color (30% darker)
GetPressedColor(baseColor: Color): Color =
    ColorFade(baseColor, ColorIntensity.Pressed);

// Get disabled state color (60% lighter, washed out)
GetDisabledColor(baseColor: Color): Color =
    ColorFade(baseColor, ColorIntensity.Disabled);

// Get focus border color (10% darker)
GetFocusColor(baseColor: Color): Color =
    ColorFade(baseColor, ColorIntensity.Focus);


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
//   - ToastState: Consolidated state (Counter, ToRemove, AnimationStart, Reverting)
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

// User Defined Type for Revert Data
// Requires UDTs to be enabled: Settings > Updates > User-Defined Types
// Customize fields to match your Items table schema as needed
RevertDataType := Type({ItemID: Text, ItemName: Text});

// Revert Callback Registry - Replaces magic numbers with named constants
// Used by HandleRevert() to identify which undo action to execute
// Example: NotifyDeleteWithUndo(..., RevertCallbackIDs.DELETE_UNDO)
RevertCallbackIDs = {
    DELETE_UNDO: 0,      // Restore deleted item
    ARCHIVE_UNDO: 1,     // Unarchive item
    CUSTOM: 2            // Custom user-defined revert action
};

// Get toast background color by type
// Uses ColorFade() to derive light variants from semantic colors (Microsoft-documented function)
// ColorFade(color, 0.85) = 85% lighter toward white = subtle tinted background
GetToastBackground(toastType: Text): Color =
    Switch(
        toastType,
        "Success", ColorFade(ThemeColors.Success, 0.85),    // Light green
        "Error", ColorFade(ThemeColors.Error, 0.85),        // Light red
        "Warning", ColorFade(ThemeColors.Warning, 0.85),    // Light amber
        "Info", ColorFade(ThemeColors.Info, 0.85),           // Light blue
        ThemeColors.Surface                                  // Default white
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
AddToast(message: Text, toastType: Text, shouldAutoClose: Boolean, duration: Number): Void = {
    // Patch new toast into NotificationStack collection with schema:
    // ID (unique identifier), Message, Type, AutoClose, Duration, CreatedAt, IsVisible
    Patch(
        NotificationStack,
        Defaults(NotificationStack),
        {
            ID: ToastState.Counter,
            Message: message,
            Type: toastType,
            AutoClose: shouldAutoClose,
            Duration: duration,
            CreatedAt: Now(),
            IsVisible: true
        }
    );
    // Increment counter for next toast to ensure unique IDs
    Set(ToastState, Patch(ToastState, {Counter: ToastState.Counter + 1}))
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
//   revertData: RevertDataType - Data needed to revert action (e.g., {ItemID: "123"}) (NEW)
//   revertCallbackID: Number - Callback handler ID (0=Delete, 1=Archive, 2=Custom) (NEW)
//
// Schema added to NotificationStack:
//   HasRevert: Boolean - whether toast shows revert button
//   RevertLabel: Text - button text
//   RevertData: RevertDataType - serialized data for revert
//   RevertCallbackID: Number - handler identifier
//   IsReverting: Boolean - revert in progress (loading state)
//   RevertError: Text - error message if revert fails
AddToastWithRevert(
    message: Text,
    toastType: Text,
    shouldAutoClose: Boolean,
    duration: Number,
    hasRevert: Boolean,
    revertLabel: Text,
    revertData: RevertDataType,
    revertCallbackID: Number
): Void = {
    Patch(
        NotificationStack,
        Defaults(NotificationStack),
        {
            ID: ToastState.Counter,
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
    Set(ToastState, Patch(ToastState, {Counter: ToastState.Counter + 1}))
};

// Handle revert/undo action (NEW)
// Called when user clicks revert button on toast
// Executes appropriate callback based on ID and removes toast on success
// Parameters:
//   toastID: Number - Toast ID to revert
//   callbackID: Number - Callback type (0=Delete Undo, 1=Archive Undo, 2=Custom)
//   revertData: RevertDataType - Data for executing revert (e.g., {ItemID: "123"})
//
// Callback IDs:
//   0: DELETE_UNDO - Restore deleted item
//   1: ARCHIVE_UNDO - Unarchive item
//   2: CUSTOM - Custom revert handler (extend in app code)
HandleRevert(toastID: Number, callbackID: Number, revertData: RevertDataType): Void = {
    // Mark toast as reverting (shows loading spinner in UI)
    Patch(
        NotificationStack,
        LookUp(NotificationStack, ID = toastID),
        {IsReverting: true, RevertError: Blank()}
    );

    // Execute callback based on ID
    Switch(
        callbackID,
        // DELETE_UNDO - Restore deleted item
        RevertCallbackIDs.DELETE_UNDO,
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
        // ARCHIVE_UNDO - Unarchive item
        RevertCallbackIDs.ARCHIVE_UNDO,
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
        // CUSTOM - User-defined callbacks (extend as needed)
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
    message: Text,
    notificationType: Text,
    revertLabel: Text,
    revertData: RevertDataType,
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
    message: Text,
    revertLabel: Text,
    revertData: RevertDataType,
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
//   revertData: RevertDataType - Must contain: {ItemID, ItemName}
NotifyDeleteWithUndo(itemName: Text, revertData: RevertDataType): Void = {
    NotifySuccessWithRevert(
        "Eintrag '" & itemName & "' gelöscht",
        "Rückgängig",
        revertData,
        RevertCallbackIDs.DELETE_UNDO
    )
};

// Archive success notification with restore button (NEW)
// Convenience function: pre-configured for archive/restore workflow
// Parameters:
//   itemName: Text - Name of archived item (for message)
//   revertData: RevertDataType - Must contain: {ItemID, ItemName}
NotifyArchiveWithUndo(itemName: Text, revertData: RevertDataType): Void = {
    NotifySuccessWithRevert(
        "Eintrag '" & itemName & "' archiviert",
        "Wiederherstellen",
        revertData,
        RevertCallbackIDs.ARCHIVE_UNDO
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
        Text(startItem) & "-" & Text(endItem) & " von " & Text(totalItems)
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
ErrorMessage_Generic = "Ein Fehler ist aufgetreten. Bitte versuchen Sie später erneut.";

// Validation error messages
ErrorMessage_ValidationFailed(fieldName: Text, reason: Text): Text =
    "Validierung fehlgeschlagen für " & fieldName & ": " & reason;

// Network/connection errors
ErrorMessage_NetworkError = "Verbindung fehlgeschlagen. Bitte überprüfen Sie Ihr Netzwerk und versuchen Sie erneut.";

// Timeout errors
ErrorMessage_TimeoutError = "Die Anfrage hat zu lange gedauert. Bitte versuchen Sie später erneut.";

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
// --- NON-CRITICAL ERROR (No longer applicable - no caching) ---
// All data loaded on-demand via Named Formulas
// Error handling moved to control level (e.g., Gallery.Items = IfError(...))
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
