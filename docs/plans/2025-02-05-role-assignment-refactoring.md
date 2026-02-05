# Role Assignment System Refactoring Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Refactor the role assignment system to eliminate magic strings, enable Office365Groups integration, consolidate role configuration into a single source of truth, and improve code readability for template reuse.

**Architecture:** Create a centralized `RoleConfiguration` Named Formula containing role metadata (Azure AD GUIDs, permissions, display labels) as a single record. Replace scattered role name strings and permission logic with UDFs that reference this configuration. Enable Office365Groups integration with proper caching and validation.

**Tech Stack:** Power Fx 2025 (Named Formulas, UDFs, Collections, Office365Groups connector)

---

## Current State Analysis

**Problem Summary:**
1. All role assignments hardcoded to `false` (non-functional out-of-the-box)
2. Role names scattered as magic strings in 3+ locations
3. Permission logic duplicated between `UserPermissions` record and `HasPermission()` UDF
4. No single source of truth for role configuration
5. Azure AD group IDs commented out with placeholders

**Files Affected:**
- `/src/App-Formulas-Template.fx` (lines 391-738) - Role definition, permissions, access control
- `/src/App-OnStart-Minimal.fx` (lines 271-363) - Role initialization, caching
- `/docs/UDF-REFERENCE.md` - Documentation (out of sync)

**Current Risk:** Implementing new roles requires edits in 5+ locations; missing/misspelled strings fail silently.

---

## Task 1: Create RoleConfiguration Constant

**Objective:** Single source of truth for all role metadata (name, Azure AD GUID, permissions, labels, colors)

**Files:**
- Modify: `src/App-Formulas-Template.fx:364-390` (insert new RoleConfiguration before UserRoles)

**Step 1: Design RoleConfiguration structure**

RoleConfiguration will be a record containing:
- `AdminGroupID` - Azure AD Security Group GUID for Admin role
- `ManagerGroupID` - Azure AD Security Group GUID for Manager role
- `HRGroupID` - Azure AD Security Group GUID for HR role
- `GFGroupID` - Azure AD Security Group GUID for Geschäftsführer role
- `SachbearbeiterGroupID` - Azure AD Security Group GUID for Sachbearbeiter role
- `RoleNames` - Table with columns: RoleName (Text), IsAdmin, IsManager, IsHR, IsGF, IsSachbearbeiter, DisplayLabel (German), BadgeText (short), RoleColor
- `Permissions` - Table with columns: PermissionName, RoleRequirements (array of role names allowed)

**Step 2: Add RoleConfiguration Named Formula**

Insert this before line 391 (before `UserRoles`):

```powerfx
RoleConfiguration = {
    // Azure AD Security Group IDs - REQUIRED: Replace with actual GUIDs
    AdminGroupID: "00000000-0000-0000-0000-000000000001",        // TODO: Your Admin Group GUID
    ManagerGroupID: "00000000-0000-0000-0000-000000000002",      // TODO: Your Manager Group GUID
    HRGroupID: "00000000-0000-0000-0000-000000000003",           // TODO: Your HR Group GUID
    GFGroupID: "00000000-0000-0000-0000-000000000004",           // TODO: Your GF Group GUID
    SachbearbeiterGroupID: "00000000-0000-0000-0000-000000000005", // TODO: Your Sachbearbeiter Group GUID

    // Role metadata for display and access control
    Roles: Table(
        {
            Name: "admin",
            DisplayLabel: "Administrator",
            BadgeText: "Admin",
            Color: RGBA(217, 48, 37, 1),             // Dark red
            GroupID: "00000000-0000-0000-0000-000000000001"
        },
        {
            Name: "gf",
            DisplayLabel: "Geschäftsführer",
            BadgeText: "GF",
            Color: RGBA(0, 33, 71, 1),               // Dark blue
            GroupID: "00000000-0000-0000-0000-000000000004"
        },
        {
            Name: "manager",
            DisplayLabel: "Manager",
            BadgeText: "Manager",
            Color: RGBA(0, 120, 212, 1),             // Blue
            GroupID: "00000000-0000-0000-0000-000000000002"
        },
        {
            Name: "hr",
            DisplayLabel: "HR",
            BadgeText: "HR",
            Color: RGBA(255, 185, 0, 1),             // Amber
            GroupID: "00000000-0000-0000-0000-000000000003"
        },
        {
            Name: "sachbearbeiter",
            DisplayLabel: "Sachbearbeiter",
            BadgeText: "Sachbearbeiter",
            Color: RGBA(84, 175, 233, 1),            // Light blue
            GroupID: "00000000-0000-0000-0000-000000000005"
        },
        {
            Name: "user",
            DisplayLabel: "Benutzer",
            BadgeText: "User",
            Color: RGBA(128, 128, 128, 1),           // Gray
            GroupID: Blank()                         // All users
        }
    ),

    // Permission to required roles mapping
    Permissions: Table(
        {PermissionName: "create", AllowedRoles: "admin,manager,sachbearbeiter"},
        {PermissionName: "read", AllowedRoles: "admin,manager,hr,sachbearbeiter,user"},
        {PermissionName: "edit", AllowedRoles: "admin,manager,sachbearbeiter"},
        {PermissionName: "delete", AllowedRoles: "admin"},
        {PermissionName: "viewall", AllowedRoles: "admin,manager,hr"},
        {PermissionName: "viewown", AllowedRoles: "admin,manager,hr,sachbearbeiter,user"},
        {PermissionName: "approve", AllowedRoles: "admin,manager"},
        {PermissionName: "reject", AllowedRoles: "admin,manager"},
        {PermissionName: "archive", AllowedRoles: "admin,manager"}
    )
};
```

**Step 3: Verify structure**

- [ ] `RoleConfiguration.Roles` is a table with 6 rows (one per role)
- [ ] `RoleConfiguration.Permissions` is a table with 9 rows (one per permission)
- [ ] All color values use RGBA() function (4 parameters)
- [ ] All GroupID fields are GUIDs (36 chars with hyphens) or Blank()
- [ ] All permission names are lowercase
- [ ] All role names in AllowedRoles are lowercase, comma-separated

**Step 4: Commit**

```bash
git add src/App-Formulas-Template.fx
git commit -m "refactor: add RoleConfiguration constant for centralized role metadata

- Create single source of truth for role names, colors, labels, GUIDs
- Replace scattered magic strings with structured configuration
- Support easy role/permission changes without code edits
- Template ready for Azure AD integration"
```

---

## Task 2: Refactor UserRoles to Use RoleConfiguration

**Objective:** Replace hardcoded role booleans with dynamic role checks using RoleConfiguration

**Files:**
- Modify: `src/App-Formulas-Template.fx:391-452` (refactor UserRoles Named Formula)

**Step 1: Update UserRoles to check RoleConfiguration GUIDs**

Replace the entire UserRoles formula (lines 391-452) with:

```powerfx
UserRoles = {
    IsAdmin:
        IfError(
            Office365Groups.CheckMembershipAsync(
                RoleConfiguration.AdminGroupID,
                User().Email
            ).value,
            false  // Default to false if check fails
        ),
    IsGF:
        IfError(
            Office365Groups.CheckMembershipAsync(
                RoleConfiguration.GFGroupID,
                User().Email
            ).value,
            false
        ),
    IsManager:
        IfError(
            Office365Groups.CheckMembershipAsync(
                RoleConfiguration.ManagerGroupID,
                User().Email
            ).value,
            false
        ),
    IsHR:
        IfError(
            Office365Groups.CheckMembershipAsync(
                RoleConfiguration.HRGroupID,
                User().Email
            ).value,
            false
        ),
    IsSachbearbeiter:
        IfError(
            Office365Groups.CheckMembershipAsync(
                RoleConfiguration.SachbearbeiterGroupID,
                User().Email
            ).value,
            false
        ),
    IsUser: true  // All authenticated users are "User" role
};
```

**Step 2: Enable caching logic in UserRoles**

Wrap the formula in cache check (if not already present):

```powerfx
UserRoles =
    If(
        IsBlank(CachedRolesCache),
        // Cache miss: Evaluate role checks and store in cache
        With(
            {
                roles: {
                    IsAdmin: IfError(Office365Groups.CheckMembershipAsync(RoleConfiguration.AdminGroupID, User().Email).value, false),
                    IsGF: IfError(Office365Groups.CheckMembershipAsync(RoleConfiguration.GFGroupID, User().Email).value, false),
                    IsManager: IfError(Office365Groups.CheckMembershipAsync(RoleConfiguration.ManagerGroupID, User().Email).value, false),
                    IsHR: IfError(Office365Groups.CheckMembershipAsync(RoleConfiguration.HRGroupID, User().Email).value, false),
                    IsSachbearbeiter: IfError(Office365Groups.CheckMembershipAsync(RoleConfiguration.SachbearbeiterGroupID, User().Email).value, false),
                    IsUser: true
                }
            },
            Patch(roles, {_Cached: Now()})  // Add timestamp for debugging
        ),
        // Cache hit: Return first cached record
        First(CachedRolesCache)
    );
```

**Step 3: Verify Office365Groups references**

- [ ] All 5 Office365Groups.CheckMembershipAsync calls reference RoleConfiguration GUIDs
- [ ] All calls wrapped in IfError() with fallback to `false`
- [ ] IsUser always returns `true`
- [ ] Caching logic preserves performance (warm start returns cached value)

**Step 4: Commit**

```bash
git add src/App-Formulas-Template.fx
git commit -m "refactor: integrate RoleConfiguration into UserRoles

- Replace commented-out hardcoded roles with dynamic Office365Groups checks
- Reference GUIDs from RoleConfiguration constant
- Add IfError() handling for failed AD checks
- Enable warm-start caching with timestamp tracking"
```

---

## Task 3: Create Role and Permission Lookup UDFs

**Objective:** Replace magic string matching with RoleConfiguration lookups to prevent silent failures

**Files:**
- Modify: `src/App-Formulas-Template.fx:565-615` (add helper UDFs before HasRole)

**Step 1: Add RoleInfo lookup UDF**

Insert before line 565 (before HasRole):

```powerfx
RoleInfo(roleName: Text): Record =
    LookUp(
        RoleConfiguration.Roles,
        Lower(Name) = Lower(roleName)
    );
```

**Step 2: Add PermissionInfo lookup UDF**

```powerfx
PermissionInfo(permissionName: Text): Record =
    LookUp(
        RoleConfiguration.Permissions,
        Lower(PermissionName) = Lower(permissionName)
    );
```

**Step 3: Add ValidateRoleName UDF**

```powerfx
ValidateRoleName(roleName: Text): Boolean =
    Not(IsBlank(RoleInfo(roleName)));
```

**Step 4: Add validation to HasRole UDF**

Replace lines 565-575 (HasRole) with:

```powerfx
HasRole(roleName: Text): Boolean =
    If(
        IsBlank(RoleInfo(roleName)),
        Error({Message: "Invalid role name: " & roleName & ". Valid roles: admin, gf, manager, hr, sachbearbeiter, user"}),
        Switch(
            Lower(roleName),
            "admin", UserRoles.IsAdmin,
            "gf", UserRoles.IsGF,
            "manager", UserRoles.IsManager,
            "hr", UserRoles.IsHR,
            "sachbearbeiter", UserRoles.IsSachbearbeiter,
            "user", UserRoles.IsUser,
            false
        )
    );
```

**Step 5: Verify UDFs**

- [ ] RoleInfo() returns a record with all role metadata columns
- [ ] RoleInfo("invalid") returns Blank()
- [ ] PermissionInfo() lookup works correctly
- [ ] ValidateRoleName() returns true for valid roles, false for invalid
- [ ] HasRole() throws Error for invalid role names (won't fail silently anymore)

**Step 6: Commit**

```bash
git add src/App-Formulas-Template.fx
git commit -m "refactor: add role/permission lookup UDFs with validation

- Add RoleInfo() to look up role metadata from RoleConfiguration
- Add PermissionInfo() to look up permission requirements
- Add ValidateRoleName() helper
- Update HasRole() to throw Error() on invalid role names
- Prevent silent failures from typos in role names"
```

---

## Task 4: Refactor Permission Check UDFs

**Objective:** Derive permissions from RoleConfiguration.Permissions table instead of hardcoded logic

**Files:**
- Modify: `src/App-Formulas-Template.fx:474-489` (UserPermissions) and `src/App-Formulas-Template.fx:549-562` (HasPermission)

**Step 1: Update UserPermissions to reference RoleConfiguration**

Replace lines 474-489 (UserPermissions record) with:

```powerfx
UserPermissions = {
    CanCreate: Or(Split(LookUp(RoleConfiguration.Permissions, Lower(PermissionName)="create").AllowedRoles, ","),
        LookUp(RoleConfiguration.Permissions, Lower(PermissionName)="create").AllowedRoles,
        (role: Text) => HasRole(role)),

    CanRead: Or(Split(LookUp(RoleConfiguration.Permissions, Lower(PermissionName)="read").AllowedRoles, ","),
        LookUp(RoleConfiguration.Permissions, Lower(PermissionName)="read").AllowedRoles,
        (role: Text) => HasRole(role)),

    CanEdit: Or(Split(LookUp(RoleConfiguration.Permissions, Lower(PermissionName)="edit").AllowedRoles, ","),
        LookUp(RoleConfiguration.Permissions, Lower(PermissionName)="edit").AllowedRoles,
        (role: Text) => HasRole(role)),

    CanDelete: Or(Split(LookUp(RoleConfiguration.Permissions, Lower(PermissionName)="delete").AllowedRoles, ","),
        LookUp(RoleConfiguration.Permissions, Lower(PermissionName)="delete").AllowedRoles,
        (role: Text) => HasRole(role)),

    CanViewAll: Or(Split(LookUp(RoleConfiguration.Permissions, Lower(PermissionName)="viewall").AllowedRoles, ","),
        LookUp(RoleConfiguration.Permissions, Lower(PermissionName)="viewall").AllowedRoles,
        (role: Text) => HasRole(role)),

    CanViewOwn: Or(Split(LookUp(RoleConfiguration.Permissions, Lower(PermissionName)="viewown").AllowedRoles, ","),
        LookUp(RoleConfiguration.Permissions, Lower(PermissionName)="viewown").AllowedRoles,
        (role: Text) => HasRole(role)),

    CanApprove: Or(Split(LookUp(RoleConfiguration.Permissions, Lower(PermissionName)="approve").AllowedRoles, ","),
        LookUp(RoleConfiguration.Permissions, Lower(PermissionName)="approve").AllowedRoles,
        (role: Text) => HasRole(role)),

    CanReject: Or(Split(LookUp(RoleConfiguration.Permissions, Lower(PermissionName)="reject").AllowedRoles, ","),
        LookUp(RoleConfiguration.Permissions, Lower(PermissionName)="reject").AllowedRoles,
        (role: Text) => HasRole(role)),

    CanArchive: Or(Split(LookUp(RoleConfiguration.Permissions, Lower(PermissionName)="archive").AllowedRoles, ","),
        LookUp(RoleConfiguration.Permissions, Lower(PermissionName)="archive").AllowedRoles,
        (role: Text) => HasRole(role))
};
```

**Step 2: Add CanUserPerform helper UDF**

Insert before HasPermission:

```powerfx
CanUserPerform(permissionName: Text): Boolean =
    If(
        IsBlank(PermissionInfo(permissionName)),
        Error({Message: "Invalid permission: " & permissionName}),
        Or(
            Split(PermissionInfo(permissionName).AllowedRoles, ","),
            PermissionInfo(permissionName).AllowedRoles,
            (role: Text) => HasRole(Trim(role))
        )
    );
```

**Step 3: Update HasPermission to use CanUserPerform**

Replace lines 549-562 (HasPermission) with:

```powerfx
HasPermission(permissionName: Text): Boolean =
    CanUserPerform(permissionName);
```

**Step 4: Verify permissions**

- [ ] UserPermissions record now derives from RoleConfiguration.Permissions
- [ ] HasPermission() delegates to CanUserPerform()
- [ ] CanUserPerform() throws Error on invalid permission names
- [ ] Changing permission in RoleConfiguration.Permissions automatically updates UserPermissions
- [ ] No duplication between UserPermissions and HasPermission logic

**Step 5: Commit**

```bash
git add src/App-Formulas-Template.fx
git commit -m "refactor: derive permissions from RoleConfiguration

- Replace hardcoded permission logic with RoleConfiguration lookups
- Add CanUserPerform() UDF for dynamic permission checks
- Permissions now single source of truth (RoleConfiguration.Permissions)
- Add validation to throw Error on invalid permission names
- One edit point for adding/removing permissions"
```

---

## Task 5: Consolidate Role Display Functions

**Objective:** Replace 3 scattered role display sources (RoleColor, RoleBadgeText, GetRoleLabel) with single UDFs that reference RoleConfiguration.Roles

**Files:**
- Modify: `src/App-Formulas-Template.fx:491-615` (consolidate role display logic)

**Step 1: Replace RoleColor Named Formula**

Replace lines 491-500 (RoleColor) with:

```powerfx
RoleColor =
    With(
        {highestRole: GetHighestRoleInfo()},
        If(
            IsBlank(highestRole),
            RGBA(128, 128, 128, 1),  // Gray for "user" role
            highestRole.Color
        )
    );
```

**Step 2: Replace RoleBadgeText Named Formula**

Replace lines 503-511 (RoleBadgeText) with:

```powerfx
RoleBadgeText =
    With(
        {highestRole: GetHighestRoleInfo()},
        If(
            IsBlank(highestRole),
            "User",
            highestRole.BadgeText
        )
    );
```

**Step 3: Add GetHighestRoleInfo helper UDF**

Insert before RoleColor:

```powerfx
GetHighestRoleInfo(): Record =
    // Return role info for highest-priority role user has
    // Priority: admin > gf > manager > hr > sachbearbeiter > user
    With(
        {
            roles: Filter(
                RoleConfiguration.Roles,
                HasRole(Name) = true
            )
        },
        If(
            CountRows(roles) = 0,
            LookUp(RoleConfiguration.Roles, Lower(Name) = "user"),  // Default to "user"
            Index(
                Sort(
                    roles,
                    Name,
                    SortOrder.Ascending  // admin comes first alphabetically
                ),
                1
            )
        )
    );
```

**Step 4: Update GetRoleLabel UDF**

Replace lines 600-609 (GetRoleLabel) with:

```powerfx
GetRoleLabel(): Text =
    With(
        {highestRole: GetHighestRoleInfo()},
        If(
            IsBlank(highestRole),
            "Benutzer",
            highestRole.DisplayLabel
        )
    );
```

**Step 5: Update GetRoleBadgeColor UDF**

Replace line 612 (GetRoleBadgeColor) with:

```powerfx
GetRoleBadgeColor(): Color =
    RoleColor;
```

**Step 6: Update GetRoleBadge UDF**

Replace line 615 (GetRoleBadge) with:

```powerfx
GetRoleBadge(): Text =
    RoleBadgeText;
```

**Step 7: Verify consolidation**

- [ ] All role colors come from RoleConfiguration.Roles
- [ ] All role labels (English & German) come from RoleConfiguration.Roles
- [ ] GetHighestRoleInfo() prioritizes admin > gf > manager > hr > sachbearbeiter > user
- [ ] Default fallback to "user" role works correctly
- [ ] No hardcoded role names or colors remain

**Step 8: Commit**

```bash
git add src/App-Formulas-Template.fx
git commit -m "refactor: consolidate role display logic

- Replace scattered role colors/labels with RoleConfiguration lookups
- Add GetHighestRoleInfo() to determine priority role for display
- All role metadata now single source of truth
- No more maintaining color/label mapping in 3 places"
```

---

## Task 6: Fix Office365Users Caching

**Objective:** Use With() to cache Office365Users.MyProfileV2() result, prevent repeated API calls

**Files:**
- Modify: `src/App-OnStart-Minimal.fx:310-331` (fix Office365Users caching)

**Step 1: Wrap Office365Users calls in With()**

Replace lines 314-318 with:

```powerfx
With(
    {profile: Office365Users.MyProfileV2()},
    {
        DisplayName: profile.DisplayName,
        Email: profile.UserPrincipalName,
        Department: If(IsBlank(profile.Department), "(Unbekannt)", profile.Department),
        JobTitle: profile.JobTitle,
        MobilePhone: profile.MobilePhone
    }
)
```

**Step 2: Verify only one API call**

- [ ] Office365Users.MyProfileV2() appears only once in the formula
- [ ] All field references use `profile.FieldName` (not separate calls)
- [ ] Result is same as before (no logic change, only performance)

**Step 3: Commit**

```bash
git add src/App-OnStart-Minimal.fx
git commit -m "fix: cache Office365Users.MyProfileV2() with With()

- Prevent multiple API calls to MyProfileV2()
- Store result in profile variable
- Improves startup performance (one call instead of 5)
- No behavior change, pure performance optimization"
```

---

## Task 7: Add Department Fallback

**Objective:** Handle blank department safely without breaking filtering

**Files:**
- Modify: `src/App-Formulas-Template.fx:625-630` (GetDepartmentScope)

**Step 1: Update GetDepartmentScope with fallback**

Replace line 629-630 (GetDepartmentScope) with:

```powerfx
GetDepartmentScope(): Text =
    If(
        UserRoles.IsAdmin,
        Blank(),  // Admin sees all departments
        If(
            IsBlank(UserProfile.Department),
            "(Unbekannt)",  // Fallback: show only records with unknown department
            UserProfile.Department
        )
    );
```

**Step 2: Update CanAccessDepartment to handle fallback**

Replace lines 639-642 with:

```powerfx
CanAccessDepartment(recordDept: Text): Boolean =
    If(
        UserRoles.IsAdmin,
        true,  // Admin access all departments
        If(
            IsBlank(recordDept),
            UserProfile.Department = Blank() || UserProfile.Department = "(Unbekannt)",
            recordDept = UserProfile.Department
        )
    );
```

**Step 3: Verify fallback behavior**

- [ ] GetDepartmentScope() returns "(Unbekannt)" if user's department is blank
- [ ] CanAccessDepartment() handles both blank and "(Unbekannt)" correctly
- [ ] Admin users still see all departments regardless
- [ ] Non-admin users without department only see records with matching "(Unbekannt)" value

**Step 4: Commit**

```bash
git add src/App-Formulas-Template.fx
git commit -m "fix: add department fallback for users with blank department

- GetDepartmentScope() returns '(Unbekannt)' instead of blank
- CanAccessDepartment() handles both blank and fallback value
- Prevents silent filtering when department not loaded
- Non-admin users can still access department-scoped records"
```

---

## Task 8: Add Comprehensive Documentation

**Objective:** Update docs to reflect new RoleConfiguration approach

**Files:**
- Modify: `docs/UDF-REFERENCE.md` - Update role permission sections
- Modify: `docs/App-Formulas-Design.md` - Add RoleConfiguration section
- Modify: `CLAUDE.md` - Update role configuration instructions

**Step 1: Update UDF-REFERENCE.md**

Add new section after Role & Permission UDFs (around line 200):

```markdown
## Role Configuration

### RoleConfiguration Named Formula

Central configuration for all role-related metadata. Modify this formula to:
- Replace GROUP_IDs with your Azure AD Security Group GUIDs
- Add/remove roles by editing RoleConfiguration.Roles table
- Modify permissions by editing RoleConfiguration.Permissions table

**Fields:**
- `AdminGroupID` - Azure AD GUID for Admin role
- `ManagerGroupID` - Azure AD GUID for Manager role
- `HRGroupID` - Azure AD GUID for HR role
- `GFGroupID` - Azure AD GUID for Geschäftsführer role
- `SachbearbeiterGroupID` - Azure AD GUID for Sachbearbeiter role
- `Roles` - Table with role metadata (name, label, color, GroupID)
- `Permissions` - Table with permission to role mappings

**Usage:**
```powerfx
// Lookup a role's color
LookUp(RoleConfiguration.Roles, Name="admin").Color

// Get all roles allowed for a permission
LookUp(RoleConfiguration.Permissions, PermissionName="viewall").AllowedRoles
// Returns: "admin,manager,hr"
```

### Helper UDFs

| UDF | Returns | Beschreibung |
|-----|---------|-------------|
| `RoleInfo(name)` | Record | Look up role metadata from RoleConfiguration |
| `PermissionInfo(name)` | Record | Look up permission requirements from RoleConfiguration |
| `ValidateRoleName(name)` | Boolean | Check if role name is valid |
| `CanUserPerform(permission)` | Boolean | Check if user has permission (validates input) |
| `GetHighestRoleInfo()` | Record | Get user's highest-priority role for display |

### Configuration Required

Before first deployment, update these GROUP_IDs in RoleConfiguration:

1. Get Azure AD Security Group GUIDs (PowerShell or Azure Portal)
2. Open `src/App-Formulas-Template.fx`
3. Find RoleConfiguration (around line 364)
4. Replace placeholder GUIDs:
   - `"00000000-0000-0000-0000-000000000001"` → Your Admin Group GUID
   - etc.
5. Test in Power Apps Studio (roles should load after authentication)
```

**Step 2: Update App-Formulas-Design.md**

Add section on role inheritance strategy:

```markdown
## Role System Architecture

### Role Priority/Inheritance

Roles follow an implicit priority hierarchy for display purposes:

```
Admin (highest priority)
  ↓
Geschäftsführer (GF)
  ↓
Manager
  ↓
HR
  ↓
Sachbearbeiter
  ↓
User (default, all users)
```

A user assigned to multiple groups displays their highest-priority role. For example:
- User is member of both "Manager" and "Sachbearbeiter" groups → displays as "Manager"
- User is member of "HR" and "Sachbearbeiter" → displays as "HR"

### Adding a New Role

To add a new role (e.g., "Auditor"):

1. Add Azure AD Security Group (get GUID)
2. Edit RoleConfiguration in App-Formulas-Template.fx:
   - Add `AuditorGroupID` field
   - Add new row to `Roles` table with name, label, color, GroupID
   - Add new row to `Permissions` table with permission requirements
3. Edit UserRoles formula to add Office365Groups check:
   ```powerfx
   IsAuditor: IfError(Office365Groups.CheckMembershipAsync(...), false)
   ```
4. Update role priority in GetHighestRoleInfo() sorting logic
5. Test with Azure AD user who is member of new group
```

**Step 3: Update CLAUDE.md**

Replace role configuration section (around line 186-217):

```markdown
### Rollen-System (6 Rollen) - Mit RoleConfiguration

| Rolle | Deutsch | Azure AD Config |
|-------|---------|-----------------|
| Admin | Administrator | RoleConfiguration.AdminGroupID |
| GF | Geschäftsführer | RoleConfiguration.GFGroupID |
| Manager | Manager | RoleConfiguration.ManagerGroupID |
| HR | HR | RoleConfiguration.HRGroupID |
| Sachbearbeiter | Sachbearbeiter | RoleConfiguration.SachbearbeiterGroupID |
| User | Benutzer | N/A (all users) |

**Konfiguration erforderlich**:

1. Öffne `src/App-Formulas-Template.fx` (Zeile ~364)
2. Ersetze alle `"00000000-0000-0000-0000-000000000000"` mit echten Azure AD Gruppen-GUIDs:
   - Admin-Gruppe GUID
   - Manager-Gruppe GUID
   - etc.
3. Speichern und App neu starten
4. Rollen werden automatisch aus Azure AD geladen

**Single Source of Truth:** Alle Rolle konfiguriert in RoleConfiguration:
```powerfx
RoleConfiguration.Roles        // Role names, colors, labels, GUIDs
RoleConfiguration.Permissions  // Permission to role mapping
```

Neue Rollen oder Permissions hinzufügen: Nur RoleConfiguration bearbeiten!
```

**Step 4: Verify documentation**

- [ ] UDF-REFERENCE.md explains RoleConfiguration structure
- [ ] Configuration section has step-by-step instructions
- [ ] App-Formulas-Design.md has role priority explanation
- [ ] Instructions for adding new roles are clear
- [ ] CLAUDE.md role section updated with RoleConfiguration reference
- [ ] All code examples use new UDFs (RoleInfo, PermissionInfo, etc.)

**Step 5: Commit**

```bash
git add docs/UDF-REFERENCE.md docs/App-Formulas-Design.md CLAUDE.md
git commit -m "docs: update role system documentation for RoleConfiguration

- Add RoleConfiguration structure and usage guide
- Document role priority/inheritance model
- Add step-by-step Azure AD GUID configuration instructions
- Explain how to add new roles using single source of truth
- Update CLAUDE.md with RoleConfiguration references"
```

---

## Task 9: Add Validation Tests

**Objective:** Create test cases to verify role assignments work correctly (manual testing guide)

**Files:**
- Create: `docs/ROLE-SYSTEM-TESTING.md`

**Step 1: Create testing guide**

```markdown
# Role System Testing Guide

## Pre-Deployment Testing Checklist

Before deploying the template to production, verify role system functionality:

### 1. Configuration Validation

**Test:** GUIDs are valid Azure AD Security Group IDs

```
Steps:
1. Open Azure Portal → Azure AD → Groups
2. Note the GUIDs for each role group:
   - Admin Group GUID
   - Manager Group GUID
   - etc.
3. Open src/App-Formulas-Template.fx line ~364
4. Verify all 5 GUIDs match your groups (not placeholders)
5. Save and reload app
```

**Expected Result:** No errors in formula bar; app loads normally

### 2. Role Assignment Test

**Test:** Users inherit roles from Azure AD groups

```
Steps:
1. Add test user to "Manager" Azure AD group in Azure Portal
2. Wait 5-10 minutes for Azure AD sync
3. Log in as test user in Power Apps
4. Open monitor (F12) and check NotificationStack
5. Look for GetRoleLabel() result or user profile display

Expected: Badge shows "Manager" (not "User")
```

### 3. Permission Inheritance Test

**Test:** Permissions calculate correctly from roles

```
Steps for each role:

Admin user:
1. Log in as admin user
2. Verify: CanDelete = true, CanViewAll = true, CanApprove = true
3. Test delete button - should be enabled

Manager user:
1. Log in as manager
2. Verify: CanDelete = false, CanViewAll = true, CanApprove = true
3. Test delete button - should be disabled

Sachbearbeiter user:
1. Log in as sachbearbeiter
2. Verify: CanDelete = false, CanViewAll = false, CanApprove = false
3. Test readonly mode - should only see own records

Regular user:
1. Log in as user not in any role group
2. Verify: CanDelete = false, CanViewAll = false
3. Test readonly mode - should only see own records
```

### 4. Cache Validation Test

**Test:** Role information is cached correctly

```
Steps:
1. Open Power Apps Monitor (F12)
2. Log in as a user
3. Check Network tab - verify Office365Groups calls appear once
4. Refresh app (F5)
5. Check Network tab again
6. Expected: Office365Groups NOT called again (using cache)
7. Wait 5+ minutes for cache TTL to expire
8. Refresh again
9. Expected: Office365Groups called again (cache expired)
```

### 5. Invalid Role Name Validation

**Test:** Invalid role names throw errors

```
Steps:
1. Open Power Apps Monitor console
2. In formula bar, try: HasRole("invalid_role_name")
3. Expected: Error message "Invalid role name: invalid_role_name..."
4. Verify: Silent failures no longer possible
```

### 6. Invalid Permission Name Validation

**Test:** Invalid permission names throw errors

```
Steps:
1. In formula bar, try: HasPermission("invalid_permission")
2. Expected: Error message "Invalid permission: invalid_permission"
3. Verify: Permission typos caught immediately
```

### 7. Department Filtering Test

**Test:** Department-based access control works

```
Steps for HR user:
1. Log in as HR user
2. Verify: GetDepartmentScope() returns Blank() (HR sees all)
3. Test filtering - should see records from all departments

Steps for Sachbearbeiter user:
1. Log in as sachbearbeiter in "Sales" department
2. Verify: GetDepartmentScope() returns "Sales"
3. Test filtering - should only see Sales records

Steps for user with blank department:
1. Create test user with no department in Azure AD
2. Log in as that user
3. Verify: GetDepartmentScope() returns "(Unbekannt)"
4. Test filtering - should see records with "(Unbekannt)" department
```

### 8. Multiple Roles Test

**Test:** Users with multiple roles display highest-priority role

```
Steps:
1. Add test user to both "Manager" and "Sachbearbeiter" groups
2. Wait for Azure AD sync
3. Log in as test user
4. Verify: GetRoleLabel() returns "Manager" (not "Sachbearbeiter")
5. Verify: GetRoleBadge() shows "Manager" badge
6. Verify: GetRoleBadgeColor() is blue (Manager color, not light blue)
```

### 9. Performance Baseline

**Test:** Startup time remains <2 seconds

```
Steps:
1. Open Power Apps Monitor (F12)
2. Force clear cache (close app, reopen)
3. Log in - measure OnStart execution time
4. Expected: <2000ms total startup time
5. Record baseline in `.planning/PERF-BASELINE.txt`

Timeline:
- Critical path (profile + roles): 500-800ms
- Background data (departments, categories): 300-500ms
- User-scoped data (my items, pending tasks): 200-300ms
- Total: ~1050-1850ms
```

### 10. Error Handling Test

**Test:** App degrades gracefully if Office365 unavailable

```
Steps:
1. Disconnect from network
2. Try to log in / refresh app
3. Expected:
   - IfError() catches Office365 errors
   - Default roles: IsUser=true, others=false
   - App still loads with minimal role
4. Reconnect network
5. Refresh app
6. Verify: Role data reloads correctly
```

## Automation Testing (Future)

For larger deployments, consider:
- Automated role assignment test in Power Automate
- Regression test suite for permission matrix
- Integration test for Office365Groups → Power Apps sync
- Performance monitoring dashboard for startup times

---

## Common Issues & Troubleshooting

| Symptom | Cause | Solution |
|---------|-------|----------|
| All users show as "User" | GROUP_IDs are placeholders | Replace GUIDs in RoleConfiguration |
| Roles not loading | Azure AD sync delay | Wait 5-10 minutes after group assignment |
| Invalid role error | Typo in HasRole() call | Check role name (case-sensitive, lowercase) |
| Delete button showing when shouldn't | Permission logic error | Verify CanDelete in UserPermissions |
| Cache never expires | TTL formula wrong | Check CacheTimestamp initialization |
| Performance degraded | Office365Groups called per formula | Use cache with UserRoles check |

---

## Sign-Off Checklist

- [ ] All 5 Azure AD GROUP_IDs configured
- [ ] At least 1 user from each role tested
- [ ] Startup time baseline recorded (<2s)
- [ ] Cache validation verified (Office365Groups called once)
- [ ] Permission inheritance working for all 6 roles
- [ ] Invalid role/permission names throw errors
- [ ] Department filtering works correctly
- [ ] Error handling tested (graceful degradation)
- [ ] Ready for production deployment
```

**Step 2: Commit**

```bash
git add docs/ROLE-SYSTEM-TESTING.md
git commit -m "docs: add comprehensive role system testing guide

- Step-by-step tests for role assignment, permissions, caching
- Configuration validation checklist
- Performance baseline procedures
- Error handling and troubleshooting
- Sign-off checklist before production"
```

---

## Task 10: Update CLAUDE.md Index

**Objective:** Ensure all documentation changes are reflected in CLAUDE.md index

**Files:**
- Modify: `CLAUDE.md` (lines 40-100) - update documentation table

**Step 1: Update documentation references**

Replace docs table section with:

```markdown
### Dokumentation (23 Dateien - Updated für RoleConfiguration)

**Architektur & Design:**
| Datei | Beschreibung |
|-------|-------------|
| `docs/App-Formulas-Design.md` | Architektur-Dokumentation, Layer-Konzept, **Role Priority/Inheritance** |
| `docs/UDF-REFERENCE.md` | **Vollständige API-Referenz aller 35+ UDFs + RoleConfiguration Guide** |
| `docs/UI-DESIGN-REFERENCE.md` | Fluent Design Implementation Guide |
| `docs/POWER-PLATFORM-BEST-PRACTICES.md` | Platform-weite Best Practices |

**Role System (NEW):**
| Datei | Beschreibung |
|-------|-------------|
| `docs/ROLE-SYSTEM-TESTING.md` | **Umfassender Test-Guide für Rollen-System** |
| `docs/ROLE-CONFIGURATION-GUIDE.md` | (Future) Step-by-step Azure AD Integration |

...rest of docs...
```

**Step 2: Add section on RoleConfiguration to Rollen-System section**

Ensure section links to relevant docs:

```markdown
### Rollen-System (6 Rollen) - RoleConfiguration (Single Source of Truth)

**Dokumentation:** Siehe `docs/ROLE-SYSTEM-TESTING.md` für vollständigen Test-Guide.

**Single Source:** `RoleConfiguration` Named Formula enthält:
- `Roles` - Role Metadata (Name, Label, Color, GUIDs)
- `Permissions` - Permission to Role Mapping
- `...GroupID` - Azure AD Security Group GUIDs
```

**Step 3: Commit**

```bash
git add CLAUDE.md
git commit -m "docs: update CLAUDE.md for RoleConfiguration system

- Add ROLE-SYSTEM-TESTING.md reference
- Link to new role configuration guide
- Update Rollen-System section with RoleConfiguration emphasis
- Consistent with refactored role architecture"
```

---

## Implementation Roadmap

**Execution Order (Sequential):**
1. **Task 1:** Create RoleConfiguration constant (foundation)
2. **Task 2:** Refactor UserRoles to use RoleConfiguration
3. **Task 3:** Create Role/Permission lookup UDFs
4. **Task 4:** Refactor Permission check UDFs
5. **Task 5:** Consolidate role display functions
6. **Task 6:** Fix Office365Users caching (performance)
7. **Task 7:** Add department fallback (robustness)
8. **Tasks 8-10:** Documentation updates (polish)

**Total Commits:** 10 (one per task, atomic changes)

**Estimated Duration:** 2-3 hours of focused work

---

## Success Criteria

After completing all tasks:

- [ ] **No magic strings:** All role names, permissions, colors in RoleConfiguration
- [ ] **Validation:** Invalid role/permission names throw Error() (no silent failures)
- [ ] **Single source of truth:** Role configuration in one place (RoleConfiguration)
- [ ] **Performance:** Office365Users.MyProfileV2() called once per session
- [ ] **Robustness:** Department fallback handles blank values gracefully
- [ ] **Readability:** Code clearly shows intent (fewer inline calculations)
- [ ] **Reusability:** Future projects can fork template, only update RoleConfiguration
- [ ] **Documentation:** Clear setup instructions, testing guide, troubleshooting
- [ ] **Functionality:** All 6 roles work, permissions inherit correctly, caching validates

---

## Rollback Plan

If issues encountered, revert commits in reverse order:

```bash
# Revert last commit
git revert HEAD

# Revert to before refactoring started
git reset --hard <commit-before-task-1>
```

Maintain Git history to allow partial rollback if only certain tasks cause issues.
