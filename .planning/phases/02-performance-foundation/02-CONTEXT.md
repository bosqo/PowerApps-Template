# Phase 2: Performance Foundation - Context

**Gathered:** 2026-01-18
**Status:** Ready for planning

<domain>
## Phase Boundary

Achieve sub-2-second App.OnStart by optimizing Office365 API calls, implementing caching, and parallelizing data loading. This phase focuses on startup performance and resilience, not on filtering, UI enhancements, or additional features (those are Phase 3+).

</domain>

<decisions>
## Implementation Decisions

### Startup Sequencing

**Critical data loading (must complete before app is usable):**
- User profile (Office365Users.MyProfileV2)
- User roles (Office365Groups membership check)
- User permissions (derived from roles)
- Load order: Sequential — user → roles → permissions (each depends on previous)

**Background data loading (loads while app is interactive):**
- Lookup data (departments, categories, statuses, etc.)
- Recent items / user context data
- Does NOT include all Office365 groups (optional, can be omitted)

**Initial screen:** Land directly on main work screen (e.g., Items gallery) — not home/dashboard or splash screen.

**UI during loading:** App fully visible, interactive elements (dropdowns, lists) disabled until their data arrives. Galleries show empty/skeleton states.

**Ready signal:** Automatic transition when critical data loads (no "Continue" button needed).

**Timeout:** No timeout — wait indefinitely if network is slow. User can close/retry app.

**Critical failure handling:** If any critical data fails to load, block startup with error message. User must resolve (network, auth) and retry.

### Error Handling

**Connector failures (Office365Users, Office365Groups):**
- Show blocking error message to user
- Error appears during startup if critical data fails
- User must close app and retry after resolving network/auth

**Non-critical API failures (lookup data, background operations):**
- Retry once after 2-second delay
- If still fails, use fallback value: "Unbekannt" (Unknown in German)
- Do not block app, allow graceful degradation

**Error message tone:** Plain German, user-friendly language — no technical jargon or error codes
- Examples: "Verbindung fehlgeschlagen. Bitte überprüfen Sie Ihr Netzwerk."
- NOT: "Office365Users Connector Timeout. Error: -2147024809"

**Fallback behavior:** When Office365 fails and data is needed, show "Unbekannt" instead of empty or technical error.

### Claude's Discretion

- Exact caching mechanism (collections vs Dataverse vs other approach)
- Cache invalidation strategy and TTL
- Specific implementation of Concurrent() for background tasks
- Exact UI spinner/skeleton design during loading
- Retry delay duration (suggested: 2 seconds)
- Whether to track/log failed API calls for diagnostics

</decisions>

<specifics>
## Specific Ideas

- App should feel responsive — critical data loads quickly, user sees interaction points immediately
- "Unbekannt" fallback should be consistent across all missing data fields (department, category, owner, etc.)
- Sequential load order ensures permissions are calculated with complete role data

</specifics>

<deferred>
## Deferred Ideas

- Caching strategy details (Dataverse vs collections vs browser storage) — defer to planner/executor
- Performance measurement and monitoring dashboard — Phase 4+ (UX/Documentation)
- Offline mode with pre-cached data — potential future phase
- Custom retry UI (showing "Retrying..." spinner) — can be simple for this phase

</deferred>

---

*Phase: 02-performance-foundation*
*Context gathered: 2026-01-18*
