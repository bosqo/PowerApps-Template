# Power Fx Formula Audit Report
**Date**: 2026-01-10
**Scope**: App.Formulas implementation for Canvas Apps
**Status**: ❌ Issues Found - Corrections Required

---

## Executive Summary

During code review, several Power Fx functions were identified that are **NOT valid** in Canvas Apps. These functions either:
1. Do not exist in Canvas Apps
2. Have incorrect syntax
3. Are from different Power Fx contexts (Excel, Power Automate, etc.)

**Files Affected**:
- `App-Formulas-Design.md`
- `App-OnStart-Template.fx`
- `Datasource-Filter-Patterns.fx`
- `App-Formulas-README.md`

---

## Issues Identified

### ❌ ISSUE #1: Lambda() Function
**Severity**: HIGH
**Location**: `App-Formulas-Design.md` lines 286-320

**Problem**:
```powerfx
// ❌ INVALID in Canvas Apps
ApplyDataFilter = Lambda(
    dataSource: Table,
    additionalFilter: Boolean,
    Filter(...)
);
```

**Explanation**:
- `Lambda()` is NOT available in Canvas Apps
- Lambda functions exist in Excel and are planned for Power Fx, but not currently in Canvas Apps
- The syntax shown with type annotations (`dataSource: Table`) is also not valid

**Solution**:
User-Defined Functions (UDFs) were introduced in 2025 but have different syntax:
```powerfx
// ✅ VALID - Named Formula (no parameters, constant only)
MyConstant = "Value";

// ⚠️ FUTURE - UDF syntax (in preview/limited availability)
// Syntax: FunctionName(Param1: Type): ReturnType = Formula
```

**Recommended Approach**: Remove Lambda pattern entirely and use direct Filter() calls inline.

---

### ❌ ISSUE #2: User().Image for ID
**Severity**: MEDIUM
**Location**:
- `App-Formulas-Design.md` line 23
- Similar usage pattern across files

**Problem**:
```powerfx
// ❌ INVALID usage
Id: User().Image
```

**Explanation**:
- `User().Image` returns binary image data, NOT a user ID
- There is NO `User().Id` function in Canvas Apps
- The `User()` function only provides: `.Email`, `.FullName`, `.Image`

**Solution**:
```powerfx
// ✅ VALID - Use email as unique identifier
Email: User().Email  // This IS the user's unique identifier

// ❌ REMOVE this line
Id: User().Image
```

---

### ❌ ISSUE #3: Export() Function
**Severity**: HIGH
**Location**:
- `App-Formulas-Design.md` line 383
- `Datasource-Filter-Patterns.fx` line 255
- `App-Formulas-README.md` multiple references

**Problem**:
```powerfx
// ❌ INVALID - Export() does not exist in Canvas Apps
Export(Gallery.AllItems, "export.xlsx")
```

**Explanation**:
- `Export()` is NOT a built-in Canvas Apps function
- There is no native function to export data to Excel/CSV directly

**Solution Options**:

**Option 1: Power Automate (Recommended)**
```powerfx
// Button_Export.OnSelect
If(
    App.User.Permissions.CanExport,

    // Trigger a Power Automate flow
    'ExportFlow'.Run(
        JSON(Gallery.AllItems)
    );
    Notify("Export started, you'll receive an email", NotificationType.Success),

    Notify("Export permission required", NotificationType.Error)
)
```

**Option 2: Navigate to Excel/SharePoint**
```powerfx
// Create a SharePoint list or Excel file, then navigate
Navigate(ExcelScreen, ScreenTransition.None)
```

**Option 3: Custom Component**
```powerfx
// Use Power Apps Component Framework (PCF) custom export component
CustomExportComponent.Export(Gallery.AllItems)
```

**Recommendation**: Update all Export() references to indicate this requires Power Automate or a custom solution.

---

### ⚠️ ISSUE #4: Office365Users.MyProfileV2()
**Severity**: MEDIUM
**Location**: Multiple files, heavily used

**Problem**:
```powerfx
// ⚠️ Syntax needs verification
Profile: Office365Users.MyProfileV2()
JobTitle: Office365Users.MyProfileV2().jobTitle
```

**Explanation**:
- The correct function name might be `MyProfile()` (V1) or `MyProfileV2()`
- Function availability depends on which version of the connector is added
- The V2 suffix suggests this is the newer version

**Verification Needed**:
- Check in Power Apps Studio what shows in intellisense
- The V2 function does exist but may not be available in all environments
- Properties available: `displayName`, `givenName`, `jobTitle`, `mail`, `mobilePhone`, `officeLocation`, `surname`, `userPrincipalName`, `id`

**Recommendation**:
- Use `MyProfileV2()` but add a note that users should verify in their environment
- Add error handling in case the function isn't available
- Alternative: Use `Office365Users.UserProfileV2(User().Email)` which is more explicit

**Corrected Approach**:
```powerfx
// ✅ More robust - with error handling
With(
    {userProfile: Office365Users.MyProfileV2()},
    Set(App.User, {
        Email: User().Email,
        FullName: User().FullName,
        JobTitle: If(IsBlank(userProfile.jobTitle), "", userProfile.jobTitle),
        Department: If(IsBlank(userProfile.department), "", userProfile.department)
    })
)
```

---

### ⚠️ ISSUE #5: Connection.Connected
**Severity**: LOW
**Location**: Multiple files

**Problem**:
```powerfx
// ⚠️ Syntax needs verification
IsOnline: Connection.Connected
```

**Explanation**:
- The Connection object exists but the correct property is `Connection.Connected` (Boolean)
- This should work, but it's read-only and reflects the app's connection status

**Status**: ✅ VALID - This is correct syntax

---

### ⚠️ ISSUE #6: Office365Groups.ListGroupMembers()
**Severity**: LOW
**Location**: Multiple files

**Problem**:
```powerfx
// ⚠️ Verify return structure
LookUp(
    Office365Groups.ListGroupMembers("group-id"),
    mail = User().Email
)
```

**Explanation**:
- The function exists and is correct
- However, the return structure needs verification for the LookUp
- The returned table might have different column names depending on API version

**Verification**:
- Common column names in return: `mail`, `userPrincipalName`, `displayName`, `id`
- The comparison `mail = User().Email` should work

**Status**: ✅ MOSTLY VALID - but users should verify column names

---

### ❌ ISSUE #7: Circular Reference in App.User
**Severity**: LOW
**Location**: Permission calculations in App.OnStart

**Problem**:
```powerfx
Set(App.User, {
    Roles: {
        IsAdmin: !IsBlank(LookUp(...))
    },
    Permissions: {
        // ⚠️ Tries to reference App.User.Roles before it's fully set
        CanCreate: App.User.Roles.IsAdmin || App.User.Roles.IsManager
    }
});
```

**Explanation**:
- When setting a record, you cannot reference itself during initialization
- This will cause errors in Canvas Apps

**Solution**: Split into two Set statements
```powerfx
// ✅ CORRECTED - Step 1: Set roles
Set(App.User, {
    Email: User().Email,
    FullName: User().FullName,
    Roles: {
        IsAdmin: !IsBlank(LookUp(...)),
        IsManager: !IsBlank(LookUp(...)),
        IsUser: true
    }
});

// ✅ CORRECTED - Step 2: Set permissions using roles
Set(App.User,
    Patch(App.User, {
        Permissions: {
            CanCreate: App.User.Roles.IsAdmin || App.User.Roles.IsManager,
            CanEdit: App.User.Roles.IsAdmin || App.User.Roles.IsManager,
            CanDelete: App.User.Roles.IsAdmin
        }
    })
);
```

---

### ⚠️ ISSUE #8: Multiple API Calls to Office365Users.MyProfileV2()
**Severity**: MEDIUM (Performance)
**Location**: App.OnStart - called 3+ times

**Problem**:
```powerfx
Set(App.User, {
    Profile: Office365Users.MyProfileV2(),        // Call 1
    JobTitle: Office365Users.MyProfileV2().jobTitle,  // Call 2
    Department: Office365Users.MyProfileV2().department // Call 3
});
```

**Explanation**:
- Each call to MyProfileV2() is a separate API request
- This is inefficient and slows down app startup

**Solution**: Use With() to call once
```powerfx
// ✅ CORRECTED - Single API call
With(
    {profile: Office365Users.MyProfileV2()},
    Set(App.User, {
        Email: User().Email,
        FullName: User().FullName,
        JobTitle: profile.jobTitle,
        Department: profile.department,
        OfficeLocation: profile.officeLocation,
        MobilePhone: profile.mobilePhone
    })
);
```

---

## Summary of Required Changes

| Issue | Severity | Action Required |
|-------|----------|----------------|
| Lambda() function | HIGH | Remove entirely, use inline Filter() |
| User().Image for ID | MEDIUM | Remove this line |
| Export() function | HIGH | Document that Power Automate is needed |
| MyProfileV2() syntax | MEDIUM | Verify and add error handling |
| Connection.Connected | LOW | No change needed - valid |
| ListGroupMembers() | LOW | Add note to verify column names |
| Circular reference | LOW | Split into two Set() statements |
| Multiple API calls | MEDIUM | Use With() for optimization |

---

## Testing Recommendations

After corrections:

1. **Test in actual Canvas App environment**:
   - Copy corrected formulas to App.OnStart
   - Check for red squiggly lines (syntax errors)
   - Use IntelliSense to verify function names

2. **Test with real user accounts**:
   - Verify Office365Users functions work
   - Test with users in security groups
   - Test with users not in security groups

3. **Check delegation warnings**:
   - Monitor for yellow warning triangles
   - Ensure Filter operations delegate properly

4. **Performance testing**:
   - Measure App.OnStart execution time
   - Optimize if > 2-3 seconds

---

## References

For verification, consult:
- [Power Fx Formula Reference for Canvas Apps](https://learn.microsoft.com/en-us/power-platform/power-fx/formula-reference-canvas-apps)
- [Named Formulas in Power Apps](https://www.microsoft.com/en-us/power-platform/blog/power-apps/power-fx-introducing-named-formulas/)
- [Office365Users Connector Reference](https://learn.microsoft.com/en-us/connectors/office365users/)
- [Office365Groups Connector Reference](https://learn.microsoft.com/en-us/connectors/office365groups/)

---

## Next Steps

1. ✅ Create this audit report
2. ⏳ Fix all HIGH severity issues
3. ⏳ Fix MEDIUM severity issues
4. ⏳ Update all documentation files
5. ⏳ Create corrected templates
6. ⏳ Add warning notes where verification is needed
7. ⏳ Commit corrected version

---

*Audit completed by: Claude Code*
*Review status: Pending corrections*
