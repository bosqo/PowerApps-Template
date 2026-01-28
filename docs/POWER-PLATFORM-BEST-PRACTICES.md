# Power Platform Best Practices

Comprehensive guide for building efficient, scalable Canvas Apps with SharePoint as data source.

---

## Table of Contents

1. [Declarative vs Imperative Programming](#1-declarative-vs-imperative-programming)
2. [Understanding Delegation](#2-understanding-delegation)
3. [Data Loading Strategies](#3-data-loading-strategies)
4. [ClearCollect vs Direct Data Source](#4-clearcollect-vs-direct-data-source)
5. [Search & Filter Patterns](#5-search--filter-patterns)
6. [Pagination Patterns](#6-pagination-patterns)
7. [Performance Optimization](#7-performance-optimization)
8. [SharePoint-Specific Patterns](#8-sharepoint-specific-patterns)

---

## 1. Declarative vs Imperative Programming

### The Core Difference

| Aspect | Declarative | Imperative |
|--------|-------------|------------|
| **What** | Describes WHAT the result should be | Describes HOW to achieve the result |
| **Where** | `App.Formulas`, Control properties | `App.OnStart`, `OnSelect`, `OnVisible` |
| **Evaluation** | Lazy (on-demand, reactive) | Eager (runs immediately when triggered) |
| **State** | Computed values, no side effects | Mutable state, side effects |

### Why This Matters

**Problem:** Legacy apps use `Set()` everywhere, causing:
- Slow startup (all variables calculated at once)
- Stale data (manual refresh needed)
- Complex dependency tracking (what updates what?)
- Difficult debugging (state scattered across events)

**Solution:** Declarative-first architecture

```powerfx
// ❌ IMPERATIVE (Legacy) - App.OnStart
Set(varUserName, Office365Users.MyProfileV2().displayName);
Set(varIsAdmin, "Admin" in User().Email);
Set(varFilteredItems, Filter(Items, Owner = varUserName));

// ✓ DECLARATIVE (Modern) - App.Formulas
UserProfile = Office365Users.MyProfileV2();
UserName = UserProfile.displayName;
IsAdmin = "Admin" in User().Email;
FilteredItems = Filter(Items, Owner = UserName);
```

### When to Use Each

| Use Case | Approach | Why |
|----------|----------|-----|
| User profile, roles, permissions | Declarative (Named Formula) | Computed once, auto-updates, lazy-loaded |
| Theme colors, config values | Declarative (Named Formula) | Static, referenced everywhere |
| Filtered/computed data views | Declarative (Named Formula) | Reactive to source changes |
| Lookup tables (Departments, Statuses) | Imperative (ClearCollect in OnStart) | Cache for performance |
| User input state (search text, selection) | Imperative (Set/UpdateContext) | User-driven, mutable |
| Navigation, dialogs, forms | Imperative (Set/UpdateContext) | UI state management |
| Data modifications (Patch, Remove) | Imperative (OnSelect) | Side effects required |

### The Hybrid Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                      App.Formulas                           │
│  (Declarative Layer - Computed Values, UDFs)                │
│                                                             │
│  ThemeColors = { Primary: "#0078D4", ... }                  │
│  UserProfile = Office365Users.MyProfileV2()                 │
│  UserRoles = { IsAdmin: ..., IsManager: ... }               │
│  HasPermission(perm) = perm in UserPermissions              │
│  GetCETToday() = DateAdd(Today(), 1, TimeUnit.Hours)        │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                      App.OnStart                            │
│  (Imperative Layer - State Init, Cached Data)               │
│                                                             │
│  Set(AppState, { IsLoading: false, Error: Blank() })        │
│  Set(ActiveFilters, { Search: "", Status: "All" })          │
│  Concurrent(                                                │
│      ClearCollect(CachedDepartments, Departments),          │
│      ClearCollect(CachedStatuses, Statuses)                 │
│  )                                                          │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                   Control Properties                        │
│  (Declarative - Reference formulas and state)               │
│                                                             │
│  Gallery.Items = Filter(Items, Status = ActiveFilters.Status)│
│  Button.Visible = HasPermission("Delete")                   │
│  Label.Text = UserProfile.displayName                       │
└─────────────────────────────────────────────────────────────┘
```

### Benefits of Declarative-First

| Benefit | Explanation |
|---------|-------------|
| **Faster startup** | Named Formulas are lazy-evaluated (only computed when referenced) |
| **Auto-refresh** | When source data changes, computed values update automatically |
| **Single source of truth** | UDFs prevent copy-paste of validation logic |
| **Easier testing** | Pure functions with no side effects |
| **Better IntelliSense** | Named Formulas appear in autocomplete everywhere |

---

## 2. Understanding Delegation

### What Is Delegation?

Delegation is when Power Apps sends a query to the data source (SharePoint, Dataverse) to be processed server-side, rather than downloading all data and filtering locally.

```
┌─────────────────┐         ┌─────────────────┐
│   Power App     │         │   SharePoint    │
│                 │         │                 │
│  Filter(Items,  │ ──────► │  Execute query  │
│    Status="A")  │         │  server-side    │
│                 │ ◄────── │  Return 50 rows │
└─────────────────┘         └─────────────────┘

     DELEGATED: Server filters, returns only matching rows
```

vs.

```
┌─────────────────┐         ┌─────────────────┐
│   Power App     │         │   SharePoint    │
│                 │         │                 │
│  Filter(Items,  │ ◄────── │  Return 2000    │
│    Year(Date)   │         │  rows (limit!)  │
│      = 2025)    │         │                 │
│                 │         │                 │
│  Filter locally │         │                 │
│  (incomplete!)  │         │                 │
└─────────────────┘         └─────────────────┘

     NOT DELEGATED: Downloads up to 2000 rows, filters locally
                    MISSES DATA BEYOND 2000 ROW LIMIT!
```

### Why Delegation Matters

**Problem:** Non-delegable queries silently return incomplete results.

| Scenario | List Size | Delegation | Result |
|----------|-----------|------------|--------|
| Filter by Status | 500 items | ✓ Delegated | All 500 checked |
| Filter by Status | 10,000 items | ✓ Delegated | All 10,000 checked |
| Filter by Year(Date) | 500 items | ✗ Not delegated | All 500 checked (works by luck) |
| Filter by Year(Date) | 10,000 items | ✗ Not delegated | Only 2000 checked, **8000 IGNORED** |

### Delegable vs Non-Delegable Functions

#### SharePoint Delegable Functions

| Function | Delegable | Notes |
|----------|-----------|-------|
| `Filter()` | ✓ Yes | With simple conditions |
| `Sort()` | ✓ Yes | Single column only |
| `SortByColumns()` | ✓ Yes | Single column only |
| `Search()` | ✓ Yes | Text columns only |
| `=, <>, <, >, <=, >=` | ✓ Yes | Comparison operators |
| `And`, `Or`, `Not` | ✓ Yes | Logical operators |
| `StartsWith()` | ✓ Yes | Text matching |
| `IsBlank()` | ✓ Yes | Null checks |
| `in` (static list) | ✓ Yes | e.g., `Status in ["A", "B"]` |

#### SharePoint Non-Delegable Functions

| Function | Why Not Delegable | Workaround |
|----------|-------------------|------------|
| `Year()`, `Month()`, `Day()` | Date extraction | Use date range: `Date >= start && Date < end` |
| `EndsWith()` | Text manipulation | Pre-calculate column or use Search() |
| `Len()`, `Left()`, `Right()` | Text manipulation | Pre-calculate column |
| `Lower()`, `Upper()` | Case manipulation | SharePoint is case-insensitive anyway |
| `Trim()` | Text manipulation | Clean data at source |
| `CountRows()` on filtered | Aggregation | Use separate counter column |
| `Sum()`, `Average()` | Aggregation | Use Power Automate or calculated column |
| `Lookup()` in filter | Nested query | Flatten data or pre-load lookup |
| `in` (dynamic collection) | Variable lookup | Pre-filter or restructure query |

### How to Detect Delegation Warnings

1. **Blue underline** in formula bar = delegation warning
2. **App Checker** (Settings → Upcoming features → App checker)
3. **Monitor Tool** (F12) shows "Non-delegable" in network tab

### Delegation Workarounds

#### Pattern 1: Date Range Instead of Year()

```powerfx
// ❌ NON-DELEGABLE - Year() not supported
Filter(Items, Year(CreatedDate) = 2025)

// ✓ DELEGABLE - Use date range comparison
Filter(Items,
    CreatedDate >= Date(2025, 1, 1) &&
    CreatedDate < Date(2026, 1, 1)
)
```

#### Pattern 2: StartsWith Instead of Contains

```powerfx
// ⚠️ PARTIALLY DELEGABLE - Contains is NOT delegable on SharePoint
Filter(Items, "urgent" in Lower(Title))

// ✓ DELEGABLE - StartsWith is delegable
Filter(Items, StartsWith(Title, "urgent"))

// ✓ DELEGABLE - Search() for text matching
Search(Items, "urgent", "Title", "Description")
```

#### Pattern 3: Pre-Filter Then Local Filter

```powerfx
// ❌ NON-DELEGABLE - Len() not supported
Filter(Items, Len(Notes) > 100)

// ✓ HYBRID - Delegate what you can, then filter locally
With(
    { delegatedItems: Filter(Items, Status = "Active") },
    Filter(delegatedItems, Len(Notes) > 100)
)
// Works if delegated filter reduces to < 2000 rows
```

#### Pattern 4: Calculated Columns in SharePoint

```
Problem: Need to filter by calculated value (e.g., FullName = FirstName + LastName)

Solution: Add calculated column in SharePoint
1. SharePoint List → Add Column → Calculated
2. Formula: =[FirstName] & " " & [LastName]
3. Now delegable: Filter(Items, StartsWith(FullName, searchText))
```

---

## 3. Data Loading Strategies

### When to Load Data: Decision Matrix

| Load Timing | Use Case | Why | Example |
|-------------|----------|-----|---------|
| **App.Formulas** | Computed/derived data | Lazy, reactive, no storage | `FilteredItems = Filter(Items, ...)` |
| **App.OnStart** | Static lookup tables | Cache once, use everywhere | `ClearCollect(CachedDepartments, ...)` |
| **OnVisible** | Screen-specific data | Fresh data per screen | `ClearCollect(ScreenItems, ...)` |
| **OnSelect** | On-demand/expensive | User-triggered only | `ClearCollect(SearchResults, ...)` |
| **Timer.OnTimerEnd** | Auto-refresh | Periodic updates | Refresh every 5 minutes |

### App.OnStart: What to Load

**Goal:** Load data that is:
- Used on multiple screens
- Rarely changes during session
- Small enough to cache (< 500 rows typically)

```powerfx
// App.OnStart - Load static lookups in parallel
Concurrent(
    // Lookup tables (small, static)
    ClearCollect(CachedDepartments,
        Filter(Departments, Status.Value = "Active")),
    ClearCollect(CachedStatuses,
        Filter(Statuses, IsActive = true)),
    ClearCollect(CachedCategories,
        Filter(Categories, Status.Value = "Active")),

    // User-specific small dataset
    ClearCollect(MyRecentItems,
        TopN(
            Sort(
                Filter(Items, 'Created By'.Email = User().Email),
                'Modified', SortOrder.Descending
            ),
            10
        )
    )
);
```

**Do NOT load in OnStart:**
- Large datasets (> 500 rows)
- Frequently changing data
- Screen-specific data
- Data that may not be needed

### OnVisible: Screen-Specific Loading

**Goal:** Load fresh data when user navigates to screen

```powerfx
// Screen.OnVisible
If(
    // Only reload if needed (caching pattern)
    IsEmpty(ScreenOrders) ||
    DateDiff(LastOrdersLoad, Now(), TimeUnit.Minutes) > 5,

    Concurrent(
        ClearCollect(ScreenOrders,
            Filter(Orders,
                Status.Value <> "Closed" &&
                'Assigned To'.Email = User().Email
            )
        ),
        Set(LastOrdersLoad, Now())
    )
);
```

### Direct Data Source vs Collection

```
┌─────────────────────────────────────────────────────────────┐
│                    DIRECT DATA SOURCE                       │
│                                                             │
│  Gallery.Items = Filter(SharePointList, Status = "Active") │
│                                                             │
│  ✓ Always fresh data                                        │
│  ✓ Delegable (server-side filtering)                        │
│  ✓ No memory usage for storage                              │
│  ✗ Network call on every reference                          │
│  ✗ Slower UI response                                       │
└─────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────┐
│                    COLLECTION (ClearCollect)                │
│                                                             │
│  OnVisible: ClearCollect(LocalItems, Filter(...))           │
│  Gallery.Items = LocalItems                                 │
│                                                             │
│  ✓ Fast UI response (local data)                            │
│  ✓ Can use non-delegable functions                          │
│  ✓ Works offline (if pre-loaded)                            │
│  ✗ Stale data (must manually refresh)                       │
│  ✗ Memory usage                                             │
│  ✗ Initial load time                                        │
└─────────────────────────────────────────────────────────────┘
```

---

## 4. ClearCollect vs Direct Data Source

### Decision Framework

| Factor | Use Direct Source | Use ClearCollect |
|--------|-------------------|------------------|
| **Data size** | Any size (delegable) | < 2000 rows (limit) |
| **Change frequency** | Frequent changes | Rarely changes in session |
| **Query complexity** | Simple, delegable | Complex, non-delegable |
| **Offline requirement** | Not needed | Required |
| **UI responsiveness** | Acceptable latency | Must be instant |
| **Screen usage** | Single screen | Multiple screens |

### Pattern 1: Direct Source for Galleries

```powerfx
// ✓ RECOMMENDED for large, frequently changing data
glr_Orders.Items =
    Sort(
        Filter(Orders,
            Status.Value = drp_StatusFilter.Selected.Value &&
            StartsWith(Title, txt_Search.Text)
        ),
        'Modified', SortOrder.Descending
    )
```

**Why:**
- Delegable query runs server-side
- Always shows fresh data
- No memory overhead

### Pattern 2: ClearCollect for Lookups

```powerfx
// App.OnStart
ClearCollect(CachedDepartments,
    Sort(
        Filter(Departments, Status.Value = "Active"),
        Title, SortOrder.Ascending
    )
);

// Control usage
drp_Department.Items = CachedDepartments
```

**Why:**
- Dropdown loads instantly
- No network call per interaction
- Data rarely changes during session

### Pattern 3: Hybrid for Complex Queries

```powerfx
// OnVisible - Get delegable subset
ClearCollect(BaseOrders,
    Filter(Orders,
        Status.Value <> "Closed" &&
        'Created' >= DateAdd(Today(), -30, TimeUnit.Days)
    )
);

// Gallery - Apply non-delegable filters locally
glr_Orders.Items =
    Filter(BaseOrders,
        // Non-delegable filters are now safe
        Len(Notes) > 50 &&
        Weekday('Due Date') <> 1  // Exclude Sundays
    )
```

**Why:**
- Delegation gets manageable subset (< 2000 rows)
- Complex filters run on local collection
- Best of both worlds

### Pattern 4: Refresh Strategy

```powerfx
// Manual refresh button
btn_Refresh.OnSelect =
    ClearCollect(CachedOrders,
        Filter(Orders, Status.Value = "Active")
    );
    Notify("Data refreshed", NotificationType.Success);

// Auto-refresh every 5 minutes
Timer.Duration = 300000  // 5 minutes in ms
Timer.OnTimerEnd =
    If(
        !AppState.IsEditing,  // Don't refresh during edits
        ClearCollect(CachedOrders, Filter(Orders, Status.Value = "Active"))
    )
```

---

## 5. Search & Filter Patterns

### Simple Search (Delegable)

```powerfx
// ✓ DELEGABLE - Search() function
glr_Items.Items =
    Search(Items, txt_Search.Text, "Title", "Description")
```

**How it works:**
- SharePoint performs full-text search
- Matches partial words
- Case-insensitive
- Searches across specified columns

**Limitations:**
- Cannot combine with Filter() in same query
- Only works on text columns
- No control over match type (contains vs starts with)

### StartsWith Search (Delegable)

```powerfx
// ✓ DELEGABLE - StartsWith in Filter
glr_Items.Items =
    Filter(Items,
        StartsWith(Title, txt_Search.Text) ||
        StartsWith(Description, txt_Search.Text)
    )
```

**When to use:**
- Need to combine with other filters
- Want prefix matching specifically
- More predictable than Search()

### Combined Filter + Search Pattern

```powerfx
// Problem: Search() and Filter() don't combine well in one query

// ✓ SOLUTION: Use nested Filter with StartsWith
glr_Items.Items =
    Filter(Items,
        Status.Value = drp_Status.Selected.Value &&
        Category.Value = drp_Category.Selected.Value &&
        (
            IsBlank(txt_Search.Text) ||
            StartsWith(Title, txt_Search.Text) ||
            StartsWith('Customer Name', txt_Search.Text)
        )
    )
```

### Advanced Search Form Pattern

```powerfx
// Advanced search with multiple optional criteria
glr_Items.Items =
    Filter(Items,
        // Required: Active items only
        Status.Value = "Active" &&

        // Optional: Status filter
        (IsBlank(drp_Status.Selected.Value) ||
         Status.Value = drp_Status.Selected.Value) &&

        // Optional: Category filter
        (IsBlank(drp_Category.Selected.Value) ||
         Category.Value = drp_Category.Selected.Value) &&

        // Optional: Date range
        (IsBlank(dat_StartDate.SelectedDate) ||
         'Created' >= dat_StartDate.SelectedDate) &&
        (IsBlank(dat_EndDate.SelectedDate) ||
         'Created' <= dat_EndDate.SelectedDate) &&

        // Optional: Text search
        (IsBlank(txt_Search.Text) ||
         StartsWith(Title, txt_Search.Text))
    )
```

### Search UDF Pattern

```powerfx
// App.Formulas - Reusable search filter
MatchesSearch(title: Text, search: Text): Boolean =
    IsBlank(search) || StartsWith(Lower(title), Lower(search));

// Usage in Gallery
glr_Items.Items = Filter(Items, MatchesSearch(Title, txt_Search.Text))
```

### Filter State Management

```powerfx
// App.OnStart - Initialize filter state
Set(ActiveFilters, {
    Search: "",
    Status: Blank(),
    Category: Blank(),
    DateFrom: Blank(),
    DateTo: Blank(),
    ShowArchived: false
});

// Reset button
btn_ResetFilters.OnSelect =
    Set(ActiveFilters, {
        Search: "",
        Status: Blank(),
        Category: Blank(),
        DateFrom: Blank(),
        DateTo: Blank(),
        ShowArchived: false
    });
    Reset(txt_Search);
    Reset(drp_Status);
    Reset(drp_Category);

// Apply filters
glr_Items.Items =
    Filter(Items,
        (ActiveFilters.ShowArchived || Status.Value <> "Archived") &&
        (IsBlank(ActiveFilters.Status) || Status.Value = ActiveFilters.Status) &&
        (IsBlank(ActiveFilters.Search) || StartsWith(Title, ActiveFilters.Search))
    )
```

---

## 6. Pagination Patterns

### Why Pagination Matters

**Problem:** Displaying 10,000 items in a gallery is:
- Slow to render
- Memory-intensive
- Poor UX (endless scrolling)

**Solution:** Load and display data in pages

### Server-Side Pagination (Delegable)

```powerfx
// State
Set(CurrentPage, 1);
Set(PageSize, 50);

// Gallery Items - Skip and Take pattern
glr_Items.Items =
    FirstN(
        Skip(
            Sort(
                Filter(Items, Status.Value = "Active"),
                'Modified', SortOrder.Descending
            ),
            (CurrentPage - 1) * PageSize
        ),
        PageSize
    )

// Navigation
btn_NextPage.OnSelect = Set(CurrentPage, CurrentPage + 1)
btn_PrevPage.OnSelect = Set(CurrentPage, Max(1, CurrentPage - 1))

// Disable buttons appropriately
btn_PrevPage.DisplayMode = If(CurrentPage = 1, DisplayMode.Disabled, DisplayMode.Edit)
btn_NextPage.DisplayMode = If(CountRows(glr_Items.AllItems) < PageSize, DisplayMode.Disabled, DisplayMode.Edit)
```

### Pagination UDF

```powerfx
// App.Formulas
GetPagedItems(
    items: Table,
    page: Number,
    pageSize: Number
): Table =
    FirstN(Skip(items, (page - 1) * pageSize), pageSize);

// Usage
glr_Items.Items = GetPagedItems(
    Filter(Items, Status.Value = "Active"),
    CurrentPage,
    50
)
```

### Load More Pattern (Infinite Scroll Alternative)

```powerfx
// State
Set(LoadedCount, 50);

// Gallery - Show loaded items
glr_Items.Items = FirstN(AllFilteredItems, LoadedCount)

// Load More button
btn_LoadMore.OnSelect = Set(LoadedCount, LoadedCount + 50)
btn_LoadMore.Visible = LoadedCount < CountRows(AllFilteredItems)
```

---

## 7. Performance Optimization

### Startup Performance

| Optimization | Impact | How |
|--------------|--------|-----|
| Concurrent() for parallel loads | 40-60% faster | `Concurrent(ClearCollect(...), ClearCollect(...))` |
| Lazy loading with Named Formulas | Startup not blocked | `UserProfile = Office365Users.MyProfileV2()` |
| Defer non-critical loads | Faster perceived startup | Load details in OnVisible |
| Minimize OnStart code | Faster first paint | Only load essential data |

### Query Performance

| Optimization | Impact | How |
|--------------|--------|-----|
| Use delegation | Query any size list | Use delegable functions only |
| Add indexes in SharePoint | Faster queries | Index filtered/sorted columns |
| Limit columns returned | Less data transfer | `ShowColumns(Items, "Title", "Status")` |
| Filter early | Less data to process | `Filter()` before `Sort()` |

### UI Performance

| Optimization | Impact | How |
|--------------|--------|-----|
| Reduce gallery items | Faster rendering | Pagination or FirstN() |
| Simplify gallery templates | Faster rendering | Fewer controls per row |
| Use DelayOutput on TextInput | Fewer re-renders | `txt_Search.DelayOutput = true` |
| Avoid nested galleries | Much faster | Flatten data structure |
| Cache static content | No re-fetch | Use collections for lookups |

### Memory Optimization

```powerfx
// ❌ BAD - Loading entire list into memory
ClearCollect(AllItems, Items)  // Could be 100,000 rows!

// ✓ GOOD - Load only what's needed
ClearCollect(RecentItems,
    FirstN(
        Sort(Items, 'Modified', SortOrder.Descending),
        100
    )
)

// ✓ GOOD - Use direct source for large lists
glr_Items.Items = Filter(Items, ...)  // No collection needed
```

### Monitoring Performance

1. **Power Apps Monitor** (F12 in Studio)
   - Network tab: See all data calls
   - Duration: Identify slow queries
   - Rows: Check data volumes

2. **App Checker**
   - Settings → Upcoming features → Formula-level error management
   - Shows delegation warnings

3. **Timing patterns**
```powerfx
// Measure load time
Set(LoadStart, Now());
ClearCollect(Items, ...);
Set(LoadDuration, DateDiff(LoadStart, Now(), TimeUnit.Milliseconds));
// Use LoadDuration for diagnostics
```

---

## 8. SharePoint-Specific Patterns

### SharePoint Column Types and Delegation

| Column Type | Delegable Operations | Notes |
|-------------|---------------------|-------|
| Single line text | =, <>, StartsWith, Search | Case-insensitive |
| Multiple lines | Search only | No Filter support |
| Choice | =, <> | Use `.Value` property |
| Lookup | =, <> (ID only) | Use `.Id` not `.Value` for delegation |
| Person | =, <> (Email) | Use `.Email` property |
| Date/Time | =, <>, <, >, <=, >= | Direct comparison only |
| Number | =, <>, <, >, <=, >= | Full support |
| Yes/No | =, <> | Boolean comparison |
| Calculated | None | Never delegable |
| Managed Metadata | None | Not delegable |

### Lookup Column Patterns

```powerfx
// ❌ NON-DELEGABLE - Comparing lookup value
Filter(Items, Category.Value = "Electronics")

// ✓ DELEGABLE - Compare lookup ID
Filter(Items, Category.Id = LookUp(Categories, Value = "Electronics", Id))

// ✓ BETTER - Pre-resolve ID
// In OnStart or OnVisible:
Set(ElectronicsCategoryId, LookUp(Categories, Value = "Electronics", Id));
// Then in Gallery:
Filter(Items, Category.Id = ElectronicsCategoryId)
```

### Person Column Patterns

```powerfx
// ✓ DELEGABLE - Compare email
Filter(Items, 'Assigned To'.Email = User().Email)

// ✓ DELEGABLE - Compare with variable
Filter(Items, 'Created By'.Email = CurrentUserEmail)

// ❌ NON-DELEGABLE - Display name comparison
Filter(Items, 'Assigned To'.DisplayName = "John Doe")
```

### Choice Column Patterns

```powerfx
// ✓ DELEGABLE - Single choice comparison
Filter(Items, Status.Value = "Active")

// ✓ DELEGABLE - Multiple choice values
Filter(Items, Status.Value = "Active" || Status.Value = "Pending")

// Using dropdown selection
Filter(Items, Status.Value = drp_Status.Selected.Value)
```

### Date Column Patterns

```powerfx
// ✓ DELEGABLE - Direct date comparison
Filter(Items, 'Due Date' >= Today())

// ✓ DELEGABLE - Date range
Filter(Items,
    'Created' >= Date(2025, 1, 1) &&
    'Created' < Date(2025, 2, 1)
)

// ❌ NON-DELEGABLE - Date functions
Filter(Items, Month('Created') = 1)  // Month() not delegable

// ⚠️ TIMEZONE - SharePoint stores UTC
// Use CET conversion for German apps
Filter(Items, 'Due Date' < GetCETToday())
```

### SharePoint View Integration

```powerfx
// Use SharePoint views to pre-filter data
// Create view "ActiveItems" in SharePoint with filter Status = Active

// Reference view in Power Apps (reduces initial query)
ClearCollect(ActiveItems, 'ActiveItems')  // Uses view name

// Note: Views are still subject to delegation limits
```

### Optimizing SharePoint Queries

```powerfx
// 1. Index columns used in filters
//    SharePoint → List Settings → Indexed Columns
//    Add: Status, Created, Modified, Assigned To

// 2. Create compound index for common queries
//    Index both Status AND Department if often filtered together

// 3. Limit columns retrieved
ShowColumns(
    Filter(Items, Status.Value = "Active"),
    "ID", "Title", "Status", "Modified"
)

// 4. Use lookup caching
// Don't resolve lookup in gallery - cache in collection
ClearCollect(ItemsWithLookups,
    AddColumns(
        Filter(Items, Status.Value = "Active"),
        "CategoryName", LookUp(CachedCategories, Id = Category.Id, Title)
    )
)
```

---

## Quick Reference Card

### Data Loading Decision Tree

```
Is the data...
├─ Static lookup (Departments, Statuses)?
│   └─ ClearCollect in App.OnStart
├─ User-specific, used on multiple screens?
│   └─ ClearCollect in App.OnStart
├─ Screen-specific?
│   └─ ClearCollect in OnVisible (with caching)
├─ Large (>500 rows) and frequently changing?
│   └─ Direct source in Gallery.Items
├─ Needs complex non-delegable filtering?
│   └─ Hybrid: Delegate first, then local filter
└─ Computed from other data?
    └─ Named Formula (App.Formulas)
```

### Delegation Checklist

- [ ] All Filter() conditions use delegable functions
- [ ] No Year(), Month(), Day() on dates
- [ ] No Len(), Left(), Right() on text
- [ ] Lookup columns compared by ID, not Value
- [ ] Person columns compared by Email
- [ ] Date ranges instead of date extraction
- [ ] StartsWith() instead of Contains() for search
- [ ] Indexed columns in SharePoint for filtered fields

### Performance Checklist

- [ ] Concurrent() for parallel ClearCollect
- [ ] Named Formulas for computed values
- [ ] Pagination for large galleries
- [ ] DelayOutput on search inputs
- [ ] Cached lookups for dropdowns
- [ ] FirstN() to limit result sets
- [ ] No nested galleries
- [ ] Monitor tool shows <500ms queries

---

*Last updated: 2025-01-28*
