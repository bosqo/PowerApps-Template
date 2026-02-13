# Role-Based Permission Matrix Design

**Date:** 2026-02-13
**Status:** Implemented
**Goal:** Centralize all role permissions, gallery visibility, and display metadata into explicit, editable tables.

---

## Problem

The previous system had permissions scattered across multiple locations:
- `UserPermissions` used inline `ActiveRole = "X" || ActiveRole = "Y"` logic per permission
- `RoleColor` and `RoleBadgeText` used separate `Switch()` statements
- Gallery visibility was implicitly derived from `CanViewAll` with no per-role control
- Adding a new role required editing 5+ locations
- Only 3 roles existed (Admin, Teamleitung, User) despite the architecture describing 6

## Solution: Three Central Tables

### 1. PermissionMatrix (CRUD + Special Permissions)

A single `Table()` Named Formula with one row per role and one column per permission.
All boolean values are explicit — you can read the full matrix at a glance.

```
┌──────────────┬───────┬────┬─────────┬────┬───────────────┬──────┐
│ Permission   │ Admin │ GF │ Manager │ HR │ Sachbearbeiter│ User │
├──────────────┼───────┼────┼─────────┼────┼───────────────┼──────┤
│ CanCreate    │  ✓    │    │    ✓    │    │      ✓        │      │
│ CanRead      │  ✓    │ ✓  │    ✓    │ ✓  │      ✓        │  ✓   │
│ CanEdit      │  ✓    │    │    ✓    │    │      ✓        │      │
│ CanDelete    │  ✓    │    │         │    │               │      │
│ CanViewAll   │  ✓    │ ✓  │    ✓    │ ✓  │               │      │
│ CanViewOwn   │  ✓    │ ✓  │    ✓    │ ✓  │      ✓        │  ✓   │
│ CanApprove   │  ✓    │ ✓  │    ✓    │    │               │      │
│ CanReject    │  ✓    │ ✓  │    ✓    │    │               │      │
│ CanArchive   │  ✓    │    │    ✓    │    │               │      │
│ CanExport    │  ✓    │ ✓  │    ✓    │ ✓  │               │      │
└──────────────┴───────┴────┴─────────┴────┴───────────────┴──────┘
```

**Usage:** `UserPermissions = LookUp(PermissionMatrix, Role = ActiveRole)`

### 2. RoleMetadata (Display Configuration)

Controls how each role appears in the UI. One row per role with priority, label, badge, and color.

| Role           | Priority | DisplayLabel       | BadgeText | BadgeColor       |
|----------------|----------|--------------------|-----------|------------------|
| Admin          | 1        | Administrator      | Admin     | Red (#D13438)    |
| GF             | 2        | Geschäftsführung   | GF        | Dark Blue        |
| Manager        | 3        | Manager            | MGR       | Blue (#0078D4)   |
| HR             | 4        | Personalwesen      | HR        | Amber (#FFB900)  |
| Sachbearbeiter | 5        | Sachbearbeiter     | SB        | Teal             |
| User           | 6        | Benutzer           | User      | Gray (#8A8886)   |

**Usage:** `RoleColor = LookUp(RoleMetadata, Role = ActiveRole, BadgeColor)`

### 3. GalleryVisibility (Record Visibility per Role)

Controls which records each role can see in galleries. Separate from CRUD permissions because "can edit" and "can see" are different concerns.

```
┌───────────────┬─────────┬──────┬──────┬──────────┐
│ Role          │ AllRec. │ Own  │ Dept │ Archived │
├───────────────┼─────────┼──────┼──────┼──────────┤
│ Admin         │   ✓     │  ✓   │  ✓   │    ✓     │
│ GF            │   ✓     │  ✓   │  ✓   │          │
│ Manager       │   ✓     │  ✓   │  ✓   │    ✓     │
│ HR            │   ✓     │  ✓   │      │          │
│ Sachbearbeiter│         │  ✓   │  ✓   │          │
│ User          │         │  ✓   │      │          │
└───────────────┴─────────┴──────┴──────┴──────────┘
```

**Usage:** `UserGalleryAccess = LookUp(GalleryVisibility, Role = ActiveRole)`

---

## How Derived Formulas Work

All downstream formulas use `LookUp()` against these tables:

```powerfx
// Permissions - one LookUp replaces 9 inline conditions
UserPermissions = LookUp(PermissionMatrix, Role = ActiveRole);

// Display - one LookUp replaces Switch() statements
RoleColor = LookUp(RoleMetadata, Role = ActiveRole, BadgeColor);
RoleBadgeText = LookUp(RoleMetadata, Role = ActiveRole, BadgeText);

// Gallery access - one LookUp replaces scattered If() chains
UserGalleryAccess = LookUp(GalleryVisibility, Role = ActiveRole);
```

UDFs like `HasPermission()`, `HasRole()`, `CanAccessRecord()`, `GetRoleLabel()` all derive from these lookups without any hardcoded role names.

---

## How to Add a New Role

Example: Adding "Auditor" role.

1. **RoleConfig** — Add `AuditorGroupId: "your-guid-here"`
2. **PermissionMatrix** — Add one row:
   ```powerfx
   {Role: "Auditor", CanCreate: false, CanRead: true, CanEdit: false, CanDelete: false, CanViewAll: true, CanViewOwn: true, CanApprove: false, CanReject: false, CanArchive: false, CanExport: true}
   ```
3. **RoleMetadata** — Add one row:
   ```powerfx
   {Role: "Auditor", Priority: 4, DisplayLabel: "Prüfer", BadgeText: "AUD", BadgeColor: RGBA(100, 100, 200, 1)}
   ```
4. **GalleryVisibility** — Add one row:
   ```powerfx
   {Role: "Auditor", SeeAllRecords: true, SeeOwnRecords: true, SeeDeptRecords: false, SeeArchived: true}
   ```
5. **ActiveRole** — Add priority check before the role it should rank above
6. **UserRoles** — Add `IsAuditor: ActiveRole = "Auditor"`
7. **HasRole()** — Add `"auditor", UserRoles.IsAuditor` case

## How to Add a New Permission

Example: Adding "CanImport" permission.

1. **PermissionMatrix** — Add `CanImport: true/false` to every row
2. **HasPermission()** — Add `"import", UserPermissions.CanImport` case

---

## Files Changed

| File | Changes |
|------|---------|
| `src/App-Formulas-Template.fx` | Added PermissionMatrix, RoleMetadata, GalleryVisibility tables; expanded to 6 roles; derived UserPermissions/RoleColor/RoleBadgeText via LookUp; added CanAccessDepartment, CanSeeArchived UDFs |
| `src/Control-Patterns-Modern.fx` | Updated gallery patterns to use CanSeeArchived() for role-based archived record visibility |
| `CLAUDE.md` | Updated roles & permissions documentation |
