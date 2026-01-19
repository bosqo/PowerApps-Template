# Requirements: PowerApps Canvas App Production Template

**Defined:** 2026-01-18
**Core Value:** Fast, secure, reusable foundation that eliminates copy-paste inconsistencies and startup performance issues across customer projects

## v1 Requirements

Requirements for this template optimization. Each requirement must be implemented, tested, and included in the final template deliverable.

### Performance Optimization

- [x] **PERF-01**: App.OnStart completes in under 2 seconds
- [x] **PERF-02**: Office365Users and Office365Groups API calls cached to eliminate redundant calls between sessions
- [x] **PERF-03**: Concurrent() used for all independent data loading operations in App.OnStart
- [x] **PERF-04**: Gallery with 500+ records renders without performance degradation
- [x] **PERF-05**: Non-delegable operations identified and documented with FirstN(Skip()) pagination pattern

### Filtering & Data Access

- [x] **FILT-01**: Delegation-friendly filter UDF for role-based data scoping (ViewAll OR Owner = CurrentUser)
- [x] **FILT-02**: Delegation-friendly filter UDF for text search across multiple SharePoint columns
- [x] **FILT-03**: Delegation-friendly filter UDF for status/dropdown filtering
- [x] **FILT-04**: Delegation-friendly filter UDF for user-based filtering ("My Items" toggle)
- [x] **FILT-05**: Filter composition pattern that combines role + search + status + user without breaking delegation
- [x] **FILT-06**: All filters work with datasets >2000 records without silent data loss

### Code Structure & Naming

- [x] **NAMING-01**: Standardized naming convention for Named Formulas (PascalCase: ThemeColors, UserProfile, UserPermissions)
- [x] **NAMING-02**: Standardized naming convention for UDFs (PascalCase with verb: HasRole(), GetUserScope(), FormatDateShort())
- [x] **NAMING-03**: Standardized naming convention for variables (PascalCase: AppState, ActiveFilters, UIState)
- [x] **NAMING-04**: Standardized naming convention for collections (PascalCase: CachedDepartments, MyRecentItems)
- [x] **NAMING-05**: Standardized abbreviated naming for controls (glr=Gallery, btn=Button, lbl=Label, txt=TextInput, img=Image, form=Form)
- [x] **NAMING-06**: Naming convention documentation in template comments and CLAUDE.md

### Variable Structure

- [x] **VAR-01**: AppState variable structure reviewed for logical consistency
- [x] **VAR-02**: ActiveFilters variable structure reviewed and optimized
- [x] **VAR-03**: UIState variable structure reviewed for redundancy elimination
- [x] **VAR-04**: Each variable has documented purpose and schema in template comments
- [x] **VAR-05**: Variable dependency chain validated (no circular references)

### Error Handling

- [x] **ERROR-01**: Graceful error handling pattern for Office365Users connector failures
- [x] **ERROR-02**: Graceful error handling pattern for Office365Groups connector failures
- [x] **ERROR-03**: Graceful error handling pattern for SharePoint data modification failures (Patch, Remove)
- [x] **ERROR-04**: Fallback values documented for all API calls (e.g., empty department if Office365 unavailable)
- [x] **ERROR-05**: User-friendly error messages (not technical jargon) for all error scenarios

### Notification System

- [x] **NOTIF-01**: Toast notification UDF for info messages (blue, auto-dismiss)
- [x] **NOTIF-02**: Toast notification UDF for success messages (green, auto-dismiss)
- [x] **NOTIF-03**: Toast notification UDF for warning messages (amber, auto-dismiss)
- [x] **NOTIF-04**: Toast notification UDF for error messages (red, auto-dismiss)
- [x] **NOTIF-05**: Toast notifications auto-dismiss after 3-5 seconds
- [x] **NOTIF-06**: Multiple toasts can stack (no overlap)
- [x] **NOTIF-07**: Toast styling consistent with Fluent Design theme colors
- [x] **NOTIF-08**: Toast positioned at top or bottom of screen (configurable)

### Bug Fixes & Validation

- [x] **BUG-01**: Fix HasAnyRole() hardcoded 3-role limit (handle unlimited role lists)
- [x] **BUG-02**: Fix IsOneOf() incorrect `in` operator usage (use proper Filter/CountRows pattern)
- [x] **BUG-03**: Strengthen IsValidEmail() validation (reject multiple @, spaces, invalid formats)
- [x] **BUG-04**: All validation UDFs handle edge cases (empty strings, null values, special characters)

### Documentation & Template

- [x] **DOC-01**: Template includes configuration guide for EntraID group IDs
- [x] **DOC-02**: Code comments document purpose and usage of each Named Formula
- [x] **DOC-03**: Code comments document purpose and parameters of each UDF
- [x] **DOC-04**: CLAUDE.md updated with naming conventions and best practices
- [x] **DOC-05**: Quick-start guide for using template in new customer projects

## v2 Requirements

Deferred to future releases. Acknowledged but not in current scope.

### Testing & Quality

- **TEST-01**: Automated unit tests for all UDFs (edge cases, permission logic, timezone conversion)
- **TEST-02**: Integration tests for filter composition patterns with real SharePoint data
- **TEST-03**: Performance benchmarks (startup time, API call count, gallery render time)
- **TEST-04**: Deployment script validation for new environments

### Advanced Features

- **CACHE-01**: Dataverse caching layer for Office365 API results (optional, for large organizations)
- **AUDIT-01**: Audit trail for all Create/Update/Delete operations
- **COMP-01**: Power Apps Component Library for reusable UI controls
- **MULTI-01**: Multi-language support (currently German-only)

### Deployment & ALM

- **CI-01**: GitHub Actions / Azure DevOps pipeline configuration
- **ENV-01**: Environment-specific configuration (DEV/TEST/PROD)
- **HOTFIX-01**: Hotfix branch workflow and emergency deployment procedure

## Out of Scope

Explicitly excluded from this template. Documented to prevent scope creep.

| Feature | Reason |
|---------|--------|
| Automated testing framework | Manual testing sufficient for template validation; automated testing is customer app responsibility |
| CI/CD pipeline | Deployment scripts exist; full pipeline is customer-specific and beyond template scope |
| Component library | Code patterns provide sufficient reusability; component library requires separate Power Platform solution |
| Model-Driven App patterns | Canvas Apps only; Model-Driven Apps have different architecture and requirements |
| Mobile-specific optimization | Responsive design is Canvas App runtime responsibility, not template code |
| Offline support | Network-dependent by design; offline requirements are customer-specific |
| Multi-language support | German-only standard; internationalization adds complexity without value for current use cases |
| Real-time features (signalR) | Async patterns sufficient for data entry/forms use cases |
| Third-party API integrations | Connectors are customer-specific; template remains data-source agnostic |

## Traceability

Which phases cover which requirements. Updated during roadmap creation.

| Requirement | Category | Phase | Status |
|-------------|----------|-------|--------|
| NAMING-01 | Code Structure | Phase 1 | Complete |
| NAMING-02 | Code Structure | Phase 1 | Complete |
| NAMING-03 | Code Structure | Phase 1 | Complete |
| NAMING-04 | Code Structure | Phase 1 | Complete |
| NAMING-05 | Code Structure | Phase 1 | Complete |
| NAMING-06 | Code Structure | Phase 1 | Complete |
| VAR-01 | Variable Structure | Phase 1 | Complete |
| VAR-02 | Variable Structure | Phase 1 | Complete |
| VAR-03 | Variable Structure | Phase 1 | Complete |
| VAR-04 | Variable Structure | Phase 1 | Complete |
| VAR-05 | Variable Structure | Phase 1 | Complete |
| BUG-01 | Bug Fixes | Phase 1 | Complete |
| BUG-02 | Bug Fixes | Phase 1 | Complete |
| BUG-03 | Bug Fixes | Phase 1 | Complete |
| BUG-04 | Bug Fixes | Phase 1 | Complete |
| PERF-01 | Performance | Phase 2 | Complete |
| PERF-02 | Performance | Phase 2 | Complete |
| PERF-03 | Performance | Phase 2 | Complete |
| ERROR-01 | Error Handling | Phase 2 | Complete |
| ERROR-02 | Error Handling | Phase 2 | Complete |
| ERROR-03 | Error Handling | Phase 2 | Complete |
| ERROR-04 | Error Handling | Phase 2 | Complete |
| ERROR-05 | Error Handling | Phase 2 | Complete |
| FILT-01 | Filtering | Phase 3 | Complete |
| FILT-02 | Filtering | Phase 3 | Complete |
| FILT-03 | Filtering | Phase 3 | Complete |
| FILT-04 | Filtering | Phase 3 | Complete |
| FILT-05 | Filtering | Phase 3 | Complete |
| FILT-06 | Filtering | Phase 3 | Complete |
| PERF-04 | Performance | Phase 3 | Complete |
| PERF-05 | Performance | Phase 3 | Complete |
| NOTIF-01 | Notifications | Phase 4 | Pending |
| NOTIF-02 | Notifications | Phase 4 | Pending |
| NOTIF-03 | Notifications | Phase 4 | Pending |
| NOTIF-04 | Notifications | Phase 4 | Pending |
| NOTIF-05 | Notifications | Phase 4 | Pending |
| NOTIF-06 | Notifications | Phase 4 | Pending |
| NOTIF-07 | Notifications | Phase 4 | Pending |
| NOTIF-08 | Notifications | Phase 4 | Pending |
| DOC-01 | Documentation | Phase 4 | Pending |
| DOC-02 | Documentation | Phase 4 | Pending |
| DOC-03 | Documentation | Phase 4 | Pending |
| DOC-04 | Documentation | Phase 4 | Pending |
| DOC-05 | Documentation | Phase 4 | Pending |

**Coverage:**
- v1 requirements: 45 total
- Mapped to phases: 45
- Unmapped: 0 ✓

**Phase Distribution:**
- Phase 1 (Code Cleanup & Standards): 15 requirements
- Phase 2 (Performance Foundation): 8 requirements
- Phase 3 (Delegation & Filtering): 8 requirements
- Phase 4 (User Experience & Documentation): 13 requirements

---
*Requirements defined: 2026-01-18*
*Last updated: 2026-01-18 after roadmap creation*
