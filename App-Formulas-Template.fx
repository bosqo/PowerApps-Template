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
    WeightRegular: Font.'Segoe UI',
    WeightSemibold: Font.'Segoe UI Semibold',
    WeightBold: Font.'Segoe UI Bold',

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
    IsProduction: Param("environment") = "prod",
    IsDevelopment: Param("environment") <> "prod",

    // API Configuration
    ApiBaseUrl: If(
        Param("environment") = "prod",
        "https://api.yourcompany.com/prod",
        "https://api.yourcompany.com/dev"
    ),

    // Data Settings
    ItemsPerPage: 50,
    MaxSearchResults: 500,
    CacheExpiryMinutes: 5,
    AutoRefreshEnabled: true,
    AutoRefreshIntervalSeconds: 300,

    // Feature Limits
    MaxFileUploadMB: 10,
    MaxBulkOperationItems: 100,
    MaxExportRecords: 5000
};


// ============================================================
// SECTION 2: COMPUTED NAMED FORMULAS
// These auto-refresh when their dependencies change
// ============================================================

// Date Range Calculations - Recomputed daily
DateRanges = {
    // Current Date References
    Today: Today(),
    Now: Now(),
    CurrentYear: Year(Today()),
    CurrentMonth: Month(Today()),
    CurrentQuarter: RoundUp(Month(Today()) / 3, 0),

    // Period Starts
    StartOfWeek: DateAdd(Today(), -(Weekday(Today()) - 1), TimeUnit.Days),
    StartOfMonth: Date(Year(Today()), Month(Today()), 1),
    StartOfQuarter: Date(
        Year(Today()),
        (RoundUp(Month(Today()) / 3, 0) - 1) * 3 + 1,
        1
    ),
    StartOfYear: Date(Year(Today()), 1, 1),

    // Period Ends
    EndOfWeek: DateAdd(Today(), 7 - Weekday(Today()), TimeUnit.Days),
    EndOfMonth: DateAdd(
        DateAdd(Date(Year(Today()), Month(Today()), 1), 1, TimeUnit.Months),
        -1,
        TimeUnit.Days
    ),
    EndOfQuarter: DateAdd(
        DateAdd(
            Date(Year(Today()), (RoundUp(Month(Today()) / 3, 0) - 1) * 3 + 1, 1),
            3,
            TimeUnit.Months
        ),
        -1,
        TimeUnit.Days
    ),
    EndOfYear: Date(Year(Today()), 12, 31),

    // Rolling Periods
    Last7Days: DateAdd(Today(), -7, TimeUnit.Days),
    Last14Days: DateAdd(Today(), -14, TimeUnit.Days),
    Last30Days: DateAdd(Today(), -30, TimeUnit.Days),
    Last60Days: DateAdd(Today(), -60, TimeUnit.Days),
    Last90Days: DateAdd(Today(), -90, TimeUnit.Days),
    Last180Days: DateAdd(Today(), -180, TimeUnit.Days),
    Last365Days: DateAdd(Today(), -365, TimeUnit.Days),

    // Future Periods
    Next7Days: DateAdd(Today(), 7, TimeUnit.Days),
    Next14Days: DateAdd(Today(), 14, TimeUnit.Days),
    Next30Days: DateAdd(Today(), 30, TimeUnit.Days),
    Next90Days: DateAdd(Today(), 90, TimeUnit.Days)
};

// User Profile - Lazy-loaded from Office365Users connector
// This is fetched ONCE when first accessed and cached
UserProfile = With(
    { profile: Office365Users.MyProfileV2() },
    {
        // Identity
        Email: User().Email,
        FullName: User().FullName,
        Id: Lower(User().Email),  // Use email as unique ID

        // Office365 Profile Data
        JobTitle: Coalesce(profile.jobTitle, ""),
        Department: Coalesce(profile.department, ""),
        OfficeLocation: Coalesce(profile.officeLocation, ""),
        City: Coalesce(profile.city, ""),
        Country: Coalesce(profile.country, ""),
        MobilePhone: Coalesce(profile.mobilePhone, ""),
        BusinessPhone: Coalesce(profile.businessPhones, ""),
        Manager: Coalesce(profile.manager, ""),

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

// User Roles - Determined from Security Groups and Profile
// Update the Group IDs to match your Azure AD configuration
UserRoles = {
    // ===========================================
    // Method 1: Security Group Membership (RECOMMENDED)
    // Replace with your actual Azure AD Security Group GUIDs
    // ===========================================
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

    // All authenticated users are Users
    IsUser: true,

    // ===========================================
    // Method 2: Email Domain-Based Roles
    // Useful for distinguishing internal vs external users
    // ===========================================
    IsCorporate: EndsWith(Lower(User().Email), "@yourcompany.com"),
    IsExternal: !EndsWith(Lower(User().Email), "@yourcompany.com"),
    IsGuest: Contains(Lower(User().Email), "#ext#"),

    // ===========================================
    // Method 3: Department-Based Roles
    // Auto-populated from Office365 profile
    // ===========================================
    IsSales: UserProfile.Department = "Sales",
    IsFinance: UserProfile.Department = "Finance",
    IsIT: UserProfile.Department = "IT",
    IsHR: UserProfile.Department = "Human Resources",
    IsOperations: UserProfile.Department = "Operations",
    IsMarketing: UserProfile.Department = "Marketing",

    // ===========================================
    // Method 4: Job Title-Based Roles
    // For title-specific permissions
    // ===========================================
    IsExecutive: Contains(Lower(UserProfile.JobTitle), "director") ||
                 Contains(Lower(UserProfile.JobTitle), "vp") ||
                 Contains(Lower(UserProfile.JobTitle), "chief") ||
                 Contains(Lower(UserProfile.JobTitle), "president"),

    IsSupervisor: Contains(Lower(UserProfile.JobTitle), "lead") ||
                  Contains(Lower(UserProfile.JobTitle), "supervisor") ||
                  Contains(Lower(UserProfile.JobTitle), "team lead")
};

// User Permissions - Derived from Roles
// Automatically updates when UserRoles changes
UserPermissions = {
    // CRUD Permissions
    CanCreate: UserRoles.IsAdmin || UserRoles.IsManager,
    CanRead: true,  // All users can read (filtered by scope)
    CanEdit: UserRoles.IsAdmin || UserRoles.IsManager || UserRoles.IsUser,
    CanDelete: UserRoles.IsAdmin,

    // Scope Permissions
    CanViewAll: UserRoles.IsAdmin || UserRoles.IsManager,
    CanViewOwn: true,
    CanViewDepartment: UserRoles.IsAdmin || UserRoles.IsManager || UserRoles.IsSupervisor,

    // Feature Permissions
    CanExport: UserRoles.IsAdmin || UserRoles.IsManager,
    CanImport: UserRoles.IsAdmin,
    CanBulkOperations: UserRoles.IsAdmin,
    CanManageUsers: UserRoles.IsAdmin,
    CanViewAuditLog: UserRoles.IsAdmin,
    CanConfigureSettings: UserRoles.IsAdmin,

    // Special Permissions
    CanApprove: UserRoles.IsAdmin || UserRoles.IsManager,
    CanReject: UserRoles.IsAdmin || UserRoles.IsManager,
    CanArchive: UserRoles.IsAdmin || UserRoles.IsManager,
    CanRestore: UserRoles.IsAdmin
};

// Dynamic Role-Based Color
RoleColor = Switch(
    true,
    UserRoles.IsAdmin, ThemeColors.Error,        // Red for Admin
    UserRoles.IsManager, ThemeColors.Primary,     // Blue for Manager
    UserRoles.IsSupervisor, ThemeColors.Warning,  // Amber for Supervisor
    ThemeColors.Success                           // Green for User
);

// Role Badge Text
RoleBadgeText = Switch(
    true,
    UserRoles.IsAdmin, "Admin",
    UserRoles.IsManager, "Manager",
    UserRoles.IsSupervisor, "Lead",
    UserRoles.IsExecutive, "Executive",
    "User"
);

// Feature Flags - Control feature availability
FeatureFlags = {
    // Search Features
    EnableAdvancedSearch: UserRoles.IsAdmin || UserRoles.IsManager,
    EnableGlobalSearch: true,
    EnableSavedFilters: UserRoles.IsAdmin || UserRoles.IsManager,

    // Data Features
    EnableBulkOperations: UserRoles.IsAdmin,
    EnableExport: UserPermissions.CanExport,
    EnableImport: UserPermissions.CanImport,
    EnableOfflineMode: false,

    // UI Features
    EnableDarkMode: false,
    EnableCompactView: true,
    EnableKeyboardShortcuts: true,
    EnableNotifications: true,

    // Debug Features (Development only)
    ShowDebugInfo: Param("debug") = "true" && UserRoles.IsAdmin,
    ShowPerformanceMetrics: Param("perf") = "true" && UserRoles.IsAdmin,
    EnableMockData: Param("mock") = "true" && AppConfig.IsDevelopment,

    // Audit Features
    EnableAuditLog: UserRoles.IsAdmin,
    EnableActivityTracking: true
};

// Default Filter Configuration (reactive to permissions)
DefaultFilters = {
    UserScope: If(UserPermissions.CanViewAll, Blank(), User().Email),
    DepartmentScope: If(
        UserRoles.IsAdmin,
        Blank(),
        UserProfile.Department
    ),
    DateRangeStart: DateRanges.StartOfMonth,
    DateRangeEnd: DateRanges.Today,
    ActiveOnly: true,
    IncludeArchived: false
};


// ============================================================
// SECTION 3: USER DEFINED FUNCTIONS (UDFs)
// Reusable functions that can be called from any control
// ============================================================

// -----------------------------------------------------------
// Permission & Role Check Functions
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
        "viewdepartment", UserPermissions.CanViewDepartment,
        "export", UserPermissions.CanExport,
        "import", UserPermissions.CanImport,
        "bulk", UserPermissions.CanBulkOperations,
        "manageusers", UserPermissions.CanManageUsers,
        "audit", UserPermissions.CanViewAuditLog,
        "settings", UserPermissions.CanConfigureSettings,
        "approve", UserPermissions.CanApprove,
        "reject", UserPermissions.CanReject,
        "archive", UserPermissions.CanArchive,
        "restore", UserPermissions.CanRestore,
        false
    );

// Check if user has a specific role by name
HasRole(roleName: Text): Boolean =
    Switch(
        Lower(roleName),
        "admin", UserRoles.IsAdmin,
        "manager", UserRoles.IsManager,
        "user", UserRoles.IsUser,
        "supervisor", UserRoles.IsSupervisor,
        "executive", UserRoles.IsExecutive,
        "corporate", UserRoles.IsCorporate,
        "external", UserRoles.IsExternal,
        "guest", UserRoles.IsGuest,
        "sales", UserRoles.IsSales,
        "finance", UserRoles.IsFinance,
        "it", UserRoles.IsIT,
        "hr", UserRoles.IsHR,
        "operations", UserRoles.IsOperations,
        "marketing", UserRoles.IsMarketing,
        false
    );

// Check if user has any of the specified roles (comma-separated)
// Refactored 2025: Now properly handles unlimited roles instead of hardcoded 3
HasAnyRole(roleNames: Text): Boolean =
    CountRows(
        Filter(
            Split(roleNames, ","),
            HasRole(Trim(Value))
        )
    ) > 0;

// Check if user has ALL of the specified roles (comma-separated)
// Added 2025: Complement to HasAnyRole for AND logic
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
        UserRoles.IsManager, "Manager",
        UserRoles.IsSupervisor, "Team Lead",
        UserRoles.IsExecutive, "Executive",
        UserRoles.IsSales, "Sales Rep",
        UserRoles.IsFinance, "Finance Analyst",
        UserRoles.IsIT, "IT Specialist",
        UserRoles.IsHR, "HR Specialist",
        "Team Member"
    );

// Get role badge color for display
GetRoleBadgeColor(): Color = RoleColor;

// Get role badge text (short form)
GetRoleBadge(): Text = RoleBadgeText;


// -----------------------------------------------------------
// Access Control Functions
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
// Theme & Color Functions
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
        "completed", ThemeColors.Success,
        "done", ThemeColors.Success,
        "published", ThemeColors.Success,
        "resolved", ThemeColors.Success,
        // In Progress
        "in progress", ThemeColors.Primary,
        "processing", ThemeColors.Primary,
        "reviewing", ThemeColors.Primary,
        "pending review", ThemeColors.Primary,
        // Warning/Pending
        "pending", ThemeColors.Warning,
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
        "failed", ThemeColors.Error,
        "error", ThemeColors.Error,
        "overdue", ThemeColors.Error,
        "blocked", ThemeColors.Error,
        // Default
        ThemeColors.Text
    );

// Get status icon name (for use with Icon control)
GetStatusIcon(status: Text): Icon =
    Switch(
        Lower(status),
        "active", Icon.CheckmarkCircle,
        "completed", Icon.CheckmarkCircle,
        "approved", Icon.CheckmarkCircle,
        "in progress", Icon.Clock,
        "pending", Icon.Clock,
        "draft", Icon.Edit,
        "cancelled", Icon.CancelBadge,
        "rejected", Icon.CancelBadge,
        "error", Icon.Warning,
        "archived", Icon.DocumentSet,
        Icon.CircleHollow
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
// Date Functions
// -----------------------------------------------------------

// Get date range start by name
GetDateRangeStart(rangeName: Text): Date =
    Switch(
        Lower(rangeName),
        "today", DateRanges.Today,
        "thisweek", DateRanges.StartOfWeek,
        "thismonth", DateRanges.StartOfMonth,
        "thisquarter", DateRanges.StartOfQuarter,
        "thisyear", DateRanges.StartOfYear,
        "last7days", DateRanges.Last7Days,
        "last14days", DateRanges.Last14Days,
        "last30days", DateRanges.Last30Days,
        "last60days", DateRanges.Last60Days,
        "last90days", DateRanges.Last90Days,
        "last180days", DateRanges.Last180Days,
        "last365days", DateRanges.Last365Days,
        "lastyear", DateRanges.Last365Days,
        DateRanges.StartOfMonth
    );

// Get date range end by name
GetDateRangeEnd(rangeName: Text): Date =
    Switch(
        Lower(rangeName),
        "today", DateRanges.Today,
        "thisweek", DateRanges.EndOfWeek,
        "thismonth", DateRanges.EndOfMonth,
        "thisquarter", DateRanges.EndOfQuarter,
        "thisyear", DateRanges.EndOfYear,
        "next7days", DateRanges.Next7Days,
        "next14days", DateRanges.Next14Days,
        "next30days", DateRanges.Next30Days,
        "next90days", DateRanges.Next90Days,
        DateRanges.Today
    );

// Check if a date is within a named range
IsWithinDateRange(checkDate: Date, rangeName: Text): Boolean =
    checkDate >= GetDateRangeStart(rangeName) &&
    checkDate <= GetDateRangeEnd(rangeName);

// Check if a date is today
IsToday(checkDate: Date): Boolean =
    checkDate = Today();

// Check if a date is in the past
IsPastDate(checkDate: Date): Boolean =
    checkDate < Today();

// Check if a date is in the future
IsFutureDate(checkDate: Date): Boolean =
    checkDate > Today();

// Check if a date is overdue (past due date)
IsOverdue(dueDate: Date): Boolean =
    !IsBlank(dueDate) && dueDate < Today();

// Get days until/since a date (negative = past, positive = future)
GetDaysDifference(targetDate: Date): Number =
    DateDiff(Today(), targetDate, TimeUnit.Days);

// Format date as relative text (Today, Yesterday, X days ago, etc.)
FormatDateRelative(inputDate: DateTime): Text =
    With(
        { daysDiff: DateDiff(DateValue(inputDate), Today(), TimeUnit.Days) },
        Switch(
            true,
            daysDiff = 0, "Today",
            daysDiff = 1, "Yesterday",
            daysDiff = -1, "Tomorrow",
            daysDiff > 1 && daysDiff < 7, Text(daysDiff) & " days ago",
            daysDiff < -1 && daysDiff > -7, "In " & Text(-daysDiff) & " days",
            daysDiff >= 7 && daysDiff < 14, "Last week",
            daysDiff >= 14 && daysDiff < 30, Text(RoundDown(daysDiff / 7, 0)) & " weeks ago",
            daysDiff >= 30 && daysDiff < 60, "Last month",
            daysDiff >= 60 && daysDiff < 365, Text(RoundDown(daysDiff / 30, 0)) & " months ago",
            daysDiff >= 365, Text(RoundDown(daysDiff / 365, 0)) & " year(s) ago",
            daysDiff <= -7 && daysDiff > -14, "Next week",
            daysDiff <= -14 && daysDiff > -30, "In " & Text(RoundDown(-daysDiff / 7, 0)) & " weeks",
            Text(inputDate, "[$-en-US]mmm d, yyyy")
        )
    );

// Format date for display (short format)
FormatDateShort(inputDate: Date): Text =
    Text(inputDate, "[$-en-US]mm/dd/yyyy");

// Format date for display (long format)
FormatDateLong(inputDate: Date): Text =
    Text(inputDate, "[$-en-US]mmmm d, yyyy");

// Format datetime for display
FormatDateTime(inputDateTime: DateTime): Text =
    Text(inputDateTime, "[$-en-US]mmm d, yyyy h:mm AM/PM");


// -----------------------------------------------------------
// Notification Functions
// -----------------------------------------------------------

// Standard success notification
NotifySuccess(message: Text): Boolean =
    Notify(message, NotificationType.Success);

// Standard error notification
NotifyError(message: Text): Boolean =
    Notify(message, NotificationType.Error);

// Standard warning notification
NotifyWarning(message: Text): Boolean =
    Notify(message, NotificationType.Warning);

// Standard info notification
NotifyInfo(message: Text): Boolean =
    Notify(message, NotificationType.Information);

// Permission denied notification with action context
NotifyPermissionDenied(action: Text): Boolean =
    Notify(
        "Permission denied: You do not have access to " & Lower(action),
        NotificationType.Error
    );

// Action completed notification
NotifyActionCompleted(action: Text, itemName: Text): Boolean =
    Notify(
        action & " completed: " & itemName,
        NotificationType.Success
    );

// Validation error notification
NotifyValidationError(fieldName: Text, message: Text): Boolean =
    Notify(
        fieldName & ": " & message,
        NotificationType.Warning
    );


// -----------------------------------------------------------
// Validation Functions
// -----------------------------------------------------------

// Check if text is blank or empty (whitespace only)
// Added 2025: Common helper for null/empty string checks
IsBlankOrEmpty(input: Text): Boolean =
    IsBlank(input) || Len(Trim(input)) = 0;

// Validate email format
// Refactored 2025: Stronger validation with additional checks
IsValidEmail(email: Text): Boolean =
    !IsBlankOrEmpty(email) &&
    !Contains(email, " ") &&
    CountRows(Split(email, "@")) = 2 &&
    Len(First(Split(email, "@")).Value) >= 1 &&
    Len(Last(Split(email, "@")).Value) > 3 &&
    Contains(Last(Split(email, "@")).Value, ".") &&
    !StartsWith(Last(Split(email, "@")).Value, ".") &&
    !EndsWith(Last(Split(email, "@")).Value, ".");

// Check if text is within length limits
IsValidLength(input: Text, minLen: Number, maxLen: Number): Boolean =
    Len(Coalesce(input, "")) >= minLen &&
    Len(Coalesce(input, "")) <= maxLen;

// Check if a value is in a set of allowed values (comma-separated)
// Refactored 2025: Fixed incorrect ForAll/in pattern
IsOneOf(value: Text, allowedValues: Text): Boolean =
    CountRows(
        Filter(
            Split(allowedValues, ","),
            Lower(Trim(Value)) = Lower(Coalesce(value, ""))
        )
    ) > 0;

// Check if text contains only alphanumeric characters
IsAlphanumeric(input: Text): Boolean =
    IsMatch(input, "^[a-zA-Z0-9]+$");

// Check if text is a valid phone number (basic check)
IsValidPhone(phone: Text): Boolean =
    !IsBlank(phone) &&
    Len(Substitute(Substitute(Substitute(Substitute(phone, " ", ""), "-", ""), "(", ""), ")", "")) >= 10;

// Check if a required field has a value
IsRequired(value: Text): Boolean =
    !IsBlank(Trim(Coalesce(value, "")));

// Validate date is not in the past
IsNotPastDate(inputDate: Date): Boolean =
    IsBlank(inputDate) || inputDate >= Today();

// Validate date is within acceptable range
IsDateInRange(inputDate: Date, minDate: Date, maxDate: Date): Boolean =
    inputDate >= minDate && inputDate <= maxDate;


// -----------------------------------------------------------
// Pagination Functions (Added 2025)
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
// Text Formatting Functions
// -----------------------------------------------------------

// Truncate text with ellipsis
TruncateText(input: Text, maxLength: Number): Text =
    If(
        Len(Coalesce(input, "")) > maxLength,
        Left(input, maxLength - 3) & "...",
        Coalesce(input, "")
    );

// Format number as currency
FormatCurrency(amount: Number, currencySymbol: Text): Text =
    Coalesce(currencySymbol, "$") & Text(amount, "#,##0.00");

// Format number as percentage
FormatPercent(value: Number, decimals: Number): Text =
    Text(value * 100, "#,##0." & Left("000000", decimals)) & "%";

// Format number with thousand separators
FormatNumber(value: Number): Text =
    Text(value, "#,##0");

// Get initials from full name
GetInitials(fullName: Text): Text =
    Upper(
        Left(Coalesce(fullName, "?"), 1) &
        If(
            Contains(fullName, " "),
            Mid(fullName, Find(" ", fullName) + 1, 1),
            ""
        )
    );

// Convert text to title case (first letter of each word capitalized)
ToTitleCase(input: Text): Text =
    Concat(
        Split(Lower(Coalesce(input, "")), " "),
        Upper(Left(Value, 1)) & Mid(Value, 2, Len(Value)),
        " "
    );


// ============================================================
// END OF APP.FORMULAS
// ============================================================
