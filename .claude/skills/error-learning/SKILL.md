---
name: error-learning
description: Systematisches Lernen aus Fehlern und Dokumentation von Lösungen. Nutze diesen Skill um Fehler zu analysieren, dokumentieren und zukünftig zu vermeiden.
---

# Lernen aus Fehlern

## Fehleranalyse-Prozess

### 1. Fehler identifizieren
```
Was ist passiert?
├── Fehlermeldung (vollständig)
├── Kontext (wann, wo, wie)
├── Erwartetes Verhalten
└── Tatsächliches Verhalten
```

### 2. Root Cause Analysis
```
Warum ist es passiert?
├── Direkter Auslöser
├── Zugrundeliegende Ursache
├── Systemische Faktoren
└── Präventionsmöglichkeiten
```

### 3. Lösung dokumentieren
```
Wie wurde es gelöst?
├── Sofortmaßnahme
├── Langfristige Lösung
├── Verifikation
└── Lessons Learned
```

## Fehler-Dokumentationsvorlage

```markdown
## [Datum] - [Kurzbeschreibung]

### Fehler
[Vollständige Fehlermeldung]

### Kontext
- Aktion: [Was wurde versucht]
- Umgebung: [DEV/TEST/PROD]
- Komponente: [App/Flow/Plugin]

### Ursache
[Root Cause Analyse]

### Lösung
[Schritt-für-Schritt Lösung]

### Prävention
[Wie kann dieser Fehler zukünftig vermieden werden]

### Tags
#[Kategorie] #[Technologie] #[Schweregrad]
```

## Power Platform Fehler-Kategorien

### Canvas App Fehler

| Fehler | Häufige Ursache | Lösung |
|--------|-----------------|--------|
| Network error | Timeout/Verbindung | Retry-Logik, Offline-Caching |
| Delegation warning | Zu viele Daten | Server-seitige Filter |
| Type mismatch | Falscher Datentyp | Explicit Type Conversion |
| Permission denied | Fehlende Rechte | Security Role prüfen |

### Power Automate Fehler

| Fehler | Häufige Ursache | Lösung |
|--------|-----------------|--------|
| ActionFailed | Expression-Fehler | Null-Handling mit coalesce() |
| Timeout | Lange Operation | Child Flow, Async Pattern |
| InvalidTemplate | Syntax-Fehler | Expression Validator nutzen |
| Throttling | Rate Limit | Retry Policy, Batching |

### Dataverse Fehler

| Fehler | Häufige Ursache | Lösung |
|--------|-----------------|--------|
| -2147220891 | Duplicate Key | Alternate Key prüfen |
| -2147187707 | Missing Privilege | Security Role anpassen |
| -2147220969 | Plugin Timeout | Code optimieren, async |
| -2147204733 | Record not found | Existenz prüfen |

## Debugging-Strategien

### Canvas Apps
```powerfx
// Trace für Debugging
Trace("Variable value: " & Text(varMyValue));

// Monitor nutzen
// Öffne Monitor: Ctrl+Shift+M

// Fehler abfangen
IfError(
    Patch(Table, Record, {Field: Value}),
    Notify("Fehler: " & FirstError.Message, NotificationType.Error)
);
```

### Power Automate
```json
// Compose für Debugging
{
  "type": "Compose",
  "inputs": "@{outputs('Previous_Action')}"
}

// Scope für Error Handling
// Run After: Failed, TimedOut

// Terminate mit Details
{
  "type": "Terminate",
  "inputs": {
    "runStatus": "Failed",
    "runError": {
      "message": "@{result('Scope_Try')}"
    }
  }
}
```

### Plugins
```csharp
// Tracing nutzen
tracingService.Trace($"Entity: {entity.LogicalName}");
tracingService.Trace($"Attributes: {string.Join(", ", entity.Attributes.Keys)}");

// Plugin Trace Log aktivieren
// Settings > Administration > System Settings > Customization
// Enable logging to plug-in trace log: All
```

## Präventive Maßnahmen

### Code Reviews
- [ ] Delegation-Warnings geprüft
- [ ] Null-Handling implementiert
- [ ] Error-Handling vorhanden
- [ ] Performance getestet

### Testing
- [ ] Happy Path getestet
- [ ] Edge Cases getestet
- [ ] Fehlerszenarien getestet
- [ ] Lasttests durchgeführt

### Monitoring
- [ ] Application Insights konfiguriert
- [ ] Alerts eingerichtet
- [ ] Regelmäßige Log-Review

## Wissensaufbau

### Nach jedem Fehler
1. Fehler in CLAUDE.md dokumentieren
2. Pattern erkennen (wiederkehrende Fehler?)
3. Checkliste aktualisieren
4. Team informieren

### Regelmäßige Review
- Wöchentlich: Neue Fehler durchgehen
- Monatlich: Patterns identifizieren
- Quartalsweise: Prozesse verbessern

## Quick Reference

```
Debugging-Workflow:
1. Fehlermeldung lesen (vollständig!)
2. Reproduzieren
3. Isolieren (wo genau?)
4. Hypothese aufstellen
5. Testen
6. Lösung dokumentieren
```
