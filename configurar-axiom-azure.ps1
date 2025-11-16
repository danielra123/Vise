# Script simple para configurar Axiom en Azure App Service

Write-Host "🔧 Configurando Axiom en Azure App Service..." -ForegroundColor Cyan
Write-Host ""

$AXIOM_TOKEN = "xaat-4b39648e-d2fb-45eb-aa4d-68ce3bbda173"
$AXIOM_DATASET = "vise-api-logs"
$APP_NAME = "vise-api-app"

Write-Host "📋 Configuración:" -ForegroundColor Yellow
Write-Host "   Token: xaat-4b39...173" -ForegroundColor Gray
Write-Host "   Dataset: $AXIOM_DATASET" -ForegroundColor Gray
Write-Host "   App Service: $APP_NAME" -ForegroundColor Gray
Write-Host ""

# Login a Azure
Write-Host "Iniciando sesión en Azure..." -ForegroundColor Cyan
az login

Write-Host ""
Write-Host "Buscando App Service..." -ForegroundColor Cyan
$apps = az webapp list --query "[?name=='$APP_NAME'].{Name:name, ResourceGroup:resourceGroup}" -o json | ConvertFrom-Json

if (-not $apps -or $apps.Count -eq 0) {
    Write-Host "❌ No se encontró el App Service '$APP_NAME'" -ForegroundColor Red
    exit 1
}

$resourceGroup = $apps[0].ResourceGroup
Write-Host "✅ App Service encontrado en: $resourceGroup" -ForegroundColor Green

Write-Host ""
Write-Host "Configurando variables..." -ForegroundColor Cyan

az webapp config appsettings set `
  --name $APP_NAME `
  --resource-group $resourceGroup `
  --settings `
    AXIOM_TOKEN="$AXIOM_TOKEN" `
    AXIOM_DATASET="$AXIOM_DATASET" `
  --output table

Write-Host ""
Write-Host "✅ Variables configuradas" -ForegroundColor Green

Write-Host ""
Write-Host "Reiniciando App Service..." -ForegroundColor Cyan
az webapp restart --name $APP_NAME --resource-group $resourceGroup --output none

Write-Host "✅ App Service reiniciado" -ForegroundColor Green

Write-Host ""
Write-Host "⏳ Esperando 30 segundos..." -ForegroundColor Yellow
Start-Sleep -Seconds 30

Write-Host ""
Write-Host "═══════════════════════════════════════════════════════════" -ForegroundColor Green
Write-Host "✅ CONFIGURACIÓN COMPLETADA" -ForegroundColor Green
Write-Host "═══════════════════════════════════════════════════════════" -ForegroundColor Green
Write-Host ""
Write-Host "📝 Próximos pasos:" -ForegroundColor Cyan
Write-Host ""
Write-Host "1. Genera tráfico en tu API:" -ForegroundColor White
Write-Host "   Invoke-WebRequest https://vise-api-app.azurewebsites.net" -ForegroundColor Gray
Write-Host ""
Write-Host "2. Ve a Axiom:" -ForegroundColor White
Write-Host "   https://app.axiom.co" -ForegroundColor Magenta
Write-Host ""
Write-Host "3. Haz clic en dataset:" -ForegroundColor White
Write-Host "   vise-api-logs" -ForegroundColor Yellow
Write-Host ""
Write-Host "4. Ejecuta esta query:" -ForegroundColor White
Write-Host "   ['vise-api-logs']" -ForegroundColor Gray
Write-Host "   | where _time > ago(10m)" -ForegroundColor Gray
Write-Host "   | where environment == 'production'" -ForegroundColor Gray
Write-Host "   | project _time, level, message, event_type, method, url" -ForegroundColor Gray
Write-Host "   | sort by _time desc" -ForegroundColor Gray
