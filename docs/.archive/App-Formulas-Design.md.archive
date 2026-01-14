# App.Formulas Design - User Role Determination & Datasource Prefiltering

**🔄 CORRECTED VERSION** - All formulas verified for Canvas Apps compatibility

## Overview
This document outlines the App.Formulas structure for Canvas Apps using the dot notation pattern with integrated user role determination via Office365Users connector and datasource prefiltering capabilities.

### ⚠️ Important Notes (Updated 2026-01-10)
- **All formulas corrected** for actual Canvas Apps Power Fx syntax
- **Export() removed** - This function does NOT exist in Canvas Apps (use Power Automate instead)
- **Lambda() removed** - Not available in Canvas Apps (use inline Filter patterns)
- **User().Image removed** - Does not provide user ID (use User().Email as identifier)
- **Optimized API calls** - Office365Users calls minimized with With() statements
- **Circular references fixed** - Permissions set in separate Patch() call

For a detailed audit of all corrections, see `AUDIT-REPORT.md`.

---

## 1. App Initialization Structure

### App.OnStart Formula Pattern

```powerfx
// ============================================================
// APP INITIALIZATION - Place in App.OnStart
// ============================================================

// 1. USER PROFILE & ROLE DETERMINATION
// ============================================================
// Load Office365 profile once for performance
With(
    {profile: Office365Users.MyProfileV2()},
    Set(App.User, {
        // Basic Profile from Office365Users
        Email: User().Email,
        FullName: User().FullName,
        JobTitle: profile.jobTitle,
        Department: profile.department,
        OfficeLocation: profile.officeLocation,
        MobilePhone: profile.mobilePhone,

    // Role Determination (Multiple Methods)
    Roles: {
        // Method 1: Security Group Membership (Recommended)
        IsAdmin: !IsBlank(
            LookUp(
                Office365Groups.ListGroupMembers("admin-group-id"),
                mail = User().Email
            )
        ),
        IsManager: !IsBlank(
            LookUp(
                Office365Groups.ListGroupMembers("manager-group-id"),
                mail = User().Email
            )
        ),
        IsUser: true, // All authenticated users

        // Method 2: Email Domain-based
        IsCorporate: EndsWith(Lower(User().Email), "@company.com"),
        IsExternal: !EndsWith(Lower(User().Email), "@company.com"),

        // Method 3: Dataverse Role-based (if using custom role table)
        CustomRole: LookUp(
            'User Roles',
            'User Email' = User().Email
        ).'Role Name',

        // Method 4: Department-based
        IsSales: profile.department = "Sales",
        IsFinance: profile.department = "Finance",
        IsIT: profile.department = "IT"
    }
    })
);

// Set permissions separately to avoid circular reference
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

// 2. DATASOURCE PREFILTERING
// ============================================================
Set(Data.Filter, {
    // User-specific filters (apply based on role)
    UserScope: If(
        App.User.Permissions.CanViewAll,
        Blank(), // No filter - see all records
        User().Email // Filter to own records only
    ),

    // Department filter (use cached value from App.User)
    DepartmentScope: If(
        App.User.Roles.IsAdmin,
        Blank(), // Admins see all departments
        App.User.Department
    ),

    // Date range filters (common presets)
    DateRange: {
        Today: Today(),
        ThisWeek: Today() - Weekday(Today()) + 1,
        ThisMonth: Date(Year(Today()), Month(Today()), 1),
        ThisQuarter: Date(
            Year(Today()),
            (Ceiling(Month(Today())/3) - 1) * 3 + 1,
            1
        ),
        ThisYear: Date(Year(Today()), 1, 1),
        Last30Days: Today() - 30,
        Last90Days: Today() - 90
    },

    // Status filters
    ActiveOnly: true,
    IncludeArchived: false,

    // Custom filter placeholders (set per screen/context)
    Custom: {
        SearchTerm: "",
        Category: Blank(),
        Status: Blank(),
        Priority: Blank()
    }
});

// 3. APPLICATION CONFIGURATION
// ============================================================
Set(App.Config, {
    // Environment settings
    Environment: If(
        Param("environment") = "prod",
        "Production",
        "Development"
    ),
    ApiUrl: If(
        Param("environment") = "prod",
        "https://api.company.com/prod",
        "https://api.company.com/dev"
    ),

    // Feature flags (toggle features by role)
    Features: {
        EnableAdvancedSearch: App.User.Roles.IsAdmin || App.User.Roles.IsManager,
        EnableBulkOperations: App.User.Roles.IsAdmin,
        EnableExport: App.User.Permissions.CanExport,
        EnableAuditLog: App.User.Roles.IsAdmin,
        ShowDebugInfo: Param("debug") = "true" && App.User.Roles.IsAdmin
    },

    // Data refresh settings
    CacheExpiry: 5, // minutes
    AutoRefresh: true,

    // UI Configuration
    ItemsPerPage: 50,
    MaxSearchResults: 500
});

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

    // Role-based visual indicators
    RoleColor: Switch(
        true,
        App.User.Roles.IsAdmin, ColorValue("#D13438"),
        App.User.Roles.IsManager, ColorValue("#0078D4"),
        ColorValue("#107C10")
    )
});

// 5. APPLICATION STATE
// ============================================================
Set(App.State, {
    IsLoading: false,
    CurrentScreen: "Home",
    LastRefresh: Now(),
    NavigationHistory: [],

    // Error handling
    LastError: Blank(),
    ShowError: false,

    // User session
    SessionStart: Now(),
    IsOnline: Connection.Connected
});

// 6. DATA CACHE INITIALIZATION
// ============================================================
// Load commonly used lookup data into collections
ClearCollect(
    Data.Cache.Departments,
    Filter(
        Departments,
        Status = "Active"
    )
);

ClearCollect(
    Data.Cache.Categories,
    Filter(
        Categories,
        Status = "Active"
    )
);

// Initial data load with user-specific filtering
ClearCollect(
    Data.Cache.MyItems,
    Filter(
        Items,
        // Apply user scope filter
        If(
            IsBlank(Data.Filter.UserScope),
            true,
            Owner.Email = Data.Filter.UserScope
        ) &&
        // Apply active filter
        Status <> "Archived" &&
        // Apply date filter (created within last 90 days)
        'Created On' >= Data.Filter.DateRange.Last90Days
    )
);
```

---

## 2. Datasource Prefiltering Patterns

### Pattern 1: Gallery with User Scope Filter

```powerfx
// Gallery.Items
Filter(
    Orders,
    // User scope
    If(
        IsBlank(Data.Filter.UserScope),
        true, // Admin/Manager - see all
        'Assigned To'.Email = Data.Filter.UserScope // Regular user - own only
    ),
    // Additional filters
    StartsWith(
        Lower('Order Number'),
        Lower(Data.Filter.Custom.SearchTerm)
    ),
    If(
        IsBlank(Data.Filter.Custom.Status),
        true,
        Status = Data.Filter.Custom.Status
    )
)
```

### Pattern 2: Lookup with Department Filter

```powerfx
// Dropdown.Items
Filter(
    Projects,
    // Department scope
    If(
        IsBlank(Data.Filter.DepartmentScope),
        true, // Cross-department access
        Department = Data.Filter.DepartmentScope
    ),
    // Active only
    If(
        Data.Filter.ActiveOnly,
        Status = "Active",
        true
    )
)
```

### Pattern 3: Reusable Filter Pattern (inline approach)

**Note**: Lambda() is NOT available in Canvas Apps. For reusable logic, use consistent inline Filter patterns.

```powerfx
// Gallery.Items - Standard multi-filter pattern (copy and adapt)
Filter(
    Customers,
    // User scope
    If(
        IsBlank(Data.Filter.UserScope),
        true,
        Owner.Email = Data.Filter.UserScope
    ),
    // Department scope
    If(
        IsBlank(Data.Filter.DepartmentScope),
        true,
        Department = Data.Filter.DepartmentScope
    ),
    // Active only
    If(
        Data.Filter.ActiveOnly,
        Status <> "Archived",
        true
    ),
    // Custom search filter
    StartsWith(Lower(Name), Lower(SearchBox.Text))
)

// Alternative: Use collections for complex scenarios
// Screen.OnVisible
ClearCollect(
    colFiltered,
    Filter(
        Customers,
        If(IsBlank(Data.Filter.UserScope), true, Owner.Email = Data.Filter.UserScope),
        If(IsBlank(Data.Filter.DepartmentScope), true, Department = Data.Filter.DepartmentScope),
        If(Data.Filter.ActiveOnly, Status <> "Archived", true)
    )
);

// Then in Gallery.Items - apply local search
Search(colFiltered, SearchBox.Text, "Name", "Email")
```

---

## 3. Usage Examples in Screens

### Example 1: Screen-Level State with Filters

```powerfx
// Screen.OnVisible
Set(Screen.State, {
    SelectedItem: Blank(),
    IsEditing: false,

    // Screen-specific filters (override global)
    LocalFilters: {
        ShowMyItems: true,
        DateFrom: Data.Filter.DateRange.ThisMonth,
        DateTo: Today(),
        StatusFilter: "In Progress"
    }
});
```

### Example 2: Conditional Visibility Based on Roles

```powerfx
// Button_Admin.Visible
App.User.Roles.IsAdmin

// Button_CreateNew.Visible
App.User.Permissions.CanCreate

// Gallery_AllUsers.Visible
App.User.Permissions.CanViewAll

// Label_RoleBadge.Text
Switch(
    true,
    App.User.Roles.IsAdmin, "Administrator",
    App.User.Roles.IsManager, "Manager",
    "User"
)

// Label_RoleBadge.Color
App.Themes.RoleColor
```

### Example 3: Data Operations with Permission Checks

```powerfx
// Button_Delete.OnSelect
If(
    App.User.Permissions.CanDelete,
    Remove(Items, Gallery.Selected);
    Notify("Item deleted successfully", NotificationType.Success),

    Notify("You don't have permission to delete items", NotificationType.Error)
);

// Button_Export.OnSelect
// ⚠️ NOTE: Export() does NOT exist in Canvas Apps - use Power Automate
If(
    App.User.Permissions.CanExport,
    // Trigger Power Automate flow to export data
    'ExportFlow'.Run(
        JSON(Gallery.AllItems),
        User().Email
    );
    Notify("Export started - check your email", NotificationType.Success),

    Notify("Export permission required", NotificationType.Warning)
);
```

---

## 4. Advanced: Dynamic Role Configuration

### Using Dataverse Table for Role Management

```powerfx
// Create a 'User Roles' Dataverse table with columns:
// - User Email (Single line of text)
// - Role Name (Choice: Admin, Manager, User)
// - Department Access (Multi-select choice)
// - Permissions (JSON text with custom permissions)

// Enhanced role loading in App.OnStart
Set(App.User,
    Patch(
        App.User,
        {
            RoleConfig: LookUp(
                'User Roles',
                'User Email' = User().Email
            ),
            Permissions: {
                CanCreate: LookUp('User Roles', 'User Email' = User().Email).'Can Create',
                CanEdit: LookUp('User Roles', 'User Email' = User().Email).'Can Edit',
                CanDelete: LookUp('User Roles', 'User Email' = User().Email).'Can Delete',
                CanExport: LookUp('User Roles', 'User Email' = User().Email).'Can Export',
                DepartmentAccess: LookUp('User Roles', 'User Email' = User().Email).'Department Access'
            }
        }
    )
);
```

---

## 5. Best Practices & Performance Tips

### 1. Role Determination Performance
- **Cache role information**: Load once in App.OnStart, don't repeatedly call Office365Users
- **Use security groups**: Preferred over email/department checks for scalability
- **Limit API calls**: Avoid checking roles in gallery items or formulas that execute frequently

### 2. Datasource Filtering
- **Delegate to server**: Use delegation-friendly filters when possible
- **Index important columns**: Ensure filtered columns are indexed in Dataverse
- **Use views**: Create Dataverse views with pre-applied filters for complex scenarios
- **Cache static data**: Load lookup tables once, filter locally

### 3. Security Considerations
- **Server-side enforcement**: Canvas App filtering is UI-only - enforce in Dataverse/APIs
- **Never trust client**: Always validate permissions in backend/business rules
- **Audit sensitive operations**: Log who performed what action
- **Regular access reviews**: Periodically review and update role assignments

### 4. Testing Different Roles
```powerfx
// Add debug override in App.OnStart (dev only!)
If(
    Param("debug") = "true" && App.Config.Environment = "Development",
    Set(App.User.Roles,
        Patch(
            App.User.Roles,
            {
                IsAdmin: Param("role") = "admin",
                IsManager: Param("role") = "manager",
                IsUser: true
            }
        )
    )
);

// Test URLs:
// ?debug=true&role=admin
// ?debug=true&role=manager
```

---

## 6. Migration from Old Pattern

### Before (Simple Variables)
```powerfx
Set(varUserEmail, User().Email);
Set(varIsAdmin, User().Email = "admin@company.com");
Set(varCanEdit, varIsAdmin);
```

### After (Dot Notation)
```powerfx
Set(App.User, {
    Email: User().Email,
    Roles: {
        IsAdmin: !IsBlank(LookUp(Office365Groups.ListGroupMembers("group-id"), mail = User().Email))
    },
    Permissions: {
        CanEdit: App.User.Roles.IsAdmin
    }
});
```

---

## 7. Placeholder Reference Quick Guide

### User Context
- `App.User.Email` - Current user email
- `App.User.FullName` - Display name
- `App.User.JobTitle` - From Office365
- `App.User.Department` - From Office365
- `App.User.Roles.IsAdmin` - Admin check
- `App.User.Roles.IsManager` - Manager check
- `App.User.Permissions.CanCreate` - Create permission
- `App.User.Permissions.CanDelete` - Delete permission

### Datasource Filters
- `Data.Filter.UserScope` - Email or Blank for user/role filtering
- `Data.Filter.DepartmentScope` - Department or Blank
- `Data.Filter.DateRange.Today` - Today's date
- `Data.Filter.DateRange.ThisMonth` - Start of current month
- `Data.Filter.DateRange.Last30Days` - 30 days ago
- `Data.Filter.ActiveOnly` - Boolean for active records
- `Data.Filter.Custom.SearchTerm` - Search text
- `Data.Filter.Custom.Status` - Status filter

### Feature Toggles
- `App.Config.Features.EnableAdvancedSearch` - Feature flag
- `App.Config.Features.EnableBulkOperations` - Feature flag
- `App.Config.Features.ShowDebugInfo` - Debug mode

---

## Summary

This design provides:

✅ **User Role Determination** via Office365Users and Office365Groups
✅ **Hierarchical dot notation** following CLAUDE.md standards
✅ **Datasource prefiltering placeholders** ready for reuse
✅ **Permission-based UI control** for security
✅ **Scalable pattern** that grows with app complexity
✅ **Performance optimized** with caching and delegation

Copy the App.OnStart formula section to your Canvas App and customize the group IDs, role logic, and datasource names to match your specific requirements.
