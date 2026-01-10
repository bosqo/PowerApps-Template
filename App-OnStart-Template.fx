// ============================================================
// CANVAS APP - APP.ONSTART TEMPLATE (CORRECTED)
// User Role Determination + Datasource Prefiltering
// ============================================================
// Copy this formula to your Canvas App's App.OnStart property
//
// ⚠️ IMPORTANT NOTES:
// - Verify Office365Users.MyProfileV2() works in your environment
//   (Some may need MyProfile() instead - check IntelliSense)
// - Update YOUR-ADMIN-GROUP-ID and YOUR-MANAGER-GROUP-ID with actual Azure AD group IDs
// - Test each connector function before deployment

// ============================================================
// 1. USER PROFILE & ROLE DETERMINATION
// ============================================================

// Step 1a: Load Office365 profile (single API call for performance)
With(
    {profile: Office365Users.MyProfileV2()},

    // Step 1b: Set user profile and roles
    Set(App.User, {
        // Basic Profile
        Email: User().Email,
        FullName: User().FullName,
        JobTitle: If(IsBlank(profile.jobTitle), "", profile.jobTitle),
        Department: If(IsBlank(profile.department), "", profile.department),
        OfficeLocation: If(IsBlank(profile.officeLocation), "", profile.officeLocation),
        MobilePhone: If(IsBlank(profile.mobilePhone), "", profile.mobilePhone),

        // Role Determination - UPDATE GROUP IDs BELOW
        Roles: {
            // Method 1: Security Group Membership (RECOMMENDED)
            IsAdmin: !IsBlank(
                LookUp(
                    Office365Groups.ListGroupMembers("YOUR-ADMIN-GROUP-ID"),
                    mail = User().Email
                )
            ),
            IsManager: !IsBlank(
                LookUp(
                    Office365Groups.ListGroupMembers("YOUR-MANAGER-GROUP-ID"),
                    mail = User().Email
                )
            ),
            IsUser: true,

            // Method 2: Email-based (fallback)
            IsCorporate: EndsWith(Lower(User().Email), "@yourcompany.com"),
            IsExternal: !EndsWith(Lower(User().Email), "@yourcompany.com"),

            // Method 3: Dataverse custom roles (optional - comment out if not using)
            CustomRole: If(
                IsBlank(LookUp('User Roles', 'User Email' = User().Email)),
                "User",
                LookUp('User Roles', 'User Email' = User().Email).'Role Name'
            ),

            // Method 4: Department-based
            IsSales: profile.department = "Sales",
            IsFinance: profile.department = "Finance",
            IsIT: profile.department = "IT"
        }
    })
);

// Step 2: Set permissions based on roles (separate step to avoid circular reference)
Set(App.User,
    Patch(App.User, {
        Permissions: {
            CanCreate: App.User.Roles.IsAdmin || App.User.Roles.IsManager,
            CanEdit: App.User.Roles.IsAdmin || App.User.Roles.IsManager || App.User.Roles.IsUser,
            CanDelete: App.User.Roles.IsAdmin,
            CanExport: App.User.Roles.IsAdmin || App.User.Roles.IsManager,
            CanViewAll: App.User.Roles.IsAdmin || App.User.Roles.IsManager,
            CanViewOwn: true
        }
    })
);

// ============================================================
// 2. DATASOURCE PREFILTERING PLACEHOLDERS
// ============================================================
Set(Data.Filter, {
    // User Scope - Blank() for admins, User().Email for regular users
    UserScope: If(
        App.User.Permissions.CanViewAll,
        Blank(),
        User().Email
    ),

    // Department Scope (use cached value from App.User)
    DepartmentScope: If(
        App.User.Roles.IsAdmin,
        Blank(),
        App.User.Department
    ),

    // Date Range Filters
    DateRange: {
        Today: Today(),
        ThisWeek: Today() - Weekday(Today()) + 1,
        ThisMonth: Date(Year(Today()), Month(Today()), 1),
        ThisQuarter: Date(Year(Today()), (Ceiling(Month(Today())/3) - 1) * 3 + 1, 1),
        ThisYear: Date(Year(Today()), 1, 1),
        Last30Days: Today() - 30,
        Last90Days: Today() - 90,
        Last365Days: Today() - 365
    },

    // Status Filters
    ActiveOnly: true,
    IncludeArchived: false,

    // Custom Filters (set dynamically per screen)
    Custom: {
        SearchTerm: "",
        Category: Blank(),
        Status: Blank(),
        Priority: Blank(),
        Owner: Blank()
    }
});

// ============================================================
// 3. APPLICATION CONFIGURATION
// ============================================================
Set(App.Config, {
    Environment: If(Param("environment") = "prod", "Production", "Development"),
    ApiUrl: If(Param("environment") = "prod", "https://api.company.com/prod", "https://api.company.com/dev"),

    // Feature Flags (role-based)
    Features: {
        EnableAdvancedSearch: App.User.Roles.IsAdmin || App.User.Roles.IsManager,
        EnableBulkOperations: App.User.Roles.IsAdmin,
        EnableExport: App.User.Permissions.CanExport,
        EnableAuditLog: App.User.Roles.IsAdmin,
        ShowDebugInfo: Param("debug") = "true" && App.User.Roles.IsAdmin
    },

    // Data Settings
    CacheExpiry: 5,
    AutoRefresh: true,
    ItemsPerPage: 50,
    MaxSearchResults: 500
});

// ============================================================
// 4. THEME & STYLING
// ============================================================
Set(App.Themes, {
    Primary: ColorValue("#0078D4"),
    Secondary: ColorValue("#50E6FF"),
    Success: ColorValue("#107C10"),
    Warning: ColorValue("#FFB900"),
    Error: ColorValue("#D13438"),
    Background: ColorValue("#F3F2F1"),
    Surface: ColorValue("#FFFFFF"),
    Text: ColorValue("#201F1E"),
    TextSecondary: ColorValue("#605E5C"),
    Border: ColorValue("#EDEBE9"),

    // Dynamic role color
    RoleColor: Switch(
        true,
        App.User.Roles.IsAdmin, ColorValue("#D13438"),
        App.User.Roles.IsManager, ColorValue("#0078D4"),
        ColorValue("#107C10")
    )
});

// ============================================================
// 5. APPLICATION STATE
// ============================================================
Set(App.State, {
    IsLoading: false,
    CurrentScreen: "Home",
    LastRefresh: Now(),
    SessionStart: Now(),
    IsOnline: Connection.Connected,
    LastError: Blank(),
    ShowError: false
});

// ============================================================
// 6. DATA CACHE - Initial Load
// ============================================================

// Load commonly used lookup data
ClearCollect(
    Data.Cache.Departments,
    Filter(Departments, Status = "Active")
);

ClearCollect(
    Data.Cache.Categories,
    Filter(Categories, Status = "Active")
);

// Load user-specific data with prefiltering
ClearCollect(
    Data.Cache.MyItems,
    Filter(
        Items,
        // Apply user scope filter
        If(
            IsBlank(Data.Filter.UserScope),
            true,
            Owner.Email = Data.Filter.UserScope
        ),
        // Apply active filter
        Status <> "Archived",
        // Apply date filter
        'Created On' >= Data.Filter.DateRange.Last90Days
    )
);

// ============================================================
// USAGE EXAMPLES
// ============================================================

/*
// ==============================================================================
// USAGE EXAMPLES (Copy these patterns to your controls)
// ==============================================================================

// EXAMPLE 1: Gallery with User Scope Filter
// Gallery.Items
Filter(
    Orders,
    If(IsBlank(Data.Filter.UserScope), true, 'Assigned To'.Email = Data.Filter.UserScope),
    StartsWith(Lower('Order Number'), Lower(Data.Filter.Custom.SearchTerm))
)

// EXAMPLE 2: Conditional Button Visibility
// Button_Delete.Visible
App.User.Permissions.CanDelete

// EXAMPLE 3: Role-based Welcome Text
// Label_Welcome.Text
"Welcome " & App.User.FullName & " (" &
Switch(true,
    App.User.Roles.IsAdmin, "Administrator",
    App.User.Roles.IsManager, "Manager",
    "User"
) & ")"

// EXAMPLE 4: Permission Check in Button OnSelect
// Button_Delete.OnSelect
If(
    App.User.Permissions.CanDelete,
    Remove(Items, Gallery.Selected);
    Notify("Deleted successfully", NotificationType.Success),
    Notify("No permission to delete", NotificationType.Error)
)

// EXAMPLE 5: Export Data via Power Automate (NO built-in Export() function exists!)
// Button_Export.OnSelect
If(
    App.User.Permissions.CanExport,
    // Trigger a Power Automate flow to export data
    'YourExportFlow'.Run(
        JSON(Filter(
            Orders,
            If(IsBlank(Data.Filter.UserScope), true, Owner.Email = Data.Filter.UserScope)
        ))
    );
    Notify("Export started - you'll receive an email with the file", NotificationType.Success),
    Notify("Export permission required", NotificationType.Error)
)

// EXAMPLE 6: Screen-level Filter Override
// Screen.OnVisible
Set(Screen.State, {
    SelectedItem: Blank(),
    IsEditing: false,
    LocalFilters: {
        DateFrom: Data.Filter.DateRange.ThisMonth,
        DateTo: Today(),
        StatusFilter: "In Progress"
    }
})

// EXAMPLE 7: Dynamic Filter Toggle
// Toggle_ShowAll.OnChange
Set(Data.Filter,
    Patch(Data.Filter, {
        UserScope: If(
            Self.Value && App.User.Permissions.CanViewAll,
            Blank(),  // Show all
            User().Email  // Show own only
        )
    })
);
Notify("Filter updated", NotificationType.Information)

*/
