# Testing Patterns

**Analysis Date:** 2026-01-18

## Test Framework

**Runner:**
- Power Apps Test Studio (built-in)
- Manual testing in Power Apps Studio preview mode
- No automated unit test framework detected

**Assertion Library:**
- Not applicable (no unit test files found)

**Run Commands:**
```powershell
# No automated test commands
# Testing done via Power Apps Studio:
# 1. File > Settings > Upcoming features > Enable "Test Studio"
# 2. Navigate to App > Tests
# 3. Record or write test cases
# 4. Run tests via Test Studio interface
```

## Test File Organization

**Location:**
- No test files found in repository
- Testing is manual via Power Apps Studio Test Studio feature
- Pattern files serve as reference implementations (not automated tests)

**Naming:**
- Not applicable (no test files)

**Structure:**
```
PowerApps-Vibe-Claude/
├── src/                              # Source Power Fx files
│   ├── App-Formulas-Template.fx      # UDFs and Named Formulas
│   ├── App-OnStart-Minimal.fx        # Initialization logic
│   ├── Control-Patterns-Modern.fx    # Example control formulas
│   └── Datasource-Filter-Patterns.fx # Legacy reference patterns
├── docs/                             # Architecture documentation
└── log/                              # Code review and audit reports
```

## Test Structure

**Suite Organization:**
- No automated test suites found
- Recommended approach: Use Test Studio to create test suites per screen
- Manual testing checklist documented in `log/CODE-REVIEW-2025.md`

**Patterns:**
- **Manual validation**: Test role-based permissions by switching authenticated users
- **Visual inspection**: Verify UI rendering in preview mode
- **Data validation**: Test CRUD operations against Dataverse/SharePoint test environments
- **Permission testing**: Validate `HasRole()`, `HasPermission()`, `CanAccessRecord()` functions with different user roles

**Example Manual Test Case (from code comments):**
```powerfx
// Test: Delete with permission guard
// File: src/Control-Patterns-Modern.fx:550-556
// Steps:
// 1. Login as Admin user
// 2. Select record in Gallery_Items
// 3. Click Button_Delete
// Expected: Record removed, NotifySuccess shown
// 4. Login as regular user
// 5. Click Button_Delete
// Expected: NotifyPermissionDenied shown, record NOT removed
```

## Mocking

**Framework:** Not applicable

**Patterns:**
- **Feature flags for mock data**: `FeatureFlags.EnableMockData` in `src/App-Formulas-Template.fx:269`
- **Static collections**: Use `ClearCollect()` with hardcoded tables for dropdown testing (lines 151-174 in `src/App-OnStart-Minimal.fx`)
- **URL parameters**: `Param("mock") = "true"` enables test mode in development environments

**Example Mock Pattern:**
```powerfx
// CachedStatuses - static test data
ClearCollect(
    CachedStatuses,
    Table(
        {Value: "Active", DisplayName: "Aktiv", SortOrder: 1},
        {Value: "Pending", DisplayName: "Ausstehend", SortOrder: 2},
        {Value: "Completed", DisplayName: "Abgeschlossen", SortOrder: 5}
    )
)
```

**What to Mock:**
- Lookup tables (Departments, Categories, Statuses, Priorities)
- User roles during development (hardcode `IsAdmin: true` for testing)
- Date ranges for time-sensitive features

**What NOT to Mock:**
- Production Dataverse/SharePoint connections (use DEV environment instead)
- Office365Users connector (requires real authentication)
- Security group membership (test with actual Azure AD groups in TEST environment)

## Fixtures and Factories

**Test Data:**
```powerfx
// Static fixture pattern for dropdown data
// File: src/App-OnStart-Minimal.fx:151-174

ClearCollect(
    CachedPriorities,
    Table(
        {Value: "Critical", DisplayName: "Kritisch", SortOrder: 1},
        {Value: "High", DisplayName: "Hoch", SortOrder: 2},
        {Value: "Medium", DisplayName: "Mittel", SortOrder: 3},
        {Value: "Low", DisplayName: "Niedrig", SortOrder: 4},
        {Value: "None", DisplayName: "Keine", SortOrder: 5}
    )
)
```

**Location:**
- Inline in `src/App-OnStart-Minimal.fx` (lines 151-174)
- No separate fixture files

## Coverage

**Requirements:** Not enforced (no automated coverage tooling)

**View Coverage:**
```bash
# Not applicable - no coverage tooling for Power Apps
# Manual coverage tracking via checklist in code reviews
```

**Known Coverage Gaps (from code review):**
- No automated tests for UDFs (`HasRole()`, `CanAccessRecord()`, timezone functions)
- No integration tests for Dataverse/SharePoint data operations
- No performance tests for delegation scenarios
- Notification UDFs not validated (noted as issue in `log/CODE-REVIEW-2025.md`)

## Test Types

**Unit Tests:**
- Not automated
- Manual validation: Test individual UDFs by calling them in control formulas and inspecting results
- Example: Set `Label_Debug.Text = HasRole("Admin")` to verify role detection

**Integration Tests:**
- Manual testing against DEV environment Dataverse tables
- Required data sources documented in `src/App-OnStart-Minimal.fx:19-24`:
  - Departments (columns: Name, Status)
  - Categories (columns: Name, Status)
  - Items (columns: Owner, Status, 'Modified On')
  - Tasks (columns: 'Assigned To', Status, 'Due Date')

**E2E Tests:**
- Manual test scenarios via Test Studio
- Deployment testing via automated PowerShell scripts (`deploy-dev.bat`, `deploy-test.bat`, `deploy-prod.bat`)
- ALM workflow testing: DEV → Git → TEST → PROD (documented in `DEPLOYMENT-WORKFLOW.md`)

## Common Patterns

**Async Testing:**
```powerfx
// Pattern: Test async data loading with loading state
// File: src/App-OnStart-Minimal.fx:33-36

Set(AppState, {IsLoading: true, IsInitializing: true});
// ... perform data operations ...
Set(AppState, Patch(AppState, {IsLoading: false, IsInitializing: false}));

// Test: Verify AppState.IsLoading transitions
// Expected: IsLoading = true during ClearCollect, false after completion
```

**Error Testing:**
```powerfx
// Pattern: Permission-guarded operation with error notification
// File: src/Control-Patterns-Modern.fx:550-556

If(
    HasPermission("Delete") && CanDeleteRecord(Gallery.Selected.Owner.Email),
    Remove(Items, Gallery.Selected);
    NotifyActionCompleted("Delete", Gallery.Selected.Name),
    NotifyPermissionDenied("delete this item")
)

// Test cases:
// 1. Admin user + own record → Success
// 2. Admin user + others record → Success
// 3. Regular user + own record → Permission denied
// 4. Regular user + others record → Permission denied
```

**Timezone Testing:**
```powerfx
// Pattern: UTC to CET conversion validation
// File: src/App-Formulas-Template.fx:642-673

// Test: Compare Today() vs GetCETToday()
// Expected: May differ by 1 day at midnight UTC (23:00 or 00:00 CET)

// Test: Verify DST transitions (last Sunday March/October)
// Test date: 2025-03-30 02:00 UTC → 2025-03-30 04:00 CEST (UTC+2)
// Test date: 2025-10-26 02:00 UTC → 2025-10-26 03:00 CET (UTC+1)
```

**Role-Based Access Testing:**
```powerfx
// Pattern: Test visibility and permissions per role
// File: src/Control-Patterns-Modern.fx:232-240

Button_Delete.Visible = HasPermission("Delete")
Button_Create.Visible = HasPermission("Create")
Container_AdminPanel.Visible = HasRole("Admin")

// Test matrix:
// | Role           | Delete | Create | AdminPanel |
// |----------------|--------|--------|------------|
// | Admin          | ✓      | ✓      | ✓          |
// | Manager        | ✗      | ✓      | ✗          |
// | Sachbearbeiter | ✗      | ✓      | ✗          |
// | User           | ✗      | ✗      | ✗          |
```

## Validation Testing

**Email Validation:**
```powerfx
// Function: IsValidEmail (lines 564-572 in src/App-Formulas-Template.fx)
// Test cases:
// Valid: "user@company.com" → true
// Invalid: "user" → false (no @)
// Invalid: "user@" → false (no domain)
// Invalid: "@company.com" → false (no local part)
// Invalid: "user @company.com" → false (contains space)
// Invalid: "user@company" → false (no TLD)
```

**Date Range Validation:**
```powerfx
// Function: IsDateInRange (lines 592-593 in src/App-Formulas-Template.fx)
// Test cases:
// In range: Date(2025, 6, 15) with min=Date(2025, 1, 1), max=Date(2025, 12, 31) → true
// Out of range: Date(2024, 12, 31) with same bounds → false
// Boundary: min date → true, max date → true
```

## Deployment Testing

**Automated Deployment Scripts:**
- `deploy-dev.bat` - DEV → Git export and unpack
- `deploy-test.bat` - Git → TEST managed solution import
- `deploy-prod.bat` - Git → PROD managed solution import
- `deploy-solution.ps1` - Core PowerShell deployment logic

**Testing Workflow:**
1. Manual testing in DEV environment
2. Export via `deploy-dev.bat`
3. Deploy to TEST via `deploy-test.bat`
4. UAT (User Acceptance Testing) in TEST environment
5. Deploy to PROD via `deploy-prod.bat` (after approval)

**Validation Steps (per deployment):**
- PAC CLI authentication check (`pac auth list`)
- Solution export/import success
- Connection references resolved
- Environment variables configured
- App launches without errors
- Role-based permissions work correctly

## Known Testing Gaps

**Critical Issues from Code Review:**
1. **Notification UDFs not validated** - `NotifySuccess()`, `NotifyError()` functions were commented out initially (fixed in refactoring)
2. **No automated regression tests** - Changes to UDFs could break control formulas without detection
3. **No performance benchmarks** - Delegation limits not automatically validated
4. **Timezone edge cases** - DST transitions not systematically tested
5. **HasAnyRole() bug** - Function only checked first 3 roles (fixed in code review, but no test prevented it)

**Recommendations:**
- Implement Test Studio test suites for critical user flows
- Create manual test checklists for each role (Admin, Manager, HR, Sachbearbeiter, User)
- Document timezone test scenarios with specific dates for DST transitions
- Add performance tests for galleries with 2000+ records (delegation threshold)

## Test Environment Strategy

**DEV:**
- Unmanaged solution
- Test data: Sample records with known IDs
- User roles: Configure test Azure AD groups with known members

**TEST/UAT:**
- Managed solution (deployed from Git)
- Production-like data volume
- Real user roles for UAT validation

**PROD:**
- Managed solution only
- No direct testing (changes go through TEST first)

---

*Testing analysis: 2026-01-18*
