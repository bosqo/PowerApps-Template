---
name: power-platform
description: Allgemeine Power Platform Entwicklung, Solution Management, ALM und Environment-Strategien. Nutze diesen Skill für übergreifende Power Platform Fragen.
---

# Power Platform Entwicklung

## Solution Management

### Solution-Typen
- **Unmanaged**: Für Entwicklung, Komponenten können bearbeitet werden
- **Managed**: Für Deployment, Komponenten sind geschützt

### Solution-Struktur
```
MySolution/
├── solution.xml
├── customizations.xml
├── [Content_Types].xml
├── Entities/
│   └── [EntityName]/
├── Workflows/
├── CanvasApps/
└── EnvironmentVariables/
```

### Best Practices
1. **Eine Solution pro Feature/Modul**
2. **Publisher konsistent nutzen** - einmal erstellt, nicht ändern
3. **Versionierung**: Major.Minor.Build.Revision (z.B. 1.0.0.1)
4. **Dependencies dokumentieren**

## Environment Variables

```xml
<!-- Definition -->
<environmentvariable>
  <schemaname>contoso_APIEndpoint</schemaname>
  <displayname>API Endpoint</displayname>
  <type>String</type>
  <defaultvalue>https://api.dev.contoso.com</defaultvalue>
</environmentvariable>
```

### Verwendung in Power Fx
```
LookUp(
  'Environment Variable Values',
  'Environment Variable Definition'.'Schema Name' = "contoso_APIEndpoint"
).'Value'
```

### Verwendung in Power Automate
- Expression: `@parameters('contoso_APIEndpoint')`

## Connection References

```xml
<connectionreference>
  <connectionreferencelogicalname>contoso_SharePointConnection</connectionreferencelogicalname>
  <connectorid>/providers/Microsoft.PowerApps/apis/shared_sharepointonline</connectorid>
</connectionreference>
```

## ALM Pipeline

```
DEV ──► Build ──► TEST ──► Approval ──► PROD
         │
         └── Export Unmanaged
             Convert to Managed
             Store in Repo
```

### PAC CLI Befehle

```bash
# Authentifizierung
pac auth create --url https://org.crm.dynamics.com

# Solution exportieren
pac solution export \
  --name MySolution \
  --path ./exports \
  --managed false

# Solution importieren
pac solution import \
  --path ./MySolution_managed.zip \
  --activate-plugins

# Solution packen
pac solution pack \
  --zipfile MySolution.zip \
  --folder ./src/MySolution

# Solution entpacken
pac solution unpack \
  --zipfile MySolution.zip \
  --folder ./src/MySolution \
  --processCanvasApps
```

## Häufige Fehler

| Fehler | Ursache | Lösung |
|--------|---------|--------|
| Missing Dependencies | Fehlende Basis-Solution | Dependencies zuerst importieren |
| Active Layer Conflict | Unmanaged Customizations | Active Layer entfernen |
| Publisher Mismatch | Falscher Publisher | Gleichen Publisher verwenden |

## Checkliste vor Deployment

- [ ] Solution Version erhöht
- [ ] Alle Dependencies vorhanden
- [ ] Environment Variables definiert
- [ ] Connection References konfiguriert
- [ ] Managed Solution getestet
- [ ] Rollback-Plan dokumentiert
