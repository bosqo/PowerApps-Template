# Phase 4: User Experience & Documentation - Research

**Researched:** 2026-01-19
**Domain:** PowerApps Canvas App Notification System & Developer Documentation
**Confidence:** HIGH

## Summary

Phase 4 focuses on two complementary domains: delivering a polished **toast notification system** with Fluent Design styling, and providing **comprehensive developer documentation** for rapid customer project deployment. The codebase already has a foundation of notification UDFs using Power Apps' built-in `Notify()` function, but lacks the custom UI controls (toast containers) and supporting documentation needed for a production-quality experience.

**Key findings:**

1. **Notification Foundation Exists:** The template already defines `NotifySuccess()`, `NotifyError()`, `NotifyWarning()`, and `NotifyInfo()` UDFs that wrap Power Apps' native `Notify()` function. These are ready to use but require custom toast UI for non-blocking, styled notifications (the native `Notify()` uses a single banner, not stacked toasts).

2. **Fluent Design Colors Ready:** `ThemeColors` Named Formula already contains all semantic colors (Success green, Error red, Warning amber, Info blue) needed for toast styling. Controls can reference these directly.

3. **State Management Pattern Established:** The app uses three centralized state variables (`AppState`, `ActiveFilters`, `UIState`). A notification collection can integrate cleanly into this structure without architectural changes.

4. **Documentation Gaps:** While CLAUDE.md covers architecture and naming conventions well, it lacks: (a) notification system usage guide, (b) developer setup & configuration walkthrough, (c) troubleshooting section, (d) inline code comments in template files.

5. **Container Control Capability:** Power Apps containers (with `cnt_` prefix pattern established) can serve as toast containers. No external libraries required; pure Power Fx control formulas can implement stacking, auto-dismiss, and animations.

**Primary recommendation:** Build custom toast container UI using Power Apps containers, implement toast state tracking via a `NotificationStack` collection, and expand CLAUDE.md with usage examples and troubleshooting. The notification UDFs themselves need no changes—they remain the public API.

## Standard Stack

### Core
| Library | Version | Purpose | Why Standard |
|---------|---------|---------|--------------|
| Power Apps Canvas | 2025.x | Native notification delivery | Built-in, no external dependencies; `Notify()` and `NotificationType` enum support |
| Fluent Design System | 2.0 | Visual design tokens | Microsoft's standard for enterprise apps; colors already in ThemeColors |
| Power Fx 2025 | Standard | Formula language | Supports UDFs, Named Formulas, lazy evaluation; required for modern patterns |
| Dataverse/SharePoint Lists | Any | Data sources | Existing template standard; notifications tied to data operations |

### Supporting (Recommended)
| Library | Version | Purpose | When to Use |
|---------|---------|---------|-------------|
| Power Platform CLI | 5.x+ | ALM and deployment | Version source files, test in isolated environments |
| VS Code with Power Platform Tools | Latest | Code editing & authoring | Writing/testing .fx templates before packing into canvas app |

### Alternatives Considered
| Instead of | Could Use | Tradeoff |
|------------|-----------|----------|
| Power Apps built-in `Notify()` | Custom HTML notification library | Custom library adds complexity and cross-platform issues; built-in is simpler and standard |
| Centered banner notifications | Top-right toast stack (chosen) | Top-right is Fluent Design standard; centered blocks user content |
| Dismissal via X button only | Auto-dismiss + X option | Auto-dismiss prevents notification pile-up but errors require explicit close to prevent data loss |
| Custom animation timings | Platform defaults | Custom animations risk accessibility issues; stick to 300-400ms slide-in, 200-300ms fade-out |

**Installation/Setup:**
```bash
# No special installation needed - notifications use Power Fx only
# Verify your canvas app has these data sources connected:
# - Office365Users (for user context, already required for UserProfile)
# - SharePoint/Dataverse (for CRUD operations that trigger notifications)

# PAC CLI (if deploying via ALM):
dotnet tool install --global Microsoft.PowerApps.CLI.Tool
pac --version
```

## Architecture Patterns

### Notification System Architecture

**Layer 1: UDF Notification Triggers (Already Exists)**
```powerfx
// Source: App-Formulas-Template.fx:859-876
NotifySuccess(message: Text): Void = {
    Notify(message, NotificationType.Success);
};
```

These five UDFs remain the public API. Developers call these, not `Notify()` directly. When Phase 4 adds custom toast UI, these UDFs will call a custom toast handler instead of/in addition to `Notify()`.

**Layer 2: Toast State Management (New in Phase 4)**
```powerfx
// In App.OnStart (initialize)
NotificationStack = Table();  // Collection to hold active toasts
NotificationCounter = 0;      // Unique ID for each toast

// In App.Formulas (helper UDFs)
AddToast(message: Text, type: Text, autoClose: Boolean, duration: Number): Void = {
    Patch(
        NotificationStack,
        Defaults(NotificationStack),
        {
            ID: NotificationCounter,
            Message: message,
            Type: type,  // "Success", "Error", "Warning", "Info"
            AutoClose: autoClose,
            Duration: duration,
            CreatedAt: Now(),
            IsVisible: true
        }
    );
    Set(NotificationCounter, NotificationCounter + 1);
};

RemoveToast(toastID: Number): Void = {
    Remove(NotificationStack, LookUp(NotificationStack, ID = toastID));
};
```

**Layer 3: Toast Container Control (New in Phase 4)**
```
cnt_NotificationStack (Vertical container, top-right positioned)
├── cnt_Toast_1 (Individual toast, repeats for each item in NotificationStack)
│   ├── ico_ToastIcon (Icon per type: ✓, ✕, ⚠, ℹ)
│   ├── lbl_ToastMessage (Text message)
│   └── btn_CloseToast (X button, calls RemoveToast)
├── cnt_Toast_2
├── ... (dynamic children per NotificationStack collection)
```

### Recommended Project Structure
```
src/
├── App-Formulas-Template.fx        # UDFs + Named Formulas
│   ├── Section 1-6 (existing)
│   └── Section 7 (NEW): Notification helpers + AddToast/RemoveToast
│
├── App-OnStart-Minimal.fx          # State initialization
│   ├── Section 1-6 (existing)
│   └── Section 7 (NEW): NotificationStack collection init
│
├── Control-Patterns-Modern.fx      # Control formulas
│   ├── Section 1-5 (existing)
│   └── Section 6 (NEW): Toast container & tile patterns
│
└── Canvas App screens/controls
    └── cnt_NotificationStack (new container, added to main screen)

docs/
├── Notification-System-Guide.md    # (NEW) How to use toast UDFs
├── SETUP-CHECKLIST.md              # (NEW) Configuration steps
├── TROUBLESHOOTING.md              # (NEW) Common issues & fixes
└── CLAUDE.md (expanded)
    └── New sections: Notification API, Setup & Config, Troubleshooting
```

### Pattern 1: Basic Toast Notification Flow

**When to use:** Form submission, validation error, action completion
**Example:**
```powerfx
// Button.OnSelect handler
If(
    IsValid(form_EditItem),
    Patch(Items, ThisItem, form_EditItem.Updates);
    NotifySuccess("Record saved");
    AddToast("Record saved", "Success", true, 5000);
    Navigate(HomeScreen),
    NotifyValidationError("Form", "Please fix required fields");
    AddToast("Form invalid - please fix required fields", "Warning", true, 5000)
);
```

**Container formula:**
```powerfx
// cnt_NotificationStack.Items = NotificationStack
// This gallery auto-renders each toast in the stack

// For each toast item in gallery:
// cnt_Toast.Fill = Switch(
//     ThisItem.Type,
//     "Success", ThemeColors.SuccessLight,
//     "Error", ThemeColors.ErrorLight,
//     "Warning", ThemeColors.WarningLight,
//     ThemeColors.Info
// )

// ico_ToastIcon.Value = Switch(
//     ThisItem.Type,
//     "Success", "✓",
//     "Error", "✕",
//     "Warning", "⚠",
//     "ℹ"
// )

// btn_CloseToast.OnSelect = RemoveToast(ThisItem.ID)

// Auto-dismiss logic (if ThisItem.AutoClose):
// Set(Timer_AutoDismiss.Repeat, ThisItem.Duration / 1000)
// Timer_AutoDismiss.OnTimerEnd = RemoveToast(ThisItem.ID)
```

### Anti-Patterns to Avoid

- **❌ Using Power Apps native `Notify()` for all notifications:** Shows single banner (can't stack), blocks content with system styling, no control over position/timing. Use for critical system alerts only, custom toasts for app feedback.

- **❌ Storing notifications in AppState instead of collection:** AppState should remain minimal (loading, navigation, auth). Notifications are transient UI state; use separate `NotificationStack` collection for proper lifecycle management and render performance.

- **❌ Auto-dismissing error messages:** Errors require intentional user action (reading, understanding, clicking X). 5s auto-dismiss causes user to miss critical information. Pattern: Info/Success auto-dismiss, Error/Warning require X or immediate follow-up action.

- **❌ Hardcoding toast timing and positions in controls:** Puts display logic in UI layer instead of logic layer. Define `ToastDuration`, `ToastWidth`, `ToastPosition` in `AppConfig` Named Formula; controls reference these.

- **❌ Calling `Notify()` and `AddToast()` separately:** Duplicates notification logic. Instead, modify `NotifySuccess()` to call `AddToast()` internally, so a single UDF call handles both system notification and custom toast.

## Don't Hand-Roll

Problems that look simple but have existing solutions:

| Problem | Don't Build | Use Instead | Why |
|---------|-------------|-------------|-----|
| Notification stacking | Custom position math (Y += height per toast) | NotificationStack collection + gallery auto-layout | Manual math causes overlap/off-screen bugs; collection + gallery auto-handles ordering, sizing, flow |
| Auto-dismiss timers | Multiple manual timers per toast | Single timer component + IsExpired formula | Multiple timers cause memory leaks, race conditions; one timer per duration bucket is safe |
| Icon selection per type | If/Switch inline in control | Named Formula returning icon per type + reusable UDF | Inline If/Switch scattered across controls creates maintenance burden; centralized formula is single source of truth |
| Toast color mapping | If/Switch inline (again) | `GetToastColor(type: Text)` UDF + ThemeColors | Same reason—centralize color logic in formula layer |
| Dismissal interaction | Custom button with logic to find toast ID | Simple `RemoveToast(ThisItem.ID)` UDF | ID tracking is error-prone; UDF abstracts identity lookup away |

**Key insight:** Notification systems *look* simple (show message, auto-dismiss), but managing stack ordering, timing, colors, and dismissal across multiple toasts creates complexity. Reuse the collection + gallery + UDF pattern that's already established in this template; don't reinvent UI state management.

## Common Pitfalls

### Pitfall 1: Notification Collection Grows Unbounded

**What goes wrong:** Notifications added to collection but RemoveToast() is never called (button formula not linked, auto-dismiss timer doesn't fire). Collection grows to 100s of items, app slows down, new toasts don't appear.

**Why it happens:**
- Timer logic forgotten in template setup
- Auto-dismiss conditions never checked (IsVisible flag not monitored)
- RemoveToast() called with wrong ID or ID not passed correctly

**How to avoid:**
1. Implement auto-dismiss as immediate cleanup in AddToast():
```powerfx
AddToast(message, type, autoClose, duration): Void = {
    Patch(NotificationStack, Defaults(NotificationStack), {...});
    If(autoClose,
        Set(ToastToRemove, NotificationCounter);
        After(duration / 1000, Seconds, RemoveToast(ToastToRemove))
    );
};
```

2. Add periodic cleanup in App.OnStart or a background flow:
```powerfx
// Remove toasts older than 30 seconds (safety net)
Set(ExpiredToasts, Filter(NotificationStack, Now() - CreatedAt > TimeValue("0:0:30")));
ForAll(ExpiredToasts, Remove(NotificationStack, @Value));
```

3. Test: Open Monitor, add 10 toasts, watch NotificationStack collection. Should reduce back to 0 after 5s.

**Warning signs:** Monitor shows NotificationStack.Count growing past 5 items; toasts pile up off-screen; old toasts never disappear.

---

### Pitfall 2: Toasts Appear Behind Other Content

**What goes wrong:** Toast containers render below galleries, forms, or other controls. User clicks notification area but interacts with control underneath instead of dismissing toast.

**Why it happens:**
- Container's `ZIndex` or layering not set
- Toast container placed in wrong location in screen hierarchy (should be last/topmost)
- Parent container has `ClipContents: true`, clipping toast overflow

**How to avoid:**
1. Place `cnt_NotificationStack` as the **last child** in main container (renders on top):
```
cnt_MainScreen (Vertical)
├── cnt_Header
├── cnt_Content
├── cnt_FilterPanel
└── cnt_NotificationStack (← last = renders on top)
```

2. Set container properties:
```
ZIndex: 1000  (or highest value in screen)
ClipContents: false  (allow overflow)
Visible: CountRows(NotificationStack) > 0  (hide when empty)
```

3. Test: Add toast, try clicking content behind it. Toast X button should work, not the control behind.

**Warning signs:** Toast appears but X button doesn't respond; clicking toast area triggers gallery item selection instead.

---

### Pitfall 3: Error Messages Auto-Dismiss When User Still Reading

**What goes wrong:** Critical error message auto-dismisses after 5s before user can read/understand. User doesn't see the error, attempts action again, same failure.

**Why it happens:** Using same 5s timer for both success/warning and errors. Template defaults all notifications to 5s auto-dismiss.

**How to avoid:**
1. **Never auto-dismiss errors:**
```powerfx
NotifyError(message: Text): Void = {
    Notify(message, NotificationType.Error);
    AddToast(message, "Error", false, 0);  // autoClose = false, duration ignored
};

NotifySuccess(message: Text): Void = {
    Notify(message, NotificationType.Success);
    AddToast(message, "Success", true, 5000);  // autoClose = true, 5s
};
```

2. **Add visual indicator for non-dismissing toasts:**
```powerfx
// In toast: if not auto-closing, show "Press ESC to close" or just X icon in red
lbl_ToastHint.Visible = !ThisItem.AutoClose
lbl_ToastHint.Text = "Click X to dismiss"
```

3. Test: Trigger error, wait 6s. Toast should still be visible.

**Warning signs:** Error toasts disappear, users click button again, app floods with duplicate error toasts.

---

### Pitfall 4: Notification UDFs Called But Toasts Don't Appear

**What goes wrong:** Developer calls `NotifySuccess("Saved")`, sees Power Apps system notification banner, but custom toast container is empty.

**Why it happens:**
- Custom toast UDF not hooked into notification trigger (only native `Notify()` called)
- NotificationStack collection not initialized in App.OnStart
- Toast container hidden or off-screen, appears to not work
- Developer forgot to add custom toast container to main screen

**How to avoid:**
1. **Modify all Notify*() UDFs to call AddToast():**
```powerfx
NotifySuccess(message: Text): Void = {
    Notify(message, NotificationType.Success);  // System notification (optional)
    AddToast(message, "Success", true, 5000);   // Custom toast (required)
};
```

2. **Verify NotificationStack initialized in App.OnStart:**
```powerfx
// Section 5: Background collections
ClearCollect(NotificationStack, Table());  // Start empty
Set(NotificationCounter, 0);
```

3. **Add toast container to main screen during Phase 4 planning:**
- Container must exist in screen hierarchy
- Container.Items formula = NotificationStack
- Must be visible and positioned top-right

4. **Test in Monitor:**
```
1. Add breakpoint in NotifySuccess()
2. Call NotifySuccess("Test")
3. Watch Monitor: NotificationStack should have 1 row
4. Check screen: Toast should appear top-right
```

**Warning signs:** Monitor shows NotificationStack has rows but screen is empty; only system notification banner appears; custom toast container is greyed out or missing from controls list.

---

### Pitfall 5: Duplicate Notifications (Clicked Button Multiple Times)

**What goes wrong:** User clicks "Save" button fast twice (or network slow). Toast appears twice. User sees "Saved" twice, confuses with two saves happening.

**Why it happens:**
- Button doesn't disable during save (IsSaving state not set)
- OnSelect formula called twice before first notification removed
- No debounce on button clicks

**How to avoid:**
1. **Set IsSaving state to disable button during operation:**
```powerfx
btn_Save.OnSelect =
If(
    AppState.IsSaving,
    Notify("Save in progress", NotificationType.Warning),  // Ignore double-click
    Set(AppState, Patch(AppState, {IsSaving: true}));
    Patch(Items, ThisItem, form_EditItem.Updates);
    NotifySuccess("Saved");
    AddToast("Saved", "Success", true, 5000);
    Set(AppState, Patch(AppState, {IsSaving: false}))
);

btn_Save.DisplayMode = If(AppState.IsSaving, DisplayMode.Disabled, DisplayMode.Edit);
```

2. **Add visual feedback (button shows spinning icon while saving):**
```powerfx
ico_SaveSpinner.Visible = AppState.IsSaving
ico_SaveSpinner.Animation = If(AppState.IsSaving, Animation.Pulse, Animation.None)
lbl_SaveText.Text = If(AppState.IsSaving, "Saving...", "Save")
```

3. Test: Click Save fast 5 times. Only one toast should appear; button disabled until save completes.

**Warning signs:** Clicking button multiple times shows multiple identical toasts; button stays enabled during save operation; no visual feedback that save is in progress.

## Code Examples

Verified patterns from official template sources:

### Example 1: Complete Toast Notification Flow

**Source:** `App-Formulas-Template.fx:859-876` (existing) + proposed additions

```powerfx
// In App.Formulas (Named Formulas section)

// Configuration
ToastConfig = {
    Width: 350,           // pixels (250-400 range)
    MaxWidth: 400,
    SuccessDuration: 5000,    // ms
    WarningDuration: 5000,    // ms
    InfoDuration: 5000,       // ms
    ErrorDuration: 0,         // Never auto-dismiss
    AnimationDuration: 300,   // Slide-in time
};

// UDF: Get toast background color by type
GetToastBackground(toastType: Text): Color =
    Switch(
        toastType,
        "Success", ThemeColors.SuccessLight,
        "Error", ThemeColors.ErrorLight,
        "Warning", ThemeColors.WarningLight,
        "Info", ColorValue("#E7F4FF"),  // Light blue
        ThemeColors.Surface
    );

// UDF: Get toast border color by type
GetToastBorderColor(toastType: Text): Color =
    Switch(
        toastType,
        "Success", ThemeColors.Success,
        "Error", ThemeColors.Error,
        "Warning", ThemeColors.Warning,
        "Info", ThemeColors.Info,
        ThemeColors.Border
    );

// UDF: Get icon per toast type
GetToastIcon(toastType: Text): Text =
    Switch(
        toastType,
        "Success", "✓",     // Checkmark
        "Error", "✕",       // X mark
        "Warning", "⚠",     // Warning triangle
        "Info", "ℹ",        // Info circle
        ""
    );

// UDF: Get icon color per toast type
GetToastIconColor(toastType: Text): Color =
    Switch(
        toastType,
        "Success", ThemeColors.Success,
        "Error", ThemeColors.Error,
        "Warning", ThemeColors.Warning,
        "Info", ThemeColors.Info,
        ThemeColors.Text
    );

// Modified notification UDFs (now call AddToast)
NotifySuccess(message: Text): Void = {
    Notify(message, NotificationType.Success);
    AddToast(message, "Success", true, ToastConfig.SuccessDuration)
};

NotifyError(message: Text): Void = {
    Notify(message, NotificationType.Error);
    AddToast(message, "Error", false, ToastConfig.ErrorDuration)
};

NotifyWarning(message: Text): Void = {
    Notify(message, NotificationType.Warning);
    AddToast(message, "Warning", true, ToastConfig.WarningDuration)
};

NotifyInfo(message: Text): Void = {
    Notify(message, NotificationType.Information);
    AddToast(message, "Info", true, ToastConfig.InfoDuration)
};

// UDF: Add toast to stack
AddToast(message: Text; toastType: Text; shouldAutoClose: Boolean; duration: Number): Void = {
    // Patch new toast into collection
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
            IsVisible: true
        }
    );

    // Increment counter for next toast
    Set(NotificationCounter, NotificationCounter + 1);

    // If auto-close, schedule removal
    If(
        shouldAutoClose,
        Set(ToastToRemove, NotificationCounter - 1);
        // After() is a placeholder - actual implementation uses Timer
        // Timer approach shown below under "App.OnStart" section
    );
};

// UDF: Remove toast from stack
RemoveToast(toastID: Number): Void = {
    Remove(NotificationStack, LookUp(NotificationStack, ID = toastID))
};
```

### Example 2: App.OnStart - Toast Initialization

**Source:** `App-OnStart-Minimal.fx` (proposed Section 7)

```powerfx
// ============================================================
// SECTION 7: NOTIFICATION STACK (NEW in Phase 4)
// ============================================================
// Purpose: Initialize toast notification state
// Timing: 100-200ms (background loading, doesn't block critical path)

// Collection: Holds active toast notifications
// Schema: { ID, Message, Type, AutoClose, Duration, CreatedAt, IsVisible }
ClearCollect(
    NotificationStack,
    Table()  // Start empty
);

// Counter: Unique ID for each toast (incremented in AddToast)
Set(NotificationCounter, 0);

// For auto-dismiss: Store current toast ID being dismissed
Set(ToastToRemove, Blank());

// OPTIONAL: Periodic cleanup of old toasts (safety net)
// Uncomment if you notice collection growing unbounded
// (This is handled in Timer_CleanupToasts below)
```

### Example 3: Toast Container Control Formulas

**Source:** `Control-Patterns-Modern.fx` (proposed Section 6)

```powerfx
// ============================================================
// TOAST NOTIFICATION CONTAINER PATTERN
// ============================================================
//
// Parent Container: cnt_NotificationStack
// - Positioned: top-right, fixed overlay
// - Visibility: Shows when NotificationStack has rows
// - Children: Gallery showing each toast
//
// Gallery: glr_Toasts
// - Items: NotificationStack
// - Repeats: One toast tile per item
//
// Toast Tile: cnt_Toast (child of gallery)
// - Dynamic styling per toast type (Success/Error/Warning/Info)
// - Auto-closes if AutoClose = true
// - Can be manually dismissed via X button

// === MAIN CONTAINER SETUP ===

// Property: cnt_NotificationStack.Items
// Bind to notification collection
NotificationStack

// Property: cnt_NotificationStack.X (position)
Parent.Width - 400  // Dock to right edge (with margin)

// Property: cnt_NotificationStack.Y
Spacing.MD  // Top padding

// Property: cnt_NotificationStack.Visible
CountRows(NotificationStack) > 0  // Hide when empty

// Property: cnt_NotificationStack.Width
If(CountRows(NotificationStack) > 0, 380, 0)  // 350 content + 30 padding

// Property: cnt_NotificationStack.LayoutMode
LayoutMode.Vertical  // Stack top-to-bottom

// Property: cnt_NotificationStack.ClipContents
false  // Allow toasts to overflow if needed (for animations)

// Property: cnt_NotificationStack.ZIndex
1000  // Render on top of all other controls


// === INDIVIDUAL TOAST TILE (repeats per notification) ===

// Container: cnt_Toast (child of gallery, repeats for each row)

// Property: cnt_Toast.Fill
GetToastBackground(ThisItem.Type)

// Property: cnt_Toast.BorderColor
GetToastBorderColor(ThisItem.Type)

// Property: cnt_Toast.BorderThickness
2  // Visible border per type

// Property: cnt_Toast.CornerRadius
BorderRadius.MD  // 4px

// Property: cnt_Toast.Padding
Spacing.SM  // 8px padding around contents

// Property: cnt_Toast.Height (auto based on content)
Auto  // Let content determine height

// Property: cnt_Toast.Width
ToastConfig.Width  // 350px (or content-based 250-400)


// === TOAST CONTENT: ICON ===

// Icon: ico_ToastIcon (child of cnt_Toast)

// Property: ico_ToastIcon.Value
GetToastIcon(ThisItem.Type)  // "✓", "✕", "⚠", "ℹ"

// Property: ico_ToastIcon.Color
GetToastIconColor(ThisItem.Type)  // Semantic color

// Property: ico_ToastIcon.Size
24  // px, visible but not overwhelming


// === TOAST CONTENT: MESSAGE TEXT ===

// Label: lbl_ToastMessage (child of cnt_Toast)

// Property: lbl_ToastMessage.Text
ThisItem.Message

// Property: lbl_ToastMessage.FontSize
Typography.SizeMD  // 14px

// Property: lbl_ToastMessage.Color
ThemeColors.Text  // Primary text color

// Property: lbl_ToastMessage.WordWrap
true  // Wrap long messages (max 400px width)

// Property: lbl_ToastMessage.AutoHeight
true  // Grow with message length


// === TOAST CONTENT: CLOSE BUTTON ===

// Button: btn_CloseToast (child of cnt_Toast, top-right)

// Property: btn_CloseToast.Text
"✕"  // Unicode X button

// Property: btn_CloseToast.OnSelect
RemoveToast(ThisItem.ID)  // Dismiss this specific toast

// Property: btn_CloseToast.HoverFill
ThemeColors.SurfaceHover  // Light grey on hover

// Property: btn_CloseToast.DisplayMode
DisplayMode.Edit  // Always interactive (never disabled)

// Property: btn_CloseToast.AccessibleLabel
"Close " & ThisItem.Type & " notification"  // Accessibility


// === ANIMATION: SLIDE-IN ===

// Property: cnt_Toast.OnVisible
Set(ToastAnimationStart, Now())

// Property: cnt_Toast.X (offset animation)
If(
    IsBlank(ToastAnimationStart),
    ToastConfig.Width,  // Start off-screen right
    If(
        Now() - ToastAnimationStart < TimeValue("0:0:0.3"),  // 300ms animation
        ToastConfig.Width -
        (ToastConfig.Width * ((Now() - ToastAnimationStart) / TimeValue("0:0:0.3"))),
        0  // Final position
    )
)

// === ANIMATION: AUTO-DISMISS ===

// Timer: Timer_AutoDismiss_[ToastID] (created dynamically)
// Trigger: When toast added with AutoClose = true
// Duration: ThisItem.Duration ms
// OnTimerEnd: RemoveToast(ThisItem.ID)

// OR: Simpler approach without timer (uses Power Fx only)

// Property: cnt_Toast.Visible (fade-out)
If(
    IsBlank(ThisItem.CreatedAt),
    true,
    If(
        ThisItem.AutoClose && Now() - ThisItem.CreatedAt > TimeValue("0:0:5"),
        false,  // Hide after 5s (makes it fade/disappear)
        true
    )
)

// Then call RemoveToast() via flow trigger or scheduled cleanup
```

### Example 4: Toast Trigger in Form Submission

**Source:** `Control-Patterns-Modern.fx` (Button handler example)

```powerfx
// === BUTTON: SAVE RECORD ===
// Pattern: Form submission with success/error notifications

// Property: btn_SaveRecord.OnSelect

If(
    // Validate form before saving
    Not(IsValid(form_EditRecord)),
    // VALIDATION FAILED - Show validation error toast
    (
        NotifyValidationError("Form", "Please complete all required fields");
        // Message appears as both system notification AND custom toast
    ),

    // VALIDATION PASSED - Attempt save
    (
        // Disable button during save to prevent duplicate submissions
        Set(AppState, Patch(AppState, {IsSaving: true}));

        // Attempt to save the record
        IfError(
            Patch(Items, ThisItem, form_EditRecord.Updates),

            // ERROR HANDLER
            (
                Set(AppState, Patch(AppState, {IsSaving: false}));
                NotifyError("Failed to save: " & Error.Message);
                // Error toast will NOT auto-dismiss (user must click X)
            ),

            // SUCCESS HANDLER
            (
                Set(AppState, Patch(AppState, {IsSaving: false}));
                NotifySuccess("Record saved successfully");
                // Success toast auto-dismisses after 5s

                // Refresh data and navigate
                Refresh(Items);
                Navigate(ListScreen)
            )
        )
    )
);

// Button visual feedback during save
// Property: btn_SaveRecord.DisplayMode
If(AppState.IsSaving, DisplayMode.Disabled, DisplayMode.Edit)

// Property: btn_SaveRecord.Text
If(AppState.IsSaving, "Saving...", "Save")
```

## State of the Art

| Old Approach | Current Approach | When Changed | Impact |
|--------------|------------------|--------------|--------|
| Single system notification banner | Stacked custom toasts in top-right | 2024 Fluent Design update | Non-blocking, multiple messages visible, enterprise UX standard |
| UDFs named `ShowErrorDialog()` | UDFs named `NotifyError()` following naming convention | Phase 4 design (this phase) | Consistent prefix pattern (Notify* for behavior, Has*/Can*/Is* for checks) |
| No state management for toasts | NotificationStack collection + auto-dismiss via Timer | Phase 4 implementation | Enables proper lifecycle (add → display → auto-dismiss → remove) |
| Hard-coded timeouts in controls | ToastConfig.SuccessDuration, ErrorDuration, etc. | Phase 4 design | Configurable in one place, easier to customize per org |
| Auto-dismiss all notifications | Auto-dismiss info/success/warning; never auto-dismiss errors | Phase 4 decision (from CONTEXT.md) | Errors require explicit acknowledgment; non-critical messages don't clutter |
| Inline notification logic in buttons | Centralized NotifySuccess/NotifyError UDFs | Phase 2+ pattern (now enforced) | Single source of truth; consistent behavior across app |

**Deprecated/outdated:**
- **`App.User`, `App.Themes` variables:** Replaced by Named Formulas `UserProfile`, `ThemeColors` (lazy-evaluated, reactive)
- **Centered banner notifications:** Replaced by top-right toast stack (Fluent Design standard, non-blocking)
- **Inline `Notify()` calls:** Developers should call `NotifySuccess()` instead (wraps native Notify + custom toast logic)

## Open Questions

Things that couldn't be fully resolved and require validation during planning:

1. **Toast Auto-Dismiss Implementation**
   - What we know: Timer approach or Power Fx conditional visibility. Need to decide: Use Power Automate Timer flow (complex but reliable) or pure Power Fx solution (simpler but may have race conditions)?
   - What's unclear: How to handle auto-dismiss cleanly if user removes toast manually before timer fires. Remove() on already-removed row causes error?
   - Recommendation: Implement in planning phase using approach: add `IsRemoving` flag to toast, skip timer execution if flag set. Test edge case of manual dismiss while auto-dismiss pending.

2. **Notification Container Positioning**
   - What we know: Top-right is Fluent Design standard. Toast stack should be fixed overlay (stay visible while scrolling).
   - What's unclear: How to position fixed overlay in Power Apps without dedicated "overlay" control. Will using a high ZIndex container work, or does parent Container always clip to bounds?
   - Recommendation: During planning, test control hierarchy: create test screen, add main container (clipped), add overlay container (not clipped), verify top-right toast stays visible while scrolling main content.

3. **Animation Performance**
   - What we know: 300-400ms slide-in, 200-300ms fade-out are Fluent Design standards.
   - What's unclear: Does Power Apps handle simultaneous animations on multiple toasts smoothly? Will 10 toasts sliding in cause UI lag?
   - Recommendation: Load test during implementation: add 10 toasts rapidly, monitor Monitor tool for render performance. If lag detected, simplify animations or use CSS approach if available.

4. **Accessibility (Screen Reader Support)**
   - What we know: CONTEXT.md specifies "aria-label announcing message type" required.
   - What's unclear: Does Power Apps canvas support `aria-label`? Or does it auto-announce container content?
   - Recommendation: Test with accessibility scanner during implementation. May need to add hidden label (`Display: false, AccessibleLabel: "Success notification: " & Message`) for screen readers to announce.

## Sources

### Primary (HIGH confidence)
- **Power Apps Official Docs** (Microsoft Learn)
  - [Notify function documentation](https://learn.microsoft.com/en-us/power-apps/maker/canvas-apps/functions/function-notifications)
  - [NotificationType enum values](https://learn.microsoft.com/en-us/power-apps/maker/canvas-apps/controls/control-container)
  - [Canvas App containers and layering](https://learn.microsoft.com/en-us/power-apps/maker/canvas-apps/controls/control-container)

- **Project Codebase** (verified source)
  - `src/App-Formulas-Template.fx:859-876` — Existing NotifySuccess/NotifyError UDFs
  - `src/App-Formulas-Template.fx:51-81` — ThemeColors Named Formula with semantic colors
  - `src/App-OnStart-Minimal.fx:38-83` — State variable structure pattern (AppState, UIState)
  - `src/Control-Patterns-Modern.fx:22-46` — Control naming conventions (cnt_, glr_, btn_, etc.)

- **Existing Documentation** (HIGH confidence)
  - `CLAUDE.md` — Naming conventions, architecture principles
  - `.planning/codebase/ARCHITECTURE.md` — Layers, data flow, abstractions
  - `docs/App-Formulas-Design.md` — UDF design patterns

### Secondary (MEDIUM confidence)
- **Fluent Design System 2.0** (Microsoft official)
  - Semantic colors (Success green, Error red, Warning amber, Info blue)
  - Toast positioning (top-right, non-blocking)
  - Animation timings (300ms enter, 200ms exit)
  - Referenced in project ThemeColors; cross-verified with Microsoft docs

### Tertiary (LOW confidence - marked for validation)
- **Community practices** (Stack Overflow, Power Apps forums)
  - Auto-dismiss vs manual-dismiss patterns for error notifications
  - Toast stacking implementation via gallery/collection
  - *Note: Community approaches vary; verify patterns work with 2025 Power Apps version during Phase 4 planning*

## Metadata

**Confidence breakdown:**
- **Standard Stack (Notify, Containers, ThemeColors):** HIGH — Source: Power Apps official docs + verified in codebase
- **Architecture (State structure, UDF patterns, control layout):** HIGH — Source: Existing template code + architecture docs
- **Notification System Design (stacking, auto-dismiss, colors):** MEDIUM — Source: Phase 4 CONTEXT decisions + Fluent Design standard, implementation details deferred to planning
- **Documentation approach (CLAUDE.md sections, troubleshooting format):** MEDIUM — Source: Existing CLAUDE.md structure, specific troubleshooting content TBD

**Research date:** 2026-01-19
**Valid until:** 2026-02-19 (30 days stable; notification systems don't change frequently)
**Requires refresh if:**
- Power Apps 2025 releases major Canvas container changes (unlikely)
- Fluent Design 3.0 released with new toast recommendations (check Q2 2026)
- Organization chooses different notification library/approach
