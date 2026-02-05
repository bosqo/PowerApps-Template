# Power Fx Best Practices

**Last Updated:** 2025-02-05
**Based On:** [Microsoft Power Fx Official Documentation](https://learn.microsoft.com/en-us/power-platform/power-fx/)

This guide captures best practices for writing Power Fx code in Canvas Apps, based on official Microsoft documentation and lessons learned from the PowerApps Template project.

---

## Table of Contents

1. [Principles](#principles)
2. [Declarative vs. Imperative](#declarative-vs-imperative)
3. [Named Formulas & UDFs](#named-formulas--udfs)
4. [State Management](#state-management)
5. [With() Function](#with-function)
6. [Magic Numbers & Constants](#magic-numbers--constants)
7. [Side Effects](#side-effects)
8. [Delegation](#delegation)
9. [Performance](#performance)
10. [Common Anti-Patterns](#common-anti-patterns)

---

## Principles

### Microsoft's Golden Rule

> **"Declarative is always best, so use this facility [behavior UDFs] only when you must."**
> — [Working with Formulas In-Depth](https://learn.microsoft.com/en-us/power-apps/maker/canvas-apps/working-with-formulas-in-depth)

**What This Means:**
- Prefer Named Formulas over behavior functions
- Use side effects (Set, Patch, Notify) only when necessary
- Keep formulas pure when possible (same input → same output)

### Simplicity Over Cleverness

**Good:**
```powerfx
NotifySuccess(message: Text): Void = {
    Notify(message, NotificationType.Success);
    AddToast(message, "Success", true, 5000)
};
```

**Over-Engineered:**
```powerfx
// Adds indirection without clear benefit
_InternalNotify(msg, type, autoClose) =
    With({enumType: Switch(...)}, ...);

NotifySuccess(message) = _InternalNotify(message, "Success", true);
```

**Why Simple Wins:**
- ✅ Easier to debug (errors point to exact function)
- ✅ Self-documenting (function name = behavior)
- ✅ No hidden abstractions to trace through
- ✅ Can modify one notification type without affecting others

---

## Declarative vs. Imperative

### Declarative (Preferred)

**Named Formulas** - Computed values that update automatically:

```powerfx
// GOOD: Declarative Named Formula
UserRoles = {
    IsAdmin: User().Email in AdminEmails,
    IsManager: User().Email in ManagerEmails
};

// Usage: UserRoles.IsAdmin (auto-updates when User() changes)
```

**Characteristics:**
- No side effects
- Evaluated lazily (only when needed)
- Automatically reactive
- Defined in `App.Formulas`

### Imperative (Use Sparingly)

**Behavior Functions** - Execute actions with side effects:

```powerfx
// ACCEPTABLE: Behavior UDF (when you must)
NotifySuccess(message: Text): Void = {
    Notify(message, NotificationType.Success);  // Side effect
    AddToast(message, "Success", true, 5000)    // Side effect
};
```

**Characteristics:**
- Have side effects (Set, Patch, Notify, Navigate)
- Must use curly braces `{ }`
- Return type often `Void`
- Use only when declarative approach isn't possible

**When to Use Imperative:**
- User actions (button clicks, form submissions)
- Navigation
- Updating state
- Showing notifications
- Data mutations (Patch, Remove)

---

## Named Formulas & UDFs

### Named Formulas (Declarative)

**Purpose:** Compute values, don't execute actions

```powerfx
// Named Formula for computed values
ThemeColors = {
    Primary: ColorValue("#0078D4"),
    Success: ColorValue("#107C10"),
    Error: ColorValue("#D13438")
};

// Usage: Fill: GetThemeColor("Primary")
GetThemeColor(name: Text): Color =
    Switch(
        name,
        "Primary", ThemeColors.Primary,
        "Success", ThemeColors.Success,
        "Error", ThemeColors.Error,
        ThemeColors.Primary  // Default
    );
```

**Naming:** PascalCase, no verb prefix
- ✅ `ThemeColors`, `UserProfile`, `DateRanges`
- ❌ `getThemeColors`, `calculateUserProfile`

### UDFs (User-Defined Functions)

**Purpose:** Encapsulate reusable logic

**Boolean Check UDFs:**
```powerfx
// Boolean checks: Has*, Can*, Is*
HasRole(roleName: Text): Boolean =
    roleName in UserRoles.AssignedRoles;

CanEditRecord(ownerEmail: Text, status: Text): Boolean =
    HasPermission("Edit") &&
    (ownerEmail = User().Email || HasRole("Admin")) &&
    status <> "Locked";

IsValidEmail(email: Text): Boolean =
    !IsBlank(email) &&
    CountRows(Filter([email], IsMatch(Value, Match.Email))) = 1;
```

**Data Retrieval UDFs:**
```powerfx
// Get* pattern for retrieval
GetUserScope(): Text =
    If(HasPermission("ViewAll"), Blank(), User().Email);

GetThemeColor(name: Text): Color =
    Switch(name, "Primary", ThemeColors.Primary, ...);
```

**Formatting UDFs:**
```powerfx
// Format* pattern for display
FormatDateShort(date: Date): Text =
    Text(date, "d.m.yyyy");

FormatCurrency(amount: Number): Text =
    Text(amount, "€#,##0.00");
```

**Behavior UDFs:**
```powerfx
// Notify*, Show*, Update* for actions (Void return)
NotifySuccess(message: Text): Void = {
    Notify(message, NotificationType.Success);
    AddToast(message, "Success", true, 5000)
};

ShowErrorDialog(error: Text): Void = {
    Set(DialogState, {IsOpen: true, Message: error})
};
```

---

## State Management

### Global State - Use Records

**Bad (Multiple Variables):**
```powerfx
// App.OnStart - AVOID THIS
Set(NotificationCounter, 0);
Set(ToastToRemove, Blank());
Set(ToastAnimationStart, Blank());
Set(ToastReverting, Blank());
```

**Problems:**
- 4 separate variables in global namespace
- Hard to reset all at once
- Unclear which variables belong together

**Good (Consolidated Record):**
```powerfx
// App.OnStart - DO THIS
Set(ToastState, {
    Counter: 0,
    ToRemove: Blank(),
    AnimationStart: Blank(),
    Reverting: Blank()
});
```

**Benefits:**
- Single variable to track
- IntelliSense shows all fields
- Easy to reset: `Set(ToastState, {Counter: 0, ...})`
- Clear ownership (all toast-related state)

### Context State - UpdateContext

```powerfx
// Screen-level state (not global)
UpdateContext({
    ScreenState: {
        SelectedItem: ThisItem,
        IsEditing: false,
        FormMode: FormMode.View
    }
});
```

---

## With() Function

### Correct Usage - Computed Values

The `With()` function is for **computing values**, not executing side effects.

**✅ GOOD - Computing Values:**
```powerfx
// Computing opacity value for animation
With(
    {elapsed: Now() - ThisItem.CreatedAt},
    If(
        elapsed < TimeValue("0:0:0.3"),
        elapsed / TimeValue("0:0:0.3"),  // Fade in
        1
    )
)
```

**✅ GOOD - Simplifying Complex Calculations:**
```powerfx
With(
    {
        taxRate: 0.19,
        basePrice: 100
    },
    basePrice * (1 + taxRate)  // Returns computed value
)
```

**❌ WRONG - Side Effects:**
```powerfx
// NEVER DO THIS
With(
    {enumType: Switch(...), duration: Switch(...)},
    Notify(message, enumType);           // ❌ Side effect
    AddToast(message, type, duration)    // ❌ Side effect
)
```

**Why Wrong:**
> "The With function is used to improve the readability of complex formulas by dividing them into smaller **named sub-formulas**... these named values acting like simple local variables."
> — [With Function Reference](https://learn.microsoft.com/en-us/power-platform/power-fx/reference/function-with)

**With() is designed for:**
- ✅ Computing values (declarative)
- ✅ Simplifying complex calculations
- ❌ **NOT for executing side effects** (imperative)

**Correct Pattern for Side Effects:**
```powerfx
// Direct execution in behavior UDF
NotifySuccess(message: Text): Void = {
    Notify(message, NotificationType.Success);
    AddToast(message, "Success", true, 5000)
};
```

---

## Magic Numbers & Constants

### Problem: Magic Numbers

```powerfx
// BAD - What does 0, 1, 2 mean?
HandleRevert(toastID, callbackID, data) =
    Switch(
        callbackID,
        0, /* delete undo */,
        1, /* archive undo */,
        2, /* custom */
    );

// Usage
NotifyDeleteWithUndo("Item", data, 0);  // What is 0?
```

### Solution: Named Constants

```powerfx
// GOOD - Self-documenting
RevertCallbackIDs = {
    DELETE_UNDO: 0,
    ARCHIVE_UNDO: 1,
    CUSTOM: 2
};

HandleRevert(toastID, callbackID, data) =
    Switch(
        callbackID,
        RevertCallbackIDs.DELETE_UNDO,     // Clear intent
        /* delete undo */,
        RevertCallbackIDs.ARCHIVE_UNDO,    // Clear intent
        /* archive undo */
    );

// Usage
NotifyDeleteWithUndo("Item", data, RevertCallbackIDs.DELETE_UNDO);
```

**Benefits:**
- Self-documenting code
- IntelliSense shows available options
- Single source of truth
- Easy to add new constants

---

## Side Effects

### Chaining Side Effects

**Semicolon vs. Curly Braces:**

```powerfx
// Multiple statements in button OnSelect
btn_Submit.OnSelect =
    Patch(Items, ...);
    Set(FormState, {IsSaving: false});
    Navigate(HomeScreen)
```

**In UDFs - Use Curly Braces:**

```powerfx
SaveAndNotify(item: Record): Void = {
    Patch(Items, Defaults(Items), item);
    NotifySuccess("Saved successfully")
};
```

**Note on Chaining Separator:**
- Use `;` (single semicolon) when decimal separator is `.` (period)
- Use `;;` (double semicolon) when decimal separator is `,` (comma)
- This template uses `.` as decimal separator → use `;`

### Error Handling with Side Effects

```powerfx
// Use IfError for graceful degradation
SaveRecord(item: Record): Void = {
    IfError(
        // Try to save
        Patch(Items, Defaults(Items), item);
        NotifySuccess("Record saved"),
        // On error
        NotifyError("Save failed: " & Error.Message)
    )
};
```

---

## Delegation

### Delegation Limits

SharePoint and Dataverse limit non-delegable queries to **2000 records**. Exceeding this limit causes incomplete results.

### Delegable Operations

**✅ These delegate (work with >2000 records):**
```powerfx
Filter(Items, Status = "Active")                    // Equality
Filter(Items, Amount > 100)                         // Comparison
Filter(Items, Owner.Email = User().Email)          // Lookup
Search(Items, "searchterm", "Name", "Description") // Text search
Sort(Items, Created, Descending)                   // Sorting
```

**❌ These DON'T delegate (2000 record limit):**
```powerfx
Filter(Items, Status in ["Active", "Pending"])     // 'in' operator
Filter(Items, StartsWith(Name, "A"))               // Text functions
CountRows(Filter(Items, ...))                      // Counting filtered results
Filter(Items, CustomUDF(field))                    // UDFs in Filter
```

### Delegation-Safe Patterns

**Pattern 1: Avoid CountRows on Filtered Data**
```powerfx
// BAD - Counts only first 2000
CountRows(Filter(Orders, Status = "Open"))

// GOOD - Use server-side view or aggregation
LookUp('Order Statistics', Type = "OpenCount").Value
```

**Pattern 2: Pagination with FirstN/Skip**
```powerfx
// GOOD - Handles large datasets
FirstN(
    Skip(
        Filter(Items, Status = "Active"),  // Delegable filter
        (CurrentPage - 1) * PageSize
    ),
    PageSize
)
```

**Pattern 3: Delegation-Safe UDFs**
```powerfx
// UDF that returns delegation-safe formulas
FilteredGalleryData(showMyItems, status, search): Table =
    Filter(
        Items,
        // All delegable operations
        If(showMyItems, Owner.Email = User().Email, true),
        If(!IsBlank(status), Status = status, true),
        If(!IsBlank(search),
           StartsWith(Name, search) || StartsWith(Description, search),
           true)
    );
```

**Check Delegation Warnings:**
- Power Apps Studio shows blue underlines for non-delegable operations
- Always test with >2000 records before production

---

## Performance

### App.OnStart Optimization

**Goal:** Load critical data first, parallelize independent operations

```powerfx
// SECTION 1: Critical Path (Sequential)
// User profile MUST load first for permissions
ClearCollect(UserProfileCache, Office365Users.MyProfileV2());

// Roles depend on profile
Set(AppState, Patch(AppState, {UserRoles: UserRoles}));

// Permissions depend on roles
Set(AppState, Patch(AppState, {UserPermissions: UserPermissions}));

// SECTION 2: Background Data (Parallel)
// These don't depend on each other
Concurrent(
    ClearCollect(CachedDepartments, Filter(Departments, Status = "Active")),
    ClearCollect(CachedCategories, Filter(Categories, Status = "Active")),
    ClearCollect(CachedStatuses, StatusTable)
);
```

**Timing Target:** App.OnStart < 2 seconds

**Use Concurrent() for:**
- Independent data loads
- Lookup table caching
- Non-critical collections

**DON'T use Concurrent() for:**
- Dependent operations (profile → roles → permissions)
- Single operations (no benefit)
- Critical path items (sequential is clearer)

### Caching Strategies

**Cache API Calls:**
```powerfx
// BAD - Calls Office365Users every time
UserProfile = Office365Users.MyProfileV2();

// GOOD - Cache in App.OnStart
ClearCollect(UserProfileCache, Office365Users.MyProfileV2());

// Use cached data in Named Formula
UserProfile = First(UserProfileCache);
```

**Cache Collection Results:**
```powerfx
// BAD - Recalculates filter every time gallery refreshes
Gallery.Items = Filter(Items, Owner.Email = User().Email)

// GOOD - Cache in variable, refresh on demand
Set(MyItems, Filter(Items, Owner.Email = User().Email));
Gallery.Items = MyItems;
```

---

## Common Anti-Patterns

### 1. The "App.*" Pattern (Pre-2023 Workaround)

**OLD (Before Named Formulas):**
```powerfx
// App.OnStart
Set(App.User, {IsAdmin: ...});
Set(App.Themes, {Primary: ColorValue(...)});
```

**NEW (With Named Formulas):**
```powerfx
// App.Formulas
UserProfile = {
    Email: User().Email,
    IsAdmin: User().Email in AdminEmails
};

ThemeColors = {
    Primary: ColorValue("#0078D4")
};
```

**Why Named Formulas Win:**
- ✅ Lazy evaluation (only computed when needed)
- ✅ Automatically reactive
- ✅ No startup performance hit
- ✅ No manual refresh needed

### 2. Inline Complex Logic

**BAD:**
```powerfx
Gallery.Items = Filter(
    Items,
    If(
        IsBlank(Data.Filter.UserScope),
        true,
        Owner.Email = Data.Filter.UserScope
    ),
    If(
        IsBlank(Data.Filter.DepartmentScope),
        true,
        Department = Data.Filter.DepartmentScope
    )
)
```

**GOOD:**
```powerfx
// UDF for access control
CanAccessItem(ownerEmail: Text, dept: Text): Boolean =
    (IsBlank(GetUserScope()) || ownerEmail = GetUserScope()) &&
    (IsBlank(GetDepartmentScope()) || dept = GetDepartmentScope());

// Clean gallery formula
Gallery.Items = Filter(Items, CanAccessItem(Owner.Email, Department))
```

### 3. Repeated Switch Statements

**BAD:**
```powerfx
// Color logic repeated in 5 places
Icon.Color = Switch(Status, "Active", Green, "Error", Red, ...)
Label.Fill = Switch(Status, "Active", Green, "Error", Red, ...)
Rectangle.Fill = Switch(Status, "Active", Green, "Error", Red, ...)
```

**GOOD:**
```powerfx
// Centralized UDF
GetStatusColor(status: Text): Color =
    Switch(
        status,
        "Active", ThemeColors.Success,
        "Error", ThemeColors.Error,
        ThemeColors.TextSecondary
    );

// Single source of truth
Icon.Color = GetStatusColor(Status)
Label.Fill = GetStatusColor(Status)
Rectangle.Fill = GetStatusColor(Status)
```

### 4. Boolean Traps

**BAD:**
```powerfx
// What does true/false mean here?
SaveRecord(item, true, false)
```

**GOOD:**
```powerfx
// Named parameters or record
SaveRecord(item: Record, options: {ShowNotification: true, ValidateFirst: false})

// Or separate functions
SaveRecordWithValidation(item)
SaveRecordSilent(item)
```

### 5. Deep Nesting

**BAD:**
```powerfx
If(
    condition1,
    If(
        condition2,
        If(
            condition3,
            result1,
            result2
        ),
        result3
    ),
    result4
)
```

**GOOD:**
```powerfx
// Early returns with Switch/IfError
Switch(
    true,
    !condition1, result4,
    !condition2, result3,
    !condition3, result2,
    result1
)

// Or extract to UDF
IsEligible(): Boolean = condition1 && condition2 && condition3;
If(IsEligible(), result1, result4)
```

---

## Validation Checklist

Before committing Power Fx code, verify:

### Syntax & Structure
- [ ] No delegation warnings (or documented why acceptable)
- [ ] All UDF return types specified explicitly
- [ ] Side effects only in behavior UDFs (marked with `Void` return)
- [ ] `With()` used only for computed values, never side effects

### Naming Conventions
- [ ] Named Formulas: PascalCase, no verbs (e.g., `UserProfile`)
- [ ] UDFs: PascalCase with verb prefix (e.g., `HasRole`, `GetUserScope`)
- [ ] State variables: PascalCase, descriptive (e.g., `AppState`, `ToastState`)
- [ ] No magic numbers - use Named Formulas for constants

### Code Organization
- [ ] Declarative logic in `App.Formulas` (Named Formulas)
- [ ] Imperative logic in `App.OnStart` or control event handlers
- [ ] Repeated logic extracted to UDFs
- [ ] Complex formulas broken into smaller, named parts

### Performance
- [ ] API calls cached (not repeated)
- [ ] Independent operations use `Concurrent()`
- [ ] Large datasets use pagination (`FirstN`/`Skip`)
- [ ] App.OnStart < 2 seconds

### Documentation
- [ ] Complex UDFs have comment explaining purpose
- [ ] Magic number replacements documented
- [ ] Delegation workarounds explained
- [ ] Breaking changes noted

---

## Resources

### Official Microsoft Documentation

**Power Fx Core:**
- [Power Fx Overview](https://learn.microsoft.com/en-us/power-platform/power-fx/overview)
- [Expression Grammar](https://learn.microsoft.com/en-us/power-platform/power-fx/expression-grammar)
- [Formula Reference](https://learn.microsoft.com/en-us/power-platform/power-fx/formula-reference-overview)

**Canvas Apps Specific:**
- [Working with Formulas In-Depth](https://learn.microsoft.com/en-us/power-apps/maker/canvas-apps/working-with-formulas-in-depth)
- [Understand Canvas App Variables](https://learn.microsoft.com/en-us/power-apps/maker/canvas-apps/working-with-variables)
- [Delegation in Canvas Apps](https://learn.microsoft.com/en-us/power-apps/maker/canvas-apps/delegation-overview)

**User-Defined Functions:**
- [UDFs General Availability (Blog)](https://www.microsoft.com/en-us/power-platform/blog/power-apps/power-apps-user-defined-functions-ga/)
- [With Function Reference](https://learn.microsoft.com/en-us/power-platform/power-fx/reference/function-with)

**Performance:**
- [Canvas App Performance Best Practices](https://learn.microsoft.com/en-us/power-apps/maker/canvas-apps/performance-tips)
- [Optimize Canvas App Performance](https://learn.microsoft.com/en-us/power-apps/maker/canvas-apps/create-performant-apps-overview)

### Project-Specific Docs

- `CLAUDE.md` - Project overview and architecture
- `docs/UDF-REFERENCE.md` - Complete UDF API reference
- `docs/DELEGATION-PATTERNS.md` - Delegation-safe filtering patterns
- `docs/TOAST-NOTIFICATION-GUIDE.md` - Notification system implementation

---

## Changelog

### 2025-02-05
- Initial version based on notification system refactoring
- Added With() function guidance
- Added magic number elimination patterns
- Added validation checklist

---

**Questions or suggestions?** Open an issue or submit a PR with improvements.

**Session ID:** https://claude.ai/code/session_012pAUaTftS5wL3uHtJYUT6y
