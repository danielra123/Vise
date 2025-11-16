# Script simple para verificar configuración de Axiom en Azure

Write-Host "🔍 Verificando configuración de Axiom en Azure..." -ForegroundColor Cyan
Write-Host ""

# Paso 1: Listar todos los App Services
Write-Host "📋 Paso 1: Buscando App Services..." -ForegroundColor Yellow
$apps = az webapp list --query "[].{Name:name, ResourceGroup:resourceGroup, State:state}" -o json | ConvertFrom-Json

if ($apps.Count -eq 0) {
    Write-Host "❌ No se encontraron App Services" -ForegroundColor Red
    Write-Host "   ¿Ya iniciaste sesión en Azure? Ejecuta: az login" -ForegroundColor Yellow
    exit 1
}

Write-Host "✅ App Services encontrados:" -ForegroundColor Green
foreach ($app in $apps) {
    Write-Host "   • $($app.Name) ($($app.State))" -ForegroundColor Cyan
}

# Paso 2: Buscar vise-api-app
Write-Host ""
Write-Host "📋 Paso 2: Buscando 'vise-api-app'..." -ForegroundColor Yellow
$targetApp = $apps | Where-Object { $_.Name -eq "vise-api-app" }

if (-not $targetApp) {
    Write-Host "❌ No se encontró 'vise-api-app'" -ForegroundColor Red
    Write-Host ""
    Write-Host "App Services disponibles:" -ForegroundColor Yellow
    foreach ($app in $apps) {
        Write-Host "   • $($app.Name)" -ForegroundColor Cyan
    }
    Write-Host ""
    $selectedName = Read-Host "Ingresa el nombre correcto del App Service"
    $targetApp = $apps | Where-Object { $_.Name -eq $selectedName }

    if (-not $targetApp) {
        Write-Host "❌ App Service no encontrado" -ForegroundColor Red
        exit 1
    }
}

$appName = $targetApp.Name
$resourceGroup = $targetApp.ResourceGroup

Write-Host "✅ App Service encontrado:" -ForegroundColor Green
Write-Host "   Nombre: $appName" -ForegroundColor Cyan
Write-Host "   Resource Group: $resourceGroup" -ForegroundColor Cyan
Write-Host "   Estado: $($targetApp.State)" -ForegroundColor Cyan

# Paso 3: Obtener variables de entorno
Write-Host ""
Write-Host "📋 Paso 3: Obteniendo variables de entorno..." -ForegroundColor Yellow

$settings = az webapp config appsettings list --name $appName --resource-group $resourceGroup -o json | ConvertFrom-Json

# Variables necesarias para Axiom
$axiomVars = @{
    "AXIOM_TOKEN" = $null
    "AXIOM_DATASET" = $null
}

Write-Host ""
Write-Host "═══════════════════════════════════════════════════════════" -ForegroundColor Yellow
Write-Host "📊 ESTADO DE VARIABLES DE AXIOM" -ForegroundColor Yellow
Write-Host "═══════════════════════════════════════════════════════════" -ForegroundColor Yellow
Write-Host ""

$allConfigured = $true

foreach ($varName in $axiomVars.Keys) {
    $setting = $settings | Where-Object { $_.name -eq $varName }

    if ($setting) {
        $value = $setting.value
        # Ocultar token parcialmente
        if ($value.Length -gt 20) {
            $displayValue = $value.Substring(0, 15) + "..." + $value.Substring($value.Length - 10)
        } else {
            $displayValue = $value
        }
        Write-Host "✅ $varName = $displayValue" -ForegroundColor Green
        $axiomVars[$varName] = $value
    } else {
        Write-Host "❌ $varName = NO CONFIGURADA" -ForegroundColor Red
        $allConfigured = $false
    }
}

Write-Host ""
Write-Host "═══════════════════════════════════════════════════════════" -ForegroundColor Yellow

# Paso 4: Diagnóstico
Write-Host ""
if ($allConfigured) {
    Write-Host "🎉 ¡Todas las variables de Axiom están configuradas!" -ForegroundColor Green
    Write-Host ""
    Write-Host "📝 Próximos pasos:" -ForegroundColor Cyan
    Write-Host "1. Reinicia el App Service para aplicar cambios:" -ForegroundColor White
    Write-Host "   az webapp restart --name $appName --resource-group $resourceGroup" -ForegroundColor Gray
    Write-Host ""
    Write-Host "2. Espera 1-2 minutos" -ForegroundColor White
    Write-Host ""
    Write-Host "3. Haz una petición de prueba a tu API:" -ForegroundColor White
    Write-Host "   Invoke-WebRequest https://$appName.azurewebsites.net" -ForegroundColor Gray
    Write-Host ""
    Write-Host "4. Ve a Axiom para ver los logs:" -ForegroundColor White
    Write-Host "   https://app.axiom.co" -ForegroundColor Magenta

} else {
    Write-Host "⚠️  Faltan variables de Axiom" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "📝 Para configurarlas, ejecuta:" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "az webapp config appsettings set \\" -ForegroundColor Gray
    Write-Host "  --name $appName \\" -ForegroundColor Gray
    Write-Host "  --resource-group $resourceGroup \\" -ForegroundColor Gray
    Write-Host "  --settings \\" -ForegroundColor Gray

    foreach ($varName in $axiomVars.Keys) {
        if (-not $axiomVars[$varName]) {
            $value = switch ($varName) {
                "AXIOM_TOKEN" { "xaat-c3c5124b-b22a-4172-b701-2075ce260cc8" }
                "AXIOM_DATASET" { "vise-api-logs" }
            }
            Write-Host "    $varName=`"$value`" \\" -ForegroundColor Gray
        }
    }
    Write-Host ""
}

# Paso 5: Verificar logs actuales del App Service
Write-Host ""
Write-Host "═══════════════════════════════════════════════════════════" -ForegroundColor Yellow
Write-Host "📋 LOGS RECIENTES DEL APP SERVICE" -ForegroundColor Yellow
Write-Host "═══════════════════════════════════════════════════════════" -ForegroundColor Yellow
Write-Host ""
Write-Host "Obteniendo últimos logs..." -ForegroundColor Cyan
Write-Host ""

az webapp log tail --name $appName --resource-group $resourceGroup --only-show-errors 2>&1 | Select-Object -First 30
