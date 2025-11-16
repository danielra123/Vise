# Script para verificar las variables de entorno en Azure App Service

Write-Host "🔍 Verificando variables de entorno en Azure..." -ForegroundColor Cyan
Write-Host ""

# Verificar si Azure CLI está instalado
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
Write-Host "📋 Obteniendo Resource Group de vise-api-app" -ForegroundColor Yellow
Write-Host "═══════════════════════════════════════════════════════════" -ForegroundColor Yellow

$appInfo = az webapp show --name vise-api-app --query "{ResourceGroup:resourceGroup, State:state, DefaultHostName:defaultHostName}" -o json | ConvertFrom-Json

if (-not $appInfo) {
    Write-Host "❌ No se encontró el App Service 'vise-api-app'" -ForegroundColor Red
    Write-Host "   Verifica que el nombre sea correcto" -ForegroundColor Yellow
    exit 1
}

$resourceGroup = $appInfo.ResourceGroup
Write-Host "✅ App Service encontrado" -ForegroundColor Green
Write-Host "   Resource Group: $resourceGroup" -ForegroundColor Gray
Write-Host "   Estado: $($appInfo.State)" -ForegroundColor $(if ($appInfo.State -eq "Running") { "Green" } else { "Yellow" })
Write-Host "   URL: https://$($appInfo.DefaultHostName)" -ForegroundColor Magenta

Write-Host ""
Write-Host "═══════════════════════════════════════════════════════════" -ForegroundColor Yellow
Write-Host "🔐 Variables de Entorno Configuradas" -ForegroundColor Yellow
Write-Host "═══════════════════════════════════════════════════════════" -ForegroundColor Yellow

$settings = az webapp config appsettings list --name vise-api-app --resource-group $resourceGroup -o json | ConvertFrom-Json

# Variables que necesitamos
$requiredVars = @(
    "AXIOM_TOKEN",
    "AXIOM_DATASET",
    "APPLICATIONINSIGHTS_CONNECTION_STRING",
    "NODE_ENV",
    "PORT"
)

Write-Host ""
foreach ($varName in $requiredVars) {
    $setting = $settings | Where-Object { $_.name -eq $varName }

    if ($setting) {
        $value = $setting.value
        # Ocultar parcialmente valores sensibles
        if ($varName -like "*TOKEN*" -or $varName -like "*KEY*" -or $varName -like "*STRING*") {
            if ($value.Length -gt 20) {
                $value = $value.Substring(0, 10) + "..." + $value.Substring($value.Length - 10)
            }
        }
        Write-Host "✅ $varName = $value" -ForegroundColor Green
    } else {
        Write-Host "❌ $varName = NO CONFIGURADA" -ForegroundColor Red
    }
}

Write-Host ""
Write-Host "═══════════════════════════════════════════════════════════" -ForegroundColor Yellow
Write-Host "📝 Todas las Variables de Entorno" -ForegroundColor Yellow
Write-Host "═══════════════════════════════════════════════════════════" -ForegroundColor Yellow
Write-Host ""

foreach ($setting in $settings) {
    Write-Host "$($setting.name)" -ForegroundColor Cyan -NoNewline
    Write-Host " = " -NoNewline

    # Ocultar valores sensibles
    $value = $setting.value
    if ($setting.name -like "*TOKEN*" -or $setting.name -like "*KEY*" -or $setting.name -like "*PASSWORD*" -or $setting.name -like "*SECRET*" -or $setting.name -like "*STRING*") {
        if ($value.Length -gt 20) {
            $value = $value.Substring(0, 10) + "..." + $value.Substring($value.Length - 10)
        }
    }

    Write-Host "$value" -ForegroundColor Gray
}

Write-Host ""
Write-Host "═══════════════════════════════════════════════════════════" -ForegroundColor Green
Write-Host "✅ Verificación completada" -ForegroundColor Green
Write-Host "═══════════════════════════════════════════════════════════" -ForegroundColor Green
Write-Host ""

# Verificar qué falta
$missingVars = @()
foreach ($varName in $requiredVars) {
    $setting = $settings | Where-Object { $_.name -eq $varName }
    if (-not $setting) {
        $missingVars += $varName
    }
}

if ($missingVars.Count -gt 0) {
    Write-Host "⚠️  Faltan las siguientes variables:" -ForegroundColor Yellow
    foreach ($var in $missingVars) {
        Write-Host "   - $var" -ForegroundColor Red
    }
    Write-Host ""
    Write-Host "Para agregarlas, ejecuta:" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "az webapp config appsettings set \\" -ForegroundColor Gray
    Write-Host "  --name vise-api-app \\" -ForegroundColor Gray
    Write-Host "  --resource-group $resourceGroup \\" -ForegroundColor Gray
    Write-Host "  --settings \\" -ForegroundColor Gray

    foreach ($var in $missingVars) {
        $value = switch ($var) {
            "AXIOM_TOKEN" { "xaat-c3c5124b-b22a-4172-b701-2075ce260cc8" }
            "AXIOM_DATASET" { "vise-api-logs" }
            "NODE_ENV" { "production" }
            "PORT" { "3000" }
            default { "<tu-valor>" }
        }
        Write-Host "    $var=`"$value`" \\" -ForegroundColor Gray
    }
    Write-Host ""
} else {
    Write-Host "🎉 ¡Todas las variables necesarias están configuradas!" -ForegroundColor Green
}
