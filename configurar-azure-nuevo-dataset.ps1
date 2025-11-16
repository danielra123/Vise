# Script para configurar el nuevo dataset en Azure App Service

Write-Host "🔧 Configurando nuevo dataset de Axiom en Azure..." -ForegroundColor Cyan
Write-Host ""

$AXIOM_TOKEN = "xaat-4b39648e-d2fb-45eb-aa4d-68ce3bbda173"
$AXIOM_DATASET = "vise-api-axiom"
$APP_NAME = "vise-api-app"

Write-Host "📋 Configuración a aplicar:" -ForegroundColor Yellow
Write-Host "   App Service: $APP_NAME" -ForegroundColor Gray
Write-Host "   Dataset: $AXIOM_DATASET" -ForegroundColor Gray
Write-Host "   Token: xaat-4b39...173 (oculto)" -ForegroundColor Gray
Write-Host ""

# Verificar Azure CLI
try {
    az --version | Out-Null
    Write-Host "✅ Azure CLI instalado" -ForegroundColor Green
} catch {
    Write-Host "❌ Azure CLI no está instalado" -ForegroundColor Red
    Write-Host "   Instálalo desde: https://aka.ms/installazurecliwindows" -ForegroundColor Yellow
    exit 1
}

Write-Host ""
Write-Host "Iniciando sesión en Azure..." -ForegroundColor Cyan
az login

Write-Host ""
Write-Host "═══════════════════════════════════════════════════════════" -ForegroundColor Yellow
Write-Host "🔍 Buscando App Service..." -ForegroundColor Yellow
Write-Host "═══════════════════════════════════════════════════════════" -ForegroundColor Yellow

$apps = az webapp list --query "[].{Name:name, ResourceGroup:resourceGroup}" -o json | ConvertFrom-Json
$targetApp = $apps | Where-Object { $_.Name -eq $APP_NAME }

if (-not $targetApp) {
    Write-Host "❌ No se encontró el App Service '$APP_NAME'" -ForegroundColor Red
    Write-Host ""
    Write-Host "App Services disponibles:" -ForegroundColor Yellow
    foreach ($app in $apps) {
        Write-Host "   • $($app.Name)" -ForegroundColor Cyan
    }
    exit 1
}

$resourceGroup = $targetApp.ResourceGroup
Write-Host "✅ App Service encontrado" -ForegroundColor Green
Write-Host "   Resource Group: $resourceGroup" -ForegroundColor Cyan

Write-Host ""
Write-Host "═══════════════════════════════════════════════════════════" -ForegroundColor Yellow
Write-Host "⚙️  Configurando variables de entorno..." -ForegroundColor Yellow
Write-Host "═══════════════════════════════════════════════════════════" -ForegroundColor Yellow
Write-Host ""

# Configurar variables
Write-Host "Actualizando AXIOM_TOKEN y AXIOM_DATASET..." -ForegroundColor Cyan

az webapp config appsettings set `
  --name $APP_NAME `
  --resource-group $resourceGroup `
  --settings `
    "AXIOM_TOKEN=$AXIOM_TOKEN" `
    "AXIOM_DATASET=$AXIOM_DATASET" `
  --output none

if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ Variables actualizadas correctamente" -ForegroundColor Green
} else {
    Write-Host "❌ Error al actualizar variables" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "═══════════════════════════════════════════════════════════" -ForegroundColor Yellow
Write-Host "🔄 Reiniciando App Service..." -ForegroundColor Yellow
Write-Host "═══════════════════════════════════════════════════════════" -ForegroundColor Yellow
Write-Host ""

az webapp restart --name $APP_NAME --resource-group $resourceGroup --output none

if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ App Service reiniciado" -ForegroundColor Green
} else {
    Write-Host "❌ Error al reiniciar" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "⏳ Esperando 30 segundos a que el servicio inicie..." -ForegroundColor Cyan
Start-Sleep -Seconds 30

Write-Host ""
Write-Host "═══════════════════════════════════════════════════════════" -ForegroundColor Yellow
Write-Host "🧪 Probando conectividad..." -ForegroundColor Yellow
Write-Host "═══════════════════════════════════════════════════════════" -ForegroundColor Yellow

try {
    $response = Invoke-WebRequest -Uri "https://$APP_NAME.azurewebsites.net" -Method Get -TimeoutSec 15
    Write-Host "✅ Servidor respondiendo - Status: $($response.StatusCode)" -ForegroundColor Green
} catch {
    Write-Host "⚠️  Servidor aún iniciando o hay un error" -ForegroundColor Yellow
    Write-Host "   Puedes verificar los logs con:" -ForegroundColor Cyan
    Write-Host "   az webapp log tail --name $APP_NAME --resource-group $resourceGroup" -ForegroundColor Gray
}

Write-Host ""
Write-Host "═══════════════════════════════════════════════════════════" -ForegroundColor Green
Write-Host "✅ CONFIGURACIÓN COMPLETADA" -ForegroundColor Green
Write-Host "═══════════════════════════════════════════════════════════" -ForegroundColor Green
Write-Host ""

Write-Host "📝 Próximos pasos:" -ForegroundColor Cyan
Write-Host ""
Write-Host "1. Ejecuta el script de prueba:" -ForegroundColor White
Write-Host "   .\probar-axiom.ps1" -ForegroundColor Gray
Write-Host ""
Write-Host "2. Ve a Axiom para ver los logs:" -ForegroundColor White
Write-Host "   https://app.axiom.co" -ForegroundColor Magenta
Write-Host ""
Write-Host "3. Dataset a buscar:" -ForegroundColor White
Write-Host "   vise-api-axiom" -ForegroundColor Yellow
Write-Host ""
Write-Host "4. Query de ejemplo:" -ForegroundColor White
Write-Host "   ['vise-api-axiom']" -ForegroundColor Gray
Write-Host "   | where _time > ago(10m)" -ForegroundColor Gray
Write-Host "   | project _time, level, message, ['span.name']" -ForegroundColor Gray
Write-Host "   | sort by _time desc" -ForegroundColor Gray
