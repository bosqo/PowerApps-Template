# Claude Code Projekt-Konfiguration

## Allgemeine Regeln

### Code-Qualität
- Schreibe sauberen, lesbaren Code mit aussagekräftigen Variablennamen
- Halte Funktionen klein und fokussiert (Single Responsibility)
- Vermeide Code-Duplizierung - nutze Wiederverwendung
- Kommentiere nur komplexe Logik, nicht offensichtlichen Code

### Fehlerbehandlung
- Fange Fehler immer spezifisch ab, nicht generisch
- Logge Fehler mit vollständigem Kontext (Quelle, Parameter, Stack)
- Gib dem Benutzer verständliche Fehlermeldungen
- Fail fast: Validiere Eingaben früh

### Sicherheit
- Speichere niemals Credentials im Code
- Validiere alle externen Eingaben
- Nutze Umgebungsvariablen für sensible Daten
- Prüfe Berechtigungen vor Aktionen

### Git & Versionierung
- Schreibe aussagekräftige Commit-Messages (Was + Warum)
- Ein Commit = eine logische Änderung
- Feature-Branches für neue Funktionen
- Teste vor dem Push

---

## Power Platform Spezifisch

### Naming Conventions
- **Solutions**: `[Publisher]_[Projektname]_[Typ]` (z.B. `contoso_CRM_Core`)
- **Tabellen**: PascalCase, Singular (z.B. `Customer`, `OrderItem`)
- **Spalten**: camelCase mit Präfix (z.B. `cust_firstName`)
- **Flows**: `[App]-[Aktion]-[Trigger]` (z.B. `CRM-SendEmail-OnCreate`)
- **Canvas Apps**: `[Bereich]_[Funktion]_App` (z.B. `Sales_OrderEntry_App`)

### Canvas App Variablen (Dot Notation)
Verwende hierarchische Record-Strukturen für bessere Organisation:

| Struktur | Verwendung | Beispiel-Zugriff |
|----------|------------|------------------|
| `App.Themes` | Farben, Größen, Schatten | `App.Themes.Primary`, `App.Themes.Background` |
| `App.Fonts` | Schriftarten, Größen | `App.Fonts.Header`, `App.Fonts.Body` |
| `App.User` | Benutzerinfo, Berechtigungen | `App.User.Email`, `App.User.IsAdmin` |
| `App.Config` | Einstellungen, Feature-Flags | `App.Config.ApiUrl`, `App.Config.DebugMode` |
| `App.State` | Navigation, Ladezustand | `App.State.CurrentScreen`, `App.State.IsLoading` |
| `Screen.State` | Screen-lokaler Kontext | `Screen.State.SelectedItem` |
| `Data.Cache` | Gecachte Collections | `Data.Cache.Customers`, `Data.Cache.Products` |

### Environment Strategy
- **DEV**: Entwicklung und Tests
- **TEST/UAT**: User Acceptance Testing
- **PROD**: Produktiv - nur managed Solutions

### Best Practices
- Nutze Solutions für ALM (Application Lifecycle Management)
- Verwende Environment Variables statt hardcodierter Werte
- Implementiere Connection References für Konnektoren
- Dokumentiere Abhängigkeiten zwischen Komponenten

---

## Lernen aus Fehlern

### Dokumentierte Fehler & Lösungen

<!-- Hier werden Fehler dokumentiert, die aufgetreten sind -->

| Datum | Fehler | Ursache | Lösung |
|-------|--------|---------|--------|
| | | | |

### Häufige Fallstricke

1. **Delegation in Canvas Apps**
   - Problem: Nicht-delegierbare Funktionen auf große Datenmengen
   - Lösung: Filter serverseitig, nutze Dataverse Views

2. **Flow-Timeouts**
   - Problem: Flows brechen nach 30 Tagen ab
   - Lösung: Lange Prozesse in Child-Flows aufteilen

3. **Lizenz-Limits**
   - Problem: API-Limits überschritten
   - Lösung: Batch-Operationen, Throttling implementieren

---

## Projekt-spezifische Befehle

```bash
# Solution exportieren
pac solution export --name MySolution --path ./exports

# Solution importieren
pac solution import --path ./MySolution.zip

# Canvas App packen
pac canvas pack --sources ./src --msapp ./app.msapp

# Canvas App entpacken
pac canvas unpack --msapp ./app.msapp --sources ./src
```

---

## Kontext für Claude

- Dieses Projekt nutzt die Microsoft Power Platform
- Hauptsprachen: Power Fx, JSON, YAML
- Entwicklungsumgebung: VS Code mit Power Platform Tools
- Source Control: Git mit Unpacked Solutions
