# Phase 4: User Experience & Documentation - Context

**Gathered:** 2026-01-18
**Status:** Ready for planning

<domain>
## Phase Boundary

Deliver a polished notification system with Fluent Design styling and comprehensive documentation. The phase covers two distinct domains:
1. **Toast Notifications** (NOTIF-01 through NOTIF-08) — Non-blocking visual feedback system for user actions
2. **Documentation & Configuration** (DOC-01 through DOC-05) — Developer onboarding and setup guides for customer projects

Notifications are non-blocking overlays appearing in top-right. Customization guidance and troubleshooting support are separate from implementation.

</domain>

<decisions>
## Implementation Decisions

### Notification Triggers
- Form submission success (create, edit, delete operations)
- Validation errors (field-level and form-level validation failures)
- Approval workflows (approve/reject actions on records)
- No other triggers in Phase 4 (additional triggers can be added in future phases)

### Notification Behavior
- **Stacking:** New notifications appear at top, pushing older ones down (top-to-bottom stack)
- **Position:** Top-right corner of screen (Fluent Design standard)
- **Auto-dismiss timing:**
  - Info messages: 5 seconds auto-dismiss
  - Success messages: 5 seconds auto-dismiss
  - Warning messages: 5 seconds auto-dismiss
  - Error messages: NO auto-dismiss (user must close via X button)
- **Non-blocking:** Toasts float as overlay; users can interact with app while toast is visible
- **Max count:** Show all toasts (unlimited stack, no forced removal)
- **Width:** Content-based (minimum 250px, maximum 400px; text wraps as needed)

### Notification Interaction
- **Manual dismissal:** X button in top-right corner of each toast
- **Visual indicators:**
  - Icon per message type (info icon, checkmark, warning triangle, error X)
  - Color coding (blue for info, green for success, amber for warning, red for error)
  - Brief animation on entrance (slide in) and exit (fade out)
- **Message content:** Text message only (no action buttons, no subtitles)
- **Accessibility:** Screen reader support with aria-label announcing message type

### Documentation & Configuration
- **Target audience:** PowerApps developers (assume PowerApps knowledge; focus on template-specific config)
- **Documentation locations:**
  - Inline code comments in App-Formulas-Template.fx
  - Separate QUICK-START.md file
  - Expanded CLAUDE.md section with setup/config/troubleshooting
- **Azure AD setup:** Minimal approach (just placeholders in code; assume developers know how to find group IDs from Azure portal)
- **Code comments standard:** Purpose + usage example per Named Formula and UDF
- **Versioning:** No versioning docs needed (template treated as stable v1)
- **CLAUDE.md expansions:**
  - Notification system guide (how to use NotifySuccess/NotifyError UDFs)
  - Setup & configuration section (Azure AD, data sources)
  - Quick-start example (clone template → configure → test)
  - Troubleshooting section (common issues and solutions)
- **Setup verification:** Checklist approach (simple "Is X configured?" items; no automated tests)

### Customization & Troubleshooting
- **Theming documentation:** Minimal (reference ThemeColors Named Formula; assume devs can read code)
- **Troubleshooting format:** Symptom-based (Problem → Solution pairs)
- **Key issues to document:**
  - Notifications don't appear (UDF not called correctly or data source issues)
  - Toasts block content (positioning or z-index problems)
  - Multiple toasts overlap (stacking math or container sizing issues)
- **UDF modification scope:** Basic modifications only (how to change timeout 3-5s, colors, message text; not architectural changes)

### Claude's Discretion
- Exact animation speed and easing (slide-in, fade-out timing)
- Notification container dimensions and padding
- Icon selection (specific Fluent Design icons to use)
- Font sizing and spacing within toast
- z-index layering and overflow behavior
- Error recovery if notifications fail to render

</decisions>

<specifics>
## Specific Ideas

- Notifications should feel like Microsoft Teams or Outlook — familiar to enterprise PowerApps users
- Errors require user action (X button); informational messages auto-dismiss so they don't block workflow
- Documentation should allow a PowerApps developer to configure and deploy template in <30 minutes
- Troubleshooting should anticipate common mistakes (group IDs wrong, data sources not connected)

</specifics>

<deferred>
## Deferred Ideas

- Notification action buttons (Undo, Retry, etc.) — future phase
- Sound notifications — future phase
- Notification history/log panel — future phase
- Scheduled/delayed notifications — future phase
- Mobile-specific toast positioning (bottom sheet on mobile) — future phase
- Notification localization beyond German — future phase

</deferred>

---

*Phase: 04-user-experience-documentation*
*Context gathered: 2026-01-18*
