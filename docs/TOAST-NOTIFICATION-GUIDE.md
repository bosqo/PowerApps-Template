# Toast Notification System Guide

**Purpose:** Understand how notifications work, when to use each type, and how to customize behavior
**Audience:** PowerApps developers implementing app features that need user feedback
**Related:** [QUICK-START.md](./QUICK-START.md), [CLAUDE.md - Notification API](../CLAUDE.md#notification-system)

## When to Use Notifications

| Scenario | UDF | Auto-Dismiss | Example |
|----------|-----|--------------|---------|
| Record saved, action completed | `NotifySuccess` | Yes (5s) | "Record saved" |
| Required field missing, invalid data | `NotifyWarning` | Yes (5s) | "Email format invalid" |
| Save failed, no permission, server error | `NotifyError` | No (manual X) | "Failed to save: Check network" |
| Status update, informational message | `NotifyInfo` | Yes (5s) | "Loading data..." |

---

## How Notifications Work

Toast notifications use a three-layer architecture: triggers → state management → UI rendering.

### Layer 1: Trigger UDFs (App-Formulas-Template.fx)

Developers call these. They handle both system notification and custom toast:

```powerfx
NotifySuccess(message: Text): Void = {
    Notify(message, NotificationType.Success);  // System banner at top
    AddToast(message, "Success", true, 5000)    // Custom toast in corner
};
```

The UDF simultaneously displays:
- System banner (top of screen, 3 seconds, auto-dismisses)
- Custom toast (top-right corner, styled by type, manages its own lifecycle)

### Layer 2: State Management (App.OnStart & App-Formulas)

Internal helpers that maintain the notification stack:

```powerfx
AddToast(message, type, autoClose, duration): Void = {
    // Adds row to NotificationStack collection
    Patch(NotificationStack, Defaults(NotificationStack), {
        ID: NotificationCounter,
        Message: message,
        Type: type,              // "Success", "Error", "Warning", "Info"
        AutoClose: autoClose,    // true = auto-dismiss, false = manual only
        Duration: duration,      // milliseconds until auto-dismiss
        CreatedAt: Now(),        // for timeout calculation
        IsVisible: true          // rendered
    });
    // Increments counter for next unique ID
    Set(NotificationCounter, NotificationCounter + 1);
};
```

The `RemoveToast(ID)` UDF removes a specific toast from collection (called by close button or auto-dismiss timeout).

### Layer 3: UI Rendering (Control-Patterns-Modern.fx, Pattern 1.9)

Container and controls that display toasts:

- **Parent container:** `cnt_NotificationStack` (top-right corner, fixed overlay, high ZIndex)
- **Child tiles:** `cnt_Toast` (repeats for each row in `NotificationStack` collection)
- **Styling:** Dynamic colors via `GetToastBackground(Type)`, icons via `GetToastIcon(Type)`
- **Interaction:** Close button calls `RemoveToast(ID)` to remove specific toast
- **Auto-dismiss:** Opacity fades when elapsed time > duration, visibility becomes false at 5s

---

## Usage Examples

### Example 1: Basic Form Submission

```powerfx
btn_SaveRecord.OnSelect =
If(
    IsValid(form_EditRecord),
    // Validation passed - save
    IfError(
        Patch(Items, ThisItem, form_EditRecord.Updates);
        Refresh(Items);
        NotifySuccess("Record saved successfully");
        Navigate(ListScreen),
        // Save failed
        NotifyError("Save failed: " & Error.Message)
    ),
    // Validation failed
    NotifyValidationError("Form", "Please complete all required fields")
)
```

Flow:
1. Check if form has no validation errors
2. If valid: Try to save using Patch()
3. Success → Show green "Record saved successfully" toast
4. Error → Show red toast with error message
5. Validation failed → Show yellow toast asking user to complete fields

### Example 2: Delete with Confirmation

```powerfx
btn_DeleteRecord.OnSelect =
If(
    Confirm("Delete this record permanently?"),
    IfError(
        Remove(Items, ThisItem);
        NotifyActionCompleted("Delete", ThisItem.Name),
        NotifyError("Delete failed: " & Error.Message)
    ),
    NotifyInfo("Delete cancelled")
)
```

Flow:
1. Show browser confirm dialog
2. If user clicks "OK" (cancellation was false):
   - Try to delete
   - Success → "Delete completed: [Item Name]" green toast
   - Error → Show error message in red toast
3. If user clicks "Cancel":
   - Show info toast "Delete cancelled"

### Example 3: Approval Workflow

```powerfx
btn_ApproveRecord.OnSelect =
If(
    HasPermission("Approve"),
    Patch(Items, ThisItem, {Status: "Approved"});
    NotifySuccess("Record approved");
    // Optional: Send email via Power Automate
    SendApprovalEmail(ThisItem.Name),
    NotifyPermissionDenied("approve records")
)
```

Flow:
1. Check if current user has "Approve" permission
2. If yes: Update status, show success toast, send email
3. If no: Show red error toast "Permission denied to approve records"

### Example 4: Long-Running Operation

```powerfx
btn_BulkUpdate.OnSelect =
If(
    AppState.IsProcessing,
    NotifyWarning("Operation in progress..."),
    // Start operation
    Set(AppState, Patch(AppState, {IsProcessing: true}));
    NotifyInfo("Processing started - this may take a moment");
    // Call Power Automate flow
    BulkUpdateFlow.Run(...);
    // Flow calls back to app when done
    Set(AppState, Patch(AppState, {IsProcessing: false}));
    NotifySuccess("Bulk update completed")
)
```

Flow:
1. Check if already processing (prevent double-click)
2. If processing: Show warning toast
3. If not: Set flag, show info toast, start flow, wait for completion
4. When flow done: Show success toast

---

## How to Customize Notifications

### Change Auto-Dismiss Timeout

Edit `ToastConfig` Named Formula in `App-Formulas-Template.fx` (line ~885):

```powerfx
ToastConfig = {
    SuccessDuration: 3000,   // Change to 3 seconds
    WarningDuration: 5000,   // Keep at 5 seconds
    ErrorDuration: 0,        // Never auto-dismiss (errors always manual)
    InfoDuration: 5000,      // Keep at 5 seconds
}
```

**Note:** Never change `ErrorDuration` from 0. Errors require user acknowledgment.

### Change Toast Colors

Edit `GetToastBackground()` UDF in `App-Formulas-Template.fx` (line ~920):

```powerfx
GetToastBackground(toastType: Text): Color =
    Switch(
        toastType,
        "Success", ColorValue("#98D08C"),  // Change from green
        "Error", ColorValue("#C5504B"),    // Change from red
        "Warning", ColorValue("#FFD966"),  // Change from yellow
        "Info", ColorValue("#E7F4FF"),     // Change from light blue
        ColorValue("#F2F2F2")              // Fallback gray
    )
```

Use standard hex color codes. Test colors with accessibility tools to ensure sufficient contrast.

### Change Toast Icons

Edit `GetToastIcon()` UDF in `App-Formulas-Template.fx` (line ~935):

```powerfx
GetToastIcon(toastType: Text): Text =
    Switch(
        toastType,
        "Success", "👍",      // Change from checkmark to thumbs-up
        "Error", "❌",        // Change from X to red circle-X
        "Warning", "⚠️",      // Change from warning triangle to emoji
        "Info", "ℹ️",         // Change from info circle to emoji
        ""                    // Fallback (blank icon)
    )
```

Use Unicode characters or emoji. Some fonts may not support all characters (test in your environment).

### Add New Notification Type

To add a custom notification type (e.g., "Debug" for development):

1. **Edit `GetToastBackground()` UDF** - add case:
   ```powerfx
   "Debug", ColorValue("#F0F0F0")  // Light gray background
   ```

2. **Edit `GetToastIcon()` UDF** - add case:
   ```powerfx
   "Debug", "🐛"  // Bug emoji
   ```

3. **Edit `GetToastIconColor()` UDF** - add case:
   ```powerfx
   "Debug", ColorValue("#666666")  // Dark gray icon
   ```

4. **Create new UDF** in `App-Formulas-Template.fx`:
   ```powerfx
   NotifyDebug(message: Text): Void = {
       AddToast(message, "Debug", true, 5000)
   };
   ```

5. **Use new UDF** in controls:
   ```powerfx
   NotifyDebug("Debug: User clicked button at " & Now())
   ```

### Show Custom Notification (Advanced)

Skip the UDF wrapper and call `AddToast()` directly:

```powerfx
// Direct AddToast call
AddToast("Custom message", "Success", true, 8000)
// Parameters:
//   message: Text to show
//   type: Must match a case in GetToast* UDFs ("Success", "Error", "Warning", "Info", or custom)
//   autoClose: true = dismiss after duration, false = require X button
//   duration: milliseconds before auto-dismiss (ignored if autoClose=false)
```

This gives full control but bypasses the Notify() system banner. Use sparingly for truly custom scenarios.

---

## Performance Considerations

### Toast Stack Limits

- **Recommended:** 1-3 toasts visible at once
- **Maximum safe:** 5-10 toasts (UI might feel cluttered)
- **Danger zone:** 50+ toasts (collection grows large, app gets slow)

### Best Practices

- **Group notifications:** If multiple validations fail, show one summary toast instead of 5 individual toasts
- **Use correct type:** Each type has visual meaning (green=success, red=error) - don't use them interchangeably
- **Keep messages short:** Long messages wrap but might get cut off - keep under 100 characters
- **No sensitive data:** Don't show user emails, database IDs, or stack traces in toasts

### Monitoring

Use Power Apps Monitor (F12) to observe notifications:

1. Open Monitor → Collections tab
2. Look for `NotificationStack` collection
3. Expected state: 0-3 rows at any time
4. If rows keep growing: Auto-dismiss not working, see [TROUBLESHOOTING.md](./TROUBLESHOOTING.md)

---

## Related Documentation

- **Setup guide:** [QUICK-START.md](./QUICK-START.md)
- **API reference:** [CLAUDE.md - Notification System](../CLAUDE.md#notification-system)
- **Troubleshooting:** [TROUBLESHOOTING.md](./TROUBLESHOOTING.md)
- **Source code:** See `App-Formulas-Template.fx` (UDF definitions) and `Control-Patterns-Modern.fx` Pattern 1.9 (UI rendering)
