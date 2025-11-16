#!/bin/bash

# ==================================
# 🧪 Script de Prueba de Monitoreo
# ==================================
# Este script prueba tu API en Azure y verifica que los logs
# se estén enviando correctamente a Axiom y Application Insights

echo "🚀 Iniciando pruebas de monitoreo..."
echo ""

# Variables
AZURE_URL="https://vise-api-app.azurewebsites.net"
LOCAL_URL="http://localhost:3000"

# Preguntar si probar local o Azure
echo "¿Dónde quieres probar?"
echo "1) Local (http://localhost:3000)"
echo "2) Azure (https://vise-api-app.azurewebsites.net)"
read -p "Selecciona una opción (1 o 2): " OPTION

if [ "$OPTION" == "1" ]; then
    BASE_URL=$LOCAL_URL
    echo "✅ Probando servidor LOCAL"
else
    BASE_URL=$AZURE_URL
    echo "✅ Probando servidor AZURE"
fi

echo ""
echo "═══════════════════════════════════════════════════════════"
echo "📋 Paso 1: Verificar conectividad"
echo "═══════════════════════════════════════════════════════════"

if curl -f -s -o /dev/null "$BASE_URL"; then
    echo "✅ Servidor respondiendo correctamente"
else
    echo "❌ Error: Servidor no responde"
    echo "   Verifica que el servidor esté corriendo"
    exit 1
fi

echo ""
echo "═══════════════════════════════════════════════════════════"
echo "📋 Paso 2: Registrar clientes de prueba"
echo "═══════════════════════════════════════════════════════════"

# Cliente 1: Platinum (USA)
echo ""
echo "📝 Registrando Cliente 1 (Platinum - USA)..."
RESPONSE1=$(curl -s -X POST "$BASE_URL/client" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "John Doe",
    "country": "USA",
    "monthlyIncome": 1500,
    "viseClub": true,
    "cardType": "Platinum"
  }')

echo "$RESPONSE1" | jq '.'
CLIENT_ID_1=$(echo "$RESPONSE1" | jq -r '.clientId')

if [ "$CLIENT_ID_1" != "null" ]; then
    echo "✅ Cliente 1 registrado (ID: $CLIENT_ID_1)"
else
    echo "❌ Error al registrar Cliente 1"
fi

# Cliente 2: Gold (Colombia)
echo ""
echo "📝 Registrando Cliente 2 (Gold - Colombia)..."
RESPONSE2=$(curl -s -X POST "$BASE_URL/client" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "María García",
    "country": "Colombia",
    "monthlyIncome": 800,
    "viseClub": false,
    "cardType": "Gold"
  }')

echo "$RESPONSE2" | jq '.'
CLIENT_ID_2=$(echo "$RESPONSE2" | jq -r '.clientId')

if [ "$CLIENT_ID_2" != "null" ]; then
    echo "✅ Cliente 2 registrado (ID: $CLIENT_ID_2)"
else
    echo "❌ Error al registrar Cliente 2"
fi

# Cliente 3: Black (Brazil)
echo ""
echo "📝 Registrando Cliente 3 (Black - Brazil)..."
RESPONSE3=$(curl -s -X POST "$BASE_URL/client" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Pedro Silva",
    "country": "Brazil",
    "monthlyIncome": 3000,
    "viseClub": true,
    "cardType": "Black"
  }')

echo "$RESPONSE3" | jq '.'
CLIENT_ID_3=$(echo "$RESPONSE3" | jq -r '.clientId')

if [ "$CLIENT_ID_3" != "null" ]; then
    echo "✅ Cliente 3 registrado (ID: $CLIENT_ID_3)"
else
    echo "❌ Error al registrar Cliente 3"
fi

echo ""
echo "═══════════════════════════════════════════════════════════"
echo "📋 Paso 3: Procesar compras de prueba"
echo "═══════════════════════════════════════════════════════════"

# Compra 1: Cliente Platinum en Lunes (descuento 20%)
echo ""
echo "💳 Procesando Compra 1 (Cliente $CLIENT_ID_1 - Lunes - \$150)..."
PURCHASE1=$(curl -s -X POST "$BASE_URL/purchase" \
  -H "Content-Type: application/json" \
  -d "{
    \"clientId\": $CLIENT_ID_1,
    \"amount\": 150,
    \"currency\": \"USD\",
    \"purchaseDate\": \"2025-11-17T10:00:00Z\",
    \"purchaseCountry\": \"USA\"
  }")

echo "$PURCHASE1" | jq '.'

if echo "$PURCHASE1" | jq -e '.status == "Approved"' > /dev/null; then
    echo "✅ Compra 1 aprobada"
else
    echo "❌ Compra 1 rechazada"
fi

# Compra 2: Cliente Gold en Martes (descuento 15%)
echo ""
echo "💳 Procesando Compra 2 (Cliente $CLIENT_ID_2 - Martes - \$120)..."
PURCHASE2=$(curl -s -X POST "$BASE_URL/purchase" \
  -H "Content-Type: application/json" \
  -d "{
    \"clientId\": $CLIENT_ID_2,
    \"amount\": 120,
    \"currency\": \"USD\",
    \"purchaseDate\": \"2025-11-18T14:00:00Z\",
    \"purchaseCountry\": \"Colombia\"
  }")

echo "$PURCHASE2" | jq '.'

if echo "$PURCHASE2" | jq -e '.status == "Approved"' > /dev/null; then
    echo "✅ Compra 2 aprobada"
else
    echo "❌ Compra 2 rechazada"
fi

# Compra 3: Cliente Black en Sábado (descuento 35%)
echo ""
echo "💳 Procesando Compra 3 (Cliente $CLIENT_ID_3 - Sábado - \$250)..."
PURCHASE3=$(curl -s -X POST "$BASE_URL/purchase" \
  -H "Content-Type: application/json" \
  -d "{
    \"clientId\": $CLIENT_ID_3,
    \"amount\": 250,
    \"currency\": \"USD\",
    \"purchaseDate\": \"2025-11-22T18:00:00Z\",
    \"purchaseCountry\": \"Brazil\"
  }")

echo "$PURCHASE3" | jq '.'

if echo "$PURCHASE3" | jq -e '.status == "Approved"' > /dev/null; then
    echo "✅ Compra 3 aprobada"
else
    echo "❌ Compra 3 rechazada"
fi

echo ""
echo "═══════════════════════════════════════════════════════════"
echo "📋 Paso 4: Generar un error de validación"
echo "═══════════════════════════════════════════════════════════"

# Intentar registrar cliente que no cumple requisitos
echo ""
echo "❌ Intentando registrar cliente no elegible (Platinum sin VISE Club)..."
ERROR_RESPONSE=$(curl -s -X POST "$BASE_URL/client" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Test Error",
    "country": "USA",
    "monthlyIncome": 1500,
    "viseClub": false,
    "cardType": "Platinum"
  }')

echo "$ERROR_RESPONSE" | jq '.'

if echo "$ERROR_RESPONSE" | jq -e '.status == "Rejected"' > /dev/null; then
    echo "✅ Error de validación capturado correctamente"
else
    echo "❌ No se generó el error esperado"
fi

echo ""
echo "═══════════════════════════════════════════════════════════"
echo "📋 Paso 5: Consultar estadísticas"
echo "═══════════════════════════════════════════════════════════"

echo ""
echo "📊 Estadísticas de la API:"
curl -s "$BASE_URL/api/stats" | jq '.'

echo ""
echo "═══════════════════════════════════════════════════════════"
echo "✅ PRUEBAS COMPLETADAS"
echo "═══════════════════════════════════════════════════════════"

echo ""
echo "🎯 Ahora verifica los logs en:"
echo ""
echo "1️⃣  AXIOM (https://app.axiom.co)"
echo "   - Dataset: vise-api-logs"
echo "   - Deberías ver:"
echo "     ✅ 3 registros de clientes (client_registration)"
echo "     ✅ 3 compras procesadas (purchase)"
echo "     ✅ 1 error de validación (validation_error)"
echo "     ✅ Múltiples peticiones HTTP"
echo ""
echo "   Query de ejemplo:"
echo "   ['vise-api-logs']"
echo "   | where _time > ago(5m)"
echo "   | project _time, level, message, event_type"
echo ""
echo "2️⃣  AZURE APPLICATION INSIGHTS (https://portal.azure.com)"
echo "   - Ve a: Application Insights > Logs"
echo "   - Query de ejemplo:"
echo "   requests"
echo "   | where timestamp > ago(5m)"
echo "   | project timestamp, name, resultCode, duration"
echo ""
echo "🚀 ¡Todo listo! Tus logs están siendo enviados a ambas plataformas."
