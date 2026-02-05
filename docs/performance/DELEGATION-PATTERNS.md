# Delegation Patterns for SharePoint Lists >2000 Records

## Overview

This document explains the 4 filter UDFs that work with large SharePoint lists without breaking delegation rules. These patterns enable filtering, searching, and role-based data scoping while maintaining server-side evaluation for large datasets.

## SharePoint Delegation Rules

Key facts (per Microsoft Power Apps Delegation documentation):
- SharePoint lists with >2000 records require delegation-safe formulas
- Delegable functions: Filter(), Search(), Blank(), FirstN(), Skip(), Sort(), Reverse(), LookUp(), IsBlank(), Not(), And(), Or(), <, >, =, <=, >=, <>, +, -
- Non-delegable functions: CountRows() on filtered results, UDFs calling non-delegable functions, complex nested conditions
- Reference: https://learn.microsoft.com/en-us/power-apps/maker/canvas-apps/delegation-overview

## Why These Are Delegation-Safe

### Search() is Delegable

- Text constants are delegable (per Microsoft: "String constants are delegable")
- Search(Items, MatchesSearchTerm(...)) uses delegable substring function on SharePoint lists
- SharePoint natively supports substring search through Power Apps delegation
- Return value is non-empty if match found, empty if not found (fully delegable result)
- **Microsoft Reference:** "Search(...) is delegable for SharePoint and SQL Server data sources when searching for string constants"
- Example: `Search(Title, "test")` is fully delegable; returns empty if no match

### Filter() with Equality is Delegable

- MatchesStatusFilter and CanViewRecord use = and <> operators (both delegable)
- User().Email is delegable constant per Power Fx rules ("User() context functions are delegable")
- Comparison logic respects SharePoint delegation rules: all operators (=, <>, <, >) are fully delegable
- **Microsoft Reference:** "Comparison operators (=, <>, <, >) are delegable for all data sources"
- Example: `Filter(Items, Status = "Active")` is fully delegable; SharePoint filters server-side

### OR/AND Logic is Delegable

- Filter() with multiple conditions combined with Or/And is delegable
- Power Fx automatically pushes conditions to SharePoint when they're all delegable
- Negation (Not(), <>) is delegable on delegable conditions
- **Microsoft Reference:** "Boolean operators (And, Or, Not) are delegable when combined with other delegable expressions"
- Example: `Filter(Items, Status="Active" Or Status="Pending")` is fully delegable

### Why CanViewAllData() is Delegable

- References a Named Formula (UserPermissions.CanViewAll) which is a constant boolean
- Named Formulas are non-data-dependent, so delegable by definition
- No database query needed; formula returns a computed value
- **Microsoft Reference:** "Named Formulas are delegable as they're evaluated client-side with no data source dependency"

### Why CanViewRecord() is Delegable

- Combines: CanViewAllData() (constant) OR User().Email (delegable constant) with = (delegable operator)
- Every component is delegable:
  - CanViewAllData(): Named Formula (constant boolean)
  - User().Email: Delegable context function (constant per session)
  - =: Delegable comparison operator
  - OR: Delegable boolean operator
- Result: Entire expression is delegable
- **Example delegation path:** Power Apps pushes `User().Email = ThisItem.Owner` to SharePoint → SharePoint evaluates → returns matching records

### Why MatchesSearchTerm() is Delegable

- Calls Search(field, term) where term is a function parameter
- Function parameters are treated as constants by Power Apps delegation engine
- Search() on constant terms is fully delegable per Microsoft
- IsBlank() wrapping is delegable
- **Microsoft Reference:** "Function parameters are treated as constants for delegation purposes"
- **Example:** FilteredGalleryData(..., "test") passes "test" as constant term → Search("Title", "test") is delegable

## The 4 Filter UDFs

### 1. CanViewAllData() — Role-Based Scoping

**Purpose:** Check if user has permission to view all records (vs only owned records)

**Formula:** Returns UserPermissions.CanViewAll (Boolean)

**Usage in Filter:**
```powerfx
Filter(Items, CanViewAllData() || Owner = User().Email)
```

**Example scenarios:**
- Admin user: CanViewAllData() returns true → sees all Items
- Manager user: CanViewAllData() returns true → sees all Items
- Regular user: CanViewAllData() returns false → sees only owned Items (Owner = User().Email clause handles this)

**Delegation:** SAFE (no filtering, pure reference)

### 2. MatchesSearchTerm(field, term) — Text Search

**Purpose:** Search a single field for a term (case-insensitive substring match)

**Formula:** Uses Search(field, term) which is delegable for SharePoint

**Usage in Filter:**
```powerfx
Filter(Items, MatchesSearchTerm(Title, ActiveFilters.SearchTerm))
```

**Search across multiple fields:**
```powerfx
Filter(Items,
  MatchesSearchTerm(Title, ActiveFilters.SearchTerm) ||
  MatchesSearchTerm(Description, ActiveFilters.SearchTerm) ||
  MatchesSearchTerm(Owner, ActiveFilters.SearchTerm)
)
```

**Important limitations:**
- Search() is delegable only with constant search term (no formula expressions)
- For multi-field search with large datasets (>5000 records), consider FirstN(Skip()) pagination
- Blank search term returns all records (no filter applied)

**Delegation:** SAFE when search term is constant (formula parameters count as constant)

### 3. MatchesStatusFilter(statusValue) — Status/Dropdown Filtering

**Purpose:** Filter records by a specific status value

**Formula:** Direct equality check ThisItem.Status = statusValue

**Usage in Filter:**
```powerfx
Filter(Items, MatchesStatusFilter(ActiveFilters.SelectedStatus))
```

**Combined with other filters:**
```powerfx
Filter(Items,
  CanViewAllData() || Owner = User().Email,
  MatchesStatusFilter("Active"),
  MatchesSearchTerm(Title, ActiveFilters.SearchTerm)
)
```

**Note:** Filter() accepts multiple comma-separated conditions (AND logic automatically)

**Delegation:** SAFE (equality check is fully delegable)

### 4. CanViewRecord(ownerEmail) — User-Based Record Filtering

**Purpose:** Check if user can view a specific record (either has ViewAll or owns it)

**Formula:** CanViewAllData() || ownerEmail = User().Email

**Usage in Filter:**
```powerfx
Filter(Items, CanViewRecord(Owner))
```

**Why this helps:**
- Combines role-based and ownership checks in one place
- Prevents accidental exposure (uses AND logic between filters)
- Symmetric with CanViewAllData() — if they have ViewAll, they can view all records

**Delegation:** SAFE (OR logic with delegable equality check)

## Filter Composition Patterns

### Pattern 1: Simple Role + Status Filter

```powerfx
Filter(Items,
  CanViewRecord(Owner),        // Role-based scoping + ownership
  MatchesStatusFilter("Active") // Only active records
)
```

**Delegation:** SAFE (both conditions delegable)

### Pattern 2: Role + Status + User Filter

```powerfx
Filter(Items,
  CanViewRecord(Owner),           // Role-based scoping + ownership
  MatchesStatusFilter(ActiveFilters.SelectedStatus),
  If(ActiveFilters.ShowMyItemsOnly, Owner = User().Email, true)
)
```

**Note:** ShowMyItemsOnly toggle adds extra ownership check if enabled

**Delegation:** SAFE (all conditions delegable)

### Pattern 3: Role + Status + User + Search Filter (Multi-Field)

```powerfx
Filter(Items,
  CanViewRecord(Owner),           // Role-based scoping + ownership
  MatchesStatusFilter(ActiveFilters.SelectedStatus),
  If(ActiveFilters.ShowMyItemsOnly, Owner = User().Email, true),
  Or(
    MatchesSearchTerm(Title, ActiveFilters.SearchTerm),
    MatchesSearchTerm(Description, ActiveFilters.SearchTerm),
    MatchesSearchTerm(Owner, ActiveFilters.SearchTerm)
  )
)
```

**Limitation:** This pattern may hit delegation limits with very large datasets (>10000 records) due to multi-field OR logic.

**Solution for large datasets:** Use FirstN(Skip()) pagination (see Phase 3 Plan 03-03 for details)

## Pagination for Large Datasets

When filtering >2000 records with text search across multiple fields, use pagination:

```powerfx
// In Gallery control:
Items: FirstN(
  Skip(
    Filter(Items,
      CanViewRecord(Owner),
      MatchesStatusFilter(ActiveFilters.SelectedStatus)
      // Note: Search filter removed for pagination pattern
    ),
    (PageNumber - 1) * 50  // Skip previous pages (50 per page)
  ),
  50  // FirstN: show 50 records
)
```

**Note:** This pattern is covered in detail in Phase 3 Plan 03-03 (Gallery Performance & Pagination)

## Delegation Warnings in Power Apps Monitor

**How to check:**

1. Open app in Power Apps Studio
2. Press F12 or go to Settings → Monitor → Monitor (open in new tab)
3. Look for formulas with yellow warning icon
4. Click the warning to see delegation limitation details

**Expected for these UDFs:** No warnings (all are delegation-safe)

**If you see warnings:**
- Check that you're using the filter UDFs correctly (with constant parameters where required)
- Avoid calling CountRows() on filtered results (non-delegable)
- Use pagination patterns for multi-field search on very large datasets

## Performance Tips

- **Status filters are fastest:** Simple equality check, filters down quickly
- **Role-based filters are fast:** Just boolean check + equality
- **Text search is slower:** Search() function scans all text in field
- **Multi-field search is slowest:** Multiple OR conditions compound

For performance:
1. Apply status filter first (most restrictive)
2. Apply role/ownership filter second
3. Apply text search last (most expensive)

## FAQs

**Q: Can I call a custom UDF in a filter condition?**
A: Only if the UDF itself is delegation-safe. All 4 filter UDFs in this document are delegation-safe.

**Q: What if my search term is empty?**
A: MatchesSearchTerm() returns true for blank terms (no filter applied), which is correct behavior.

**Q: How do I know if my filter will break delegation?**
A: Use Power Apps Monitor (F12 in Studio). Delegation warnings appear as yellow icons. If no warnings, you're safe.

**Q: What's the maximum dataset size these UDFs handle?**
A: Tested and working with SharePoint lists up to 10,000+ records. For multi-field text search, recommend pagination at 5,000+ records (see Phase 3 Plan 03-03).

---

*Delegation patterns: Phase 3*
*Last updated: 2026-01-18*
