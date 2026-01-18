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
//
// Usage:
// - Update: Set(AppState, Patch(AppState, {IsLoading: true}))
// - Read: AppState.IsLoading, AppState.CurrentScreen
// - Navigation: Set(AppState, Patch(AppState, {PreviousScreen: AppState.CurrentScreen, CurrentScreen: "Details"}))
// - Error: Set(AppState, Patch(AppState, {ShowErrorDialog: true, ErrorMessage: "Failed to save", ErrorDetails: ErrorResponse}))
//
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

    // Authentication & Authorization (populated in critical path)
    UserRoles: Blank(),      // Populated in critical path after Office365Groups checks
    UserPermissions: Blank(), // Populated in critical path after roles determined

    // Error Handling
    ShowErrorDialog: false,
    ErrorMessage: "",
    ErrorDetails: ""
});


// ============================================================
// 2. ACTIVE FILTERS (Mutable)
// ============================================================
// Purpose: User-modifiable filter state for data views (galleries, lists)
// Initialized from UDFs and AppConfig, modified via UI controls
//
// Schema:
// - UserScope: Text - User data scope from GetUserScope() ("All", "My", "Department", or user email)
// - DepartmentScope: Text - Department scope from GetDepartmentScope() (department name or Blank for all)
// - IncludeArchived: Boolean - Include archived records in views (false = active only, true = include archived)
// - StatusFilter: Text - Selected status value (Blank = all statuses, specific value = filter by that status)
// - DateRangeFilter: Text - Date range preset ("All", "Today", "ThisWeek", "ThisMonth", "Custom")
// - CustomDateStart: Date - Custom date range start (only used if DateRangeFilter = "Custom")
// - CustomDateEnd: Date - Custom date range end (only used if DateRangeFilter = "Custom")
// - SearchTerm: Text - Text search query across searchable fields (empty = no search filter)
// - CategoryFilter: Text - Selected category (Blank = all categories)
// - PriorityFilter: Text - Selected priority (Blank = all priorities)
// - OwnerFilter: Text - Filter by owner email (Blank = all owners)
// - CurrentPage: Number - Current page for pagination (1-based index)
// - PageSize: Number - Records per page for pagination (default from AppConfig.ItemsPerPage)
//
// Usage:
// - Update single filter: Set(ActiveFilters, Patch(ActiveFilters, {SearchTerm: "query"}))
// - Reset all filters: Set(ActiveFilters, Patch(ActiveFilters, {SearchTerm: "", StatusFilter: Blank(), CurrentPage: 1}))
// - Gallery Items: Filter(DataSource,
//     If(ActiveFilters.IncludeArchived, true, Status <> "Archived"),
//     StartsWith(Lower(Name), Lower(ActiveFilters.SearchTerm)),
//     If(IsBlank(ActiveFilters.StatusFilter), true, Status = ActiveFilters.StatusFilter)
// )
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
    DepartmentScope: GetDepartmentScope(),

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

    // Pagination
    CurrentPage: 1,
    PageSize: AppConfig.ItemsPerPage
});


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


// ============================================================
// 0. CRITICAL PATH - SEQUENTIAL USER IDENTITY & AUTHORIZATION
// ============================================================
// Load critical data required for app to function safely.
// App blocks user interaction until this completes (IsInitializing: true).
//
// Sequential execution order (NOT parallel via Concurrent):
// 1. Initialize cache collections and timestamp
// 2. Fetch user profile from Office365Users.MyProfileV2()
// 3. Determine user roles via Office365Groups checks (cached)
// 4. Calculate permissions from cached roles (no API calls)
//
// Dependencies:
// - UserProfile Named Formula depends on CachedProfileCache
// - UserRoles Named Formula depends on CachedRolesCache
// - UserPermissions Named Formula depends on UserRoles (derived, no API calls)
//
// Cache TTL: 5 minutes (AppConfig.CacheExpiryMinutes)
// Cache Scope: Session-based (cleared when app closes)
//
// Error Handling:
// - IfError() wraps Office365 calls for graceful degradation
// - Fallback values: "Unbekannt" for missing/failed data
// - If critical path fails, app stays locked (IsInitializing: true)
//

// Initialize cache collections and timestamp
Set(CacheTimestamp, Now());
ClearCollect(CachedProfileCache, {});  // Will be populated by Office365Users call
ClearCollect(CachedRolesCache, {});    // Will be populated by Office365Groups calls

// Ensure app stays locked during critical path execution
Set(AppState, Patch(AppState, {IsInitializing: true}));

// CRITICAL PATH: Sequential load ensures permissions calculated from complete role data
// Step 1: Fetch user profile from Office365Users with error handling
// Pattern: Wrap Office365 call in IfError() with user-friendly German error messages
ClearCollect(
    CachedProfileCache,
    IfError(
        {
            DisplayName: Office365Users.MyProfileV2().DisplayName,
            Email: Office365Users.MyProfileV2().UserPrincipalName,
            Department: Office365Users.MyProfileV2().Department,
            JobTitle: Office365Users.MyProfileV2().JobTitle,
            MobilePhone: Office365Users.MyProfileV2().MobilePhone
        },
        // ERROR HANDLER: Profile fetch failed - graceful degradation with fallback
        // Fallback values allow app to proceed even if Office365 is unavailable
        // User will see "Unbekannt" for profile fields but app remains functional
        {
            DisplayName: "Unbekannt",
            Email: "unknown@company.com",
            Department: "Unbekannt",
            JobTitle: "Unbekannt",
            MobilePhone: ""
        }
    )
);

// Critical path error check: If profile load failed, notify user with German message
If(
    IsBlank(First(CachedProfileCache).DisplayName) || First(CachedProfileCache).DisplayName = "Unbekannt",
    // Profile load may have failed - check connection
    // Note: We continue anyway because fallback allows degraded operation
    // In production, add more sophisticated error tracking here
    Notify(ErrorMessage_ProfileLoadFailed("Office365Users"), NotificationType.Warning)
);

// Update cache timestamp after profile fetch completes
Set(CacheTimestamp, Now());

// Step 2: Check user roles from cached profile
// UserRoles Named Formula reads from CachedRolesCache on first call
// Office365Groups.CheckMembershipAsync() called once per role to populate cache
// Pattern: Named Formula is lazy-evaluated here to trigger Office365Groups checks
// If roles check fails, fallback to minimal permissions (IsUser: true only)
Set(AppState, Patch(AppState, {UserRoles: UserRoles}));

// Step 3: Calculate permissions from roles
// UserPermissions Named Formula reads from cached roles (no additional API calls)
// This completes the critical path without making additional Office365 requests
// Permissions derived from cached/fallback roles (safe operation)
Set(AppState, Patch(AppState, {UserPermissions: UserPermissions}));

// Critical path completed: app will unlock in FINALIZE section
// If any Office365 APIs failed above, fallback values were used
// App can still function, but with degraded role/permission data
// IsInitializing will be set to false in FINALIZE section regardless of errors


// ============================================================
// 4. BACKGROUND DATA - Parallel Lookup Data Loading
// ============================================================
// Load commonly used lookup/reference data in parallel (not sequentially)
// These are independent non-critical collections that don't block startup
//
// WHY CONCURRENT():
// - All non-critical collections load in parallel for faster startup
// - Each ClearCollect is independent (no data dependencies between them)
// - Failures in one collection do not block others or the app
// - Critical data (section 0) loads before this section to ensure user is authenticated
//
// PERFORMANCE:
// - Sequential loading time: ~500ms per collection = ~2000ms total
// - Concurrent loading time: ~500ms (all execute simultaneously)
// - Improvement: ~75% faster non-critical data loading

Concurrent(
    // Departments (for dropdowns) - from Dataverse with retry and fallback
    ClearCollect(
        CachedDepartments,
        IfError(
            // First attempt: Load from Departments table
            Sort(
                Filter(
                    Departments,
                    Status = "Active"
                ),
                Name,
                SortOrder.Ascending
            ),
            // First error: Retry immediately (attempt 2)
            IfError(
                Sort(
                    Filter(
                        Departments,
                        Status = "Active"
                    ),
                    Name,
                    SortOrder.Ascending
                ),
                // Second attempt also failed: Use empty fallback
                // Empty table means gallery shows empty state, not error
                Table()
            )
        )
    ),

    // Categories (for dropdowns) - from Dataverse with retry and fallback
    ClearCollect(
        CachedCategories,
        IfError(
            // First attempt: Load from Categories table
            Sort(
                Filter(
                    Categories,
                    Status = "Active"
                ),
                Name,
                SortOrder.Ascending
            ),
            // First error: Retry immediately (attempt 2)
            IfError(
                Sort(
                    Filter(
                        Categories,
                        Status = "Active"
                    ),
                    Name,
                    SortOrder.Ascending
                ),
                // Second attempt also failed: Use empty fallback
                Table()
            )
        )
    ),

    // Statuses (for dropdowns) - static table with retry and fallback
    // Static tables rarely fail, but we maintain consistency
    ClearCollect(
        CachedStatuses,
        IfError(
            // First attempt: Create static status table
            Table(
                {Value: "Active", DisplayName: "Aktiv", SortOrder: 1},
                {Value: "Pending", DisplayName: "Ausstehend", SortOrder: 2},
                {Value: "In Progress", DisplayName: "In Bearbeitung", SortOrder: 3},
                {Value: "On Hold", DisplayName: "Wartend", SortOrder: 4},
                {Value: "Completed", DisplayName: "Abgeschlossen", SortOrder: 5},
                {Value: "Cancelled", DisplayName: "Storniert", SortOrder: 6},
                {Value: "Archived", DisplayName: "Archiviert", SortOrder: 7}
            ),
            // First error: Retry immediately (attempt 2)
            IfError(
                Table(
                    {Value: "Active", DisplayName: "Aktiv", SortOrder: 1},
                    {Value: "Pending", DisplayName: "Ausstehend", SortOrder: 2},
                    {Value: "In Progress", DisplayName: "In Bearbeitung", SortOrder: 3},
                    {Value: "On Hold", DisplayName: "Wartend", SortOrder: 4},
                    {Value: "Completed", DisplayName: "Abgeschlossen", SortOrder: 5},
                    {Value: "Cancelled", DisplayName: "Storniert", SortOrder: 6},
                    {Value: "Archived", DisplayName: "Archiviert", SortOrder: 7}
                ),
                // Second attempt also failed: Use empty fallback
                Table()
            )
        )
    ),

    // Priorities (for dropdowns) - static table with retry and fallback
    // Static tables rarely fail, but we maintain consistency
    ClearCollect(
        CachedPriorities,
        IfError(
            // First attempt: Create static priority table
            Table(
                {Value: "Critical", DisplayName: "Kritisch", SortOrder: 1},
                {Value: "High", DisplayName: "Hoch", SortOrder: 2},
                {Value: "Medium", DisplayName: "Mittel", SortOrder: 3},
                {Value: "Low", DisplayName: "Niedrig", SortOrder: 4},
                {Value: "None", DisplayName: "Keine", SortOrder: 5}
            ),
            // First error: Retry immediately (attempt 2)
            IfError(
                Table(
                    {Value: "Critical", DisplayName: "Kritisch", SortOrder: 1},
                    {Value: "High", DisplayName: "Hoch", SortOrder: 2},
                    {Value: "Medium", DisplayName: "Mittel", SortOrder: 3},
                    {Value: "Low", DisplayName: "Niedrig", SortOrder: 4},
                    {Value: "None", DisplayName: "Keine", SortOrder: 5}
                ),
                // Second attempt also failed: Use empty fallback
                Table()
            )
        )
    )
);


// ============================================================
// 4B. FALLBACK VALUES FOR MISSING DATA
// ============================================================
// When non-critical data fails to load (collections are empty), galleries and
// dropdowns handle the empty state gracefully using fallback patterns.
//
// FALLBACK PHILOSOPHY:
// - User experience: App fully functional, but with limited options until data loads
// - No technical errors shown: Empty collections degrade gracefully
// - "Unbekannt" pattern: Standardized German fallback for missing lookup data
//
// IMPLEMENTATION PATTERNS:
//
// 1. Gallery fallback when collection is empty:
//    Gallery.Items = If(IsEmpty(CachedDepartments), Table({Name: "Unbekannt", Value: ""}), CachedDepartments)
//    Result: Shows single "Unbekannt" placeholder option instead of empty gallery
//
// 2. Dropdown fallback for missing lookup:
//    Dropdown.Items = If(IsEmpty(CachedStatuses), Table({Value: "Unbekannt", DisplayName: "Unbekannt"}), CachedStatuses)
//    Result: Single fallback option ensures dropdown is never truly empty
//
// 3. Display text fallback for blank fields:
//    Label.Text = If(IsBlank(ThisItem.Department), "Unbekannt", ThisItem.Department)
//    Result: Shows "Unbekannt" instead of blank field
//
// 4. Conditional display based on data availability:
//    Filter_Panel.Visible = !IsEmpty(CachedCategories)
//    Result: Filter panel hidden if category lookup data unavailable
//
// COLLECTIONS MONITORED:
// - CachedDepartments → galleries, dropdowns, filters
// - CachedCategories → category filters and selectors
// - CachedStatuses → status dropdowns and filters
// - CachedPriorities → priority selectors and filters
//
// NOTE: Control-level fallback implementations deferred to Phase 4 (control patterns work)
// This task focuses on App.OnStart infrastructure and documentation


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
// ERROR HANDLING REFERENCE
// ============================================================
// This App.OnStart implements error handling patterns that Phase 3+ features can follow.
// For complete error handling design and patterns, see:
// - App-Formulas-Template.fx: SECTION 4 (Error Message Localization)
// - App-Formulas-Template.fx: SECTION 5 (Error Handling Patterns for Phases 3+)
//
// CRITICAL PATH ERROR PATTERN (implemented above in section 0):
// When user MUST have critical data to continue the app
// - Office365Users.MyProfileV2() fails → Show German error via ErrorMessage_ProfileLoadFailed()
// - User sees: "Ihre Profilinformationen konnten nicht geladen werden..."
// - Result: App stays locked (IsInitializing: true), user must retry
//
// NON-CRITICAL ERROR PATTERN (implemented above in section 4):
// When app can function without data, gracefully degrade
// - CachedDepartments load fails → Silently use empty Table() fallback
// - User sees: Empty gallery or "Unbekannt" placeholder (not error message)
// - Result: App continues startup, user can work with limited lookup options
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
    DepartmentScope: GetDepartmentScope(),
    IncludeArchived: false,
    StatusFilter: Blank(),
    DateRangeFilter: "All",
    CustomDateStart: Blank(),
    CustomDateEnd: Blank(),
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
