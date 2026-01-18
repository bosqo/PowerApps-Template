# Phase 3: Delegation & Filtering - Context

**Gathered:** 2026-01-18
**Status:** Ready for planning

<domain>
## Phase Boundary

Create delegation-friendly filter patterns that work with SharePoint datasets >2000 records without data loss. Implement role-based scoping, text search, status filtering, and user-specific views. Ensure galleries with 500+ records render smoothly with pagination when necessary. Commenting, bookmarking, and advanced search features are separate phases.

</domain>

<decisions>
## Implementation Decisions

### Search UDF Scope
- Search across Title, Description, and Owner columns simultaneously
- Case-insensitive matching ("test" matches "Test", "TEST", "TeSt")
- Partial substring matching (case-insensitive) across all three columns
- Due to delegation limits: use FirstN(Skip()) pagination for search results (50 records per page)

### Filter Combination Strategy
- Smart AND/OR logic: AND between filter types (role, status, user, search) but OR within search terms
- Evaluation order: Status first (usually most restrictive), then Role, then User, then Search
- Filter state resets on every page load (no persistence across navigation)
- Role-based scoping: ViewAll permission shows all records, otherwise Owner = CurrentUser

### Delegation Patterns
- Page size: 50 records per page for FirstN(Skip()) pagination
- Navigation: Both Previous/Next buttons AND jump-to-page input for direct page entry
- Pagination behavior: Reset to page 1 when filters change (prevents confusion)
- Non-delegable operations: Silent pagination (no warnings about delegation limits)
- Mandatory pagination: No "Load All" option—always use pagination for >2000 record datasets

### Filter UI & Interaction
- Filter controls: Horizontal top bar above gallery (search box, status dropdown, "My Items" toggle)
- Visibility: Always visible (not collapsible)
- Clear All button: Always visible for easy filter reset
- Page indicator: Show "Page N of M" alongside pagination controls

### Claude's Discretion
- Exact UI layout and spacing of filter bar
- Search algorithm performance optimization (substring vs word-boundary tuning)
- Gallery scrolling performance tuning (virtual scrolling, lazy loading)
- Exact styling and icon choices for pagination controls
- Toggle control styling for "My Items" feature

</decisions>

<specifics>
## Specific Ideas

- Filter UI should feel responsive—<500ms to load next page even with complex filters
- "My Items" toggle should be a clear, obvious control (not buried in advanced options)
- Page indicator should show context ("Page 2 of 47") not just count
- Gallery should maintain scroll position when user changes pages (if possible within Power Apps constraints)

</specifics>

<deferred>
## Deferred Ideas

- Commenting on records — Phase 4 or later
- Bookmarking/favoriting records — add to backlog
- Advanced search with AND/OR/NOT operators — future phase
- Search result highlighting — future phase
- Column-specific search (e.g., search only Title) — future phase
- Filter saved presets — future phase
- Real-time delegation warnings — add to backlog

</deferred>

---

*Phase: 03-delegation-filtering*
*Context gathered: 2026-01-18*
