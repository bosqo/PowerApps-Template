# Power Platform Deployment Guide

## Overview

Dieses Projekt nutzt **PAC CLI** für automatisierte Solution-Deployments über DEV → TEST → PROD Umgebungen.

## Voraussetzungen

### PAC CLI Installation

```powershell
# Windows (PowerShell als Admin)
dotnet tool install --global Microsoft.PowerApps.CLI.Tool

# Oder via Installer
# Download: https://aka.ms/PowerAppsCLI

# Version prüfen
pac --version
```

### Authentifizierung

```powershell
# Erstmalige Anmeldung an allen Environments
pac auth create --environment https://org-dev.crm4.dynamics.com
pac auth create --environment https://org-test.crm4.dynamics.com
pac auth create --environment https://org-prod.crm4.dynamics.com

# Gespeicherte Authentifizierungen anzeigen
pac auth list

# Environment wechseln (interaktiv)
pac auth select --index 1
```

## Deployment-Szenarien

### 1. DEV → Source Control (Tägliche Entwicklung)

**Zweck**: Änderungen aus DEV exportieren und in Git committen

```powershell
# Export + Unpack
.\deploy-dev.bat MySolution

# Oder manuell:
.\deploy-solution.ps1 -SolutionName "MySolution" -TargetEnv DEV -Export

# Änderungen committen
git add src/
git commit -m "feat: Add new approval flow"
git push
```

**Was passiert**:
1. Exportiert **unmanaged** Solution aus DEV
2. Entpackt nach `./src/` für Version Control
3. Zeigt Git-Änderungen an

### 2. Source Control → TEST (Release-Vorbereitung)

**Zweck**: Managed Solution aus Source Control in TEST deployen

```powershell
# Pack + Import
.\deploy-test.bat MySolution

# Oder manuell:
.\deploy-solution.ps1 -SolutionName "MySolution" -TargetEnv TEST -Managed
```

**Was passiert**:
1. Packt **managed** Solution aus `./src/`
2. Führt Solution Checker aus (optional)
3. Importiert in TEST Environment
4. User Acceptance Testing möglich

### 3. Source Control → PROD (Production Release)

**Zweck**: Geprüfte managed Solution in PROD deployen

```powershell
# Pack + Import mit Sicherheitscheck
.\deploy-prod.bat MySolution

# Oder manuell:
.\deploy-solution.ps1 -SolutionName "MySolution" -TargetEnv PROD -Managed
```

**Was passiert**:
1. Packt **managed** Solution aus `./src/`
2. Führt Solution Checker aus
3. Doppelte Bestätigung erforderlich
4. Importiert in PROD Environment

### 4. DEV → TEST (Direkt-Migration)

**Zweck**: Aus DEV exportieren und direkt in TEST importieren

```powershell
.\deploy-solution.ps1 -SolutionName "MySolution" -TargetEnv TEST -Export -Managed
```

**Was passiert**:
1. Verbindet mit DEV und exportiert **managed**
2. Wechselt zu TEST Environment
3. Importiert direkt

## Script-Parameter

### deploy-solution.ps1

| Parameter | Beschreibung | Werte | Erforderlich |
|-----------|--------------|-------|--------------|
| `-SolutionName` | Name der Solution (technischer Name) | String | ✅ Ja |
| `-TargetEnv` | Ziel-Environment | DEV, TEST, PROD | ✅ Ja |
| `-Export` | Aus Environment exportieren | Switch | ❌ Nein |
| `-Managed` | Als managed Solution deployen | Switch | ❌ Nein |
| `-SkipChecks` | Bestätigungen überspringen | Switch | ❌ Nein |
| `-ExportPath` | Pfad für Exports | String | ❌ Nein (default: `./exports`) |
| `-SourcePath` | Pfad für Source Control | String | ❌ Nein (default: `./src`) |

### Beispiele

```powershell
# Export unmanaged aus DEV
.\deploy-solution.ps1 -SolutionName "CRMCore" -TargetEnv DEV -Export

# Pack und Deploy managed zu TEST
.\deploy-solution.ps1 -SolutionName "CRMCore" -TargetEnv TEST -Managed

# Direkt-Migration DEV → PROD (managed)
.\deploy-solution.ps1 -SolutionName "CRMCore" -TargetEnv PROD -Export -Managed

# Ohne Bestätigungen (CI/CD)
.\deploy-solution.ps1 -SolutionName "CRMCore" -TargetEnv TEST -Managed -SkipChecks
```

## Environment Strategy

| Environment | Solution-Typ | Zweck | Deployment |
|-------------|--------------|-------|------------|
| **DEV** | Unmanaged | Entwicklung, direktes Editieren | Täglich, automatisch |
| **TEST** | Managed | User Acceptance Testing | Wöchentlich, manuell |
| **PROD** | Managed | Produktiv, keine direkten Änderungen | Nach Approval, manuell |

### Regeln

1. **DEV**: Nur unmanaged Solutions
2. **TEST**: Managed Solutions empfohlen
3. **PROD**: **NUR** managed Solutions (Script erzwingt dies)
4. **Niemals** direkt in PROD editieren
5. **Immer** Source Control zwischen TEST und PROD nutzen

## Solution Checker

Der Solution Checker analysiert Best Practices und potenzielle Probleme.

### Manuell ausführen

```powershell
# Solution Checker für ZIP-File
pac solution check --path ./exports/MySolution-managed.zip --outputDirectory ./checker-results

# Ergebnisse reviewen
cat ./checker-results/CheckerResults.json
```

### Automatisch im Script

Der Checker läuft automatisch bei TEST/PROD Deployments. Bei Problemen:

1. Script pausiert und zeigt Ergebnisse
2. Reviewe `./exports/checker-results/`
3. Entscheide: Fortsetzen oder Abbrechen

## Fehlerbehandlung

### Problem: "Solution not found"

```powershell
# Lösung: Solution-Name prüfen (NICHT Display Name!)
pac solution list
```

### Problem: "Missing dependencies"

```powershell
# Lösung: Abhängigkeiten zuerst deployen
.\deploy-solution.ps1 -SolutionName "BaseSolution" -TargetEnv TEST -Managed
.\deploy-solution.ps1 -SolutionName "MainSolution" -TargetEnv TEST -Managed
```

### Problem: "Import failed - conflicts"

```powershell
# Lösung: Force overwrite (Achtung: Überschreibt Customizations!)
# Manuell:
pac solution import --path MySolution.zip --force-overwrite --activate-plugins
```

### Problem: PAC CLI nicht gefunden

```powershell
# Lösung: PATH-Variable prüfen
$env:PATH -split ";" | Select-String "PowerApps"

# Oder neu installieren
dotnet tool uninstall --global Microsoft.PowerApps.CLI.Tool
dotnet tool install --global Microsoft.PowerApps.CLI.Tool
```

## CI/CD Integration

### Azure DevOps Pipeline

```yaml
# azure-pipelines.yml
trigger:
  branches:
    include:
      - main

pool:
  vmImage: 'windows-latest'

steps:
- task: PowerShell@2
  displayName: 'Install PAC CLI'
  inputs:
    targetType: 'inline'
    script: |
      dotnet tool install --global Microsoft.PowerApps.CLI.Tool

- task: PowerShell@2
  displayName: 'Authenticate to TEST'
  inputs:
    targetType: 'inline'
    script: |
      pac auth create --environment $(TEST_ENV_URL) --applicationId $(APP_ID) --clientSecret $(CLIENT_SECRET) --tenant $(TENANT_ID)

- task: PowerShell@2
  displayName: 'Deploy to TEST'
  inputs:
    filePath: 'deploy-solution.ps1'
    arguments: '-SolutionName "$(SOLUTION_NAME)" -TargetEnv TEST -Managed -SkipChecks'
```

### GitHub Actions

```yaml
# .github/workflows/deploy.yml
name: Deploy to TEST

on:
  push:
    branches: [main]

jobs:
  deploy:
    runs-on: windows-latest

    steps:
      - uses: actions/checkout@v3

      - name: Install PAC CLI
        run: dotnet tool install --global Microsoft.PowerApps.CLI.Tool

      - name: Authenticate
        run: |
          pac auth create --environment ${{ secrets.TEST_ENV_URL }} `
            --applicationId ${{ secrets.APP_ID }} `
            --clientSecret ${{ secrets.CLIENT_SECRET }} `
            --tenant ${{ secrets.TENANT_ID }}

      - name: Deploy Solution
        run: |
          .\deploy-solution.ps1 `
            -SolutionName "${{ secrets.SOLUTION_NAME }}" `
            -TargetEnv TEST `
            -Managed `
            -SkipChecks
```

## Best Practices

### 1. Immer Version Bumpen

Vor jedem Deployment in `solution.xml`:

```xml
<Version>1.2.3</Version>  <!-- Erhöhen! -->
```

### 2. Backup vor PROD

```powershell
# Aktuellen Stand exportieren
pac auth select --index [PROD-Index]
pac solution export --name "MySolution" --path "./backups/MySolution-backup-$(Get-Date -Format 'yyyyMMdd').zip" --managed
```

### 3. Connection References

```powershell
# Nach Import Connection References verbinden
# Entweder manuell im Portal oder via PowerShell:
pac connection list
```

### 4. Environment Variables

```powershell
# Environment-spezifische Werte setzen
# Manuell: make.powerapps.com → Solutions → MySolution → Environment Variables
```

### 5. Change Notes

```powershell
git tag -a v1.2.3 -m "Release: Add approval flow, fix timezone bug"
git push origin v1.2.3
```

## Deployment-Checklist

### Vor PROD Deployment

- [ ] Solution in TEST erfolgreich getestet
- [ ] Solution Checker ohne kritische Issues
- [ ] Backup von PROD erstellt
- [ ] Connection References dokumentiert
- [ ] Environment Variables dokumentiert
- [ ] Change Notes geschrieben
- [ ] Version Nummer erhöht
- [ ] Stakeholder informiert
- [ ] Rollback-Plan vorhanden

### Nach PROD Deployment

- [ ] App-Funktionalität getestet
- [ ] Connection References verbunden
- [ ] Environment Variables gesetzt
- [ ] User informiert
- [ ] Dokumentation aktualisiert
- [ ] Git Tag erstellt

## Troubleshooting

### Logs anzeigen

```powershell
# PAC CLI Logs
Get-Content "$env:USERPROFILE\.pac\logs\latest.log"

# Script-Logs
Get-Content "./exports/deployment-$timestamp.log"
```

### Rollback

```powershell
# Option 1: Vorherige Version re-deployen
.\deploy-solution.ps1 -SolutionName "MySolution" -TargetEnv PROD -Managed -ExportPath "./backups"

# Option 2: Solution löschen (VORSICHT!)
pac solution delete --solution-name "MySolution"
```

## Support

- **PAC CLI Docs**: https://learn.microsoft.com/power-platform/developer/cli/introduction
- **Solution Lifecycle**: https://learn.microsoft.com/power-platform/alm/
- **Best Practices**: https://learn.microsoft.com/power-platform/alm/best-practices
