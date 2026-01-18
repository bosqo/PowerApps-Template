# Gallery Performance & Pagination Patterns

## Overview

This document explains how to implement performant galleries with 500+ records and handle non-delegable operations through pagination.

## Performance Baseline

**Gallery render time (500 records, simple layout):** <1 second
**Page load time (FirstN/Skip pagination, 50 records):** <500ms
**Smooth scrolling:** Maintained at 30+ FPS with responsive interaction

These baselines established in Phase 2-03 (Performance Validation). See PERF-04 requirement.

## When to Use Pagination

### Use FirstN(Skip()) Pagination When:

1. **Large dataset + text search:** Filtering >5000 records with Search() across multiple fields
2. **Large dataset + complex filters:** Multiple filter conditions combined with AND/OR logic
3. **Gallery is slow:** Rendering takes >1 second or scrolling stutters
4. **Delegation warnings in Monitor:** Yellow warnings indicate non-delegable operations

### Don't Need Pagination When:

1. **Dataset <2000 records:** Can use Filter() directly without FirstN/Skip
2. **Simple filter:** Single condition like Status = "Active"
3. **No text search:** Filtering only by status/role/ownership

## FirstN(Skip()) Pagination Pattern

### Basic Pattern

```powerfx
Gallery.Items: Table = FirstN(
  Skip(
    Filter(DataSource, Condition1, Condition2, ...),
    (AppState.CurrentPage - 1) * AppState.PageSize
  ),
  AppState.PageSize
)
```

**Key formula breakdown:**

| Part | What it does | Example |
|------|-------------|---------|
| Filter(...) | Applies all conditions, returns filtered table | Filter(Items, Status="Active") |
| Skip(..., offset) | Skips N records from start of filtered table | Skip(..., 50) = skip first 50 records |
| (CurrentPage-1)*PageSize | Calculates offset: if page=2, pagesize=50, then (2-1)*50=50 | On page 3 of 50: (3-1)*50=100 |
| FirstN(..., count) | Takes N records from current position | FirstN(..., 50) = take next 50 records |

### Example: Showing Pages

| Page | Formula | Records shown |
|------|---------|-----------------|
| 1 | FirstN(Skip(Filter(...), 0), 50) | 1-50 |
| 2 | FirstN(Skip(Filter(...), 50), 50) | 51-100 |
| 3 | FirstN(Skip(Filter(...), 100), 50) | 101-150 |

## Implementation Steps

### Step 1: Add Pagination State Variables

In App.OnStart:

```powerfx
// Add to AppState initialization
Set(AppState, Patch(AppState, {
  CurrentPage: 1,      // Start at page 1
  PageSize: 50,        // Show 50 records per page
  LastFilterChangeTime: Now()
}));
```

### Step 2: Calculate Total Pages

In Gallery label or variable:

```powerfx
// Calculate total pages from filtered dataset
TotalPages: Number = Ceiling(
  CountRows(
    Filter(Items, Status = "Active")  // Use SAME filter conditions as Gallery.Items
  ) / 50  // Divide by page size
);
```

**Critical:** CountRows() should use same Filter() conditions as Gallery.Items.

**Why:** CountRows() is non-delegable, so call it on already-filtered result, not on full datasource.

### Step 3: Set Gallery.Items to Paginated Formula

```powerfx
Gallery.Items: Table = FirstN(
  Skip(
    Filter(Items, Status = "Active"),  // All your filter conditions here
    (AppState.CurrentPage - 1) * 50    // Calculate skip offset
  ),
  50  // Show 50 records per page
)
```

### Step 4: Add Navigation Controls

**Previous Button OnSelect:**
```powerfx
If(
  AppState.CurrentPage > 1,
  Set(AppState, Patch(AppState, {CurrentPage: AppState.CurrentPage - 1})),
  Notify("Bereits auf der ersten Seite", NotificationType.Information)
)
```

**Next Button OnSelect:**
```powerfx
If(
  AppState.CurrentPage < TotalPages,
  Set(AppState, Patch(AppState, {CurrentPage: AppState.CurrentPage + 1})),
  Notify("Bereits auf der letzten Seite", NotificationType.Information)
)
```

**Previous Button DisplayMode (disable at page 1):**
```powerfx
If(AppState.CurrentPage > 1, DisplayMode.Edit, DisplayMode.Disabled)
```

**Next Button DisplayMode (disable at last page):**
```powerfx
If(AppState.CurrentPage < TotalPages, DisplayMode.Edit, DisplayMode.Disabled)
```

### Step 5: Reset Page When Filters Change

Add logic to reset CurrentPage to 1 when filters change:

```powerfx
// In App.OnStart or filter change handler
If(
  ActiveFilters <> PreviousActiveFilters,  // Detect filter change
  Set(AppState, Patch(AppState, {CurrentPage: 1})),  // Reset to page 1
  // No action if filters unchanged
  true
)
```

**Why:** Prevents user from staying on page 47 after applying a filter that results in only 2 pages.

## Using with FilteredGalleryData() Composition

When using the FilteredGalleryData() UDF from Plan 03-02:

```powerfx
// Gallery.Items with pagination
Gallery.Items: Table = FirstN(
  Skip(
    FilteredGalleryData(
      ActiveFilters.ShowMyItemsOnly,
      ActiveFilters.SelectedStatus,
      ActiveFilters.SearchTerm
    ),
    (AppState.CurrentPage - 1) * AppState.PageSize
  ),
  AppState.PageSize
);

// Total pages calculation
TotalPages: Number = Ceiling(
  CountRows(
    FilteredGalleryData(
      ActiveFilters.ShowMyItemsOnly,
      ActiveFilters.SelectedStatus,
      ActiveFilters.SearchTerm
    )
  ) / AppState.PageSize
);
```

**Important:** Use exact same FilteredGalleryData() parameters in both Gallery.Items AND TotalPages calculation.

## Common Mistakes

### Mistake 1: Calling CountRows() on full datasource

```powerfx
// ✗ WRONG: CountRows on 10,000 record list
TotalPages: Number = Ceiling(CountRows(Items) / 50);
```

**Fix:** Count only the filtered result

```powerfx
// ✓ CORRECT: CountRows on filtered result
TotalPages: Number = Ceiling(
  CountRows(
    Filter(Items, Status = "Active")
  ) / 50
);
```

### Mistake 2: Filter() after FirstN(Skip())

```powerfx
// ✗ WRONG: Pagination before filtering breaks delegation
Gallery.Items: Table = Filter(
  FirstN(Skip(Items, 0), 50),
  Status = "Active"
);
```

**Fix:** Filter first, then paginate

```powerfx
// ✓ CORRECT: Filter before pagination
Gallery.Items: Table = FirstN(
  Skip(
    Filter(Items, Status = "Active"),
    0
  ),
  50
);
```

### Mistake 3: Not resetting page on filter change

```powerfx
// ✗ PROBLEM: User on page 10, applies restrictive filter (now only 3 pages)
// Result: Gallery shows blank because CurrentPage (10) > TotalPages (3)
```

**Fix:** Reset CurrentPage to 1 when filters change

```powerfx
// ✓ CORRECT: Detect filter change and reset
If(
  ActiveFilters <> LastActiveFilters,
  Set(AppState, Patch(AppState, {CurrentPage: 1})),
  true
)
```

## Performance Tips

### For Fastest Performance:

1. **Apply most restrictive filter first:** Status usually filters down 80%, so put it first
2. **Skip text search if possible:** Text search is slowest operation
3. **Use FirstN/Skip for large datasets:** Pagination <500ms vs 2+ seconds for full filter
4. **Keep page size around 50:** Too small (10) = many page clicks, too large (500) = slow load

### Monitoring Performance

Use Power Apps Monitor (F12 in Studio):

1. **Check formula timing:** How long does FirstN(Skip()) take?
2. **Check data retrieval:** How long does datasource query take?
3. **Check rendering:** How long does gallery render take?
4. **Look for delegation warnings:** Yellow icon = potential problem

**Target timings:**
- FirstN/Skip calculation: <100ms
- Datasource query: <500ms for filtered 50 records
- Gallery render: <300ms for 50 rows with simple layout

## Testing Pagination

### Test Scenario 1: Normal Pagination

1. Open app, gallery should show page 1 (records 1-50)
2. Click Next, verify gallery shows page 2 (records 51-100)
3. Click Previous, verify page 1 is shown again
4. Page indicator should update correctly ("Seite N von M")

### Test Scenario 2: Filter and Reset Page

1. Navigate to page 3
2. Apply a restrictive filter (e.g., Status="Active" shows only 75 records)
3. Page should reset to 1 automatically
4. Total pages should update (e.g., "Seite 1 von 2" instead of "Seite 1 von 5")

### Test Scenario 3: Text Search

1. Apply text search for "test"
2. Verify gallery shows only matching records
3. Verify page indicator updates based on matching records (not all records)
4. Navigate pages, verify search filter stays applied

### Test Scenario 4: Large Dataset Performance

1. Load app with 5000+ record list
2. Apply multiple filters
3. Verify first page loads in <500ms
4. Verify page navigation is responsive
5. Monitor tool should show no delegation warnings

## FAQ

**Q: Why FirstN/Skip instead of just Filter()?**
A: For large datasets, Filter() with complex conditions becomes non-delegable. FirstN/Skip ensures delegable pagination on top of filtered data.

**Q: Can I use a different page size (not 50)?**
A: Yes! Change AppState.PageSize and update all formulas. 50 is recommended for balance of load time and clicks.

**Q: What if my total page count changes while user is viewing?**
A: This happens when records are added/deleted by other users. Power Apps refreshes automatically. If user is on page 10 and records drop to 5 pages, they'll see blank page until they click Previous.

**Q: Can I show "Jump to page N" input?**
A: Yes, add TextInput where user enters page number, validate 1 <= input <= TotalPages, then Set(AppState.CurrentPage, Value(txt_PageInput)).

**Q: What's the maximum page size I should use?**
A: 50-100 is recommended. Beyond 100, gallery render time increases significantly. Very large pages (1000+) should use virtual scrolling (advanced feature).

---

*Gallery Performance Patterns: Phase 3*
*Last updated: 2026-01-18*
