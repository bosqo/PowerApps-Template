// ============================================================
// MODERN CONTROL PATTERNS (2025)
// Using UDFs and Named Formulas from App.Formulas
// ============================================================
//
// This file contains ready-to-use control formulas that leverage
// the UDFs and Named Formulas defined in App-Formulas-Template.fx
//
// Each pattern shows:
// - BEFORE: Traditional inline approach
// - AFTER: Modern UDF-based approach
//
// Benefits of the modern approach:
// - Cleaner, more readable formulas
// - Centralized logic (single source of truth)
// - Easier maintenance and updates
// - Consistent behavior across the app
//
// ============================================================


// ============================================================
// SHAREPOINT TIMEZONE HANDLING
// ============================================================
// SharePoint stores all datetime fields in UTC
// MEZ (Mitteleuropäische Zeit): CET (UTC+1) or CEST (UTC+2 during daylight saving)
//
// Key Functions:
// - ConvertUTCToMEZ(utcDateTime) - Convert SharePoint UTC to MEZ time
// - GetMEZToday() - Get today's date in MEZ timezone
// - FormatDateTimeMEZ(utcDateTime) - Format UTC datetime in MEZ time
//
// Example: SharePoint 'Modified' field is UTC, use:
//   ConvertUTCToMEZ('Modified')  -> DateTime in MEZ time
//   DateValue(ConvertUTCToMEZ('Modified'))  -> Date only
//   FormatDateTimeMEZ('Modified')  -> Formatted string "d.m.yyyy hh:mm"
//
// For filters comparing SharePoint dates with MEZ timezone:
//   Filter(Items, DateValue(ConvertUTCToMEZ('Modified')) >= GetMEZToday())
// ============================================================


// ============================================================
// SECTION 1: GALLERY PATTERNS
// ============================================================

// -----------------------------------------------------------
// Pattern 1.1: Basic Gallery with User Scope
// -----------------------------------------------------------

// BEFORE (inline logic):
/*
Filter(
    Orders,
    If(
        IsBlank(Data.Filter.UserScope),
        true,
        Owner.Email = Data.Filter.UserScope
    )
)
*/

// AFTER (using UDFs):
// Gallery_Orders.Items
Filter(
    Orders,
    CanAccessRecord(Owner.Email)
)


// -----------------------------------------------------------
// Pattern 1.2: Gallery with Multiple Filters (including SharePoint UTC dates)
// -----------------------------------------------------------

// BEFORE (complex inline logic):
/*
Filter(
    Projects,
    If(IsBlank(Data.Filter.UserScope), true, Owner.Email = Data.Filter.UserScope),
    If(IsBlank(Data.Filter.DepartmentScope), true, Department = Data.Filter.DepartmentScope),
    If(Data.Filter.ActiveOnly, Status <> "Archived", true),
    'Created On' >= Data.Filter.DateRange.ThisMonth,
    StartsWith(Lower('Project Name'), Lower(Data.Filter.Custom.SearchTerm))
)
*/

// AFTER (using UDFs + ActiveFilters):
// Gallery_Projects.Items
Filter(
    Projects,
    // Access control via UDF
    CanAccessItem(Owner.Email, Department),
    // Active status via conditional
    If(ActiveFilters.ActiveOnly, Status <> "Archived", true),
    // Date range filter (manual date comparison)
    // NOTE: For SharePoint UTC datetime fields, convert with ConvertUTCToMEZ() first
    If(IsBlank(ActiveFilters.DateRangeStart), true, DateValue(ConvertUTCToMEZ('Modified')) >= ActiveFilters.DateRangeStart),
    // Search (native)
    StartsWith(Lower('Project Name'), Lower(ActiveFilters.SearchTerm))
)


// -----------------------------------------------------------
// Pattern 1.3: Gallery with Status and Priority Filters
// -----------------------------------------------------------

// Gallery_Tasks.Items
Filter(
    Tasks,
    // User access
    CanAccessRecord('Assigned To'.Email),
    // Status filter (if selected)
    If(IsBlank(ActiveFilters.StatusFilter), true, Status = ActiveFilters.StatusFilter),
    // Priority filter (if selected)
    If(IsBlank(ActiveFilters.PriorityFilter), true, Priority = ActiveFilters.PriorityFilter),
    // Active only
    If(ActiveFilters.ActiveOnly, Status <> "Archived", true),
    // Due in future or today (handles both Date and UTC DateTime fields)
    If(
        IsBlank('Due Date'),
        true,
        // For Date fields (stored locally): use Today()
        // For DateTime fields (stored in UTC from SharePoint): use GetMEZToday()
        'Due Date' >= GetMEZToday()
    )
)


// -----------------------------------------------------------
// Pattern 1.4: Search Gallery (Delegation-Friendly)
// -----------------------------------------------------------

// Gallery_Contacts.Items
Search(
    Filter(
        Contacts,
        CanAccessRecord(Owner.Email)
    ),
    ActiveFilters.SearchTerm,
    "FullName", "Email", "Company", "Phone"
)


// -----------------------------------------------------------
// Pattern 1.5: Sorted Gallery with Custom Column
// -----------------------------------------------------------

// Gallery_Invoices.Items
// NOTE: 'Invoice Date' from SharePoint is in UTC, convert with ConvertUTCToMEZ()
Sort(
    Filter(
        Invoices,
        CanAccessRecord('Sales Rep'.Email),
        DateValue(ConvertUTCToMEZ('Invoice Date')) >= GetMEZToday() - 90,
        If(ActiveFilters.ActiveOnly, Status <> "Void", true)
    ),
    'Invoice Date',
    SortOrder.Descending
)


// -----------------------------------------------------------
// Pattern 1.6: Paginated Gallery (Refactored 2025 with UDFs)
// -----------------------------------------------------------

// Gallery_AllRecords.Items - Using pagination UDFs
FirstN(
    Skip(
        Sort(
            Filter(
                Records,
                CanAccessRecord(Owner.Email),
                If(ActiveFilters.ActiveOnly, Status <> "Archived", true)
            ),
            'Created On',
            SortOrder.Descending
        ),
        GetSkipCount(ActiveFilters.CurrentPage, ActiveFilters.PageSize)
    ),
    ActiveFilters.PageSize
)

// Label_PageInfo.Text - Page range display
GetPageRangeText(
    ActiveFilters.CurrentPage,
    ActiveFilters.PageSize,
    CountRows(Filter(Records, CanAccessRecord(Owner.Email)))
)

// Button_PreviousPage.DisplayMode
If(CanGoToPreviousPage(ActiveFilters.CurrentPage), DisplayMode.Edit, DisplayMode.Disabled)

// Button_NextPage.DisplayMode
If(
    CanGoToNextPage(
        ActiveFilters.CurrentPage,
        CountRows(Filter(Records, CanAccessRecord(Owner.Email))),
        ActiveFilters.PageSize
    ),
    DisplayMode.Edit,
    DisplayMode.Disabled
)

// Button_PreviousPage.OnSelect
Set(ActiveFilters, Patch(ActiveFilters, {CurrentPage: Max(1, ActiveFilters.CurrentPage - 1)}))

// Button_NextPage.OnSelect
Set(ActiveFilters,
    Patch(ActiveFilters, {
        CurrentPage: Min(
            GetTotalPages(
                CountRows(Filter(Records, CanAccessRecord(Owner.Email))),
                ActiveFilters.PageSize
            ),
            ActiveFilters.CurrentPage + 1
        )
    })
)


// ============================================================
// SECTION 2: VISIBILITY PATTERNS
// ============================================================

// -----------------------------------------------------------
// Pattern 2.1: Button Visibility Based on Permissions
// -----------------------------------------------------------

// BEFORE:
/*
App.User.Permissions.CanDelete
*/

// AFTER:
// Button_Delete.Visible
HasPermission("Delete")

// Button_Create.Visible
HasPermission("Create")

// Button_Export.Visible
HasPermission("Export")

// Button_BulkOperations.Visible
HasPermission("Bulk")

// Button_Settings.Visible
HasPermission("Settings")


// -----------------------------------------------------------
// Pattern 2.2: Control Visibility Based on Roles
// -----------------------------------------------------------

// Container_AdminPanel.Visible
HasRole("Admin")

// Container_ManagerTools.Visible
HasRole("Manager") || HasRole("Admin")

// Label_InternalOnly.Visible
HasRole("Corporate")

// Container_DepartmentData.Visible
HasAnyRole("Sales,Finance,IT")


// -----------------------------------------------------------
// Pattern 2.3: Conditional Button Visibility for Record Actions
// -----------------------------------------------------------

// Button_EditRecord.Visible
HasPermission("Edit") && CanAccessRecord(Gallery.Selected.Owner.Email)

// Button_DeleteRecord.Visible (with status check)
HasPermission("Delete") &&
CanDeleteRecord(Gallery.Selected.Owner.Email) &&
!IsOneOf(Gallery.Selected.Status, "Archived,Closed")

// Button_ApproveRecord.Visible
HasPermission("Approve") &&
Gallery.Selected.Status = "Pending"

// Button_ArchiveRecord.Visible
HasPermission("Archive") &&
Gallery.Selected.Status <> "Archived"


// -----------------------------------------------------------
// Pattern 2.4: Feature Flag Visibility
// -----------------------------------------------------------

// Container_AdvancedSearch.Visible
FeatureFlags.EnableAdvancedSearch

// Button_BulkExport.Visible
FeatureFlags.EnableExport && HasPermission("Export")

// Container_DebugInfo.Visible
FeatureFlags.ShowDebugInfo

// Container_OfflineIndicator.Visible
FeatureFlags.EnableOfflineMode && !AppState.IsOnline


// ============================================================
// SECTION 3: COLOR PATTERNS
// ============================================================

// -----------------------------------------------------------
// Pattern 3.1: Status-Based Colors
// -----------------------------------------------------------

// BEFORE:
/*
Switch(ThisItem.Status,
    "Active", App.Themes.Success,
    "Pending", App.Themes.Warning,
    "Error", App.Themes.Error,
    App.Themes.Text
)
*/

// AFTER:
// Icon_StatusIndicator.Color
GetStatusColor(ThisItem.Status)

// Label_Status.Fill
GetStatusColor(ThisItem.Status)


// -----------------------------------------------------------
// Pattern 3.2: Priority-Based Colors
// -----------------------------------------------------------

// Icon_PriorityFlag.Color
GetPriorityColor(ThisItem.Priority)

// Rectangle_PriorityBar.Fill
GetPriorityColor(ThisItem.Priority)


// -----------------------------------------------------------
// Pattern 3.3: Role-Based Colors
// -----------------------------------------------------------

// Label_RoleBadge.Fill
GetRoleBadgeColor()

// Circle_UserAvatar.BorderColor
RoleColor

// Icon_UserRole.Color
GetRoleBadgeColor()


// -----------------------------------------------------------
// Pattern 3.4: Theme Color References
// -----------------------------------------------------------

// Button_Primary.Fill
GetThemeColor("Primary")

// Button_Primary.HoverFill
GetThemeColor("PrimaryLight")

// Button_Primary.PressedFill
GetThemeColor("PrimaryDark")

// Container_Surface.Fill
GetThemeColor("Surface")

// Label_Secondary.Color
GetThemeColor("TextSecondary")

// Rectangle_Divider.Fill
GetThemeColor("Divider")

// Container_Error.Fill
GetThemeColor("ErrorLight")


// -----------------------------------------------------------
// Pattern 3.5: Conditional Row Colors (Gallery)
// -----------------------------------------------------------

// Gallery Row Template - Rectangle_RowBackground.Fill
If(
    ThisRecord = Gallery.Selected,
    GetThemeColor("PrimaryLight"),
    If(
        Mod(Coalesce(ThisItem.RowIndex, 1), 2) = 0,
        GetThemeColor("Surface"),
        GetThemeColor("Background")
    )
)


// ============================================================
// SECTION 4: TEXT & LABEL PATTERNS
// ============================================================

// -----------------------------------------------------------
// Pattern 4.1: Role Badge Text
// -----------------------------------------------------------

// BEFORE:
/*
Switch(true,
    App.User.Roles.IsAdmin, "Administrator",
    App.User.Roles.IsManager, "Manager",
    "User"
)
*/

// AFTER:
// Label_RoleBadge.Text
GetRoleLabel()

// Or short form:
// Label_RoleBadgeShort.Text
GetRoleBadge()


// -----------------------------------------------------------
// Pattern 4.2: Welcome Message
// -----------------------------------------------------------

// Label_Welcome.Text
"Welcome, " & UserProfile.DisplayName & " (" & GetRoleLabel() & ")"


// -----------------------------------------------------------
// Pattern 4.3: Date Formatting
// -----------------------------------------------------------

// BEFORE:
/*
Text(ThisItem.'Created On', "mmm d, yyyy")
*/

// AFTER (using German date formatting UDFs with Berlin timezone):
// For SharePoint Date-only fields (stored as local date):
// Label_CreatedDate.Text (short format)
FormatDateShort(ThisItem.'Created On')

// Label_DateShort.Text
FormatDateShort(ThisItem.'Due Date')

// Label_DateLong.Text
FormatDateLong(ThisItem.'Event Date')

// For SharePoint DateTime fields (stored in UTC - most common):
// Label_DateTime.Text (auto-converts UTC to MEZ time)
FormatDateTimeMEZ(ThisItem.'Last Modified')

// Label_ModifiedTime.Text (another UTC datetime example)
FormatDateTimeMEZ(ThisItem.'Created')


// -----------------------------------------------------------
// Pattern 4.4: Status with Due Date Context (MEZ Timezone)
// -----------------------------------------------------------

// Label_TaskStatus.Text
// NOTE: If 'Due Date' is a SharePoint DateTime (UTC), compare with GetMEZToday()
// If 'Due Date' is a SharePoint Date (local), use Today() instead
If(
    ThisItem.'Due Date' < GetMEZToday(),
    "Überfällig: " & Text(GetMEZToday() - ThisItem.'Due Date') & " Tage",
    If(
        ThisItem.'Due Date' = GetMEZToday(),
        "Fällig heute",
        If(
            ThisItem.'Due Date' > GetMEZToday() && !IsBlank(ThisItem.'Due Date'),
            "Fällig in " & Text(ThisItem.'Due Date' - GetMEZToday()) & " Tagen",
            ThisItem.Status
        )
    )
)


// -----------------------------------------------------------
// Pattern 4.5: Truncated Text
// -----------------------------------------------------------

// Label_Description.Text
If(
    Len(Coalesce(ThisItem.Description, "")) > 100,
    Left(ThisItem.Description, 97) & "...",
    Coalesce(ThisItem.Description, "")
)

// Tooltip on Label_Description.Tooltip
ThisItem.Description


// -----------------------------------------------------------
// Pattern 4.6: Currency and Number Formatting
// -----------------------------------------------------------

// Label_Amount.Text
FormatCurrency(ThisItem.Amount, "$")

// Label_Percentage.Text
FormatPercent(ThisItem.CompletionRate, 1)

// Label_Count.Text
FormatNumber(ThisItem.Quantity)


// -----------------------------------------------------------
// Pattern 4.7: User Initials
// -----------------------------------------------------------

// Label_Avatar.Text
GetInitials(ThisItem.Owner.DisplayName)


// ============================================================
// SECTION 5: ICON PATTERNS
// ============================================================

// -----------------------------------------------------------
// Pattern 5.1: Status Icons
// -----------------------------------------------------------

// Icon_Status.Icon
GetStatusIcon(ThisItem.Status)

// Icon_Status.Color
GetStatusColor(ThisItem.Status)


// -----------------------------------------------------------
// Pattern 5.2: Conditional Icons (MEZ Timezone)
// -----------------------------------------------------------

// Icon_OverdueWarning.Icon
If(ThisItem.'Due Date' < GetMEZToday(), Icon.Warning, Icon.Clock)

// Icon_OverdueWarning.Visible
!IsBlank(ThisItem.'Due Date')

// Icon_OverdueWarning.Color
If(ThisItem.'Due Date' < GetMEZToday(), GetThemeColor("Error"), GetThemeColor("TextSecondary"))


// ============================================================
// SECTION 6: BUTTON ONSELECT PATTERNS
// ============================================================

// -----------------------------------------------------------
// Pattern 6.1: Permission-Guarded Delete
// -----------------------------------------------------------

// BEFORE:
/*
If(
    App.User.Permissions.CanDelete,
    Remove(Items, Gallery.Selected);
    Notify("Deleted successfully", NotificationType.Success),
    Notify("No permission to delete", NotificationType.Error)
)
*/

// AFTER:
// Button_Delete.OnSelect
If(
    HasPermission("Delete") && CanDeleteRecord(Gallery.Selected.Owner.Email),
    Remove(Items, Gallery.Selected);
    NotifyActionCompleted("Delete", Gallery.Selected.Name),
    NotifyPermissionDenied("delete this item")
)


// -----------------------------------------------------------
// Pattern 6.2: Permission-Guarded Edit
// -----------------------------------------------------------

// Button_Edit.OnSelect
If(
    CanEditRecord(Gallery.Selected.Owner.Email, Gallery.Selected.Status),
    Set(UIState, Patch(UIState, {
        SelectedItem: Gallery.Selected,
        IsEditMode: true,
        FormMode: FormMode.Edit
    }));
    Navigate(EditScreen, ScreenTransition.None),
    NotifyPermissionDenied("edit this record")
)


// -----------------------------------------------------------
// Pattern 6.3: Export with Permission Check
// -----------------------------------------------------------

// Button_Export.OnSelect
If(
    HasPermission("Export"),
    Set(AppState, Patch(AppState, {IsLoading: true}));
    'ExportToExcelFlow'.Run(
        JSON(Filter(
            Records,
            CanAccessRecord(Owner.Email)
        )),
        "Export_" & Text(Now(), "yyyymmdd_hhmmss"),
        UserProfile.Email
    );
    Set(AppState, Patch(AppState, {IsLoading: false}));
    NotifySuccess("Export started - check your email shortly"),
    NotifyPermissionDenied("export data")
)


// -----------------------------------------------------------
// Pattern 6.4: Update Filter State
// -----------------------------------------------------------

// Dropdown_Status.OnChange
Set(ActiveFilters,
    Patch(ActiveFilters, {
        StatusFilter: Self.Selected.Value,
        CurrentPage: 1  // Reset to first page
    })
);
NotifyInfo("Filter applied: " & Self.Selected.DisplayName)


// -----------------------------------------------------------
// Pattern 6.5: Date Range Selection
// -----------------------------------------------------------

// Dropdown_DateRange.OnChange
Set(ActiveFilters,
    Patch(ActiveFilters, {
        DateRangeName: Self.Selected.Value,
        CurrentPage: 1
    })
)


// -----------------------------------------------------------
// Pattern 6.6: Toggle Show All (Admin/Manager)
// -----------------------------------------------------------

// Toggle_ShowAll.OnChange
If(
    HasPermission("ViewAll"),
    Set(ActiveFilters,
        Patch(ActiveFilters, {
            UserScope: If(Self.Value, Blank(), User().Email)
        })
    );
    NotifyInfo(If(Self.Value, "Showing all records", "Showing my records")),
    // Reset toggle if no permission
    Reset(Self);
    NotifyPermissionDenied("view all records")
)


// -----------------------------------------------------------
// Pattern 6.7: Bulk Delete with Confirmation
// -----------------------------------------------------------

// Button_BulkDelete.OnSelect
If(
    HasPermission("Bulk") && HasPermission("Delete"),
    If(
        CountRows(Gallery.SelectedItems) > 0,
        Set(UIState, Patch(UIState, {
            IsConfirmDialogOpen: true,
            ConfirmDialogTitle: "Confirm Bulk Delete",
            ConfirmDialogMessage: "Delete " & CountRows(Gallery.SelectedItems) & " selected items?",
            ConfirmDialogAction: "bulkdelete"
        })),
        NotifyWarning("Please select items to delete")
    ),
    NotifyPermissionDenied("perform bulk delete")
)

// ConfirmDialog_Confirm.OnSelect (for bulk delete)
If(
    UIState.ConfirmDialogAction = "bulkdelete",
    ForAll(
        Filter(Gallery.SelectedItems, CanDeleteRecord(Owner.Email)),
        Remove(Items, ThisRecord)
    );
    Set(UIState, Patch(UIState, {IsConfirmDialogOpen: false, ConfirmDialogAction: Blank()}));
    NotifySuccess("Deleted " & CountRows(Gallery.SelectedItems) & " items")
)


// -----------------------------------------------------------
// Pattern 6.8: Refresh Data
// -----------------------------------------------------------

// Button_Refresh.OnSelect
Set(AppState, Patch(AppState, {IsLoading: true}));
ClearCollect(
    MyRecentItems,
    FirstN(
        Sort(
            Filter(
                Items,
                CanAccessRecord(Owner.Email),
                Status <> "Archived",
                'Modified On' >= DateRanges.Last30Days
            ),
            'Modified On',
            SortOrder.Descending
        ),
        50
    )
);
Set(AppState, Patch(AppState, {IsLoading: false, LastRefresh: Now()}));
NotifySuccess("Data refreshed at " & Text(Now(), "h:mm AM/PM"))


// -----------------------------------------------------------
// Pattern 6.9: Reset All Filters
// -----------------------------------------------------------

// Button_ResetFilters.OnSelect
Set(ActiveFilters, {
    UserScope: GetUserScope(),
    DepartmentScope: GetDepartmentScope(),
    DateRangeStart: DateRanges.StartOfMonth,
    DateRangeEnd: DateRanges.Today,
    DateRangeName: "thismonth",
    ActiveOnly: true,
    IncludeArchived: false,
    StatusFilter: Blank(),
    SearchTerm: "",
    CategoryFilter: Blank(),
    PriorityFilter: Blank(),
    OwnerFilter: Blank(),
    CurrentPage: 1,
    PageSize: AppConfig.ItemsPerPage
});
Reset(TextInput_Search);
Reset(Dropdown_Status);
Reset(Dropdown_Category);
Reset(Dropdown_DateRange);
NotifyInfo("All filters reset")


// ============================================================
// SECTION 7: FORM PATTERNS
// ============================================================

// -----------------------------------------------------------
// Pattern 7.1: Conditional Form Mode
// -----------------------------------------------------------

// Form_Details.DefaultMode
If(
    IsBlank(UIState.SelectedItem),
    FormMode.New,
    If(
        CanEditRecord(UIState.SelectedItem.Owner.Email, UIState.SelectedItem.Status),
        FormMode.Edit,
        FormMode.View
    )
)


// -----------------------------------------------------------
// Pattern 7.2: DataCard Default Values with User Context
// -----------------------------------------------------------

// DataCardValue_Owner.DefaultSelectedItems
If(
    HasPermission("ViewAll"),
    // Can select anyone
    LookUp(Users, Email = Coalesce(UIState.SelectedItem.Owner.Email, User().Email)),
    // Must be current user
    LookUp(Users, Email = User().Email)
)

// DataCardValue_Department.Default
If(
    IsBlank(GetDepartmentScope()),
    "",  // Admin can leave blank
    UserProfile.Department  // Pre-fill with user's department
)

// DataCardValue_CreatedBy.Default
UserProfile.Email

// DataCardValue_CreatedOn.Default
Now()


// -----------------------------------------------------------
// Pattern 7.3: DataCard Visibility
// -----------------------------------------------------------

// DataCard_AdminNotes.Visible
HasRole("Admin")

// DataCard_ApprovalSection.Visible
HasPermission("Approve") && Form.Mode <> FormMode.New

// DataCard_AuditInfo.Visible
HasPermission("Audit")


// -----------------------------------------------------------
// Pattern 7.4: Form Submit with Validation
// -----------------------------------------------------------

// Button_Submit.OnSelect
If(
    Form.Valid,
    SubmitForm(Form_Details);
    NotifyActionCompleted(
        If(Form.Mode = FormMode.New, "Created", "Updated"),
        DataCardValue_Name.Value
    );
    Set(UIState, Patch(UIState, {IsEditMode: false, UnsavedChanges: false}));
    Back(),
    NotifyValidationError("Form", "Please correct the errors before submitting")
)


// ============================================================
// SECTION 8: SCREEN PATTERNS
// ============================================================

// -----------------------------------------------------------
// Pattern 8.1: Screen.OnVisible - Load Data
// -----------------------------------------------------------

// DetailsScreen.OnVisible
Set(AppState, Patch(AppState, {CurrentScreen: "Details"}));
If(
    !CanAccessRecord(UIState.SelectedItem.Owner.Email),
    NotifyPermissionDenied("view this record");
    Navigate(HomeScreen, ScreenTransition.None)
)


// -----------------------------------------------------------
// Pattern 8.2: Screen.OnVisible - Filter Context
// -----------------------------------------------------------

// DepartmentScreen.OnVisible
Set(AppState, Patch(AppState, {CurrentScreen: "Department"}));
Set(ActiveFilters,
    Patch(ActiveFilters, {
        DepartmentScope: Coalesce(UIState.SelectedDepartment, UserProfile.Department)
    })
)


// -----------------------------------------------------------
// Pattern 8.3: Screen.OnVisible - Permission Check
// -----------------------------------------------------------

// AdminScreen.OnVisible
If(
    !HasRole("Admin"),
    NotifyPermissionDenied("access admin area");
    Navigate(HomeScreen, ScreenTransition.None),
    Set(AppState, Patch(AppState, {CurrentScreen: "Admin"}))
)


// ============================================================
// SECTION 9: AGGREGATION PATTERNS
// ============================================================

// -----------------------------------------------------------
// Pattern 9.1: Count with User Scope
// -----------------------------------------------------------

// Label_TotalCount.Text
Text(
    CountRows(
        Filter(
            Items,
            CanAccessRecord(Owner.Email),
            If(ActiveFilters.ActiveOnly, Status <> "Archived", true)
        )
    )
) & " items"


// -----------------------------------------------------------
// Pattern 9.2: Sum with Filters
// -----------------------------------------------------------

// Label_TotalAmount.Text
FormatCurrency(
    Sum(
        Filter(
            Invoices,
            CanAccessRecord('Sales Rep'.Email)
        ),
        'Total Amount'
    ),
    "$"
)


// -----------------------------------------------------------
// Pattern 9.3: Overdue Count (MEZ Timezone)
// -----------------------------------------------------------

// Label_OverdueCount.Text
Text(
    CountRows(
        Filter(
            Tasks,
            CanAccessRecord('Assigned To'.Email),
            'Due Date' < GetMEZToday(),
            Status in ["Active", "In Progress", "Pending"]
        )
    )
)


// -----------------------------------------------------------
// Pattern 9.4: Completion Percentage
// -----------------------------------------------------------

// Label_CompletionRate.Text
FormatPercent(
    CountRows(Filter(Tasks, CanAccessRecord('Assigned To'.Email), Status = "Completed")) /
    Max(1, CountRows(Filter(Tasks, CanAccessRecord('Assigned To'.Email)))),
    1
)


// ============================================================
// SECTION 10: ACCESSIBILITY PATTERNS
// ============================================================

// -----------------------------------------------------------
// Pattern 10.1: Accessible Labels
// -----------------------------------------------------------

// Button_Delete.AccessibleLabel
"Delete " & Gallery.Selected.Name

// Button_Edit.AccessibleLabel
"Edit " & Gallery.Selected.Name & ", " & GetRoleLabel() & " access"


// -----------------------------------------------------------
// Pattern 10.2: Status Announcements
// -----------------------------------------------------------

// Label_StatusAnnouncement.Text (Live region)
If(
    AppState.IsLoading,
    "Loading data, please wait",
    If(
        !IsBlank(AppState.LastError),
        "Error: " & AppState.ErrorMessage,
        "Data loaded: " & Text(CountRows(Gallery.Items)) & " items displayed"
    )
)


// ============================================================
// END OF CONTROL PATTERNS
// ============================================================
