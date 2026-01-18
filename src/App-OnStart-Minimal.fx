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
//
// REQUIRED DATA SOURCES:
// Connect these tables before using this template:
// 1. Departments (Dataverse/SharePoint) - columns: Name, Status
// 2. Categories (Dataverse/SharePoint) - columns: Name, Status
// 3. Items (Dataverse/SharePoint) - columns: Owner, Status, 'Modified On'
// 4. Tasks (Dataverse/SharePoint) - columns: 'Assigned To', Status, 'Due Date'
//
// ============================================================


// ============================================================
// NAMING CONVENTIONS FOR STATE VARIABLES
// ============================================================
//
// STATE VARIABLES (Set): PascalCase
// - AppState: Application-wide state (loading, navigation, errors)
// - ActiveFilters: User-modifiable filter state
// - UIState: UI component state (panels, dialogs, selections)
//
// COLLECTIONS (ClearCollect): PascalCase with prefix
// - Cached*: Static lookup data loaded at startup (e.g., CachedDepartments)
// - My*: User-scoped data (e.g., MyRecentItems, MyPendingTasks)
// - Filter*: Filtered views of data (if needed)
//
// All variable names must be PascalCase (no underscores, no prefixes)
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
            {Value: "Active", DisplayName: "Aktiv", SortOrder: 1},
            {Value: "Pending", DisplayName: "Ausstehend", SortOrder: 2},
            {Value: "In Progress", DisplayName: "In Bearbeitung", SortOrder: 3},
            {Value: "On Hold", DisplayName: "Wartend", SortOrder: 4},
            {Value: "Completed", DisplayName: "Abgeschlossen", SortOrder: 5},
            {Value: "Cancelled", DisplayName: "Storniert", SortOrder: 6},
            {Value: "Archived", DisplayName: "Archiviert", SortOrder: 7}
        )
    ),

    // Priorities (for dropdowns) - static table
    ClearCollect(
        CachedPriorities,
        Table(
            {Value: "Critical", DisplayName: "Kritisch", SortOrder: 1},
            {Value: "High", DisplayName: "Hoch", SortOrder: 2},
            {Value: "Medium", DisplayName: "Mittel", SortOrder: 3},
            {Value: "Low", DisplayName: "Niedrig", SortOrder: 4},
            {Value: "None", DisplayName: "Keine", SortOrder: 5}
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
                Status <> "Archived"
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
            Status in ["Active", "Pending", "In Progress"]
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
            'Due Date' < Today()
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
            Filter(Items, CanAccessRecord(Owner.Email), Status <> "Archived"),
            'Modified On', SortOrder.Descending
        ), 50
    )
);
Set(AppState, Patch(AppState, {IsLoading: false, LastRefresh: Now()}));
NotifySuccess("Daten aktualisiert");


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
NotifyInfo("Filter aktualisiert");


// --- RESET FILTERS ---
// Button_ResetFilters.OnSelect
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
NotifyInfo("Filter zurückgesetzt");


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
        ConfirmDialogTitle: "Löschen bestätigen",
        ConfirmDialogMessage: "Möchten Sie diesen Eintrag wirklich löschen?",
        ConfirmDialogAction: "delete"
    })),
    NotifyPermissionDenied("Einträge löschen")
);

// ConfirmDialog_Yes.OnSelect
If(
    UIState.ConfirmDialogAction = "delete",
    Remove(Items, UIState.SelectedItem);
    NotifyActionCompleted("Löschen", UIState.SelectedItem.Name);
    Set(UIState, Patch(UIState, {
        IsConfirmDialogOpen: false,
        SelectedItem: Blank()
    }))
);
*/


// ============================================================
// END OF APP.ONSTART
// ============================================================
