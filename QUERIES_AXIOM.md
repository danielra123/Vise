# 🔍 Queries Útiles para Axiom - VISE API

## Queries Básicas

### Ver todos los logs
```apl
['vise-api-logs']
```

### Ver logs de los últimos 15 minutos
```apl
['vise-api-logs']
| where _time > ago(15m)
```

### Ver logs de hoy
```apl
['vise-api-logs']
| where _time > startofday(now())
```

---

## Queries por Nivel de Log

### Solo errores
```apl
['vise-api-logs']
| where level == "ERROR"
```

### Advertencias y errores
```apl
['vise-api-logs']
| where level in ("WARNING", "ERROR")
```

### Logs exitosos
```apl
['vise-api-logs']
| where level == "SUCCESS"
```

---

## Queries de Negocio

### Ver todos los registros de clientes
```apl
['vise-api-logs']
| where event_type == "client_registration"
| project _time, client_id, card_type, country, vise_club
| order by _time desc
```

### Ver todas las compras procesadas
```apl
['vise-api-logs']
| where event_type == "purchase"
| project _time, client_id, original_amount, discount_applied, final_amount, benefit
| order by _time desc
```

### Compras con descuentos mayores a $50
```apl
['vise-api-logs']
| where event_type == "purchase"
| where discount_applied > 50
| project _time, client_id, original_amount, discount_applied, final_amount, benefit
| order by discount_applied desc
```

### Ver errores de validación
```apl
['vise-api-logs']
| where event_type == "validation_error"
| project _time, error_message, name, country, card_type
| order by _time desc
```

### Registros por tipo de tarjeta
```apl
['vise-api-logs']
| where event_type == "client_registration"
| summarize count() by card_type
| order by count_ desc
```

### Compras por país
```apl
['vise-api-logs']
| where event_type == "purchase"
| summarize total_amount = sum(final_amount), count = count() by purchaseCountry
| order by total_amount desc
```

---

## Queries de Performance HTTP

### Ver todas las peticiones HTTP
```apl
['vise-api-logs']
| where method != ""
| project _time, method, url, statusCode, executionTime, ip
| order by _time desc
```

### Peticiones lentas (>500ms)
```apl
['vise-api-logs']
| where method != ""
| extend exec_ms = todouble(replace("ms", "", executionTime))
| where exec_ms > 500
| project _time, method, url, statusCode, executionTime, ip
| order by exec_ms desc
```

### Peticiones muy lentas (>1 segundo)
```apl
['vise-api-logs']
| where method != ""
| extend exec_ms = todouble(replace("ms", "", executionTime))
| where exec_ms > 1000
| project _time, method, url, statusCode, executionTime
```

### Errores HTTP (4xx y 5xx)
```apl
['vise-api-logs']
| where statusCode >= 400
| project _time, method, url, statusCode, ip
| order by _time desc
```

### Errores HTTP agrupados
```apl
['vise-api-logs']
| where statusCode >= 400
| summarize count() by statusCode, url
| order by count_ desc
```

### Promedio de tiempo de respuesta por endpoint
```apl
['vise-api-logs']
| where method != ""
| extend exec_ms = todouble(replace("ms", "", executionTime))
| summarize avg_time = avg(exec_ms), count = count() by url
| order by avg_time desc
```

### Top 10 endpoints más lentos
```apl
['vise-api-logs']
| where method != ""
| extend exec_ms = todouble(replace("ms", "", executionTime))
| summarize avg_time = avg(exec_ms), max_time = max(exec_ms), count = count() by url
| order by avg_time desc
| take 10
```

---

## Queries de Análisis

### Tráfico por hora
```apl
['vise-api-logs']
| where method != ""
| summarize count() by bin(_time, 1h)
| order by _time desc
```

### Distribución de métodos HTTP
```apl
['vise-api-logs']
| where method != ""
| summarize count() by method
```

### Top IPs con más peticiones
```apl
['vise-api-logs']
| where method != ""
| summarize count() by ip
| order by count_ desc
| take 10
```

### Clientes por país
```apl
['vise-api-logs']
| where event_type == "client_registration"
| summarize count() by country
| order by count_ desc
```

### Distribución de tipos de tarjeta
```apl
['vise-api-logs']
| where event_type == "client_registration"
| summarize count() by card_type
| order by count_ desc
```

### Clientes con VISE Club vs sin VISE Club
```apl
['vise-api-logs']
| where event_type == "client_registration"
| summarize count() by vise_club
```

### Beneficios más aplicados
```apl
['vise-api-logs']
| where event_type == "purchase"
| where benefit != "Sin beneficios aplicables"
| summarize count() by benefit
| order by count_ desc
```

### Monto total procesado
```apl
['vise-api-logs']
| where event_type == "purchase"
| summarize
    total_original = sum(original_amount),
    total_discounts = sum(discount_applied),
    total_final = sum(final_amount),
    total_transactions = count()
```

### Descuento promedio por tipo de tarjeta
```apl
['vise-api-logs']
| where event_type == "purchase"
| summarize
    avg_discount = avg(discount_applied),
    total_purchases = count()
    by cardType
| order by avg_discount desc
```

---

## Queries Avanzadas

### Timeline de eventos por cliente específico
```apl
['vise-api-logs']
| where client_id == 1
| project _time, event_type, message, level
| order by _time desc
```

### Detección de anomalías en tiempo de respuesta
```apl
['vise-api-logs']
| where method != ""
| extend exec_ms = todouble(replace("ms", "", executionTime))
| summarize
    avg_time = avg(exec_ms),
    p95_time = percentile(exec_ms, 95),
    p99_time = percentile(exec_ms, 99)
    by url
```

### Tasa de error por endpoint
```apl
['vise-api-logs']
| where method != ""
| extend is_error = iff(statusCode >= 400, 1, 0)
| summarize
    total_requests = count(),
    total_errors = sum(is_error),
    error_rate = round(100.0 * sum(is_error) / count(), 2)
    by url
| order by error_rate desc
```

### Compras rechazadas vs aprobadas
```apl
['vise-api-logs']
| where url == "/purchase"
| summarize count() by statusCode
```

### Clientes rechazados por razón
```apl
['vise-api-logs']
| where event_type == "validation_error"
| summarize count() by error_message
| order by count_ desc
```

---

## Tips para Usar APL

1. **Filtrar primero**: Usa `where` al principio para reducir datos
2. **Usar agregaciones**: `summarize` es muy poderoso
3. **Proyectar solo lo necesario**: `project` reduce el output
4. **Ordenar resultados**: `order by` para ver lo más importante primero
5. **Limitar resultados**: `take N` para ver solo los primeros N resultados

## Funciones Útiles

- `ago(15m)` - Hace 15 minutos
- `startofday(now())` - Inicio del día actual
- `bin(_time, 1h)` - Agrupar por hora
- `todouble()` - Convertir a número
- `replace()` - Reemplazar texto
- `sum()`, `avg()`, `max()`, `min()` - Agregaciones
- `percentile()` - Percentiles
- `count()` - Contar

---

¿Necesitas más queries? Modifica estas según tus necesidades!
