# Power Platform Deployment - Quick Reference

## 🚀 Quick Start

```powershell
# 1. Install PAC CLI (einmalig)
dotnet tool install --global Microsoft.PowerApps.CLI.Tool

# 2. Authenticate (einmalig pro Environment)
pac auth create --environment https://your-org.crm4.dynamics.com

# 3. Deploy!
.\deploy-dev.bat YourSolutionName
```

## 📦 Common Commands

### Täglich (Development)

```powershell
# Export aus DEV + Unpack zu Git
.\deploy-dev.bat MySolution

# Git commit
git add src/
git commit -m "feat: Add new feature"
git push
```

### Wöchentlich (Release to TEST)

```powershell
# Pack + Deploy managed zu TEST
.\deploy-test.bat MySolution

# UAT durchführen...
```

### Monthly (Production Release)

```powershell
# PROD Backup erstellen
pac solution export --name "MySolution" --path "./backups/backup-$(Get-Date -Format 'yyyyMMdd').zip" --managed

# Deploy zu PROD
.\deploy-prod.bat MySolution

# Git Tag erstellen
git tag -a v1.2.3 -m "Release notes..."
git push origin v1.2.3
```

## 🔧 PAC CLI Essentials

| Aktion | Command |
|--------|---------|
| Auth anzeigen | `pac auth list` |
| Environment wechseln | `pac auth select --index 1` |
| Aktuelles Org | `pac org who` |
| Solutions auflisten | `pac solution list` |
| Solution exportieren | `pac solution export --name MySol --path ./sol.zip` |
| Solution importieren | `pac solution import --path ./sol.zip` |
| Solution entpacken | `pac solution unpack --zipfile sol.zip --folder ./src` |
| Solution packen | `pac solution pack --folder ./src --zipfile sol.zip` |
| Checker ausführen | `pac solution check --path ./sol.zip` |

## 🎯 Script Shortcuts

### Einfache Deployments

```powershell
# DEV → Source Control (unmanaged)
.\deploy-dev.bat MySolution

# Source → TEST (managed)
.\deploy-test.bat MySolution

# Source → PROD (managed, mit Checks)
.\deploy-prod.bat MySolution
```

### Advanced Deployments

```powershell
# DEV → TEST direkt (managed)
.\deploy-solution.ps1 -SolutionName "MySol" -TargetEnv TEST -Export -Managed

# Source → TEST ohne Bestätigungen (CI/CD)
.\deploy-solution.ps1 -SolutionName "MySol" -TargetEnv TEST -Managed -SkipChecks

# Custom Pfade
.\deploy-solution.ps1 -SolutionName "MySol" -TargetEnv DEV -Export -ExportPath "C:\Backups"
```

## ⚠️ Deployment Regeln

| Environment | Solution-Typ | Wann | Wie |
|-------------|--------------|------|-----|
| **DEV** | Unmanaged | Täglich | `deploy-dev.bat` |
| **TEST** | Managed | Wöchentlich | `deploy-test.bat` |
| **PROD** | Managed | Nach Approval | `deploy-prod.bat` |

### Goldene Regeln

1. ✅ **IMMER** Source Control nutzen (DEV → Git → TEST → PROD)
2. ✅ **IMMER** Backup von PROD vor Deployment
3. ✅ **IMMER** Version Number erhöhen
4. ❌ **NIEMALS** unmanaged in PROD
5. ❌ **NIEMALS** direkt in PROD editieren

## 🔍 Troubleshooting

| Problem | Lösung |
|---------|--------|
| "Solution not found" | `pac solution list` für korrekten Namen |
| "Authentication failed" | `pac auth create --environment <URL>` |
| "Missing dependencies" | Dependencies zuerst deployen |
| "Import conflicts" | `--force-overwrite` flag nutzen |
| PAC CLI nicht gefunden | `dotnet tool install --global Microsoft.PowerApps.CLI.Tool` |

## 📊 Environment URLs

```powershell
# Typ 1: Deutschland (crm4)
https://org-dev.crm4.dynamics.com

# Typ 2: Europa (crm16)
https://org-dev.crm16.dynamics.com

# Typ 3: US (crm)
https://org-dev.crm.dynamics.com

# URL finden: https://admin.powerplatform.microsoft.com
```

## 🛡️ PROD Deployment Checklist

```markdown
Vor Deployment:
- [ ] In TEST erfolgreich getestet
- [ ] Solution Checker passed
- [ ] Backup erstellt
- [ ] Version erhöht
- [ ] Change Notes geschrieben
- [ ] Stakeholder informiert

Nach Deployment:
- [ ] App-Funktionalität getestet
- [ ] Connection References verbunden
- [ ] Environment Variables gesetzt
- [ ] Git Tag erstellt
- [ ] User informiert
```

## 🔄 Git Workflow

```powershell
# Feature Branch
git checkout -b feature/add-approval-flow

# Änderungen aus DEV exportieren
.\deploy-dev.bat MySolution

# Commit + Push
git add src/
git commit -m "feat: Add approval flow for managers"
git push origin feature/add-approval-flow

# Pull Request erstellen
gh pr create --title "Add approval flow" --body "Implements manager approval workflow"

# Nach Merge: Deploy zu TEST
git checkout main
git pull
.\deploy-test.bat MySolution
```

## 💡 Pro Tips

### Parallel Deployments

```powershell
# Mehrere Solutions parallel deployen
Start-Job { .\deploy-test.bat Solution1 }
Start-Job { .\deploy-test.bat Solution2 }
Get-Job | Wait-Job
Get-Job | Receive-Job
```

### Automated Backups

```powershell
# Scheduled Task für tägliche PROD Backups
$action = New-ScheduledTaskAction -Execute "PowerShell.exe" -Argument "-File C:\Scripts\backup-prod.ps1"
$trigger = New-ScheduledTaskTrigger -Daily -At 2AM
Register-ScheduledTask -TaskName "PROD Backup" -Action $action -Trigger $trigger
```

### Version Bump Script

```powershell
# version-bump.ps1
$solutionXml = Get-Content "src/Other/Solution.xml"
$solutionXml -replace '<Version>(\d+)\.(\d+)\.(\d+)</Version>', {
    $major = [int]$_.Groups[1].Value
    $minor = [int]$_.Groups[2].Value
    $patch = [int]$_.Groups[3].Value + 1
    "<Version>$major.$minor.$patch</Version>"
} | Set-Content "src/Other/Solution.xml"
```

## 📚 Links

- [PAC CLI Docs](https://learn.microsoft.com/power-platform/developer/cli/introduction)
- [ALM Guide](https://learn.microsoft.com/power-platform/alm/)
- [Solution Concepts](https://learn.microsoft.com/power-platform/alm/solution-concepts-alm)
- [Best Practices](https://learn.microsoft.com/power-platform/alm/best-practices)
- [Service Principal Setup](https://learn.microsoft.com/power-platform/admin/create-service-principal)
