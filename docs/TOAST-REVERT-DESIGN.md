# Toast Revert System - Architecture & Implementation

## Overview

Erweitert das Toast-Notification-System um eine optionale **Revert/Undo-Taste** für Aktionen wie:
- ✅ Delete mit Undo (Item wiederherstellen)
- ✅ Archive mit Undo (Item reactivieren)
- ✅ Bulk-Aktionen mit Undo (z.B. mehrere Einträge archiviert)
- ✅ Beliebige Callbacks (benutzerdefinierte Undo-Aktionen)

---

## Architecture

### Current Schema (Layer 2 State)

```powerfx
NotificationStack = Table(
    {
        ID: 0,
        Message: "Record saved",
        Type: "Success",
        AutoClose: true,
        Duration: 5000,
        CreatedAt: Now(),
        IsVisible: true
    }
)
```

### Extended Schema (with Revert)

```powerfx
NotificationStack = Table(
    {
        ID: 0,
        Message: "Record deleted",
        Type: "Success",
        AutoClose: true,                    // ← auto-dismiss (false for errors)
        Duration: 5000,                     // ← timeout in ms
        CreatedAt: Now(),                   // ← timestamp
        IsVisible: true,                    // ← visibility
        // NEW: Revert Fields
        HasRevert: true,                    // ← show revert button?
        RevertLabel: "Undo",                // ← button text (e.g., "Undo", "Restore")
        RevertCallbackID: 0,                // ← reference to callback handler
        RevertData: {                       // ← data needed to revert (serialized)
            deletedItemID: "abc-123",
            deletedItemName: "Project Alpha"
        }
    }
)
```

---

## Three-Layer Revert Architecture

### Layer 1: Trigger UDFs (App-Formulas)

```powerfx
// Basic toast (existing)
NotifySuccess(message)

// New: Toast with revert capability
NotifySuccessWithRevert(message, revertLabel, revertData, revertCallbackID)

// Examples:
NotifySuccessWithRevert(
    "Item deleted",                    // message
    "Undo",                            // revertLabel (e.g., "Undo", "Restore")
    {ItemID: "123", ItemName: "Foo"},  // revertData (saved for revert action)
    0                                  // revertCallbackID (0 = default delete revert)
)
```

### Layer 2: State & Callbacks (App.OnStart + App-Formulas)

```powerfx
// Add new collection for revert handlers
ClearCollect(RevertCallbacks, Table());

// Revert callback registry (maps ID to handler function)
RevertCallbackRegistry = {
    0: "DELETE_UNDO",           // Restore deleted item
    1: "ARCHIVE_UNDO",          // Unarchive item
    2: "CUSTOM"                 // User-defined callback
}

// AddToast extended with revert support
AddToast(message, toastType, autoClose, duration, hasRevert, revertLabel, revertData, callbackID)

// Remove toast (existing)
RemoveToast(toastID)

// NEW: Handle revert action
HandleRevert(toastID, callbackID, revertData)
```

### Layer 3: UI Controls (Power Apps Studio)

```
cnt_NotificationStack
└── cnt_Toast
    ├── lbl_ToastIcon
    ├── lbl_ToastMessage
    ├── cnt_RevertAction (NEW - conditional container)
    │   ├── btn_RevertAction (NEW - undo button)
    │   └── lbl_RevertLoading (NEW - loading indicator)
    └── btn_CloseToast
```

---

## Implementation Steps

### Step 1: Extend NotificationStack Schema

In **App.OnStart Section 7**, füge RevertCallbacks Collection hinzu:

```powerfx
// After: ClearCollect(NotificationStack, Table())
// Add new collection for storing revert callback handlers
ClearCollect(
    RevertCallbacks,
    Table(
        {
            ID: 0,
            Name: "DELETE_UNDO",
            Description: "Restore deleted item"
        },
        {
            ID: 1,
            Name: "ARCHIVE_UNDO",
            Description: "Unarchive item"
        },
        {
            ID: 2,
            Name: "CUSTOM",
            Description: "Custom revert action"
        }
    )
);

// Variable: Track which toast is reverting (for loading state)
Set(ToastReverting, Blank());
```

---

### Step 2: Create Revert UDFs (App-Formulas)

Füge nach der existierenden `NotifyValidationError` UDF hinzu:

```powerfx
// ============================================================
// REVERT-ENABLED NOTIFICATION UDFs (NEW)
// ============================================================

// Success notification with optional undo button
NotifySuccessWithRevert(
    message: Text;
    revertLabel: Text;
    revertData: Record;
    revertCallbackID: Number
): Void = {
    Notify(message, NotificationType.Success);
    AddToast(
        message,
        "Success",
        true,
        ToastConfig.SuccessDuration,
        true,                           // HasRevert: true
        revertLabel,                    // "Undo", "Restore", etc.
        revertData,                     // {ItemID: "123", ...}
        revertCallbackID                // 0 = Delete, 1 = Archive, etc.
    )
};

// Generic notification with revert (any type)
NotifyWithRevert(
    message: Text;
    notificationType: Text;
    revertLabel: Text;
    revertData: Record;
    revertCallbackID: Number
): Void = {
    Notify(
        message,
        Switch(
            notificationType,
            "Success", NotificationType.Success,
            "Error", NotificationType.Error,
            "Warning", NotificationType.Warning,
            "Info", NotificationType.Information,
            NotificationType.Information
        )
    );
    AddToast(
        message,
        notificationType,
        notificationType <> "Error",    // Auto-close unless error
        Switch(
            notificationType,
            "Success", ToastConfig.SuccessDuration,
            "Warning", ToastConfig.WarningDuration,
            "Info", ToastConfig.InfoDuration,
            ToastConfig.ErrorDuration
        ),
        true,                           // HasRevert: true
        revertLabel,
        revertData,
        revertCallbackID
    )
};

// Delete with undo
NotifyDeleteWithUndo(itemName: Text; revertData: Record): Void = {
    NotifySuccessWithRevert(
        "Item '" & itemName & "' deleted",
        "Undo",
        revertData,
        0                               // CallbackID: DELETE_UNDO
    )
};

// Archive with undo
NotifyArchiveWithUndo(itemName: Text; revertData: Record): Void = {
    NotifySuccessWithRevert(
        "Item '" & itemName & "' archived",
        "Restore",
        revertData,
        1                               // CallbackID: ARCHIVE_UNDO
    )
};
```

---

### Step 3: Update AddToast & Add HandleRevert

Ersetze existierende `AddToast` UDF:

```powerfx
// Extended AddToast with revert support
AddToast(
    message: Text;
    toastType: Text;
    shouldAutoClose: Boolean;
    duration: Number;
    hasRevert: Boolean;
    revertLabel: Text;
    revertData: Record;
    revertCallbackID: Number
): Void = {
    Patch(
        NotificationStack,
        Defaults(NotificationStack),
        {
            ID: NotificationCounter,
            Message: message,
            Type: toastType,
            AutoClose: shouldAutoClose,
            Duration: duration,
            CreatedAt: Now(),
            IsVisible: true,
            // NEW: Revert fields
            HasRevert: hasRevert,
            RevertLabel: revertLabel,
            RevertData: revertData,
            RevertCallbackID: revertCallbackID,
            // NEW: Revert state
            IsReverting: false,
            RevertError: Blank()
        }
    );
    Set(NotificationCounter, NotificationCounter + 1)
};

// NEW: Handle revert action
HandleRevert(toastID: Number; callbackID: Number; revertData: Record): Void = {
    // Mark toast as reverting (shows loading spinner)
    Patch(
        NotificationStack,
        LookUp(NotificationStack, ID = toastID),
        {IsReverting: true, RevertError: Blank()}
    );

    // Execute callback based on ID
    Switch(
        callbackID,
        // DELETE_UNDO: Restore deleted item
        0,
        IfError(
            Patch(Items, Defaults(Items), revertData);
            RemoveToast(toastID);
            NotifySuccess("Item restored: " & revertData.ItemName),
            Patch(
                NotificationStack,
                LookUp(NotificationStack, ID = toastID),
                {
                    IsReverting: false,
                    RevertError: "Restore failed: " & Error.Message
                }
            )
        ),
        // ARCHIVE_UNDO: Unarchive item
        1,
        IfError(
            Patch(Items, {ID: revertData.ItemID}, {Status: "Active"});
            RemoveToast(toastID);
            NotifySuccess("Item unarchived: " & revertData.ItemName),
            Patch(
                NotificationStack,
                LookUp(NotificationStack, ID = toastID),
                {
                    IsReverting: false,
                    RevertError: "Unarchive failed: " & Error.Message
                }
            )
        ),
        // Default: No-op (custom handlers in app code)
        Patch(
            NotificationStack,
            LookUp(NotificationStack, ID = toastID),
            {IsReverting: false}
        )
    )
};

// Remove toast (existing - unchanged)
RemoveToast(toastID: Number): Void = {
    IfError(
        Remove(NotificationStack, LookUp(NotificationStack, ID = toastID)),
        Blank()
    )
};
```

---

### Step 4: Update UI Controls (Power Apps Studio)

#### 4.1: Modify cnt_Toast Container

Ändere Layout von Horizontal zu Auto für flexible Anordnung:

```powerfx
// cnt_Toast Properties
LayoutMode = LayoutMode.Auto  // Changed from Horizontal for conditional revert button
```

Oder behalte Horizontal, aber erstelle cnt_RevertAction als separaten Container.

#### 4.2: Add Revert Button Container

Erstelle neuen horizontalen Container innerhalb cnt_Toast:

```powerfx
// NEUER CONTROL: cnt_RevertAction (Horizontal Container)
// Parent: cnt_Toast (oder innerhalb neuer Struktur)

// Visibility
Visible = ThisItem.HasRevert && !ThisItem.IsReverting

// Layout
LayoutMode = LayoutMode.Horizontal
LayoutGap = 8
Padding = 0

// Styling
Fill = RGBA(0, 0, 0, 0)  // Transparent
```

#### 4.3: Add Revert Button

```powerfx
// NEUER CONTROL: btn_RevertAction (Button)
// Parent: cnt_RevertAction

// Text & Behavior
Text = ThisItem.RevertLabel  // "Undo", "Restore", etc.
OnSelect = HandleRevert(ThisItem.ID, ThisItem.RevertCallbackID, ThisItem.RevertData)

// Styling
Fill = RGBA(0, 0, 0, 0)  // Transparent
HoverFill = ThemeColors.SurfaceHover
PressedFill = ThemeColors.Border
Color = ThemeColors.Info  // Blue text for action
HoverColor = ThemeColors.Primary  // Darker on hover
BorderThickness = 1
BorderColor = ThemeColors.Info
CornerRadius = 2

// Sizing
Width = Auto
Height = 32
Padding = 8

// Typography
FontSize = 12
FontWeight = FontWeight.Semibold

// Accessibility
AccessibleLabel = ThisItem.RevertLabel & " " & ThisItem.Message
```

#### 4.4: Add Loading Spinner (Optional)

```powerfx
// OPTIONAL CONTROL: lbl_RevertLoading (Label/Spinner)
// Parent: cnt_RevertAction
// Purpose: Show loading indicator while revert is executing

// Visibility
Visible = ThisItem.IsReverting

// Text
Text = "⟳"  // Spinner character or use animated GIF

// Animation (if using Label)
Rotation = If(
    ThisItem.IsReverting,
    (Now() - ThisItem.CreatedAt) * 360 / TimeValue("0:0:2"),  // 360° every 2 seconds
    0
)

// Styling
Color = ThemeColors.Info
FontSize = 14

// Size
Width = 20
Height = 20
```

#### 4.5: Error Message (Optional)

```powerfx
// OPTIONAL CONTROL: lbl_RevertError (Label)
// Parent: cnt_Toast or cnt_RevertAction
// Purpose: Show error if revert fails

// Visibility
Visible = !IsBlank(ThisItem.RevertError)

// Text
Text = ThisItem.RevertError

// Styling
Color = ThemeColors.Error
FontSize = 12
FontStyle = FontStyle.Italic

// Sizing
Width = Fill
```

---

## Updated Control Hierarchy

```
cnt_NotificationStack (Vertical Container)
└── cnt_Toast (Horizontal Container) [Template]
    ├── lbl_ToastIcon (Label)
    ├── lbl_ToastMessage (Label - grows with available space)
    ├── cnt_RevertAction (Horizontal Container) [NEW]
    │   ├── btn_RevertAction (Button) [NEW] - "Undo", "Restore", etc.
    │   └── lbl_RevertLoading (Label/Spinner) [OPTIONAL]
    ├── lbl_RevertError (Label) [OPTIONAL]
    └── btn_CloseToast (Button)
```

---

## Usage Examples

### Example 1: Delete with Undo

```powerfx
// btn_DeleteRecord.OnSelect
If(
    Confirm("Delete this record permanently?"),
    IfError(
        // Save deleted item data for potential restore
        Set(DeletedItem, Gallery.Selected);

        // Delete from datasource
        Remove(Items, Gallery.Selected);

        // Show success toast with undo button
        NotifyDeleteWithUndo(
            Gallery.Selected.Name,
            {
                ItemID: Gallery.Selected.ID,
                ItemName: Gallery.Selected.Name,
                ItemData: Gallery.Selected  // Save full record
            }
        ),
        // Error handling
        NotifyError("Delete failed: " & Error.Message)
    )
)
```

### Example 2: Archive with Restore

```powerfx
// btn_ArchiveRecord.OnSelect
If(
    HasPermission("Archive"),
    IfError(
        Patch(Items, Gallery.Selected, {Status: "Archived"});
        NotifyArchiveWithUndo(
            Gallery.Selected.Name,
            {ItemID: Gallery.Selected.ID, ItemName: Gallery.Selected.Name}
        ),
        NotifyError("Archive failed: " & Error.Message)
    ),
    NotifyPermissionDenied("archive records")
)
```

### Example 3: Bulk Action with Undo

```powerfx
// btn_BulkArchive.OnSelect
If(
    CountRows(SelectedItems) > 0,
    IfError(
        ForAll(SelectedItems, Patch(Items, @Value, {Status: "Archived"}));
        NotifyWithRevert(
            "Archived " & Text(CountRows(SelectedItems)) & " items",
            "Success",
            "Undo",
            {Count: CountRows(SelectedItems), Items: SelectedItems},
            2  // CustomCallback
        ),
        NotifyError("Bulk action failed: " & Error.Message)
    )
)
```

### Example 4: Custom Revert Handler

```powerfx
// If HandleRevert CallbackID = 2 (Custom)
// Add custom logic in HandleRevert switch:

2,  // CUSTOM_UNDO
IfError(
    // Your custom revert logic here
    ForAll(
        revertData.Items,
        Patch(Items, @Value, {Status: "Active"})
    );
    RemoveToast(toastID);
    NotifySuccess("Bulk action undone"),
    Patch(
        NotificationStack,
        LookUp(NotificationStack, ID = toastID),
        {IsReverting: false, RevertError: Error.Message}
    )
)
```

---

## Testing Scenarios

### Test 1: Simple Delete with Undo

1. Click Delete button
2. Confirm deletion
3. Success toast appears with "Undo" button
4. Toast shows 5s countdown
5. Click "Undo" → Item restored
6. Second success toast appears: "Item restored"

### Test 2: Delete, Wait, Auto-Close

1. Click Delete button
2. Success toast appears
3. Wait 5 seconds
4. Toast fades and closes
5. "Undo" button disappears (too late)

### Test 3: Error during Revert

1. Click Delete → Success toast with "Undo"
2. Click "Undo"
3. Revert fails (e.g., permission denied)
4. Toast shows error message
5. User can retry or close

### Test 4: Multiple Toasts

1. Delete 3 items
2. 3 success toasts appear, each with "Undo"
3. Click undo on middle toast
4. Only middle item restored
5. Other 2 undo buttons remain active

---

## German Localization

```powerfx
// Add to SECTION 4 (Error Messages) in App-Formulas:

// Revert-related messages
RevertMessage_DeleteUndo: Text = "Löschen rückgängig machen";
RevertMessage_ArchiveUndo: Text = "Archivierung rückgängig machen";
RevertMessage_ItemDeleted(itemName: Text): Text = "Eintrag '" & itemName & "' gelöscht";
RevertMessage_ItemArchived(itemName: Text): Text = "Eintrag '" & itemName & "' archiviert";
RevertMessage_ItemRestored(itemName: Text): Text = "Eintrag '" & itemName & "' wiederhergestellt";
RevertMessage_ItemUnarchived(itemName: Text): Text = "Eintrag '" & itemName & "' reaktiviert";
ErrorMessage_RevertFailed(action: Text): Text = "Fehler beim Rückgängigmachen: " & action;
```

---

## Performance Considerations

### 1. Revert Data Serialization

Speichere nur essenzielle Daten für Revert:

```powerfx
// ✓ GOOD: Minimal data
{
    ItemID: Gallery.Selected.ID,
    ItemName: Gallery.Selected.Name
}

// ✗ BAD: Full record (too large for collection)
Gallery.Selected
```

### 2. Collection Cleanup

Entferne alte reversible Toasts nach Auto-Close:

```powerfx
// Nur Toasts mit HasRevert behalten nach Timeout
If(
    CountRows(Filter(NotificationStack, HasRevert = true && Now() - CreatedAt > TimeValue("0:1:0"))) > 5,
    ForAll(
        FirstN(
            Filter(NotificationStack, HasRevert = true && Now() - CreatedAt > TimeValue("0:1:0")),
            CountRows(...) - 5
        ),
        Remove(NotificationStack, @Value)
    )
)
```

### 3. Concurrent Reverts

Nur eine Revert-Operation gleichzeitig erlauben:

```powerfx
// In HandleRevert - check if another toast is reverting
If(
    !IsBlank(ToastReverting) && ToastReverting <> toastID,
    // Another revert in progress
    NotifyWarning("Bitte warten Sie auf die laufende Operation"),
    // Proceed with revert
    Set(ToastReverting, toastID);
    // ... revert logic ...
    Set(ToastReverting, Blank())
)
```

---

## Migration from Existing Toasts

Keine Breaking Changes! Alle bestehenden UDFs funktionieren weiterhin:

```powerfx
// OLD: Arbeitet immer noch (HasRevert = false)
NotifySuccess("Saved")

// NEW: Mit Revert-Option
NotifySuccessWithRevert("Deleted", "Undo", {ItemID: "123"}, 0)
```

---

## Files to Modify

1. **src/App-Formulas-Template.fx**
   - Add RevertCallbacks reference (optional comment)
   - Update AddToast signature (extend parameters)
   - Add HandleRevert UDF
   - Add NotifyWithRevert, NotifyDeleteWithUndo, NotifyArchiveWithUndo
   - Add German messages to Section 4

2. **src/App-OnStart-Minimal.fx Section 7**
   - Add RevertCallbacks collection (optional)
   - Add ToastReverting variable

3. **docs/TOAST-NOTIFICATION-SETUP.md**
   - Add Step 4.3 (Revert Button)
   - Update Control Hierarchy
   - Add Integration Examples

4. **NEW: docs/TOAST-REVERT-GUIDE.md**
   - Architecture overview
   - Implementation steps
   - Usage examples
   - Testing guide

---

## Summary

✅ **Backwards Compatible** - Alle existierenden Toasts funktionieren ohne Änderungen
✅ **Flexible** - Revert-Daten können beliebig angepasst werden
✅ **Performant** - Nur minimale Daten in Collection
✅ **Accessible** - Screenreader-freundlich
✅ **German-First** - Alle Meldungen auf Deutsch

*Letzte Aktualisierung: 2025-01-22 | Phase 4*
