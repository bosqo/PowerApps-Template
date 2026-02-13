# Reactive Filter System Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Implement a fully reactive filter system using Named Formulas that automatically recalculate when filter state changes, eliminating manual ClearCollect operations.

**Architecture:** Three-layer declarative system: (1) Base data layers (UserScopedItems, ActiveItems, InactiveItems) provide permission-filtered views, (2) FilteredItems Named Formula combines all dropdown filters reactively, (3) Gallery.Items binds directly to FilteredItems for instant UI updates. No manual ClearCollect needed - dropdowns update ActiveFilters state, FilteredItems auto-recalculates, gallery refreshes automatically.

**Tech Stack:** Power Fx Named Formulas, ActiveFilters state variable, CachedDepartments/CachedStatuses collections, Delegation-safe Filter() expressions

---

## Prerequisites

Before starting:
- [ ] Review design doc: `docs/plans/2026-02-13-reactive-filter-system-design.md`
- [ ] Review delegation patterns: `docs/performance/DELEGATION-PATTERNS.md`
- [ ] Verify data sources connected: Items, Departments, Categories
- [ ] Verify collections exist: CachedDepartments, CachedStatuses

---

## Task 1: Update DateRanges Named Formula

**Files:**
- Modify: `src/App-Formulas-Template.fx:216-242`

**Context:** Add `Last14Days` field to existing DateRanges Named Formula. This provides a date range option for "Last 14 Days" filter.

**Step 1: Locate DateRanges Named Formula**

Open: `src/App-Formulas-Template.fx`
Find: Line 216 (search for `DateRanges = {`)
Current code:
```powerfx
DateRanges = {
    // ... existing fields ...
    Last7Days: Today() - 7,
    Last30Days: Today() - 30,
    Last90Days: Today() - 90
};
```

**Step 2: Add Last14Days field**

Insert after `Last7Days` line (~239):
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

    // Relative Ranges
    Last7Days: Today() - 7,
    Last14Days: Today() - 14,    // NEW
    Last30Days: Today() - 30,
    Last90Days: Today() - 90
};
```

**Step 3: Verify syntax in Power Apps Studio**

Action: Save file, reload app in Power Apps Studio
Expected: No formula errors, DateRanges.Last14Days = (Today - 14 days)

**Step 4: Test in Power Apps Monitor**

Action: Open Monitor (F12), check `DateRanges` Named Formula
Expected: `Last14Days` field shows date 14 days ago

**Step 5: Commit**

```bash
git add src/App-Formulas-Template.fx
git commit -m "feat(filters): add Last14Days to DateRanges Named Formula"
```

---

## Task 2: Add Base Layer Named Formulas

**Files:**
- Modify: `src/App-Formulas-Template.fx:242` (insert after DateRanges)

**Context:** Add UserScopedItems, ActiveItems, InactiveItems Named Formulas. These provide reusable base layers for galleries and dashboards.

**Step 1: Insert base layer comment header**

Location: After `DateRanges` Named Formula (line ~242)
Code:
```powerfx

// ============================================================================
// BASE DATA LAYERS (Permission-Filtered)
// ============================================================================
// Purpose: Reusable base layers for galleries and dashboards
// Depends on: UserPermissions.CanViewAll, User().Email
// Used by: FilteredItems, dashboard KPIs, multiple galleries
```

**Step 2: Add UserScopedItems Named Formula**

Insert after comment header:
```powerfx
// All items visible to current user (respects ViewAll permission)
UserScopedItems = If(
    UserPermissions.CanViewAll,
    Items,
    Filter(Items, Owner.Email = User().Email)
);
```

**Step 3: Add ActiveItems Named Formula**

Insert after UserScopedItems:
```powerfx
// Active items only (Status = "Active")
ActiveItems = Filter(UserScopedItems, Status = "Active");
```

**Step 4: Add InactiveItems Named Formula**

Insert after ActiveItems:
```powerfx
// Inactive items only (Status = "Inactive")
InactiveItems = Filter(UserScopedItems, Status = "Inactive");
```

**Step 5: Verify syntax in Power Apps Studio**

Action: Save file, reload app in Power Apps Studio
Expected: No formula errors, Named Formulas appear in autocomplete

**Step 6: Test Named Formulas in Monitor**

Action: Open Monitor (F12), evaluate each Named Formula
Expected:
- `UserScopedItems` returns Items table (filtered by permission)
- `ActiveItems` returns subset where Status = "Active"
- `InactiveItems` returns subset where Status = "Inactive"

**Step 7: Commit**

```bash
git add src/App-Formulas-Template.fx
git commit -m "feat(filters): add base layer Named Formulas (UserScopedItems, ActiveItems, InactiveItems)"
```

---

## Task 3: Add FilteredItems Named Formula

**Files:**
- Modify: `src/App-Formulas-Template.fx` (insert after base layers)

**Context:** Add FilteredItems Named Formula that reactively combines all dropdown filters. This is the core of the reactive filter system.

**Step 1: Insert dynamic filter comment header**

Location: After base layer Named Formulas
Code:
```powerfx

// ============================================================================
// DYNAMIC FILTER LAYER (Reactive to ActiveFilters state)
// ============================================================================
// Purpose: Combines all dropdown filters - fully reactive
// Depends on: ActiveFilters state (Status, Department, DateRange, SearchTerm)
// Used by: Gallery.Items property
// Delegation: All filter expressions are delegable (no UDFs inside Filter)
```

**Step 2: Add FilteredItems Named Formula**

Insert after comment header:
```powerfx
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

**Step 3: Verify syntax in Power Apps Studio**

Action: Save file, reload app in Power Apps Studio
Expected: No formula errors, FilteredItems appears in autocomplete

**Step 4: Test FilteredItems in Monitor**

Action: Open Monitor (F12), evaluate FilteredItems
Expected: Returns filtered Items table (initially all items if ActiveFilters fields are Blank())

**Step 5: Check for delegation warnings**

Action: Power Apps Studio → App Checker → Delegation warnings
Expected: No delegation warnings for FilteredItems formula

**Step 6: Commit**

```bash
git add src/App-Formulas-Template.fx
git commit -m "feat(filters): add FilteredItems Named Formula with reactive filtering"
```

---

## Task 4: Update ActiveFilters State Initialization

**Files:**
- Modify: `src/App-OnStart-Minimal.fx:188-208`

**Context:** Add Status, Department, DateRange fields to ActiveFilters state variable. Keep existing fields for backward compatibility.

**Step 1: Locate ActiveFilters initialization**

Open: `src/App-OnStart-Minimal.fx`
Find: Line 188 (search for `Set(ActiveFilters, {`)
Current code ends at line ~208

**Step 2: Add new fields to ActiveFilters**

Insert new fields at end of record (before closing `});`):
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

**Step 3: Verify syntax in Power Apps Studio**

Action: Save file, reload app in Power Apps Studio → Run App.OnStart
Expected: No errors, ActiveFilters variable initialized with new fields

**Step 4: Test ActiveFilters in Monitor**

Action: Open Monitor (F12), check ActiveFilters variable
Expected: Record shows all fields including Status, Department, DateRange (all Blank())

**Step 5: Commit**

```bash
git add src/App-OnStart-Minimal.fx
git commit -m "feat(filters): add Status, Department, DateRange fields to ActiveFilters state"
```

---

## Task 5: Create Status Dropdown Control

**Files:**
- Create: Control `drp_Status` in Power Apps Studio

**Context:** Create status dropdown that updates ActiveFilters.Status when changed. Uses CachedStatuses collection as data source.

**Step 1: Create dropdown control**

Action: Power Apps Studio → Insert → Dropdown
Name: `drp_Status`
Location: Filter panel area (left or top of screen)

**Step 2: Configure dropdown Items property**

Property: `drp_Status.Items`
Value:
```powerfx
CachedStatuses
```

**Step 3: Configure dropdown Default property**

Property: `drp_Status.Default`
Value:
```powerfx
Blank()
```

**Step 4: Configure dropdown OnChange property**

Property: `drp_Status.OnChange`
Value:
```powerfx
Set(ActiveFilters, Patch(ActiveFilters, {Status: Self.Selected.Value}))
```

**Step 5: Configure display properties**

Properties:
- `DisplayFields`: `["DisplayName"]`
- `ValueField`: `"Value"`
- `AllowEmptySelection`: `true`
- `HintText`: `"Status auswählen"`

**Step 6: Test dropdown in Play mode**

Action: Play app (F5), change dropdown value
Expected:
- Dropdown shows status options ("Aktiv", "Ausstehend", etc.)
- Selecting value updates ActiveFilters.Status
- FilteredItems recalculates automatically
- Gallery refreshes (if bound to FilteredItems)

**Step 7: Verify in Monitor**

Action: Monitor (F12) → Select dropdown → Check ActiveFilters variable
Expected: `ActiveFilters.Status` matches selected dropdown value

**Step 8: Export and commit**

Action: File → Save → Download as .msapp → Unpack
```bash
pac canvas unpack --msapp PowerApps-Template.msapp --sources ./src
git add src/
git commit -m "feat(filters): add drp_Status dropdown control"
```

---

## Task 6: Create Department Dropdown Control

**Files:**
- Create: Control `drp_Department` in Power Apps Studio

**Context:** Create department dropdown that updates ActiveFilters.Department when changed. Uses CachedDepartments collection as data source.

**Step 1: Create dropdown control**

Action: Power Apps Studio → Insert → Dropdown
Name: `drp_Department`
Location: Next to drp_Status in filter panel

**Step 2: Configure dropdown Items property**

Property: `drp_Department.Items`
Value:
```powerfx
CachedDepartments
```

**Step 3: Configure dropdown Default property**

Property: `drp_Department.Default`
Value:
```powerfx
Blank()
```

**Step 4: Configure dropdown OnChange property**

Property: `drp_Department.OnChange`
Value:
```powerfx
Set(ActiveFilters, Patch(ActiveFilters, {Department: Self.Selected.Value}))
```

**Step 5: Configure display properties**

Properties:
- `DisplayFields`: `["Name"]`
- `ValueField`: `"Name"`
- `AllowEmptySelection`: `true`
- `HintText`: `"Abteilung auswählen"`

**Step 6: Test dropdown in Play mode**

Action: Play app (F5), change dropdown value
Expected:
- Dropdown shows department options from CachedDepartments
- Selecting value updates ActiveFilters.Department
- FilteredItems recalculates automatically

**Step 7: Verify in Monitor**

Action: Monitor (F12) → Select dropdown → Check ActiveFilters variable
Expected: `ActiveFilters.Department` matches selected dropdown value

**Step 8: Export and commit**

Action: File → Save → Download as .msapp → Unpack
```bash
pac canvas unpack --msapp PowerApps-Template.msapp --sources ./src
git add src/
git commit -m "feat(filters): add drp_Department dropdown control"
```

---

## Task 7: Create Date Range Dropdown Control

**Files:**
- Create: Control `drp_DateRange` in Power Apps Studio

**Context:** Create date range dropdown that updates ActiveFilters.DateRange when changed. Uses static table with date range options.

**Step 1: Create dropdown control**

Action: Power Apps Studio → Insert → Dropdown
Name: `drp_DateRange`
Location: Next to drp_Department in filter panel

**Step 2: Configure dropdown Items property**

Property: `drp_DateRange.Items`
Value:
```powerfx
Table(
    {Value: Blank(), DisplayName: "Alle"},
    {Value: "Last7Days", DisplayName: "Letzte 7 Tage"},
    {Value: "Last14Days", DisplayName: "Letzte 14 Tage"},
    {Value: "Last30Days", DisplayName: "Letzte 30 Tage"},
    {Value: "Last90Days", DisplayName: "Letzte 90 Tage"}
)
```

**Step 3: Configure dropdown Default property**

Property: `drp_DateRange.Default`
Value:
```powerfx
Blank()
```

**Step 4: Configure dropdown OnChange property**

Property: `drp_DateRange.OnChange`
Value:
```powerfx
Set(ActiveFilters, Patch(ActiveFilters, {DateRange: Self.Selected.Value}))
```

**Step 5: Configure display properties**

Properties:
- `DisplayFields`: `["DisplayName"]`
- `ValueField`: `"Value"`
- `AllowEmptySelection`: `true`
- `HintText`: `"Zeitraum auswählen"`

**Step 6: Test dropdown in Play mode**

Action: Play app (F5), change dropdown value
Expected:
- Dropdown shows date range options ("Letzte 7 Tage", etc.)
- Selecting value updates ActiveFilters.DateRange
- FilteredItems recalculates using DateRanges[ActiveFilters.DateRange].Start

**Step 7: Verify in Monitor**

Action: Monitor (F12) → Select dropdown → Check ActiveFilters variable
Expected: `ActiveFilters.DateRange` matches selected dropdown value (e.g., "Last7Days")

**Step 8: Export and commit**

Action: File → Save → Download as .msapp → Unpack
```bash
pac canvas unpack --msapp PowerApps-Template.msapp --sources ./src
git add src/
git commit -m "feat(filters): add drp_DateRange dropdown control"
```

---

## Task 8: Create Search Text Input Control

**Files:**
- Create: Control `txt_SearchName` in Power Apps Studio

**Context:** Create text input for searching by display name. Uses DelayedOnChange to avoid filtering on every keystroke.

**Step 1: Create text input control**

Action: Power Apps Studio → Insert → Text input
Name: `txt_SearchName`
Location: Next to dropdowns in filter panel

**Step 2: Configure text input Default property**

Property: `txt_SearchName.Default`
Value:
```powerfx
""
```

**Step 3: Configure text input DelayedOnChange property**

Property: `txt_SearchName.DelayedOnChange`
Value:
```powerfx
Set(ActiveFilters, Patch(ActiveFilters, {SearchTerm: Self.Text}))
```

**Step 4: Configure display properties**

Properties:
- `HintText`: `"Nach Name suchen..."`
- `Mode`: `TextMode.SingleLine`
- `DelayOutput`: `true`
- `DelayedOutputTime`: `500` (500ms delay)

**Step 5: Test text input in Play mode**

Action: Play app (F5), type in text input
Expected:
- After 500ms delay, ActiveFilters.SearchTerm updates
- FilteredItems recalculates using StartsWith(Title, ActiveFilters.SearchTerm)
- Gallery shows matching items

**Step 6: Verify in Monitor**

Action: Monitor (F12) → Type text → Wait 500ms → Check ActiveFilters variable
Expected: `ActiveFilters.SearchTerm` matches typed text (after delay)

**Step 7: Export and commit**

Action: File → Save → Download as .msapp → Unpack
```bash
pac canvas unpack --msapp PowerApps-Template.msapp --sources ./src
git add src/
git commit -m "feat(filters): add txt_SearchName text input control with delayed filtering"
```

---

## Task 9: Update Gallery Items Binding

**Files:**
- Modify: Control `glr_Items` in Power Apps Studio

**Context:** Change gallery Items property from manual collection to reactive FilteredItems Named Formula. This enables instant filter updates without ClearCollect.

**Step 1: Locate gallery control**

Action: Power Apps Studio → Tree view → Find `glr_Items` (or main gallery)

**Step 2: Check current Items property**

Property: `glr_Items.Items`
Current value (might be):
```powerfx
FilteredCollection
// OR
Filter(Items, /* some filter logic */)
```

**Step 3: Update Items property to use FilteredItems**

Property: `glr_Items.Items`
New value:
```powerfx
FilteredItems
```

**Step 4: Remove old ClearCollect code (if exists)**

Action: Search app for `ClearCollect(FilteredCollection,`
If found: Delete those ClearCollect calls and any "Apply Filters" button

**Step 5: Test gallery in Play mode**

Action: Play app (F5)
Expected:
- Gallery shows all items initially (all filters Blank())
- Changing any dropdown → Gallery refreshes instantly
- No button click needed

**Step 6: Test combined filters**

Action: Set drp_Status = "Active", drp_Department = "Sales"
Expected: Gallery shows only Active items in Sales department

**Step 7: Verify delegation in App Checker**

Action: App Checker (Alt+Shift+F10) → Check delegation warnings
Expected: No delegation warnings for FilteredItems

**Step 8: Export and commit**

Action: File → Save → Download as .msapp → Unpack
```bash
pac canvas unpack --msapp PowerApps-Template.msapp --sources ./src
git add src/
git commit -m "feat(filters): bind gallery to reactive FilteredItems Named Formula"
```

---

## Task 10: Create Reset Filters Button

**Files:**
- Create: Control `btn_ResetFilters` in Power Apps Studio

**Context:** Create button that resets all filter dropdowns to "All" (Blank() state). This provides easy way to clear all filters.

**Step 1: Create button control**

Action: Power Apps Studio → Insert → Button
Name: `btn_ResetFilters`
Location: Below filter dropdowns

**Step 2: Configure button Text property**

Property: `btn_ResetFilters.Text`
Value:
```powerfx
"Filter zurücksetzen"
```

**Step 3: Configure button OnSelect property**

Property: `btn_ResetFilters.OnSelect`
Value:
```powerfx
Set(ActiveFilters, Patch(ActiveFilters, {
    Status: Blank(),
    Department: Blank(),
    DateRange: Blank(),
    SearchTerm: ""
}))
```

**Step 4: Configure button styling**

Properties:
- `Fill`: `ThemeColors.NeutralGray`
- `HoverFill`: `GetHoverColor(ThemeColors.NeutralGray)`
- `PressedFill`: `GetPressedColor(ThemeColors.NeutralGray)`
- `Color`: `ThemeColors.Text`

**Step 5: Test button in Play mode**

Action: Play app (F5)
1. Set multiple filters (status, department, date range, search)
2. Click "Filter zurücksetzen" button

Expected:
- All dropdowns reset to Blank() / "Alle"
- Text input clears
- Gallery shows all items (no filters applied)

**Step 6: Verify in Monitor**

Action: Monitor (F12) → Click button → Check ActiveFilters variable
Expected: All filter fields (Status, Department, DateRange, SearchTerm) reset to Blank() or ""

**Step 7: Export and commit**

Action: File → Save → Download as .msapp → Unpack
```bash
pac canvas unpack --msapp PowerApps-Template.msapp --sources ./src
git add src/
git commit -m "feat(filters): add reset filters button"
```

---

## Task 11: Integration Testing

**Files:**
- Create: `docs/testing/reactive-filter-system-tests.md`

**Context:** Comprehensive testing of all filter combinations and edge cases. Verify reactive behavior and delegation safety.

**Step 1: Create test documentation file**

File: `docs/testing/reactive-filter-system-tests.md`
Content:
```markdown
# Reactive Filter System - Integration Tests

**Date:** 2026-02-13
**Feature:** Reactive filter system with Named Formulas

---

## Test 1: Single Filter (Status)

**Steps:**
1. Reset all filters
2. Set drp_Status to "Active"

**Expected:**
- Gallery shows only items where Status = "Active"
- FilteredItems recalculates automatically
- No delay or manual refresh needed

**Actual:** [PASS/FAIL]

---

## Test 2: Single Filter (Department)

**Steps:**
1. Reset all filters
2. Set drp_Department to "Sales"

**Expected:**
- Gallery shows only items where Department = "Sales"
- FilteredItems recalculates automatically

**Actual:** [PASS/FAIL]

---

## Test 3: Single Filter (Date Range)

**Steps:**
1. Reset all filters
2. Set drp_DateRange to "Last7Days"

**Expected:**
- Gallery shows only items modified in last 7 days
- FilteredItems uses DateRanges.Last7Days correctly

**Actual:** [PASS/FAIL]

---

## Test 4: Single Filter (Search)

**Steps:**
1. Reset all filters
2. Type "Test" in txt_SearchName

**Expected:**
- After 500ms delay, gallery shows items where Title starts with "Test"
- FilteredItems uses StartsWith() correctly

**Actual:** [PASS/FAIL]

---

## Test 5: Combined Filters (Status + Department)

**Steps:**
1. Reset all filters
2. Set drp_Status to "Active"
3. Set drp_Department to "Sales"

**Expected:**
- Gallery shows items where Status = "Active" AND Department = "Sales"
- Both filters applied correctly

**Actual:** [PASS/FAIL]

---

## Test 6: Combined Filters (All Four)

**Steps:**
1. Reset all filters
2. Set drp_Status to "Active"
3. Set drp_Department to "Sales"
4. Set drp_DateRange to "Last30Days"
5. Type "Project" in txt_SearchName

**Expected:**
- Gallery shows items matching ALL four filters
- No delegation warnings
- Query completes in <1 second

**Actual:** [PASS/FAIL]

---

## Test 7: Reset Filters Button

**Steps:**
1. Apply multiple filters (status, department, date, search)
2. Click btn_ResetFilters

**Expected:**
- All dropdowns reset to Blank() / "Alle"
- Text input clears
- Gallery shows all items

**Actual:** [PASS/FAIL]

---

## Test 8: Blank() = "All" Logic

**Steps:**
1. Set all dropdowns to Blank() (select "Alle" if available)
2. Clear text input

**Expected:**
- Gallery shows all items (no filters applied)
- FilteredItems returns same as UserScopedItems

**Actual:** [PASS/FAIL]

---

## Test 9: Delegation Check (<2000 records)

**Steps:**
1. Open App Checker (Alt+Shift+F10)
2. Check for delegation warnings

**Expected:**
- No delegation warnings for FilteredItems formula
- All Filter expressions are delegable

**Actual:** [PASS/FAIL]

---

## Test 10: Performance Check

**Steps:**
1. Open Monitor (F12)
2. Change dropdown filter
3. Measure FilteredItems recalculation time

**Expected:**
- Recalculation completes in <100ms
- No network calls (uses cached data)

**Actual:** [PASS/FAIL]

---

## Test 11: Permission Scoping (ViewAll)

**Steps:**
1. Test with Admin user (ViewAll permission)
2. Set filters

**Expected:**
- UserScopedItems returns all Items
- Filters apply to all items

**Actual:** [PASS/FAIL]

---

## Test 12: Permission Scoping (Own Items Only)

**Steps:**
1. Test with regular User (no ViewAll permission)
2. Set filters

**Expected:**
- UserScopedItems returns only items where Owner.Email = User().Email
- Filters apply only to own items

**Actual:** [PASS/FAIL]

---

## Test 13: Edge Case - Empty Results

**Steps:**
1. Set filters that match no items (e.g., Status = "Archived", Department = "NonExistent")

**Expected:**
- Gallery shows empty state
- No errors or crashes
- FilteredItems returns empty table

**Actual:** [PASS/FAIL]

---

## Test 14: Edge Case - Missing Data Source

**Steps:**
1. Disconnect CachedDepartments collection (simulate load failure)
2. Try to use drp_Department

**Expected:**
- Dropdown shows empty or fallback state
- App doesn't crash
- Other filters continue working

**Actual:** [PASS/FAIL]

---

## Summary

**Total Tests:** 14
**Passed:** [X]
**Failed:** [X]
**Skipped:** [X]

**Notes:**
[Add any additional observations or issues found during testing]
```

**Step 2: Execute Test 1 - Single Filter (Status)**

Action: Play app, reset filters, set drp_Status to "Active"
Result: Record PASS/FAIL in test doc

**Step 3: Execute Test 2 - Single Filter (Department)**

Action: Play app, reset filters, set drp_Department to "Sales"
Result: Record PASS/FAIL in test doc

**Step 4: Execute Test 3 - Single Filter (Date Range)**

Action: Play app, reset filters, set drp_DateRange to "Last7Days"
Result: Record PASS/FAIL in test doc

**Step 5: Execute Test 4 - Single Filter (Search)**

Action: Play app, reset filters, type "Test" in txt_SearchName
Result: Record PASS/FAIL in test doc

**Step 6: Execute Test 5 - Combined Filters (Status + Department)**

Action: Play app, set both drp_Status and drp_Department
Result: Record PASS/FAIL in test doc

**Step 7: Execute Test 6 - Combined Filters (All Four)**

Action: Play app, set all four filters
Result: Record PASS/FAIL in test doc

**Step 8: Execute Test 7 - Reset Filters Button**

Action: Apply filters, click btn_ResetFilters
Result: Record PASS/FAIL in test doc

**Step 9: Execute Test 8 - Blank() = "All" Logic**

Action: Set all dropdowns to Blank()
Result: Record PASS/FAIL in test doc

**Step 10: Execute Test 9 - Delegation Check**

Action: Open App Checker, check delegation warnings
Result: Record PASS/FAIL in test doc

**Step 11: Execute Test 10 - Performance Check**

Action: Open Monitor, measure recalculation time
Result: Record PASS/FAIL in test doc

**Step 12: Execute Test 11 - Permission Scoping (ViewAll)**

Action: Test with Admin user
Result: Record PASS/FAIL in test doc

**Step 13: Execute Test 12 - Permission Scoping (Own Items Only)**

Action: Test with regular User
Result: Record PASS/FAIL in test doc

**Step 14: Execute Test 13 - Edge Case (Empty Results)**

Action: Set filters that match no items
Result: Record PASS/FAIL in test doc

**Step 15: Execute Test 14 - Edge Case (Missing Data Source)**

Action: Simulate CachedDepartments failure
Result: Record PASS/FAIL in test doc

**Step 16: Update test summary**

Action: Count PASS/FAIL/SKIPPED, add notes
File: `docs/testing/reactive-filter-system-tests.md`

**Step 17: Commit test results**

```bash
git add docs/testing/reactive-filter-system-tests.md
git commit -m "test(filters): add integration test results for reactive filter system"
```

---

## Task 12: Update Documentation

**Files:**
- Modify: `docs/reference/UDF-REFERENCE.md` (add FilteredItems reference)
- Modify: `CLAUDE.md` (add reactive filter pattern)

**Context:** Update documentation to reflect new reactive filter system and Named Formulas.

**Step 1: Add FilteredItems to UDF-REFERENCE.md**

File: `docs/reference/UDF-REFERENCE.md`
Location: Add new section after existing Named Formulas

Content:
```markdown
## Named Formulas - Data Layers

### UserScopedItems

**Type:** Table (Items)
**Purpose:** Permission-filtered view of Items table
**Returns:** All items if user has ViewAll permission, otherwise only user's own items

**Formula:**
```powerfx
UserScopedItems = If(
    UserPermissions.CanViewAll,
    Items,
    Filter(Items, Owner.Email = User().Email)
);
```

**Usage:**
```powerfx
// Use in galleries
glr_AllItems.Items = UserScopedItems

// Use in calculations
CountRows(UserScopedItems)
```

---

### ActiveItems

**Type:** Table (Items)
**Purpose:** Active items only (Status = "Active")
**Returns:** Subset of UserScopedItems where Status = "Active"

**Formula:**
```powerfx
ActiveItems = Filter(UserScopedItems, Status = "Active");
```

**Usage:**
```powerfx
// Dashboard count
lbl_ActiveCount.Text = CountRows(ActiveItems)

// Gallery
glr_ActiveItems.Items = ActiveItems
```

---

### InactiveItems

**Type:** Table (Items)
**Purpose:** Inactive items only (Status = "Inactive")
**Returns:** Subset of UserScopedItems where Status = "Inactive"

**Formula:**
```powerfx
InactiveItems = Filter(UserScopedItems, Status = "Inactive");
```

**Usage:**
```powerfx
// Archive screen
glr_Archive.Items = InactiveItems
```

---

### FilteredItems

**Type:** Table (Items)
**Purpose:** Reactive multi-filter combination
**Returns:** UserScopedItems filtered by Status, Department, DateRange, SearchTerm
**Delegation:** All expressions are delegable (no UDFs inside Filter)

**Formula:**
```powerfx
FilteredItems = Filter(
    UserScopedItems,
    (IsBlank(ActiveFilters.Status) || Status = ActiveFilters.Status) &&
    (IsBlank(ActiveFilters.Department) || Department = ActiveFilters.Department) &&
    (IsBlank(ActiveFilters.DateRange) || 'Modified On' >= DateRanges[ActiveFilters.DateRange].Start) &&
    (IsBlank(ActiveFilters.SearchTerm) || StartsWith(Title, ActiveFilters.SearchTerm))
);
```

**Usage:**
```powerfx
// Gallery binding
glr_Items.Items = FilteredItems

// Count
lbl_Count.Text = CountRows(FilteredItems)
```

**Key Features:**
- ✅ Reactive: Auto-recalculates when ActiveFilters changes
- ✅ Delegable: All Filter expressions are SharePoint-compatible
- ✅ Composable: Combines all dropdown filters in one place
- ✅ No ClearCollect needed: Gallery refreshes automatically

---
```

**Step 2: Add reactive filter pattern to CLAUDE.md**

File: `CLAUDE.md`
Location: After "## 35+ UDFs Reference" section

Content:
```markdown
## Reactive Filter Pattern (Named Formulas)

**Pattern:** Dropdown changes → ActiveFilters state → FilteredItems recalculates → Gallery refreshes

**Architecture:**
```powerfx
// Layer 1: Base data (permission-filtered)
UserScopedItems = If(UserPermissions.CanViewAll, Items, Filter(Items, Owner.Email = User().Email));

// Layer 2: Dynamic filter (reactive)
FilteredItems = Filter(
    UserScopedItems,
    (IsBlank(ActiveFilters.Status) || Status = ActiveFilters.Status) &&
    (IsBlank(ActiveFilters.Department) || Department = ActiveFilters.Department)
);

// Layer 3: UI binding
glr_Items.Items = FilteredItems  // Auto-refreshes when FilteredItems changes
```

**Dropdown setup:**
```powerfx
// Status dropdown OnChange
drp_Status.OnChange = Set(ActiveFilters, Patch(ActiveFilters, {Status: Self.Selected.Value}));

// Gallery items (no ClearCollect needed)
glr_Items.Items = FilteredItems
```

**Benefits:**
- ✅ Zero manual ClearCollect calls
- ✅ Instant reactivity (no "Apply Filters" button)
- ✅ Delegation-safe (all inline expressions)
- ✅ Single source of truth (FilteredItems formula)

**Reference:** See `docs/plans/2026-02-13-reactive-filter-system-design.md`
```

**Step 3: Verify documentation formatting**

Action: Read both files, check markdown syntax
Expected: No broken links, proper code blocks, consistent formatting

**Step 4: Commit documentation updates**

```bash
git add docs/reference/UDF-REFERENCE.md CLAUDE.md
git commit -m "docs(filters): add reactive filter pattern and Named Formulas reference"
```

---

## Task 13: Final Verification and Cleanup

**Files:**
- Review: All modified files
- Verify: No leftover TODO comments or debug code

**Context:** Final checks before marking feature complete.

**Step 1: Review all git changes**

```bash
git log --oneline --since="1 day ago"
git diff main...HEAD --stat
```

Expected commits:
1. feat(filters): add Last14Days to DateRanges Named Formula
2. feat(filters): add base layer Named Formulas (UserScopedItems, ActiveItems, InactiveItems)
3. feat(filters): add FilteredItems Named Formula with reactive filtering
4. feat(filters): add Status, Department, DateRange fields to ActiveFilters state
5. feat(filters): add drp_Status dropdown control
6. feat(filters): add drp_Department dropdown control
7. feat(filters): add drp_DateRange dropdown control
8. feat(filters): add txt_SearchName text input control with delayed filtering
9. feat(filters): bind gallery to reactive FilteredItems Named Formula
10. feat(filters): add reset filters button
11. test(filters): add integration test results for reactive filter system
12. docs(filters): add reactive filter pattern and Named Formulas reference

**Step 2: Check for TODO comments**

```bash
grep -r "TODO\|FIXME\|HACK" src/
```

Expected: No results (or only pre-existing TODOs unrelated to this feature)

**Step 3: Check for debug code**

Action: Review App-Formulas-Template.fx and App-OnStart-Minimal.fx
Look for: Console.log, Notify() for debugging, commented-out code
Expected: Clean code, no debug artifacts

**Step 4: Verify all files compile**

Action: Power Apps Studio → File → Save → Check for errors
Expected: No formula errors, app saves successfully

**Step 5: Run final smoke test**

Action: Play app (F5)
1. Reset filters
2. Set each dropdown individually
3. Set all dropdowns together
4. Reset filters
5. Search by name

Expected: All filters work, gallery refreshes instantly, no errors

**Step 6: Create final commit (if cleanup needed)**

```bash
git add .
git commit -m "chore(filters): final cleanup and verification"
```

**Step 7: Push to remote branch**

```bash
git push -u origin claude/fix-isblank-delegation-nycuP
```

Expected: Push succeeds, branch available for PR

---

## Completion Checklist

- [ ] All 13 tasks completed
- [ ] All commits pushed to remote
- [ ] Integration tests passed (14/14)
- [ ] Documentation updated
- [ ] No delegation warnings
- [ ] No formula errors
- [ ] Smoke test passed

---

## References

- Design doc: `docs/plans/2026-02-13-reactive-filter-system-design.md`
- UDF reference: `docs/reference/UDF-REFERENCE.md`
- Delegation patterns: `docs/performance/DELEGATION-PATTERNS.md`
- CLAUDE.md: Project documentation
