# External Integrations

**Analysis Date:** 2026-01-18

## APIs & External Services

**Office 365:**
- Office365Users connector - User profile and directory information
  - SDK/Client: Power Apps standard connector
  - Auth: Implicit via Power Platform environment
  - Usage: `Office365Users.MyProfileV2()` called in `src/App-Formulas-Template.fx:158` for user profile lazy-loading
  - Fields retrieved: Department, Email, FullName

- Office365Groups connector - Azure AD security group membership
  - SDK/Client: Power Apps standard connector
  - Auth: Implicit via Power Platform environment
  - Usage: `Office365Groups.ListGroupMembers(GROUP_ID)` referenced in `src/App-Formulas-Template.fx:197` for role-based access control
  - Purpose: Determine user roles (Admin, Manager, HR, GF, Sachbearbeiter)

**Power Platform:**
- Connection API - Network connectivity detection
  - SDK/Client: Built-in Power Fx global
  - Usage: `Connection.Connected` in `src/App-OnStart-Minimal.fx:49`
  - Purpose: Online/offline detection for `AppState.IsOnline`

## Data Storage

**Databases:**
- Microsoft Dataverse
  - Connection: Implicit via Power Platform environment
  - Client: Power Apps Dataverse connector
  - Tables used:
    - `Departments` - Lookup data for department dropdowns (`src/App-OnStart-Minimal.fx:125-135`)
    - `Categories` - Lookup data for category dropdowns (`src/App-OnStart-Minimal.fx:137-148`)
    - `Items` - Primary business data with Owner, Status, Modified On columns (`src/App-OnStart-Minimal.fx:190`)
    - `Tasks` - Task management with Assigned To, Status, Due Date columns (`src/App-OnStart-Minimal.fx:208`)
  - Schema documented in `docs/DATAVERSE-ITEM-SCHEMA.md`

- SharePoint Lists (Alternative)
  - Connection: SharePoint connector (if configured)
  - Client: Power Apps SharePoint connector
  - Tables: Same as Dataverse (Departments, Categories, Items, Tasks)
  - Note: All DateTime fields stored in UTC, requires CET conversion via UDFs

**File Storage:**
- Not detected (no file upload/download patterns in source)

**Caching:**
- In-memory collections via `ClearCollect()` in `src/App-OnStart-Minimal.fx:123-175`
  - `CachedDepartments` - Active departments sorted by name
  - `CachedCategories` - Active categories sorted by name
  - `CachedStatuses` - Static status dropdown values (German labels)
  - `CachedPriorities` - Static priority dropdown values (German labels)
  - `MyRecentItems` - User-scoped recent items (50 most recent)
  - `MyPendingTasks` - User-assigned pending tasks

## Authentication & Identity

**Auth Provider:**
- Azure Active Directory (Azure AD)
  - Implementation: Implicit authentication via Power Platform
  - User identity: `User().Email`, `User().FullName` Power Fx globals
  - Security groups: Azure AD security groups for role-based access control
  - Configuration required: Azure AD Group IDs in `src/App-Formulas-Template.fx:186-217`

**Role-Based Access Control (RBAC):**
- Six roles defined: Admin, GF (Geschäftsführer), Manager, HR, Sachbearbeiter, User
- Role detection: Azure AD security group membership via `Office365Groups.ListGroupMembers()`
- Permissions: Derived from roles in `UserPermissions` Named Formula (`src/App-Formulas-Template.fx:219-236`)
- UDFs for access control:
  - `HasRole(roleName: Text): Boolean`
  - `HasPermission(permission: Text): Boolean`
  - `CanAccessRecord(ownerEmail: Text): Boolean`
  - `CanEditRecord(ownerEmail: Text, status: Text): Boolean`
  - `CanDeleteRecord(ownerEmail: Text): Boolean`

## Monitoring & Observability

**Error Tracking:**
- In-app error state management via `AppState.LastError`, `AppState.ErrorMessage`, `AppState.ErrorDetails` (`src/App-OnStart-Minimal.fx:51-55`)
- No external error tracking service detected

**Logs:**
- Power Platform environment logs (admin access required)
- No application-level logging framework detected

## CI/CD & Deployment

**Hosting:**
- Microsoft Power Apps (Canvas App runtime)
- Deployed via Power Platform solutions

**CI Pipeline:**
- Local deployment automation via PowerShell scripts
- Service Principal support for automated CI/CD (optional, configured via `APP_ID`, `TENANT_ID`, `CLIENT_SECRET` in `.env.example:23-26`)
- Scripts:
  - `deploy-solution.ps1` - Main deployment orchestration
  - `deploy-dev.bat` - DEV to source control export
  - `deploy-test.bat` - Source control to TEST import
  - `deploy-prod.bat` - Source control to PROD import

**Deployment Workflow:**
- DEV → Git → TEST → PROD
- PAC CLI commands:
  - `pac solution export` - Export solution from environment
  - `pac solution unpack` - Unpack to source control
  - `pac solution pack` - Pack from source control
  - `pac solution import` - Import to target environment
  - `pac solution check` - Run solution checker (static analysis)

**Documentation:**
- `docs/DEPLOYMENT-GUIDE.md` - Full deployment guide
- `DEPLOYMENT-INSTRUCTIONS.md` - Step-by-step instructions
- `DEPLOYMENT-WORKFLOW.md` - Visual workflows
- `DEPLOYMENT-CHEATSHEET.md` - Command reference
- `QUICK-START.md` - Quick reference guide

## Environment Configuration

**Required env vars:**
- `DEV_ENV_URL` - Development environment URL (e.g., `https://org-dev.crm4.dynamics.com`)
- `TEST_ENV_URL` - Test environment URL
- `PROD_ENV_URL` - Production environment URL
- `SOLUTION_NAME` - Power Platform solution name

**Optional env vars (CI/CD):**
- `APP_ID` - Azure AD Service Principal Application ID
- `TENANT_ID` - Azure AD Tenant ID
- `CLIENT_SECRET` - Service Principal secret (store in Azure DevOps/GitHub Secrets)

**Secrets location:**
- `.env` file (local, gitignored)
- Azure DevOps Secure Files or GitHub Secrets (for CI/CD)
- Azure AD Service Principal credentials

**Data Source Configuration:**
- Dataverse tables must be connected manually in Power Apps Studio
- Required tables: Departments, Categories, Items, Tasks
- SharePoint Lists alternative requires connector configuration

## Webhooks & Callbacks

**Incoming:**
- None detected

**Outgoing:**
- None detected (no Power Automate Flow calls or HTTP requests in source files)
- Note: Power Automate Flows may exist separately but are not referenced in Canvas App code

## Timezone Handling

**Critical Integration:**
- SharePoint/Dataverse stores all DateTime in UTC
- CET/CEST conversion required for German users
- UDFs for timezone handling:
  - `GetCETToday(): Date` - Current date in CET timezone
  - `ConvertUTCToCET(utcDateTime: DateTime): DateTime` - UTC to CET conversion
  - `FormatDateTimeCET(utcDateTime: DateTime): Text` - Format in German format with CET timezone
- **Important:** Never use `Today()` directly with SharePoint/Dataverse DateTimes, always use `GetCETToday()`

## Data Source Schema

**Items Table:**
- Columns: Owner (User), Status (Choice), Modified On (DateTime)
- Status values: beantragt, in Bearbeitung, genehmigt, abgelehnt
- Prozessschritt (Choice): Manager, Supervisor, Executive, GF, Sales, Finance, IT, HR, Operations, Marketing

**Tasks Table:**
- Columns: Assigned To (User), Status (Choice), Due Date (DateTime)

**Departments Table:**
- Columns: Name (Text), Status (Choice)

**Categories Table:**
- Columns: Name (Text), Status (Choice)

---

*Integration audit: 2026-01-18*
