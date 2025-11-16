# ✅ Configuración Final de Axiom

## 🎯 Credenciales Actuales

```
Token: xaat-15218009-c82e-41e6-8cb2-f4c7a2dddc8a
Dataset: vise-api-logs
```

---

## 🚀 Pasos para Ver Logs en Axiom (FINAL)

### **Paso 1: Configurar Azure App Service**

```powershell
.\configurar-axiom-azure.ps1
```

Esto configura:
- ✅ `AXIOM_TOKEN=xaat-15218009-c82e-41e6-8cb2-f4c7a2dddc8a`
- ✅ `AXIOM_DATASET=vise-api-logs`
- ✅ Reinicia el App Service

---

### **Paso 2: Generar Tráfico**

```powershell
.\probar-axiom.ps1
```

Selecciona opción `2` (Azure)

O manualmente:

```powershell
# Registrar cliente
Invoke-RestMethod -Uri "https://vise-api-app.azurewebsites.net/client" `
  -Method Post `
  -Body '{"name":"Test","country":"USA","monthlyIncome":1500,"viseClub":true,"cardType":"Platinum"}' `
  -ContentType "application/json"
```

---

### **Paso 3: Ver en Axiom**

#### **Opción A: Stream (Más Fácil)** ⭐

1. Abre: **https://app.axiom.co**
2. Haz clic en el dataset: **`vise-api-logs`**
3. Verás el **Stream** automáticamente (logs en tiempo real)
4. Haz clic en **"Live"** para ver logs en vivo

#### **Opción B: Query (Avanzado)**

En Axiom, ejecuta esta query:

```apl
['vise-api-logs']
| where _time > ago(10m)
| project _time, level, message, event_type, environment
| sort by _time desc
```

**⚠️ IMPORTANTE**: Usa **corchetes y comillas simples** exactamente como arriba.

---

## 📊 Queries Útiles

### Ver todos los logs de Azure (production)
```apl
['vise-api-logs']
| where environment == "production"
| project _time, level, message, event_type
| sort by _time desc
| take 50
```

### Ver registros de clientes
```apl
['vise-api-logs']
| where event_type == "client_registration"
| project _time, message, client_id, card_type, country
| sort by _time desc
```

### Ver compras procesadas
```apl
['vise-api-logs']
| where event_type == "purchase"
| project _time, client_id, original_amount, final_amount, benefit
| sort by _time desc
```

### Ver errores
```apl
['vise-api-logs']
| where level == "ERROR" or level == "WARNING"
| project _time, level, message, error_message
| sort by _time desc
```

### Ver peticiones HTTP
```apl
['vise-api-logs']
| where method != ""
| project _time, method, url, statusCode, executionTime
| sort by _time desc
```

---

## 🔍 Troubleshooting

### No veo logs en el Stream

1. **Verifica que las variables estén configuradas:**

```powershell
az webapp config appsettings list --name vise-api-app --query "[?name=='AXIOM_TOKEN' || name=='AXIOM_DATASET']" -o table
```

Deberías ver:
```
Name            Value
--------------  --------------------------------------
AXIOM_TOKEN     xaat-15218009-c82e-41e6-8cb2-f4c7a2dddc8a
AXIOM_DATASET   vise-api-logs
```

2. **Verifica los logs del App Service:**

```powershell
az webapp log tail --name vise-api-app
```

Busca:
```
✅ Axiom Logger conectado correctamente
📊 Dataset: vise-api-logs
```

3. **Si ves:**
```
⚠️ Axiom Logger deshabilitado (no se encontró AXIOM_TOKEN)
```

Entonces ejecuta de nuevo:
```powershell
.\configurar-axiom-azure.ps1
```

---

### Error en Query: "unexpected token"

Asegúrate de usar la sintaxis correcta:

✅ **Correcto:**
```apl
['vise-api-logs']
```

❌ **Incorrecto:**
```apl
'vise-api-logs'
["vise-api-logs"]
[vise-api-logs]
```

---

## ✅ Checklist Final

### Local
- [ ] Token actualizado en `.env`
- [ ] Ejecutar `npm start`
- [ ] Ver mensaje: "Axiom Logger conectado correctamente"
- [ ] Hacer peticiones de prueba
- [ ] Ver logs en Axiom Stream

### Azure
- [ ] Ejecutar `.\configurar-axiom-azure.ps1`
- [ ] Ver confirmación de variables actualizadas
- [ ] App Service reiniciado
- [ ] Ejecutar `.\probar-axiom.ps1` (opción 2)
- [ ] Ver logs en Axiom con `environment: "production"`

---

## 🎯 Resumen

**Tu configuración**:
```
Token:    xaat-15218009-c82e-41e6-8cb2-f4c7a2dddc8a
Dataset:  vise-api-logs
URL API:  https://vise-api-app.azurewebsites.net
Axiom:    https://app.axiom.co
```

**Qué se envía a Axiom**:
- ✅ Logs de eventos de negocio (client_registration, purchase)
- ✅ Logs de peticiones HTTP (method, url, status)
- ✅ Logs de errores de validación
- ✅ Datos del cliente (environment: production/development)

**Qué NO se envía**:
- ❌ Trazas OpenTelemetry (desactivado)
- ❌ Métricas (solo logs)

---

## 🎉 ¡Listo!

Ahora solo ejecuta:
```powershell
.\configurar-axiom-azure.ps1
```

Y ve al Stream en Axiom: https://app.axiom.co
