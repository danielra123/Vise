# Test simple local para ver logs en Axiom

Write-Host "🧪 Test Local - Logs en Axiom" -ForegroundColor Cyan
Write-Host ""
Write-Host "Dataset: vise-api-logs" -ForegroundColor Yellow
Write-Host ""

# Verificar node_modules
if (-not (Test-Path "node_modules")) {
    Write-Host "Instalando dependencias..." -ForegroundColor Yellow
    npm install
}

Write-Host "Iniciando servidor..." -ForegroundColor Cyan
Write-Host ""

# Iniciar servidor en background
$job = Start-Job -ScriptBlock {
    Set-Location $using:PWD
    node app.js
}

Start-Sleep -Seconds 10

Write-Host "Probando conectividad..." -ForegroundColor Cyan
try {
    $response = Invoke-WebRequest -Uri "http://localhost:3000" -TimeoutSec 5
    Write-Host "✅ Servidor corriendo" -ForegroundColor Green
} catch {
    Write-Host "❌ Servidor no responde" -ForegroundColor Red
    Receive-Job -Job $job
    Stop-Job -Job $job
    Remove-Job -Job $job
    exit 1
}

Write-Host ""
Write-Host "Generando logs de prueba..." -ForegroundColor Cyan
Write-Host ""

# Registrar cliente
Write-Host "1. Registrando cliente..." -ForegroundColor Yellow
$cliente = @{
    name = "Test User"
    country = "USA"
    monthlyIncome = 1500
    viseClub = $true
    cardType = "Platinum"
} | ConvertTo-Json

$res1 = Invoke-RestMethod -Uri "http://localhost:3000/client" -Method Post -Body $cliente -ContentType "application/json"
Write-Host "   ✅ Cliente ID: $($res1.clientId)" -ForegroundColor Green

# Hacer compra
Write-Host ""
Write-Host "2. Procesando compra..." -ForegroundColor Yellow
$compra = @{
    clientId = $res1.clientId
    amount = 200
    currency = "USD"
    purchaseDate = (Get-Date).ToString("yyyy-MM-ddTHH:mm:ssZ")
    purchaseCountry = "USA"
} | ConvertTo-Json

$res2 = Invoke-RestMethod -Uri "http://localhost:3000/purchase" -Method Post -Body $compra -ContentType "application/json"
Write-Host "   ✅ Monto final: `$$($res2.purchase.finalAmount)" -ForegroundColor Green

# Error de validación
Write-Host ""
Write-Host "3. Generando error de validación..." -ForegroundColor Yellow
$invalido = @{
    name = "Test Error"
    country = "USA"
    monthlyIncome = 500
    viseClub = $false
    cardType = "Platinum"
} | ConvertTo-Json

try {
    Invoke-RestMethod -Uri "http://localhost:3000/client" -Method Post -Body $invalido -ContentType "application/json" -ErrorAction Stop
} catch {
    Write-Host "   ✅ Error capturado (esperado)" -ForegroundColor Green
}

Write-Host ""
Write-Host "Esperando a que los logs se envíen..." -ForegroundColor Yellow
Start-Sleep -Seconds 5

# Detener servidor
Stop-Job -Job $job
Remove-Job -Job $job

Write-Host ""
Write-Host "═══════════════════════════════════════════════════════════" -ForegroundColor Green
Write-Host "✅ TEST COMPLETADO" -ForegroundColor Green
Write-Host "═══════════════════════════════════════════════════════════" -ForegroundColor Green
Write-Host ""
Write-Host "📊 Ahora ve a Axiom:" -ForegroundColor Cyan
Write-Host ""
Write-Host "1. Abre: https://app.axiom.co" -ForegroundColor Magenta
Write-Host ""
Write-Host "2. Haz clic en: vise-api-logs" -ForegroundColor Yellow
Write-Host ""
Write-Host "3. Query:" -ForegroundColor White
Write-Host ""
Write-Host "   ['vise-api-logs']" -ForegroundColor Gray
Write-Host "   | where _time > ago(5m)" -ForegroundColor Gray
Write-Host "   | where environment == 'development'" -ForegroundColor Gray
Write-Host "   | project _time, level, message, event_type" -ForegroundColor Gray
Write-Host "   | sort by _time desc" -ForegroundColor Gray
Write-Host ""
Write-Host "Deberías ver:" -ForegroundColor Yellow
Write-Host "   • client_registration" -ForegroundColor White
Write-Host "   • purchase" -ForegroundColor White
Write-Host "   • validation_error" -ForegroundColor White
