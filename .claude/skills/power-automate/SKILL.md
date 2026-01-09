---
name: power-automate
description: Power Automate Flow-Entwicklung, Trigger, Aktionen, Expressions und Fehlerbehandlung. Nutze diesen Skill für Workflow-Automatisierung und Integrationen.
---

# Power Automate Entwicklung

## Flow-Typen

| Typ | Verwendung |
|-----|------------|
| **Automated** | Trigger-basiert (Event) |
| **Instant** | Manuell gestartet |
| **Scheduled** | Zeitgesteuert |
| **Desktop** | RPA, lokale Automation |
| **Business Process** | Guided Process |

## Flow-Struktur

```
Flow
├── Trigger
├── Actions
│   ├── Condition
│   │   ├── If yes
│   │   └── If no
│   ├── Apply to each
│   ├── Scope (Try)
│   └── Scope (Catch)
└── Response/Terminate
```

## Trigger

### Dataverse Trigger
```json
{
  "type": "OpenApiConnectionWebhook",
  "inputs": {
    "host": {
      "connectionName": "shared_commondataserviceforapps"
    },
    "parameters": {
      "subscriptionRequest/entityname": "account",
      "subscriptionRequest/scope": 4,
      "subscriptionRequest/filteringattributes": "name,revenue"
    }
  }
}
```

### HTTP Trigger
```json
{
  "type": "Request",
  "kind": "Http",
  "inputs": {
    "schema": {
      "type": "object",
      "properties": {
        "name": {"type": "string"},
        "id": {"type": "integer"}
      },
      "required": ["name"]
    }
  }
}
```

## Expressions

### Häufig verwendete Expressions

```javascript
// Trigger Output
triggerOutputs()?['body/accountid']
triggerBody()?['name']

// Action Output
outputs('Get_Item')?['body/value']
body('HTTP_Request')

// Variablen
variables('varCounter')

// Null-Handling
coalesce(triggerBody()?['email'], 'keine-email@example.com')

// String-Operationen
concat('Hello, ', triggerBody()?['name'])
substring(variables('text'), 0, 10)
replace(variables('text'), 'old', 'new')
toLower(triggerBody()?['email'])
trim(variables('input'))

// Datum/Zeit
utcNow()
addDays(utcNow(), 7)
formatDateTime(utcNow(), 'yyyy-MM-dd')
convertTimeZone(utcNow(), 'UTC', 'W. Europe Standard Time')

// Bedingungen
if(equals(triggerBody()?['status'], 'Active'), 'Ja', 'Nein')
if(greater(variables('count'), 10), 'Viele', 'Wenige')

// Arrays
first(body('List_Items')?['value'])
last(body('List_Items')?['value'])
length(body('List_Items')?['value'])

// JSON
json(triggerBody()?['jsonString'])
string(variables('myObject'))
```

### Expression-Syntax

```javascript
// Zugriff auf verschachtelte Eigenschaften
items('Apply_to_each')?['customer']?['address']?['city']

// Array-Index
body('List_Items')?['value'][0]?['name']

// Dynamische Pfade
outputs('Get_Item')?['body']?[variables('fieldName')]
```

## Fehlerbehandlung

### Try-Catch Pattern

```yaml
Scope_Try:
  actions:
    - Action1
    - Action2

Scope_Catch:
  runAfter:
    Scope_Try: [Failed, TimedOut]
  actions:
    - Compose_Error:
        inputs: "@result('Scope_Try')"
    - Send_Email_Notification
    - Terminate:
        inputs:
          runStatus: Failed
          runError:
            code: "500"
            message: "@{outputs('Compose_Error')}"
```

### Configure Run After
```yaml
Action_After_Failure:
  runAfter:
    Previous_Action:
      - Succeeded
      - Failed
      - Skipped
      - TimedOut
```

### Retry Policy
```json
{
  "retryPolicy": {
    "type": "exponential",
    "count": 3,
    "interval": "PT10S",
    "minimumInterval": "PT5S",
    "maximumInterval": "PT1H"
  }
}
```

## Performance & Limits

### Concurrency Control
```json
{
  "runtimeConfiguration": {
    "concurrency": {
      "runs": 1,
      "maximumWaitingRuns": 10
    }
  }
}
```

### Batch-Verarbeitung
```javascript
// Statt einzeln: Batch-Operationen
// Power Automate: "List rows" mit Filter
// Dataverse: Batch API nutzen
```

### Limits beachten
| Limit | Wert |
|-------|------|
| Flow-Timeout | 30 Tage |
| Action-Timeout | 1 Tag (HTTP) |
| Loop-Iterationen | 100.000 |
| Variables | 256 pro Flow |
| Nested Depth | 8 Ebenen |

## Child Flows

### Aufruf
```yaml
Run_Child_Flow:
  type: Workflow
  inputs:
    host:
      workflow:
        id: /workflows/[child-flow-id]
    body:
      parameter1: "@variables('input')"
```

### Rückgabe
```yaml
# Im Child Flow
Respond_to_PowerApp_or_Flow:
  type: Response
  inputs:
    statusCode: 200
    body:
      result: "@variables('output')"
```

## HTTP-Aktionen

### REST API Aufruf
```json
{
  "method": "POST",
  "uri": "https://api.example.com/data",
  "headers": {
    "Content-Type": "application/json",
    "Authorization": "Bearer @{variables('token')}"
  },
  "body": {
    "name": "@{triggerBody()?['name']}",
    "data": "@{variables('payload')}"
  }
}
```

### Pagination
```json
{
  "runtimeConfiguration": {
    "paginationPolicy": {
      "minimumItemCount": 5000
    }
  }
}
```

## Best Practices

1. **Naming Convention**: `[App]-[Aktion]-[Trigger]`
2. **Scopes nutzen** für Gruppierung und Error Handling
3. **Compose-Aktionen** für Debugging und Lesbarkeit
4. **Environment Variables** für Konfiguration
5. **Connection References** für Deployment
6. **Parallelisierung** wo möglich (Apply to each → Concurrency)
7. **Filter früh** - weniger Daten = schnellerer Flow
