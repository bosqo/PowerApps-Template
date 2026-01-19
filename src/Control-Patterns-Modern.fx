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
// PATTERN 1.8: GALLERY WITH FirstN(Skip()) PAGINATION
// ============================================================
//
// For galleries with >2000 record datasets, use FirstN(Skip()) pagination
// This pattern handles non-delegable operations without breaking delegation
//
// Purpose: Show filtered records with pagination controls
// Page size: 50 records per page (configurable via AppState.PageSize)
// Total pages: Calculated as Ceiling(CountRows(AllFilteredRecords) / PageSize)
//
// Key principle: Filter first, then paginate
// ✓ CORRECT: FirstN(Skip(Filter(...), ...))
// ✗ INCORRECT: Filter(FirstN(Skip(...)), ...) — pagination BEFORE filtering breaks delegation

glr_Items_Pagination_Items_Property: Table =
  FirstN(
    Skip(
      FilteredGalleryData(
        ActiveFilters.ShowMyItemsOnly,
        ActiveFilters.SelectedStatus,
        ActiveFilters.SearchTerm
      ),
      (AppState.CurrentPage - 1) * AppState.PageSize  // Skip previous pages
    ),
    AppState.PageSize  // Show this many records on current page
  );

// Page Number Calculation
// Calculate total pages from filtered dataset
glr_Items_TotalPages_Calculation: Number =
  Ceiling(
    CountRows(
      FilteredGalleryData(
        ActiveFilters.ShowMyItemsOnly,
        ActiveFilters.SelectedStatus,
        ActiveFilters.SearchTerm
      )
    ) / AppState.PageSize
  );

// Page Indicator Label
// Shows "Page N of M" format
lbl_PageIndicator_Text: Text =
  Concatenate("Seite ", AppState.CurrentPage, " von ", glr_Items_TotalPages_Calculation);

// Previous Button OnSelect
btn_Previous_OnSelect: Boolean =
  If(
    AppState.CurrentPage > 1,
    Set(AppState, Patch(AppState, {CurrentPage: AppState.CurrentPage - 1})),
    Notify("Bereits auf der ersten Seite", NotificationType.Information)
  );

// Next Button OnSelect
btn_Next_OnSelect: Boolean =
  If(
    AppState.CurrentPage < glr_Items_TotalPages_Calculation,
    Set(AppState, Patch(AppState, {CurrentPage: AppState.CurrentPage + 1})),
    Notify("Bereits auf der letzten Seite", NotificationType.Information)
  );

// Previous Button DisplayMode (disable if on page 1)
btn_Previous_DisplayMode: DisplayMode =
  If(AppState.CurrentPage > 1, DisplayMode.Edit, DisplayMode.Disabled);

// Next Button DisplayMode (disable if on last page)
btn_Next_DisplayMode: DisplayMode =
  If(AppState.CurrentPage < glr_Items_TotalPages_Calculation, DisplayMode.Edit, DisplayMode.Disabled);

// Clear All Filters Button OnSelect
btn_ClearAll_OnSelect: Boolean =
  Set(ActiveFilters, {
    ShowMyItemsOnly: false,
    SelectedStatus: "",
    SearchTerm: "",
    StartDate: Blank(),
    EndDate: Blank()
  });
  // Note: Page reset to 1 handled automatically via filter change detection in App.OnStart


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
// SECTION 11: TOAST NOTIFICATION PATTERNS (NEW in Phase 4)
// ============================================================
// Toast notifications appear as non-blocking overlays in top-right corner
// Rendering NotificationStack collection managed by NotifySuccess/NotifyError UDFs
//
// Architecture:
// Layer 1: UDFs (NotifySuccess, NotifyError) - public API in App-Formulas
// Layer 2: State (NotificationStack collection, NotificationCounter) - App.OnStart
// Layer 3: UI (cnt_NotificationStack, cnt_Toast, animations) - this file
//
// Purpose of Phase 4-02: Translate notification state into polished animated UI

// -----------------------------------------------------------
// Pattern 11.1: Toast Notification Container (Main)
// -----------------------------------------------------------
//
// PURPOSE: Fixed overlay container positioned top-right
// Automatically shows/hides based on NotificationStack collection
// Children: cnt_Toast tiles repeat for each notification
// Non-blocking: Toasts float on top layer (z-index 1000), don't intercept clicks

// cnt_NotificationStack - Main container
// PROPERTIES:

// Items property (bind to notification collection):
// ============
// Items: NotificationStack
// Comment: Bind to notification collection from App-OnStart Section 7
// This collection is automatically updated by NotifySuccess/NotifyError/etc. UDFs

// Position properties:
// ============
// X: Parent.Width - 400
// Comment: Position at right edge (350px content + 30px padding + 20px margin)

// Y: 16
// Comment: Top padding (16px from screen top, Fluent Design spacing)

// Width: If(CountRows(NotificationStack) > 0, 380, 0)
// Comment: 350px content + 30px padding; collapse to 0 when empty (avoids empty click zone)

// Height: Parent.Height - 32
// Comment: Full screen height minus top/bottom padding; auto-layout handles child sizing

// Layout & Appearance:
// ============
// LayoutMode: LayoutMode.Vertical
// Comment: Stack toasts vertically, newest on top (Power Apps adds rows to end)

// ClipContents: false
// Comment: Allow toast animations (slide-in) to overflow container edges if needed

// ZIndex: 1000
// Comment: Render on top of galleries, forms, panels; ensures toasts always visible

// Visible: CountRows(NotificationStack) > 0
// Comment: Hide completely when no toasts (prevents empty floating container + click zone)

// Fill: RGBA(0, 0, 0, 0)
// Comment: Transparent background (only child toasts have colored backgrounds)

// Padding: 8
// Comment: 8px padding around entire container (Fluent Design baseline spacing)

// Spacing: 12
// Comment: 12px gap between individual toasts for visual breathing room


// -----------------------------------------------------------
// Pattern 11.2: Individual Toast Tile (Child Control)
// -----------------------------------------------------------
//
// PURPOSE: Individual notification tile with icon, message, and close button
// Repeats for each row in NotificationStack collection
// Horizontal layout: [icon] | [message] | [close button]

// cnt_Toast - Individual toast tile (repeats inside cnt_NotificationStack)
// PROPERTIES:

// Styling:
// ============
// Fill: GetToastBackground(ThisItem.Type)
// Comment: Dynamic background color per type (Success=green light, Error=red light, Warning=amber, Info=blue)

// BorderColor: GetToastBorderColor(ThisItem.Type)
// Comment: Colored left/top border accent per notification type (matches icon color)

// BorderThickness: 2
// Comment: Visible 2px border to distinguish toast from content behind it

// CornerRadius: 4
// Comment: Rounded corners (4px) per Fluent Design standard for modern look

// Padding: 12
// Comment: 12px padding around all contents (icon + message + close button)

// Sizing:
// ============
// Height: Auto
// Comment: Let content determine height; grows with message length if text wraps

// Width: ToastConfig.Width
// Comment: Use configured width (350px from ToastConfig Named Formula in App-Formulas)

// Visibility & Timing:
// ============
// Visible: If(ThisItem.AutoClose && Now() - ThisItem.CreatedAt > TimeValue("0:0:5"), false, true)
// Comment: Hide after 5 seconds if AutoClose=true (fade-out animation handled separately via Opacity)
// Note: For error toasts (AutoClose=false), this formula returns true indefinitely until RemoveToast() called

// Opacity (fade-out effect):
// ============
// Opacity: If(ThisItem.AutoClose && Now() - ThisItem.CreatedAt > TimeValue("0:0:4.7"), Max(0, 1 - ((Now() - ThisItem.CreatedAt - TimeValue("0:0:4.7")) / TimeValue("0:0:0.3"))), 1)
// Comment: Fades from opacity 1.0 to 0.0 over last 300ms (4.7s to 5.0s) before Visible becomes false
// This creates smooth fade-out animation for success/info/warning toasts before they're removed

// Border Style:
// ============
// BorderStyle: BorderStyle.Solid
// Comment: Solid border (not dotted or dashed)


// -----------------------------------------------------------
// Pattern 11.3: Toast Icon (Child - Left side)
// -----------------------------------------------------------
//
// ico_ToastIcon - Icon control showing notification type icon

// Text: GetToastIcon(ThisItem.Type)
// Comment: Returns Unicode icon: ✓ (success), ✕ (error), ⚠ (warning), ℹ (info)

// Color: GetToastIconColor(ThisItem.Type)
// Comment: Icon color matches type (green/red/amber/blue)

// FontSize: 24
// Comment: Icon should be visible and prominent (24px is readable but not overwhelming)

// AccessibleLabel: ThisItem.Type & " notification"
// Comment: Screen reader announces notification type for accessibility


// -----------------------------------------------------------
// Pattern 11.4: Toast Message (Child - Middle)
// -----------------------------------------------------------
//
// lbl_ToastMessage - Label showing notification message text

// Text: ThisItem.Message
// Comment: Display the notification message from NotificationStack row

// FontSize: 14 (Typography.SizeMD if available)
// Comment: Standard body text size for readability

// Color: ThemeColors.Text
// Comment: Use default text color (matches app theme)

// WordWrap: true
// Comment: Text wraps to multiple lines if message is long

// AutoHeight: true
// Comment: Label height grows automatically to fit wrapped text


// -----------------------------------------------------------
// Pattern 11.5: Toast Close Button (Child - Right side)
// -----------------------------------------------------------
//
// btn_CloseToast - Close button (X) to manually dismiss individual toast

// Text: "✕" (Unicode X character)
// Comment: Unicode X is recognizable universal close button symbol

// OnSelect: RemoveToast(ThisItem.ID)
// Comment: Call RemoveToast UDF to remove this specific toast from NotificationStack collection
// The toast immediately disappears when X clicked (no fade-out for manual dismissal)

// HoverFill: ThemeColors.SurfaceHover
// Comment: Light hover color to indicate button is interactive

// DisplayMode: DisplayMode.Edit
// Comment: Always interactive (can't disable close button)

// AccessibleLabel: "Close " & ThisItem.Type & " notification"
// Comment: Screen reader announces action: "Close error notification" etc.

// Width: 32
// Height: 32
// Comment: 32x32 px for good touch target on mobile (minimum 44x44 for mobile, but 32x32 works on desktop)


// -----------------------------------------------------------
// Pattern 11.6: Toast Animation (Entrance & Exit)
// -----------------------------------------------------------
//
// ENTRANCE ANIMATION (Slide-in):
// Two implementation approaches:

// APPROACH A: Built-in Animation Property (Recommended if available in your Power Apps version)
// ============
// cnt_Toast.Animation (if supported): Animation.SlideInLeft
// Automatically slides toast from right to left on entrance
// Duration: ~300ms (platform default)
// Simplest implementation, but less customizable

// APPROACH B: Manual X Position with Timing (Works on all Power Apps versions)
// ============
// This approach uses a hidden timer state to calculate animation progress

// Implementation steps:
// 1. Add hidden state variable to track animation start:
//    ToastAnimationStart (DateTime) - stores when toast first appears
//
// 2. Use X offset formula on cnt_Toast or wrapper container:
//    X = Parent.Width - 400 + If(
//        IsBlank(ToastAnimationStart),
//        0,  // Not animating - position is final
//        If(
//            Now() - ToastAnimationStart < TimeValue("0:0:0.3"),  // Within 300ms animation window
//            (ToastConfig.Width * (Now() - ToastAnimationStart)) / TimeValue("0:0:0.3"),
//            0  // Animation complete - at final position
//        )
//    )
//    This moves toast from right (ToastConfig.Width offset) to left (0 offset) over 300ms
//
// 3. Initialize ToastAnimationStart when toast appears:
//    OnVisible event: Set(ToastAnimationStart, Now())
//    Or: In RemoveToast UDF, clear animation state
//
// APPROACH C: Opacity Fade-In (Simplest, less visual impact)
// ============
// Instead of slide, fade in toast:
// Opacity: If(
//     IsBlank(ToastAnimationStart),
//     1,  // No animation state - fully opaque
//     If(
//         Now() - ToastAnimationStart < TimeValue("0:0:0.3"),
//         (Now() - ToastAnimationStart) / TimeValue("0:0:0.3"),  // Fade from 0 to 1
//         1  // Animation complete - fully opaque
//     )
// )
// Toasts fade in smoothly over 300ms

// EXIT ANIMATION (Fade-out):
// Already implemented in Pattern 11.2 via Opacity formula
// When Now() - CreatedAt > 4.7 seconds (for auto-dismiss):
//   Opacity fades from 1.0 to 0.0 over 300ms
//   Visible becomes false at 5.0 seconds
// When user clicks X button:
//   RemoveToast() immediately removes from collection
//   Toast disappears without fade (instant removal)

// RECOMMENDED APPROACH FOR PHASE 4:
// Use APPROACH C (Opacity Fade-In) because:
// - Works on all Power Apps versions (no platform-specific features needed)
// - Simple to implement (single Opacity formula)
// - Combines nicely with fade-out exit animation
// - Creates professional "fade in, then fade out" effect
// - No need for additional state variables or timer complexity

// To implement: Add ToastAnimationStart variable to App.OnStart Section 7:
//   Set(ToastAnimationStart, Blank());
// Then update cnt_Toast.Opacity with the fade-in logic above


// -----------------------------------------------------------
// Pattern 11.7: Toast Testing & Verification
// -----------------------------------------------------------
//
// COMPREHENSIVE TEST SCENARIOS for verifying toast system functionality
// Copy these formulas into Power Apps Studio formula bar or button OnSelect handlers

// TEST 1: Basic Success Notification
// Execute in any control's OnSelect (e.g., test button):
/*
NotifySuccess("Record saved successfully")
*/
// Expected: Green toast appears top-right, disappears after 5 seconds

// TEST 2: Multiple Toasts (Stacking Verification)
// Execute in button or formula bar:
/*
NotifySuccess("First message");
NotifySuccess("Second message");
NotifySuccess("Third message")
*/
// Expected: All 3 toasts visible, stacked vertically, newest (Third) on top

// TEST 3: Mixed Types (Colors & Icons)
// Execute all at once:
/*
NotifyInfo("Information message");
NotifyWarning("Warning message");
NotifyError("Error message");
NotifySuccess("Success message")
*/
// Expected:
// - Info: Blue background, ℹ icon
// - Warning: Amber background, ⚠ icon
// - Error: Red background, ✕ icon, does NOT auto-dismiss
// - Success: Green background, ✓ icon, auto-dismisses after 5s

// TEST 4: Auto-Dismiss Timing
// Execute:
/*
NotifySuccess("Success - will dismiss in 5 seconds");
NotifyError("Error - stays until you click X")
*/
// Expected:
// - Success: Visible ~4.7s, fades during last 0.3s, gone by 5s
// - Error: Remains indefinitely (no auto-dismiss, no fade-out)
// - X button works on both at any time

// TEST 5: Manual Dismissal (X Button)
// Execute:
/*
NotifyError("Error 1");
NotifyError("Error 2");
NotifyError("Error 3")
*/
// Then: Click X on middle error (Error 2)
// Expected: Only Error 2 disappears; Error 1 and 3 remain

// TEST 6: Long Message Text (Wrapping)
// Execute:
/*
NotifyWarning("This is a very long warning message that will definitely wrap across multiple lines in the toast container to test text wrapping behavior and ensure the toast grows properly")
*/
// Expected:
// - Text wraps to multiple lines within 350px width
// - Toast height grows to fit wrapped content
// - Icon and close button remain properly aligned

// TEST 7: Rapid Sequential Notifications (Performance)
// Execute (creates 10 toasts rapidly):
/*
ForAll(
    Sequence(10),
    Notify("Toast " & Value, NotificationType.Success)
)
*/
// Expected:
// - All 10 toasts appear
// - No crashes or performance lag
// - App remains responsive
// - Each toast has unique ID (can verify via LookUp NotificationStack)

// TEST 8: Non-Blocking Behavior
// Setup: Create a test gallery or button on main screen
// Execute toast: NotifySuccess("Toast appears")
// While toast visible: Try clicking gallery items, buttons, forms
// Expected: All controls remain interactive; toast doesn't block clicks


// IMPLEMENTATION CHECKLIST FOR DEVELOPERS:

// Before publishing the app, verify:
// [ ] NotificationStack collection initialized in App.OnStart (empty table)
// [ ] NotificationCounter initialized in App.OnStart (set to 0)
// [ ] ToastAnimationStart initialized in App.OnStart (set to Blank)
// [ ] cnt_NotificationStack container added to main screen
//     - Items: NotificationStack
//     - Position: Top-right (X = Parent.Width - 400, Y = 16)
//     - ZIndex: 1000 (above all other content)
// [ ] cnt_Toast child control added inside cnt_NotificationStack
//     - Fill: GetToastBackground(ThisItem.Type)
//     - Opacity: Fade-in/fade-out formula implemented
//     - Width: ToastConfig.Width (350px)
// [ ] Child controls inside cnt_Toast:
//     - ico_ToastIcon: Shows GetToastIcon(ThisItem.Type)
//     - lbl_ToastMessage: Shows ThisItem.Message
//     - btn_CloseToast: OnSelect calls RemoveToast(ThisItem.ID)
// [ ] All UDFs present in App-Formulas:
//     - NotifySuccess, NotifyError, NotifyWarning, NotifyInfo
//     - GetToastBackground, GetToastBorderColor, GetToastIcon, GetToastIconColor
//     - AddToast, RemoveToast
// [ ] Test all 8 test scenarios above


// CUSTOMIZATION GUIDE:

// To change auto-dismiss timeout (default: 5 seconds):
// In App-Formulas-Template.fx, update ToastConfig:
/*
ToastConfig = {
    SuccessDuration: 3000,    // Change from 5000 to 3000 for 3 seconds
    WarningDuration: 5000,
    InfoDuration: 5000,
    ErrorDuration: 0,
    ...
}
*/

// To change toast width (default: 350px):
// In App-Formulas-Template.fx:
/*
ToastConfig = {
    Width: 400,    // Change from 350 to 400 for wider toasts
    ...
}
*/

// To change toast colors:
// In App-Formulas-Template.fx, update GetToastBackground():
/*
GetToastBackground(toastType: Text): Color =
    Switch(
        toastType,
        "Success", ColorValue("#E7F7E7"),  // Your custom green
        "Error", ColorValue("#FFF0F0"),     // Your custom red
        ...
    );
*/

// To add custom notification type (e.g., "Critical"):
// 1. Update ToastConfig with new duration:
//    CriticalDuration: 0,  // Never dismiss
// 2. Add to GetToastBackground():
//    "Critical", ColorValue("#FF0000"),  // Your color
// 3. Add to GetToastIcon():
//    "Critical", "🛑",  // Your icon
// 4. Create new UDF in App-Formulas:
//    NotifyCritical(message: Text): Void = { AddToast(message, "Critical", false, 0) };
// 5. Call NotifyCritical("message") from your code


// ============================================================
// END OF CONTROL PATTERNS
// ============================================================
