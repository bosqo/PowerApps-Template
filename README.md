# Power Apps Canvas App Template

A modern, production-ready Canvas App template using **Named Formulas** and **User Defined Functions (UDFs)** following 2025 Power Fx best practices.

## Features

- **Modern Power Fx Architecture** - Declarative Named Formulas over imperative OnStart
- **User Defined Functions (UDFs)** - Reusable, centralized logic
- **Role-Based Access Control** - Security group integration with Azure AD
- **Permission System** - Granular CRUD permissions derived from roles
- **Datasource Prefiltering** - User-scoped data access patterns
- **Theme System** - Microsoft Fluent Design colors
- **Date Utilities** - Computed date ranges and relative formatting
- **Notification Helpers** - Standardized user feedback

## Table of Contents

- [Features](#features)
- [Quick Start](#quick-start)
- [File Structure](#file-structure)
- [Architecture](#architecture)
- [Named Formulas Reference](#named-formulas-reference)
- [UDF Reference](#udf-reference)
- [Configuration](#configuration)
- [Migration](#migration-from-legacy-pattern)
- [Common Patterns](#common-patterns)
- [Requirements](#requirements)
- [Contributing](#contributing)

## Quick Start

1. Copy `src/App-Formulas-Template.fx` to your Canvas App's **App.Formulas** property
2. Copy `src/App-OnStart-Minimal.fx` to your Canvas App's **App.OnStart** property
3. Configure your Azure AD security group IDs
4. Use patterns from `src/Control-Patterns-Modern.fx` in your controls

## File Structure

```
PowerApps-Vibe-Claude/
├── src/
│   ├── App-Formulas-Template.fx      # Named Formulas + UDFs (copy to App.Formulas)
│   ├── App-OnStart-Minimal.fx        # Minimal OnStart (copy to App.OnStart)
│   ├── App-OnStart-Template.fx       # Legacy OnStart template (for reference)
│   ├── Control-Patterns-Modern.fx    # Modern control formula patterns
│   └── Datasource-Filter-Patterns.fx # Legacy filter patterns (for reference)
├── docs/
│   ├── MODERNIZATION-PLAN.md         # Architecture and implementation plan
│   ├── MIGRATION-GUIDE.md            # Step-by-step migration instructions
│   ├── App-Formulas-Design.md        # Original design documentation
│   ├── App-Formulas-README.md        # Original usage guide
│   └── DATAVERSE-ITEM-SCHEMA.md      # Dataverse schema documentation
├── log/
│   ├── AUDIT-REPORT.md               # Formula validation and corrections
│   ├── CODE-REFACTORING-SUMMARY-2025.md
│   └── CODE-REVIEW-2025.md
└── CLAUDE.md                         # Project conventions
```

## Architecture

### Modern Pattern (2025)

```
App.Formulas (Named Formulas + UDFs)
├── ThemeColors, Typography, Spacing    # Static definitions
├── DateRanges, UserProfile, UserRoles  # Computed values (auto-refresh)
├── UserPermissions, FeatureFlags       # Derived from roles
└── HasPermission(), CanAccessRecord()  # Reusable UDFs

App.OnStart (Minimal)
├── Set(AppState, {...})                # Mutable state only
├── Set(ActiveFilters, {...})           # User-modifiable filters
└── ClearCollect(...)                   # Initial data loading

Controls
├── Gallery.Items = Filter(Table, CanAccessRecord(Owner.Email))
├── Button.Visible = HasPermission("Delete")
└── Label.Color = GetStatusColor(ThisItem.Status)
```

### Key Benefits

| Before (OnStart) | After (App.Formulas) |
|-----------------|---------------------|
| All computed upfront | Lazy evaluation |
| Manual refresh needed | Auto-refresh on change |
| Repeated inline logic | Single UDF definition |
| Complex control formulas | Clean function calls |

## Named Formulas Reference

### Static Values
```powerfx
ThemeColors.Primary       // Color
AppConfig.ItemsPerPage    // Number
```

### Computed Values (auto-refresh)
```powerfx
DateRanges.Today          // Always current date
UserProfile.Email         // Lazy-loaded from Office365
UserRoles.IsAdmin         // Security group membership
UserPermissions.CanDelete // Derived from roles
```

## UDF Reference

### Permission Checks
```powerfx
HasPermission("Delete")   // Check permission by name
HasRole("Admin")          // Check role by name
CanAccessRecord(email)    // Check if user can access record
```

### Display Functions
```powerfx
GetRoleLabel()            // "Administrator", "Manager", "User"
GetStatusColor(status)    // Color based on status value
FormatDateRelative(date)  // "Today", "Yesterday", "3 days ago"
```

### Notifications
```powerfx
NotifySuccess("Saved!")   // Green success toast
NotifyError("Failed")     // Red error toast
NotifyPermissionDenied("delete items")  // Permission error
```

## Configuration

### Security Groups

Update these Group IDs in `src/App-Formulas-Template.fx`:

```powerfx
UserRoles = {
    IsAdmin: CountRows(Filter(
        Office365Groups.ListGroupMembers("YOUR-ADMIN-GROUP-ID"),
        mail = User().Email
    )) > 0,
    // ...
};
```

### Email Domain

Update the domain pattern for corporate detection:

```powerfx
IsCorporate: EndsWith(Lower(User().Email), "@yourcompany.com"),
```

## Migration from Legacy Pattern

If migrating from the old `App.OnStart` pattern:

1. Read `docs/MIGRATION-GUIDE.md` for step-by-step instructions
2. Start with a development copy of your app
3. Migrate one feature at a time
4. Test with different user roles

## Common Patterns

### Gallery with User Scope
```powerfx
Filter(Orders, CanAccessRecord(Owner.Email))
```

### Permission-Guarded Button
```powerfx
// Visible
HasPermission("Delete")

// OnSelect
If(HasPermission("Delete"),
    Remove(Items, Selected);
    NotifySuccess("Deleted"),
    NotifyPermissionDenied("delete")
)
```

### Status-Based Styling
```powerfx
// Color
GetStatusColor(ThisItem.Status)

// Icon
GetStatusIcon(ThisItem.Status)
```

## Requirements

- Power Apps with Named Formulas support (2024+)
- Office365Users connector (for profile)
- Office365Groups connector (for security groups)
- Dataverse (for business data)

## Contributing

1. Follow conventions in `CLAUDE.md`
2. Test with Admin, Manager, and User roles
3. Document new UDFs in `src/App-Formulas-Template.fx`
4. Update patterns in `src/Control-Patterns-Modern.fx`

## License

MIT
