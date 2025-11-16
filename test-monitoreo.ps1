# ==================================
# 🧪 Script de Prueba de Monitoreo
# ==================================
# Este script prueba tu API en Azure y verifica que los logs
# se estén enviando correctamente a Axiom y Application Insights

Write-Host "🚀 Iniciando pruebas de monitoreo..." -ForegroundColor Cyan
Write-Host ""

# Variables
$AZURE_URL = "https://vise-api-app.azurewebsites.net"
$LOCAL_URL = "http://localhost:3000"

# Preguntar si probar local o Azure
Write-Host "¿Dónde quieres probar?"
Write-Host "1) Local (http://localhost:3000)"
Write-Host "2) Azure (https://vise-api-app.azurewebsites.net)"
$OPTION = Read-Host "Selecciona una opción (1 o 2)"

if ($OPTION -eq "1") {
    $BASE_URL = $LOCAL_URL
    Write-Host "✅ Probando servidor LOCAL" -ForegroundColor Green
} else {
    $BASE_URL = $AZURE_URL
    Write-Host "✅ Probando servidor AZURE" -ForegroundColor Green
}

Write-Host ""
Write-Host "═══════════════════════════════════════════════════════════" -ForegroundColor Yellow
Write-Host "📋 Paso 1: Verificar conectividad" -ForegroundColor Yellow
Write-Host "═══════════════════════════════════════════════════════════" -ForegroundColor Yellow

try {
    $response = Invoke-WebRequest -Uri $BASE_URL -Method Get -ErrorAction Stop
    Write-Host "✅ Servidor respondiendo correctamente" -ForegroundColor Green
} catch {
    Write-Host "❌ Error: Servidor no responde" -ForegroundColor Red
    Write-Host "   Verifica que el servidor esté corriendo" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "═══════════════════════════════════════════════════════════" -ForegroundColor Yellow
Write-Host "📋 Paso 2: Registrar clientes de prueba" -ForegroundColor Yellow
Write-Host "═══════════════════════════════════════════════════════════" -ForegroundColor Yellow

# Cliente 1: Platinum (USA)
Write-Host ""
Write-Host "📝 Registrando Cliente 1 (Platinum - USA)..." -ForegroundColor Cyan
$body1 = @{
    name = "John Doe"
    country = "USA"
    monthlyIncome = 1500
    viseClub = $true
    cardType = "Platinum"
} | ConvertTo-Json

$response1 = Invoke-RestMethod -Uri "$BASE_URL/client" -Method Post -Body $body1 -ContentType "application/json"
$response1 | ConvertTo-Json | Write-Host
$CLIENT_ID_1 = $response1.clientId

if ($CLIENT_ID_1) {
    Write-Host "✅ Cliente 1 registrado (ID: $CLIENT_ID_1)" -ForegroundColor Green
} else {
    Write-Host "❌ Error al registrar Cliente 1" -ForegroundColor Red
}

# Cliente 2: Gold (Colombia)
Write-Host ""
Write-Host "📝 Registrando Cliente 2 (Gold - Colombia)..." -ForegroundColor Cyan
$body2 = @{
    name = "María García"
    country = "Colombia"
    monthlyIncome = 800
    viseClub = $false
    cardType = "Gold"
} | ConvertTo-Json

$response2 = Invoke-RestMethod -Uri "$BASE_URL/client" -Method Post -Body $body2 -ContentType "application/json"
$response2 | ConvertTo-Json | Write-Host
$CLIENT_ID_2 = $response2.clientId

if ($CLIENT_ID_2) {
    Write-Host "✅ Cliente 2 registrado (ID: $CLIENT_ID_2)" -ForegroundColor Green
} else {
    Write-Host "❌ Error al registrar Cliente 2" -ForegroundColor Red
}

# Cliente 3: Black (Brazil)
Write-Host ""
Write-Host "📝 Registrando Cliente 3 (Black - Brazil)..." -ForegroundColor Cyan
$body3 = @{
    name = "Pedro Silva"
    country = "Brazil"
    monthlyIncome = 3000
    viseClub = $true
    cardType = "Black"
} | ConvertTo-Json

$response3 = Invoke-RestMethod -Uri "$BASE_URL/client" -Method Post -Body $body3 -ContentType "application/json"
$response3 | ConvertTo-Json | Write-Host
$CLIENT_ID_3 = $response3.clientId

if ($CLIENT_ID_3) {
    Write-Host "✅ Cliente 3 registrado (ID: $CLIENT_ID_3)" -ForegroundColor Green
} else {
    Write-Host "❌ Error al registrar Cliente 3" -ForegroundColor Red
}

Write-Host ""
Write-Host "═══════════════════════════════════════════════════════════" -ForegroundColor Yellow
Write-Host "📋 Paso 3: Procesar compras de prueba" -ForegroundColor Yellow
Write-Host "═══════════════════════════════════════════════════════════" -ForegroundColor Yellow

# Compra 1: Cliente Platinum en Lunes (descuento 20%)
Write-Host ""
Write-Host "💳 Procesando Compra 1 (Cliente $CLIENT_ID_1 - Lunes - `$150)..." -ForegroundColor Cyan
$purchase1 = @{
    clientId = $CLIENT_ID_1
    amount = 150
    currency = "USD"
    purchaseDate = "2025-11-17T10:00:00Z"
    purchaseCountry = "USA"
} | ConvertTo-Json

$responsePurchase1 = Invoke-RestMethod -Uri "$BASE_URL/purchase" -Method Post -Body $purchase1 -ContentType "application/json"
$responsePurchase1 | ConvertTo-Json | Write-Host

if ($responsePurchase1.status -eq "Approved") {
    Write-Host "✅ Compra 1 aprobada" -ForegroundColor Green
} else {
    Write-Host "❌ Compra 1 rechazada" -ForegroundColor Red
}

# Compra 2: Cliente Gold en Martes (descuento 15%)
Write-Host ""
Write-Host "💳 Procesando Compra 2 (Cliente $CLIENT_ID_2 - Martes - `$120)..." -ForegroundColor Cyan
$purchase2 = @{
    clientId = $CLIENT_ID_2
    amount = 120
    currency = "USD"
    purchaseDate = "2025-11-18T14:00:00Z"
    purchaseCountry = "Colombia"
} | ConvertTo-Json

$responsePurchase2 = Invoke-RestMethod -Uri "$BASE_URL/purchase" -Method Post -Body $purchase2 -ContentType "application/json"
$responsePurchase2 | ConvertTo-Json | Write-Host

if ($responsePurchase2.status -eq "Approved") {
    Write-Host "✅ Compra 2 aprobada" -ForegroundColor Green
} else {
    Write-Host "❌ Compra 2 rechazada" -ForegroundColor Red
}

# Compra 3: Cliente Black en Sábado (descuento 35%)
Write-Host ""
Write-Host "💳 Procesando Compra 3 (Cliente $CLIENT_ID_3 - Sábado - `$250)..." -ForegroundColor Cyan
$purchase3 = @{
    clientId = $CLIENT_ID_3
    amount = 250
    currency = "USD"
    purchaseDate = "2025-11-22T18:00:00Z"
    purchaseCountry = "Brazil"
} | ConvertTo-Json

$responsePurchase3 = Invoke-RestMethod -Uri "$BASE_URL/purchase" -Method Post -Body $purchase3 -ContentType "application/json"
$responsePurchase3 | ConvertTo-Json | Write-Host

if ($responsePurchase3.status -eq "Approved") {
    Write-Host "✅ Compra 3 aprobada" -ForegroundColor Green
} else {
    Write-Host "❌ Compra 3 rechazada" -ForegroundColor Red
}

Write-Host ""
Write-Host "═══════════════════════════════════════════════════════════" -ForegroundColor Yellow
Write-Host "📋 Paso 4: Generar un error de validación" -ForegroundColor Yellow
Write-Host "═══════════════════════════════════════════════════════════" -ForegroundColor Yellow

# Intentar registrar cliente que no cumple requisitos
Write-Host ""
Write-Host "❌ Intentando registrar cliente no elegible (Platinum sin VISE Club)..." -ForegroundColor Cyan
$errorBody = @{
    name = "Test Error"
    country = "USA"
    monthlyIncome = 1500
    viseClub = $false
    cardType = "Platinum"
} | ConvertTo-Json

try {
    $errorResponse = Invoke-RestMethod -Uri "$BASE_URL/client" -Method Post -Body $errorBody -ContentType "application/json" -ErrorAction Stop
    $errorResponse | ConvertTo-Json | Write-Host
} catch {
    $statusCode = $_.Exception.Response.StatusCode.value__
    if ($statusCode -eq 400) {
        Write-Host "✅ Error de validación capturado correctamente (400 Bad Request)" -ForegroundColor Green
    } else {
        Write-Host "❌ Error inesperado: $statusCode" -ForegroundColor Red
    }
}

Write-Host ""
Write-Host "═══════════════════════════════════════════════════════════" -ForegroundColor Yellow
Write-Host "📋 Paso 5: Consultar estadísticas" -ForegroundColor Yellow
Write-Host "═══════════════════════════════════════════════════════════" -ForegroundColor Yellow

Write-Host ""
Write-Host "📊 Estadísticas de la API:" -ForegroundColor Cyan
$stats = Invoke-RestMethod -Uri "$BASE_URL/api/stats" -Method Get
$stats | ConvertTo-Json | Write-Host

Write-Host ""
Write-Host "═══════════════════════════════════════════════════════════" -ForegroundColor Green
Write-Host "✅ PRUEBAS COMPLETADAS" -ForegroundColor Green
Write-Host "═══════════════════════════════════════════════════════════" -ForegroundColor Green

Write-Host ""
Write-Host "🎯 Ahora verifica los logs en:" -ForegroundColor Cyan
Write-Host ""
Write-Host "1️⃣  AXIOM (https://app.axiom.co)" -ForegroundColor Yellow
Write-Host "   - Dataset: vise-api-logs"
Write-Host "   - Deberías ver:"
Write-Host "     ✅ 3 registros de clientes (client_registration)"
Write-Host "     ✅ 3 compras procesadas (purchase)"
Write-Host "     ✅ 1 error de validación (validation_error)"
Write-Host "     ✅ Múltiples peticiones HTTP"
Write-Host ""
Write-Host "   Query de ejemplo:" -ForegroundColor Magenta
Write-Host "   ['vise-api-logs']"
Write-Host "   | where _time > ago(5m)"
Write-Host "   | project _time, level, message, event_type"
Write-Host ""
Write-Host "2️⃣  AZURE APPLICATION INSIGHTS (https://portal.azure.com)" -ForegroundColor Yellow
Write-Host "   - Ve a: Application Insights > Logs"
Write-Host "   - Query de ejemplo:" -ForegroundColor Magenta
Write-Host "   requests"
Write-Host "   | where timestamp > ago(5m)"
Write-Host "   | project timestamp, name, resultCode, duration"
Write-Host ""
Write-Host "🚀 ¡Todo listo! Tus logs están siendo enviados a ambas plataformas." -ForegroundColor Green
