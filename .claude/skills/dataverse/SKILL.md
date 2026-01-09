---
name: dataverse
description: Microsoft Dataverse Entwicklung - Tabellen, Spalten, Beziehungen, Web API und Plugins. Nutze diesen Skill für Datenmodellierung und Backend-Entwicklung.
---

# Dataverse Entwicklung

## Tabellen-Design

### Tabellentypen
| Typ | Verwendung |
|-----|------------|
| **Standard** | Eigene Geschäftsdaten |
| **Activity** | Zeitbasierte Aktivitäten |
| **Virtual** | Externe Daten ohne Import |
| **Elastic** | Große Datenmengen (JSON) |

### Spaltentypen
```yaml
Text:
  - Single Line (max 4000)
  - Multiple Lines (max 1M)
  - Rich Text

Number:
  - Whole Number
  - Decimal
  - Float
  - Currency

Date:
  - Date Only
  - Date and Time

Lookup:
  - Single (N:1)
  - Customer (Account/Contact)
  - Owner (User/Team)

Choice:
  - Local Choice
  - Global Choice
  - Yes/No
```

### Beziehungen

```
1:N (One-to-Many)
├── Primäre Tabelle: Account
├── Verknüpfte Tabelle: Contact
└── Lookup-Spalte: parentcustomerid

N:N (Many-to-Many)
├── Tabelle 1: Product
├── Tabelle 2: Category
└── Intersect Entity: product_category_association
```

### Calculated vs Rollup

```yaml
Calculated Column:
  - Sofortige Berechnung
  - Einfache Formeln
  - Beispiel: FullName = FirstName + " " + LastName

Rollup Column:
  - Asynchrone Berechnung (alle 12h oder manuell)
  - Aggregation über verknüpfte Datensätze
  - Beispiel: TotalRevenue = SUM(Orders.Amount)
```

## Web API

### Basis-URL
```
https://[org].api.crm.dynamics.com/api/data/v9.2/
```

### CRUD Operationen

```http
# CREATE
POST /accounts
Content-Type: application/json
{
  "name": "Contoso Ltd",
  "revenue": 1000000
}

# READ
GET /accounts(guid)?$select=name,revenue

# READ mit Expand (Beziehungen)
GET /accounts(guid)?$expand=contact_customer_accounts($select=fullname)

# UPDATE (PATCH)
PATCH /accounts(guid)
Content-Type: application/json
{
  "revenue": 1500000
}

# DELETE
DELETE /accounts(guid)
```

### Abfragen

```http
# Filter
GET /accounts?$filter=revenue gt 1000000

# OrderBy
GET /accounts?$orderby=createdon desc

# Top/Skip (Pagination)
GET /accounts?$top=50&$skip=100

# Kombiniert
GET /accounts?$select=name,revenue
  &$filter=statecode eq 0 and revenue gt 100000
  &$orderby=revenue desc
  &$top=10
  &$expand=primarycontactid($select=fullname,emailaddress1)
```

### Batch Requests

```http
POST /$batch
Content-Type: multipart/mixed; boundary=batch_123

--batch_123
Content-Type: application/http
Content-Transfer-Encoding: binary

GET /accounts?$top=5 HTTP/1.1
Accept: application/json

--batch_123
Content-Type: application/http
Content-Transfer-Encoding: binary

POST /contacts HTTP/1.1
Content-Type: application/json

{"firstname":"John","lastname":"Doe"}

--batch_123--
```

## Plugins (C#)

### Plugin-Struktur
```csharp
public class AccountPreCreate : IPlugin
{
    public void Execute(IServiceProvider serviceProvider)
    {
        // Context abrufen
        var context = (IPluginExecutionContext)
            serviceProvider.GetService(typeof(IPluginExecutionContext));

        // Services abrufen
        var serviceFactory = (IOrganizationServiceFactory)
            serviceProvider.GetService(typeof(IOrganizationServiceFactory));
        var service = serviceFactory.CreateOrganizationService(context.UserId);

        var tracingService = (ITracingService)
            serviceProvider.GetService(typeof(ITracingService));

        try
        {
            if (context.InputParameters.Contains("Target")
                && context.InputParameters["Target"] is Entity)
            {
                var entity = (Entity)context.InputParameters["Target"];

                // Logik hier
                if (!entity.Contains("name"))
                {
                    throw new InvalidPluginExecutionException(
                        "Account name is required");
                }
            }
        }
        catch (Exception ex)
        {
            tracingService.Trace($"Error: {ex.Message}");
            throw;
        }
    }
}
```

### Plugin Registration

```yaml
Step:
  Message: Create
  Primary Entity: account
  Stage: Pre-operation (20) / Post-operation (40)
  Execution Mode: Synchronous / Asynchronous
  Filtering Attributes: name, revenue (optional)
```

### Pre vs Post Operation

| Stage | Verwendung |
|-------|------------|
| Pre-validation (10) | Validierung vor DB-Lock |
| Pre-operation (20) | Werte ändern vor Speicherung |
| Post-operation (40) | Nach Speicherung, Folgeaktionen |

## Custom APIs

```xml
<customapi uniquename="contoso_CalculateDiscount">
  <displayname>Calculate Discount</displayname>
  <bindingtype>Global</bindingtype>
  <allowedcustomprocessingsteptype>None</allowedcustomprocessingsteptype>
  <isfunction>false</isfunction>
  <requestparameters>
    <customapirequestparameter uniquename="OrderId" type="EntityReference" />
    <customapirequestparameter uniquename="DiscountCode" type="String" />
  </requestparameters>
  <responseproperty uniquename="DiscountAmount" type="Decimal" />
</customapi>
```

## Security

### Security Roles
```yaml
Privileges:
  - Create: Benutzer/Unternehmenseinheit/Organisation
  - Read: Benutzer/Unternehmenseinheit/Organisation
  - Write: Benutzer/Unternehmenseinheit/Organisation
  - Delete: Benutzer/Unternehmenseinheit/Organisation
  - Append: Datensätze verknüpfen
  - AppendTo: Als Ziel für Verknüpfung
  - Assign: Besitzer ändern
  - Share: Freigeben
```

### Row-Level Security
```yaml
Field Security Profile:
  - Allowed: Lesen/Aktualisieren/Erstellen
  - Not Allowed: Kein Zugriff
```

## Best Practices

1. **Prefixe nutzen** für Custom-Spalten (z.B. `contoso_`)
2. **Audit aktivieren** für wichtige Tabellen
3. **Indexes** für häufig gefilterte Spalten
4. **Alternate Keys** für Integrationen
5. **Business Rules** vor Plugins für einfache Logik
6. **Plugins async** wenn möglich
7. **Change Tracking** für Sync-Szenarien
