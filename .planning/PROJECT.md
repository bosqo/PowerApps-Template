# PowerApps Canvas App Production Template

## What This Is

A production-ready PowerApps Canvas App template for data entry/forms apps connected to SharePoint Lists. Provides role-based security via EntraID groups, optimized performance, delegation-friendly filtering patterns, and standardized error handling. Designed for rapid customer project deployment.

## Core Value

Fast, secure, reusable foundation that eliminates copy-paste inconsistencies and startup performance issues across customer projects.

## Requirements

### Validated

Existing capabilities proven across multiple customer projects:

- ✓ **Theme System** - Fluent Design color palette, typography, spacing scale — existing
- ✓ **Role-Based Access Control** - 6-role system (Admin, GF, Manager, HR, Sachbearbeiter, User) with EntraID group mapping — existing
- ✓ **Permission System** - UDFs for HasRole(), HasPermission(), CanAccessRecord(), CanEditRecord(), CanDeleteRecord() — existing
- ✓ **Timezone Handling** - CET/CEST conversion for SharePoint UTC dates (GetCETToday(), ConvertUTCToCET(), FormatDateTimeCET()) — existing
- ✓ **Notification Patterns** - Standardized user feedback (NotifySuccess(), NotifyError(), NotifyWarning(), NotifyPermissionDenied()) — existing
- ✓ **Validation UDFs** - Input validation (IsValidEmail(), IsNotPastDate(), IsAlphanumeric(), IsOneOf()) — existing
- ✓ **State Management** - AppState, ActiveFilters, UIState variable structure — existing
- ✓ **Control Patterns** - Gallery, Button, Form configurations for common scenarios — existing
- ✓ **Collection Loading** - ClearCollect patterns with Concurrent() for parallel data loading — existing

### Active

Improvements and additions for this milestone:

- [ ] **Variable Structure Optimization** - Review AppState/ActiveFilters/UIState for logical consistency and eliminate redundancy
- [ ] **Fast Startup Performance** - Reduce App.OnStart to <2 seconds by caching Office365 API calls, minimizing sequential operations, maximizing Concurrent() usage
- [ ] **Delegation-Friendly Filters** - Create UDFs for common filtering patterns that work with SharePoint delegation:
  - Role-based data scoping (ViewAll OR Owner = CurrentUser)
  - Text search across multiple columns
  - Status/dropdown filters
  - User-based filters ("My Items" toggle)
- [ ] **Gallery Performance** - Optimize large dataset rendering, implement virtual scrolling patterns, reduce non-delegable operations
- [ ] **Error Handling Patterns** - Standardized error boundaries, graceful API failure handling, user-friendly error messages
- [ ] **Bug Fixes** - Fix HasAnyRole() hardcoded limit, IsOneOf() incorrect operator, strengthen IsValidEmail() validation
- [ ] **API Call Optimization** - Cache Office365Users.MyProfileV2() and Office365Groups calls to reduce startup API load
- [ ] **Filter Composition** - Pattern for combining role + search + status + user filters without breaking delegation

### Out of Scope

Explicit boundaries for this template:

- **Multi-language support** - German-only is standard for customer projects, internationalization adds complexity without value
- **Automated testing framework** - Manual testing is sufficient for template validation, automated testing targets individual customer apps
- **CI/CD pipeline** - Deployment scripts exist, full pipeline automation is customer-specific
- **Component library** - Code patterns provide sufficient reusability, component library requires separate Power Platform solution
- **Model-Driven App patterns** - This template is Canvas App only, Model-Driven Apps have different architecture
- **Mobile-specific optimization** - Responsive design is handled by Canvas Apps runtime, no mobile-specific code needed
- **Offline support** - Network-dependent by design, offline scenarios are customer-specific requirements

## Context

**Technical Environment:**
- Power Platform (Canvas Apps)
- Power Fx 2025 (Named Formulas, UDFs, Behavior functions)
- SharePoint Lists as primary data source
- Office365Users and Office365Groups connectors for identity
- EntraID (Azure AD) for group-based role assignment

**Customer Project Pattern:**
1. Copy App-Formulas-Template.fx, App-OnStart-Minimal.fx, Control-Patterns-Modern.fx to new app
2. Configure EntraID group IDs in UserRoles formula
3. Connect SharePoint Lists
4. Wire up galleries and forms using control patterns
5. Deploy via PAC CLI using deployment scripts

**Known Pain Points from Production Use:**
- App.OnStart takes 3-5 seconds due to 6 separate Office365Groups API calls
- Gallery performance degrades with >500 records when using CanAccessRecord() UDF in filter (non-delegable)
- Delegation warnings force use of FirstN() limiting visible records to 2000
- Search across multiple columns requires careful pattern to stay delegable
- Combining role-based filter + text search + status filter often breaks delegation

**Existing Architecture Strengths:**
- Clean separation: Declarative (App.Formulas) vs Imperative (App.OnStart) vs Presentation (Controls)
- Lazy evaluation of Named Formulas reduces initial load
- With() caching pattern prevents redundant API calls within single formula
- Concurrent() used for parallel lookup data loading
- Permission guards prevent unauthorized actions before they execute

## Constraints

- **Tech Stack**: Power Fx 2025, Canvas Apps — no Python/JavaScript/C# allowed
- **Data Source**: SharePoint Lists — must maintain delegation compatibility
- **Security Model**: UI-level only (Canvas Apps limitation) — server-side validation must be added in customer-specific Power Automate flows
- **Performance**: App.OnStart must complete in <2 seconds — Microsoft best practice threshold
- **Delegation**: All filters must work with >2000 records — SharePoint delegation requirement
- **Compatibility**: Must work in Power Platform environments with GCC/GCC-High restrictions — some organizations block certain connectors
- **Browser Support**: Edge, Chrome, Safari — Canvas Apps runtime handles cross-browser compatibility
- **Reusability**: Code must be copy-pastable — no solution dependencies, all code self-contained in template files

## Key Decisions

| Decision | Rationale | Outcome |
|----------|-----------|---------|
| Named Formulas over App.OnStart variables | Lazy evaluation, reactive updates, better performance | ✓ Good - proven across projects |
| 6-role system (Admin, GF, Manager, HR, Sachbearbeiter, User) | Matches German business hierarchy, covers all customer needs | ✓ Good - no customer has needed changes |
| EntraID Groups for role assignment | Centralized identity management, no manual role tables | ✓ Good - but API performance needs caching |
| CET/CEST timezone handling | SharePoint stores UTC, German customers need local time | ✓ Good - critical for date comparisons |
| Office365Users.MyProfileV2() for profile | Richer profile data than User() function alone | ⚠️ Revisit - API call slows startup, consider caching in Dataverse |
| Behavior UDFs for notifications | Power Fx 2025 feature, cleaner than inline Notify() | ✓ Good - eliminates code duplication |
| Permission checks before actions | Fail-fast pattern, prevents unauthorized operations early | ✓ Good - better UX than post-action errors |
| SharePoint Lists over Dataverse | Lower licensing cost for customers | ⚠️ Revisit - delegation limits more restrictive than Dataverse |

---
*Last updated: 2026-01-18 after project initialization*
