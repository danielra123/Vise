# Script para probar OpenTelemetry + Axiom

Write-Host "╔════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║   🧪 Test de OpenTelemetry + Axiom + Logs                 ║" -ForegroundColor Cyan
Write-Host "╚════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
Write-Host ""

Write-Host "📋 Configuración actual:" -ForegroundColor Yellow
Write-Host "   Dataset: vise-api-axiom" -ForegroundColor Gray
Write-Host "   Token: xaat-4b39...173 (oculto)" -ForegroundColor Gray
Write-Host ""

# Verificar que node_modules existan
if (-not (Test-Path "node_modules")) {
    Write-Host "⚠️  node_modules no encontrado. Instalando dependencias..." -ForegroundColor Yellow
    npm install
}

Write-Host "═══════════════════════════════════════════════════════════" -ForegroundColor Yellow
Write-Host "🚀 Iniciando servidor..." -ForegroundColor Yellow
Write-Host "═══════════════════════════════════════════════════════════" -ForegroundColor Yellow
Write-Host ""
Write-Host "Busca estos mensajes en la consola:" -ForegroundColor Cyan
Write-Host "  ✅ OpenTelemetry iniciado y enviando trazas a Axiom" -ForegroundColor Gray
Write-Host "  ✅ Axiom Logger conectado correctamente" -ForegroundColor Gray
Write-Host "  ✅ Application Insights conectado correctamente" -ForegroundColor Gray
Write-Host ""

# Iniciar el servidor en background
$job = Start-Job -ScriptBlock {
    Set-Location $using:PWD
    node app.js
}

Write-Host "⏳ Esperando que el servidor inicie (10 segundos)..." -ForegroundColor Cyan
Start-Sleep -Seconds 10

# Obtener los logs del job
$logs = Receive-Job -Job $job

Write-Host ""
Write-Host "═══════════════════════════════════════════════════════════" -ForegroundColor Green
Write-Host "📋 Logs del servidor:" -ForegroundColor Green
Write-Host "═══════════════════════════════════════════════════════════" -ForegroundColor Green
Write-Host $logs
Write-Host ""

# Verificar que el servidor esté corriendo
Write-Host "═══════════════════════════════════════════════════════════" -ForegroundColor Yellow
Write-Host "🔍 Verificando conectividad..." -ForegroundColor Yellow
Write-Host "═══════════════════════════════════════════════════════════" -ForegroundColor Yellow

try {
    $response = Invoke-WebRequest -Uri "http://localhost:3000" -Method Get -TimeoutSec 5
    Write-Host "✅ Servidor respondiendo correctamente" -ForegroundColor Green
} catch {
    Write-Host "❌ Error: Servidor no responde" -ForegroundColor Red
    Write-Host "   Revisa los logs arriba para ver el error" -ForegroundColor Yellow
    Stop-Job -Job $job
    Remove-Job -Job $job
    exit 1
}

Write-Host ""
Write-Host "═══════════════════════════════════════════════════════════" -ForegroundColor Yellow
Write-Host "🧪 Ejecutando pruebas de API..." -ForegroundColor Yellow
Write-Host "═══════════════════════════════════════════════════════════" -ForegroundColor Yellow
Write-Host ""

# Test 1: Registrar cliente
Write-Host "1️⃣ Registrando cliente..." -ForegroundColor Cyan
$cliente = @{
    name = "Test OpenTelemetry"
    country = "USA"
    monthlyIncome = 1500
    viseClub = $true
    cardType = "Platinum"
} | ConvertTo-Json

$response = Invoke-RestMethod -Uri "http://localhost:3000/client" -Method Post -Body $cliente -ContentType "application/json"
Write-Host "   ✅ Cliente ID: $($response.clientId)" -ForegroundColor Green

# Test 2: Hacer compra
Write-Host ""
Write-Host "2️⃣ Procesando compra..." -ForegroundColor Cyan
$compra = @{
    clientId = $response.clientId
    amount = 200
    currency = "USD"
    purchaseDate = (Get-Date).ToString("yyyy-MM-ddTHH:mm:ssZ")
    purchaseCountry = "USA"
} | ConvertTo-Json

$purchaseResponse = Invoke-RestMethod -Uri "http://localhost:3000/purchase" -Method Post -Body $compra -ContentType "application/json"
Write-Host "   ✅ Monto final: `$$($purchaseResponse.purchase.finalAmount)" -ForegroundColor Green
Write-Host "   ✅ Beneficio: $($purchaseResponse.purchase.benefit)" -ForegroundColor Green

# Test 3: Obtener estadísticas
Write-Host ""
Write-Host "3️⃣ Obteniendo estadísticas..." -ForegroundColor Cyan
$stats = Invoke-RestMethod -Uri "http://localhost:3000/api/stats" -Method Get
Write-Host "   ✅ Total requests: $($stats.totalRequests)" -ForegroundColor Green

Write-Host ""
Write-Host "⏳ Esperando 5 segundos para que los datos se envíen..." -ForegroundColor Yellow
Start-Sleep -Seconds 5

# Detener el servidor
Write-Host ""
Write-Host "🛑 Deteniendo servidor..." -ForegroundColor Yellow
Stop-Job -Job $job
Remove-Job -Job $job

Write-Host ""
Write-Host "═══════════════════════════════════════════════════════════" -ForegroundColor Green
Write-Host "✅ PRUEBAS COMPLETADAS" -ForegroundColor Green
Write-Host "═══════════════════════════════════════════════════════════" -ForegroundColor Green
Write-Host ""

Write-Host "📊 Ahora verifica en Axiom:" -ForegroundColor Cyan
Write-Host ""
Write-Host "1. Abre: https://app.axiom.co" -ForegroundColor Magenta
Write-Host ""
Write-Host "2. Haz clic en dataset: vise-api-axiom" -ForegroundColor White
Write-Host ""
Write-Host "3. Deberías ver DOS tipos de datos:" -ForegroundColor Yellow
Write-Host ""
Write-Host "   A) LOGS (de axiom-logger.js):" -ForegroundColor Cyan
Write-Host "      ['vise-api-axiom']" -ForegroundColor Gray
Write-Host "      | where level != ''" -ForegroundColor Gray
Write-Host "      | project _time, level, message, event_type" -ForegroundColor Gray
Write-Host ""
Write-Host "   B) TRAZAS OpenTelemetry (de tracing.js):" -ForegroundColor Cyan
Write-Host "      ['vise-api-axiom']" -ForegroundColor Gray
Write-Host "      | where ['span.kind'] != ''" -ForegroundColor Gray
Write-Host "      | project _time, ['span.name'], ['span.kind'], duration" -ForegroundColor Gray
Write-Host ""
Write-Host "⏰ Nota: Los datos pueden tardar 10-60 segundos en aparecer" -ForegroundColor Yellow
Write-Host ""
Write-Host "🎉 ¡Listo! Ahora tienes:" -ForegroundColor Green
Write-Host "   ✅ Logs estructurados en Axiom" -ForegroundColor White
Write-Host "   ✅ Trazas OpenTelemetry en Axiom" -ForegroundColor White
Write-Host "   ✅ Telemetría en Azure Application Insights" -ForegroundColor White
