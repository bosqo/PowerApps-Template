# Reactive Filter UI Controls Implementation Guide

**Date:** 2026-02-13
**Status:** Implementation Guide
**Framework:** Power Apps Canvas App (Power Fx)
**Localization:** German (Deutsch) | Timezone: CET | Date Format: d.m.yyyy

---

## Overview

This guide provides step-by-step instructions for implementing the six UI controls that enable reactive filtering in Power Apps. These controls work together with the `ActiveFilters` state variable and `FilteredItems` Named Formula to provide instant, automatic filtering without manual button clicks.

### What You'll Build

| Control | Type | Purpose |
|---------|------|---------|
| `drp_Status` | Dropdown | Filter items by status (Active, Inactive, etc.) |
| `drp_Department` | Dropdown | Filter items by department (Sales, HR, etc.) |
| `drp_DateRange` | Dropdown | Filter items by date range (Last 7/14/30/90 days) |
| `txt_SearchName` | TextInput | Search items by title/name |
| `glr_Items` | Gallery | Display filtered items (bind to FilteredItems) |
| `btn_ResetFilters` | Button | Reset all filters to default state |

### How It Works

```
User changes control
  ↓
Control's OnChange handler fires
  ↓
Updates ActiveFilters state variable
  ↓
FilteredItems Named Formula auto-recalculates
  ↓
Gallery.Items automatically refreshes
```

---

## Prerequisites

Before implementing these controls, ensure:

- [ ] `ActiveFilters` state variable initialized in `App.OnStart` with fields: `Status`, `Department`, `DateRange`, `SearchTerm`
- [ ] `FilteredItems` Named Formula created in `App.Formulas`
- [ ] `DateRanges` Named Formula includes `Last14Days` field
- [ ] `CachedStatuses` collection populated with status values
- [ ] `CachedDepartments` collection populated with department values
- [ ] Main gallery control (`glr_Items`) exists on the screen
- [ ] Power Apps Studio open with app in edit mode

### Verify Prerequisites

In Power Apps Studio:

1. **Check ActiveFilters:** View → App → Formulas → Search for `ActiveFilters`
   - Should have fields: `Status`, `Department`, `DateRange`, `SearchTerm`

2. **Check FilteredItems:** View → App → Formulas → Search for `FilteredItems`
   - Should be a Named Formula returning a Table

3. **Check DateRanges:** View → App → Formulas → Search for `DateRanges`
   - Should have `Last14Days` field

4. **Check collections:** In formula bar, type `CachedStatuses` and `CachedDepartments`
   - Both should return data tables

---

## Task 5: Create drp_Status Dropdown Control

### Overview

Creates a dropdown list for filtering items by status. Users select a status value to restrict the gallery to items matching that status.

### Step 1: Insert Dropdown Control

**Action:** Power Apps Studio → Insert menu → Dropdown
**Name:** `drp_Status`
**Location:** Place in filter panel area (top or left of gallery)

### Step 2: Configure Items Property

**Property:** `drp_Status.Items`

**Formula:**
```powerfx
CachedStatuses
```

**What it does:** Populates dropdown with status values from `CachedStatuses` collection. Each row is an option the user can select.

**Verify:**
- [ ] Formula bar shows `CachedStatuses`
- [ ] No syntax errors
- [ ] Dropdown shows status options when clicked (in preview/play mode)

### Step 3: Configure Default Property

**Property:** `drp_Status.Default`

**Formula:**
```powerfx
Blank()
```

**What it does:** Sets initial value to empty (meaning "show all statuses"). Users see "All" option by default.

**Verify:**
- [ ] Dropdown shows empty/blank initially
- [ ] Selecting an option works correctly

### Step 4: Configure OnChange Handler

**Property:** `drp_Status.OnChange`

**Formula:**
```powerfx
Set(ActiveFilters, Patch(ActiveFilters, {Status: Self.Selected.Value}))
```

**What it does:**
1. User selects a status from dropdown
2. `OnChange` fires automatically
3. `Patch()` updates the `Status` field in `ActiveFilters` record
4. `FilteredItems` Named Formula sees the change and recalculates
5. Gallery automatically refreshes

**Important:** Use `Self.Selected.Value` (not `Self.Value`) to get the actual selected value.

**Verify:**
- [ ] Formula bar shows the Patch formula
- [ ] No syntax errors
- [ ] Test by selecting different options → verify gallery updates

### Step 5: Configure Display Properties

Set these properties for better user experience:

| Property | Value | Purpose |
|----------|-------|---------|
| `DisplayFields` | `["DisplayName"]` or `["Value"]` | Which field to show in dropdown |
| `ValueField` | `"Value"` | Field to use as the actual value |
| `AllowEmptySelection` | `true` | Allow user to clear selection (shows "All") |
| `HintText` | `"Status auswählen"` | Placeholder text when empty |

**Implementation:**

In Power Apps Studio:
1. Select `drp_Status` dropdown
2. In properties panel (right side):
   - Set `DisplayFields` to match your data structure
   - Set `ValueField` to the field containing the actual status value
   - Set `AllowEmptySelection` to `true`
   - Set `HintText` to `"Status auswählen"`

### Step 6: Test the Dropdown

**Test scenario:**

1. **Play the app** (F5)
2. **Click dropdown** → Verify status options appear
3. **Select "Active"** → Verify:
   - Dropdown shows selected value
   - Gallery refreshes (if already bound to `FilteredItems`)
   - Only active items displayed
4. **Select different option** → Verify gallery updates instantly
5. **Clear selection** → Verify gallery shows all items again

**Monitor performance:**

Open Monitor tool (F12) and:
1. Select a status from dropdown
2. Watch Network tab → Should see 0 calls (no refresh needed, uses cached data)
3. Check `ActiveFilters.Status` value → Should match selected option

---

## Task 6: Create drp_Department Dropdown Control

### Overview

Creates a dropdown list for filtering items by department. Works identically to the status dropdown but filters on the Department field.

### Step 1: Insert Dropdown Control

**Action:** Power Apps Studio → Insert menu → Dropdown
**Name:** `drp_Department`
**Location:** Next to `drp_Status` in filter panel

### Step 2: Configure Items Property

**Property:** `drp_Department.Items`

**Formula:**
```powerfx
CachedDepartments
```

**What it does:** Populates dropdown with department values from `CachedDepartments` collection.

### Step 3: Configure Default Property

**Property:** `drp_Department.Default`

**Formula:**
```powerfx
Blank()
```

**What it does:** Sets initial value to empty (meaning "show all departments").

### Step 4: Configure OnChange Handler

**Property:** `drp_Department.OnChange`

**Formula:**
```powerfx
Set(ActiveFilters, Patch(ActiveFilters, {Department: Self.Selected.Value}))
```

**What it does:** Updates `ActiveFilters.Department` when user selects a department.

### Step 5: Configure Display Properties

| Property | Value |
|----------|-------|
| `DisplayFields` | `["Name"]` or `["DisplayName"]` |
| `ValueField` | `"Name"` or appropriate field |
| `AllowEmptySelection` | `true` |
| `HintText` | `"Abteilung auswählen"` |

### Step 6: Test the Dropdown

**Test scenario:**

1. **Play the app** (F5)
2. **Click dropdown** → Verify department options appear
3. **Select "Sales"** → Verify:
   - Only items in Sales department displayed
   - Gallery updates instantly
4. **Change to "HR"** → Verify gallery shows HR items
5. **Combine with status filter**:
   - Set `drp_Status` to "Active"
   - Set `drp_Department` to "Sales"
   - Gallery should show: Active items in Sales department only

---

## Task 7: Create drp_DateRange Dropdown Control

### Overview

Creates a dropdown list for filtering items by date range. Options include "Last 7 Days", "Last 14 Days", etc., allowing users to quickly filter recent items.

### Step 1: Insert Dropdown Control

**Action:** Power Apps Studio → Insert menu → Dropdown
**Name:** `drp_DateRange`
**Location:** Next to `drp_Department` in filter panel

### Step 2: Configure Items Property

**Property:** `drp_DateRange.Items`

**Formula:**
```powerfx
Table(
    {Value: Blank(), DisplayName: "Alle"},
    {Value: "Last7Days", DisplayName: "Letzte 7 Tage"},
    {Value: "Last14Days", DisplayName: "Letzte 14 Tage"},
    {Value: "Last30Days", DisplayName: "Letzte 30 Tage"},
    {Value: "Last90Days", DisplayName: "Letzte 90 Tage"}
)
```

**What it does:**
- Creates a static table with date range options
- `Value` column contains the key used in `DateRanges` Named Formula
- `DisplayName` column shows friendly text to user (in German)
- First row has `Blank()` value = "All" option

**Important:** The `Value` fields must match keys in your `DateRanges` Named Formula (e.g., "Last7Days", "Last14Days").

### Step 3: Configure Default Property

**Property:** `drp_DateRange.Default`

**Formula:**
```powerfx
Blank()
```

**What it does:** Sets initial value to "Alle" (all dates, no filter).

### Step 4: Configure OnChange Handler

**Property:** `drp_DateRange.OnChange`

**Formula:**
```powerfx
Set(ActiveFilters, Patch(ActiveFilters, {DateRange: Self.Selected.Value}))
```

**What it does:** Updates `ActiveFilters.DateRange` when user selects a date range.

**How it works in FilteredItems:**

In your `FilteredItems` Named Formula, this filter line uses the selected value:
```powerfx
(IsBlank(ActiveFilters.DateRange) || 'Modified On' >= DateRanges[ActiveFilters.DateRange].Start)
```

Explanation:
- If `ActiveFilters.DateRange` is blank → shows all items (no date filter)
- If `ActiveFilters.DateRange` = "Last7Days" → shows items modified >= 7 days ago
- Looks up the date value from `DateRanges["Last7Days"].Start`

### Step 5: Configure Display Properties

| Property | Value |
|----------|-------|
| `DisplayFields` | `["DisplayName"]` |
| `ValueField` | `"Value"` |
| `AllowEmptySelection` | `true` |
| `HintText` | `"Zeitraum auswählen"` |

### Step 6: Test the Dropdown

**Test scenario:**

1. **Play the app** (F5)
2. **Click dropdown** → Verify options appear:
   - Alle (all)
   - Letzte 7 Tage
   - Letzte 14 Tage
   - Letzte 30 Tage
   - Letzte 90 Tage

3. **Select "Letzte 7 Tage"** → Verify:
   - Only items modified in last 7 days displayed
   - Gallery updates instantly
   - Gallery shows fewer items than "Alle"

4. **Select "Letzte 30 Tage"** → Verify:
   - More items appear (includes items from last 30 days)
   - Update is instant

5. **Combine all three filters:**
   - Set `drp_Status` to "Active"
   - Set `drp_Department` to "Sales"
   - Set `drp_DateRange` to "Letzte 7 Tage"
   - Gallery should show: Active Sales items modified in last 7 days

---

## Task 8: Create txt_SearchName Text Input Control

### Overview

Creates a text input field for searching items by name/title. Uses `DelayedOnChange` to avoid filtering on every keystroke, improving performance.

### Step 1: Insert Text Input Control

**Action:** Power Apps Studio → Insert menu → Text input
**Name:** `txt_SearchName`
**Location:** Next to dropdowns in filter panel

### Step 2: Configure Default Property

**Property:** `txt_SearchName.Default`

**Formula:**
```powerfx
""
```

**What it does:** Initializes text input to empty string (no search).

### Step 3: Configure DelayedOnChange Handler

**Property:** `txt_SearchName.DelayedOnChange`

**Formula:**
```powerfx
Set(ActiveFilters, Patch(ActiveFilters, {SearchTerm: Self.Text}))
```

**What it does:**
- Waits 500ms after user stops typing (configurable)
- Then updates `ActiveFilters.SearchTerm`
- `FilteredItems` recalculates using `StartsWith()` match

**Why DelayedOnChange?**
- Avoids filtering on every keystroke (e.g., user types "Project" triggers filter 7 times)
- Reduces performance load and API calls
- Better user experience (no flickering results)

**Alternative: OnChange**

If you prefer instant filtering (less reliable for performance):
```powerfx
Set(ActiveFilters, Patch(ActiveFilters, {SearchTerm: Self.Text}))
```

### Step 4: Configure Display Properties

| Property | Value | Purpose |
|----------|-------|---------|
| `HintText` | `"Nach Name suchen..."` | Placeholder text |
| `Mode` | `TextMode.SingleLine` | Single line input (not multiline) |
| `DelayOutput` | `true` | Enable delayed output |
| `DelayedOutputTime` | `500` | Wait 500ms before triggering OnChange |

**Setting DelayedOutputTime in Studio:**

1. Select `txt_SearchName` control
2. Properties panel (right) → Advanced
3. Find `DelayedOutputTime` → Set to `500` (milliseconds)

### Step 5: How FilteredItems Uses SearchTerm

In your `FilteredItems` Named Formula, the search filter is:

```powerfx
(IsBlank(ActiveFilters.SearchTerm) || StartsWith(Title, ActiveFilters.SearchTerm))
```

**Explanation:**
- If `ActiveFilters.SearchTerm` is blank → shows all items (no search filter)
- If user typed "Project" → shows items where Title starts with "Project"
- Uses `StartsWith()` (delegable) not `Search()` (not delegable with SharePoint)

**Important:** This is case-insensitive and searches from the start of the Title field.

### Step 6: Test the Text Input

**Test scenario:**

1. **Play the app** (F5)
2. **Type in search box:** "Test"
   - Wait 500ms (or watch for update)
   - Gallery updates to show items starting with "Test"

3. **Continue typing:** "TestItem"
   - Gallery filters to items starting with "TestItem"

4. **Delete text** → Gallery reverts to showing all items (or applies other filters)

5. **Combine with dropdowns:**
   - Set `drp_Status` to "Active"
   - Type "Project" in search
   - Gallery shows: Active items where Title starts with "Project"

6. **Empty search field:**
   - Clear text → Gallery shows all Active items (search filter removed)

---

## Task 9: Update Gallery.Items Binding

### Overview

Changes the gallery to bind directly to the `FilteredItems` Named Formula, enabling reactive filtering. This replaces any manual `ClearCollect()` patterns.

### Step 1: Locate Gallery Control

**Action:**
1. Power Apps Studio → Tree view (left panel)
2. Find main gallery control (likely named `glr_Items` or similar)
3. Click to select it

### Step 2: Check Current Items Property

**Action:** Select gallery → Look at formula bar
**Current formula might be:**
- `FilteredCollection` (manual collection)
- A `Filter()` formula (manual inline)
- Something else

### Step 3: Update Items to Use FilteredItems

**Property:** `Gallery.Items`

**Old formula (example):**
```powerfx
FilteredCollection
```

**New formula:**
```powerfx
FilteredItems
```

**Implementation:**
1. Click on gallery control
2. Click formula bar
3. Clear current formula
4. Type: `FilteredItems`
5. Press Enter
6. Save app

### Step 4: Remove Old Manual Filter Code

**Search for and delete:**

1. Any `ClearCollect(FilteredCollection,` statements
   - Usually in button OnSelect handlers
   - No longer needed with reactive filtering

2. "Apply Filters" button (if it exists)
   - No longer needed - filters apply instantly

3. Any manual refresh code

**How to find:**

In Power Apps Studio:
1. Edit → Find and replace (Ctrl+H)
2. Search for: `ClearCollect(FilteredCollection`
3. Replace with: (leave blank)
4. Click Replace All

### Step 5: Verify Delegation Safety

**Action:** Power Apps Studio → Checker (Alt+Shift+F10)

**Expected:** No delegation warnings for `FilteredItems` formula

**If you see warnings:**
1. Click on warning details
2. Check what's non-delegable
3. Verify `FilteredItems` formula uses only delegable expressions:
   - ✅ `Status = Value` (delegable)
   - ✅ `Department = Value` (delegable)
   - ✅ `StartsWith(Title, text)` (delegable)
   - ❌ `Search(Title, text)` (not delegable)
   - ❌ `MatchesSearchTerm(...)` (UDFs not delegable)

### Step 6: Test Reactive Binding

**Test scenario:**

1. **Play the app** (F5)
2. **Initial state:** Gallery shows all items (all filters blank)
3. **Change status dropdown:**
   - Select "Active"
   - Gallery updates instantly (no button click needed)
   - Verify only active items shown

4. **Change multiple filters together:**
   - Set `drp_Status` to "Active"
   - Set `drp_Department` to "Sales"
   - Type "Project" in search
   - Gallery shows combined filtered results
   - All updates are instant

5. **Reset filters:**
   - Click `btn_ResetFilters` (if created)
   - Gallery returns to showing all items
   - Verify no ClearCollect delays

6. **Performance check:**
   - Open Monitor (F12)
   - Change filters multiple times
   - Watch Network tab → Should see 0 calls
   - Changes are all client-side, no API latency

---

## Task 10: Create btn_ResetFilters Button

### Overview

Creates a button that instantly resets all filters to their default state, allowing users to easily clear all applied filters and start over.

### Step 1: Insert Button Control

**Action:** Power Apps Studio → Insert menu → Button
**Name:** `btn_ResetFilters`
**Location:** Below filter controls (filter panel)

### Step 2: Configure Text Property

**Property:** `btn_ResetFilters.Text`

**Formula:**
```powerfx
"Filter zurücksetzen"
```

**What it does:** Button label in German ("Reset filters")

### Step 3: Configure OnSelect Handler

**Property:** `btn_ResetFilters.OnSelect`

**Formula:**
```powerfx
Set(ActiveFilters, Patch(ActiveFilters, {
    Status: Blank(),
    Department: Blank(),
    DateRange: Blank(),
    SearchTerm: ""
}))
```

**What it does:**
1. User clicks button
2. `Patch()` updates all filter fields in `ActiveFilters` record
3. All dropdowns reset to blank (empty)
4. All text inputs clear
5. `FilteredItems` sees all fields blank and returns unfiltered results
6. Gallery immediately shows all items

**Important:** Set `SearchTerm` to `""` (empty string), not `Blank()` (it's a text field, not optional).

### Step 4: Configure Button Styling

For consistent appearance with your theme, set these properties:

| Property | Formula/Value | Purpose |
|----------|---|---------|
| `Fill` | `ThemeColors.NeutralGray` | Button background |
| `HoverFill` | `GetHoverColor(ThemeColors.NeutralGray)` | Color when hovering |
| `PressedFill` | `GetPressedColor(ThemeColors.NeutralGray)` | Color when clicked |
| `Color` | `ThemeColors.Text` | Text color |
| `Visible` | `true` | Always visible |
| `DisplayMode` | `EditMode.Edit` | Always enabled |

**Alternative styling:**

If you don't have `ThemeColors` or color helper UDFs:
```powerfx
Fill: RGBA(240, 240, 240, 1)      // Light gray
HoverFill: RGBA(220, 220, 220, 1) // Darker gray on hover
PressedFill: RGBA(200, 200, 200, 1) // Even darker when pressed
Color: RGBA(0, 0, 0, 1)            // Black text
```

### Step 5: Test the Reset Button

**Test scenario:**

1. **Play the app** (F5)
2. **Apply multiple filters:**
   - Set `drp_Status` to "Active"
   - Set `drp_Department` to "Sales"
   - Set `drp_DateRange` to "Letzte 7 Tage"
   - Type "Project" in search
   - Verify gallery shows filtered results

3. **Click "Filter zurücksetzen" button:**
   - All dropdowns return to blank/"Alle"
   - Search box clears
   - Gallery shows all items again
   - Verify instant update (no delay)

4. **Verify Monitor:**
   - Open Monitor (F12)
   - Click reset button
   - Check `ActiveFilters` variable → All filter fields should be blank/empty
   - Watch gallery update in real-time

5. **Edge case - Reset when no filters applied:**
   - Start with no filters set
   - Click reset button
   - Should show all items (no change, but no error)

---

## Complete Control Configuration Reference

This section provides a quick reference for all control properties.

### drp_Status Configuration

```powerfx
drp_Status:
  Items:          CachedStatuses
  Default:        Blank()
  OnChange:       Set(ActiveFilters, Patch(ActiveFilters, {Status: Self.Selected.Value}))
  DisplayFields:  ["Value"] or ["DisplayName"]
  ValueField:     "Value"
  AllowEmptySelection: true
  HintText:       "Status auswählen"
```

### drp_Department Configuration

```powerfx
drp_Department:
  Items:          CachedDepartments
  Default:        Blank()
  OnChange:       Set(ActiveFilters, Patch(ActiveFilters, {Department: Self.Selected.Value}))
  DisplayFields:  ["Name"] or ["DisplayName"]
  ValueField:     "Name"
  AllowEmptySelection: true
  HintText:       "Abteilung auswählen"
```

### drp_DateRange Configuration

```powerfx
drp_DateRange:
  Items:          Table(
                    {Value: Blank(), DisplayName: "Alle"},
                    {Value: "Last7Days", DisplayName: "Letzte 7 Tage"},
                    {Value: "Last14Days", DisplayName: "Letzte 14 Tage"},
                    {Value: "Last30Days", DisplayName: "Letzte 30 Tage"},
                    {Value: "Last90Days", DisplayName: "Letzte 90 Tage"}
                  )
  Default:        Blank()
  OnChange:       Set(ActiveFilters, Patch(ActiveFilters, {DateRange: Self.Selected.Value}))
  DisplayFields:  ["DisplayName"]
  ValueField:     "Value"
  AllowEmptySelection: true
  HintText:       "Zeitraum auswählen"
```

### txt_SearchName Configuration

```powerfx
txt_SearchName:
  Default:            ""
  DelayedOnChange:    Set(ActiveFilters, Patch(ActiveFilters, {SearchTerm: Self.Text}))
  HintText:           "Nach Name suchen..."
  Mode:               TextMode.SingleLine
  DelayOutput:        true
  DelayedOutputTime:  500
```

### glr_Items Configuration

```powerfx
glr_Items:
  Items:          FilteredItems
```

### btn_ResetFilters Configuration

```powerfx
btn_ResetFilters:
  Text:           "Filter zurücksetzen"
  OnSelect:       Set(ActiveFilters, Patch(ActiveFilters, {
                    Status: Blank(),
                    Department: Blank(),
                    DateRange: Blank(),
                    SearchTerm: ""
                  }))
  Fill:           ThemeColors.NeutralGray
  HoverFill:      GetHoverColor(ThemeColors.NeutralGray)
  PressedFill:    GetPressedColor(ThemeColors.NeutralGray)
  Color:          ThemeColors.Text
```

---

## Common Issues & Troubleshooting

### Issue 1: Dropdown Shows No Options

**Symptom:** Dropdown appears empty when clicked

**Possible causes:**
1. Collection (e.g., `CachedStatuses`) not populated
2. Wrong field name in `DisplayFields`
3. Data connection failed

**Solution:**
1. Verify collection has data:
   - Type `CachedStatuses` in formula bar
   - Should show table with rows
2. Check data structure:
   - If collection has columns: `Value`, `DisplayName`
   - Set `DisplayFields: ["DisplayName"]`, `ValueField: "Value"`
3. Verify data loading in App.OnStart:
   - Check `ClearCollect(CachedStatuses, ...)` executes without errors

### Issue 2: Gallery Doesn't Update When Dropdown Changes

**Symptom:** Changing dropdown value doesn't filter gallery

**Possible causes:**
1. `OnChange` formula not set correctly
2. Gallery still bound to old collection (not `FilteredItems`)
3. `FilteredItems` formula has errors

**Solution:**
1. Verify dropdown `OnChange`:
   - Formula bar should show: `Set(ActiveFilters, Patch(ActiveFilters, {Status: Self.Selected.Value}))`
   - Check for typos

2. Verify gallery Items binding:
   - Select gallery → Formula bar should show: `FilteredItems`
   - Not: `FilteredCollection` or manual `Filter()` call

3. Check `FilteredItems` formula:
   - App → Formulas → Find `FilteredItems`
   - Should have no syntax errors
   - Verify all filter layers are included

4. Open Monitor (F12):
   - Change dropdown
   - Check `ActiveFilters` variable → Should update
   - Check gallery → Should refresh

### Issue 3: Performance Issues (Gallery Slow to Update)

**Symptom:** Noticeable delay when changing filters

**Possible causes:**
1. Text search without `DelayedOnChange` (filters on every keystroke)
2. Non-delegable expressions in `FilteredItems`
3. Very large dataset (10,000+ items)

**Solution:**
1. Use `DelayedOnChange` on text input:
   - Property: `txt_SearchName.DelayedOnChange`
   - Not: `OnChange`
   - Wait 500ms before filtering

2. Check delegation:
   - Open App Checker (Alt+Shift+F10)
   - No warnings for `FilteredItems`
   - Verify uses only delegable expressions:
     - ✅ `StartsWith()` for text search
     - ❌ `Search()` or UDFs inside Filter

3. For large datasets:
   - Implement pagination (see `docs/performance/GALLERY-PERFORMANCE.md`)
   - Use `FirstN()` and `Skip()` with page state

### Issue 4: Reset Button Doesn't Clear Dropdowns

**Symptom:** Clicking reset button updates gallery but dropdowns still show selected values

**Possible causes:**
1. Dropdown `Default` property bound to state variable
2. Dropdown items need explicit reset formula

**Solution:**

This is expected behavior in Power Apps. To fix:

Option A: Update dropdown `Default` properties to reset with button:
```powerfx
// In button OnSelect, also set dropdowns
btn_ResetFilters.OnSelect = {
  Set(ActiveFilters, Patch(ActiveFilters, {
    Status: Blank(),
    Department: Blank(),
    DateRange: Blank(),
    SearchTerm: ""
  }));
  Reset(drp_Status);
  Reset(drp_Department);
  Reset(drp_DateRange);
  Reset(txt_SearchName)
}
```

Option B: Bind dropdown `Default` to state:
```powerfx
drp_Status.Default = ActiveFilters.Status
```

Then when `ActiveFilters.Status` changes, dropdown updates automatically.

### Issue 5: Search Not Finding Items

**Symptom:** Items matching search term not displayed

**Possible causes:**
1. Search uses `Search()` function (doesn't work with SharePoint)
2. Item Title field is blank
3. Search is case-sensitive

**Solution:**
1. Verify `FilteredItems` uses `StartsWith()`:
   ```powerfx
   StartsWith(Title, ActiveFilters.SearchTerm)  // ✅ Correct
   Search(Title, ActiveFilters.SearchTerm)       // ❌ Wrong
   ```

2. Check item data:
   - Verify items have Title values
   - Open Monitor, evaluate `Items` table
   - See what Title values exist

3. Note: `StartsWith()` is case-insensitive by default

---

## Testing Checklist

Use this checklist to verify all controls work correctly:

### Status Dropdown Tests
- [ ] Dropdown displays all status options
- [ ] Selecting a status filters gallery correctly
- [ ] Clearing selection shows all items
- [ ] Works with other filters (status + department)

### Department Dropdown Tests
- [ ] Dropdown displays all department options
- [ ] Selecting a department filters gallery correctly
- [ ] Clearing selection shows all items
- [ ] Works with other filters (status + department)

### Date Range Dropdown Tests
- [ ] Dropdown displays all date range options
- [ ] Selecting a date range filters gallery correctly
- [ ] "Letzte 7 Tage" shows items from last 7 days
- [ ] "Letzte 90 Tage" shows more items than "Letzte 7 Tage"
- [ ] Clearing selection shows all items

### Search Text Input Tests
- [ ] Typing in search box updates after 500ms
- [ ] Items matching search term are displayed
- [ ] Clearing search box shows all items
- [ ] Search works with partial matches (e.g., "Pro" matches "Project")

### Gallery Binding Tests
- [ ] Gallery initially shows all items
- [ ] Gallery updates instantly when any filter changes
- [ ] Combining multiple filters works correctly
- [ ] No delay or need for manual refresh

### Reset Button Tests
- [ ] Clicking button resets all filters
- [ ] Gallery shows all items after reset
- [ ] Works when multiple filters are applied
- [ ] Works when no filters are applied

### Performance Tests
- [ ] Filter changes complete in <100ms
- [ ] No network calls during filtering (uses cached data)
- [ ] Monitor shows no delegation warnings
- [ ] App Checker shows no errors

### Edge Case Tests
- [ ] Gallery shows empty state when no items match filters
- [ ] No errors when filtering returns 0 items
- [ ] Can combine all 4 filters simultaneously
- [ ] Reset works after complex filter combinations

---

## Integration Example

Here's a complete end-to-end example showing how all controls work together:

### Scenario: User filters for "Active Sales projects from last 30 days"

**Step 1: User interface**
```
┌─────────────────────────────────┐
│ Filter Panel                    │
├─────────────────────────────────┤
│ Status: [Dropdown: Active    ▼] │
│ Department: [Dropdown: Sales ▼] │
│ Date Range: [Dropdown: L30T  ▼] │
│ Search: [Text: Project      ] │
│ [Reset Filters button]          │
└─────────────────────────────────┘
        ↓ (user selects)

┌─────────────────────────────────┐
│ Gallery Results                 │
│ - Project Alpha (Active, Sales) │
│ - Project Beta (Active, Sales)  │
│ 45 items matching filters       │
└─────────────────────────────────┘
```

**Step 2: State changes**

User selects "Active" from status dropdown:
```powerfx
// Dropdown OnChange fires
Set(ActiveFilters, Patch(ActiveFilters, {Status: "Active"}))

// ActiveFilters state now:
{
  Status: "Active",        // ← Changed
  Department: Blank(),
  DateRange: Blank(),
  SearchTerm: ""
}
```

**Step 3: FilteredItems recalculates**

```powerfx
FilteredItems = Filter(
    UserScopedItems,
    (IsBlank("Active") || Status = "Active") &&     // ← Now filters to Active
    (IsBlank(Blank()) || Department = Blank()) &&   // ← Shows all departments
    (IsBlank(Blank()) || 'Modified On' >= ...) &&   // ← Shows all dates
    (IsBlank("") || StartsWith(Title, ""))          // ← Shows all items
)
// Result: All Active items
```

**Step 4: User selects "Sales" department**

```powerfx
// Dropdown OnChange fires
Set(ActiveFilters, Patch(ActiveFilters, {Department: "Sales"}))

// ActiveFilters state now:
{
  Status: "Active",
  Department: "Sales",     // ← Changed
  DateRange: Blank(),
  SearchTerm: ""
}

// FilteredItems recalculates to:
// Active items in Sales department only
```

**Step 5: User selects "Last 30 Days"**

```powerfx
Set(ActiveFilters, Patch(ActiveFilters, {DateRange: "Last30Days"}))

// FilteredItems recalculates to:
// Active items in Sales department modified in last 30 days
```

**Step 6: User types "Project"**

```powerfx
// DelayedOnChange fires (500ms after typing stops)
Set(ActiveFilters, Patch(ActiveFilters, {SearchTerm: "Project"}))

// FilteredItems recalculates to:
// Active items in Sales department, modified in last 30 days, with Title starting with "Project"
```

**Result:** Gallery shows only matching items: "Project Alpha", "Project Beta", etc.

**Step 7: User clicks Reset button**

```powerfx
Set(ActiveFilters, Patch(ActiveFilters, {
    Status: Blank(),
    Department: Blank(),
    DateRange: Blank(),
    SearchTerm: ""
}))

// FilteredItems recalculates with all Blank() values
// Gallery shows all items again
```

---

## Next Steps

After implementing these 6 controls:

1. **Test thoroughly** using the testing checklist above
2. **Optimize performance** if needed:
   - Check Monitor for delegation warnings
   - Use pagination for large datasets (>2000 items)
   - Ensure columns are indexed in data source

3. **Customize styling** to match your app design:
   - Update colors to use your theme
   - Adjust control sizes and spacing
   - Add icons or additional labels

4. **Document for users**:
   - Create user guide explaining each filter
   - Show example filter scenarios
   - Explain date range options (German users familiar with week/month terminology)

5. **Monitor usage** in production:
   - Use app telemetry to see which filters are used most
   - Adjust available filters based on user behavior
   - Consider adding more filter options

---

## References

- **Design doc:** `docs/plans/2026-02-13-reactive-filter-system-design.md`
- **Delegation patterns:** `docs/performance/DELEGATION-PATTERNS.md`
- **Filter composition guide:** `docs/performance/FILTER-COMPOSITION-GUIDE.md`
- **UDF reference:** `docs/reference/UDF-REFERENCE.md`
- **Power Apps docs:** [Microsoft Power Apps Formulas Reference](https://learn.microsoft.com/en-us/power-apps/maker/canvas-apps/formula-reference)

---

**Last updated:** 2026-02-13
**Status:** Implementation Complete
**Maintained by:** PowerApps Template Team
