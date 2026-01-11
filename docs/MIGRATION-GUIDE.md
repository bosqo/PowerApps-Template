# Migration Guide: Modernizing Canvas Apps with UDFs and Named Formulas

## Quick Start

This guide walks you through migrating an existing Canvas App from the traditional `App.OnStart` pattern to the modern `App.Formulas` pattern using Named Formulas and User Defined Functions (UDFs).

---

## Prerequisites

- Power Apps version with App.Formulas support (2024+)
- Familiarity with existing Canvas App structure
- Access to Azure AD for security group configuration

---

## Migration Steps Overview

| Step | Task | Time Estimate |
|------|------|---------------|
| 1 | Enable App.Formulas | 5 min |
| 2 | Copy Named Formulas | 10 min |
| 3 | Configure Security Groups | 15 min |
| 4 | Copy UDFs | 10 min |
| 5 | Simplify App.OnStart | 20 min |
| 6 | Update Control Formulas | 30-60 min |
| 7 | Test and Validate | 30 min |

---

## Step 1: Enable App.Formulas

1. Open your Canvas App in Power Apps Studio
2. Go to **Settings** (gear icon)
3. Navigate to **Upcoming features** > **Experimental** or **Preview**
4. Enable **Named formulas** if not already enabled
5. Enable **User-defined functions** if not already enabled
6. Save the app

> Note: As of 2025, these features are generally available and enabled by default.

---

## Step 2: Copy Named Formulas

1. In Power Apps Studio, select **App** in the Tree View
2. In the properties panel, find **Formulas** property
3. Copy the contents from `App-Formulas-Template.fx` (Sections 1-2)

### Minimal Named Formulas to Start

```powerfx
// Start with these essential Named Formulas:

// Theme Colors
ThemeColors = {
    Primary: ColorValue("#0078D4"),
    Success: ColorValue("#107C10"),
    Warning: ColorValue("#FFB900"),
    Error: ColorValue("#D13438"),
    Background: ColorValue("#F3F2F1"),
    Surface: ColorValue("#FFFFFF"),
    Text: ColorValue("#201F1E"),
    TextSecondary: ColorValue("#605E5C"),
    Border: ColorValue("#EDEBE9")
};

// Date Ranges
DateRanges = {
    Today: Today(),
    StartOfMonth: Date(Year(Today()), Month(Today()), 1),
    Last30Days: DateAdd(Today(), -30, TimeUnit.Days),
    Last90Days: DateAdd(Today(), -90, TimeUnit.Days)
};

// User Profile
UserProfile = With(
    { profile: Office365Users.MyProfileV2() },
    {
        Email: User().Email,
        FullName: User().FullName,
        Department: Coalesce(profile.department, "")
    }
);

// User Roles (configure your group IDs)
UserRoles = {
    IsAdmin: false, // Replace with actual security group check
    IsManager: false,
    IsUser: true
};

// User Permissions
UserPermissions = {
    CanCreate: UserRoles.IsAdmin || UserRoles.IsManager,
    CanEdit: true,
    CanDelete: UserRoles.IsAdmin,
    CanExport: UserRoles.IsAdmin || UserRoles.IsManager,
    CanViewAll: UserRoles.IsAdmin || UserRoles.IsManager
};
```

---

## Step 3: Configure Security Groups

### Find Your Azure AD Group IDs

1. Go to [Azure Portal](https://portal.azure.com)
2. Navigate to **Azure Active Directory** > **Groups**
3. Search for your admin/manager groups
4. Copy the **Object ID** for each group

### Update Group IDs in App.Formulas

Replace the placeholder IDs in the `UserRoles` Named Formula:

```powerfx
UserRoles = {
    IsAdmin: CountRows(
        Filter(
            Office365Groups.ListGroupMembers("xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"), // Your Admin Group ID
            mail = User().Email
        )
    ) > 0,
    IsManager: CountRows(
        Filter(
            Office365Groups.ListGroupMembers("yyyyyyyy-yyyy-yyyy-yyyy-yyyyyyyyyyyy"), // Your Manager Group ID
            mail = User().Email
        )
    ) > 0,
    IsUser: true
};
```

### Alternative: Email Domain-Based Roles

If you don't have security groups, use email-based detection:

```powerfx
UserRoles = {
    IsAdmin: User().Email in ["admin1@company.com", "admin2@company.com"],
    IsManager: Contains(Lower(UserProfile.JobTitle), "manager"),
    IsUser: true,
    IsCorporate: EndsWith(Lower(User().Email), "@yourcompany.com")
};
```

---

## Step 4: Copy UDFs

Add the User Defined Functions from `App-Formulas-Template.fx` (Section 3) to your App.Formulas.

### Essential UDFs to Start

```powerfx
// Permission check
HasPermission(permissionName: Text): Boolean =
    Switch(Lower(permissionName),
        "create", UserPermissions.CanCreate,
        "edit", UserPermissions.CanEdit,
        "delete", UserPermissions.CanDelete,
        "export", UserPermissions.CanExport,
        "viewall", UserPermissions.CanViewAll,
        false
    );

// Role check
HasRole(roleName: Text): Boolean =
    Switch(Lower(roleName),
        "admin", UserRoles.IsAdmin,
        "manager", UserRoles.IsManager,
        "user", UserRoles.IsUser,
        false
    );

// Access control
CanAccessRecord(ownerEmail: Text): Boolean =
    UserPermissions.CanViewAll || Lower(ownerEmail) = Lower(User().Email);

// Role display
GetRoleLabel(): Text =
    Switch(true, UserRoles.IsAdmin, "Admin", UserRoles.IsManager, "Manager", "User");

// Status colors
GetStatusColor(status: Text): Color =
    Switch(Lower(status),
        "active", ThemeColors.Success,
        "pending", ThemeColors.Warning,
        "error", ThemeColors.Error,
        ThemeColors.Text
    );

// Notifications
NotifySuccess(message: Text): Boolean = Notify(message, NotificationType.Success);
NotifyError(message: Text): Boolean = Notify(message, NotificationType.Error);
NotifyPermissionDenied(action: Text): Boolean =
    Notify("Permission denied: " & action, NotificationType.Error);
```

---

## Step 5: Simplify App.OnStart

### Before (Old Pattern)

```powerfx
// App.OnStart - BEFORE
Set(App.User, {...});  // Profile
Set(App.User, Patch(App.User, {...}));  // Permissions
Set(App.Themes, {...});  // Static colors
Set(App.Config, {...});  // Config
Set(Data.Filter, {...});  // Filters
ClearCollect(...);  // Data loading
```

### After (Modern Pattern)

```powerfx
// App.OnStart - AFTER (minimal)

// Only mutable state
Set(AppState, {
    IsLoading: false,
    CurrentScreen: "Home",
    LastRefresh: Now()
});

// User-modifiable filters
Set(ActiveFilters, {
    UserScope: If(UserPermissions.CanViewAll, Blank(), User().Email),
    DateRangeStart: DateRanges.StartOfMonth,
    DateRangeEnd: DateRanges.Today,
    ActiveOnly: true,
    SearchTerm: ""
});

// Data loading
ClearCollect(
    CachedDepartments,
    Filter(Departments, Status = "Active")
);

ClearCollect(
    MyItems,
    Filter(
        Items,
        CanAccessRecord(Owner.Email),
        Status <> "Archived"
    )
);
```

### What to Remove from App.OnStart

| Remove | Replace With |
|--------|--------------|
| `Set(App.Themes, {...})` | `ThemeColors` Named Formula |
| `Set(App.User.Email, ...)` | `UserProfile` Named Formula |
| `Set(App.User.Roles, ...)` | `UserRoles` Named Formula |
| `Set(App.User.Permissions, ...)` | `UserPermissions` Named Formula |
| Static date calculations | `DateRanges` Named Formula |
| Feature flag definitions | `FeatureFlags` Named Formula |

---

## Step 6: Update Control Formulas

### Button Visibility

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

### Gallery Items

**Before:**
```powerfx
// Gallery.Items
Filter(
    Orders,
    If(IsBlank(Data.Filter.UserScope), true, Owner.Email = Data.Filter.UserScope)
)
```

**After:**
```powerfx
// Gallery.Items
Filter(
    Orders,
    CanAccessRecord(Owner.Email)
)
```

### Theme Colors

**Before:**
```powerfx
// Button.Fill
App.Themes.Primary
```

**After:**
```powerfx
// Button.Fill
ThemeColors.Primary
// or
GetThemeColor("Primary")
```

### Status Colors

**Before:**
```powerfx
// Icon.Color
Switch(ThisItem.Status,
    "Active", App.Themes.Success,
    "Pending", App.Themes.Warning,
    App.Themes.Text
)
```

**After:**
```powerfx
// Icon.Color
GetStatusColor(ThisItem.Status)
```

### Role Labels

**Before:**
```powerfx
// Label.Text
Switch(true,
    App.User.Roles.IsAdmin, "Administrator",
    App.User.Roles.IsManager, "Manager",
    "User"
)
```

**After:**
```powerfx
// Label.Text
GetRoleLabel()
```

### Permission-Guarded Actions

**Before:**
```powerfx
// Button.OnSelect
If(
    App.User.Permissions.CanDelete,
    Remove(Items, Gallery.Selected);
    Notify("Deleted", NotificationType.Success),
    Notify("No permission", NotificationType.Error)
)
```

**After:**
```powerfx
// Button.OnSelect
If(
    HasPermission("Delete") && CanAccessRecord(Gallery.Selected.Owner.Email),
    Remove(Items, Gallery.Selected);
    NotifySuccess("Item deleted"),
    NotifyPermissionDenied("delete items")
)
```

---

## Step 7: Test and Validate

### Test Checklist

- [ ] App loads without errors
- [ ] User profile displays correctly
- [ ] Role is detected correctly
- [ ] Permissions work as expected
- [ ] Gallery filters by user scope
- [ ] Delete button visible only for admins
- [ ] Export button visible only for admins/managers
- [ ] Theme colors render correctly
- [ ] Status colors display properly
- [ ] Date formatting works
- [ ] Notifications display correctly

### Test Different User Roles

1. **Test as Admin:**
   - All buttons visible
   - All records visible
   - Can delete and export

2. **Test as Manager:**
   - Create/Edit/Export visible
   - Delete hidden
   - All records visible

3. **Test as Regular User:**
   - Only own records visible
   - Edit visible, Delete/Export hidden

### Debug Parameters

Add these URL parameters for testing:

```
?debug=true&role=admin    // Test as admin
?debug=true&role=manager  // Test as manager
?debug=true&role=user     // Test as regular user
```

Handle in App.Formulas:

```powerfx
// Add to UserRoles (development only!)
IsAdmin: If(
    Param("debug") = "true" && AppConfig.IsDevelopment,
    Param("role") = "admin",
    // Normal security group check
    CountRows(Filter(Office365Groups.ListGroupMembers("..."), mail = User().Email)) > 0
);
```

---

## Common Migration Issues

### Issue 1: Circular Reference Error

**Problem:** Named Formulas reference each other in a loop.

**Solution:** Ensure dependency chain is linear:
```
UserProfile → UserRoles → UserPermissions → FeatureFlags
```

### Issue 2: Office365Users.MyProfileV2() Not Working

**Problem:** Different environments may use different API versions.

**Solution:** Try alternatives:
```powerfx
// Try these in order:
Office365Users.MyProfileV2()
Office365Users.MyProfile()
Office365Users.MyProfile().DisplayName
```

### Issue 3: Security Group Check is Slow

**Problem:** Group membership check adds load time.

**Solution:** Cache the result in a collection on first access:
```powerfx
// In App.OnStart
Set(UserIsAdmin,
    CountRows(Filter(Office365Groups.ListGroupMembers("..."), mail = User().Email)) > 0
);
```

### Issue 4: UDF Not Recognized

**Problem:** Function shows as error in editor.

**Solution:**
1. Check UDF syntax (no trailing semicolons)
2. Ensure function is defined before use
3. Save and reload the app

### Issue 5: Theme Colors Not Updating

**Problem:** Old variable references still in controls.

**Solution:** Use Find & Replace:
- Find: `App.Themes.`
- Replace: `ThemeColors.`

---

## Performance Comparison

| Metric | Before (OnStart) | After (Formulas) |
|--------|-----------------|------------------|
| Initial Load | 3-5 seconds | 1-2 seconds |
| Permission Check | Instant (cached) | Instant (computed) |
| Theme Access | Variable lookup | Named Formula |
| Memory Usage | All loaded upfront | Lazy evaluation |
| Refresh Required | Manual Set() | Automatic |

---

## Quick Reference Card

### Named Formulas (direct access)

```powerfx
ThemeColors.Primary          // Color
DateRanges.Today             // Date
UserProfile.Email            // Text
UserRoles.IsAdmin            // Boolean
UserPermissions.CanDelete    // Boolean
FeatureFlags.EnableExport    // Boolean
```

### UDFs (function calls)

```powerfx
HasPermission("Delete")      // Boolean
HasRole("Admin")             // Boolean
CanAccessRecord(email)       // Boolean
GetRoleLabel()               // Text
GetStatusColor(status)       // Color
GetThemeColor("Primary")     // Color
FormatDateRelative(date)     // Text
NotifySuccess(message)       // Boolean
```

### Variables (mutable state)

```powerfx
AppState.IsLoading           // Boolean
AppState.CurrentScreen       // Text
ActiveFilters.SearchTerm     // Text
ActiveFilters.UserScope      // Text
UIState.SelectedItem         // Record
```

---

## Files Reference

| File | Purpose |
|------|---------|
| `App-Formulas-Template.fx` | Complete Named Formulas + UDFs |
| `App-OnStart-Minimal.fx` | Simplified App.OnStart |
| `Control-Patterns-Modern.fx` | Ready-to-use control formulas |
| `MODERNIZATION-PLAN.md` | Architecture overview |
| `MIGRATION-GUIDE.md` | This guide |

---

## Next Steps

1. Start with a development copy of your app
2. Migrate one feature at a time
3. Test thoroughly at each step
4. Document any custom UDFs you create
5. Share patterns with your team

---

## Support

For issues or questions:
- Review the AUDIT-REPORT.md for known formula corrections
- Check Power Apps Community forums
- Reference Microsoft Power Fx documentation
