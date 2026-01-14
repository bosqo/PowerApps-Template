// ============================================================
// CORE BOOTSTRAP: App.Formulas - Named Formulas + UDFs
// ============================================================
//
// USAGE:
// 1. Copy entire content to Power Apps Studio → App.Formulas
// 2. Replace placeholder EntraID group IDs (lines ~130-140)
// 3. Test role detection with admin/user accounts
//
// CONFIGURATION REQUIRED:
// Line ~130: YOUR-ADMIN-GROUP-ID (Azure AD Group Object ID)
// Line ~135: YOUR-MANAGER-GROUP-ID (Azure AD Group Object ID)
// Line ~140: YOUR-HR-GROUP-ID (Azure AD Group Object ID)
//
// ============================================================

// ============================================================
// SECTION 1: STATIC NAMED FORMULAS
// These are constant values that never change during app session
// ============================================================

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

// Typography Sizes
Typography = {
    SizeXS: 10,
    SizeSM: 12,
    SizeMD: 14,
    SizeLG: 16,
    SizeXL: 20,
    Size2XL: 24,
    Size3XL: 32,
    Font: Font.'Segoe UI',
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
    Environment: If(
        Param("environment") = "prod",
        "Production",
        "Development"
    ),
    ItemsPerPage: 50,
    MaxSearchResults: 500,
    TimeoutSeconds: 30
};

// Role-to-Permissions Mapping
Permission = {
    Admin: {
        ViewAll: true,
        Edit: true,
        Delete: true,
        Approve: true,
        ViewAudit: true
    },
    Manager: {
        ViewAll: true,
        Edit: true,
        Delete: false,
        Approve: true,
        ViewAudit: false
    },
    HR: {
        ViewAll: true,
        Edit: false,
        Delete: false,
        Approve: false,
        ViewAudit: false
    },
    Processor: {
        ViewAll: false,
        Edit: true,
        Delete: false,
        Approve: false,
        ViewAudit: false
    }
};

// ============================================================
// SECTION 2: COMPUTED NAMED FORMULAS (Auto-refresh on dependency change)
// ============================================================

// User Profile - Lazy-loaded from Office365Users
UserProfile = With(
    { profile: Office365Users.MyProfileV2() },
    {
        Email: User().Email,
        FullName: User().FullName,
        JobTitle: Coalesce(profile.jobTitle, ""),
        Department: Coalesce(profile.department, ""),
        OfficeLocation: Coalesce(profile.officeLocation, ""),
        MobilePhone: Coalesce(profile.mobilePhone, ""),
        Manager: Coalesce(profile.manager, "")
    }
);

// User Roles - Determined from EntraID security groups
UserRoles = {
    // CONFIGURE THESE: Replace with your actual Azure AD Group Object IDs
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

    IsHR: CountRows(
        Filter(
            Office365Groups.ListGroupMembers("YOUR-HR-GROUP-ID"),
            mail = User().Email
        )
    ) > 0,

    // Fallback: all authenticated users are at least Users
    IsUser: true,

    // Domain-based role detection
    IsCorporate: EndsWith(Lower(User().Email), "@yourcompany.com"),
    IsExternal: !EndsWith(Lower(User().Email), "@yourcompany.com")
};

// User Permissions - Derived from roles
UserPermissions = {
    CanViewAll: UserRoles.IsAdmin || UserRoles.IsManager,
    CanEdit: UserRoles.IsAdmin || UserRoles.IsManager || UserRoles.IsHR || UserRoles.IsUser,
    CanDelete: UserRoles.IsAdmin,
    CanApprove: UserRoles.IsAdmin || UserRoles.IsManager,
    CanViewAudit: UserRoles.IsAdmin,
    CanExport: UserRoles.IsAdmin || UserRoles.IsManager
};

// Date Ranges - CET-aware, auto-updating
DateRange = {
    Today: GetCETToday(),
    ThisWeek: DateAdd(GetCETToday(), -Weekday(GetCETToday()) + 1, TimeUnit.Days),
    ThisMonth: Date(Year(GetCETToday()), Month(GetCETToday()), 1),
    ThisQuarter: Date(
        Year(GetCETToday()),
        (RoundUp(Month(GetCETToday())/3, 0) - 1) * 3 + 1,
        1
    ),
    ThisYear: Date(Year(GetCETToday()), 1, 1),
    Last7Days: DateAdd(GetCETToday(), -7, TimeUnit.Days),
    Last30Days: DateAdd(GetCETToday(), -30, TimeUnit.Days),
    Last90Days: DateAdd(GetCETToday(), -90, TimeUnit.Days),
    Last365Days: DateAdd(GetCETToday(), -365, TimeUnit.Days)
};

// ============================================================
// SECTION 3: CORE UDFS - Permissions & Access Control
// ============================================================

// Check if user has specific role
HasRole(roleName: Text): Boolean =
    Switch(
        Lower(roleName),
        "admin", UserRoles.IsAdmin,
        "manager", UserRoles.IsManager,
        "hr", UserRoles.IsHR,
        "user", UserRoles.IsUser,
        "corporate", UserRoles.IsCorporate,
        false
    );

// Check if user has specific permission
HasPermission(permissionName: Text): Boolean =
    Switch(
        Lower(permissionName),
        "viewall", UserPermissions.CanViewAll,
        "edit", UserPermissions.CanEdit,
        "delete", UserPermissions.CanDelete,
        "approve", UserPermissions.CanApprove,
        "audit", UserPermissions.CanViewAudit,
        "export", UserPermissions.CanExport,
        false
    );

// Check if user has any of multiple roles (comma-separated)
HasAnyRole(roleNames: Text): Boolean =
    With(
        { roles: Split(roleNames, ",") },
        CountRows(
            Filter(
                roles,
                HasRole(Trim(Value))
            )
        ) > 0
    );

// Get effective user scope for filtering (Email or Blank)
GetUserScope(): Text =
    If(
        UserPermissions.CanViewAll,
        Blank(),  // Admin/Manager see all
        User().Email  // Regular users see only their own
    );

// Check if user can access a specific record (by owner email)
CanAccess(ownerEmail: Text): Boolean =
    If(
        IsBlank(ownerEmail),
        UserPermissions.CanViewAll,
        UserPermissions.CanViewAll || Lower(ownerEmail) = Lower(User().Email)
    );

// Check if user can edit a record
CanEdit(ownerEmail: Text): Boolean =
    If(
        IsBlank(ownerEmail),
        UserPermissions.CanEdit,
        UserPermissions.CanEdit && (UserRoles.IsAdmin || Lower(ownerEmail) = Lower(User().Email))
    );

// Check if user can delete a record
CanDelete(ownerEmail: Text): Boolean =
    UserPermissions.CanDelete && (
        UserRoles.IsAdmin || Lower(ownerEmail) = Lower(User().Email)
    );

// Get display name for current user's role
GetRoleDisplayName(): Text =
    Switch(
        true,
        UserRoles.IsAdmin, "Administrator",
        UserRoles.IsManager, "Manager",
        UserRoles.IsHR, "HR",
        "Benutzer"  // German: User
    );

// Get color for current user's role
GetRoleColor(): Color =
    Switch(
        true,
        UserRoles.IsAdmin, ThemeColors.Error,
        UserRoles.IsManager, ThemeColors.Primary,
        UserRoles.IsHR, ThemeColors.Warning,
        ThemeColors.Success
    );

// ============================================================
// SECTION 4: TIMEZONE UDFS - CET/CEST Handling (CRITICAL)
// SharePoint stores everything in UTC - always use these functions!
// ============================================================

// Get today's date in CET timezone
GetCETToday(): Date =
    DateAdd(
        Today(),
        If(
            Or(
                And(Month(Today()) < 3, false),  // Before March
                And(Month(Today()) > 10, false)  // After October
            ),
            1,  // CET: UTC+1
            2   // CEST: UTC+2 (March - October)
        ),
        TimeUnit.Hours
    );

// Convert UTC DateTime to CET DateTime
ConvertUTCToCET(utcDateTime: DateTime): DateTime =
    DateAdd(
        utcDateTime,
        If(
            Or(
                And(Month(utcDateTime) < 3, false),
                And(Month(utcDateTime) > 10, false)
            ),
            1,  // CET: UTC+1
            2   // CEST: UTC+2
        ),
        TimeUnit.Hours
    );

// Format date as short German format (15.1.2025)
FormatDateShort(inputDate: Date): Text =
    If(
        IsBlank(inputDate),
        "",
        Text(inputDate, "dd.m.yyyy")
    );

// Format date as long German format (15. Januar 2025)
FormatDateLong(inputDate: Date): Text =
    If(
        IsBlank(inputDate),
        "",
        Text(Day(inputDate), "00") & ". " &
        Choose(
            Month(inputDate),
            "Januar", "Februar", "März", "April", "Mai", "Juni",
            "Juli", "August", "September", "Oktober", "November", "Dezember"
        ) & " " &
        Text(Year(inputDate), "0000")
    );

// Format date as relative German text (Heute, Gestern, vor 3 Tagen)
FormatDateRelative(inputDate: DateTime): Text =
    If(
        IsBlank(inputDate),
        "",
        With(
            { daysDiff: DateDiff(ConvertUTCToCET(inputDate), Now(), TimeUnit.Days) },
            Switch(
                true,
                daysDiff = 0, "Heute",
                daysDiff = 1, "Gestern",
                daysDiff < 7, "vor " & Text(daysDiff) & " Tagen",
                daysDiff < 30, "vor " & Text(RoundDown(daysDiff / 7, 0)) & " Wochen",
                daysDiff < 365, "vor " & Text(RoundDown(daysDiff / 30, 0)) & " Monaten",
                FormatDateShort(DateValue(inputDate))
            )
        )
    );

// ============================================================
// SECTION 5: UTILITY UDFS - Validation & Formatting
// ============================================================

// Validate email format
IsValidEmail(email: Text): Boolean =
    If(
        IsBlank(email),
        false,
        And(
            CountRows(Split(email, "@")) = 2,
            Len(Last(Split(email, "@")).Value) >= 3,
            Len(First(Split(email, "@")).Value) >= 1
        )
    );

// Validate text length
IsValidLength(input: Text; minLen: Number; maxLen: Number): Boolean =
    And(
        Len(input) >= minLen,
        Len(input) <= maxLen
    );

// Check if value is in a comma-separated list
IsOneOf(value: Text; allowedValues: Text): Boolean =
    If(
        IsBlank(value),
        false,
        CountRows(
            Filter(
                Split(allowedValues, ","),
                Trim(Value) = value
            )
        ) > 0
    );

// Get color for status value (German status names)
GetStatusColor(statusValue: Text): Color =
    Switch(
        Lower(Trim(statusValue)),
        "aktiv", ThemeColors.Success,
        "genehmigt", ThemeColors.Success,
        "in bearbeitung", ThemeColors.Primary,
        "in bearbeitung", ThemeColors.Primary,
        "ausstehend", ThemeColors.Warning,
        "wartet", ThemeColors.Warning,
        "abgeschlossen", ThemeColors.TextSecondary,
        "abgebrochen", ThemeColors.Error,
        "fehler", ThemeColors.Error,
        "archiviert", ThemeColors.TextDisabled,
        ThemeColors.Text
    );

// Get display text for boolean value (German)
BoolToText(value: Boolean): Text =
    If(value, "Ja", "Nein");

// Safe coalesce - return first non-blank value
Coalesce(value1: any; value2: any; value3: any): any =
    If(
        Not(IsBlank(value1)),
        value1,
        If(
            Not(IsBlank(value2)),
            value2,
            value3
        )
    );

// ============================================================
// SECTION 6: CORE BOOTSTRAP MARKER
// ============================================================

// All code above this line is CORE and required in every app.
// Do not delete or modify the core UDFs above.
// Optional modules can be added below in separate sections.

// End of Core Bootstrap

