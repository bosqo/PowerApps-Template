# Roadmap: PowerApps Canvas App Production Template

**Project:** PowerApps Canvas App Production Template
**Core Value:** Fast, secure, reusable foundation that eliminates copy-paste inconsistencies and startup performance issues across customer projects
**Depth:** Quick (3-5 phases)
**Total Requirements:** 45 v1 requirements

## Overview

This roadmap transforms the existing PowerApps Canvas App template from a functional but inconsistent codebase into a production-optimized, delegation-friendly template with standardized patterns and sub-2-second startup time. The phases progress from foundational code quality to performance optimization to advanced filtering patterns, culminating in polished user experience and documentation.

## Phases

### Phase 1: Code Cleanup & Standards

**Goal:** Establish consistent naming conventions, optimize variable structure, and eliminate known bugs to create a clean foundation for performance work.

**Dependencies:** None (foundation phase)

**Plans:** 3 plans

Plans:
- [x] 01-01-PLAN.md — Fix critical bugs in HasAnyRole(), IsOneOf(), IsValidEmail() UDFs
- [x] 01-02-PLAN.md — Standardize naming conventions for Named Formulas, UDFs, variables, collections, controls
- [x] 01-03-PLAN.md — Optimize variable structure (AppState, ActiveFilters, UIState) and validate dependencies

**Requirements:**
- NAMING-01: Standardized naming convention for Named Formulas (PascalCase: ThemeColors, UserProfile, UserPermissions)
- NAMING-02: Standardized naming convention for UDFs (PascalCase with verb: HasRole(), GetUserScope(), FormatDateShort())
- NAMING-03: Standardized naming convention for variables (PascalCase: AppState, ActiveFilters, UIState)
- NAMING-04: Standardized naming convention for collections (PascalCase: CachedDepartments, MyRecentItems)
- NAMING-05: Standardized abbreviated naming for controls (glr=Gallery, btn=Button, lbl=Label, txt=TextInput, img=Image, form=Form)
- NAMING-06: Naming convention documentation in template comments and CLAUDE.md
- VAR-01: AppState variable structure reviewed for logical consistency
- VAR-02: ActiveFilters variable structure reviewed and optimized
- VAR-03: UIState variable structure reviewed for redundancy elimination
- VAR-04: Each variable has documented purpose and schema in template comments
- VAR-05: Variable dependency chain validated (no circular references)
- BUG-01: Fix HasAnyRole() hardcoded 3-role limit (handle unlimited role lists)
- BUG-02: Fix IsOneOf() incorrect `in` operator usage (use proper Filter/CountRows pattern)
- BUG-03: Strengthen IsValidEmail() validation (reject multiple @, spaces, invalid formats)
- BUG-04: All validation UDFs handle edge cases (empty strings, null values, special characters)

**Success Criteria:**
1. All Named Formulas, UDFs, variables, collections, and controls follow consistent naming patterns documented in code comments
2. AppState, ActiveFilters, and UIState variables have clear, non-redundant structure with documented schemas
3. HasAnyRole(), IsOneOf(), and IsValidEmail() handle all edge cases without errors
4. No circular dependencies exist between variables and Named Formulas
5. Developer can copy template files and understand naming/structure without external documentation

### Phase 2: Performance Foundation

**Goal:** Achieve sub-2-second App.OnStart time by eliminating redundant API calls, caching Office365 connector results, and parallelizing all independent operations.

**Dependencies:** Phase 1 (requires clean variable structure)

**Plans:** 3 plans

Plans:
- [x] 02-01-PLAN.md — Implement critical path caching and Office365 connector optimization
- [x] 02-02-PLAN.md — Implement parallel background loading and error handling patterns
- [x] 02-03-PLAN.md — Validate performance metrics and document results

**Requirements:**
- PERF-01: App.OnStart completes in under 2 seconds
- PERF-02: Office365Users and Office365Groups API calls cached to eliminate redundant calls between sessions
- PERF-03: Concurrent() used for all independent data loading operations in App.OnStart
- ERROR-01: Graceful error handling pattern for Office365Users connector failures
- ERROR-02: Graceful error handling pattern for Office365Groups connector failures
- ERROR-03: Graceful error handling pattern for SharePoint data modification failures (Patch, Remove)
- ERROR-04: Fallback values documented for all API calls (e.g., empty department if Office365 unavailable)
- ERROR-05: User-friendly error messages (not technical jargon) for all error scenarios

**Success Criteria:**
1. App.OnStart timer in Monitor shows <2000ms from start to completion
2. Office365Users.MyProfileV2() called only once during app session (subsequent reads use cached value)
3. Office365Groups API calls for role checking happen in parallel using Concurrent() not sequentially
4. App remains functional with reduced capabilities when Office365 connectors fail (e.g., shows "Unknown" for department instead of crashing)
5. User sees friendly error messages like "Unable to load profile information" instead of technical error codes

### Phase 3: Delegation & Filtering

**Goal:** Create delegation-friendly filter patterns that work with SharePoint datasets >2000 records without data loss, enabling performant galleries and search functionality.

**Dependencies:** Phase 2 (requires optimized startup and variable structure)

**Plans:** 3 plans

Plans:
- [x] 03-01-PLAN.md — Implement 4 delegation-friendly filter UDFs (role, search, status, user)
- [x] 03-02-PLAN.md — Create filter composition pattern and Gallery integration
- [x] 03-03-PLAN.md — Validate gallery performance and document pagination patterns

**Requirements:**
- FILT-01: Delegation-friendly filter UDF for role-based data scoping (ViewAll OR Owner = CurrentUser)
- FILT-02: Delegation-friendly filter UDF for text search across multiple SharePoint columns
- FILT-03: Delegation-friendly filter UDF for status/dropdown filtering
- FILT-04: Delegation-friendly filter UDF for user-based filtering ("My Items" toggle)
- FILT-05: Filter composition pattern that combines role + search + status + user without breaking delegation
- FILT-06: All filters work with datasets >2000 records without silent data loss
- PERF-04: Gallery with 500+ records renders without performance degradation
- PERF-05: Non-delegable operations identified and documented with FirstN(Skip()) pagination pattern

**Success Criteria:**
1. User with ViewAll permission can see all records in SharePoint list with >2000 items without delegation warnings
2. User can search across Title, Description, and Owner fields simultaneously without triggering FirstN() limitation
3. User can apply "Status = Active" filter combined with "My Items" toggle and text search without breaking delegation
4. Gallery renders 500 records with smooth scrolling and no lag when filtering or sorting
5. Non-delegable operations clearly documented with pagination pattern that shows page N of M pages

### Phase 4: User Experience & Documentation

**Goal:** Deliver polished notification system with Fluent Design styling and comprehensive documentation for rapid customer project deployment.

**Dependencies:** Phase 3 (requires complete functional template)

**Plans:** 3 plans

Plans:
- [ ] 04-01-PLAN.md — Notification System Core (UDF helpers, state management, AddToast/RemoveToast)
- [ ] 04-02-PLAN.md — Toast UI Controls & Styling (container patterns, animations, Fluent Design)
- [ ] 04-03-PLAN.md — Documentation & Configuration (QUICK-START, CLAUDE.md expansion, troubleshooting)

**Requirements:**
- NOTIF-01: Toast notification UDF for info messages (blue, auto-dismiss)
- NOTIF-02: Toast notification UDF for success messages (green, auto-dismiss)
- NOTIF-03: Toast notification UDF for warning messages (amber, auto-dismiss)
- NOTIF-04: Toast notification UDF for error messages (red, auto-dismiss)
- NOTIF-05: Toast notifications auto-dismiss after 3-5 seconds
- NOTIF-06: Multiple toasts can stack (no overlap)
- NOTIF-07: Toast styling consistent with Fluent Design theme colors
- NOTIF-08: Toast positioned at top or bottom of screen (configurable)
- DOC-01: Template includes configuration guide for EntraID group IDs
- DOC-02: Code comments document purpose and usage of each Named Formula
- DOC-03: Code comments document purpose and parameters of each UDF
- DOC-04: CLAUDE.md updated with naming conventions and best practices
- DOC-05: Quick-start guide for using template in new customer projects

**Success Criteria:**
1. User sees color-coded toast notifications (blue/green/amber/red) that auto-dismiss after 3-5 seconds without blocking interaction
2. Multiple simultaneous notifications stack vertically without overlapping or covering each other
3. Toast styling matches Fluent Design system colors defined in ThemeColors Named Formula
4. Developer can configure EntraID group IDs by following inline comments in App-Formulas-Template.fx without reading external docs
5. Developer can copy template files to new project and have working app in <30 minutes following Quick-start guide

## Progress Tracking

| Phase | Requirements | Status | Completion |
|-------|--------------|--------|------------|
| Phase 1: Code Cleanup & Standards | 15 | Complete | 100% |
| Phase 2: Performance Foundation | 8 | Complete | 100% |
| Phase 3: Delegation & Filtering | 8 | Complete | 100% |
| Phase 4: User Experience & Documentation | 13 | Complete | 100% |
| **Total** | **45** | **Complete** | **100%** |

## Milestone Summary

**Total Phases:** 4
**Total Requirements:** 45 (all v1)
**Coverage:** 100% (45/45 requirements mapped)
**Estimated Duration:** 4-6 weeks for full implementation
**Key Deliverables:**
- App-Formulas-Template.fx (Named Formulas + UDFs)
- App-OnStart-Minimal.fx (<2 second startup)
- Control-Patterns-Modern.fx (delegation-friendly patterns)
- Updated CLAUDE.md (standards documentation)
- Quick-start guide for customer projects

---

*Roadmap created: 2026-01-18*
*Last updated: 2026-01-19 — Phase 4 execution complete (all 45 requirements delivered)*
