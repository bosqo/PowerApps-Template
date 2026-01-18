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

// User Profile - Lazy-loaded from Office365Users connector
// This is fetched ONCE when first accessed and cached
//
// Depends on:
// - Office365Users.MyProfileV2() connector
// - User() function (built-in Power Apps identity)
//
// Used by:
// - UserRoles (for email-based group membership checks)
// - GetUserScope() UDF
// - GetDepartmentScope() UDF
//
UserProfile = With(
    { profile: Office365Users.MyProfileV2() },
    {
        // Identity
        Email: User().Email,
        FullName: User().FullName,
        Id: Lower(User().Email),  // Use email as unique ID

        // Office365 Profile Data
        Department: Coalesce(profile.department, ""),

        // Computed Display Values
        DisplayName: Coalesce(
            User().FullName,
            Text(User().Email)
        ),
        Initials: Upper(
            Left(User().FullName, 1) &
            Mid(
                User().FullName,
                Find(" ", User().FullName & " ") + 1,
                1
            )
        )
    }
);

// User Roles - Determined from Security Groups
// Update the Group IDs to match your Azure AD configuration
//
// Depends on:
// - UserProfile.Email (for group membership checks)
// - Office365Groups.ListGroupMembers() connector (commented out in template)
//
// Used by:
// - UserPermissions (derives permissions from role booleans)
// - Permission check UDFs (HasRole, HasAnyRole)
// - UI visibility checks (role-based feature access)
// - RoleColor and RoleBadgeText Named Formulas
//
UserRoles = {
    // ===========================================
    // Security Group Membership
    // ===========================================

    // Administrator - Full system access
    IsAdmin: false,
        /*
        CountRows(

        Filter(
            Office365Groups.ListGroupMembers("GROUP_ID"),
            mail = User().Email
        )
    ) > 0,
    */

    // Manager - Team/department management
    IsManager: false,

    // HR - Human Resources department
    IsHR: false,

    // GF - Geschäftsführung
    IsGF: false,

    // Sachbearbeiter
    IsSachbearbeiter: false,

    // User - Default role for all authenticated users
    IsUser: true
};

// User Permissions - Derived from Roles
// Automatically updates when UserRoles changes
//
// Depends on:
// - UserRoles.IsAdmin, UserRoles.IsManager, UserRoles.IsHR, UserRoles.IsSachbearbeiter (role booleans)
//
// Used by:
// - Permission check UDFs (HasPermission, CanAccessRecord, CanEditRecord, CanDeleteRecord)
// - Button visibility checks (CanCreate, CanEdit, CanDelete)
// - Filter initialization (GetUserScope, GetDepartmentScope)
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
    DepartmentScope: If(
        UserRoles.IsAdmin,
        Blank(),
        UserProfile.Department
    ),
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

// Get effective department scope for datasource filtering
GetDepartmentScope(): Text =
    If(UserRoles.IsAdmin, Blank(), UserProfile.Department);

// Check if current user can access a specific record by owner
CanAccessRecord(ownerEmail: Text): Boolean =
    UserPermissions.CanViewAll ||
    IsBlank(ownerEmail) ||
    Lower(ownerEmail) = Lower(User().Email);

// Check if current user can access records in a department
CanAccessDepartment(recordDepartment: Text): Boolean =
    UserRoles.IsAdmin ||
    IsBlank(recordDepartment) ||
    recordDepartment = UserProfile.Department;

// Combined access check for owner AND department
CanAccessItem(ownerEmail: Text, department: Text): Boolean =
    CanAccessRecord(ownerEmail) && CanAccessDepartment(department);

// Check if user can edit a specific record
CanEditRecord(ownerEmail: Text, status: Text): Boolean =
    UserPermissions.CanEdit &&
    CanAccessRecord(ownerEmail) &&
    !IsOneOf(Lower(status), "archived,closed,cancelled");

// Check if user can delete a specific record
CanDeleteRecord(ownerEmail: Text): Boolean =
    UserPermissions.CanDelete && CanAccessRecord(ownerEmail);


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

// Standard success notification
NotifySuccess(message: Text): Void = {
    Notify(message, NotificationType.Success);
};

// Standard error notification
NotifyError(message: Text): Void = {
    Notify(message, NotificationType.Error);
};

// Standard warning notification
NotifyWarning(message: Text): Void = {
    Notify(message, NotificationType.Warning);
};

// Standard info notification
NotifyInfo(message: Text): Void = {
    Notify(message, NotificationType.Information);
};

// Permission denied notification with action context
NotifyPermissionDenied(action: Text): Void = {
    Notify(
        "Permission denied: You do not have access to " & Lower(action),
        NotificationType.Error
    );
};

// Action completed notification
NotifyActionCompleted(action: Text, itemName: Text): Void = {
    Notify(
        action & " completed: " & itemName,
        NotificationType.Success
    );
};

// Validation error notification
NotifyValidationError(fieldName: Text, message: Text): Void = {
    Notify(
        fieldName & ": " & message,
        NotificationType.Warning
    );
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
// END OF APP.FORMULAS
// ============================================================
