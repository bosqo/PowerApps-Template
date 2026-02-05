# Quick Start: PowerApps Canvas App Template

**Target:** Deploy working template to new customer project in <30 minutes
**Audience:** PowerApps developers familiar with connectors and Power Fx
**Assumptions:** You have access to a customer's Dataverse or SharePoint environment

## What You Get

- Named Formulas for user profile, roles, permissions (auto-calculated, reactive)
- Delegation-friendly filter UDFs for 2000+ record datasets
- Toast notification system with Fluent Design styling
- Gallery patterns with pagination for 500+ records
- Performance-optimized App.OnStart (<2 seconds)

See [CLAUDE.md](../CLAUDE.md) for complete feature list.

---

## Step 1: Clone Template Files (2 min)

1. Copy template files to your project:
   - `src/App-Formulas-Template.fx` → Your app's formulas section
   - `src/App-OnStart-Minimal.fx` → Your app's App.OnStart
   - `src/Control-Patterns-Modern.fx` → Copy patterns you need

2. In Power Apps Studio:
   - Select your canvas app
   - Open Advanced editor (Ctrl+Shift+X)
   - Paste formulas into corresponding sections

3. Fix import errors:
   - Blue squiggles on Dataverse/SharePoint connectors? Click → "Add data"
   - Missing collections? Check Step 2 (connect data sources)

---

## Step 2: Connect Required Data Sources (5 min)

1. Add these connectors to your app:
   - **Office365Users** - For user profile (required for roles/permissions)
   - **Office365Groups** - For Azure AD group membership (required for roles)
   - **SharePoint Lists** or **Dataverse** - For your app data

2. Add these tables as data sources:
   - **Departments** (SharePoint/Dataverse) - columns: `Name`, `Status`
   - **Categories** (SharePoint/Dataverse) - columns: `Name`, `Status`
   - **Items** (your main data table) - columns: `Owner`, `Status`, `Modified On`
   - (Add others as your app needs)

3. In Power Apps Studio:
   - Select Data → Connectors
   - Search for "Office365Users" → Connect
   - Search for "Office365Groups" → Connect
   - Add your SharePoint/Dataverse tables via Data → Add data

4. Verify in formula bar:
   - Type: `Office365Users.MyProfileV2()` → Should return your profile
   - Type: `Items` → Should show your table

---

## Step 3: Configure Azure AD Group IDs (5 min)

The template uses Azure AD groups to determine user roles (Admin, Manager, HR, etc.).

1. Find your group IDs in Azure Portal:
   - Go to https://portal.azure.com → Azure Active Directory → Groups
   - Find groups for your organization (e.g., "Sales Team", "Managers")
   - Copy group ID (not group name) for each role

2. In Power Apps, open Advanced editor (Ctrl+Shift+X) and find `App-Formulas-Template.fx`:
   - Scroll to "UserRoles" Named Formula (around line 186)
   - You'll see placeholder group IDs like:
   ```
   AdminGroupId: "00000000-0000-0000-0000-000000000001",  // TODO: Replace with your group ID
   ManagerGroupId: "00000000-0000-0000-0000-000000000002",  // TODO: Replace
   ```

3. Replace each placeholder with actual group IDs from Step 1

4. Verify: Ask a manager to login - they should see admin features if in Manager group

**Note:** If you don't have Azure AD groups, set group IDs to "invalid-id-for-testing" and add yourself to all roles temporarily for demo purposes. See [TROUBLESHOOTING.md](#roles-empty-or-all-false) for details.

---

## Step 4: Verify Setup (3 min)

1. Save and reload the app (Ctrl+R)
2. Open Power Apps Monitor (F12 in browser, or Ctrl+Shift+X in Studio)
3. Check:
   - [ ] App loads without errors (Monitor shows no red errors)
   - [ ] Startup time <2000ms (Monitor → Performance tab)
   - [ ] UserProfile populated (Monitor → Collections → Check for profile data)
   - [ ] NotificationStack collection exists and is empty (Monitor → Collections)
   - [ ] Galleries show data (no empty placeholders)

If something fails, see [TROUBLESHOOTING.md](./TROUBLESHOOTING.md)

---

## Step 5: Test & Deploy (3 min)

1. Test a complete user flow:
   - Add a record (form submission) → Should see green "Saved" toast notification
   - Edit the record → Toast appears on save
   - Delete (if allowed) → Toast appears
   - Search/filter galleries → Should show filtered results
   - Try action without permission → Should see red error toast

2. Share app with team:
   - Power Apps Studio → Share button
   - Add user emails or security groups
   - Set permission (Viewer, Editor, Owner)

3. Monitor for issues:
   - Check Monitor tool regularly for errors
   - Collect user feedback on performance
   - Adjust gallery pagination (500-record limit default) if needed

4. Next steps:
   - Customize gallery columns for your data
   - Add approval workflows
   - Connect to Power Automate flows for email/notifications
   - See [CLAUDE.md](../CLAUDE.md) for customization patterns

---

## Quick Reference

- **Performance target:** <2000ms startup, <500ms page navigation
- **Gallery limit:** 500+ records with pagination (FirstN/Skip pattern)
- **Delegation:** All filters work with 2000+ record SharePoint lists
- **Notifications:** See [CLAUDE.md - Notification System](../CLAUDE.md#notification-system)
- **Documentation:** [CLAUDE.md](../CLAUDE.md) for architecture, [TROUBLESHOOTING.md](./TROUBLESHOOTING.md) for issues

**Total time: ~18 minutes (target <30 min)**

Version: 1.0 (Phase 4, 2026-01-19)
