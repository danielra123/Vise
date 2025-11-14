# 🚀 Guía Rápida: Configurar Axiom en 5 Minutos

## ✅ Checklist de Configuración

### Paso 1: Crear cuenta en Axiom (2 min)
- [ ] Ir a: https://app.axiom.co/register
- [ ] Registrarse con email/GitHub/Google
- [ ] Verificar email

### Paso 2: Crear Dataset (1 min)
- [ ] En el dashboard de Axiom, ir a **"Datasets"**
- [ ] Clic en **"Create Dataset"**
- [ ] Nombre: `vise-api-logs`
- [ ] Guardar

### Paso 3: Generar API Token (1 min)
- [ ] Ir a **Settings** (⚙️)
- [ ] Seleccionar **"API Tokens"**
- [ ] Clic en **"Create API Token"**
- [ ] Nombre: `vise-api-token`
- [ ] Permisos: Marcar **"Ingest"**
- [ ] **¡COPIAR EL TOKEN!** (solo se muestra una vez)

### Paso 4: Configurar el proyecto (1 min)
- [ ] Abrir el archivo `.env` en la raíz del proyecto
- [ ] Reemplazar `AQUI_PEGA_TU_TOKEN` con tu token real
- [ ] Guardar el archivo

## 📝 Ejemplo de archivo `.env` configurado:

```bash
# ===============================
# 📊 AXIOM CONFIGURATION
# ===============================
AXIOM_TOKEN=xaat-abcd1234-5678-90ef-ghij-klmnopqrstuv
AXIOM_DATASET=vise-api-logs

# ===============================
# 🔍 AZURE APPLICATION INSIGHTS
# ===============================
APPLICATIONINSIGHTS_CONNECTION_STRING=InstrumentationKey=dd2c0206-4c52-43e9-a88f-77e18c1a6915

# ===============================
# 🚀 APPLICATION SETTINGS
# ===============================
NODE_ENV=development
PORT=3000
```

## 🧪 Probar la Configuración

### Opción 1: Script de Prueba (Recomendado)
```bash
npm run test:axiom
```

Deberías ver:
```
✅ Axiom Logger conectado correctamente
📊 Dataset: vise-api-logs
✅ Log de información enviado
✅ Log de éxito enviado
✅ Log de advertencia enviado
...
🎉 ¡Todas las pruebas completadas exitosamente!
```

### Opción 2: Iniciar el Servidor
```bash
npm start
```

Deberías ver:
```
✅ Axiom Logger conectado correctamente
📊 Dataset: vise-api-logs
✅ Application Insights conectado correctamente
✅ OpenTelemetry iniciado y enviando trazas a Grafana Tempo
🚀 Servidor VISE API ejecutándose en http://localhost:3000
```

### Opción 3: Hacer una Petición de Prueba
```bash
curl -X POST http://localhost:3000/client \
  -H "Content-Type: application/json" \
  -d "{\"name\":\"Test User\",\"country\":\"USA\",\"monthlyIncome\":1500,\"viseClub\":true,\"cardType\":\"Platinum\"}"
```

## 📊 Verificar en Axiom

1. Ve a: https://app.axiom.co
2. Abre tu dataset: `vise-api-logs`
3. Deberías ver tus logs apareciendo en tiempo real!

### Queries útiles para probar:

**Ver todos los logs:**
```apl
['vise-api-logs']
```

**Ver solo registros de clientes:**
```apl
['vise-api-logs']
| where event_type == "client_registration"
```

**Ver solo compras:**
```apl
['vise-api-logs']
| where event_type == "purchase"
```

**Ver peticiones HTTP:**
```apl
['vise-api-logs']
| where method != ""
| project _time, method, url, statusCode, executionTime
```

## ⚠️ Problemas Comunes

### ❌ "Axiom Logger deshabilitado"
**Causa:** No se encontró `AXIOM_TOKEN` en el archivo `.env`
**Solución:**
1. Verifica que el archivo `.env` existe en la raíz del proyecto
2. Verifica que `AXIOM_TOKEN` está correctamente escrito
3. Reinicia el servidor

### ❌ "Error al conectar con Axiom"
**Causa:** Token inválido o dataset no existe
**Solución:**
1. Verifica que el token es correcto (cópialo nuevamente)
2. Verifica que el dataset existe en tu cuenta de Axiom
3. Verifica que el nombre del dataset coincide exactamente

### ❌ No veo logs en Axiom
**Causa:** Los logs se envían de forma asíncrona
**Solución:**
1. Espera 10-30 segundos
2. Refresca la página de Axiom
3. Usa el script de prueba: `npm run test:axiom`

## 🎯 Siguientes Pasos

Una vez configurado correctamente:

1. **Crea un Dashboard** en Axiom para visualizar tus logs
2. **Configura Alertas** para errores críticos
3. **Explora APL** (Axiom Processing Language) para queries avanzadas

## 📚 Recursos Útiles

- Dashboard de Axiom: https://app.axiom.co
- Documentación: https://axiom.co/docs
- APL Reference: https://axiom.co/docs/apl/introduction
- API Tokens: https://app.axiom.co/settings/api-tokens

## 🆘 ¿Necesitas ayuda?

Si tienes problemas:
1. Revisa esta guía desde el principio
2. Verifica el archivo `AXIOM_SETUP.md` para más detalles
3. Ejecuta `npm run test:axiom` y comparte el output

---

**¡Listo! Ahora tienes observabilidad completa de tu API con Axiom 🎉**
