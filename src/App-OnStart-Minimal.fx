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
// 1. Departments (Dataverse/SharePoint) - columns: Name, Status (accessed via Named Formulas)
// 2. Categories (Dataverse/SharePoint) - columns: Name, Status (accessed via Named Formulas)
// 3. Items (Dataverse/SharePoint) - columns: Owner, Status, 'Modified On' (accessed via Named Formulas)
// 4. Tasks (Dataverse/SharePoint) - columns: 'Assigned To', Status, 'Due Date' (accessed via Named Formulas)
//
// NOTE: No data is cached in App.OnStart. All data is loaded on-demand via Named Formulas.
//
// ============================================================


// ============================================================
// TIMING MARKER: App.OnStart Start
// ============================================================
// Monitor tool measurement begins here
// Expected total duration: <2000ms (2 seconds)
// See "Monitor Tool Usage Guide" below for measurement instructions


// ============================================================
// NAMING CONVENTIONS FOR STATE VARIABLES
// ============================================================
//
// STATE VARIABLES (Set): PascalCase
// - AppState: Application-wide state (loading, navigation, errors)
// - ActiveFilters: User-modifiable filter state
// - UIState: UI component state (panels, dialogs, selections)
//
// COLLECTIONS: NO CACHED COLLECTIONS IN APP.ONSTART
// - All data accessed on-demand via Named Formulas in App.Formulas
// - No Cached* collections (removed for simplicity)
// - No My* collections (accessed directly via Named Formulas)
//
// All variable names must be PascalCase (no underscores, no prefixes)
//
// ============================================================


// ============================================================
// VARIABLE STRUCTURE PHILOSOPHY
// ============================================================
//
// This template uses THREE STATE VARIABLES (not dozens):
//
// 1. AppState - Application-wide state (loading, navigation, errors)
//    WHY: Centralized app-level concerns, easier to debug
//
// 2. ActiveFilters - User-modifiable filter state
//    WHY: All filter state in one place, easy to reset/share
//
// 3. UIState - UI component state (panels, dialogs, selections)
//    WHY: UI concerns separate from data/business logic
//
// ANTI-PATTERN TO AVOID:
// - Don't create variables like varIsLoading, varCurrentScreen, varSearchTerm
// - Don't scatter related state across multiple variables
// - Don't mix UI state with business logic state
//
// BENEFITS OF THIS STRUCTURE:
// - Single source of truth for each concern
// - Easy to reset state: Set(UIState, Patch(UIState, {SelectedItem: Blank()}))
// - Intellisense shows all available fields: UIState. → autocomplete
// - Debugging shows complete state: AppState record in Monitor
//
// ============================================================


// ============================================================
// 1. APPLICATION STATE (Mutable)
// ============================================================
// Purpose: Global application state that changes during usage
// Centralized app-level concerns (loading, navigation, connectivity, errors)
//
// Schema:
// - IsLoading: Boolean - General loading indicator (data refresh, operations)
// - IsInitializing: Boolean - App startup loading (first load only, set to false after OnStart)
// - IsSaving: Boolean - Save operation in progress (Submit, Patch, Remove operations)
// - CurrentScreen: Text - Active screen name for navigation tracking and analytics
// - PreviousScreen: Text - Previous screen for back navigation (Blank if no history)
// - SessionStart: DateTime - App session start time (set once at OnStart, used for analytics)
// - LastRefresh: DateTime - Last data refresh timestamp (updated after ClearCollect, Refresh)
// - LastAction: Text - Last user action performed (for debugging, optional tracking)
// - IsOnline: Boolean - Network connectivity status cached at startup (read Connection.Connected fresh for critical operations)
// - ShowErrorDialog: Boolean - Error dialog visibility state
// - ErrorMessage: Text - User-facing error message (localized, friendly)
// - ErrorDetails: Text - Technical error details for debugging (stack trace, error codes)
// - CurrentPage: Number - Current page number for pagination (1-based index, starts at 1)
// - TotalPages: Number - Total pages calculated from filtered record count (calculated dynamically)
// - PageSize: Number - Records per page for pagination (set to 50 for optimal performance)
// - LastFilterChangeTime: DateTime - Timestamp of last filter change (used to detect filter changes and reset page)
//
// Usage:
// - Update: Set(AppState, Patch(AppState, {IsLoading: true}))
// - Read: AppState.IsLoading, AppState.CurrentScreen
// - Navigation: Set(AppState, Patch(AppState, {PreviousScreen: AppState.CurrentScreen, CurrentScreen: "Details"}))
// - Error: Set(AppState, Patch(AppState, {ShowErrorDialog: true, ErrorMessage: "Failed to save", ErrorDetails: ErrorResponse}))
// - Pagination: Set(AppState, Patch(AppState, {CurrentPage: 2}))
//
// TIMING: Section 1 - AppState initialization
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

    // Authentication & Authorization
    // ActiveRole is a Named Formula (auto-reactive, no need to store in AppState)
    // UserPermissions is a Named Formula (derived from ActiveRole, auto-reactive)
    // CachedActiveRole variable is set in critical path below

    // Pagination (for galleries with >2000 record datasets)
    CurrentPage: 1,           // Current page number (1-based)
    TotalPages: 0,            // Total pages calculated from filtered record count
    PageSize: 50,             // Records per page (PERF-05 recommendation)
    LastFilterChangeTime: Now(), // Timestamp of last filter change (to reset page on filter change)

    // Error Handling
    ShowErrorDialog: false,
    ErrorMessage: "",
    ErrorDetails: ""
});


// TIMING: Section 2 - ActiveFilters initialization

// ============================================================
// 2. ACTIVE FILTERS (Mutable)
// ============================================================
// Purpose: User-modifiable filter state for data views (galleries, lists)
// Initialized from UDFs and AppConfig, modified via UI controls
//
// Schema:
// - UserScope: Text - User data scope from GetUserScope() (Blank = all, or user email)
// - IncludeArchived: Boolean - Include archived records in views (false = active only, true = include archived)
// - StatusFilter: Text - Selected status value (Blank = all statuses, specific value = filter by that status)
// - DateRangeFilter: Text - Date range preset ("All", "Today", "ThisWeek", "ThisMonth", "Custom")
// - CustomDateStart: Date - Custom date range start (only used if DateRangeFilter = "Custom")
// - CustomDateEnd: Date - Custom date range end (only used if DateRangeFilter = "Custom")
// - SearchTerm: Text - Text search query across searchable fields (empty = no search filter)
// - CategoryFilter: Text - Selected category (Blank = all categories)
// - PriorityFilter: Text - Selected priority (Blank = all priorities)
// - OwnerFilter: Text - Filter by owner email (Blank = all owners)
// - ShowMyItemsOnly: Boolean - Filter to show only current user's items (used by CanViewRecord)
// - SelectedStatus: Text - Selected status filter value (empty string = all statuses)
//
// Usage:
// - Update single filter: Set(ActiveFilters, Patch(ActiveFilters, {SearchTerm: "query"}))
// - Reset all filters: Set(ActiveFilters, Patch(ActiveFilters, {SearchTerm: "", SelectedStatus: "", ShowMyItemsOnly: false}))
// - Gallery Items: Use inline Filter pattern (FILT-05) from App-Formulas-Template.fx
// - Date range: Filter(DataSource,
//     Switch(ActiveFilters.DateRangeFilter,
//         "Today", DateValue(Created) = Today(),
//         "ThisWeek", DateValue(Created) >= DateRanges.StartOfWeek && DateValue(Created) <= DateRanges.EndOfWeek,
//         "Custom", DateValue(Created) >= ActiveFilters.CustomDateStart && DateValue(Created) <= ActiveFilters.CustomDateEnd,
//         true  // "All" or default
//     )
// )
//
Set(ActiveFilters, {
    // Scope Filters (initialized from UDFs)
    UserScope: GetUserScope(),

    // Status Filters
    IncludeArchived: false,  // false = show active only, true = include archived
    StatusFilter: Blank(),

    // Date Range Filters
    DateRangeFilter: "All",  // "All" | "Today" | "ThisWeek" | "ThisMonth" | "Custom"
    CustomDateStart: Blank(),
    CustomDateEnd: Blank(),

    // Search & Custom Filters
    SearchTerm: "",
    CategoryFilter: Blank(),
    PriorityFilter: Blank(),
    OwnerFilter: Blank(),
    ShowMyItemsOnly: false,   // Filter to show only current user's items
    SelectedStatus: "",       // Selected status filter value

    // === NEW FIELDS ===
    Status: Blank(),          // Selected status (or Blank() for "All")
    Department: Blank(),      // Selected department (or Blank() for "All")
    DateRange: Blank()        // Selected date range key (or Blank() for "All")
});


// TIMING: Section 3 - UIState initialization

// ============================================================
// 3. UI STATE (Mutable)
// ============================================================
// Purpose: UI component state (selections, panels, dialogs, forms)
// Ephemeral state that doesn't persist between sessions
//
// Schema:
// - SelectedItem: Record - Currently selected single item (Blank if no selection)
// - SelectedItems: Table - Selected items in multi-select mode (empty table if no selection)
// - SelectionMode: Text - Selection behavior ("single" = one item, "multiple" = multiple items)
// - IsDetailsPanelOpen: Boolean - Details panel visibility (right-side panel showing item details)
// - IsFilterPanelOpen: Boolean - Filter panel visibility (left-side or top filter controls)
// - IsSettingsPanelOpen: Boolean - Settings panel visibility (app configuration, user preferences)
// - IsConfirmDialogOpen: Boolean - Confirmation dialog visibility (for destructive actions)
// - ConfirmDialogTitle: Text - Dialog title text (e.g., "Delete Confirmation")
// - ConfirmDialogMessage: Text - Dialog message text (e.g., "Are you sure you want to delete this item?")
// - ConfirmDialogAction: Text - Action to execute on confirm (e.g., "delete", "approve", "archive")
// - FormMode: FormMode - Form display mode (FormMode.View = read-only, FormMode.Edit = editing, FormMode.New = creating)
// - UnsavedChanges: Boolean - Form has unsaved modifications (used to show discard changes warning)
//
// Usage:
// - Update selection: Set(UIState, Patch(UIState, {SelectedItem: Gallery.Selected}))
// - Panel visibility: Panel.Visible = UIState.IsDetailsPanelOpen
// - Open panel: Set(UIState, Patch(UIState, {IsDetailsPanelOpen: true}))
// - Form mode: Form.Mode = UIState.FormMode
// - Check edit mode: UIState.FormMode = FormMode.Edit (instead of using IsEditMode field)
// - Confirmation dialog: Set(UIState, Patch(UIState, {
//     IsConfirmDialogOpen: true,
//     ConfirmDialogTitle: "Delete Item",
//     ConfirmDialogMessage: "Are you sure?",
//     ConfirmDialogAction: "delete"
// }))
//
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
    FormMode: FormMode.View,
    UnsavedChanges: false
});


// NO CACHING - Data loaded on-demand via Named Formulas
// All dropdown data (Departments, Categories, Statuses, Priorities)
// is accessed directly from data sources via Named Formulas in App.Formulas
// User-scoped data (Recent Items, Pending Tasks) also accessed via Named Formulas


// TIMING: Section 6 - Finalize (IsInitializing = false)

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


// TIMING: Section 7 - Notification Stack (NEW in Phase 4) BEGIN

// ============================================================
// 7. NOTIFICATION STACK (NEW in Phase 4)
// ============================================================
// Purpose: Initialize toast notification state for custom notification UI
// Timing: 100-200ms (background loading, doesn't block critical path)
// Architecture: Toast notifications are managed via NotificationStack collection
// - Developers call NotifySuccess/NotifyError/etc. UDFs
// - These UDFs call AddToast internally to update NotificationStack
// - UI layer (04-02) renders toasts from this collection
// - Auto-dismiss timers (UI layer) call RemoveToast to cleanup old toasts
//
// Schema: { ID, Message, Type, AutoClose, Duration, CreatedAt, IsVisible }
// - ID: Unique identifier for each toast (incremented by NotificationCounter)
// - Message: Text message to display
// - Type: "Success", "Error", "Warning", or "Info"
// - AutoClose: Boolean - whether toast auto-dismisses (errors: false, others: true)
// - Duration: Timeout in ms (errors: 0/never, others: 5000/5 seconds)
// - CreatedAt: Timestamp when toast was added (for auto-dismiss calculation)
// - IsVisible: Boolean - visibility state (true = show, false = hide during fade-out)
//
// Initialize NotificationStack collection (empty at startup)
// Will be populated as users trigger actions (save, delete, etc.)
ClearCollect(NotificationStack, Table());

// Consolidated toast state (replaces 4 separate global variables)
// Benefits: Better organization, easier to reset, single source of truth
Set(ToastState, {
    Counter: 0,              // Unique ID generator (incremented in AddToast UDF)
    ToRemove: Blank(),       // Current toast ID being dismissed (for auto-dismiss tracking)
    AnimationStart: Blank(), // Animation start timestamp (for entrance fade-in)
    Reverting: Blank()       // Current toast ID being reverted (prevents concurrent reverts)
});

// Cleanup timer state: Track last cleanup run (for debugging)
// Used by tim_ToastCleanup control (Pattern 11.8) to prevent memory leaks
Set(ToastCleanupLastRun, Now());

// NEW (Phase 4 - Revert System): Optional collection for revert callback registry
// Maps callback ID to handler name (informational, not required for functionality)
ClearCollect(
    RevertCallbackRegistry,
    Table(
        {ID: 0, Name: "DELETE_UNDO", Description: "Restore deleted item"},
        {ID: 1, Name: "ARCHIVE_UNDO", Description: "Unarchive item"},
        {ID: 2, Name: "CUSTOM", Description: "Custom revert action"}
    )
);

// NOTE: Periodic cleanup now handled by tim_ToastCleanup control (see Control-Patterns Pattern 11.8)
// The timer runs every 60 seconds and removes toasts older than 2 minutes
// This provides a safety net against memory leaks if auto-dismiss fails

// TIMING: Section 7 - Notification Stack END


// TIMING MARKER: App.OnStart Complete

// ============================================================
// PERFORMANCE TARGET DOCUMENTATION
// ============================================================
// Expected timing breakdown (NO CACHING):
// - Sections 1-3 (State initialization): ~50-150ms
// - Section 6 (Finalize): ~50ms
// - Section 7 (Notification stack): ~100ms
// Total: ~200-300ms (well under 2000ms target)
//
// Note: All data (departments, categories, role checks) loaded on-demand via Named Formulas
// Note: UserProfile uses built-in User() function (instant, no API calls)
// Note: Role determination moved to Named Formulas (ActiveRole, UserRoles, UserPermissions)

// ============================================================
// MONITOR TOOL USAGE GUIDE
// ============================================================
// TO MEASURE PERFORMANCE:
//
// 1. Open Power Apps Studio
// 2. Settings > Upcoming features > Monitor tool (enable if not already on)
// 3. Reload app (Ctrl+Shift+F5) to trigger App.OnStart
// 4. Open Monitor tool (F12 or Settings > Monitor)
// 5. Filter Network tab: search for "OnStart"
// 6. Look for total duration (should be ~200-300ms without caching)
// 7. Click on OnStart timeline to see breakdown by section
//
// EXPECTED OUTPUT (NO CACHING):
// - OnStart total time: ~200-300ms (much faster without caching)
// - State initialization (Sections 1-3): ~50-150ms
// - Finalization (Section 6): ~50ms
// - Notification stack (Section 7): ~100ms
//
// ROLE DETERMINATION:
// - Moved to Named Formulas (ActiveRole in App.Formulas)
// - Evaluated on-demand when needed (no API calls during OnStart)
// - No caching means always fresh data

// ============================================================
// ERROR HANDLING RESULTS
// ============================================================
// UserProfile (simplified):
// [✓] Uses built-in User() function (no API calls, no error handling needed)
// [✓] User().Email and User().FullName always available
//
// Role Determination:
// [✓] Moved to Named Formulas (ActiveRole in App.Formulas)
// [✓] Evaluated on-demand when needed
// [✓] No caching means simpler error handling
//
// No Cached Collections:
// [✓] All data loaded on-demand via Named Formulas
// [✓] Departments, Categories accessed directly from data sources
// [✓] No retry logic needed (data queried fresh each time)
// [✓] Simpler code, easier to maintain
//
// Error Messages (German Localization):
// [✓] All messages in German (no English)
// [✓] No error codes shown (no "-2147024809" or "HTTP 401")
// [✓] All messages include remediation hints ("check network", "try later")

// ============================================================
// VALIDATION CHECKLIST
// ============================================================
// Run Monitor tool and verify:
// [ ] UserProfile: Uses built-in User() function (no API calls)
// [ ] ActiveRole Named Formula evaluates correctly ("Admin", "Teamleitung", or "User")
// [ ] UserPermissions derived correctly from ActiveRole
// [ ] App.OnStart total time <2000ms (should be ~200-300ms without caching)
// [ ] IsInitializing: true during startup, false after finalization
// [ ] All data loaded on-demand via Named Formulas (no cached collections)

// ============================================================
// ERROR HANDLING REFERENCE
// ============================================================
// This App.OnStart implements error handling patterns that Phase 3+ features can follow.
// For complete error handling design and patterns, see:
// - App-Formulas-Template.fx: SECTION 4 (Error Message Localization)
// - App-Formulas-Template.fx: SECTION 5 (Error Handling Patterns for Phases 3+)
//
// NO CACHING APPROACH:
// - UserProfile: Uses built-in User() function (no API calls, always works)
// - ActiveRole: Named Formula checks Entra ID groups on-demand (no caching)
// - Departments, Categories: Loaded directly from data sources via Named Formulas
// - Result: Simpler code, no cache invalidation concerns, data always fresh
//
// USER ACTION ERROR PATTERN (use in Phase 3+ features):
// When user performs action that fails (save, delete, approve)
// Example for delete button in Phase 3:
//   IfError(
//     Remove(Items, Gallery.Selected),
//     Set(AppState, Patch(AppState, {
//       ShowErrorDialog: true,
//       ErrorMessage: ErrorMessage_DataRefreshFailed("delete")
//     }))
//   );
//
// USER ACTION ERROR PATTERN (use in Phase 4+ features):
// When user submits form that fails
// Example for form save in Phase 4:
//   IfError(
//     SubmitForm(EditForm),
//     Set(AppState, Patch(AppState, {
//       ShowErrorDialog: true,
//       ErrorMessage: ErrorMessage_DataRefreshFailed("save")
//     }))
//   );
//
// VALIDATION ERROR PATTERN (use in Phase 4 features):
// When user input fails validation
// Example for email field validation:
//   If(
//     !IsValidEmail(txt_Email.Value),
//     NotifyValidationError("Email", "Ungültiges E-Mail-Format")
//   );
//


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
    IncludeArchived: false,
    StatusFilter: Blank(),
    DateRangeFilter: "All",
    CustomDateStart: Blank(),
    CustomDateEnd: Blank(),
    SearchTerm: "",
    CategoryFilter: Blank(),
    PriorityFilter: Blank(),
    OwnerFilter: Blank(),
    ShowMyItemsOnly: false,
    SelectedStatus: ""
});
// Reset pagination when filters are cleared
Set(AppState, Patch(AppState, {CurrentPage: 1}));
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
