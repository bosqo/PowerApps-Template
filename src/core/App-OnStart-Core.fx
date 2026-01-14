// ============================================================
// CORE BOOTSTRAP: App.OnStart - State Initialization & Data Loading
// ============================================================
//
// USAGE:
// 1. Copy entire content to Power Apps Studio → App.OnStart
// 2. Ensure datasources are connected: Items, Tasks
// 3. Adjust ClearCollect filters if needed for your data model
// 4. Test app load time
//
// REQUIRED DATASOURCES:
// - Items (Dataverse or SharePoint List)
//   Columns: Owner (Lookup), Status (Choice), Created On (DateTime)
// - Tasks (Dataverse or SharePoint List)
//   Columns: Assigned To (Lookup), Status (Choice), Due Date (Date)
//
// ============================================================

// ============================================================
// SECTION 1: APPLICATION STATE (Mutable)
// Tracks loading, navigation, errors during app session
// ============================================================

Set(
    AppState,
    {
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
    }
);

// ============================================================
// SECTION 2: FILTER STATE (Mutable)
// User-modifiable filters - can be changed via UI controls
// ============================================================

Set(
    Filter,
    {
        // Scope Filters (initialized from UDFs)
        UserScope: GetUserScope(),

        // Status Filters
        ActiveOnly: true,
        IncludeArchived: false,
        StatusFilter: Blank(),

        // Search & Custom Filters
        SearchTerm: "",
        CategoryFilter: Blank(),
        PriorityFilter: Blank(),

        // Date Range Filters
        DateRangeStart: DateRange.ThisMonth,
        DateRangeEnd: DateRange.Today,

        // Pagination
        CurrentPage: 1,
        PageSize: AppConfig.ItemsPerPage
    }
);

// ============================================================
// SECTION 3: UI STATE (Mutable)
// UI-related state for dialogs, panels, selections
// ============================================================

Set(
    UI,
    {
        // Selection State
        SelectedItem: Blank(),
        SelectedItems: Table(),
        SelectionMode: "single",  // "single" | "multiple"

        // Panel States
        IsDetailsPanelOpen: false,
        IsFilterPanelOpen: false,
        IsSettingsPanelOpen: false,
        IsErrorDialogOpen: false,

        // Dialog/Modal State
        DialogTitle: "",
        DialogMessage: "",
        DialogType: "info",  // "info" | "success" | "warning" | "error"

        // Form Mode
        FormMode: "view"  // "view" | "edit" | "create"
    }
);

// ============================================================
// SECTION 4: DATA LOADING (Concurrent)
// Load collections in parallel for better performance
// ============================================================

Concurrent(
    // Load Items collection
    ClearCollect(
        Items,
        Filter(
            'Items Data Source',
            // Filter by user scope (Admin sees all, others see own)
            If(
                IsBlank(Filter.UserScope),
                true,
                Owner.Email = Filter.UserScope
            ),
            // Filter by active status if configured
            If(
                Filter.ActiveOnly,
                Status <> "Archiviert",
                true
            ),
            // Filter by date range (last 90 days)
            'Modified On' >= DateRange.Last90Days
        )
    ),

    // Load Tasks collection
    ClearCollect(
        Tasks,
        Filter(
            'Tasks Data Source',
            // Filter by assigned user or all if manager/admin
            If(
                IsBlank(Filter.UserScope),
                true,
                'Assigned To'.Email = Filter.UserScope
            ),
            // Filter by active status
            If(
                Filter.ActiveOnly,
                Status <> "Abgeschlossen",
                true
            ),
            // Filter by due date (not overdue)
            'Due Date' >= DateRange.Today
        )
    )
);

// ============================================================
// SECTION 5: POST-LOAD INITIALIZATION
// Run after data loading completes
// ============================================================

// Update loading state
Set(
    AppState,
    Patch(
        AppState,
        {
            IsInitializing: false,
            IsLoading: false,
            LastRefresh: Now()
        }
    )
);

// Verify required collections exist (error handling)
If(
    IsBlank(Items),
    Set(
        AppState,
        Patch(
            AppState,
            {
                LastError: "Datenladung fehlgeschlagen",
                ErrorMessage: "Items-Sammlung konnte nicht geladen werden",
                ShowErrorDialog: true
            }
        )
    )
);

If(
    IsBlank(Tasks),
    Set(
        AppState,
        Patch(
            AppState,
            {
                LastError: "Datenladung fehlgeschlagen",
                ErrorMessage: "Tasks-Sammlung konnte nicht geladen werden",
                ShowErrorDialog: true
            }
        )
    )
);

// ============================================================
// CORE BOOTSTRAP COMPLETE
// ============================================================
//
// At this point:
// ✅ App.Formulas has been loaded (Named Formulas + UDFs)
// ✅ User roles determined from EntraID
// ✅ User permissions computed
// ✅ AppState initialized
// ✅ Filter state ready
// ✅ UI state ready
// ✅ Data collections loaded
//
// Your app is ready to use!
// You can now:
// - Reference Filter.UserScope in Gallery.Items
// - Use HasPermission() in control visibility
// - Use GetCETToday() in date comparisons
// - Add optional modules as needed
//
// See MIGRATION-GUIDE.md for next steps
//
// ============================================================
