// ============================================================
// APP.ONSTART - Minimal Modern Pattern (2025)
// ============================================================
//
// This is the modernized App.OnStart formula that works with
// App-Formulas-Template.fx (Named Formulas + UDFs)
//
// KEY PRINCIPLE:
// App.OnStart should ONLY contain:
// 1. Mutable state initialization
// 2. Data collection loading (ClearCollect)
// 3. One-time imperative actions
//
// Everything else (computed values, static configs, derived data)
// should be in App.Formulas as Named Formulas or UDFs
//
// ============================================================


// ============================================================
// 1. APPLICATION STATE (Mutable)
// ============================================================
// State that changes during app usage
Set(AppState, {
    // Loading States
    IsLoading: false,
    IsInitializing: true,
    IsSaving: false,

    // Navigation
    CurrentScreen: "Home",
    PreviousScreen: Blank(),

    // Session Info
    SessionStart: Now(),
    LastRefresh: Now(),
    LastAction: Blank(),

    // Connectivity
    IsOnline: Connection.Connected,

    // Error Handling
    LastError: Blank(),
    ShowErrorDialog: false,
    ErrorMessage: "",
    ErrorDetails: ""
});


// ============================================================
// 2. ACTIVE FILTERS (Mutable)
// ============================================================
// User-modifiable filter state (can be changed via UI controls)
// Uses UDFs from App.Formulas for default values
Set(ActiveFilters, {
    // Scope Filters (initialized from UDFs)
    UserScope: GetUserScope(),
    DepartmentScope: GetDepartmentScope(),

    // Date Filters
    DateRangeStart: DateRanges.StartOfMonth,
    DateRangeEnd: DateRanges.Today,
    DateRangeName: "thismonth",

    // Status Filters
    ActiveOnly: true,
    IncludeArchived: false,
    StatusFilter: Blank(),

    // Search & Custom Filters
    SearchTerm: "",
    CategoryFilter: Blank(),
    PriorityFilter: Blank(),
    OwnerFilter: Blank(),

    // Pagination
    CurrentPage: 1,
    PageSize: AppConfig.ItemsPerPage
});


// ============================================================
// 3. UI STATE (Mutable)
// ============================================================
// UI-related state for dialogs, panels, selections
Set(UIState, {
    // Selection State
    SelectedItem: Blank(),
    SelectedItems: Table(),
    SelectionMode: "single",  // "single" | "multiple"

    // Panel States
    IsDetailsPanelOpen: false,
    IsFilterPanelOpen: false,
    IsSettingsPanelOpen: false,

    // Dialog States
    IsConfirmDialogOpen: false,
    ConfirmDialogTitle: "",
    ConfirmDialogMessage: "",
    ConfirmDialogAction: Blank(),

    // Form States
    IsEditMode: false,
    FormMode: FormMode.View,
    UnsavedChanges: false
});


// ============================================================
// 4. DATA CACHE - Static Lookup Data
// ============================================================
// Load commonly used lookup/reference data once at startup
// These are used for dropdowns, filters, and validation
//
// Refactored 2025: Using Concurrent() for parallel data loading
// This improves app startup performance by fetching data simultaneously

Concurrent(
    // Departments (for dropdowns) - from Dataverse
    ClearCollect(
        CachedDepartments,
        Sort(
            Filter(
                Departments,
                Status = "Active"
            ),
            Name,
            SortOrder.Ascending
        )
    ),

    // Categories (for dropdowns) - from Dataverse
    ClearCollect(
        CachedCategories,
        Sort(
            Filter(
                Categories,
                Status = "Active"
            ),
            Name,
            SortOrder.Ascending
        )
    ),

    // Statuses (for dropdowns) - static table
    ClearCollect(
        CachedStatuses,
        Table(
            {Value: "Active", DisplayName: "Active", SortOrder: 1},
            {Value: "Pending", DisplayName: "Pending", SortOrder: 2},
            {Value: "In Progress", DisplayName: "In Progress", SortOrder: 3},
            {Value: "On Hold", DisplayName: "On Hold", SortOrder: 4},
            {Value: "Completed", DisplayName: "Completed", SortOrder: 5},
            {Value: "Cancelled", DisplayName: "Cancelled", SortOrder: 6},
            {Value: "Archived", DisplayName: "Archived", SortOrder: 7}
        )
    ),

    // Priorities (for dropdowns) - static table
    ClearCollect(
        CachedPriorities,
        Table(
            {Value: "Critical", DisplayName: "Critical", SortOrder: 1},
            {Value: "High", DisplayName: "High", SortOrder: 2},
            {Value: "Medium", DisplayName: "Medium", SortOrder: 3},
            {Value: "Low", DisplayName: "Low", SortOrder: 4},
            {Value: "None", DisplayName: "None", SortOrder: 5}
        )
    ),

    // Date Range Options (for dropdowns) - static table
    ClearCollect(
        CachedDateRanges,
        Table(
            {Value: "today", DisplayName: "Today", SortOrder: 1},
            {Value: "thisweek", DisplayName: "This Week", SortOrder: 2},
            {Value: "thismonth", DisplayName: "This Month", SortOrder: 3},
            {Value: "thisquarter", DisplayName: "This Quarter", SortOrder: 4},
            {Value: "thisyear", DisplayName: "This Year", SortOrder: 5},
            {Value: "last7days", DisplayName: "Last 7 Days", SortOrder: 6},
            {Value: "last30days", DisplayName: "Last 30 Days", SortOrder: 7},
            {Value: "last90days", DisplayName: "Last 90 Days", SortOrder: 8},
            {Value: "custom", DisplayName: "Custom Range", SortOrder: 9}
        )
    )
);


// ============================================================
// 5. USER-SCOPED DATA CACHE
// ============================================================
// Pre-filtered data based on user's access scope
// Uses UDFs for access control

// My Recent Items (user's own or all if admin)
ClearCollect(
    MyRecentItems,
    FirstN(
        Sort(
            Filter(
                Items,
                // Use UDF for access control
                CanAccessRecord(Owner.Email),
                // Active records only
                Status <> "Archived",
                // Recent records
                'Modified On' >= DateRanges.Last30Days
            ),
            'Modified On',
            SortOrder.Descending
        ),
        50  // Limit to 50 most recent
    )
);

// My Pending Tasks (user's assigned tasks)
ClearCollect(
    MyPendingTasks,
    Sort(
        Filter(
            Tasks,
            // Assigned to current user
            'Assigned To'.Email = User().Email,
            // Not completed
            Status in ["Active", "Pending", "In Progress"],
            // Due within next 30 days or overdue
            'Due Date' <= DateRanges.Next30Days
        ),
        'Due Date',
        SortOrder.Ascending
    )
);

// Dashboard Counts (KPI data)
Set(DashboardCounts, {
    TotalItems: CountRows(
        Filter(
            Items,
            CanAccessRecord(Owner.Email),
            Status <> "Archived"
        )
    ),
    ActiveItems: CountRows(
        Filter(
            Items,
            CanAccessRecord(Owner.Email),
            Status = "Active"
        )
    ),
    PendingTasks: CountRows(MyPendingTasks),
    OverdueTasks: CountRows(
        Filter(
            MyPendingTasks,
            IsOverdue('Due Date')
        )
    )
});


// ============================================================
// 6. FINALIZE INITIALIZATION
// ============================================================
// Mark app as ready
Set(AppState,
    Patch(AppState, {
        IsInitializing: false,
        IsLoading: false,
        LastRefresh: Now()
    })
);


// ============================================================
// HELPER FUNCTIONS FOR COMMON ACTIONS
// (Copy these to Button.OnSelect as needed)
// ============================================================

/*
// --- REFRESH DATA ---
// Button_Refresh.OnSelect
Set(AppState, Patch(AppState, {IsLoading: true}));
ClearCollect(
    MyRecentItems,
    FirstN(
        Sort(
            Filter(Items, CanAccessRecord(Owner.Email), Status <> "Archived", 'Modified On' >= DateRanges.Last30Days),
            'Modified On', SortOrder.Descending
        ), 50
    )
);
Set(AppState, Patch(AppState, {IsLoading: false, LastRefresh: Now()}));
NotifySuccess("Data refreshed");


// --- UPDATE FILTERS ---
// Dropdown_DateRange.OnChange
Set(ActiveFilters,
    Patch(ActiveFilters, {
        DateRangeName: Self.Selected.Value,
        DateRangeStart: GetDateRangeStart(Self.Selected.Value),
        DateRangeEnd: GetDateRangeEnd(Self.Selected.Value)
    })
);


// --- TOGGLE SHOW ALL ---
// Toggle_ShowAll.OnChange
Set(ActiveFilters,
    Patch(ActiveFilters, {
        UserScope: If(
            Self.Value && HasPermission("ViewAll"),
            Blank(),
            User().Email
        )
    })
);
NotifyInfo("Filter updated");


// --- RESET FILTERS ---
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
NotifyInfo("Filters reset to defaults");


// --- NAVIGATE WITH STATE ---
// Button_ViewDetails.OnSelect
Set(UIState, Patch(UIState, {SelectedItem: Gallery.Selected}));
Set(AppState, Patch(AppState, {PreviousScreen: AppState.CurrentScreen, CurrentScreen: "Details"}));
Navigate(DetailsScreen, ScreenTransition.None);


// --- DELETE WITH CONFIRMATION ---
// Button_Delete.OnSelect
If(
    HasPermission("Delete") && CanDeleteRecord(Gallery.Selected.Owner.Email),
    Set(UIState, Patch(UIState, {
        IsConfirmDialogOpen: true,
        ConfirmDialogTitle: "Confirm Delete",
        ConfirmDialogMessage: "Are you sure you want to delete this item?",
        ConfirmDialogAction: "delete"
    })),
    NotifyPermissionDenied("delete items")
);

// ConfirmDialog_Yes.OnSelect
If(
    UIState.ConfirmDialogAction = "delete",
    Remove(Items, UIState.SelectedItem);
    NotifyActionCompleted("Delete", UIState.SelectedItem.Name);
    Set(UIState, Patch(UIState, {
        IsConfirmDialogOpen: false,
        SelectedItem: Blank()
    }))
);
*/


// ============================================================
// END OF APP.ONSTART
// ============================================================
