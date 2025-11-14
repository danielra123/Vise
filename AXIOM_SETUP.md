# 📊 Configuración de Axiom para VISE Payment API

Este proyecto integra **Axiom** como plataforma de observabilidad para logs y trazas.

## 🚀 Configuración Rápida

### 1. Crear una cuenta en Axiom

1. Ve a [axiom.co](https://axiom.co) y crea una cuenta
2. Crea un nuevo dataset llamado `vise-api-logs` (o el nombre que prefieras)
3. Genera un API token desde **Settings > API Tokens**

### 2. Configurar Variables de Entorno

Crea un archivo `.env` en la raíz del proyecto con las siguientes variables:

```bash
# Axiom Configuration
AXIOM_TOKEN=xaat-tu-token-aqui
AXIOM_DATASET=vise-api-logs

# Opcional: OpenTelemetry para Grafana Tempo
TEMPO_URL=https://tempo-<tu-instancia>.grafana.net/otlp/v1/traces
TEMPO_USER=tu-usuario
TEMPO_TOKEN=tu-token

# Azure Application Insights (opcional)
APPLICATIONINSIGHTS_CONNECTION_STRING=InstrumentationKey=tu-key

# Entorno
NODE_ENV=production
```

### 3. Instalar Dependencias

Las dependencias de Axiom ya están incluidas en el `package.json`:

```bash
npm install
```

### 4. Iniciar la Aplicación

```bash
npm start
```

## 📝 ¿Qué se registra en Axiom?

### 1. Logs de Aplicación

Todos los eventos importantes se envían a Axiom:

- ✅ **Registro de clientes**: Con detalles de tarjeta, país, ingresos
- 💳 **Procesamiento de compras**: Con montos, descuentos y beneficios
- ⚠️ **Errores de validación**: Clientes no elegibles, restricciones
- 🌐 **Todas las peticiones HTTP**: Método, URL, status code, tiempos de respuesta

### 2. Trazas OpenTelemetry (Opcional)

Si configuras el token de Axiom, las trazas de OpenTelemetry también se enviarán a Axiom además de Grafana Tempo.

## 🔍 Estructura de Logs en Axiom

Cada log incluye:

```json
{
  "_time": "2025-11-13T15:30:00.000Z",
  "level": "INFO",
  "message": "Cliente registrado",
  "service": "vise-payment-api",
  "environment": "production",
  "event_type": "client_registration",
  "client_id": 123,
  "card_type": "Platinum",
  "country": "USA",
  "method": "POST",
  "url": "/client",
  "statusCode": 201,
  "ip": "192.168.1.1",
  "executionTime": "45ms"
}
```

## 📊 Queries Útiles en Axiom

### Ver todos los registros de clientes
```apl
['vise-api-logs']
| where event_type == "client_registration"
```

### Ver todas las compras procesadas
```apl
['vise-api-logs']
| where event_type == "purchase"
| project _time, client_id, original_amount, final_amount, benefit
```

### Ver errores de validación
```apl
['vise-api-logs']
| where event_type == "validation_error"
| project _time, error_message, country, card_type
```

### Peticiones HTTP lentas (>500ms)
```apl
['vise-api-logs']
| where method != ""
| extend exec_time = todouble(replace("ms", "", executionTime))
| where exec_time > 500
| project _time, method, url, statusCode, executionTime
```

### Errores HTTP (4xx y 5xx)
```apl
['vise-api-logs']
| where statusCode >= 400
| summarize count() by statusCode, url
```

## 🎯 Características Principales

### 1. Logger Personalizado (`axiom-logger.js`)

Módulo dedicado con métodos específicos:

```javascript
const axiomLogger = require('./axiom-logger');

// Logs generales
await axiomLogger.info('Mensaje de información');
await axiomLogger.success('Operación exitosa');
await axiomLogger.warning('Advertencia');
await axiomLogger.error('Error crítico');

// Logs específicos del negocio
await axiomLogger.logClientRegistration(client);
await axiomLogger.logPurchase(purchase, metadata);
await axiomLogger.logValidationError(error, metadata);
```

### 2. Integración con OpenTelemetry

El archivo `tracing.js` envía trazas tanto a Grafana Tempo como a Axiom (si está configurado).

### 3. Logs Automáticos de HTTP

Middleware que captura automáticamente todas las peticiones HTTP con:
- Método y URL
- Status code
- Tiempo de ejecución
- IP del cliente
- User-Agent
- Request y Response bodies

## 🔒 Seguridad

- **Nunca** commits el archivo `.env` al repositorio
- Usa `.env.example` como plantilla
- Rota los tokens regularmente
- Usa diferentes tokens para desarrollo y producción

## 🧪 Pruebas

Para probar que Axiom está funcionando:

1. Inicia el servidor:
```bash
npm start
```

2. Verifica en la consola:
```
✅ Axiom Logger conectado correctamente
📊 Dataset: vise-api-logs
```

3. Haz una petición de prueba:
```bash
curl -X POST http://localhost:3000/client \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Test User",
    "country": "USA",
    "monthlyIncome": 1500,
    "viseClub": true,
    "cardType": "Platinum"
  }'
```

4. Ve a tu dashboard de Axiom y verifica que aparezcan los logs

## 📚 Recursos

- [Documentación de Axiom](https://axiom.co/docs)
- [Axiom JS SDK](https://github.com/axiomhq/axiom-js)
- [APL Query Language](https://axiom.co/docs/apl/introduction)

## 🆘 Solución de Problemas

### Logs no aparecen en Axiom

1. Verifica que `AXIOM_TOKEN` esté configurado correctamente
2. Verifica que `AXIOM_DATASET` exista en tu cuenta de Axiom
3. Revisa la consola para ver errores de conexión
4. Asegúrate de que el token tenga permisos de escritura

### "Axiom Logger deshabilitado"

Esto significa que no se encontró la variable `AXIOM_TOKEN`. Configúrala en tu archivo `.env`.

### Problemas de rendimiento

Los logs se envían de forma asíncrona, pero si experimentas lentitud:
- Considera usar batching (enviar múltiples logs juntos)
- Aumenta el intervalo de flush
- Usa un queue para logs

## 🎉 ¡Listo!

Ahora tienes observabilidad completa de tu API con Axiom. Puedes crear dashboards personalizados, alertas y monitores para tu aplicación.
