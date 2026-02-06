---
name: powerfx-syntax
description: Power Fx Syntax-Referenz basierend auf Microsoft-Dokumentation. Nutze diesen Skill fuer korrekte Power Fx Syntax, UDF-Deklarationen, Named Formulas, Delegation und Funktionsreferenz.
---

# Power Fx Syntax Reference (Microsoft-Verified)

All syntax patterns in this document are verified against official Microsoft documentation.
Sources:
- https://learn.microsoft.com/en-us/power-platform/power-fx/formula-reference-overview
- https://learn.microsoft.com/en-us/power-apps/maker/canvas-apps/user-defined-functions
- https://learn.microsoft.com/en-us/power-platform/power-fx/reference/object-app

---

## 1. Named Formulas (App.Formulas)

Named Formulas are declared in `App.Formulas`. They are **declarative, immutable, lazy-evaluated, and auto-reactive**.

### Syntax

```powerfx
// Simple constant
AppName = "My Application";

// Record constant
ThemeColors = {
    Primary: ColorValue("#0078D4"),
    Success: ColorValue("#107C10")
};

// Computed value (auto-reactive, recalculates when dependencies change)
UserEmail = User().Email;
```

### Rules

- Each formula ends with a semicolon `;`
- Type is inferred from the expression (no explicit type annotation on Named Formulas)
- **Immutable**: Cannot be reassigned at runtime. Use `Set()` for mutable state.
- **No behavior functions**: Cannot use `Set`, `Collect`, `Patch`, `Navigate`, `Notify` inside Named Formulas
- **No circular references**: Formulas can reference each other but not create cycles
- **Lazy evaluation**: Calculated only when first needed, not at app startup
- **Auto-reactive**: Recalculate when dependencies change (like Excel cells)

### WRONG Patterns (DO NOT USE)

```powerfx
// WRONG: Type annotation on Named Formulas
MyValue: Text = "hello";           // Named Formulas have no type annotation
MyFlag: Boolean = true;            // This is UDF syntax, not Named Formula

// WRONG: Side effects in Named Formulas
UserData = ClearCollect(Users, Office365Users.SearchUserV2({searchTerm: ""}));
Counter = Set(x, x + 1);

// WRONG: Using App as a variable
Set(App, { User: { Email: "..." } });   // App is a reserved system object
```

---

## 2. User Defined Functions (UDFs)

UDFs are declared in `App.Formulas` alongside Named Formulas. They are **GA as of 2025** (version 2508.3+).

### Pure Function Syntax

```powerfx
// Pattern: FunctionName(Param1: Type1, Param2: Type2): ReturnType = Expression;
IsValidAge(age: Number): Boolean = age >= 0 && age <= 150;

GetGrade(score: Number): Text =
    Switch(true, score >= 90, "A", score >= 80, "B", score >= 70, "C", "F");

// Multiple parameters
CalculateInterest(capital: Number, rate: Number, years: Number): Number =
    capital * Power(1 + rate / 100, years);

// No-parameter UDF (note the empty parentheses - required)
CanViewAllData(): Boolean = UserPermissions.CanViewAll;
```

### Behavior UDF Syntax (Side Effects)

Behavior UDFs use curly braces `{}` and return `Void`.

```powerfx
// Pattern: FunctionName(Param: Type): Void = { Statement1; Statement2 };
NotifySuccess(message: Text): Void = {
    Notify(message, NotificationType.Success);
    Set(LastAction, "success")
};

// Multiple side effects
AddAndNotify(item: Text): Void = {
    Collect(MyCollection, { Name: item });
    Notify("Added: " & item, NotificationType.Success)
};
```

### German Locale (Semicolons as List Separators)

In German locale, `,` is the decimal separator and `;` is the list separator. UDF parameters use `;`:

```powerfx
// German locale: semicolons separate parameters
AddToast(message: Text; toastType: Text; autoClose: Boolean; duration: Number): Void = {
    Collect(NotificationStack, { Message: message, Type: toastType })
};

// Calling in German locale
AddToast("Saved"; "Success"; true; 5000)
```

### Supported Types

**Scalar types**: `Text`, `Number`, `Boolean`, `Date`, `Time`, `DateTime`, `Color`, `GUID`, `Hyperlink`

**Return-only**: `Void` (cannot be a parameter type)

**Record and Table types**: Supported via User Defined Types (UDTs):
```powerfx
PaperType := Type({ Name: Text, Width: Number, Height: Number });
PaperArea(Paper: PaperType): Number = Paper.Width * Paper.Height;
```

### UDF Limitations

- **NOT delegable**: UDFs used inside `Filter()` are NEVER delegated to the data source
- **No recursion**: A UDF cannot call itself
- **UDF-to-UDF calls**: Supported (one UDF can call another)
- **Scoped to app**: Cannot be shared across apps (use Enhanced Component Properties for that)

### WRONG UDF Patterns (DO NOT USE)

```powerfx
// WRONG: Function() syntax with As keyword
MyFunc: Function(x As Text): Boolean = !IsBlank(x);
// CORRECT:
MyFunc(x: Text): Boolean = !IsBlank(x);

// WRONG: Named Formula with type annotation (looks like UDF but has no parameters)
MyValue: Boolean = true;
// CORRECT (Named Formula, no type):
MyValue = true;
// CORRECT (UDF with no params):
MyValue(): Boolean = true;

// WRONG: Using ThisItem inside a UDF (UDFs don't have implicit record context)
CheckStatus: Function(status As Text): Boolean = ThisItem.Status = status;
// CORRECT: Pass the field value as a parameter
CheckStatus(recordStatus: Text, filterValue: Text): Boolean = recordStatus = filterValue;
```

---

## 3. Delegation Rules

### What is Delegation?

Power Apps can delegate Filter/Sort/Search operations to the data source (SharePoint, Dataverse, SQL). Non-delegable operations process data locally, limited to the **delegation limit** (default 500, max 2000 records).

### Key Rule: If ANY part of a query is non-delegable, NOTHING is delegated.

### Delegable Functions

| Function | SharePoint | Dataverse | SQL |
|----------|-----------|-----------|-----|
| `Filter` | Yes (with constraints) | Yes | Yes |
| `Search` | **NO** | Yes | Yes |
| `LookUp` | Yes | Yes | Yes |
| `Sort` | Yes (single column) | Yes | Yes |
| `SortByColumns` | Yes | Yes | Yes |
| `First` | Yes | Yes | Yes |
| `StartsWith` | Yes (text only) | Yes | Yes |
| `CountRows` | **NO** | Yes (cached) | Yes |
| `Sum/Avg/Min/Max` | **NO** | Yes | Yes |

### Delegable Operators (inside Filter/LookUp)

| Operator | SharePoint | Dataverse |
|----------|-----------|-----------|
| `=`, `<>` | Yes | Yes |
| `<`, `>`, `<=`, `>=` | Yes (numeric/date) | Yes |
| `&&` (And) | Yes | Yes |
| `\|\|` (Or) | Yes | Yes |
| `!` (Not) | **NO** | Yes |
| `in` | **NO** | Yes |
| `exactin` | **NO** | Yes |

### SharePoint-Specific Gotchas

- `Search()` is **NOT delegable**. Use `StartsWith()` or `Filter()` with `=`
- `IsBlank(Column)` is **NOT delegable**. Use `Column = Blank()` instead
- `in` operator with arrays is **NOT delegable**: `Status in ["A", "B"]`. Use `Status = "A" || Status = "B"`
- Person fields: only `.Email` and `.DisplayName` are delegable
- Choice fields: only `=` is delegable (not `StartsWith`)

### UDFs and Delegation

**UDFs inside Filter() are NEVER delegable**, regardless of what the UDF contains:

```powerfx
// NOT DELEGABLE (even though the inner logic is simple equality):
Filter(Items, MyUDF(Status))

// DELEGABLE (same logic written inline):
Filter(Items, Status = "Active" || Status = "Pending")
```

For datasets >2000 records, always use inline delegable expressions.

### Delegation-Safe Patterns

```powerfx
// Text search (SharePoint-delegable)
Filter(Items, StartsWith(Title, searchTerm))

// Status filter (delegable)
Filter(Items, IsBlank(selectedStatus) || Status = selectedStatus)

// Owner filter (delegable)
Filter(Items, UserPermissions.CanViewAll || Owner.Email = User().Email)

// Date filter (delegable)
Filter(Items, 'Created On' >= DateAdd(Today(), -30, TimeUnit.Days))

// Combined (delegable)
Filter(
    Items,
    (IsBlank(statusFilter) || Status = statusFilter) &&
    (UserPermissions.CanViewAll || Owner.Email = User().Email) &&
    StartsWith(Title, searchTerm)
)
```

### Pagination for Large Datasets

```powerfx
// FirstN(Skip()) pattern for server-side pagination
FirstN(
    Skip(
        Sort(
            Filter(Items, Status = "Active"),
            'Created On', SortOrder.Descending
        ),
        (currentPage - 1) * pageSize
    ),
    pageSize
)
```

---

## 4. Function Reference (Verified Syntax)

### Filter()
```powerfx
Filter(Table, Formula1 [, Formula2, ...])
// Multiple formulas are combined with AND
// Each formula must return Boolean
```

### Search()
```powerfx
Search(Table, SearchString, Column1 [, Column2, ...])
// FIRST argument is a TABLE, not a text value
// Case-insensitive substring match
// NOT delegable with SharePoint
// Returns empty table if SearchString is blank
```

**WRONG**: `Search(textValue, searchTerm)` -- Search does NOT take text as first argument

### LookUp()
```powerfx
LookUp(Table, Formula [, ReductionFormula])
// Returns FIRST matching record (or reduced value)
// Max 2 lookups in a single query expression for performance
```

### Sort() / SortByColumns()
```powerfx
Sort(Table, Formula [, SortOrder])
// Formula can only be a single column name for delegation
SortByColumns(Table, "ColumnName1" [, SortOrder1, "ColumnName2", SortOrder2, ...])
// Column names are strings
```

### With()
```powerfx
With(Record, Formula)
// Creates named local values for readability
// CORRECT: Use for computed values
With({ total: x + y, avg: (x + y) / 2 }, If(avg > 10, "High", "Low"))
// WRONG: Don't use for side effects
```

### Concurrent()
```powerfx
Concurrent(Formula1, Formula2 [, ...])
// Evaluates multiple formulas at the same time (parallel network calls)
// Only useful for formulas with connector/Dataverse calls
// Can only be used in behavior properties (OnStart, OnSelect, OnVisible)
```

### Patch()
```powerfx
// Create or modify single record
Patch(DataSource, BaseRecord, ChangeRecord)
// Merge records (no data source)
Patch(Record1, Record2)
// Returns the patched record
```

### IfError()
```powerfx
IfError(Value1, Replacement1 [, Value2, Replacement2, ...] [, DefaultResult])
// Tests values for errors, returns replacement on error
// Structure resembles If() but tests for errors
```

### IsBlank() / IsEmpty()
```powerfx
IsBlank(Value)    // Tests scalar for blank OR empty string
IsEmpty(Table)    // Tests table for zero records
// For blank-only check (not empty string): Value = Blank()
// For SharePoint delegation: Column = Blank() (not IsBlank(Column))
```

### ColorValue() / ColorFade() / RGBA()
```powerfx
ColorValue("#0078D4")                 // 6-digit hex
ColorValue("#ff7f5080")               // 8-digit hex with alpha
ColorFade(Color.Red, -0.20)           // 20% darker (range: -1 to 1)
ColorFade(ThemeColors.Primary, 0.60)  // 60% lighter
RGBA(0, 120, 212, 100%)              // Red, Green, Blue (0-255), Alpha (0%-100%)
```

### Notify()
```powerfx
Notify(Message [, NotificationType [, Timeout]])
// NotificationType: .Error, .Warning, .Success, .Information
// Timeout: milliseconds (0 = manual dismiss)
Notify("Saved!", NotificationType.Success, 5000)
```

### RoundUp() (NOT Ceiling)
```powerfx
RoundUp(Number, DecimalPlaces)
// Power Fx does NOT have Ceiling(). Use RoundUp(value, 0) instead.
RoundUp(3.2, 0)  // Returns 4
RoundUp(totalItems / pageSize, 0)  // Page count calculation
```

### Today() vs Now()
```powerfx
Today()    // Returns Date (no time component), local timezone
Now()      // Returns DateTime (with time), local timezone
// SharePoint stores DateTime in UTC. Convert with DateAdd():
DateAdd(utcDateTime, 1, TimeUnit.Hours)  // UTC to CET (winter)
```

---

## 5. App.OnStart vs App.Formulas

| Aspect | App.OnStart | App.Formulas |
|--------|-------------|--------------|
| Model | Imperative (runs once) | Declarative (on-demand) |
| Blocks startup | Yes | No (lazy evaluation) |
| Mutability | Variables can change | Immutable definitions |
| Side effects | Set, Collect, Navigate | None allowed |
| Direction | Being phased out | Recommended by Microsoft |

### What Goes Where

**App.Formulas** (declarative):
- Constants, theme colors, configuration
- Computed values (UserProfile, permissions)
- UDFs (pure + behavior)
- Named Formulas that reference data sources (lazy-loaded)

**App.OnStart** (imperative):
- Mutable state: `Set(AppState, { IsLoading: false, ... })`
- Collections: `ClearCollect(CachedData, Filter(...))`
- One-time imperative actions
- `Concurrent()` for parallel data loading

---

## 6. Office365 Connector Methods

| Method | Purpose |
|--------|---------|
| `Office365Users.MyProfileV2()` | Current user profile (recommended over v1) |
| `Office365Users.UserProfileV2(id)` | Specific user by ID/UPN |
| `Office365Users.SearchUserV2({searchTerm: "...", top: 5})` | Search users |
| `Office365Users.Manager(id)` | Get user's manager |
| `Office365Users.DirectReports(id)` | Get direct reports |

**Properties**: `.DisplayName`, `.Mail`, `.Department`, `.JobTitle`, `.Id` (GUID), `.UserPrincipalName`, `.City`, `.CompanyName`, `.GivenName`, `.Surname`, `.mobilePhone`

**Caching**: Always cache results in collections. Each user creates their own connection (not sharable).

---

## 7. Common Mistakes Checklist

Before writing Power Fx code, verify:

- [ ] **No `Ceiling()`** -- use `RoundUp(value, 0)`
- [ ] **No `Search(textValue, term)`** -- Search takes a TABLE as first argument
- [ ] **No UDFs inside delegable Filter()** -- write inline for >2000 records
- [ ] **No `Status in ["A", "B"]`** for SharePoint -- use `Status = "A" || Status = "B"`
- [ ] **No `IsBlank(Column)`** in SharePoint Filter -- use `Column = Blank()`
- [ ] **No type annotations on Named Formulas** -- only UDFs have `: Type` annotations
- [ ] **No `Function(x As Type)` syntax** -- correct UDF syntax is `Name(x: Type): ReturnType = ...`
- [ ] **No `Set()` inside Named Formulas** -- Named Formulas are declarative only
- [ ] **No `ThisItem` inside UDFs** -- pass field values as parameters
- [ ] **No `App` as variable name** -- `App` is a reserved system object

---

## 8. Naming Conventions

### Named Formulas
PascalCase nouns: `ThemeColors`, `UserProfile`, `DateRanges`, `AppConfig`

### UDFs
PascalCase with verb prefix:
- `Has*`, `Can*`, `Is*` -- Boolean checks
- `Get*` -- Data queries
- `Format*` -- Formatting
- `Notify*`, `Show*`, `Update*` -- Behavior actions (Void return)

### State Variables
PascalCase, no prefix: `AppState`, `ActiveFilters`, `UIState`

### Collections
Prefix + PascalCase: `Cached*`, `My*`, `Filter*`

### Controls
3-char prefix: `glr_`, `btn_`, `txt_`, `lbl_`, `drp_`, `form_`, `tog_`, `chk_`, `dat_`, `img_`, `ico_`, `cnt_`
