# Power Platform Deployment - Quick Start (One Page)

## ⚡ Installation (Once)

```powershell
# Install PAC CLI
dotnet tool install --global Microsoft.PowerApps.CLI.Tool

# Verify
pac --version
```

## 🔑 Authentication (Once per Environment)

```powershell
# Connect to each environment
pac auth create --environment https://your-org-dev.crm4.dynamics.com
pac auth create --environment https://your-org-test.crm4.dynamics.com
pac auth create --environment https://your-org-prod.crm4.dynamics.com

# List connections
pac auth list

# Switch environment
pac auth select --index 1
```

## 🚀 Three Main Commands (90% of Use Cases)

### 1️⃣ Daily Dev: Export from DEV → Git

```powershell
.\deploy-dev.bat YourSolutionName

# Then commit
git add src/
git commit -m "feat: Your changes"
git push
```

**When:** After completing feature/fix in DEV

**What it does:**
- ✅ Exports unmanaged from DEV
- ✅ Unpacks to `./src/` for Git

---

### 2️⃣ Weekly Release: Git → TEST

```powershell
.\deploy-test.bat YourSolutionName
```

**When:** Sprint end, ready for UAT

**What it does:**
- ✅ Packs managed from `./src/`
- ✅ Runs Solution Checker
- ✅ Imports to TEST

---

### 3️⃣ Production: Git → PROD

```powershell
# BACKUP FIRST!
pac auth select --index 3
pac solution export --name "YourSolution" --path "./backups/backup-$(Get-Date -Format 'yyyyMMdd').zip" --managed

# Then deploy
.\deploy-prod.bat YourSolutionName
```

**When:** After successful UAT, stakeholder approval

**What it does:**
- ✅ Packs managed from `./src/`
- ✅ Runs Solution Checker
- ✅ Double confirmation
- ✅ Imports to PROD

---

## 🔧 Common PAC CLI Commands

| Task | Command |
|------|---------|
| List auth | `pac auth list` |
| Switch env | `pac auth select --index 2` |
| Current env | `pac org who` |
| List solutions | `pac solution list` |
| List connections | `pac connection list` |

---

## ⚠️ Golden Rules

| Rule | Why |
|------|-----|
| ✅ **Always backup PROD before deploy** | Enable rollback |
| ✅ **DEV = Unmanaged, PROD = Managed** | ALM best practice |
| ✅ **Always use Git between TEST & PROD** | Version control |
| ❌ **Never edit directly in PROD** | All changes via DEV |
| ❌ **Never skip TEST for PROD** | Catch bugs early |

---

## 🆘 Emergency Commands

### Quick Switch Environments
```powershell
pac auth select --index 1    # DEV
pac auth select --index 2    # TEST
pac auth select --index 3    # PROD
```

### Rollback PROD
```powershell
pac solution import --path "./backups/your-backup.zip" --force-overwrite
```

### View Logs
```powershell
Get-Content "$env:USERPROFILE\.pac\logs\latest.log"
```

---

## 📋 PROD Deployment Checklist

**Before:**
- [ ] Tested in TEST ✓
- [ ] Solution Checker passed
- [ ] Backup created
- [ ] Version bumped
- [ ] Stakeholders informed

**After:**
- [ ] Connection References connected
- [ ] Environment Variables set
- [ ] Flows activated
- [ ] Smoke test passed
- [ ] Git tag created: `git tag -a v1.2.3 -m "Release"`

---

## 🐛 Troubleshooting Quick Fixes

| Problem | Fix |
|---------|-----|
| "Solution not found" | `pac solution list` (use technical name) |
| "Auth failed" | `pac auth create --environment <URL>` |
| "Missing dependencies" | Deploy base solution first |
| "pac: command not found" | Restart PowerShell, reinstall PAC CLI |

---

## 📚 Full Documentation

- **Step-by-step guide:** `DEPLOYMENT-INSTRUCTIONS.md`
- **Visual workflows:** `DEPLOYMENT-WORKFLOW.md`
- **Cheat sheet:** `DEPLOYMENT-CHEATSHEET.md`
- **Detailed guide:** `docs/DEPLOYMENT-GUIDE.md`

---

## 🎯 Typical Day

```powershell
# Morning: Sync with Git
git pull origin main

# Work in DEV environment (via portal)
# ... make changes ...

# Evening: Export & commit
.\deploy-dev.bat MySolution
git add src/
git commit -m "feat: Add new approval step"
git push

# Friday: Deploy to TEST
.\deploy-test.bat MySolution
# ... UAT testing over weekend ...

# Monday: If all good, plan PROD deployment
```

---

## 💡 Pro Tips

1. **Alias for frequent commands:**
   ```powershell
   # Add to PowerShell profile
   function dep-dev { .\deploy-dev.bat $args[0] }
   function dep-test { .\deploy-test.bat $args[0] }
   function dep-prod { .\deploy-prod.bat $args[0] }

   # Usage: dep-dev MySolution
   ```

2. **Check Git before deploy:**
   ```powershell
   git status          # Uncommitted changes?
   git pull           # Latest from team?
   ```

3. **Always review Solution Checker results** - Fix Critical/High before PROD

4. **Tag releases:**
   ```powershell
   git tag -a v1.2.3 -m "Release notes"
   git push origin v1.2.3
   ```

---

**Need Help?** See `DEPLOYMENT-INSTRUCTIONS.md` for detailed step-by-step guidance.
