# VISE Payment API

API REST para el procesamiento de pagos y gestión de tarjetas VISE.

## Descripción

Sistema de procesamiento de pagos que gestiona diferentes tipos de tarjetas (Classic, Gold, Platinum, Black, White) con validación de elegibilidad, cálculo de beneficios y descuentos basados en reglas de negocio específicas.

## Características

- Registro de clientes con validación de elegibilidad por tipo de tarjeta
- Procesamiento de compras con aplicación automática de descuentos
- Sistema de logging con integración a Azure Application Insights y Axiom
- Restricciones geográficas para tarjetas premium
- Beneficios diferenciados por tipo de tarjeta y día de la semana
- Monitoreo con OpenTelemetry

## Tipos de Tarjeta

- **Classic**: Sin requisitos mínimos
- **Gold**: Ingreso mínimo $500
- **Platinum**: Ingreso mínimo $1000 + VISE Club
- **Black**: Ingreso mínimo $2000 + VISE Club + restricciones geográficas
- **White**: Ingreso mínimo $2000 + VISE Club + restricciones geográficas

## Endpoints

### POST /client
Registra un nuevo cliente con validación de elegibilidad.

**Body:**
```json
{
  "name": "string",
  "country": "string",
  "monthlyIncome": number,
  "viseClub": boolean,
  "cardType": "Classic|Gold|Platinum|Black|White"
}
```

### POST /purchase
Procesa una compra y calcula beneficios aplicables.

**Body:**
```json
{
  "clientId": number,
  "amount": number,
  "currency": "string",
  "purchaseDate": "ISO date",
  "purchaseCountry": "string"
}
```

### GET /clients
Obtiene la lista de todos los clientes registrados.

### GET /api/stats
Retorna estadísticas de uso de la API.

### GET /api/history
Retorna historial de peticiones procesadas.

## Instalación

```bash
npm install
```

## Variables de Entorno

Crear archivo `.env` con:

```
APPLICATIONINSIGHTS_CONNECTION_STRING=<connection-string>
AXIOM_TOKEN=<token>
AXIOM_DATASET=<dataset-name>
NODE_ENV=production
```

## Ejecución

```bash
npm start
```

La API se ejecuta en `http://localhost:3000`

## Docker

```bash
docker-compose up
```

## Tecnologías

- Node.js
- Express
- Azure Application Insights
- Axiom
- OpenTelemetry
- Docker
