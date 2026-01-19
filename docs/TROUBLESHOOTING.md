# Troubleshooting: Toast Notifications

**How to use this guide:** Find your problem symptom on the left, follow the diagnosis steps, apply the solution.

Related: [QUICK-START.md](./QUICK-START.md), [CLAUDE.md](../CLAUDE.md), [TOAST-NOTIFICATION-GUIDE.md](./TOAST-NOTIFICATION-GUIDE.md)

---

## Problem 1: I Called NotifySuccess() But No Toast Appears

### Symptoms

- Formula bar shows `NotifySuccess("Test")` executed (no errors)
- Power Apps system notification banner appears (the gray bar at top of screen)
- But custom toast in top-right corner doesn't appear
- App seems to work otherwise (no errors in Monitor)

### Diagnosis

1. Open Monitor (F12 in browser, or Ctrl+Shift+X in Studio)
2. Go to Collections tab
3. Look for "NotificationStack" collection
   - NOT FOUND? → Cause is missing initialization (Solution 1a)
   - FOUND but empty after calling NotifySuccess? → Cause is missing container (Solution 1b)
   - FOUND with rows? → Cause is hidden/off-screen container (Solution 1c)

### Solutions

**1a. NotificationStack collection not initialized:**

In App.OnStart, Section 7 (Notification Stack), verify this line exists:

```powerfx
ClearCollect(NotificationStack, Table());
```

If missing: Add it now
If present but failing: Check for typo in collection name (should be exactly "NotificationStack")

**1b. Container not added to screen:**

- In tree view (left side of Power Apps Studio), look for container named "cnt_NotificationStack"
- If MISSING: Add a new Vertical Container to your main screen (add it LAST so it renders on top)
- If PRESENT: Continue to Solution 1c

**1c. Container hidden or off-screen:**

- Right-click `cnt_NotificationStack` → Edit properties
- Check **Visible** property: Should be `CountRows(NotificationStack) > 0` or `true`
  - If shows `false`: Change to `true`
  - If formula evaluates to false: Fix the formula
- Check **X** property: Should be around `Parent.Width - 400` (positions at right edge)
  - If X=0: Container is off-screen on left
- Check **Y** property: Should be around `16` (top of screen)
  - If Y=0 and X=0: Container is off-screen

**1d. Verify NotifySuccess UDF calls AddToast:**

- Open Advanced editor (Ctrl+Shift+X)
- Find `NotifySuccess()` UDF definition in App-Formulas-Template.fx (around line 970)
- Should contain `AddToast()` call, not just `Notify()`
- If `AddToast` line is commented out or missing: Uncomment or add it

---

## Problem 2: Toast Appears But I Can't Click Buttons Behind It

### Symptoms

- Toast notification appears in top-right corner
- When I try to click a form field or button behind the toast, toast area gets the click instead
- Toast seems to be blocking interaction with app content

### Diagnosis

1. Right-click toast container (`cnt_NotificationStack`) → Edit properties
2. Check **ZIndex** property
   - If ZIndex < 100: Not high enough (other controls in front)
   - If ZIndex = 1000: Should be OK, but might still have issues

### Solutions

**2a. Set container ZIndex to highest value:**

In `cnt_NotificationStack` properties:
```
ZIndex: 1000
```

(Verify it's already set to 1000)

**2b. Check parent container ClipContents:**

- If `cnt_NotificationStack` is inside another container (e.g., `cnt_MainContent`, `cnt_Page`)
- Open parent container → Edit properties → Check **ClipContents** property
- If ClipContents = true: Change to false (allows child toast to overflow and appear on top)

**2c. Move container to end of children list:**

- In tree view, drag `cnt_NotificationStack` to be the LAST child of its parent
- Last child renders on top of earlier children in same parent
- Re-test: Toast should now appear in front

**2d. Verify toast isn't capturing clicks:**

- Toast itself shouldn't have any OnSelect handlers
- Close button (X) should only call `RemoveToast`, nothing else
- If toast has other click handlers: Remove them

---

## Problem 3: When I Show Multiple Toasts, They Stack On Top Of Each Other

### Symptoms

- I call `NotifySuccess()`, `NotifyWarning()`, `NotifyError()` in sequence
- All toasts appear but they overlap (write on top of each other)
- Can't see message text clearly
- Spacing between toasts is missing

### Diagnosis

1. Open `cnt_NotificationStack` properties
2. Check **LayoutMode** property: Should be `LayoutMode.Vertical`
3. Check **Spacing** property: Should be `12` (pixels between children)

### Solutions

**3a. Fix LayoutMode:**

In `cnt_NotificationStack` properties:
```
LayoutMode: LayoutMode.Vertical
```

(Automatic top-to-bottom stacking of child controls)

**3b. Fix Spacing:**

In `cnt_NotificationStack` properties:
```
Spacing: 12
```

(Gap between toasts in pixels)

**3c. Check child toast height:**

- Open individual toast container (`cnt_Toast`) properties
- **Height** should be `Auto` (let content determine height)
- If Height = fixed pixel value (e.g., 50): Change to `Auto`

**3d. Clear Padding if causing issues:**

- `cnt_NotificationStack` should have **Padding: 8**
- If you increased padding thinking it adds space between toasts, reduce back to 8
- Use **Spacing** property for gaps between items, not Padding

---

## Problem 4: Error Toast Disappears After 5 Seconds (I Need Longer)

### Symptoms

- Call `NotifyError("Something failed")`
- Toast appears for a few seconds then disappears
- Want errors to stay visible until I click X button

### Diagnosis

Error messages MUST NEVER auto-dismiss (they require intentional user action).

1. Check `NotifyError` UDF in App-Formulas-Template.fx (around line 975)
2. Look for: `AddToast(message, "Error", false, 0)`
   - Parameter 3 should be `false` (don't auto-close)
   - Parameter 4 should be `0` (no timeout)

### Solutions

**4a. Verify NotifyError doesn't auto-close:**

In `NotifyError` UDF, should look like:
```powerfx
NotifyError(message: Text): Void = {
    Notify(message, NotificationType.Error);
    AddToast(message, "Error", false, 0)  // false = don't auto-close, 0 = no duration
};
```

If you see `true` instead of `false` on AddToast line: Change it to `false`

**4b. Verify ToastConfig has ErrorDuration = 0:**

In `ToastConfig` Named Formula (around line 885), check:
```powerfx
ErrorDuration: 0  // Should be 0, not 5000 or any other value
```

**4c. Check cnt_Toast Visible formula:**

In `cnt_Toast` container, check **Visible** property formula. Should include logic like:
```powerfx
If(ThisItem.AutoClose && elapsed > 5s, false, true)
```

This checks `AutoClose` flag - if false (errors), toast stays visible

**4d. If error still auto-dismisses:**

Check if you're calling `NotifyError()` or `AddToast()` directly:
- If calling `AddToast()` directly: Make sure parameters are: `AddToast(message, "Error", false, 0)`
- The `false` = don't auto-close, `0` = no duration (manual dismissal only)

---

## Problem 5: After Showing Many Toasts, App Gets Slow (NotificationStack Has 100+ Rows)

### Symptoms

- Show several toasts (10+)
- Monitor shows `NotificationStack` has 100+ rows after 30 minutes of use
- App feels sluggish (slower to navigate, galleries lag)
- Expected: Old toasts auto-removed when no longer needed

### Diagnosis

1. Open Monitor → Collections tab
2. Expand `NotificationStack` and count rows
   - Expected: 0-5 rows at any time
   - Actual: 50+ rows, many with `CreatedAt` from hours ago
3. Cause: Auto-dismiss not removing old toasts, `RemoveToast()` not called

### Solutions

**5a. Verify auto-dismiss is working:**

1. Call `NotifySuccess("Timer test")`
2. Wait 5 seconds
3. Check Monitor: `NotificationStack` should have 0 rows (toast auto-removed)
4. If still 1 row: Auto-dismiss not working, go to Solution 5b

**5b. Check auto-dismiss formula in cnt_Toast:**

In `cnt_Toast` container, check **Visible** property. Should look like:
```powerfx
If(ThisItem.AutoClose && Now() - ThisItem.CreatedAt > TimeValue("0:0:5"), false, true)
```

If formula is missing or wrong: Toasts never hide. Fix the formula.

**5c. Force cleanup (manual workaround):**

Run this in formula bar as temporary fix:
```powerfx
ForAll(
    Filter(NotificationStack, Now() - CreatedAt > TimeValue("0:0:30")),
    Remove(NotificationStack, @Value)
)
```

(This removes toasts older than 30 seconds - manual cleanup as workaround)

**5d. Check if RemoveToast is working:**

1. Add a toast
2. Click X button on the toast
3. Monitor should show collection decreased by 1 row
4. If row still there: Click handler not calling `RemoveToast` properly

Verify close button formula: `btn_CloseToast.OnSelect = RemoveToast(ThisItem.ID)`

---

## Problem 6: Toast Shows But With Wrong Colors/Icons

### Symptoms

- Success toast appears green (correct) but checkmark shows as "?" or blank
- Error toast shows as blue instead of red
- Warning icon appears as wrong symbol

### Diagnosis

Check `GetToastIcon()` and `GetToastBackground()` UDFs in App-Formulas-Template.fx

### Solutions

**6a. Verify GetToastIcon has all types:**

Around line 935, should look like:
```powerfx
GetToastIcon(toastType: Text): Text =
    Switch(
        toastType,
        "Success", "✓",      // Must have case for "Success"
        "Error", "✕",        // Must have case for "Error"
        "Warning", "⚠",      // Must have case for "Warning"
        "Info", "ℹ",         // Must have case for "Info"
        ""                   // Fallback
    )
```

If missing a case: Add it

**6b. Verify GetToastBackground has all types:**

Around line 920, should look like:
```powerfx
GetToastBackground(toastType: Text): Color =
    Switch(
        toastType,
        "Success", ThemeColors.SuccessLight,
        "Error", ThemeColors.ErrorLight,
        "Warning", ThemeColors.WarningLight,
        "Info", ColorValue("#E7F4FF"),
        ThemeColors.Surface  // Fallback
    )
```

If missing a case: Add it

**6c. If icons show as "?" character:**

Unicode characters might not be supported in your font. Replace with emoji or text:
- Replace "✓" with "✅" (check mark emoji) or "[OK]"
- Replace "✕" with "❌" (red circle-X) or "[ERROR]"
- Replace "⚠" with "⚠️" (warning emoji) or "[WARNING]"

**6d. If colors are wrong:**

Verify `ThemeColors` Named Formula has these values (around line 50 of App-Formulas):
- `SuccessLight: ColorValue("#E8F5E9")`  (light green)
- `ErrorLight: ColorValue("#FFEBEE")`    (light red)
- `WarningLight: ColorValue("#FFF3E0")` (light orange)

If missing: Define them in App-Formulas-Template.fx

---

## Still Stuck?

1. Check [QUICK-START.md Setup verification](./QUICK-START.md#step-4-verify-setup) checklist
2. Open Monitor (F12) and check for error messages
3. Review [TOAST-NOTIFICATION-GUIDE.md](./TOAST-NOTIFICATION-GUIDE.md) architecture section
4. Post issue with:
   - Screenshot of Monitor (Collections tab showing NotificationStack)
   - Code snippet of your NotifySuccess/NotifyError call
   - Expected vs actual behavior

**Last resort:** Restart Power Apps (close browser tab and reopen)
