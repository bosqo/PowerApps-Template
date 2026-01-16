# Power Platform Solution Deployment - Schritt-für-Schritt Anleitung

## 📋 Inhaltsverzeichnis

1. [Erstmalige Einrichtung](#erstmalige-einrichtung)
2. [Täglicher Entwicklungs-Workflow](#täglicher-entwicklungs-workflow)
3. [Release zu TEST Environment](#release-zu-test-environment)
4. [Production Deployment](#production-deployment)
5. [Häufige Szenarien](#häufige-szenarien)
6. [Was tun bei Problemen?](#was-tun-bei-problemen)

---

## Erstmalige Einrichtung

### Schritt 1: PAC CLI installieren

**Option A: Via dotnet (empfohlen)**

```powershell
# PowerShell als Administrator öffnen
dotnet tool install --global Microsoft.PowerApps.CLI.Tool
```

**Option B: Via Installer**

1. Download von https://aka.ms/PowerAppsCLI
2. Installer ausführen
3. PowerShell neu starten

**Installation prüfen:**

```powershell
pac --version
# Erwartete Ausgabe: Microsoft PowerPlatform CLI Version: 1.x.x
```

### Schritt 2: Environments konfigurieren

**2.1 Environment URLs herausfinden**

1. Öffne https://admin.powerplatform.microsoft.com
2. Gehe zu **Environments**
3. Klicke auf jedes Environment (DEV, TEST, PROD)
4. Kopiere die **Environment URL** (z.B. `https://org-dev.crm4.dynamics.com`)

**2.2 Environment-Konfiguration erstellen**

```powershell
# Im Projekt-Verzeichnis
cd D:\_Repo\repos\PowerApps-Vibe-Claude

# .env Datei erstellen
copy .env.example .env

# .env bearbeiten und URLs eintragen
notepad .env
```

Trage deine URLs ein:
```
DEV_ENV_URL=https://ihre-org-dev.crm4.dynamics.com
TEST_ENV_URL=https://ihre-org-test.crm4.dynamics.com
PROD_ENV_URL=https://ihre-org-prod.crm4.dynamics.com
SOLUTION_NAME=IhrSolutionName
```

**2.3 Mit Environments verbinden**

```powershell
# DEV Environment
pac auth create --environment https://ihre-org-dev.crm4.dynamics.com

# Browser öffnet sich -> Mit DEV-Account anmelden

# TEST Environment
pac auth create --environment https://ihre-org-test.crm4.dynamics.com

# PROD Environment
pac auth create --environment https://ihre-org-prod.crm4.dynamics.com

# Alle Verbindungen anzeigen
pac auth list
```

**Ausgabe sollte aussehen wie:**
```
Index  Environment                           User
1      Development (org-dev)                 dev@company.com
2      Test (org-test)                       test@company.com
3      Production (org-prod)                 prod@company.com
```

### Schritt 3: Solution-Namen ermitteln

```powershell
# Zu DEV Environment wechseln
pac auth select --index 1

# Alle Solutions anzeigen
pac solution list

# Deinen Solution-Namen notieren (z.B. "contoso_CRM_Core")
```

**Wichtig:** Nutze den **technischen Namen**, nicht den Display Name!

✅ **Richtig:** `contoso_CRM_Core`
❌ **Falsch:** `CRM Core Solution`

### Schritt 4: Test-Deployment

```powershell
# Test: Exportiere aus DEV
.\deploy-dev.bat contoso_CRM_Core

# Wenn erfolgreich, siehst du:
# ✓ PAC CLI found
# ✓ Exported to: ./exports/contoso_CRM_Core-unmanaged-20250115.zip
# ✓ Unpacked to: ./src
```

**Einrichtung abgeschlossen!** ✅

---

## Täglicher Entwicklungs-Workflow

### Szenario: Du hast Änderungen in DEV gemacht

**Schritt 1: Änderungen aus DEV exportieren**

```powershell
# Im Projekt-Verzeichnis
cd D:\_Repo\repos\PowerApps-Vibe-Claude

# Export + Unpack
.\deploy-dev.bat IhrSolutionName
```

**Was passiert:**
1. ✅ Verbindet mit DEV Environment
2. ✅ Exportiert Solution als unmanaged ZIP
3. ✅ Entpackt nach `./src/` für Git
4. ✅ Zeigt Git-Änderungen an

**Schritt 2: Änderungen reviewen**

```powershell
# Welche Dateien wurden geändert?
git status

# Änderungen im Detail anschauen
git diff
```

**Schritt 3: Git Commit erstellen**

```powershell
# Alle Änderungen stagen
git add src/

# Commit mit aussagekräftiger Message
git commit -m "feat: Add manager approval workflow"

# Push zu Remote
git push origin main
```

**Fertig!** Deine Änderungen sind jetzt versioniert.

---

## Release zu TEST Environment

### Wann: Nach abgeschlossener Feature-Entwicklung

**Schritt 1: Aktuellen Stand aus Git holen**

```powershell
# Stelle sicher, dass du auf main bist
git checkout main

# Neuesten Stand holen
git pull origin main
```

**Schritt 2: Deploy zu TEST**

```powershell
# Pack + Deploy als managed Solution
.\deploy-test.bat IhrSolutionName
```

**Was passiert:**
1. ✅ Packt managed Solution aus `./src/`
2. ✅ Führt Solution Checker aus (optional)
3. ⚠️ Fragt nach TEST Environment-Auswahl
4. ✅ Importiert Solution in TEST
5. ✅ Aktiviert Plugins

**Schritt 3: User Acceptance Testing**

1. Öffne TEST Environment: https://ihre-org-test.crm4.dynamics.com
2. Teste alle neuen Features
3. Dokumentiere gefundene Bugs

**Bei Bugs:**

```powershell
# Zurück zu DEV
# Bugs fixen
# Erneut deployen
.\deploy-dev.bat IhrSolutionName
git add src/
git commit -m "fix: Correct approval logic"
git push

# Nochmal zu TEST
.\deploy-test.bat IhrSolutionName
```

---

## Production Deployment

### ⚠️ ACHTUNG: Dies ist PROD - höchste Vorsicht!

### Voraussetzungen-Checklist

Stelle sicher, dass **ALLE** Punkte erfüllt sind:

```
✅ Feature in TEST vollständig getestet
✅ Keine kritischen Bugs bekannt
✅ Solution Checker ohne kritische Issues
✅ Stakeholder über Deployment informiert
✅ Zeitfenster für Deployment abgestimmt (z.B. nachts/Wochenende)
✅ Rollback-Plan dokumentiert
✅ Connection References dokumentiert
✅ Environment Variables dokumentiert
✅ Version Number in solution.xml erhöht
```

### Schritt 1: PROD Backup erstellen

**IMMER vor jedem PROD Deployment!**

```powershell
# Zu PROD verbinden
pac auth select --index 3

# Aktuellen Stand exportieren
$date = Get-Date -Format "yyyyMMdd-HHmm"
pac solution export --name "IhrSolutionName" --path "./backups/IhrSolutionName-backup-$date.zip" --managed

# Bestätigung
Write-Host "✓ Backup erstellt: ./backups/IhrSolutionName-backup-$date.zip" -ForegroundColor Green
```

**Backup-Datei sicher aufbewahren!**

### Schritt 2: Version erhöhen

```powershell
# solution.xml öffnen
notepad src\Other\Solution.xml

# Version finden und erhöhen
# ALT: <Version>1.2.0</Version>
# NEU: <Version>1.3.0</Version>

# Speichern + Committen
git add src/Other/Solution.xml
git commit -m "chore: Bump version to 1.3.0"
git push
```

**Versioning-Schema:**
- **Major.Minor.Patch** (z.B. 1.3.0)
- **Major**: Breaking Changes
- **Minor**: Neue Features
- **Patch**: Bug Fixes

### Schritt 3: Production Deployment

```powershell
# Deploy zu PROD
.\deploy-prod.bat IhrSolutionName
```

**Script fragt nach Bestätigung:**
```
═══════════════════════════════════════════════
  WARNING: Production Deployment
═══════════════════════════════════════════════

This will deploy to PRODUCTION environment.

Are you sure? (yes/no):
```

**Tippe exakt:** `yes`

**Was passiert:**
1. ✅ Packt managed Solution aus `./src/`
2. ✅ Führt Solution Checker aus
3. ⚠️ Zeigt Checker-Ergebnisse
4. ⚠️ Fragt nach PROD Environment-Auswahl
5. ⚠️ Zweite Bestätigung erforderlich
6. ✅ Importiert Solution in PROD
7. ✅ Aktiviert Plugins

### Schritt 4: Post-Deployment Checks

**4.1 Connection References prüfen**

```powershell
# Connections anzeigen
pac connection list
```

Oder manuell:
1. Öffne https://ihre-org-prod.crm4.dynamics.com
2. Gehe zu **Solutions** → Deine Solution
3. Klicke auf **Connection References**
4. Verbinde alle nicht-verbundenen Connections

**4.2 Environment Variables setzen**

1. **Solutions** → Deine Solution → **Environment Variables**
2. Setze PROD-spezifische Werte (z.B. API URLs, Feature Flags)

**4.3 Funktionstest**

- [ ] App öffnet sich
- [ ] Login funktioniert
- [ ] Hauptfunktionen testen (Happy Path)
- [ ] Flows sind aktiv
- [ ] Keine Fehler in Logs

**4.4 Monitoring (erste 24h)**

- Überwache Fehler-Logs
- Check User-Feedback
- Monitore Performance

### Schritt 5: Git Tag erstellen

```powershell
# Tag für Release erstellen
git tag -a v1.3.0 -m "Release 1.3.0: Add manager approval workflow"

# Tag pushen
git push origin v1.3.0
```

### Schritt 6: Dokumentation

```powershell
# Release Notes erstellen (optional)
notepad RELEASE-NOTES.md
```

Beispiel:
```markdown
# Release 1.3.0 - 2025-01-15

## New Features
- Manager approval workflow für Bestellungen >1000€
- Automatische E-Mail-Benachrichtigung bei Genehmigung

## Bug Fixes
- Zeitzone-Berechnung korrigiert (CET statt UTC)

## Breaking Changes
- Keine

## Migration Notes
- Connection Reference "Office365" muss nach Deployment verbunden werden
- Environment Variable "ApprovalThreshold" auf "1000" setzen
```

**PROD Deployment abgeschlossen!** ✅

---

## Häufige Szenarien

### Szenario 1: Hotfix für PROD

**Situation:** Kritischer Bug in PROD, sofortiger Fix nötig

```powershell
# 1. Hotfix-Branch erstellen
git checkout -b hotfix/critical-bug
git push -u origin hotfix/critical-bug

# 2. In DEV fixen
# ... Änderungen in DEV machen ...

# 3. Aus DEV exportieren
.\deploy-dev.bat IhrSolutionName

# 4. Committen
git add src/
git commit -m "fix: Critical bug in approval logic"
git push

# 5. Sofort zu TEST (für Quick-Test)
.\deploy-test.bat IhrSolutionName

# 6. Nach Test: Zu PROD
# BACKUP ERSTELLEN!
pac auth select --index 3
$date = Get-Date -Format "yyyyMMdd-HHmm"
pac solution export --name "IhrSolutionName" --path "./backups/hotfix-backup-$date.zip" --managed

# Deploy
.\deploy-prod.bat IhrSolutionName

# 7. Hotfix-Branch mergen
git checkout main
git merge hotfix/critical-bug
git push
git branch -d hotfix/critical-bug
```

### Szenario 2: Mehrere Solutions deployen

**Situation:** Du hast Dependencies zwischen Solutions

```powershell
# Reihenfolge beachten: Base zuerst, dann abhängige Solutions

# 1. Base Solution
.\deploy-test.bat BaseSolution

# 2. Warte bis fertig, dann abhängige Solution
.\deploy-test.bat DependentSolution

# Oder parallel (wenn keine Dependencies):
Start-Job { .\deploy-test.bat Solution1 }
Start-Job { .\deploy-test.bat Solution2 }
Get-Job | Wait-Job
Get-Job | Receive-Job
```

### Szenario 3: Rollback nach fehlgeschlagenem Deployment

**Situation:** Deployment zu PROD fehlgeschlagen oder Bugs entdeckt

```powershell
# 1. Backup-Version re-deployen
pac auth select --index 3

# 2. Backup importieren
pac solution import --path "./backups/IhrSolutionName-backup-20250115-1430.zip" --force-overwrite

# 3. Funktionstest
# 4. Incident dokumentieren
# 5. Root-Cause-Analyse
```

### Szenario 4: Direkt-Migration DEV → PROD (Notfall)

**⚠️ Nur in Ausnahmefällen! Normalerweise IMMER über TEST!**

```powershell
# Backup erstellen
pac auth select --index 3
pac solution export --name "IhrSolutionName" --path "./backups/backup-$(Get-Date -Format 'yyyyMMdd-HHmm').zip" --managed

# Direkt von DEV exportieren und zu PROD importieren
.\deploy-solution.ps1 -SolutionName "IhrSolutionName" -TargetEnv PROD -Export -Managed
```

### Szenario 5: Canvas App einzeln deployen

**Situation:** Nur Canvas App ändern, ohne ganze Solution

```powershell
# 1. Canvas App herunterladen
pac canvas download --name "MeineApp" --path "./exports/MeineApp.msapp"

# 2. Canvas App entpacken (für Source Control)
pac canvas unpack --msapp "./exports/MeineApp.msapp" --sources "./canvas-src/MeineApp"

# 3. Änderungen in canvas-src/ machen (optional, falls Code-Änderungen)

# 4. Canvas App packen
pac canvas pack --sources "./canvas-src/MeineApp" --msapp "./exports/MeineApp-new.msapp"

# 5. Zu anderem Environment wechseln
pac auth select --index 2

# 6. Canvas App hochladen
# (Muss über Portal gemacht werden - pac canvas unterstützt kein direktes Upload)
# Alternative: Über Solution deployen
```

### Szenario 6: CI/CD Pipeline Setup (Azure DevOps)

**Einmalig: Service Principal erstellen**

1. Azure Portal → **Azure Active Directory**
2. **App registrations** → **New registration**
3. Name: "PowerPlatform-DevOps-SP"
4. **Certificates & secrets** → **New client secret**
5. Secret kopieren (nur einmal sichtbar!)
6. **API permissions** → **Dynamics CRM** → **user_impersonation**

**Azure DevOps Pipeline erstellen:**

```yaml
# azure-pipelines.yml
trigger:
  branches:
    include:
      - main

pool:
  vmImage: 'windows-latest'

variables:
  - group: PowerPlatform-Secrets  # Variable Group mit Secrets

steps:
  - task: PowerShell@2
    displayName: 'Install PAC CLI'
    inputs:
      targetType: 'inline'
      script: |
        dotnet tool install --global Microsoft.PowerApps.CLI.Tool

  - task: PowerShell@2
    displayName: 'Authenticate'
    inputs:
      targetType: 'inline'
      script: |
        pac auth create `
          --environment $(TEST_ENV_URL) `
          --applicationId $(APP_ID) `
          --clientSecret $(CLIENT_SECRET) `
          --tenant $(TENANT_ID)

  - task: PowerShell@2
    displayName: 'Deploy to TEST'
    inputs:
      filePath: 'deploy-solution.ps1'
      arguments: '-SolutionName "$(SOLUTION_NAME)" -TargetEnv TEST -Managed -SkipChecks'

  - task: PublishBuildArtifacts@1
    displayName: 'Publish Solution Package'
    inputs:
      PathtoPublish: 'exports'
      ArtifactName: 'solution-packages'
```

**Variable Group in Azure DevOps:**
- `TEST_ENV_URL`: https://ihre-org-test.crm4.dynamics.com
- `APP_ID`: Service Principal Application ID
- `CLIENT_SECRET`: Service Principal Secret (als Secret markieren!)
- `TENANT_ID`: Azure AD Tenant ID
- `SOLUTION_NAME`: IhrSolutionName

---

## Was tun bei Problemen?

### Problem 1: "Solution not found"

**Symptom:**
```
Error: Solution 'MySolution' not found in environment
```

**Lösung:**

```powershell
# 1. Solutions auflisten
pac solution list

# 2. Korrekten Namen verwenden (technischer Name, nicht Display Name)
# ✅ Richtig: contoso_CRM_Core
# ❌ Falsch: CRM Core Solution
```

### Problem 2: "Authentication failed"

**Symptom:**
```
Error: Authentication failed or token expired
```

**Lösung:**

```powershell
# 1. Authentifizierungen anzeigen
pac auth list

# 2. Neu authentifizieren
pac auth clear
pac auth create --environment https://ihre-org-dev.crm4.dynamics.com

# 3. Environment wechseln
pac auth select --index 1
```

### Problem 3: "Missing dependencies"

**Symptom:**
```
Error: Solution requires dependencies: BaseSolution (1.0.0)
```

**Lösung:**

```powershell
# 1. Dependencies zuerst deployen
.\deploy-test.bat BaseSolution

# 2. Dann Haupt-Solution
.\deploy-test.bat MainSolution
```

### Problem 4: "Import failed - conflicts detected"

**Symptom:**
```
Error: Import failed due to conflicts with existing components
```

**Lösung:**

```powershell
# Option 1: Force Overwrite (ACHTUNG: Überschreibt Änderungen!)
pac solution import --path ./exports/MySolution.zip --force-overwrite

# Option 2: Konflikte manuell auflösen
# 1. Öffne Environment im Browser
# 2. Solutions → Import Solution
# 3. Wähle "Maintain customizations" Option
```

### Problem 5: Solution Checker Fehler

**Symptom:**
```
Solution checker found 15 issues (3 critical, 5 high, 7 medium)
```

**Lösung:**

```powershell
# 1. Detaillierte Ergebnisse anschauen
cat ./exports/checker-results/CheckerResults.json

# 2. Kritische Issues fixen (Critical/High Priority)
# 3. Medium/Low können oft ignoriert werden

# 4. Häufige Issues:
# - "Avoid using JavaScript" → Legacy, oft OK
# - "Use consistent naming" → Refactoring
# - "Missing metadata" → Description hinzufügen
```

### Problem 6: "pac: command not found"

**Symptom:**
```powershell
pac : The term 'pac' is not recognized...
```

**Lösung:**

```powershell
# 1. PATH prüfen
$env:PATH -split ";" | Select-String "PowerApps"

# 2. Neu installieren
dotnet tool uninstall --global Microsoft.PowerApps.CLI.Tool
dotnet tool install --global Microsoft.PowerApps.CLI.Tool

# 3. PowerShell neu starten
```

### Problem 7: Connection References nicht verbunden

**Symptom:**
Nach Import sind Flows/Apps inaktiv wegen fehlender Connections

**Lösung:**

```powershell
# 1. Verfügbare Connections anzeigen
pac connection list

# 2. Manuell im Portal verbinden:
# - make.powerapps.com → Solutions → Deine Solution
# - Connection References
# - Auf jede Connection klicken → "Select Connection"

# 3. Flows reaktivieren
# - make.powerapps.com → Solutions → Deine Solution
# - Cloud Flows → Flow öffnen → "Turn on"
```

### Problem 8: Environment Variables fehlen

**Symptom:**
App funktioniert nicht, Fehler "Environment Variable 'xyz' not found"

**Lösung:**

```powershell
# Environment Variables müssen pro Environment gesetzt werden!

# 1. Im Portal setzen:
# - make.powerapps.com → Solutions → Deine Solution
# - Environment Variables
# - Jede Variable öffnen → "New value" → Environment-spezifischen Wert eintragen

# 2. Dokumentiere Werte pro Environment:
# DEV:  API_URL = https://api-dev.company.com
# TEST: API_URL = https://api-test.company.com
# PROD: API_URL = https://api.company.com
```

### Problem 9: Import dauert ewig

**Symptom:**
Import-Prozess hängt bei "Importing..." für >30 Minuten

**Lösung:**

```powershell
# 1. Geduld haben - große Solutions können 20-30 Min dauern

# 2. Status im Portal prüfen:
# - admin.powerplatform.microsoft.com
# - Environments → Dein Environment
# - Solution History → Aktueller Import-Status

# 3. Bei Timeout: Import erneut versuchen
```

### Problem 10: Script-Fehler "Execution Policy"

**Symptom:**
```
deploy-solution.ps1 cannot be loaded because running scripts is disabled
```

**Lösung:**

```powershell
# Option 1: Für diese Session (empfohlen)
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass

# Option 2: PowerShell als Admin und dauerhaft setzen
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned

# Dann Script erneut ausführen
.\deploy-solution.ps1 -SolutionName "MySolution" -TargetEnv TEST -Managed
```

---

## Nützliche Links

- **PAC CLI Dokumentation**: https://learn.microsoft.com/power-platform/developer/cli/introduction
- **ALM Guide**: https://learn.microsoft.com/power-platform/alm/
- **Solution Concepts**: https://learn.microsoft.com/power-platform/alm/solution-concepts-alm
- **Best Practices**: https://learn.microsoft.com/power-platform/alm/best-practices
- **Service Principal Setup**: https://learn.microsoft.com/power-platform/admin/create-service-principal
- **GitHub - PAC CLI**: https://github.com/microsoft/powerplatform-build-tools

---

## Support

Bei Fragen oder Problemen:

1. **Logs prüfen**: `Get-Content "$env:USERPROFILE\.pac\logs\latest.log"`
2. **Issue erstellen**: https://github.com/microsoft/powerplatform-build-tools/issues
3. **Community Forum**: https://powerusers.microsoft.com/

---

**Viel Erfolg beim Deployment! 🚀**
