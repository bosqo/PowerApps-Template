# Reactive Filter System Design

**Date:** 2026-02-13
**Status:** Design Phase
**Approach:** Named Formulas + ActiveFilters State (Declarative-Reactive)

---

## Overview

This design implements a **fully reactive** filter system using Named Formulas that automatically recalculate when filter state changes. This eliminates manual ClearCollect operations and provides instant UI updates.

### Key Benefits

1. **Zero manual ClearCollect** - Gallery.Items binds directly to `FilteredItems` Named Formula
2. **Instant reactivity** - Dropdown changes → `ActiveFilters` updates → `FilteredItems` auto-recalculates → Gallery refreshes
3. **Composable layers** - Base layers (UserScopedItems, ActiveItems) can be reused across multiple galleries
4. **Type-safe** - Named Formulas provide autocomplete and early error detection
5. **Maintainable** - All filter logic in one place (`FilteredItems` formula), not scattered across controls

---

## Architecture: Layered Data Flow

```
┌─────────────────────────────────────────────────────────────┐
│ Layer 1: Base Data (Permission-Filtered)                    │
│ - UserScopedItems (respects ViewAll permission)            │
│ - ActiveItems (Status = "Active")                          │
│ - InactiveItems (Status = "Inactive")                      │
└─────────────────────────────────────────────────────────────┘
                           ↓
┌─────────────────────────────────────────────────────────────┐
│ Layer 2: Dynamic Filter (Reactive to ActiveFilters state)  │
│ - FilteredItems (combines all dropdowns + search)          │
│ - Watches: Status, Department, DateRange, SearchTerm       │
└─────────────────────────────────────────────────────────────┘
                           ↓
┌─────────────────────────────────────────────────────────────┐
│ Layer 3: UI Binding (Gallery.Items)                        │
│ - glr_Items.Items = FilteredItems                          │
│ - Automatically refreshes when FilteredItems changes       │
└─────────────────────────────────────────────────────────────┘
```

**State Flow:**
```
User changes dropdown
  → Set(ActiveFilters, Patch(..., {Status: "Active"}))
    → FilteredItems Named Formula sees ActiveFilters change
      → Auto-recalculates Filter()
        → Gallery.Items sees FilteredItems change
          → UI refreshes automatically
```

---

## Design Sections

### Section 1: Named Formulas (Base Layers + Dynamic Filter)

**File:** `src/App-Formulas-Template.fx`
**Location:** Add after `DateRanges` Named Formula (line ~242)

```powerfx
// ============================================================================
// BASE DATA LAYERS (Permission-Filtered)
// ============================================================================
// Purpose: Reusable base layers for galleries and dashboards
// Depends on: UserPermissions.CanViewAll, User().Email
// Used by: FilteredItems, dashboard KPIs, multiple galleries

// All items visible to current user (respects ViewAll permission)
UserScopedItems = If(
    UserPermissions.CanViewAll,
    Items,
    Filter(Items, Owner.Email = User().Email)
);

// Active items only (Status = "Active")
ActiveItems = Filter(UserScopedItems, Status = "Active");

// Inactive items only (Status = "Inactive")
InactiveItems = Filter(UserScopedItems, Status = "Inactive");

// ============================================================================
// DYNAMIC FILTER LAYER (Reactive to ActiveFilters state)
// ============================================================================
// Purpose: Combines all dropdown filters - fully reactive
// Depends on: ActiveFilters state (Status, Department, DateRange, SearchTerm)
// Used by: Gallery.Items property
// Delegation: All filter expressions are delegable (no UDFs inside Filter)

FilteredItems = Filter(
    UserScopedItems,
    // Status dropdown (blank = show all)
    (IsBlank(ActiveFilters.Status) || Status = ActiveFilters.Status) &&

    // Department dropdown (blank = show all)
    (IsBlank(ActiveFilters.Department) || Department = ActiveFilters.Department) &&

    // Date range dropdown (blank = show all)
    (IsBlank(ActiveFilters.DateRange) ||
     'Modified On' >= DateRanges[ActiveFilters.DateRange].Start) &&

    // Display name search (blank = show all)
    (IsBlank(ActiveFilters.SearchTerm) ||
     StartsWith(Title, ActiveFilters.SearchTerm))
);
```

**Key Design Notes:**

1. **Base Layers Philosophy**
   - `UserScopedItems` - Single source of truth for permission filtering
   - `ActiveItems` / `InactiveItems` - Pre-filtered for common use cases (dashboards, status-specific galleries)
   - Reusable across multiple galleries (e.g., Dashboard shows `ActiveItems`, Archive screen shows `InactiveItems`)

2. **FilteredItems Composition**
   - Uses `IsBlank()` checks for optional filters
   - `Blank()` value = "All" (no filter applied)
   - All expressions are **delegable** (no UDFs, no `Search()`, no `in` operator)
   - Uses `StartsWith()` for text search (delegable with SharePoint)

3. **Delegation Safety**
   - ✅ `Status = ActiveFilters.Status` - delegable equality
   - ✅ `Department = ActiveFilters.Department` - delegable equality
   - ✅ `'Modified On' >= DateRanges[...].Start` - delegable comparison
   - ✅ `StartsWith(Title, ...)` - delegable text search (SharePoint/Dataverse)
   - ❌ **Do NOT use**: `MatchesSearchTerm(Title, ...)` inside Filter (UDFs are never delegable)

---

### Section 2: ActiveFilters State Structure

**File:** `src/App-OnStart-Minimal.fx`
**Location:** Update existing `ActiveFilters` initialization (line ~188)

**Current state (line 188-208):**
```powerfx
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
```

**Updated state (add new fields):**
```powerfx
Set(ActiveFilters, {
    // === EXISTING FIELDS (keep these) ===
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
    SelectedStatus: "",

    // === NEW FIELDS (add these) ===
    Status: Blank(),           // Selected status (or Blank() for "All")
    Department: Blank(),       // Selected department (or Blank() for "All")
    DateRange: Blank()         // Selected date range key (or Blank() for "All")
    // Note: SearchTerm already exists above (reuse it)
});
```

**Field Usage:**

| Field | Type | Purpose | Default | Dropdown Binding |
|-------|------|---------|---------|------------------|
| `Status` | Text | Selected status filter | `Blank()` | `drp_Status.Selected.Value` |
| `Department` | Text | Selected department filter | `Blank()` | `drp_Department.Selected.Value` |
| `DateRange` | Text | Selected date range key | `Blank()` | `drp_DateRange.Selected.Value` |
| `SearchTerm` | Text | Display name search text | `""` | `txt_SearchName.Text` |

**Important:** Keep existing fields for backward compatibility. Add new fields at the end.

---

### Section 3: DateRanges Enhancement

**File:** `src/App-Formulas-Template.fx`
**Location:** Update `DateRanges` Named Formula (line 216-242)

**Current DateRanges (line 216-242):**
```powerfx
DateRanges = {
    Today: Today(),
    Yesterday: Today() - 1,
    Tomorrow: Today() + 1,
    // ... other fields ...
    Last7Days: Today() - 7,
    Last30Days: Today() - 30,
    Last90Days: Today() - 90
};
```

**Updated DateRanges (add Last14Days):**
```powerfx
DateRanges = {
    // Today and Yesterday
    Today: Today(),
    Yesterday: Today() - 1,
    Tomorrow: Today() + 1,

    // Week Calculations (Monday = start of week for German locale)
    StartOfWeek: Today() - Weekday(Today(), StartOfWeek.Monday) + 1,
    EndOfWeek: Today() - Weekday(Today(), StartOfWeek.Monday) + 7,
    StartOfLastWeek: Today() - Weekday(Today(), StartOfWeek.Monday) + 1 - 7,
    EndOfLastWeek: Today() - Weekday(Today(), StartOfWeek.Monday) + 7 - 7,

    // Month Calculations
    StartOfMonth: Date(Year(Today()), Month(Today()), 1),
    EndOfMonth: Date(Year(Today()), Month(Today()) + 1, 1) - 1,
    StartOfLastMonth: Date(Year(Today()), Month(Today()) - 1, 1),
    EndOfLastMonth: Date(Year(Today()), Month(Today()), 1) - 1,

    // Year Calculations
    StartOfYear: Date(Year(Today()), 1, 1),
    EndOfYear: Date(Year(Today()) + 1, 1, 1) - 1,

    // Relative Ranges (UPDATED: added Last14Days)
    Last7Days: Today() - 7,
    Last14Days: Today() - 14,    // NEW
    Last30Days: Today() - 30,
    Last90Days: Today() - 90
};
```

**Change:** Add `Last14Days: Today() - 14` field.

---

### Section 4: Dropdown OnChange Handlers

**Location:** Individual dropdown control properties

```powerfx
// drp_Status.OnChange
Set(ActiveFilters, Patch(ActiveFilters, {Status: Self.Selected.Value}));

// drp_Department.OnChange
Set(ActiveFilters, Patch(ActiveFilters, {Department: Self.Selected.Value}));

// drp_DateRange.OnChange
Set(ActiveFilters, Patch(ActiveFilters, {DateRange: Self.Selected.Value}));

// txt_SearchName.OnChange (use DelayedOnChange for performance)
Set(ActiveFilters, Patch(ActiveFilters, {SearchTerm: Self.Text}));
```

**Best Practice:** Use `DelayedOnChange` property for text search to avoid filtering on every keystroke.

**Dropdown Setup:**

```powerfx
// drp_Status.Items
CachedStatuses

// drp_Status.Default
Blank()  // "All" by default (applies no filter)

// drp_Department.Items
CachedDepartments

// drp_Department.Default
Blank()  // "All" by default

// drp_DateRange.Items
Table(
    {Value: Blank(), DisplayName: "Alle"},           // "All" option
    {Value: "Last7Days", DisplayName: "Letzte 7 Tage"},
    {Value: "Last14Days", DisplayName: "Letzte 14 Tage"},
    {Value: "Last30Days", DisplayName: "Letzte 30 Tage"},
    {Value: "Last90Days", DisplayName: "Letzte 90 Tage"}
)

// drp_DateRange.Default
Blank()  // "All" by default
```

**Key Points:**

1. **Blank() = "All"** - Empty selection means no filter applied
2. **No validation needed** - `IsBlank()` checks in `FilteredItems` handle empty state
3. **Single Patch()** - Each dropdown updates only its own field
4. **Immediate reactivity** - `FilteredItems` recalculates as soon as `ActiveFilters` changes

---

### Section 5: Gallery.Items Usage

**Location:** Gallery control `Items` property

```powerfx
glr_Items.Items = FilteredItems
```

That's it! The reactive Named Formula handles all filter logic.

**Comparison with old pattern:**

```powerfx
// ❌ OLD: Manual ClearCollect (requires button click)
btn_ApplyFilters.OnSelect = ClearCollect(
    FilteredCollection,
    Filter(Items, Status = drp_Status.Selected.Value, ...)
);
glr_Items.Items = FilteredCollection

// ✅ NEW: Reactive Named Formula (automatic)
glr_Items.Items = FilteredItems
// No button needed - changes apply instantly
```

---

### Section 6: Reset Filters Button (Optional)

**Location:** Button control `OnSelect` property

```powerfx
btn_ResetFilters.OnSelect = Set(ActiveFilters, Patch(ActiveFilters, {
    Status: Blank(),
    Department: Blank(),
    DateRange: Blank(),
    SearchTerm: ""
}));
```

**Result:** All dropdowns reset to "All", gallery shows unfiltered data.

---

## Implementation Checklist

### Phase 1: Named Formulas (App-Formulas-Template.fx)
- [ ] Add `UserScopedItems` Named Formula
- [ ] Add `ActiveItems` Named Formula
- [ ] Add `InactiveItems` Named Formula
- [ ] Add `FilteredItems` Named Formula
- [ ] Update `DateRanges` with `Last14Days` field

### Phase 2: State Initialization (App-OnStart-Minimal.fx)
- [ ] Update `ActiveFilters` with new fields: `Status`, `Department`, `DateRange`
- [ ] Verify existing `SearchTerm` field is preserved

### Phase 3: Dropdown Setup
- [ ] Create `drp_Status` dropdown
  - [ ] Set `Items` to `CachedStatuses`
  - [ ] Set `Default` to `Blank()`
  - [ ] Set `OnChange` to update `ActiveFilters.Status`
- [ ] Create `drp_Department` dropdown
  - [ ] Set `Items` to `CachedDepartments`
  - [ ] Set `Default` to `Blank()`
  - [ ] Set `OnChange` to update `ActiveFilters.Department`
- [ ] Create `drp_DateRange` dropdown
  - [ ] Set `Items` to date range table
  - [ ] Set `Default` to `Blank()`
  - [ ] Set `OnChange` to update `ActiveFilters.DateRange`
- [ ] Create `txt_SearchName` text input
  - [ ] Set `DelayedOnChange` to update `ActiveFilters.SearchTerm`

### Phase 4: Gallery Binding
- [ ] Update `glr_Items.Items` to `FilteredItems`
- [ ] Remove old `ClearCollect()` calls (if any)
- [ ] Remove "Apply Filters" button (no longer needed)

### Phase 5: Reset Button (Optional)
- [ ] Create `btn_ResetFilters` button
- [ ] Set `OnSelect` to reset `ActiveFilters` fields

---

## Testing Plan

### Test 1: Single Filter
1. Set `drp_Status` to "Active"
2. **Expected:** Gallery shows only Active items
3. **Verify:** `FilteredItems` recalculates, gallery refreshes instantly

### Test 2: Combined Filters
1. Set `drp_Status` to "Active"
2. Set `drp_Department` to "Sales"
3. **Expected:** Gallery shows Active items in Sales department
4. **Verify:** Both filters applied correctly

### Test 3: Date Range Filter
1. Set `drp_DateRange` to "Last7Days"
2. **Expected:** Gallery shows items modified in last 7 days
3. **Verify:** `'Modified On' >= DateRanges.Last7Days` logic works

### Test 4: Search Filter
1. Type "Test" in `txt_SearchName`
2. **Expected:** Gallery shows items where Title starts with "Test"
3. **Verify:** `StartsWith()` search works correctly

### Test 5: Reset Filters
1. Apply multiple filters
2. Click `btn_ResetFilters`
3. **Expected:** All dropdowns reset to "All", gallery shows all items
4. **Verify:** `ActiveFilters` fields reset to `Blank()`

### Test 6: Blank() = "All" Logic
1. Set all dropdowns to `Blank()` (or select "Alle" option)
2. **Expected:** Gallery shows all items (no filters applied)
3. **Verify:** `IsBlank()` checks work correctly in `FilteredItems`

### Test 7: Delegation (>2000 records)
1. Use dataset with >2000 records
2. Apply filters via dropdowns
3. **Expected:** No delegation warnings
4. **Verify:** Monitor tool shows delegable queries

---

## Performance Considerations

### Reactivity Cost
- **Named Formulas recalculate automatically** when dependencies change
- `FilteredItems` recalculates when `ActiveFilters` changes
- For <2000 records: negligible performance impact (<50ms)
- For >2000 records: delegation ensures only filtered data is fetched

### Optimization Tips
1. **Use DelayedOnChange for text search** - Prevents filtering on every keystroke
2. **Keep base layers simple** - `UserScopedItems` should not have complex logic
3. **Avoid UDFs inside Filter()** - UDFs are never delegable
4. **Use indexed columns** - Ensure Status, Department, 'Modified On' are indexed in SharePoint/Dataverse

---

## Migration Path (Existing Apps)

If you already have a manual filter system:

### Step 1: Add Named Formulas
```powerfx
// Add to App-Formulas-Template.fx
UserScopedItems = If(UserPermissions.CanViewAll, Items, Filter(Items, Owner.Email = User().Email));
FilteredItems = Filter(UserScopedItems, /* existing filter logic */);
```

### Step 2: Update Gallery
```powerfx
// Change Gallery.Items from:
glr_Items.Items = FilteredCollection

// To:
glr_Items.Items = FilteredItems
```

### Step 3: Remove Old Code
```powerfx
// Delete these (no longer needed):
// - ClearCollect(FilteredCollection, ...) calls
// - btn_ApplyFilters button
// - FilteredCollection collection
```

### Step 4: Test
- Verify all filters work correctly
- Check delegation warnings (should be none)
- Confirm instant reactivity (no button click needed)

---

## Common Pitfalls

### ❌ Using UDFs inside Filter()
```powerfx
// DON'T DO THIS (not delegable)
FilteredItems = Filter(UserScopedItems, MatchesSearchTerm(Title, ActiveFilters.SearchTerm));
```

**Why wrong:** UDFs inside `Filter()` are **never delegable** (Microsoft limitation).

**Fix:** Use inline expressions:
```powerfx
// DO THIS (delegable)
FilteredItems = Filter(UserScopedItems, StartsWith(Title, ActiveFilters.SearchTerm));
```

### ❌ Using `in` operator
```powerfx
// DON'T DO THIS (not delegable with SharePoint)
FilteredItems = Filter(UserScopedItems, Status in ["Active", "Pending"]);
```

**Why wrong:** `in` operator is not delegable with SharePoint.

**Fix:** Use OR logic:
```powerfx
// DO THIS (delegable)
FilteredItems = Filter(UserScopedItems, Status = "Active" || Status = "Pending");
```

### ❌ Using IsBlank() for delegation
```powerfx
// DON'T DO THIS (not delegable with SharePoint)
FilteredItems = Filter(UserScopedItems, IsBlank(Department));
```

**Why wrong:** `IsBlank()` is not delegable with SharePoint.

**Fix:** Use equality check:
```powerfx
// DO THIS (delegable)
FilteredItems = Filter(UserScopedItems, Department = Blank());
```

---

## Future Enhancements

### Phase 2: Advanced Filters
- Multi-select dropdowns (e.g., select multiple statuses)
- Custom date range picker (start/end date)
- Filter presets (save/load filter combinations)

### Phase 3: Pagination
- Add `FirstN()` / `Skip()` for large datasets
- Use `AppState.CurrentPage` for pagination state
- Combine with `FilteredItems` for paginated filtered views

### Phase 4: Filter Persistence
- Save `ActiveFilters` to local storage (Persist() feature)
- Restore filters on app restart
- Share filter links (encode filters in URL params)

---

## References

- **CLAUDE.md** - Delegation patterns, naming conventions
- **App-Formulas-Template.fx** - Existing Named Formulas and UDFs
- **App-OnStart-Minimal.fx** - State initialization patterns
- **docs/performance/DELEGATION-PATTERNS.md** - Delegation best practices
- **docs/performance/FILTER-COMPOSITION-GUIDE.md** - Filter composition patterns
