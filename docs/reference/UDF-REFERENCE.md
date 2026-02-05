# UDF Reference - Power Fx User-Defined Functions

Complete reference of all User-Defined Functions (UDFs) in the PowerApps Canvas App Template.

**Source File:** `src/App-Formulas-Template.fx`

---

## Table of Contents

1. [Permission & Role Functions](#1-permission--role-functions)
2. [Data Access & Scoping Functions](#2-data-access--scoping-functions)
3. [Delegation-Safe Filter Functions](#3-delegation-safe-filter-functions)
4. [Theme & Color Functions](#4-theme--color-functions)
5. [Notification Functions](#5-notification-functions)
6. [Revert/Undo Functions](#6-revertundo-functions)
7. [Validation Functions](#7-validation-functions)
8. [Pagination Functions](#8-pagination-functions)
9. [Timezone Functions](#9-timezone-functions)
10. [Date & Time Formatting Functions](#10-date--time-formatting-functions)
11. [Text Formatting Functions](#11-text-formatting-functions)
12. [Error Message Functions](#12-error-message-functions)

---

## 1. Permission & Role Functions

Functions for checking user roles and permissions based on Azure AD group membership.

| UDF | Parameters | Returns | Description |
|-----|------------|---------|-------------|
| `HasPermission` | `permissionName: Text` | `Boolean` | Checks if user has a specific permission (create, read, edit, delete, viewall, viewown, approve, reject, archive) |
| `HasRole` | `roleName: Text` | `Boolean` | Checks if user has a specific role (admin, gf, manager, hr, sachbearbeiter, user) |
| `HasAnyRole` | `roleNames: Text` | `Boolean` | Checks if user has ANY of the comma-separated roles |
| `HasAllRoles` | `roleNames: Text` | `Boolean` | Checks if user has ALL of the comma-separated roles |
| `GetRoleLabel` | none | `Text` | Returns user's highest role as display label (German) |
| `GetRoleBadgeColor` | none | `Color` | Returns the theme color for user's role badge |
| `GetRoleBadge` | none | `Text` | Returns short role badge text (Admin, GF, Manager, etc.) |

### Why These Exist

These functions abstract Azure AD group membership checks into simple, reusable calls. Instead of checking `UserRoles.IsAdmin || UserRoles.IsManager` everywhere, you call `HasAnyRole("Admin,Manager")`.

### Usage Examples

```powerfx
// Check single permission
If(HasPermission("delete"), Remove(Items, ThisItem))

// Check any role
If(HasAnyRole("Admin,Manager,HR"), Set(ShowAdminPanel, true))

// Display role badge
lbl_RoleBadge.Text = GetRoleBadge()
lbl_RoleBadge.Fill = GetRoleBadgeColor()
```

---

## 2. Data Access & Scoping Functions

Functions for determining what data the current user can access based on ownership and department.

| UDF | Parameters | Returns | Description |
|-----|------------|---------|-------------|
| `GetUserScope` | none | `Text` | Returns user's email for filtering, or Blank() if user can view all |
| `GetDepartmentScope` | none | `Text` | Returns user's department for filtering, or Blank() if admin |
| `CanAccessRecord` | `ownerEmail: Text` | `Boolean` | Checks if user can access a record by owner email |
| `CanAccessDepartment` | `recordDepartment: Text` | `Boolean` | Checks if user can access records in a department |
| `CanAccessItem` | `ownerEmail: Text, department: Text` | `Boolean` | Combined check for owner AND department access |
| `CanEditRecord` | `ownerEmail: Text, status: Text` | `Boolean` | Checks if user can edit a record (considers status) |
| `CanDeleteRecord` | `ownerEmail: Text` | `Boolean` | Checks if user can delete a record |

### Why These Exist

Data scoping is critical for security. These functions implement row-level security by checking:
- **Ownership**: Users can only see/edit their own records unless they have ViewAll permission
- **Department**: Users can only see records in their department unless they're Admin
- **Status**: Records in "archived", "closed", or "cancelled" status cannot be edited

### Usage Examples

```powerfx
// Filter gallery to user's accessible records
Filter(Items, CanAccessRecord(Owner.Email))

// Conditional edit button visibility
btn_Edit.Visible = CanEditRecord(ThisItem.Owner, ThisItem.Status)

// Conditional delete button visibility
btn_Delete.Visible = CanDeleteRecord(ThisItem.Owner)
```

---

## 3. Delegation-Safe Filter Functions

Functions designed to work with SharePoint/Dataverse delegation for datasets >2000 records.

| UDF | Parameters | Returns | Description |
|-----|------------|---------|-------------|
| `CanViewAllData` | none | `Boolean` | Returns true if user has ViewAll permission |
| `MatchesSearchTerm` | `field: Text, term: Text` | `Boolean` | Delegation-safe text search using Search() |
| `MatchesStatusFilter` | `statusValue: Text` | `Boolean` | Delegation-safe status equality check |
| `CanViewRecord` | `ownerEmail: Text` | `Boolean` | Delegation-safe ownership + role check |
| `FilteredGalleryData` | `showMyItemsOnly: Boolean, selectedStatus: Text, searchTerm: Text` | `Table` | Combines all filter layers into one delegation-safe query |

### Why These Exist

Power Apps delegation limits queries to 2000 records by default. These functions use only delegable operations (equality, Search()) so they work with large datasets without hitting the delegation warning.

### Usage Examples

```powerfx
// Gallery Items property - fully delegation-safe
glr_Items.Items = FilteredGalleryData(
    tog_MyItemsOnly.Value,
    drp_StatusFilter.Selected.Value,
    txt_Search.Text
)

// Manual filter with delegation-safe functions
Filter(
    Items,
    CanViewRecord(Owner),
    MatchesStatusFilter(drp_Status.Selected.Value),
    MatchesSearchTerm(Title, txt_Search.Text)
)
```

---

## 4. Theme & Color Functions

Functions for retrieving colors based on semantic meaning (status, priority, theme).

| UDF | Parameters | Returns | Description |
|-----|------------|---------|-------------|
| `GetThemeColor` | `colorName: Text` | `Color` | Returns a named color from ThemeColors (primary, success, error, etc.) |
| `GetStatusColor` | `status: Text` | `Color` | Returns semantic color for status values (active=green, pending=amber, etc.) |
| `GetStatusIcon` | `status: Text` | `Text` | Returns built-in icon name for status values |
| `GetPriorityColor` | `priority: Text` | `Color` | Returns color for priority levels (critical=red, high=orange, etc.) |
| `GetHoverColor` | `baseColor: Color` | `Color` | Returns hover state color (20% darker via ColorFade) |
| `GetPressedColor` | `baseColor: Color` | `Color` | Returns pressed state color (30% darker via ColorFade) |
| `GetDisabledColor` | `baseColor: Color` | `Color` | Returns disabled state color (60% lighter via ColorFade) |
| `GetFocusColor` | `baseColor: Color` | `Color` | Returns focus border color (10% darker via ColorFade) |
| `GetToastBackground` | `toastType: Text` | `Color` | Returns background color for toast notifications |
| `GetToastBorderColor` | `toastType: Text` | `Color` | Returns border color for toast notifications |
| `GetToastIcon` | `toastType: Text` | `Text` | Returns icon character for toast notifications |
| `GetToastIconColor` | `toastType: Text` | `Color` | Returns icon color for toast notifications |

### Why These Exist

Centralized color management ensures:
- **Consistency**: Same status always has the same color across the app
- **Maintainability**: Change a color once in ThemeColors, updates everywhere
- **Semantics**: Colors convey meaning (green=success, red=error, amber=warning)

### Usage Examples

```powerfx
// Status badge color
lbl_StatusBadge.Fill = GetStatusColor(ThisItem.Status)

// Priority indicator
ico_Priority.Color = GetPriorityColor(ThisItem.Priority)

// Primary button with automatic states
btn_Submit.Fill = ThemeColors.Primary
btn_Submit.HoverFill = GetHoverColor(ThemeColors.Primary)
btn_Submit.PressedFill = GetPressedColor(ThemeColors.Primary)
btn_Submit.DisabledFill = GetDisabledColor(ThemeColors.Primary)

// Dynamic status button with hover
btn_StatusAction.Fill = GetStatusColor(ThisItem.Status)
btn_StatusAction.HoverFill = GetHoverColor(GetStatusColor(ThisItem.Status))
```

---

## 5. Notification Functions

Functions for showing user feedback via toast notifications (Phase 4 feature).

| UDF | Parameters | Returns | Description |
|-----|------------|---------|-------------|
| `NotifySuccess` | `message: Text` | `Void` | Shows green success toast, auto-dismisses after 5s |
| `NotifyError` | `message: Text` | `Void` | Shows red error toast, requires manual dismiss |
| `NotifyWarning` | `message: Text` | `Void` | Shows amber warning toast, auto-dismisses after 5s |
| `NotifyInfo` | `message: Text` | `Void` | Shows blue info toast, auto-dismisses after 5s |
| `NotifyPermissionDenied` | `action: Text` | `Void` | Shows error toast with permission denied message |
| `NotifyActionCompleted` | `action: Text, itemName: Text` | `Void` | Shows success toast for completed action |
| `NotifyValidationError` | `fieldName: Text, message: Text` | `Void` | Shows warning toast for validation failure |
| `AddToast` | `message: Text, toastType: Text, shouldAutoClose: Boolean, duration: Number` | `Void` | Low-level: adds toast to NotificationStack collection |
| `RemoveToast` | `toastID: Number` | `Void` | Low-level: removes toast from NotificationStack |

### Why These Exist

Toast notifications provide non-blocking feedback following Fluent Design patterns:
- **Non-blocking**: User can continue working while notification shows
- **Semantic**: Type determines color, icon, and auto-dismiss behavior
- **Consistent**: Same notification style across the entire app

### Usage Examples

```powerfx
// Form submission success
btn_Save.OnSelect =
    If(
        SubmitForm(form_Edit),
        NotifySuccess("Record saved successfully"),
        NotifyError("Save failed: " & form_Edit.Error)
    )

// Permission check with notification
btn_Delete.OnSelect =
    If(
        CanDeleteRecord(ThisItem.Owner),
        Remove(Items, ThisItem); NotifyActionCompleted("Delete", ThisItem.Title),
        NotifyPermissionDenied("delete records")
    )

// Validation feedback
If(
    !IsValidEmail(txt_Email.Text),
    NotifyValidationError("Email", "Invalid email format")
)
```

---

## 6. Revert/Undo Functions

Functions for showing toasts with undo/revert buttons (Phase 4 extended feature).

| UDF | Parameters | Returns | Description |
|-----|------------|---------|-------------|
| `AddToastWithRevert` | `message, toastType, shouldAutoClose, duration, hasRevert, revertLabel, revertData, revertCallbackID` | `Void` | Adds toast with optional revert button |
| `HandleRevert` | `toastID: Number, callbackID: Number, revertData: Record` | `Void` | Executes revert action when user clicks undo |
| `NotifyWithRevert` | `message, notificationType, revertLabel, revertData, revertCallbackID` | `Void` | Generic notification with revert option |
| `NotifySuccessWithRevert` | `message, revertLabel, revertData, revertCallbackID` | `Void` | Success notification with revert option |
| `NotifyDeleteWithUndo` | `itemName: Text, revertData: Record` | `Void` | Delete confirmation with "Undo" button |
| `NotifyArchiveWithUndo` | `itemName: Text, revertData: Record` | `Void` | Archive confirmation with "Restore" button |

### Why These Exist

Undo functionality improves user experience for destructive actions:
- **Safety**: Users can recover from accidental deletes
- **Confidence**: Users feel safer performing actions knowing they can undo
- **Workflow**: Delete → Show undo toast → User has 5s to revert

### Callback IDs

| ID | Action | Description |
|----|--------|-------------|
| 0 | DELETE_UNDO | Restores deleted item by patching revertData back |
| 1 | ARCHIVE_UNDO | Reactivates archived item by setting Status="Active" |
| 2+ | CUSTOM | Custom handlers (extend HandleRevert switch statement) |

### Usage Examples

```powerfx
// Delete with undo
btn_Delete.OnSelect =
    With(
        {deletedItem: ThisItem},
        Remove(Items, ThisItem);
        NotifyDeleteWithUndo(
            deletedItem.Title,
            {
                ItemID: deletedItem.ID,
                ItemName: deletedItem.Title,
                Title: deletedItem.Title,
                Status: deletedItem.Status,
                Owner: deletedItem.Owner
            }
        )
    )

// Archive with restore
btn_Archive.OnSelect =
    Patch(Items, ThisItem, {Status: "Archived"});
    NotifyArchiveWithUndo(
        ThisItem.Title,
        {ItemID: ThisItem.ID, ItemName: ThisItem.Title}
    )
```

---

## 7. Validation Functions

Functions for validating user input.

| UDF | Parameters | Returns | Description |
|-----|------------|---------|-------------|
| `IsValidEmail` | `email: Text` | `Boolean` | Validates email format (no spaces, exactly one @, valid domain) |
| `IsOneOf` | `value: Text, allowedValues: Text` | `Boolean` | Checks if value is in comma-separated list |
| `IsAlphanumeric` | `input: Text` | `Boolean` | Checks if text contains only a-z, A-Z, 0-9 |
| `IsNotPastDate` | `inputDate: Date` | `Boolean` | Checks if date is today or future |
| `IsDateInRange` | `inputDate: Date, minDate: Date, maxDate: Date` | `Boolean` | Checks if date falls within range |

### Why These Exist

Input validation prevents bad data from reaching the database:
- **Data Quality**: Ensure emails are valid before saving
- **Business Rules**: Due dates must be in the future
- **User Feedback**: Show validation errors before form submission

### Usage Examples

```powerfx
// Email validation
If(!IsValidEmail(txt_Email.Text), NotifyValidationError("Email", "Invalid format"))

// Status validation
If(!IsOneOf(drp_Status.Selected.Value, "Draft,Pending,Active"),
   NotifyWarning("Invalid status selected"))

// Date validation
If(!IsNotPastDate(dat_DueDate.SelectedDate),
   NotifyValidationError("Due Date", "Cannot be in the past"))

// Date range validation
If(!IsDateInRange(dat_EventDate.SelectedDate, DateRanges.Today, DateRanges.EndOfYear),
   NotifyValidationError("Event Date", "Must be within this year"))
```

---

## 8. Pagination Functions

Functions for implementing pagination in galleries.

| UDF | Parameters | Returns | Description |
|-----|------------|---------|-------------|
| `GetTotalPages` | `totalItems: Number, pageSize: Number` | `Number` | Calculates total page count |
| `GetSkipCount` | `currentPage: Number, pageSize: Number` | `Number` | Calculates items to skip for current page |
| `CanGoToPreviousPage` | `currentPage: Number` | `Boolean` | Checks if previous page exists |
| `CanGoToNextPage` | `currentPage: Number, totalItems: Number, pageSize: Number` | `Boolean` | Checks if next page exists |
| `GetPageRangeText` | `currentPage: Number, pageSize: Number, totalItems: Number` | `Text` | Returns "1-50 of 1234" display text |

### Why These Exist

Pagination is essential for large datasets:
- **Performance**: Only load 50 items at a time instead of 5000
- **UX**: Users can navigate through pages
- **Delegation**: Works with FirstN(Skip()) pattern

### Usage Examples

```powerfx
// Gallery Items with pagination
glr_Items.Items = FirstN(
    Skip(
        Filter(Items, CanViewRecord(Owner)),
        GetSkipCount(ActiveFilters.CurrentPage, AppConfig.ItemsPerPage)
    ),
    AppConfig.ItemsPerPage
)

// Previous button
btn_Previous.Disabled = !CanGoToPreviousPage(ActiveFilters.CurrentPage)
btn_Previous.OnSelect = Set(ActiveFilters, Patch(ActiveFilters, {CurrentPage: ActiveFilters.CurrentPage - 1}))

// Next button
btn_Next.Disabled = !CanGoToNextPage(ActiveFilters.CurrentPage, CountRows(Items), AppConfig.ItemsPerPage)

// Page info label
lbl_PageInfo.Text = GetPageRangeText(ActiveFilters.CurrentPage, AppConfig.ItemsPerPage, CountRows(Items))
```

---

## 9. Timezone Functions

Functions for converting between UTC (SharePoint storage) and CET/CEST (German timezone).

| UDF | Parameters | Returns | Description |
|-----|------------|---------|-------------|
| `IsDaylightSavingTime` | `checkDate: Date` | `Boolean` | Checks if date falls in CEST (summer time) |
| `ConvertUTCToCET` | `utcDateTime: DateTime` | `DateTime` | Converts UTC to CET/CEST |
| `ConvertCETToUTC` | `mezDateTime: DateTime` | `DateTime` | Converts CET/CEST to UTC |
| `GetCETTime` | none | `DateTime` | Returns current time in CET timezone |
| `GetCETToday` | none | `Date` | Returns today's date in CET timezone |

### Why These Exist

SharePoint and Dataverse store all DateTime fields in UTC. German users expect:
- **Local time display**: "15:30" not "13:30" (UTC)
- **Correct date comparisons**: `Today()` uses device timezone, not CET
- **DST handling**: Automatic switch between CET (UTC+1) and CEST (UTC+2)

### Critical Rule

**NEVER use `Today()` to compare with SharePoint dates!** Always use `GetCETToday()`.

### Usage Examples

```powerfx
// Check if item is overdue (CORRECT)
If(ThisItem.'Due Date' < GetCETToday(), "Overdue", "On Track")

// Display modified time in CET
lbl_Modified.Text = FormatDateTimeCET(ThisItem.'Modified')

// Convert user input to UTC before saving
Patch(Items, ThisItem, {
    'Due Date': ConvertCETToUTC(dat_DueDate.SelectedDate)
})
```

---

## 10. Date & Time Formatting Functions

Functions for formatting dates in German format.

| UDF | Parameters | Returns | Description |
|-----|------------|---------|-------------|
| `FormatDateShort` | `inputDate: Date` | `Text` | Returns "15.1.2025" format |
| `FormatDateLong` | `inputDate: Date` | `Text` | Returns "15. Januar 2025" format |
| `FormatDateTime` | `inputDateTime: DateTime` | `Text` | Returns "15.1.2025 14:30" format |
| `FormatDateTimeCET` | `utcDateTime: DateTime` | `Text` | Converts UTC to CET then formats |
| `FormatDateRelative` | `inputDate: Date` | `Text` | Returns "Heute", "Gestern", "vor 3 Tagen", etc. |

### Why These Exist

German date formatting differs from English:
- **Format**: d.m.yyyy (not mm/dd/yyyy)
- **Language**: "Januar" not "January"
- **Relative**: "vor 3 Tagen" not "3 days ago"

### Usage Examples

```powerfx
// Short date display
lbl_CreatedDate.Text = FormatDateShort(ThisItem.'Created')

// Long date for headers
lbl_ReportDate.Text = FormatDateLong(GetCETToday())

// UTC to CET formatted display
lbl_LastModified.Text = FormatDateTimeCET(ThisItem.'Modified')

// Relative date for activity feeds
lbl_ActivityDate.Text = FormatDateRelative(DateValue(ThisItem.'Created'))
```

---

## 11. Text Formatting Functions

Functions for formatting numbers and text.

| UDF | Parameters | Returns | Description |
|-----|------------|---------|-------------|
| `FormatCurrency` | `amount: Number, currencySymbol: Text` | `Text` | Returns "$1,234.00" format |
| `FormatPercent` | `value: Number, decimals: Number` | `Text` | Returns "75.5%" format |
| `GetInitials` | `fullName: Text` | `Text` | Returns "JD" from "John Doe" |

### Why These Exist

Consistent formatting across the app:
- **Currency**: Proper thousands separator and decimals
- **Percent**: Convert 0.75 to "75%" automatically
- **Initials**: Avatar placeholders when no image available

### Usage Examples

```powerfx
// Currency display
lbl_Total.Text = FormatCurrency(ThisItem.Amount, "EUR ")

// Percentage display
lbl_Progress.Text = FormatPercent(ThisItem.Completion, 1)

// User avatar initials
lbl_Avatar.Text = GetInitials(ThisItem.Owner.DisplayName)
```

---

## 12. Error Message Functions

Functions returning localized German error messages.

| UDF | Parameters | Returns | Description |
|-----|------------|---------|-------------|
| `ErrorMessage_ProfileLoadFailed` | `connectorName: Text` | `Text` | Profile loading error message |
| `ErrorMessage_DataRefreshFailed` | `operationType: Text` | `Text` | Data operation error message |
| `ErrorMessage_PermissionDenied` | `actionName: Text` | `Text` | Permission denied message |
| `ErrorMessage_Generic` | none | `Text` | Generic fallback error message |
| `ErrorMessage_ValidationFailed` | `fieldName: Text, reason: Text` | `Text` | Validation error message |
| `ErrorMessage_NetworkError` | none | `Text` | Network connection error message |
| `ErrorMessage_TimeoutError` | none | `Text` | Request timeout error message |
| `ErrorMessage_NotFound` | `itemType: Text` | `Text` | Item not found error message |

### Why These Exist

User-friendly error messages in German:
- **No technical jargon**: "Verbindung fehlgeschlagen" not "HTTP 500"
- **Actionable**: "Bitte überprüfen Sie Ihre Internetverbindung"
- **Consistent tone**: Professional German throughout

### Usage Examples

```powerfx
// Critical path error handling
IfError(
    Office365Users.MyProfileV2(),
    Set(AppState, Patch(AppState, {
        ShowErrorDialog: true,
        ErrorMessage: ErrorMessage_ProfileLoadFailed("Office365Users")
    }))
)

// Data operation error
IfError(
    Remove(Items, ThisItem),
    NotifyError(ErrorMessage_DataRefreshFailed("delete"))
)

// Permission error
If(
    !HasPermission("approve"),
    NotifyError(ErrorMessage_PermissionDenied("Genehmigen"))
)
```

---

## Quick Reference Table (All UDFs)

| # | UDF | Category | Returns | Line |
|---|-----|----------|---------|------|
| 1 | `HasPermission` | Permission | Boolean | 549 |
| 2 | `HasRole` | Permission | Boolean | 565 |
| 3 | `HasAnyRole` | Permission | Boolean | 580 |
| 4 | `HasAllRoles` | Permission | Boolean | 591 |
| 5 | `GetRoleLabel` | Permission | Text | 600 |
| 6 | `GetRoleBadgeColor` | Permission | Color | 612 |
| 7 | `GetRoleBadge` | Permission | Text | 615 |
| 8 | `GetUserScope` | Access | Text | 625 |
| 9 | `GetDepartmentScope` | Access | Text | 629 |
| 10 | `CanAccessRecord` | Access | Boolean | 633 |
| 11 | `CanAccessDepartment` | Access | Boolean | 639 |
| 12 | `CanAccessItem` | Access | Boolean | 645 |
| 13 | `CanEditRecord` | Access | Boolean | 649 |
| 14 | `CanDeleteRecord` | Access | Boolean | 655 |
| 15 | `CanViewAllData` | Filter | Boolean | 669 |
| 16 | `MatchesSearchTerm` | Filter | Boolean | 677 |
| 17 | `MatchesStatusFilter` | Filter | Boolean | 689 |
| 18 | `CanViewRecord` | Filter | Boolean | 702 |
| 19 | `FilteredGalleryData` | Filter | Table | 723 |
| 20 | `GetThemeColor` | Theme | Color | 747 |
| 21 | `GetStatusColor` | Theme | Color | 782 |
| 22 | `GetStatusIcon` | Theme | Text | 825 |
| 23 | `GetPriorityColor` | Theme | Color | 840 |
| 24 | `GetToastBackground` | Toast | Color | 920 |
| 25 | `GetToastBorderColor` | Toast | Color | 931 |
| 26 | `GetToastIcon` | Toast | Text | 942 |
| 27 | `GetToastIconColor` | Toast | Color | 953 |
| 28 | `NotifySuccess` | Notification | Void | 964 |
| 29 | `NotifyError` | Notification | Void | 970 |
| 30 | `NotifyWarning` | Notification | Void | 976 |
| 31 | `NotifyInfo` | Notification | Void | 982 |
| 32 | `NotifyPermissionDenied` | Notification | Void | 988 |
| 33 | `NotifyActionCompleted` | Notification | Void | 1002 |
| 34 | `NotifyValidationError` | Notification | Void | 1016 |
| 35 | `AddToast` | Notification | Void | 1052 |
| 36 | `RemoveToast` | Notification | Void | 1077 |
| 37 | `AddToastWithRevert` | Revert | Void | 1120 |
| 38 | `HandleRevert` | Revert | Void | 1165 |
| 39 | `NotifyWithRevert` | Revert | Void | 1225 |
| 40 | `NotifySuccessWithRevert` | Revert | Void | 1261 |
| 41 | `NotifyDeleteWithUndo` | Revert | Void | 1281 |
| 42 | `NotifyArchiveWithUndo` | Revert | Void | 1295 |
| 43 | `IsValidEmail` | Validation | Boolean | 1313 |
| 44 | `IsOneOf` | Validation | Boolean | 1338 |
| 45 | `IsAlphanumeric` | Validation | Boolean | 1350 |
| 46 | `IsNotPastDate` | Validation | Boolean | 1356 |
| 47 | `IsDateInRange` | Validation | Boolean | 1362 |
| 48 | `GetTotalPages` | Pagination | Number | 1375 |
| 49 | `GetSkipCount` | Pagination | Number | 1379 |
| 50 | `CanGoToPreviousPage` | Pagination | Boolean | 1383 |
| 51 | `CanGoToNextPage` | Pagination | Boolean | 1387 |
| 52 | `GetPageRangeText` | Pagination | Text | 1391 |
| 53 | `IsDaylightSavingTime` | Timezone | Boolean | 1410 |
| 54 | `ConvertUTCToCET` | Timezone | DateTime | 1417 |
| 55 | `ConvertCETToUTC` | Timezone | DateTime | 1429 |
| 56 | `GetCETTime` | Timezone | DateTime | 1443 |
| 57 | `GetCETToday` | Timezone | Date | 1447 |
| 58 | `FormatDateShort` | Formatting | Text | 1458 |
| 59 | `FormatDateLong` | Formatting | Text | 1462 |
| 60 | `FormatDateTime` | Formatting | Text | 1467 |
| 61 | `FormatDateTimeCET` | Formatting | Text | 1476 |
| 62 | `FormatDateRelative` | Formatting | Text | 1488 |
| 63 | `FormatCurrency` | Formatting | Text | 1518 |
| 64 | `FormatPercent` | Formatting | Text | 1522 |
| 65 | `GetInitials` | Formatting | Text | 1526 |
| 66 | `ErrorMessage_ProfileLoadFailed` | Error | Text | 1552 |
| 67 | `ErrorMessage_DataRefreshFailed` | Error | Text | 1560 |
| 68 | `ErrorMessage_PermissionDenied` | Error | Text | 1572 |
| 69 | `ErrorMessage_Generic` | Error | Text | 1576 |
| 70 | `ErrorMessage_ValidationFailed` | Error | Text | 1579 |
| 71 | `ErrorMessage_NetworkError` | Error | Text | 1583 |
| 72 | `ErrorMessage_TimeoutError` | Error | Text | 1586 |
| 73 | `ErrorMessage_NotFound` | Error | Text | 1589 |

---

## Naming Convention Summary

| Prefix | Category | Return Type | Example |
|--------|----------|-------------|---------|
| `Has*` | Permission check | Boolean | `HasRole("Admin")` |
| `Can*` | Access/action check | Boolean | `CanEditRecord(email, status)` |
| `Is*` | Validation | Boolean | `IsValidEmail(text)` |
| `Get*` | Retrieval | Various | `GetThemeColor("primary")` |
| `Format*` | Formatting | Text | `FormatDateShort(date)` |
| `Convert*` | Conversion | DateTime | `ConvertUTCToCET(datetime)` |
| `Notify*` | Notification | Void | `NotifySuccess("Saved")` |
| `Matches*` | Filter | Boolean | `MatchesSearchTerm(field, term)` |
| `ErrorMessage_*` | Error text | Text | `ErrorMessage_Generic` |
