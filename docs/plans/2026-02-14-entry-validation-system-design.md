# Dynamic Entry Validation System Design

**Date:** 2026-02-14
**Status:** Design Phase
**Approach:** Collection-Based Field Registry + Validation UDFs (Declarative-Reactive)

---

## Problem Statement

When building Power Apps without the Form control (using individual TextInputs, Dropdowns, DatePickers, etc. + `Patch()`), validation typically requires:

1. Manually checking every control by name in the submit button's `DisplayMode`
2. Repeating those checks in the `OnSelect` for error messages
3. Adding a new field = editing 3+ places (DisplayMode, OnSelect validation, error label)

This is brittle, error-prone, and doesn't scale.

**Goal:** A dynamic, collection-based validation system where:
- Fields are registered once in a central collection
- Validation rules are declared per field
- The submit button auto-disables when any field is invalid
- Error messages appear per field automatically
- Adding a new field = adding one row to the registry

---

## Approach Comparison

### Approach A: Validation Collection (Runtime State)
Register fields in a `FormFields` collection via `ClearCollect()` in `Screen.OnVisible`, then update validation state on each field's `OnChange`. The submit button checks `CountIf(FormFields, !IsValid) = 0`.

**Pros:** Truly dynamic, works with any number of fields
**Cons:** Requires `OnChange` on every control to update the collection state

### Approach B: Named Formula + Inline Record Table
Define a `FormValidation` Named Formula as a computed table where each row references a control's `.Value` directly. The formula auto-recalculates reactively.

**Pros:** Fully declarative, no OnChange wiring needed, auto-reactive
**Cons:** Named Formulas can't reference screen controls (only global scope)

### Approach C: Hybrid — State Variable with Validation UDFs
Use a single `FormState` record variable holding all field values (updated via `OnChange`), plus validation UDFs that operate on that record. A `FormErrors` Named Formula or computed variable derives all errors reactively.

**Pros:** Single source of truth, UDFs reusable, clean separation
**Cons:** Still needs OnChange per control, but only one-liner `Set()` calls

### Recommended: Approach C (Hybrid)

Approach C fits the existing template architecture (state variables + UDFs) and provides the best balance of maintainability, reusability, and Power Fx compliance.

---

## Architecture

```
┌─────────────────────────────────────────────────────────────┐
│ Layer 1: Field Registry (Named Formula — declarative)       │
│ - FieldRegistry table: field name, type, required, rules   │
│ - Defined once per screen/form in App.Formulas              │
└─────────────────────────────────────────────────────────────┘
                           ↓
┌─────────────────────────────────────────────────────────────┐
│ Layer 2: Form State (Variable — imperative)                 │
│ - FormState record holds current values of all fields       │
│ - Updated via control OnChange: Set(FormState, Patch(...))  │
└─────────────────────────────────────────────────────────────┘
                           ↓
┌─────────────────────────────────────────────────────────────┐
│ Layer 3: Validation Engine (UDFs — pure functions)          │
│ - ValidateField(fieldName, value) → error text or blank     │
│ - ValidateRequired(value) → Boolean                        │
│ - IsFormValid() checks all fields against registry          │
└─────────────────────────────────────────────────────────────┘
                           ↓
┌─────────────────────────────────────────────────────────────┐
│ Layer 4: UI Binding (Control properties)                    │
│ - btn_Submit.DisplayMode = If(IsFormValid(), Edit, Disabled)│
│ - lbl_Error_Email.Text = ValidateField("Email", ...)       │
│ - txt_Email.BorderColor = field-level error color           │
└─────────────────────────────────────────────────────────────┘
```

**State Flow:**
```
User types in txt_Email
  → OnChange: Set(FormState, Patch(FormState, {Email: Self.Text}))
    → IsFormValid() re-evaluates (references FormState)
      → btn_Submit.DisplayMode auto-updates
      → lbl_Error_Email.Text auto-updates (shows/hides error)
```

---

## Design Sections

### Section 1: Field Registry (Named Formula)

**File:** `src/App-Formulas-Template.fx`
**Location:** After validation UDFs section

The field registry is a Named Formula table that declares all form fields, their types, whether they're required, and which validation rule to apply.

```powerfx
// ============================================================================
// FIELD REGISTRY — Entry Validation System
// ============================================================================
// Purpose: Central declaration of all form fields and their validation rules
// Usage:  One registry per form/screen. Copy and customize per use case.
// Note:   This is a TEMPLATE. Each app screen defines its own registry.

// Validation rule identifiers (used in FieldRegistry.Rule)
ValidationRules = {
    None: "none",
    Email: "email",
    NotPastDate: "notpastdate",
    Alphanumeric: "alphanumeric",
    MinLength: "minlength",
    MaxLength: "maxlength",
    NumberRange: "numberrange",
    OneOf: "oneof"
};

// Example field registry for a "New Item" form
FieldRegistry_NewItem = Table(
    { FieldName: "Title",       FieldLabel: "Titel",          IsRequired: true,  Rule: "maxlength",    RuleParam: "100",           FieldType: "text" },
    { FieldName: "Description", FieldLabel: "Beschreibung",   IsRequired: false, Rule: "maxlength",    RuleParam: "500",           FieldType: "text" },
    { FieldName: "Email",       FieldLabel: "E-Mail",         IsRequired: true,  Rule: "email",        RuleParam: "",              FieldType: "text" },
    { FieldName: "Category",    FieldLabel: "Kategorie",      IsRequired: true,  Rule: "oneof",        RuleParam: "A,B,C,D",       FieldType: "choice" },
    { FieldName: "DueDate",     FieldLabel: "Fälligkeitsdatum", IsRequired: true, Rule: "notpastdate", RuleParam: "",              FieldType: "date" },
    { FieldName: "Priority",    FieldLabel: "Priorität",      IsRequired: true,  Rule: "oneof",        RuleParam: "Low,Medium,High,Critical", FieldType: "choice" },
    { FieldName: "Amount",      FieldLabel: "Betrag",         IsRequired: false, Rule: "none",         RuleParam: "",              FieldType: "number" }
);
```

**Why a Named Formula table?**
- Declarative, no runtime cost
- Auto-complete in the editor
- Can be referenced by validation UDFs
- Easy to copy/customize per screen

---

### Section 2: Form State Variable

**File:** `src/App-OnStart-Minimal.fx` (or `Screen.OnVisible`)
**Purpose:** Holds the current value of every form field as a single record

```powerfx
// Initialize form state — one property per field in FieldRegistry
// Call this in Screen.OnVisible or a "Reset Form" button
Set(FormState_NewItem, {
    Title: "",
    Description: "",
    Email: "",
    Category: "",
    DueDate: Blank(),
    Priority: "",
    Amount: 0
});

// Track whether user has interacted with each field (for "show errors only after touch")
Set(FormTouched_NewItem, {
    Title: false,
    Description: false,
    Email: false,
    Category: false,
    DueDate: false,
    Priority: false,
    Amount: false
});

// Track whether the form has been submitted at least once (show all errors after first submit attempt)
Set(FormSubmitAttempted_NewItem, false);
```

**Why a single record instead of individual variables?**
- One `Set()` call to reset all fields
- Single source of truth
- Follows existing `AppState` / `ActiveFilters` / `UIState` pattern from the template

---

### Section 3: Validation Engine (UDFs)

**File:** `src/App-Formulas-Template.fx`
**Location:** After existing validation UDFs

These UDFs are the core of the system. They take field values as parameters (never reference controls directly) and return error messages or blank.

```powerfx
// ============================================================================
// VALIDATION ENGINE — Dynamic Entry Validation
// ============================================================================

// --------------------------------------------------------------------------
// Core: Validate a single value against a rule
// Returns: Error message text (blank = valid)
// --------------------------------------------------------------------------
ValidateRule(value: Text, rule: Text, ruleParam: Text, fieldLabel: Text): Text =
    If(
        // No rule
        rule = "none" || IsBlank(rule),
        "",

        // Email validation (reuses existing IsValidEmail UDF)
        rule = "email",
        If(!IsValidEmail(value), fieldLabel & ": Ungültige E-Mail-Adresse", ""),

        // Not in past
        rule = "notpastdate",
        If(
            !IsBlank(value) && DateValue(value) < GetCETToday(),
            fieldLabel & ": Datum darf nicht in der Vergangenheit liegen",
            ""
        ),

        // Alphanumeric only
        rule = "alphanumeric",
        If(!IsAlphanumeric(value), fieldLabel & ": Nur Buchstaben und Zahlen erlaubt", ""),

        // Max length
        rule = "maxlength",
        If(
            Len(value) > Value(ruleParam),
            fieldLabel & ": Maximal " & ruleParam & " Zeichen erlaubt",
            ""
        ),

        // Min length
        rule = "minlength",
        If(
            Len(value) < Value(ruleParam),
            fieldLabel & ": Mindestens " & ruleParam & " Zeichen erforderlich",
            ""
        ),

        // Value in allowed list
        rule = "oneof",
        If(!IsOneOf(value, ruleParam), fieldLabel & ": Ungültiger Wert", ""),

        // Unknown rule — no error
        ""
    );

// --------------------------------------------------------------------------
// Required field check
// Returns: Error message text (blank = valid)
// --------------------------------------------------------------------------
ValidateRequired(value: Text, fieldLabel: Text): Text =
    If(IsBlank(value), fieldLabel & ": Pflichtfeld", "");

// --------------------------------------------------------------------------
// Full field validation (required + rule)
// Returns: First error message found (blank = valid)
// --------------------------------------------------------------------------
ValidateField(value: Text, isRequired: Boolean, rule: Text, ruleParam: Text, fieldLabel: Text): Text =
    With(
        { requiredError: If(isRequired, ValidateRequired(value, fieldLabel), "") },
        If(
            !IsBlank(requiredError),
            requiredError,
            ValidateRule(value, rule, ruleParam, fieldLabel)
        )
    );

// --------------------------------------------------------------------------
// Get error message for a specific field from the registry
// Usage: GetFieldError("Email", FormState_NewItem.Email, FieldRegistry_NewItem)
// --------------------------------------------------------------------------
GetFieldError(fieldName: Text, fieldValue: Text, registry: Table): Text =
    With(
        { field: LookUp(registry, FieldName = fieldName) },
        If(
            IsBlank(field),
            "",
            ValidateField(fieldValue, field.IsRequired, field.Rule, field.RuleParam, field.FieldLabel)
        )
    );
```

**Why text-based value parameter?**
- Power Fx UDFs can't accept `Untyped` — a single `Text` parameter works for most inputs
- Date fields: pass `Text(DueDate, "yyyy-mm-dd")` or check IsBlank separately
- Number fields: pass `Text(Amount)` for validation, use the actual number for Patch

---

### Section 4: Form-Level Validation UDFs

These UDFs check the entire form state against the registry.

```powerfx
// --------------------------------------------------------------------------
// Check if entire form is valid
// Pass each field value from FormState explicitly
// --------------------------------------------------------------------------
// NOTE: Power Fx UDFs cannot iterate a table dynamically and map field names
// to record properties. We must validate each field explicitly.
// This is the ONE place you list fields — not in DisplayMode, not in OnSelect.

IsFormValid_NewItem(): Boolean =
    IsBlank(ValidateField(FormState_NewItem.Title, true, "maxlength", "100", "Titel")) &&
    IsBlank(ValidateField(FormState_NewItem.Email, true, "email", "", "E-Mail")) &&
    IsBlank(ValidateField(FormState_NewItem.Category, true, "oneof", "A,B,C,D", "Kategorie")) &&
    IsBlank(ValidateField(FormState_NewItem.DueDate, true, "notpastdate", "", "Fälligkeitsdatum")) &&
    IsBlank(ValidateField(FormState_NewItem.Priority, true, "oneof", "Low,Medium,High,Critical", "Priorität")) &&
    IsBlank(ValidateField(FormState_NewItem.Description, false, "maxlength", "500", "Beschreibung")) &&
    IsBlank(ValidateField(FormState_NewItem.Amount, false, "none", "", "Betrag"));

// --------------------------------------------------------------------------
// Collect all errors into a single text (for summary display)
// --------------------------------------------------------------------------
GetFormErrors_NewItem(): Text =
    Concat(
        Filter(
            Table(
                { Error: ValidateField(FormState_NewItem.Title, true, "maxlength", "100", "Titel") },
                { Error: ValidateField(FormState_NewItem.Email, true, "email", "", "E-Mail") },
                { Error: ValidateField(FormState_NewItem.Category, true, "oneof", "A,B,C,D", "Kategorie") },
                { Error: ValidateField(FormState_NewItem.DueDate, true, "notpastdate", "", "Fälligkeitsdatum") },
                { Error: ValidateField(FormState_NewItem.Priority, true, "oneof", "Low,Medium,High,Critical", "Priorität") },
                { Error: ValidateField(FormState_NewItem.Description, false, "maxlength", "500", "Beschreibung") },
                { Error: ValidateField(FormState_NewItem.Amount, false, "none", "", "Betrag") }
            ),
            !IsBlank(Error)
        ),
        Error,
        Char(10)
    );
```

**Important trade-off:** Power Fx cannot dynamically map a string field name like `"Title"` to `FormState.Title` at runtime. There is no `GetField(record, "fieldName")` function. This means the `IsFormValid_NewItem()` UDF must list each field explicitly. However, this is the **only** place fields are listed for validation — the submit button, error labels, and border colors all reference this single UDF.

---

### Section 5: Control Wiring

**File:** Control properties (in the Power Apps Studio)

#### 5.1 TextInput OnChange — Update FormState

```powerfx
// txt_Title.OnChange
Set(FormState_NewItem, Patch(FormState_NewItem, { Title: Self.Text }));
Set(FormTouched_NewItem, Patch(FormTouched_NewItem, { Title: true }));

// txt_Email.OnChange
Set(FormState_NewItem, Patch(FormState_NewItem, { Email: Self.Text }));
Set(FormTouched_NewItem, Patch(FormTouched_NewItem, { Email: true }));

// drp_Category.OnChange
Set(FormState_NewItem, Patch(FormState_NewItem, { Category: Self.Selected.Value }));
Set(FormTouched_NewItem, Patch(FormTouched_NewItem, { Category: true }));

// dat_DueDate.OnChange
Set(FormState_NewItem, Patch(FormState_NewItem, { DueDate: Text(Self.SelectedDate, "yyyy-mm-dd") }));
Set(FormTouched_NewItem, Patch(FormTouched_NewItem, { DueDate: true }));

// drp_Priority.OnChange
Set(FormState_NewItem, Patch(FormState_NewItem, { Priority: Self.Selected.Value }));
Set(FormTouched_NewItem, Patch(FormTouched_NewItem, { Priority: true }));
```

#### 5.2 Submit Button — Single Check

```powerfx
// btn_Submit.DisplayMode
If(IsFormValid_NewItem(), DisplayMode.Edit, DisplayMode.Disabled)

// btn_Submit.OnSelect
Set(FormSubmitAttempted_NewItem, true);
If(
    IsFormValid_NewItem(),
    // Patch to SharePoint
    Patch(
        MySharePointList,
        Defaults(MySharePointList),
        {
            Title: FormState_NewItem.Title,
            Description: FormState_NewItem.Description,
            Email: FormState_NewItem.Email,
            Category: {Value: FormState_NewItem.Category},
            DueDate: DateValue(FormState_NewItem.DueDate),
            Priority: {Value: FormState_NewItem.Priority},
            Amount: Value(FormState_NewItem.Amount)
        }
    );
    NotifySuccess("Eintrag erfolgreich gespeichert");
    Back(),
    // Show all errors
    NotifyWarning(GetFormErrors_NewItem())
)
```

#### 5.3 Per-Field Error Labels

```powerfx
// lbl_Error_Title.Text
ValidateField(FormState_NewItem.Title, true, "maxlength", "100", "Titel")

// lbl_Error_Title.Visible
(FormTouched_NewItem.Title || FormSubmitAttempted_NewItem) &&
    !IsBlank(ValidateField(FormState_NewItem.Title, true, "maxlength", "100", "Titel"))

// lbl_Error_Email.Text
ValidateField(FormState_NewItem.Email, true, "email", "", "E-Mail")

// lbl_Error_Email.Visible
(FormTouched_NewItem.Email || FormSubmitAttempted_NewItem) &&
    !IsBlank(ValidateField(FormState_NewItem.Email, true, "email", "", "E-Mail"))
```

#### 5.4 Field Border Color (Visual Feedback)

```powerfx
// txt_Title.BorderColor
If(
    (FormTouched_NewItem.Title || FormSubmitAttempted_NewItem) &&
        !IsBlank(ValidateField(FormState_NewItem.Title, true, "maxlength", "100", "Titel")),
    ThemeColors.Error,
    ColorValue("#8A8886")  // Default border
)

// txt_Email.BorderColor
If(
    (FormTouched_NewItem.Email || FormSubmitAttempted_NewItem) &&
        !IsBlank(ValidateField(FormState_NewItem.Email, true, "email", "", "E-Mail")),
    ThemeColors.Error,
    ColorValue("#8A8886")
)
```

---

### Section 6: Simplification Helper — Reducing Repetition

To avoid repeating `ValidateField(FormState_NewItem.Email, true, "email", "", "E-Mail")` in multiple control properties (error label text, visibility, border color), create per-field error Named Formulas:

```powerfx
// ============================================================================
// PER-FIELD ERROR FORMULAS (Auto-reactive)
// ============================================================================
// These Named Formulas auto-recalculate when FormState changes.

Error_NewItem_Title = ValidateField(FormState_NewItem.Title, true, "maxlength", "100", "Titel");
Error_NewItem_Email = ValidateField(FormState_NewItem.Email, true, "email", "", "E-Mail");
Error_NewItem_Category = ValidateField(FormState_NewItem.Category, true, "oneof", "A,B,C,D", "Kategorie");
Error_NewItem_DueDate = ValidateField(FormState_NewItem.DueDate, true, "notpastdate", "", "Fälligkeitsdatum");
Error_NewItem_Priority = ValidateField(FormState_NewItem.Priority, true, "oneof", "Low,Medium,High,Critical", "Priorität");
Error_NewItem_Description = ValidateField(FormState_NewItem.Description, false, "maxlength", "500", "Beschreibung");
Error_NewItem_Amount = ValidateField(FormState_NewItem.Amount, false, "none", "", "Betrag");

// Form-level validity (references the error formulas)
IsValid_NewItem =
    IsBlank(Error_NewItem_Title) &&
    IsBlank(Error_NewItem_Email) &&
    IsBlank(Error_NewItem_Category) &&
    IsBlank(Error_NewItem_DueDate) &&
    IsBlank(Error_NewItem_Priority) &&
    IsBlank(Error_NewItem_Description) &&
    IsBlank(Error_NewItem_Amount);
```

**Now control properties become trivial:**

```powerfx
// btn_Submit.DisplayMode
If(IsValid_NewItem, DisplayMode.Edit, DisplayMode.Disabled)

// lbl_Error_Email.Text
Error_NewItem_Email

// lbl_Error_Email.Visible
(FormTouched_NewItem.Email || FormSubmitAttempted_NewItem) && !IsBlank(Error_NewItem_Email)

// txt_Email.BorderColor
If(
    (FormTouched_NewItem.Email || FormSubmitAttempted_NewItem) && !IsBlank(Error_NewItem_Email),
    ThemeColors.Error,
    ColorValue("#8A8886")
)
```

This is the **sweet spot**: each field's validation is defined exactly once (the `Error_NewItem_*` formula), and all UI bindings reference that single source.

---

### Section 7: Alternative — Collection-Based Dynamic Approach

For apps with many forms or dynamically generated fields, a collection-based approach avoids listing fields in UDFs entirely. This uses `ForAll` + `Collect` instead of Named Formulas.

```powerfx
// Screen.OnVisible — Initialize validation collection
ClearCollect(
    ValidationState,
    ForAll(
        FieldRegistry_NewItem,
        {
            FieldName: FieldName,
            FieldLabel: FieldLabel,
            Value: "",
            IsRequired: IsRequired,
            Rule: Rule,
            RuleParam: RuleParam,
            ErrorMessage: "",
            IsTouched: false
        }
    )
);

// txt_Title.OnChange — Update the collection row
Patch(
    ValidationState,
    LookUp(ValidationState, FieldName = "Title"),
    {
        Value: Self.Text,
        IsTouched: true,
        ErrorMessage: ValidateField(Self.Text, true, "maxlength", "100", "Titel")
    }
);

// btn_Submit.DisplayMode — Fully dynamic check
If(
    CountIf(
        ValidationState,
        !IsBlank(
            ValidateField(Value, IsRequired, Rule, RuleParam, FieldLabel)
        )
    ) = 0,
    DisplayMode.Edit,
    DisplayMode.Disabled
)

// lbl_Error_Title.Text — From collection
LookUp(ValidationState, FieldName = "Title").ErrorMessage

// lbl_Error_Title.Visible
With(
    { vs: LookUp(ValidationState, FieldName = "Title") },
    (vs.IsTouched || FormSubmitAttempted_NewItem) && !IsBlank(vs.ErrorMessage)
)
```

**Trade-offs vs Named Formula approach:**
| Aspect | Named Formulas (Section 6) | Collection (Section 7) |
|--------|---------------------------|----------------------|
| Adding a field | Add 1 Error formula + 1 line in IsValid | Add 1 row to FieldRegistry |
| Reactivity | Auto-reactive | Must update collection in OnChange |
| Dynamic forms | No (fields fixed at design time) | Yes (can modify FieldRegistry at runtime) |
| Performance | Slightly better (no collection ops) | Fine for <50 fields |
| Complexity | Simpler | More moving parts |
| Debugging | Easier (each error is a named value) | Harder (collection rows) |

**Recommendation:** Use **Named Formulas (Section 6)** for most apps. Use **Collection (Section 7)** only if you need truly dynamic forms where fields are added/removed at runtime.

---

## Implementation Steps

### Step 1: Add Validation Engine UDFs
- Add `ValidateRule()`, `ValidateRequired()`, `ValidateField()` to `App-Formulas-Template.fx`
- Add `ValidationRules` Named Formula (constants)
- These are generic and reusable across all forms/screens

### Step 2: Create a Sample Field Registry
- Add `FieldRegistry_NewItem` Named Formula as a template example
- Document how to customize per project

### Step 3: Add Per-Field Error Named Formulas
- Add `Error_NewItem_*` Named Formulas
- Add `IsValid_NewItem` Named Formula
- These serve as the template example

### Step 4: Add FormState Initialization
- Add `FormState_NewItem`, `FormTouched_NewItem`, `FormSubmitAttempted_NewItem` to `App-OnStart-Minimal.fx`

### Step 5: Document Control Wiring Patterns
- Add control wiring examples to `Control-Patterns-Modern.fx`
- Include: OnChange, DisplayMode, error labels, border colors

### Step 6: Add Form Reset UDF
```powerfx
ResetForm_NewItem(): Void = {
    Set(FormState_NewItem, {
        Title: "", Description: "", Email: "",
        Category: "", DueDate: Blank(), Priority: "", Amount: 0
    });
    Set(FormTouched_NewItem, {
        Title: false, Description: false, Email: false,
        Category: false, DueDate: false, Priority: false, Amount: false
    });
    Set(FormSubmitAttempted_NewItem, false)
};
```

### Step 7: Update CLAUDE.md and UDF-REFERENCE.md
- Add validation system section to CLAUDE.md
- Add new UDFs to UDF-REFERENCE.md

---

## Naming Convention

| Element | Pattern | Example |
|---------|---------|---------|
| Field Registry | `FieldRegistry_[FormName]` | `FieldRegistry_NewItem` |
| Form State | `FormState_[FormName]` | `FormState_NewItem` |
| Touched State | `FormTouched_[FormName]` | `FormTouched_NewItem` |
| Submit Attempted | `FormSubmitAttempted_[FormName]` | `FormSubmitAttempted_NewItem` |
| Per-field Error | `Error_[FormName]_[Field]` | `Error_NewItem_Email` |
| Form Valid | `IsValid_[FormName]` | `IsValid_NewItem` |
| Form Valid UDF | `IsFormValid_[FormName]()` | `IsFormValid_NewItem()` |
| Form Reset UDF | `ResetForm_[FormName]()` | `ResetForm_NewItem()` |

---

## Integration with Existing Template

This system builds on existing infrastructure:

| Existing | Used By |
|----------|---------|
| `IsValidEmail()` | `ValidateRule()` — rule = "email" |
| `IsNotPastDate()` | `ValidateRule()` — rule = "notpastdate" |
| `IsAlphanumeric()` | `ValidateRule()` — rule = "alphanumeric" |
| `IsOneOf()` | `ValidateRule()` — rule = "oneof" |
| `HasMaxLength()` | `ValidateRule()` — rule = "maxlength" |
| `NotifySuccess()` | Submit button success notification |
| `NotifyWarning()` | Submit button validation summary |
| `NotifyValidationError()` | Per-field error notifications (optional) |
| `ThemeColors.Error` | Error border color |
| `GetCETToday()` | Date validation (CET-aware) |

No existing UDFs need modification. The validation engine wraps them.

---

## Edge Cases & Considerations

### Date Fields
Date values must be converted to Text for the generic `ValidateField()` UDF:
```powerfx
// In FormState, store as text
DueDate: Text(Self.SelectedDate, "yyyy-mm-dd")

// In ValidateRule for "notpastdate", parse back
DateValue(value) < GetCETToday()
```

Alternatively, create a `ValidateDate()` overload UDF that accepts `Date` type directly.

### Number Fields
Store as text in FormState for validation, convert back for Patch:
```powerfx
// FormState
Amount: Text(Self.Value)

// Patch
Amount: Value(FormState_NewItem.Amount)
```

### Edit Mode (Pre-populated Fields)
When editing an existing record, initialize FormState from the record:
```powerfx
Set(FormState_NewItem, {
    Title: SelectedRecord.Title,
    Email: SelectedRecord.Email,
    Category: SelectedRecord.Category.Value,
    DueDate: Text(SelectedRecord.DueDate, "yyyy-mm-dd"),
    Priority: SelectedRecord.Priority.Value,
    Amount: Text(SelectedRecord.Amount)
});
// Mark all as touched so existing invalid data shows errors immediately
Set(FormTouched_NewItem, {
    Title: true, Description: true, Email: true,
    Category: true, DueDate: true, Priority: true, Amount: true
});
```

### Custom Validation Rules
To add a project-specific rule (e.g., "phone number"), extend `ValidateRule()`:
```powerfx
// Add a new case to the If() chain in ValidateRule:
rule = "phone",
If(!IsMatch(value, "^\+?[0-9\s\-]{7,15}$"), fieldLabel & ": Ungültige Telefonnummer", ""),
```
