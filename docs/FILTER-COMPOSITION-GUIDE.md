# Filter Composition & UI Integration Guide

## Overview

This guide explains how to compose multiple filter conditions into a single Gallery formula and integrate them with UI controls (search box, dropdown, toggle, buttons).

## Filter Composition Principle

Filter layers should be ordered from most restrictive to least restrictive:

**Performance hierarchy:**
1. **Status filter** (usually 80% reduction) → Apply FIRST
2. **Role/Ownership filter** (usually 60% reduction of remaining) → Apply SECOND
3. **My Items toggle** (usually 50% reduction of remaining) → Apply THIRD
4. **Text search** (variable reduction, most expensive) → Apply LAST

**Why this order:**
- Filtering 500 records → 100 (status) is fast
- Filtering 100 records → 50 (role) is fast
- Filtering 50 records → text search is FAST (scanning 50 vs 500)
- vs. Reverse order: Filter 500 records → text search = SLOW

## FilteredGalleryData() Composition UDF

The `FilteredGalleryData()` function from Plan 03-02 implements this principle:

```powerfx
FilteredGalleryData: Function(showMyItemsOnly As Logical, selectedStatus As Text, searchTerm As Text): Table =
  Filter(
    Items,
    MatchesStatusFilter(selectedStatus),              // Layer 1: Status (most restrictive)
    CanViewRecord(Owner),                             // Layer 2: Role/Ownership
    If(showMyItemsOnly, Owner = User().Email, true), // Layer 3: My Items toggle
    Or(
      MatchesSearchTerm(Title, searchTerm),           // Layer 4: Search (most expensive)
      MatchesSearchTerm(Description, searchTerm),
      MatchesSearchTerm(Owner, searchTerm)
    )
  );
```

**Key design:**
- Each layer is delegable on its own
- Combined layers remain delegable
- Parameters are passed from state variable (ActiveFilters)
- Blank parameters are handled gracefully (no filter applied for that layer)

## Using FilteredGalleryData in Gallery

### Setup: Gallery.Items Property

```powerfx
Gallery.Items: Table = FilteredGalleryData(
  ActiveFilters.ShowMyItemsOnly,
  ActiveFilters.SelectedStatus,
  ActiveFilters.SearchTerm
)
```

**How it works:**
- Gallery automatically updates when ANY of these ActiveFilters values change
- No manual refresh button needed
- Delegation warnings do not appear (FilteredGalleryData is delegation-safe)

### Setup: ActiveFilters State Variable

In App.OnStart:

```powerfx
Set(ActiveFilters, {
  ShowMyItemsOnly: false,    // My Items toggle state
  SelectedStatus: "",        // Status dropdown selected value
  SearchTerm: ""             // Search box text input value
});
```

## UI Controls & Event Handlers

### Status Dropdown (drp_Status)

**Items Property:**
```powerfx
Table(
  {Value: "", Display: "-- Alle Status --"},
  {Value: "Active", Display: "Aktiv"},
  {Value: "Pending", Display: "Ausstehend"},
  {Value: "Completed", Display: "Abgeschlossen"}
)
```

**OnChange Event:**
```powerfx
Set(ActiveFilters, Patch(ActiveFilters, {SelectedStatus: Self.Value}))
```

**Effect:** Gallery immediately filters to show only records with selected status

### Search TextInput (txt_Search)

**Default Property:**
```powerfx
ActiveFilters.SearchTerm
```

**OnChange Event:**
```powerfx
Set(ActiveFilters, Patch(ActiveFilters, {SearchTerm: Self.Value}))
```

**Effect:** Gallery filters to show records matching search term in Title, Description, or Owner

**Tip:** Add placeholder text: "Nach Titel, Beschreibung oder Besitzer suchen..."

### My Items Toggle (tog_MyItemsOnly)

**Default Property:**
```powerfx
ActiveFilters.ShowMyItemsOnly
```

**OnChange Event:**
```powerfx
Set(ActiveFilters, Patch(ActiveFilters, {ShowMyItemsOnly: Self.Value}))
```

**Effect:** When ON, gallery shows only records where Owner = current user

### Clear All Button (btn_ClearAll)

**OnSelect Event:**
```powerfx
Set(ActiveFilters, {
  ShowMyItemsOnly: false,
  SelectedStatus: "",
  SearchTerm: ""
})
```

**Effect:** Resets all filters to defaults, Gallery shows all non-restricted records

### Filter Summary Label (lbl_FilterSummary)

**Text Property:**
```powerfx
Concatenate(
  "Filter: ",
  If(ActiveFilters.SelectedStatus <> "", Concatenate(ActiveFilters.SelectedStatus, ", "), ""),
  If(ActiveFilters.ShowMyItemsOnly, "Meine Einträge, ", ""),
  If(ActiveFilters.SearchTerm <> "", Concatenate("Suche: '", ActiveFilters.SearchTerm, "'"), "")
)
```

**Effect:** Shows which filters are currently active (helps user understand filters)

**Example:** "Filter: Active, Meine Einträge, Suche: 'test'"

### Record Count Label (lbl_RecordCount)

**Text Property:**
```powerfx
Concatenate(CountRows(glr_Items.AllItems), " Einträge gefunden")
```

**Effect:** Shows how many records match current filters (helps user understand scope)

**Example:** "45 Einträge gefunden"

## Common Patterns

### Pattern 1: Status Filter Only

**Scenario:** User only wants to filter by status (no search or my items)

```powerfx
// In Gallery:
Gallery.Items: FilteredGalleryData(false, drp_Status.Value, "")

// Result: Shows all records with selected status (role/ownership still applies)
```

### Pattern 2: Status + Search

**Scenario:** User filters by status AND searches within results

```powerfx
// In Gallery:
Gallery.Items: FilteredGalleryData(false, drp_Status.Value, txt_Search.Value)

// Result: Shows records matching BOTH status AND search term
```

### Pattern 3: Status + My Items

**Scenario:** User filters by status AND shows only their own items

```powerfx
// In Gallery:
Gallery.Items: FilteredGalleryData(tog_MyItems.Value, drp_Status.Value, "")

// Result: Shows records matching BOTH status AND owner=current user
```

### Pattern 4: All Filters (Status + Search + My Items)

**Scenario:** User applies all three filters simultaneously (most complex)

```powerfx
// In Gallery:
Gallery.Items: FilteredGalleryData(tog_MyItems.Value, drp_Status.Value, txt_Search.Value)

// Result: Shows records matching ALL conditions
// Order: Filter by status first, then role, then my items, then search
```

## Advanced: Conditional Filter Visibility

Sometimes you want to show/hide filters based on user role or context:

```powerfx
// Hide "My Items" toggle if user has ViewAll permission
tog_MyItemsOnly.Visible: Not(CanViewAllData());

// Hide search box for basic users (show only status filter)
txt_Search.Visible: HasRole("Manager");
```

## Troubleshooting

### Gallery Shows No Records

**Possible causes:**
1. **Status filter too restrictive:** Item has no status or wrong status value
2. **Role filter blocking:** User doesn't have ViewAll and doesn't own items
3. **My Items toggle on:** User selected My Items but doesn't own any records
4. **Search term too specific:** No records match search term

**Debug:**
1. Check Monitor tool (F12) for delegation warnings
2. Temporarily disable filters one at a time: `Filter(Items, true)` (shows all)
3. Use lbl_RecordCount to verify matching record count
4. Check sample data: Do records actually exist that match filters?

### Gallery Is Slow

**Possible causes:**
1. **Filter order wrong:** Search applied before status (searching 500 records instead of 50)
2. **Delegation broken:** Monitor shows warnings, filtering is happening client-side
3. **Counts happening too frequently:** CountRows() called on unfiltered Items table

**Solutions:**
1. Verify filter order in FilteredGalleryData (status first, search last)
2. Check Monitor for delegation warnings
3. Move record count to variable (calculated once, not per control)
4. Consider pagination for multi-field search on very large datasets

### Toggle/Dropdown OnChange Not Firing

**Possible causes:**
1. **OnChange handler not set:** Formula bar shows nothing for OnChange
2. **Circular reference:** ActiveFilters.SelectedStatus bound to drp_Status.Value AND drp_Status.OnChange updates it
3. **Default value overwrites change:** Default property conflicts with state variable

**Solutions:**
1. Verify OnChange formula is set on each UI control
2. Use Default property for initial value, OnChange for updates (not both)
3. Use `Patch()` to update specific field in state record (not `Set()`)

## Performance Tips for Large Datasets

### Keep Page Size Small

If using pagination (Plan 03-03), keep page size around 50:
- Too small (10): User clicks too many times
- Too large (500): Gallery render time increases

### Monitor Filter Performance

Use Power Apps Monitor (F12):
1. Open app in Studio
2. Press F12 to open Monitor
3. Apply filters, watch performance metrics
4. Look for yellow delegation warnings
5. CountRows timing should be <100ms (on filtered result)

### Cache Expensive Calculations

If record count is calculated frequently, cache it in a variable:

```powerfx
// In App.OnStart or on filter change:
Set(CachedRecordCount, CountRows(FilteredGalleryData(...)));

// In label:
lbl_RecordCount.Text = Concatenate(CachedRecordCount, " Einträge gefunden")
```

## Testing Filter Compositions

### Test Scenario 1: Single Filter (Status)

1. Set status dropdown to "Active"
2. Verify Gallery shows only "Active" records
3. Change to "Pending"
4. Verify Gallery updates correctly
5. Set to blank
6. Verify Gallery shows all statuses again

### Test Scenario 2: Combined Filters (Status + Search)

1. Set status to "Active"
2. Set search to "test"
3. Verify Gallery shows records matching BOTH conditions
4. Change search to "xyz"
5. Verify Gallery updates (no records if no matches)
6. Clear search box
7. Verify Gallery shows all "Active" records again

### Test Scenario 3: All Filters

1. Enable "My Items" toggle
2. Set status to "Active"
3. Set search to "test"
4. Verify Gallery shows only records where:
   - Owner = Current User AND
   - Status = "Active" AND
   - Title/Description/Owner contains "test"
5. Click Clear All
6. Verify all filters reset and Gallery shows unfiltered records

### Test Scenario 4: Role-Based Filtering

1. Login as regular user
2. Apply filters
3. Verify only own records show (if no ViewAll permission)
4. Login as Manager
5. Apply same filters
6. Verify all matching records show (because Manager has ViewAll)

## FAQ

**Q: Can I add more filters to FilteredGalleryData?**
A: Yes! Add a Layer 5 to the Filter() call. Keep most restrictive filters first.

**Q: What if I want OR logic between status values (Status="Active" OR Status="Pending")?**
A: Modify MatchesStatusFilter to accept multiple values, or add an additional Or() condition at Layer 4.

**Q: Can I persist filter selections when user navigates away?**
A: Yes, save ActiveFilters to a collection or app settings before navigation.

**Q: How do I export filtered gallery records to Excel?**
A: Use ExportData() on FilteredGalleryData() result. See Power Apps Export documentation.

**Q: Can I default filters based on user role?**
A: Yes, in App.OnStart set default status based on HasRole() checks.

---

*Filter Composition Guide: Phase 3*
*Last updated: 2026-01-18*
