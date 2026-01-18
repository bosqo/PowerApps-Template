# Requirements: PowerApps Canvas App Production Template

**Defined:** 2026-01-18
**Core Value:** Fast, secure, reusable foundation that eliminates copy-paste inconsistencies and startup performance issues across customer projects

## v1 Requirements

Requirements for this template optimization. Each requirement must be implemented, tested, and included in the final template deliverable.

### Performance Optimization

- [ ] **PERF-01**: App.OnStart completes in under 2 seconds
- [ ] **PERF-02**: Office365Users and Office365Groups API calls cached to eliminate redundant calls between sessions
- [ ] **PERF-03**: Concurrent() used for all independent data loading operations in App.OnStart
- [ ] **PERF-04**: Gallery with 500+ records renders without performance degradation
- [ ] **PERF-05**: Non-delegable operations identified and documented with FirstN(Skip()) pagination pattern

### Filtering & Data Access

- [ ] **FILT-01**: Delegation-friendly filter UDF for role-based data scoping (ViewAll OR Owner = CurrentUser)
- [ ] **FILT-02**: Delegation-friendly filter UDF for text search across multiple SharePoint columns
- [ ] **FILT-03**: Delegation-friendly filter UDF for status/dropdown filtering
- [ ] **FILT-04**: Delegation-friendly filter UDF for user-based filtering ("My Items" toggle)
- [ ] **FILT-05**: Filter composition pattern that combines role + search + status + user without breaking delegation
- [ ] **FILT-06**: All filters work with datasets >2000 records without silent data loss

### Code Structure & Naming

- [ ] **NAMING-01**: Standardized naming convention for Named Formulas (PascalCase: ThemeColors, UserProfile, UserPermissions)
- [ ] **NAMING-02**: Standardized naming convention for UDFs (PascalCase with verb: HasRole(), GetUserScope(), FormatDateShort())
- [ ] **NAMING-03**: Standardized naming convention for variables (PascalCase: AppState, ActiveFilters, UIState)
- [ ] **NAMING-04**: Standardized naming convention for collections (PascalCase: CachedDepartments, MyRecentItems)
- [ ] **NAMING-05**: Standardized abbreviated naming for controls (glr=Gallery, btn=Button, lbl=Label, txt=TextInput, img=Image, form=Form)
- [ ] **NAMING-06**: Naming convention documentation in template comments and CLAUDE.md

### Variable Structure

- [ ] **VAR-01**: AppState variable structure reviewed for logical consistency
- [ ] **VAR-02**: ActiveFilters variable structure reviewed and optimized
- [ ] **VAR-03**: UIState variable structure reviewed for redundancy elimination
- [ ] **VAR-04**: Each variable has documented purpose and schema in template comments
- [ ] **VAR-05**: Variable dependency chain validated (no circular references)

### Error Handling

- [ ] **ERROR-01**: Graceful error handling pattern for Office365Users connector failures
- [ ] **ERROR-02**: Graceful error handling pattern for Office365Groups connector failures
- [ ] **ERROR-03**: Graceful error handling pattern for SharePoint data modification failures (Patch, Remove)
- [ ] **ERROR-04**: Fallback values documented for all API calls (e.g., empty department if Office365 unavailable)
- [ ] **ERROR-05**: User-friendly error messages (not technical jargon) for all error scenarios

### Notification System

- [ ] **NOTIF-01**: Toast notification UDF for info messages (blue, auto-dismiss)
- [ ] **NOTIF-02**: Toast notification UDF for success messages (green, auto-dismiss)
- [ ] **NOTIF-03**: Toast notification UDF for warning messages (amber, auto-dismiss)
- [ ] **NOTIF-04**: Toast notification UDF for error messages (red, auto-dismiss)
- [ ] **NOTIF-05**: Toast notifications auto-dismiss after 3-5 seconds
- [ ] **NOTIF-06**: Multiple toasts can stack (no overlap)
- [ ] **NOTIF-07**: Toast styling consistent with Fluent Design theme colors
- [ ] **NOTIF-08**: Toast positioned at top or bottom of screen (configurable)

### Bug Fixes & Validation

- [ ] **BUG-01**: Fix HasAnyRole() hardcoded 3-role limit (handle unlimited role lists)
- [ ] **BUG-02**: Fix IsOneOf() incorrect `in` operator usage (use proper Filter/CountRows pattern)
- [ ] **BUG-03**: Strengthen IsValidEmail() validation (reject multiple @, spaces, invalid formats)
- [ ] **BUG-04**: All validation UDFs handle edge cases (empty strings, null values, special characters)

### Documentation & Template

- [ ] **DOC-01**: Template includes configuration guide for EntraID group IDs
- [ ] **DOC-02**: Code comments document purpose and usage of each Named Formula
- [ ] **DOC-03**: Code comments document purpose and parameters of each UDF
- [ ] **DOC-04**: CLAUDE.md updated with naming conventions and best practices
- [ ] **DOC-05**: Quick-start guide for using template in new customer projects

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
| PERF-01 | Performance | TBD | Pending |
| PERF-02 | Performance | TBD | Pending |
| PERF-03 | Performance | TBD | Pending |
| PERF-04 | Performance | TBD | Pending |
| PERF-05 | Performance | TBD | Pending |
| FILT-01 | Filtering | TBD | Pending |
| FILT-02 | Filtering | TBD | Pending |
| FILT-03 | Filtering | TBD | Pending |
| FILT-04 | Filtering | TBD | Pending |
| FILT-05 | Filtering | TBD | Pending |
| FILT-06 | Filtering | TBD | Pending |
| NAMING-01 | Code Structure | TBD | Pending |
| NAMING-02 | Code Structure | TBD | Pending |
| NAMING-03 | Code Structure | TBD | Pending |
| NAMING-04 | Code Structure | TBD | Pending |
| NAMING-05 | Code Structure | TBD | Pending |
| NAMING-06 | Code Structure | TBD | Pending |
| VAR-01 | Variable Structure | TBD | Pending |
| VAR-02 | Variable Structure | TBD | Pending |
| VAR-03 | Variable Structure | TBD | Pending |
| VAR-04 | Variable Structure | TBD | Pending |
| VAR-05 | Variable Structure | TBD | Pending |
| ERROR-01 | Error Handling | TBD | Pending |
| ERROR-02 | Error Handling | TBD | Pending |
| ERROR-03 | Error Handling | TBD | Pending |
| ERROR-04 | Error Handling | TBD | Pending |
| ERROR-05 | Error Handling | TBD | Pending |
| NOTIF-01 | Notifications | TBD | Pending |
| NOTIF-02 | Notifications | TBD | Pending |
| NOTIF-03 | Notifications | TBD | Pending |
| NOTIF-04 | Notifications | TBD | Pending |
| NOTIF-05 | Notifications | TBD | Pending |
| NOTIF-06 | Notifications | TBD | Pending |
| NOTIF-07 | Notifications | TBD | Pending |
| NOTIF-08 | Notifications | TBD | Pending |
| BUG-01 | Bug Fixes | TBD | Pending |
| BUG-02 | Bug Fixes | TBD | Pending |
| BUG-03 | Bug Fixes | TBD | Pending |
| BUG-04 | Bug Fixes | TBD | Pending |
| DOC-01 | Documentation | TBD | Pending |
| DOC-02 | Documentation | TBD | Pending |
| DOC-03 | Documentation | TBD | Pending |
| DOC-04 | Documentation | TBD | Pending |
| DOC-05 | Documentation | TBD | Pending |

**Coverage:**
- v1 requirements: 45 total
- Mapped to phases: 0 (to be filled by roadmapper)
- Unmapped: 45 ⚠️

---
*Requirements defined: 2026-01-18*
*Last updated: 2026-01-18 after initial definition*
