# Codebase Concerns

**Analysis Date:** 2026-01-18

## Tech Debt

**Azure AD Security Group Configuration (Hardcoded Placeholders):**
- Issue: Template contains placeholder Azure AD Group IDs that must be manually configured before deployment
- Files: `src/App-Formulas-Template.fx:11-13, 186-217`
- Impact: Security roles will not work until configured. All users will have `IsAdmin: false`, `IsManager: false` by default. Role-based access control is completely non-functional without configuration.
- Fix approach: Create configuration documentation or wizard to guide first-time setup. Consider environment-specific configuration files or Dataverse table for group ID storage instead of hardcoded values.

**Legacy Pattern File Inconsistency:**
- Issue: `Datasource-Filter-Patterns.fx` uses deprecated variable pattern (`Data.Filter.*`, `App.User.*`) while other files use modern UDF pattern
- Files: `src/Datasource-Filter-Patterns.fx:1-24` (entire file uses legacy pattern)
- Impact: Confusion for developers migrating existing apps. Copy-paste from this file will break modern apps. Mixed patterns reduce code maintainability.
- Fix approach: Either fully migrate file to modern pattern or clearly mark as "Legacy Reference Only" in filename (`Datasource-Filter-Patterns-LEGACY.fx`) and remove from main documentation.

**Office365 Connector API Performance:**
- Issue: Multiple API calls to `Office365Users.MyProfileV2()` and `Office365Groups.ListGroupMembers()` causing slow startup
- Files: `src/App-Formulas-Template.fx:157-183` (UserProfile), `src/App-Formulas-Template.fx:186-217` (UserRoles)
- Impact: Each role check makes separate API call to Office365Groups. App startup can take 3-5 seconds with 6 role checks. API throttling limits may be hit in large organizations.
- Fix approach: Use `With()` to cache API responses. Batch group membership checks if possible. Consider caching role results in Dataverse with 24-hour TTL to reduce API calls.

**Missing Function Implementations:**
- Issue: Template references UDFs that are commented out or not fully implemented (Notification functions were previously commented out)
- Files: `src/App-Formulas-Template.fx:512-549` (Notification UDFs now implemented), documented in `CLAUDE.md:158-160`
- Impact: Previous version had missing Notification UDFs causing runtime errors. Risk of similar gaps in future template versions.
- Fix approach: Comprehensive testing of all UDFs before template release. Add automated validation script to verify all referenced UDFs are defined.

**Environment Configuration in Code:**
- Issue: Environment URLs and configuration stored in `.env.example` but no automated mechanism to inject into app
- Files: `.env.example:1-32`, deployment scripts reference but don't use
- Impact: Developers must manually track environment-specific values. Risk of deploying dev configuration to production. No single source of truth for environment settings.
- Fix approach: Create PowerShell script to generate Power Fx configuration from .env file. Store environment-specific values in Dataverse Environment Variables instead of hardcoded app formulas.

## Known Bugs

**HasAnyRole() Function - Hardcoded Limit:**
- Symptoms: Function only checks first 3 roles in comma-separated list, silently ignores roles beyond position 3
- Files: `src/App-Formulas-Template.fx:429-432` (documented in `log/CODE-REVIEW-2025.md:28-55`)
- Trigger: Call `HasAnyRole("Role1,Role2,Role3,Role4")` - Role4 will never be checked
- Workaround: Limit role lists to 3 items maximum, or use multiple `HasRole()` calls with `||` operator

**IsOneOf() Function - Incorrect Operator Usage:**
- Symptoms: Function uses `in` operator with `ForAll()` which doesn't work as expected in Power Fx. May return incorrect true/false results.
- Files: `src/App-Formulas-Template.fx:763-765` (documented in `log/CODE-REVIEW-2025.md:76-99`)
- Trigger: Call `IsOneOf("value", "allowed1,allowed2,allowed3")`
- Workaround: Use manual Switch() statement or implement corrected version with `CountRows(Filter())` pattern

**GetStatusIcon() Typo:**
- Symptoms: Function contains "buildinicon" instead of "builtinicon" in one case
- Files: `src/App-Formulas-Template.fx:487` (documented in `CLAUDE.md:160`)
- Trigger: Call `GetStatusIcon("active")` returns malformed icon string
- Workaround: Fixed in current version (2025-01-12), but documents the fragility of string-based icon references

**Email Validation Weak:**
- Symptoms: `IsValidEmail()` allows multiple `@` symbols, spaces, and edge cases that aren't valid email addresses
- Files: `src/App-Formulas-Template.fx:751-755` (documented in `log/CODE-REVIEW-2025.md:153-189`)
- Trigger: `IsValidEmail("test@@example.com")` returns true, `IsValidEmail("test @example.com")` returns true
- Workaround: Implement regex-based validation or use stricter checks as documented in CODE-REVIEW-2025.md

**FormatNumber() Missing:**
- Symptoms: Documentation references `FormatNumber()` UDF that doesn't exist in template
- Files: Documented in `CLAUDE.md:159`, `log/AUDIT-REPORT.md:158-159`
- Trigger: Call `FormatNumber(1234.56)` causes undefined function error
- Workaround: Use `Text(value, "#,##0.00")` directly

## Security Considerations

**UI-Only Security (Critical Limitation):**
- Risk: All role-based access control (RBAC) is implemented in Canvas App UI only. No server-side enforcement.
- Files: `src/App-Formulas-Template.fx:186-276` (UserRoles, UserPermissions), documented in `log/CODE-REVIEW-2025.md:20-21`
- Current mitigation: Template correctly uses Canvas App formula visibility controls
- Recommendations: Add Dataverse security roles, field-level security, and row-level security for defense-in-depth. Document explicitly that Canvas App security is not sufficient for sensitive data. Implement server-side validation in Power Automate flows for all Create/Update/Delete operations.

**Hardcoded Security Group IDs:**
- Risk: Security configuration stored in app code makes rotation difficult. Group IDs visible to anyone who can export app.
- Files: `src/App-Formulas-Template.fx:186-217`
- Current mitigation: None - group IDs are currently placeholder values
- Recommendations: Store group IDs in Dataverse Environment Variables (not visible in exported .msapp). Use Azure Key Vault integration for production deployments. Implement group ID rotation procedure in deployment documentation.

**No Audit Logging:**
- Risk: No built-in tracking of who accessed what data or performed what actions
- Files: No audit implementation exists
- Current mitigation: None
- Recommendations: Add audit trail to Dataverse Audit Log. Implement custom audit table with User, Action, Timestamp, RecordId fields. Log all Create/Update/Delete operations and filtered data access via Power Automate.

**Email Domain Validation Missing:**
- Risk: Role assignment based on email domain (documented in `docs/MIGRATION-GUIDE.md:136-147`) has no validation for allowed domains
- Files: `docs/MIGRATION-GUIDE.md:136-147` (example pattern)
- Current mitigation: Template uses Azure AD groups by default, not email domain checking
- Recommendations: If email-based roles are used, validate against whitelist of allowed domains. Implement domain verification in UserRoles formula. Add warning comments in template about domain-based security risks.

## Performance Bottlenecks

**Office365Groups API Calls on Every App Load:**
- Problem: Role membership checked via API calls every time app loads (no caching between sessions)
- Files: `src/App-Formulas-Template.fx:186-217`
- Cause: Named Formulas are lazy-evaluated but not persisted between app sessions
- Improvement path: Cache role membership in Dataverse table with 24-hour expiration. Implement background refresh via Power Automate. Use App.OnStart to load cached roles into variable for session duration.

**Non-Delegable Filter Operations:**
- Problem: Complex filters with UDFs like `CanAccessRecord()` are non-delegable, limited to 2000 records
- Files: `src/App-OnStart-Minimal.fx:185-201` (MyRecentItems collection uses CanAccessRecord UDF)
- Cause: UDF calls inside Filter() cannot be delegated to Dataverse/SharePoint
- Improvement path: Pre-filter at data source level using Dataverse security roles. Use server-side filtering via Dataverse views. Implement pagination with FirstN/Skip pattern (already documented in template).

**Concurrent() Not Used for Lookup Data:**
- Problem: `App-OnStart-Minimal.fx` uses Concurrent() for static data but not for user-scoped data
- Files: `src/App-OnStart-Minimal.fx:123-175` (uses Concurrent), `src/App-OnStart-Minimal.fx:185-242` (sequential loading)
- Cause: User-scoped collections depend on UserPermissions which must load first
- Improvement path: Split startup into two phases: (1) Concurrent load of independent data, (2) Concurrent load of user-scoped data after permissions known. Document pattern in template comments.

**Large Formula Files:**
- Problem: `App-Formulas-Template.fx` is 759 lines, `Control-Patterns-Modern.fx` is 880 lines
- Files: `src/App-Formulas-Template.fx` (759 lines), `src/Control-Patterns-Modern.fx` (880 lines)
- Cause: All UDFs and patterns in single files for template distribution
- Improvement path: Canvas Apps don't support file splitting, but document modular approach. Create separate template variants (minimal, standard, full) for different use cases. Provide guidance on which UDFs to remove for specific app types.

## Fragile Areas

**Named Formula Dependency Chain:**
- Files: `src/App-Formulas-Template.fx:157-276` (UserProfile → UserRoles → UserPermissions chain)
- Why fragile: Circular reference error if UserPermissions tries to reference UserProfile directly. Power Fx evaluates Named Formulas in undefined order.
- Safe modification: Always maintain linear dependency: `UserProfile` → `UserRoles` → `UserPermissions` → `FeatureFlags`. Test thoroughly after adding new Named Formulas that reference existing ones.
- Test coverage: No automated testing for Named Formula dependencies

**Timezone Conversion Logic:**
- Files: `src/App-Formulas-Template.fx:552-631` (CET timezone functions), documented extensively in `CLAUDE.md:86-108`
- Why fragile: Hardcoded offset calculation (+1 hour for CET, +2 for CEST). Daylight Saving Time (DST) transition logic is complex and error-prone. SharePoint stores UTC but Power Apps `Today()` returns local timezone.
- Safe modification: Never use `Today()` directly with SharePoint dates - always use `GetCETToday()`. Test thoroughly around DST transitions (last Sunday of March/October). Consider using TimeZoneOffset() function if available in environment.
- Test coverage: No automated tests for timezone edge cases (DST transitions, leap years)

**Office365 Connector Version Compatibility:**
- Files: `src/App-Formulas-Template.fx:158` (uses MyProfileV2), documented in `log/AUDIT-REPORT.md:139-175`, `docs/MIGRATION-GUIDE.md:449-459`
- Why fragile: Different Power Platform environments may have different Office365Users connector versions. `MyProfileV2()` may not be available, requiring fallback to `MyProfile()`.
- Safe modification: Wrap Office365Users calls in error handling. Test in target environment before deployment. Document required connector versions in deployment prerequisites.
- Test coverage: No automated validation of connector availability

**Deployment Script Assumes PAC CLI:**
- Files: `deploy-solution.ps1:31-40`, `deploy-dev.bat`, `deploy-test.bat`, `deploy-prod.bat`
- Why fragile: Scripts fail silently if PAC CLI not installed or wrong version. No version compatibility checking between script and PAC CLI.
- Safe modification: Add PAC CLI version check at script start (minimum version requirement). Provide clear error messages with installation URLs. Test scripts on clean machines without PAC CLI.
- Test coverage: No automated validation of deployment scripts

## Scaling Limits

**Canvas App Data Limits:**
- Current capacity: 2000 records per non-delegable query, 500 record default for collections
- Limit: Non-delegable operations (using UDFs in Filter) hit 2000 record limit
- Scaling path: Use delegable operations only (simple comparisons, not UDF calls). Implement server-side filtering with Dataverse views. Consider Model-Driven App for large datasets (>10,000 records). Use Power Apps Component Framework (PCF) for custom data virtualization.

**Office365 API Rate Limits:**
- Current capacity: Office365Groups.ListGroupMembers called 6 times per app load (once per role)
- Limit: Microsoft Graph API throttling (varies by tenant, typically 10,000 requests per 10 minutes per app)
- Scaling path: Cache role membership in Dataverse. Use single API call to get all user's groups, then check membership locally. Implement token bucket pattern to track API usage.

**Canvas App Size Limit:**
- Current capacity: Template files total ~2600 lines of Power Fx code
- Limit: Canvas Apps have 50 MB .msapp file size limit and performance degrades with >100 controls per screen
- Scaling path: Remove unused UDFs from template. Split large apps into multiple apps with component libraries. Use code components (PCF) to reduce control count. Archive old data to separate apps.

**Concurrent User Limit:**
- Current capacity: No explicit limit in template
- Limit: Dataverse/SharePoint performance degrades with >100 simultaneous users per app
- Scaling path: Use Dataverse for better scalability vs SharePoint Lists. Implement data caching strategy. Use Azure CDN for static assets. Consider Power Pages for high-traffic public scenarios.

## Dependencies at Risk

**Office365Users Connector (Critical):**
- Risk: Template relies heavily on Office365Users connector for authentication and profile data. Connector API changes or deprecation would break UserProfile Named Formula.
- Impact: User profile data unavailable, app may fail to load
- Migration plan: Fall back to `User().Email` and `User().FullName` only (basic profile). Consider Azure AD Graph API connector as alternative. Implement graceful degradation if connector unavailable.

**Office365Groups Connector (Critical):**
- Risk: Role-based security depends entirely on Office365Groups connector. Graph API changes or permission revocation breaks RBAC.
- Impact: All users default to no roles/permissions, app becomes unusable for non-admins
- Migration plan: Store role assignments in Dataverse table instead of Azure AD groups. Implement manual role assignment UI for admins. Use Dataverse security roles as primary authorization mechanism.

**Power Fx Named Formulas (Preview Feature):**
- Risk: Named Formulas and UDFs were preview features until 2024, now generally available but syntax may still evolve
- Impact: Template may require refactoring if Power Fx syntax changes in breaking way
- Migration plan: Monitor Power Fx release notes for breaking changes. Maintain legacy version of template for older environments. Test template in new Power Platform releases before updating production apps.

**Power Platform CLI (PAC CLI):**
- Risk: Deployment automation depends on PAC CLI. Breaking changes in CLI commands or authentication would break CI/CD pipeline.
- Impact: Manual deployment required if scripts fail
- Migration plan: Pin PAC CLI version in CI/CD pipeline. Test deployment scripts against new CLI versions in dev environment first. Maintain manual deployment documentation as fallback.

## Missing Critical Features

**No Automated Testing Framework:**
- Problem: Template has no unit tests, integration tests, or automated validation
- Blocks: Continuous integration/deployment, regression testing, confident refactoring
- Files: No test files exist
- Priority: High - critical for enterprise adoption

**No Error Boundary Pattern:**
- Problem: No centralized error handling for UDF failures or API errors
- Blocks: Graceful degradation, user-friendly error messages, error logging
- Files: Documented in `log/CODE-REVIEW-2025.md:264-288` but not implemented
- Priority: Medium - improve user experience and debugging

**No Multi-Language Support:**
- Problem: Template is German-only (labels, notifications, date formats)
- Blocks: International deployment, reusability across regions
- Files: Hardcoded German text throughout `src/App-Formulas-Template.fx` and `src/App-OnStart-Minimal.fx`
- Priority: Low - organization-specific requirement

**No Component Library:**
- Problem: Common UI patterns exist as code snippets only, not reusable components
- Blocks: Consistent UI across apps, faster development, centralized updates
- Files: Documented in `log/CODE-REVIEW-2025.md:349-361` but not implemented
- Priority: Medium - enterprise scalability

**No CI/CD Pipeline:**
- Problem: Deployment scripts exist but no GitHub Actions/Azure DevOps pipeline configuration
- Blocks: Automated testing, approval workflows, rollback capability
- Files: Deployment scripts exist (`deploy-solution.ps1`) but no pipeline YAML
- Priority: Medium - documented extensively but not automated

## Test Coverage Gaps

**Named Formulas Not Tested:**
- What's not tested: UserProfile, UserRoles, UserPermissions computed values
- Files: `src/App-Formulas-Template.fx:157-276`
- Risk: Changes to UserRoles formula could break permission checks undetected
- Priority: High

**UDF Logic Not Validated:**
- What's not tested: HasAnyRole, IsOneOf, IsValidEmail, timezone conversion functions
- Files: `src/App-Formulas-Template.fx:400-759`
- Risk: Known bugs in HasAnyRole and IsOneOf exist (documented in CODE-REVIEW-2025.md), no tests to prevent regression
- Priority: High

**Deployment Scripts Not Tested:**
- What's not tested: Error handling, environment selection, rollback procedures
- Files: `deploy-solution.ps1`, `deploy-dev.bat`, `deploy-test.bat`, `deploy-prod.bat`
- Risk: Deployment failures in production, data loss, downtime
- Priority: High

**Edge Cases Not Covered:**
- What's not tested: DST transitions, leap years, empty datasets, API failures, permission changes during session
- Files: All template files potentially affected
- Risk: Runtime errors in production under specific conditions
- Priority: Medium

**Browser/Device Compatibility:**
- What's not tested: Template behavior across browsers (Chrome, Edge, Safari), mobile devices (iOS, Android)
- Files: All UI patterns in `src/Control-Patterns-Modern.fx`
- Risk: UI breaks or performs poorly on specific platforms
- Priority: Low - Canvas Apps handle cross-platform rendering

---

*Concerns audit: 2026-01-18*
