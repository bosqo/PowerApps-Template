# Power Platform Deployment - Visual Workflow

## 🔄 Complete Deployment Lifecycle

```
┌─────────────────────────────────────────────────────────────────────────┐
│                          DEVELOPMENT (DEV)                              │
│                                                                         │
│  ┌──────────────┐                                                      │
│  │  Developer   │  Makes changes in DEV Environment                    │
│  │  Changes     │  - Canvas Apps, Flows, Dataverse Tables             │
│  └──────┬───────┘                                                      │
│         │                                                               │
│         ▼                                                               │
│  ┌──────────────────────────────────────────────────────┐             │
│  │  ./deploy-dev.bat YourSolution                       │             │
│  │                                                       │             │
│  │  ✓ Export unmanaged Solution from DEV               │             │
│  │  ✓ Unpack to ./src/ for Git                         │             │
│  └──────┬───────────────────────────────────────────────┘             │
│         │                                                               │
└─────────┼───────────────────────────────────────────────────────────────┘
          │
          ▼
┌─────────────────────────────────────────────────────────────────────────┐
│                        SOURCE CONTROL (Git)                             │
│                                                                         │
│  ┌──────────────────────────────────────────────────────┐             │
│  │  git add src/                                        │             │
│  │  git commit -m "feat: Add approval workflow"        │             │
│  │  git push origin main                                │             │
│  └──────┬───────────────────────────────────────────────┘             │
│         │                                                               │
│         │  ┌────────────────────────────────────────┐                 │
│         ├─►│  Feature Branch                        │                 │
│         │  │  git checkout -b feature/new-feature   │                 │
│         │  │  git push -u origin feature/...        │                 │
│         │  └────────────────────────────────────────┘                 │
│         │                                                               │
│         │  ┌────────────────────────────────────────┐                 │
│         └─►│  Pull Request                          │                 │
│            │  gh pr create --title "..."            │                 │
│            │  Code Review → Merge to main           │                 │
│            └────────┬───────────────────────────────┘                 │
│                     │                                                   │
└─────────────────────┼───────────────────────────────────────────────────┘
                      │
                      ▼
┌─────────────────────────────────────────────────────────────────────────┐
│                      TEST/UAT ENVIRONMENT                               │
│                                                                         │
│  ┌──────────────────────────────────────────────────────┐             │
│  │  ./deploy-test.bat YourSolution                      │             │
│  │                                                       │             │
│  │  ✓ Pack managed Solution from ./src/                │             │
│  │  ✓ Run Solution Checker (optional)                  │             │
│  │  ✓ Import to TEST Environment                       │             │
│  └──────┬───────────────────────────────────────────────┘             │
│         │                                                               │
│         ▼                                                               │
│  ┌──────────────────────────────────────────────────────┐             │
│  │  User Acceptance Testing (UAT)                       │             │
│  │                                                       │             │
│  │  ✓ Test all features                                │             │
│  │  ✓ Verify business logic                            │             │
│  │  ✓ Check user permissions                           │             │
│  │  ✓ Performance testing                              │             │
│  └──────┬───────────────────────────────────────────────┘             │
│         │                                                               │
│         │  Bugs found?                                                 │
│         ├─────YES────► Back to DEV ─────┐                            │
│         │                                │                             │
│         NO                               │                             │
│         │                                │                             │
└─────────┼────────────────────────────────┼─────────────────────────────┘
          │                                │
          │                                └─────────────────┐
          ▼                                                  │
┌─────────────────────────────────────────────────────────────────────────┐
│                     PRODUCTION (PROD)                                   │
│                                                                         │
│  ┌──────────────────────────────────────────────────────┐             │
│  │  Pre-Deployment Checklist                            │             │
│  │                                                       │             │
│  │  ☐ All tests passed in TEST                         │             │
│  │  ☐ Solution Checker passed                          │             │
│  │  ☐ Stakeholders informed                            │             │
│  │  ☐ Deployment window scheduled                      │             │
│  │  ☐ Rollback plan documented                         │             │
│  │  ☐ Version number bumped                            │             │
│  └──────┬───────────────────────────────────────────────┘             │
│         │                                                               │
│         ▼                                                               │
│  ┌──────────────────────────────────────────────────────┐             │
│  │  BACKUP PROD!                                        │             │
│  │  pac solution export --name "..." --managed          │             │
│  └──────┬───────────────────────────────────────────────┘             │
│         │                                                               │
│         ▼                                                               │
│  ┌──────────────────────────────────────────────────────┐             │
│  │  ./deploy-prod.bat YourSolution                      │             │
│  │                                                       │             │
│  │  ✓ Pack managed Solution from ./src/                │             │
│  │  ✓ Run Solution Checker                             │             │
│  │  ✓ Double confirmation required                     │             │
│  │  ✓ Import to PROD Environment                       │             │
│  └──────┬───────────────────────────────────────────────┘             │
│         │                                                               │
│         ▼                                                               │
│  ┌──────────────────────────────────────────────────────┐             │
│  │  Post-Deployment                                     │             │
│  │                                                       │             │
│  │  ✓ Connect Connection References                    │             │
│  │  ✓ Set Environment Variables                        │             │
│  │  ✓ Activate Flows                                   │             │
│  │  ✓ Smoke test critical paths                        │             │
│  │  ✓ Monitor for 24h                                  │             │
│  │  ✓ Create Git tag (v1.2.3)                          │             │
│  └──────────────────────────────────────────────────────┘             │
│                                                                         │
└─────────────────────────────────────────────────────────────────────────┘
```

---

## 📊 Decision Tree: Which Deployment Command?

```
START: I want to deploy...
│
├─── Changes from DEV → Git
│    │
│    └─► ./deploy-dev.bat YourSolution
│        • Exports unmanaged
│        • Unpacks to ./src/
│        • Shows git diff
│        • Then: git commit + push
│
├─── Git → TEST Environment
│    │
│    └─► ./deploy-test.bat YourSolution
│        • Packs managed from ./src/
│        • Runs Solution Checker (optional)
│        • Imports to TEST
│        • Then: User Acceptance Testing
│
├─── Git → PROD Environment
│    │
│    └─► ./deploy-prod.bat YourSolution
│        • Requires backup first!
│        • Packs managed from ./src/
│        • Runs Solution Checker
│        • Double confirmation
│        • Imports to PROD
│        • Then: Post-deployment checks
│
└─── DEV → TEST directly (bypass Git)
     │
     └─► .\deploy-solution.ps1 -SolutionName "YourSolution" `
                                -TargetEnv TEST -Export -Managed
         • Exports from DEV
         • Imports to TEST
         • ⚠️ Not recommended for production workflow
```

---

## 🔐 Environment Rules Matrix

| Aspect | DEV | TEST | PROD |
|--------|-----|------|------|
| **Solution Type** | Unmanaged | Managed | Managed (enforced) |
| **Direct Editing** | ✅ Yes | ❌ No | ❌ Never |
| **Deployment Frequency** | Daily | Weekly | Monthly/On-Demand |
| **Approval Required** | No | Recommended | **Mandatory** |
| **Backup Before Deploy** | No | Optional | **Mandatory** |
| **Solution Checker** | Optional | Recommended | **Mandatory** |
| **Rollback Plan** | Not needed | Recommended | **Mandatory** |
| **Connection Setup** | Dev connections | Test connections | Prod connections |
| **Environment Variables** | Dev values | Test values | Prod values |

---

## 🛠️ Tool Selection Guide

### Scenario → Command Mapping

| What I'm doing | Command to use |
|----------------|----------------|
| **Daily dev work**: Export my changes | `.\deploy-dev.bat MySolution` |
| **Feature complete**: Deploy to TEST | `.\deploy-test.bat MySolution` |
| **Release ready**: Deploy to PROD | `.\deploy-prod.bat MySolution` |
| **Critical hotfix**: Emergency PROD fix | See DEPLOYMENT-INSTRUCTIONS.md → Scenario 1 |
| **Check auth status** | `pac auth list` |
| **Switch environment** | `pac auth select --index 2` |
| **List solutions** | `pac solution list` |
| **Manual export** | `pac solution export --name "Sol" --path sol.zip` |
| **Manual import** | `pac solution import --path sol.zip` |
| **View connections** | `pac connection list` |

---

## 🚦 Solution Lifecycle States

```
┌─────────────┐
│   Created   │  New solution in DEV
└──────┬──────┘
       │
       ▼
┌─────────────┐
│ Development │  Active development, frequent changes
└──────┬──────┘  • Unmanaged
       │          • Source control commits
       │          • Multiple developers
       ▼
┌─────────────┐
│   Testing   │  User acceptance testing
└──────┬──────┘  • Managed
       │          • No direct edits
       │          • Bug reports → back to Dev
       ▼
┌─────────────┐
│  Approved   │  Ready for production
└──────┬──────┘  • All tests passed
       │          • Stakeholder sign-off
       │          • Version tagged
       ▼
┌─────────────┐
│  Deployed   │  Live in production
└──────┬──────┘  • Managed
       │          • Monitoring active
       │          • Support ready
       ▼
┌─────────────┐
│  Supported  │  Maintenance mode
└──────┬──────┘  • Minor updates
       │          • Bug fixes
       │          • Monitoring
       ▼
┌─────────────┐
│  Retired    │  Deprecated, scheduled for removal
└─────────────┘
```

---

## 📈 Deployment Frequency Recommendations

```
Week 1              Week 2              Week 3              Week 4
│                   │                   │                   │
├─── DEV ─┬─ DEV ─┬─ DEV ─┬─ DEV ─┬─ DEV ─┬─ DEV ─┬─ DEV ─┬─ DEV
│         │        │        │        │        │        │        │
│         │        │        TEST     │        │        TEST     │
│         │        │        │        │        │        │        │
│         │        │        │        │        │        │        PROD
│         │        │        │        │        │        │        │
Day     Day      Day      Day      Day      Day      Day      Day
```

**Cadence:**
- **DEV**: Daily (after each completed feature/fix)
- **TEST**: Weekly or bi-weekly (sprint end)
- **PROD**: Monthly or per release (after thorough testing)

**Exceptions:**
- **Hotfix**: DEV → TEST (quick check) → PROD (same day if critical)
- **Emergency**: Can skip TEST if absolutely necessary (with approval)

---

## 🎯 Success Metrics

### Deployment Success Checklist

```
Pre-Deployment:
☐ Solution builds without errors
☐ All tests pass locally
☐ Solution Checker: 0 critical issues
☐ Dependencies documented
☐ Connection References documented
☐ Environment Variables documented
☐ Backup created (PROD only)
☐ Stakeholders notified

During Deployment:
☐ Import completes successfully
☐ No error messages in import log
☐ All components imported
☐ Plugins activated

Post-Deployment:
☐ Connection References connected
☐ Environment Variables set
☐ Flows activated and running
☐ Apps open without errors
☐ Smoke tests pass
☐ No errors in System Jobs
☐ Users notified
☐ Git tag created

24h Monitoring:
☐ No critical errors in logs
☐ Performance within SLA
☐ No user-reported issues
☐ Flows executing successfully
```

---

## 🔄 Rollback Decision Matrix

| Scenario | Action | Command |
|----------|--------|---------|
| **Import fails** | Stop immediately | Cancel import, review logs |
| **Import succeeds, app broken** | Rollback to backup | `pac solution import --path ./backups/backup.zip` |
| **Minor bugs found** | Document for hotfix | Continue, plan hotfix |
| **Critical bugs found** | Immediate rollback | Import backup, notify users |
| **Performance issues** | Monitor for 1h | Rollback if not improving |
| **Data loss detected** | Immediate rollback | Import backup, restore data |

**Rollback Trigger Criteria:**
- Critical functionality broken
- Data integrity compromised
- Security vulnerability exposed
- Performance degradation >50%
- User impact >25% of user base

---

## 📞 Escalation Path

```
Issue Detected
       │
       ▼
   Severity?
       │
       ├─── Low/Medium
       │    └─► Document → Plan Fix → Deploy in next sprint
       │
       └─── High/Critical
            │
            ▼
       Can fix in <1h?
            │
            ├─── Yes
            │    └─► Hotfix → Quick Test → Deploy
            │
            └─── No
                 │
                 ▼
            Rollback
                 │
                 ▼
            Notify Stakeholders
                 │
                 ▼
            Root Cause Analysis
                 │
                 ▼
            Plan Proper Fix
```

---

## 🎓 Training Path for New Team Members

**Week 1: Learn the basics**
- Install PAC CLI
- Authenticate to DEV
- Practice: `pac solution list`, `pac auth list`
- Read: DEPLOYMENT-INSTRUCTIONS.md

**Week 2: Practice DEV deployments**
- Make small change in DEV
- Export with `.\deploy-dev.bat`
- Commit to Git
- Repeat 3-5 times

**Week 3: TEST deployments with mentor**
- Shadow experienced developer
- Deploy to TEST with guidance
- Perform UAT testing
- Document findings

**Week 4: Full cycle with review**
- Complete DEV → TEST → PROD cycle
- Mentor reviews each step
- Create checklist for future deployments

**Week 5+: Independent deployments**
- DEV deployments independently
- TEST deployments with peer review
- PROD deployments with team lead approval

---

**For detailed step-by-step instructions, see: DEPLOYMENT-INSTRUCTIONS.md**
