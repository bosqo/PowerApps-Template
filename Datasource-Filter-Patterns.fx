// ============================================================
// DATASOURCE PREFILTERING PATTERNS
// Reusable filter formulas for Canvas App controls
// ============================================================
//
// ⚠️ DEPRECATION NOTICE (2025-01-11):
// This file uses the LEGACY variable pattern (Data.Filter.*, App.User.*).
// For new development, use the MODERN UDF pattern in:
// - App-Formulas-Template.fx (UDFs like CanAccessRecord(), HasPermission())
// - Control-Patterns-Modern.fx (examples using ActiveFilters.*, UserPermissions.*)
//
// MIGRATION:
// | Old Pattern (this file)         | New Pattern (Modern)           |
// |---------------------------------|--------------------------------|
// | Data.Filter.UserScope           | ActiveFilters.UserScope        |
// | Data.Filter.DepartmentScope     | ActiveFilters.DepartmentScope  |
// | App.User.Permissions.CanDelete  | HasPermission("Delete")        |
// | App.User.Roles.IsAdmin          | HasRole("Admin")               |
// | App.User.Roles.IsManager        | HasRole("Manager")             |
// | App.User.Roles.IsHR             | HasRole("HR")                  |
// | App.User.Roles.IsSachbearbeiter | HasRole("Sachbearbeiter")      |
//
// This file is retained for reference and backward compatibility.
// ============================================================

// ============================================================
// PATTERN 1: BASIC GALLERY WITH USER SCOPE
// ============================================================
// Gallery.Items
Filter(
    Orders,
    // User Scope Filter
    If(
        IsBlank(Data.Filter.UserScope),
        true, // Admin/Manager sees all
        'Assigned To'.Email = Data.Filter.UserScope // User sees own only
    )
)


// ============================================================
// PATTERN 2: GALLERY WITH MULTIPLE FILTERS
// ============================================================
// Gallery.Items
Filter(
    Projects,
    // User Scope
    If(IsBlank(Data.Filter.UserScope), true, Owner.Email = Data.Filter.UserScope),
    // Department Scope
    If(IsBlank(Data.Filter.DepartmentScope), true, Department = Data.Filter.DepartmentScope),
    // Active Only
    If(Data.Filter.ActiveOnly, Status <> "Archived", true),
    // Custom Search
    StartsWith(Lower('Project Name'), Lower(Data.Filter.Custom.SearchTerm))
)


// ============================================================
// PATTERN 3: DROPDOWN WITH DEPARTMENT FILTER
// ============================================================
// Dropdown.Items
Filter(
    Employees,
    If(IsBlank(Data.Filter.DepartmentScope), true, Department = Data.Filter.DepartmentScope),
    Status = "Active"
)


// ============================================================
// PATTERN 4: COMBO BOX WITH SEARCH
// ============================================================
// ComboBox.Items
Filter(
    Customers,
    // User/Department scope
    If(IsBlank(Data.Filter.UserScope), true, 'Account Owner'.Email = Data.Filter.UserScope),
    // Search in multiple fields
    Or(
        StartsWith(Lower('Customer Name'), Lower(Data.Filter.Custom.SearchTerm)),
        StartsWith(Lower('Customer ID'), Lower(Data.Filter.Custom.SearchTerm)),
        StartsWith(Lower(Email), Lower(Data.Filter.Custom.SearchTerm))
    )
)


// ============================================================
// PATTERN 5: GALLERY WITH DYNAMIC STATUS FILTER
// ============================================================
// Gallery.Items
Filter(
    Tasks,
    // User scope
    If(IsBlank(Data.Filter.UserScope), true, 'Assigned To'.Email = Data.Filter.UserScope),
    // Status filter (if selected)
    If(IsBlank(Data.Filter.Custom.Status), true, Status = Data.Filter.Custom.Status),
    // Priority filter (if selected)
    If(IsBlank(Data.Filter.Custom.Priority), true, Priority = Data.Filter.Custom.Priority)
)


// ============================================================
// PATTERN 6: LOOKUP WITH ROLE-BASED FILTER
// ============================================================
// Form.Item or LookUp usage
LookUp(
    Invoices,
    'Invoice ID' = Gallery.Selected.'Invoice ID',
    // Security check - user can only view own invoices unless admin
    If(
        App.User.Permissions.CanViewAll,
        true,
        'Created By'.Email = User().Email
    )
)


// ============================================================
// PATTERN 7: SEARCH GALLERY WITH DELEGATION
// ============================================================
// Gallery.Items (delegation-friendly)
Search(
    Filter(
        Contacts,
        // Apply user scope first (delegable)
        If(IsBlank(Data.Filter.UserScope), true, Owner.Email = Data.Filter.UserScope)
    ),
    Data.Filter.Custom.SearchTerm,
    "FullName", "Email", "Company"
)


// ============================================================
// PATTERN 8: COLLECTION WITH PREFILTERING (OnVisible)
// ============================================================
// Screen.OnVisible
ClearCollect(
    colScreenData,
    Filter(
        'Sales Orders',
        // User scope
        If(IsBlank(Data.Filter.UserScope), true, 'Sales Rep'.Email = Data.Filter.UserScope),
        // Active only
        Status = "Open" || Status = "Pending"
    )
);


// ============================================================
// PATTERN 9: AGGREGATED DATA WITH FILTERS
// ============================================================
// Label showing count
CountRows(
    Filter(
        Tickets,
        If(IsBlank(Data.Filter.UserScope), true, 'Assigned To'.Email = Data.Filter.UserScope),
        Status = "Open"
    )
)

// Label showing sum
Sum(
    Filter(
        Invoices,
        If(IsBlank(Data.Filter.UserScope), true, 'Sales Rep'.Email = Data.Filter.UserScope)
    ),
    'Total Amount'
)


// ============================================================
// PATTERN 10: NESTED GALLERIES WITH INHERITED FILTERS
// ============================================================
// Parent Gallery.Items
Filter(
    Accounts,
    If(IsBlank(Data.Filter.UserScope), true, 'Account Owner'.Email = Data.Filter.UserScope)
)

// Child Gallery.Items (inside parent)
Filter(
    Opportunities,
    Account.'Account ID' = ThisItem.'Account ID',
    // Inherit user scope
    If(IsBlank(Data.Filter.UserScope), true, 'Opportunity Owner'.Email = Data.Filter.UserScope)
)


// ============================================================
// PATTERN 11: FORM DEFAULTS WITH USER CONTEXT
// ============================================================
// Form DataCard Default Value
DataCardValue_Owner.DefaultSelectedItems = If(
    App.User.Permissions.CanViewAll,
    LookUp(Users, Email = Gallery.Selected.Owner.Email), // Can select anyone
    LookUp(Users, Email = User().Email) // Must be current user
)

// Form DataCard Default for Department
DataCardValue_Department.Default = If(
    IsBlank(Data.Filter.DepartmentScope),
    "", // Admin can leave blank
    Data.Filter.DepartmentScope // Pre-fill with user's department
)


// ============================================================
// PATTERN 12: BUTTON ONSELECT WITH PERMISSION & FILTER
// ============================================================
// Button_BulkDelete.OnSelect
If(
    App.User.Permissions.CanDelete,
    // Only delete items the user has access to
    RemoveIf(
        Tasks,
        'Task ID' in Gallery.SelectedItems.'Task ID' &&
        If(
            IsBlank(Data.Filter.UserScope),
            true,
            'Assigned To'.Email = Data.Filter.UserScope
        )
    );
    Notify("Erfolgreich gelöscht", NotificationType.Success),
    // No permission
    Notify("Löschberechtigung erforderlich", NotificationType.Error)
)


// ============================================================
// PATTERN 13: DYNAMIC FILTER UPDATE (Button/Toggle OnSelect)
// ============================================================
// Toggle_ShowAll.OnChange
Set(Data.Filter,
    Patch(
        Data.Filter,
        {
            UserScope: If(
                Toggle_ShowAll.Value && App.User.Permissions.CanViewAll,
                Blank(), // Show all
                User().Email // Show own only
            )
        }
    )
);
Notify("Filter aktualisiert", NotificationType.Information)


// ============================================================
// PATTERN 14: REFRESH DATA WITH FILTERS
// ============================================================
// Button_Refresh.OnSelect
Set(App.State.IsLoading, true);
ClearCollect(
    Data.Cache.MyItems,
    Filter(
        Items,
        If(IsBlank(Data.Filter.UserScope), true, Owner.Email = Data.Filter.UserScope),
        Status <> "Archived"
    )
);
Set(App.State.IsLoading, false);
Set(App.State.LastRefresh, Now());
Notify("Daten aktualisiert", NotificationType.Success)


// ============================================================
// PATTERN 15: CONDITIONAL FORM MODE BASED ON PERMISSIONS
// ============================================================
// Form.DefaultMode
If(
    IsBlank(Gallery.Selected),
    FormMode.New, // New record
    If(
        App.User.Permissions.CanEdit &&
        (
            App.User.Permissions.CanViewAll ||
            Gallery.Selected.Owner.Email = User().Email
        ),
        FormMode.Edit, // Can edit
        FormMode.View // Read-only
    )
)


// ============================================================
// PATTERN 16: FILTER RESET (Button OnSelect)
// ============================================================
// Button_ResetFilters.OnSelect
Set(Data.Filter,
    Patch(
        Data.Filter,
        {
            UserScope: If(App.User.Permissions.CanViewAll, Blank(), User().Email),
            DepartmentScope: If(App.User.Roles.IsAdmin, Blank(), App.User.Department),
            ActiveOnly: true,
            Custom: {
                SearchTerm: "",
                Category: Blank(),
                Status: Blank(),
                Priority: Blank()
            }
        }
    )
);
Notify("Filter zurückgesetzt", NotificationType.Information)


// ============================================================
// QUICK REFERENCE: Common Filter Placeholders
// ============================================================

/*
USER SCOPE:
- Data.Filter.UserScope (Blank() or Email)
  If(IsBlank(Data.Filter.UserScope), true, Owner.Email = Data.Filter.UserScope)

DEPARTMENT SCOPE:
- Data.Filter.DepartmentScope (Blank() or Department Name)
  If(IsBlank(Data.Filter.DepartmentScope), true, Department = Data.Filter.DepartmentScope)

ACTIVE/STATUS:
- Data.Filter.ActiveOnly (Boolean)
  If(Data.Filter.ActiveOnly, Status <> "Archived", true)

CUSTOM FILTERS:
- Data.Filter.Custom.SearchTerm (Text)
- Data.Filter.Custom.Status (Choice/Text)
- Data.Filter.Custom.Category (Choice/Text)
- Data.Filter.Custom.Priority (Choice/Text)

PERMISSIONS:
- App.User.Permissions.CanCreate
- App.User.Permissions.CanEdit
- App.User.Permissions.CanDelete
- App.User.Permissions.CanViewAll

ROLES:
- App.User.Roles.IsAdmin
- App.User.Roles.IsManager
- App.User.Roles.IsHR
- App.User.Roles.IsSachbearbeiter
- App.User.Roles.IsUser
*/
