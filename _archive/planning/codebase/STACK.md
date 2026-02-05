# Technology Stack

**Analysis Date:** 2026-01-18

## Languages

**Primary:**
- Power Fx - Canvas App formula language (2025 modern syntax with Named Formulas and UDFs)

**Secondary:**
- PowerShell 5.1+ - Deployment automation scripts
- YAML/JSON - Configuration and solution metadata
- Markdown - Documentation

## Runtime

**Environment:**
- Microsoft Power Apps Canvas App Runtime
- Power Platform environment (Development/Test/Production)

**Package Manager:**
- PAC CLI (Power Platform CLI) - Microsoft.PowerApps.CLI.Tool
- Lockfile: Not applicable (Power Platform solutions)

## Frameworks

**Core:**
- Power Apps Canvas - Application framework
- Power Fx - Declarative formula language with Named Formulas (2024+)

**Testing:**
- Power Apps Test Studio - For UI testing
- Solution Checker - Static analysis tool via PAC CLI

**Build/Dev:**
- PAC CLI (pac solution pack/unpack) - Solution packaging
- Git - Version control
- PowerShell 5.1+ - Deployment automation

## Key Dependencies

**Critical:**
- Office365Users connector - User profile retrieval (`UserProfile` Named Formula in `src/App-Formulas-Template.fx:155-182`)
- Office365Groups connector - Security group membership for role-based access control (`UserRoles` in `src/App-Formulas-Template.fx:184-217`)
- Connection API - Network connectivity detection (`AppState.IsOnline` in `src/App-OnStart-Minimal.fx:49`)

**Infrastructure:**
- Microsoft Dataverse - Primary data storage (Departments, Categories, Items, Tasks tables referenced in `src/App-OnStart-Minimal.fx:19-24`)
- SharePoint Lists - Alternative data source (configurable, same tables)
- Azure Active Directory - Authentication and security groups

## Configuration

**Environment:**
- Environment URLs configured in `.env.example` (DEV/TEST/PROD environments)
- Required environment variables:
  - `DEV_ENV_URL` - Development environment URL (e.g., `https://org-dev.crm4.dynamics.com`)
  - `TEST_ENV_URL` - Test environment URL
  - `PROD_ENV_URL` - Production environment URL
  - `SOLUTION_NAME` - Power Platform solution name
  - `APP_ID`, `TENANT_ID` - Azure AD Service Principal for CI/CD (optional)

**Build:**
- `deploy-solution.ps1` - Main deployment orchestration script
- `deploy-dev.bat`, `deploy-test.bat`, `deploy-prod.bat` - Environment-specific deployment wrappers
- Solution metadata in unpacked format under `src/` directory

**App Configuration:**
- `src/App-Formulas-Template.fx` - Named Formulas and UDFs configuration
  - Azure AD Security Group IDs (lines 186-217) - Must be configured per organization
  - Email domain for corporate detection (line 150 pattern: `@yourcompany.com`)
  - Theme colors, typography, spacing (lines 24-94)
  - Date ranges, pagination settings (lines 96-118)

## Platform Requirements

**Development:**
- Windows 10/11 or macOS/Linux (PAC CLI cross-platform)
- .NET SDK (for PAC CLI installation via `dotnet tool install`)
- Git for version control
- Power Apps Studio (web or desktop) for app editing
- Power Platform environment with Dataverse database
- Azure AD security groups for role-based access control

**Production:**
- Microsoft Power Platform environment (Production)
- Power Apps Per App or Per User licenses
- Dataverse database capacity
- SharePoint Online (if using SharePoint as data source)
- Azure AD Premium P1+ (for security group management)

**Deployment Target:**
- Power Platform environments (DEV/TEST/PROD)
- Deployed as managed solutions in TEST/PROD
- Deployed as unmanaged solutions in DEV

## Localization

**Language:**
- German (Deutsch) - Primary language for UI and notifications
- German date formats: `d.m.yyyy` (e.g., `15.1.2025`)
- CET/CEST timezone handling via UDFs (`GetCETToday()`, `ConvertUTCToCET()`)

**Regional Settings:**
- Timezone: Central European Time (CET/CEST)
- Currency: Euro (implicit in German context)
- Number format: German format with comma decimal separator

---

*Stack analysis: 2026-01-18*
