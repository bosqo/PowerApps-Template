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
//
// CONTROL NAMING CONVENTION:
// {AbbreviatedType}_{Name} (e.g., glr_Orders, btn_Submit, lbl_Status)
//
// Standard Abbreviations:
// - glr = Gallery (e.g., glr_Items, glr_RecentOrders)
// - btn = Button (e.g., btn_Submit, btn_Delete, btn_Cancel)
// - lbl = Label (e.g., lbl_Title, lbl_ErrorMessage)
// - txt = TextInput (e.g., txt_Search, txt_Email, txt_Notes)
// - img = Image (e.g., img_Logo, img_UserAvatar)
// - form = Form (e.g., form_EditItem, form_NewRecord)
// - drp = Dropdown (e.g., drp_Status, drp_Department)
// - ico = Icon (e.g., ico_Delete, ico_Info, ico_Warning)
// - cnt = Container (e.g., cnt_Header, cnt_Sidebar)
// - tog = Toggle (e.g., tog_ActiveOnly, tog_ShowArchived)
// - chk = Checkbox (e.g., chk_Terms, chk_SelectAll)
// - dat = DatePicker (e.g., dat_StartDate, dat_DueDate)
//
// Benefits of abbreviated prefixes:
// - Easier to type (3 chars vs 6-10 for full type name)
// - Consistent length for alignment in formula autocomplete
// - Clear type indication without verbosity
//
// Legacy patterns (AVOID in new code):
// - glr_Items (full type name - too verbose)
// - Button1, Button2 (auto-generated names - not descriptive)
// - submitBtn (camelCase - inconsistent with Power Fx conventions)
//
// ============================================================


// ============================================================
// SHAREPOINT TIMEZONE HANDLING
// ============================================================
// SharePoint stores all datetime fields in UTC
// CET (Central European Time): CET (UTC+1) or CEST (UTC+2 during daylight saving)
//
// Key Functions:
// - ConvertUTCToCET(utcDateTime) - Convert SharePoint UTC to MEZ time
// - GetCETToday() - Get today's date in MEZ timezone
// - FormatDateTimeCET(utcDateTime) - Format UTC datetime in MEZ time
//
// Example: SharePoint 'Modified' field is UTC, use:
//   ConvertUTCToCET('Modified')  -> DateTime in MEZ time
//   DateValue(ConvertUTCToCET('Modified'))  -> Date only
//   FormatDateTimeCET('Modified')  -> Formatted string "d.m.yyyy hh:mm"
//
// For filters comparing SharePoint dates with MEZ timezone:
//   Filter(Items, DateValue(ConvertUTCToCET('Modified')) >= GetCETToday())
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
// glr_Orders.Items
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
// glr_Projects.Items
Filter(
    Projects,
    // Access control via UDF
    CanAccessItem(Owner.Email, Department),
    // Active status via conditional
    If(!ActiveFilters.IncludeArchived, Status <> "Archived", true),
    // Search (native)
    StartsWith(Lower('Project Name'), Lower(ActiveFilters.SearchTerm))
)


// -----------------------------------------------------------
// Pattern 1.3: Gallery with Status and Priority Filters
// -----------------------------------------------------------

// glr_Tasks.Items
Filter(
    Tasks,
    // User access
    CanAccessRecord('Assigned To'.Email),
    // Status filter (if selected)
    If(IsBlank(ActiveFilters.StatusFilter), true, Status = ActiveFilters.StatusFilter),
    // Priority filter (if selected)
    If(IsBlank(ActiveFilters.PriorityFilter), true, Priority = ActiveFilters.PriorityFilter),
    // Active only
    If(!ActiveFilters.IncludeArchived, Status <> "Archived", true),
    // Due in future or today (handles both Date and UTC DateTime fields)
    If(
        IsBlank('Due Date'),
        true,
        // For Date fields (stored locally): use Today()
        // For DateTime fields (stored in UTC from SharePoint): use GetCETToday()
        'Due Date' >= GetCETToday()
    )
)


// -----------------------------------------------------------
// Pattern 1.4: Search Gallery (Delegation-Friendly)
// -----------------------------------------------------------

// glr_Contacts.Items
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

// glr_Invoices.Items
// NOTE: 'Invoice Date' from SharePoint is in UTC, convert with ConvertUTCToCET()
Sort(
    Filter(
        Invoices,
        CanAccessRecord('Sales Rep'.Email),
        DateValue(ConvertUTCToCET('Invoice Date')) >= GetCETToday() - 90,
        If(!ActiveFilters.IncludeArchived, Status <> "Void", true)
    ),
    'Invoice Date',
    SortOrder.Descending
)


// -----------------------------------------------------------
// Pattern 1.6: Paginated Gallery (Refactored 2025 with UDFs)
// -----------------------------------------------------------

// glr_AllRecords.Items - Using pagination UDFs
FirstN(
    Skip(
        Sort(
            Filter(
                Records,
                CanAccessRecord(Owner.Email),
                If(!ActiveFilters.IncludeArchived, Status <> "Archived", true)
            ),
            'Created On',
            SortOrder.Descending
        ),
        GetSkipCount(ActiveFilters.CurrentPage, ActiveFilters.PageSize)
    ),
    ActiveFilters.PageSize
)

// lbl_PageInfo.Text - Page range display
GetPageRangeText(
    ActiveFilters.CurrentPage,
    ActiveFilters.PageSize,
    CountRows(Filter(Records, CanAccessRecord(Owner.Email)))
)

// btn_PreviousPage.DisplayMode
If(CanGoToPreviousPage(ActiveFilters.CurrentPage), DisplayMode.Edit, DisplayMode.Disabled)

// btn_NextPage.DisplayMode
If(
    CanGoToNextPage(
        ActiveFilters.CurrentPage,
        CountRows(Filter(Records, CanAccessRecord(Owner.Email))),
        ActiveFilters.PageSize
    ),
    DisplayMode.Edit,
    DisplayMode.Disabled
)

// btn_PreviousPage.OnSelect
Set(ActiveFilters, Patch(ActiveFilters, {CurrentPage: Max(1, ActiveFilters.CurrentPage - 1)}))

// btn_NextPage.OnSelect
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


// -----------------------------------------------------------
// Pattern 1.7: Filtered Gallery with Active Filter UI (FILT-05)
// -----------------------------------------------------------

// For galleries with datasets >2000 records using multi-condition filters
// Purpose: Show filtered records (status, role-based, search) with UI controls
// Uses FilteredGalleryData() composition from App-Formulas
// Filters are applied via ActiveFilters state variable (updated by UI controls)
//
// Key principle: Gallery.Items calls FilteredGalleryData with current filter values
// Gallery automatically updates when any filter value in ActiveFilters changes

glr_Items_FilteredGallery_Items: Table =
  FilteredGalleryData(
    ActiveFilters.ShowMyItemsOnly,
    ActiveFilters.SelectedStatus,
    ActiveFilters.SearchTerm
  );

// Status Dropdown Control
// Populated with distinct status values from Items table
drp_StatusFilter_Items: Table = Table(
  {Value: ""},
  {Value: "Active"},
  {Value: "Pending"},
  {Value: "Completed"}
);

// Status Dropdown OnChange
drp_StatusFilter_OnChange: Boolean =
  Set(ActiveFilters, Patch(ActiveFilters, {SelectedStatus: drp_StatusFilter.Value}));

// Search TextInput OnChange
txt_SearchBox_OnChange: Boolean =
  Set(ActiveFilters, Patch(ActiveFilters, {SearchTerm: txt_SearchBox.Value}));

// My Items Toggle OnChange
tog_MyItemsOnly_OnChange: Boolean =
  Set(ActiveFilters, Patch(ActiveFilters, {ShowMyItemsOnly: tog_MyItemsOnly.Value}));

// Clear All Button OnSelect
btn_ClearAll_OnSelect: Boolean =
  Set(ActiveFilters, {
    ShowMyItemsOnly: false,
    SelectedStatus: "",
    SearchTerm: ""
  });

// Filter Summary Label (shows active filter count)
lbl_FilterSummary_Text: Text =
  Concatenate(
    "Filter: ",
    If(ActiveFilters.SelectedStatus <> "", Concatenate(ActiveFilters.SelectedStatus, ", "), ""),
    If(ActiveFilters.ShowMyItemsOnly, "Meine Einträge, ", ""),
    If(ActiveFilters.SearchTerm <> "", Concatenate("Suche: '", ActiveFilters.SearchTerm, "'"), "")
  );

// Record Count Label (shows how many records match current filters)
lbl_RecordCount_Text: Text =
  Concatenate(CountRows(glr_Items_FilteredGallery_Items), " Einträge gefunden");


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
// btn_Delete.Visible
HasPermission("Delete")

// btn_Create.Visible
HasPermission("Create")

// btn_Settings.Visible
HasPermission("Settings")


// -----------------------------------------------------------
// Pattern 2.2: Control Visibility Based on Roles
// -----------------------------------------------------------

// cnt_AdminPanel.Visible
HasRole("Admin")

// cnt_ManagerTools.Visible
HasRole("Manager") || HasRole("Admin")

// lbl_InternalOnly.Visible
HasRole("Corporate")

// cnt_DepartmentData.Visible
HasAnyRole("Sales,Finance,IT")


// -----------------------------------------------------------
// Pattern 2.3: Conditional Button Visibility for Record Actions
// -----------------------------------------------------------

// btn_EditRecord.Visible
HasPermission("Edit") && CanAccessRecord(Gallery.Selected.Owner.Email)

// btn_DeleteRecord.Visible (with status check)
HasPermission("Delete") &&
CanDeleteRecord(Gallery.Selected.Owner.Email) &&
!IsOneOf(Gallery.Selected.Status, "Archived,Closed")

// btn_ApproveRecord.Visible
HasPermission("Approve") &&
Gallery.Selected.Status = "Pending"

// btn_ArchiveRecord.Visible
HasPermission("Archive") &&
Gallery.Selected.Status <> "Archived"


// -----------------------------------------------------------
// Pattern 2.4: Feature Flag Visibility
// -----------------------------------------------------------

// cnt_DebugInfo.Visible
FeatureFlags.ShowDebugInfo


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
// ico_StatusIndicator.Color
GetStatusColor(ThisItem.Status)

// lbl_Status.Fill
GetStatusColor(ThisItem.Status)


// -----------------------------------------------------------
// Pattern 3.2: Priority-Based Colors
// -----------------------------------------------------------

// ico_PriorityFlag.Color
GetPriorityColor(ThisItem.Priority)

// rec_PriorityBar.Fill
GetPriorityColor(ThisItem.Priority)


// -----------------------------------------------------------
// Pattern 3.3: Role-Based Colors
// -----------------------------------------------------------

// lbl_RoleBadge.Fill
GetRoleBadgeColor()

// cir_UserAvatar.BorderColor
RoleColor

// ico_UserRole.Color
GetRoleBadgeColor()


// -----------------------------------------------------------
// Pattern 3.4: Theme Color References
// -----------------------------------------------------------

// btn_Primary.Fill
GetThemeColor("Primary")

// btn_Primary.HoverFill
GetThemeColor("PrimaryLight")

// btn_Primary.PressedFill
GetThemeColor("PrimaryDark")

// cnt_Surface.Fill
GetThemeColor("Surface")

// lbl_Secondary.Color
GetThemeColor("TextSecondary")

// rec_Divider.Fill
GetThemeColor("Divider")

// cnt_Error.Fill
GetThemeColor("ErrorLight")


// -----------------------------------------------------------
// Pattern 3.5: Conditional Row Colors (Gallery)
// -----------------------------------------------------------

// Gallery Row Template - rec_RowBackground.Fill
If(
    ThisItem = Gallery.Selected,
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
// lbl_RoleBadge.Text
GetRoleLabel()

// Or short form:
// lbl_RoleBadgeShort.Text
GetRoleBadge()


// -----------------------------------------------------------
// Pattern 4.2: Welcome Message
// -----------------------------------------------------------

// lbl_Welcome.Text
"Welcome, " & UserProfile.DisplayName & " (" & GetRoleLabel() & ")"


// -----------------------------------------------------------
// Pattern 4.3: Date Formatting
// -----------------------------------------------------------

// BEFORE:
/*
Text(ThisItem.'Created On', "mmm d, yyyy")
*/

// AFTER (using German date formatting UDFs with CET timezone):
// For SharePoint Date-only fields (stored as local date):
// lbl_CreatedDate.Text (short format)
FormatDateShort(ThisItem.'Created On')

// lbl_DateShort.Text
FormatDateShort(ThisItem.'Due Date')

// lbl_DateLong.Text
FormatDateLong(ThisItem.'Event Date')

// For SharePoint DateTime fields (stored in UTC - most common):
// lbl_DateTime.Text (auto-converts UTC to CET time)
FormatDateTimeCET(ThisItem.'Last Modified')

// lbl_ModifiedTime.Text (another UTC datetime example)
FormatDateTimeCET(ThisItem.'Created')


// -----------------------------------------------------------
// Pattern 4.4: Status with Due Date Context (CET Timezone)
// -----------------------------------------------------------

// lbl_TaskStatus.Text
// NOTE: If 'Due Date' is a SharePoint DateTime (UTC), compare with GetCETToday()
// If 'Due Date' is a SharePoint Date (local), use Today() instead
If(
    ThisItem.'Due Date' < GetCETToday(),
    "Überfällig: " & Text(GetCETToday() - ThisItem.'Due Date') & " Tage",
    If(
        ThisItem.'Due Date' = GetCETToday(),
        "Fällig heute",
        If(
            ThisItem.'Due Date' > GetCETToday() && !IsBlank(ThisItem.'Due Date'),
            "Fällig in " & Text(ThisItem.'Due Date' - GetCETToday()) & " Tagen",
            ThisItem.Status
        )
    )
)


// -----------------------------------------------------------
// Pattern 4.5: Truncated Text
// -----------------------------------------------------------

// lbl_Description.Text
If(
    Len(Coalesce(ThisItem.Description, "")) > 100,
    Left(ThisItem.Description, 97) & "...",
    Coalesce(ThisItem.Description, "")
)

// Tooltip on lbl_Description.Tooltip
ThisItem.Description


// -----------------------------------------------------------
// Pattern 4.6: Currency and Number Formatting
// -----------------------------------------------------------

// lbl_Amount.Text
FormatCurrency(ThisItem.Amount, "$")

// lbl_Percentage.Text
FormatPercent(ThisItem.CompletionRate, 1)

// lbl_Count.Text
Text(ThisItem.Quantity, "#,##0")


// -----------------------------------------------------------
// Pattern 4.7: User Initials
// -----------------------------------------------------------

// lbl_Avatar.Text
GetInitials(ThisItem.Owner.DisplayName)


// ============================================================
// SECTION 5: ICON PATTERNS
// ============================================================

// -----------------------------------------------------------
// Pattern 5.1: Status Icons
// -----------------------------------------------------------

// ico_Status.Icon
GetStatusIcon(ThisItem.Status)

// ico_Status.Color
GetStatusColor(ThisItem.Status)


// -----------------------------------------------------------
// Pattern 5.2: Conditional Icons (CET Timezone)
// -----------------------------------------------------------

// ico_OverdueWarning.Icon
If(ThisItem.'Due Date' < GetCETToday(), Icon.Warning, Icon.Clock)

// ico_OverdueWarning.Visible
!IsBlank(ThisItem.'Due Date')

// ico_OverdueWarning.Color
If(ThisItem.'Due Date' < GetCETToday(), GetThemeColor("Error"), GetThemeColor("TextSecondary"))


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
// btn_Delete.OnSelect
If(
    HasPermission("Delete") && CanDeleteRecord(Gallery.Selected.Owner.Email),
    Remove(Items, Gallery.Selected);
    NotifyActionCompleted("Delete", Gallery.Selected.Name),
    NotifyPermissionDenied("delete this item")
)


// -----------------------------------------------------------
// Pattern 6.2: Permission-Guarded Edit
// -----------------------------------------------------------

// btn_Edit.OnSelect
If(
    CanEditRecord(Gallery.Selected.Owner.Email, Gallery.Selected.Status),
    Set(UIState, Patch(UIState, {
        SelectedItem: Gallery.Selected,
        FormMode: FormMode.Edit
    }));
    Navigate(EditScreen, ScreenTransition.None),
    NotifyPermissionDenied("edit this record")
)


// -----------------------------------------------------------
// Pattern 6.3: Update Filter State
// -----------------------------------------------------------

// drp_Status.OnChange
Set(ActiveFilters,
    Patch(ActiveFilters, {
        StatusFilter: Self.Selected.Value,
        CurrentPage: 1  // Reset to first page
    })
);
NotifyInfo("Filter applied: " & Self.Selected.DisplayName)


// -----------------------------------------------------------
// Pattern 6.4: Toggle Show All (Admin/Manager)
// -----------------------------------------------------------

// tog_ShowAll.OnChange
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
// Pattern 6.6: Refresh Data
// -----------------------------------------------------------

// btn_Refresh.OnSelect
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
// Pattern 6.7: Reset All Filters
// -----------------------------------------------------------

// btn_ResetFilters.OnSelect
Set(ActiveFilters, {
    UserScope: GetUserScope(),
    DepartmentScope: GetDepartmentScope(),
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
Reset(txt_Search);
Reset(drp_Status);
Reset(drp_Category);
NotifyInfo("All filters reset")


// ============================================================
// SECTION 7: FORM PATTERNS
// ============================================================

// -----------------------------------------------------------
// Pattern 7.1: Conditional Form Mode
// -----------------------------------------------------------

// form_Details.DefaultMode
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

// btn_Submit.OnSelect
If(
    Form.Valid,
    SubmitForm(form_Details);
    NotifyActionCompleted(
        If(Form.Mode = FormMode.New, "Created", "Updated"),
        DataCardValue_Name.Value
    );
    Set(UIState, Patch(UIState, {FormMode: FormMode.View, UnsavedChanges: false}));
    Back(),
    NotifyWarning("Form: Please correct the errors before submitting")
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
    NotifyPermissionDenied("the admin area");
    Navigate(HomeScreen, ScreenTransition.None),
    Set(AppState, Patch(AppState, {CurrentScreen: "Admin"}))
)


// ============================================================
// SECTION 9: AGGREGATION PATTERNS
// ============================================================

// -----------------------------------------------------------
// Pattern 9.1: Count with User Scope
// -----------------------------------------------------------

// lbl_TotalCount.Text
Text(
    CountRows(
        Filter(
            Items,
            CanAccessRecord(Owner.Email),
            If(!ActiveFilters.IncludeArchived, Status <> "Archived", true)
        )
    )
) & " items"


// -----------------------------------------------------------
// Pattern 9.2: Sum with Filters
// -----------------------------------------------------------

// lbl_TotalAmount.Text
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
// Pattern 9.3: Overdue Count (CET Timezone)
// -----------------------------------------------------------

// lbl_OverdueCount.Text
Text(
    CountRows(
        Filter(
            Tasks,
            CanAccessRecord('Assigned To'.Email),
            'Due Date' < GetCETToday(),
            Status in ["Active", "In Progress", "Pending"]
        )
    )
)


// -----------------------------------------------------------
// Pattern 9.4: Completion Percentage
// -----------------------------------------------------------

// lbl_CompletionRate.Text
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

// btn_Delete.AccessibleLabel
"Delete " & Gallery.Selected.Name

// btn_Edit.AccessibleLabel
"Edit " & Gallery.Selected.Name & ", " & GetRoleLabel() & " access"


// -----------------------------------------------------------
// Pattern 10.2: Status Announcements
// -----------------------------------------------------------

// lbl_StatusAnnouncement.Text (Live region)
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
