# Script para generar tráfico y verificar logs en Axiom

$BASE_URL = "https://vise-api-app.azurewebsites.net"

Write-Host "🧪 Generando tráfico de prueba en Azure..." -ForegroundColor Cyan
Write-Host ""
Write-Host "URL: $BASE_URL" -ForegroundColor Gray
Write-Host ""

# Test 1: Health check
Write-Host "1️⃣ Test de conectividad..." -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri $BASE_URL -Method Get -TimeoutSec 15
    Write-Host "   ✅ Servidor respondiendo - Status: $($response.StatusCode)" -ForegroundColor Green
} catch {
    Write-Host "   ❌ Error: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "   ⚠️  El servidor puede estar iniciando. Espera 30 segundos y vuelve a ejecutar" -ForegroundColor Yellow
    exit 1
}

Write-Host ""
Write-Host "2️⃣ Registrando cliente de prueba..." -ForegroundColor Yellow

$cliente = @{
    name = "Test User - $(Get-Date -Format 'HH:mm:ss')"
    country = "USA"
    monthlyIncome = 1500
    viseClub = $true
    cardType = "Platinum"
} | ConvertTo-Json

try {
    $response = Invoke-RestMethod -Uri "$BASE_URL/client" -Method Post -Body $cliente -ContentType "application/json"
    Write-Host "   ✅ Cliente registrado:" -ForegroundColor Green
    Write-Host "      ID: $($response.clientId)" -ForegroundColor Cyan
    Write-Host "      Nombre: $($response.name)" -ForegroundColor Cyan
    Write-Host "      Tarjeta: $($response.cardType)" -ForegroundColor Cyan
    $clientId = $response.clientId
} catch {
    Write-Host "   ❌ Error: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "3️⃣ Procesando compra de prueba..." -ForegroundColor Yellow

$compra = @{
    clientId = $clientId
    amount = 150
    currency = "USD"
    purchaseDate = (Get-Date).ToString("yyyy-MM-ddTHH:mm:ssZ")
    purchaseCountry = "USA"
} | ConvertTo-Json

try {
    $response = Invoke-RestMethod -Uri "$BASE_URL/purchase" -Method Post -Body $compra -ContentType "application/json"
    Write-Host "   ✅ Compra procesada:" -ForegroundColor Green
    Write-Host "      Monto original: `$$($response.purchase.originalAmount)" -ForegroundColor Cyan
    Write-Host "      Descuento: `$$($response.purchase.discountApplied)" -ForegroundColor Cyan
    Write-Host "      Monto final: `$$($response.purchase.finalAmount)" -ForegroundColor Cyan
    Write-Host "      Beneficio: $($response.purchase.benefit)" -ForegroundColor Cyan
} catch {
    Write-Host "   ❌ Error: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host ""
Write-Host "4️⃣ Generando un error de validación..." -ForegroundColor Yellow

$clienteInvalido = @{
    name = "Test Error"
    country = "USA"
    monthlyIncome = 1500
    viseClub = $false
    cardType = "Platinum"
} | ConvertTo-Json

try {
    $response = Invoke-RestMethod -Uri "$BASE_URL/client" -Method Post -Body $clienteInvalido -ContentType "application/json" -ErrorAction Stop
} catch {
    Write-Host "   ✅ Error capturado correctamente (esperado)" -ForegroundColor Green
}

Write-Host ""
Write-Host "═══════════════════════════════════════════════════════════" -ForegroundColor Green
Write-Host "✅ PRUEBAS COMPLETADAS" -ForegroundColor Green
Write-Host "═══════════════════════════════════════════════════════════" -ForegroundColor Green
Write-Host ""
Write-Host "📊 Ahora ve a Axiom para ver los logs:" -ForegroundColor Cyan
Write-Host ""
Write-Host "1. Abre: https://app.axiom.co" -ForegroundColor Magenta
Write-Host "2. Haz clic en tu dataset: 'vise-api-axiom'" -ForegroundColor White
Write-Host "3. Ejecuta esta query:" -ForegroundColor White
Write-Host ""
Write-Host "   ['vise-api-axiom']" -ForegroundColor Gray
Write-Host "   | where _time > ago(5m)" -ForegroundColor Gray
Write-Host "   | project _time, level, message, event_type, method, url" -ForegroundColor Gray
Write-Host "   | sort by _time desc" -ForegroundColor Gray
Write-Host ""
Write-Host "Deberías ver:" -ForegroundColor Yellow
Write-Host "   • Registro de cliente (event_type: client_registration)" -ForegroundColor White
Write-Host "   • Compra procesada (event_type: purchase)" -ForegroundColor White
Write-Host "   • Error de validación (event_type: validation_error)" -ForegroundColor White
Write-Host "   • Peticiones HTTP (method: POST, GET)" -ForegroundColor White
Write-Host ""
Write-Host "⏰ Nota: Los logs pueden tardar 10-30 segundos en aparecer" -ForegroundColor Yellow
