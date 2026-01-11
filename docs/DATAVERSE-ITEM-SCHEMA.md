# Dataverse Item Schema Documentation

## Item Tabelle

### Status Spalte (Choice)

Die Status-Spalte für Items wurde überarbeitet und unterstützt nun folgende Werte:

| Status | Bedeutung | Farbe | Icon |
|--------|-----------|-------|------|
| **beantragt** | Antrag wurde eingereicht | Amber (Warning) | Clock |
| **in Bearbeitung** | Item wird aktuell bearbeitet | Blue (Primary) | Clock |
| **genehmigt** | Antrag wurde genehmigt | Green (Success) | CheckmarkCircle |
| **abgelehnt** | Antrag wurde abgelehnt | Red (Error) | CancelBadge |

### Status-Mapping in Power Fx

Die Status-Werte werden automatisch durch die UDFs `GetStatusColor()` und `GetStatusIcon()` unterstützt:

```powerfx
// Status-Farbe abrufen
GetStatusColor(ThisItem.Status)

// Status-Icon abrufen
GetStatusIcon(ThisItem.Status)
```

## Prozessschritt Spalte (Choice)

Eine neue Spalte für die Zuordnung von Items zu verschiedenen Prozessschritten basierend auf Benutzerrollen.

### Spaltendetails

| Eigenschaft | Wert |
|-------------|------|
| **Name** | Prozessschritt |
| **Typ** | Choice (Global oder Lokal) |
| **API Name** | cr123_prozessschritt (Präfix anpassen) |
| **Erforderlich** | Optional |

### Choice-Werte

Die folgenden Werte entsprechen den Benutzerrollen (außer Admin und User):

| Label | Wert | Beschreibung |
|-------|------|--------------|
| **Manager** | 1 | Manager-Prozessschritt |
| **Supervisor** | 2 | Team Lead/Supervisor-Prozessschritt |
| **Executive** | 3 | Executive-Prozessschritt |
| **GF** | 4 | Geschäftsführer-Prozessschritt |
| **Sales** | 5 | Sales-Abteilungs-Prozessschritt |
| **Finance** | 6 | Finance-Abteilungs-Prozessschritt |
| **IT** | 7 | IT-Abteilungs-Prozessschritt |
| **HR** | 8 | HR-Abteilungs-Prozessschritt |
| **Operations** | 9 | Operations-Abteilungs-Prozessschritt |
| **Marketing** | 10 | Marketing-Abteilungs-Prozessschritt |

### Verwendung in Power Fx

```powerfx
// Prozessschritt basierend auf Rolle setzen
Patch(Items, SelectedItem,
    {
        Prozessschritt:
            Switch(
                true,
                UserRoles.IsManager, 'Prozessschritt (cr123_prozessschritt)'.Manager,
                UserRoles.IsGF, 'Prozessschritt (cr123_prozessschritt)'.GF,
                UserRoles.IsSales, 'Prozessschritt (cr123_prozessschritt)'.Sales,
                UserRoles.IsFinance, 'Prozessschritt (cr123_prozessschritt)'.Finance,
                Blank()
            )
    }
)

// Filtern nach Prozessschritt
Filter(Items,
    Prozessschritt = 'Prozessschritt (cr123_prozessschritt)'.Manager
)

// Prüfen ob Benutzer dem Prozessschritt zugeordnet ist
CanAccessProzessschritt(itemProzessschritt: Text): Boolean =
    Switch(
        Lower(itemProzessschritt),
        "manager", UserRoles.IsManager,
        "gf", UserRoles.IsGF,
        "supervisor", UserRoles.IsSupervisor,
        "executive", UserRoles.IsExecutive,
        "sales", UserRoles.IsSales,
        "finance", UserRoles.IsFinance,
        "it", UserRoles.IsIT,
        "hr", UserRoles.IsHR,
        "operations", UserRoles.IsOperations,
        "marketing", UserRoles.IsMarketing,
        false
    );
```

## Rollen-Übersicht

### Verfügbare Rollen

| Rolle | Beschreibung | Verwendung |
|-------|--------------|------------|
| **Admin** | Administrator | Volle Berechtigungen (nicht in Prozessschritt) |
| **GF** | Geschäftsführer | Höchste Führungsebene |
| **Manager** | Manager | Team-/Bereichsleitung |
| **Supervisor** | Team Lead | Team-Supervision |
| **Executive** | Executive | Führungskraft |
| **Sales** | Sales | Vertriebsabteilung |
| **Finance** | Finance | Finanzabteilung |
| **IT** | IT | IT-Abteilung |
| **HR** | HR | Personalabteilung |
| **Operations** | Operations | Betriebsabteilung |
| **Marketing** | Marketing | Marketingabteilung |
| **User** | User | Standard-Benutzer (nicht in Prozessschritt) |

### Rollen-Prüfung in Power Fx

```powerfx
// Einzelne Rolle prüfen
HasRole("GF")
HasRole("Manager")

// Mehrere Rollen prüfen
HasAnyRole("Manager,GF,Executive")

// Rolle-Label abrufen
GetRoleLabel()  // Gibt z.B. "Geschäftsführer" zurück
```

## Implementierung in Dataverse

### 1. Status-Spalte anpassen

```bash
# Über Power Platform CLI oder Web-Portal
# Spaltentyp: Choice
# Werte: beantragt, in Bearbeitung, genehmigt, abgelehnt
```

### 2. Prozessschritt-Spalte erstellen

```bash
# Power Platform CLI
pac solution add-reference --path YourSolution
```

**Über Power Platform Web-Portal:**

1. Zu Dataverse > Tabellen > Items navigieren
2. "Neue Spalte" klicken
3. Einstellungen:
   - Anzeigename: `Prozessschritt`
   - Datentyp: `Choice > Choice`
   - Choice: Global Choice (empfohlen) oder Lokal
   - Werte hinzufügen: Manager, Supervisor, Executive, GF, Sales, Finance, IT, HR, Operations, Marketing

### 3. Security Roles anpassen

Stellen Sie sicher, dass die entsprechenden Security Roles Zugriff auf die neue Spalte haben:

```
Read: Alle Rollen
Write: Je nach Business-Logik (z.B. nur Manager und höher)
```

## Best Practices

### Status-Übergänge

Empfohlene Status-Übergänge:

```
beantragt → in Bearbeitung → genehmigt
                           ↘ abgelehnt
```

### Prozessschritt-Zuweisung

- **Automatische Zuweisung**: Bei Erstellung basierend auf Benutzerrolle
- **Manuelle Änderung**: Nur durch Benutzer mit entsprechenden Berechtigungen
- **Workflow-Integration**: Power Automate Flow für Status-Änderungen basierend auf Prozessschritt

### Berechtigungen

```powerfx
// Beispiel für kombinierte Status- und Prozessschritt-Prüfung
CanEditItem(item: Record): Boolean =
    // Nur editierbar wenn:
    // 1. Status ist "beantragt" oder "in Bearbeitung"
    // 2. Prozessschritt passt zur Benutzerrolle
    IsOneOf(Lower(item.Status), "beantragt,in bearbeitung") &&
    CanAccessProzessschritt(item.Prozessschritt);
```

## Migration

Falls bereits bestehende Items vorhanden sind:

1. **Status migrieren**:
   - Mapping alter zu neuer Status-Werte definieren
   - Bulk-Update via Power Automate Flow

2. **Prozessschritt initialisieren**:
   - Basierend auf Owner oder Department
   - Default-Wert setzen falls erforderlich

3. **Formulare anpassen**:
   - Canvas App: Dropdown-Controls aktualisieren
   - Model-Driven App: Formulare aktualisieren

## Siehe auch

- [App-Formulas-Template.fx](./App-Formulas-Template.fx) - UDF-Definitionen
- [Control-Patterns-Modern.fx](./Control-Patterns-Modern.fx) - UI-Patterns
- [CLAUDE.md](./CLAUDE.md) - Projekt-Konventionen
