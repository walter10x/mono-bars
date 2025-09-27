# Script de ayuda para desarrollo Flutter
# Ejecuta: powershell -ExecutionPolicy Bypass -File dev_helper.ps1

Write-Host "🚀 Flutter Project Helper" -ForegroundColor Green
Write-Host "=========================" -ForegroundColor Green
Write-Host ""

# Función para verificar si un comando existe
function Test-Command($cmdname) {
    return [bool](Get-Command -Name $cmdname -ErrorAction SilentlyContinue)
}

# Verificar si Flutter está instalado
Write-Host "🔍 Verificando Flutter..." -ForegroundColor Yellow
if (Test-Command "flutter") {
    Write-Host "✅ Flutter está instalado" -ForegroundColor Green
    flutter --version
    Write-Host ""
    
    Write-Host "🏥 Verificando configuración de Flutter..." -ForegroundColor Yellow
    flutter doctor
    Write-Host ""
    
    # Instalar dependencias
    Write-Host "📦 Instalando dependencias..." -ForegroundColor Yellow
    flutter pub get
    Write-Host ""
    
    # Generar código
    Write-Host "⚙️ Generando código automático..." -ForegroundColor Yellow
    flutter packages pub run build_runner build --delete-conflicting-outputs
    Write-Host ""
    
    # Verificar si hay dispositivos disponibles
    Write-Host "📱 Verificando dispositivos disponibles..." -ForegroundColor Yellow
    flutter devices
    Write-Host ""
    
    Write-Host "🎉 Proyecto listo para ejecutar!" -ForegroundColor Green
    Write-Host "Ejecuta: flutter run" -ForegroundColor Cyan
    
} else {
    Write-Host "❌ Flutter no está instalado" -ForegroundColor Red
    Write-Host ""
    Write-Host "🔧 Instrucciones para instalar Flutter:" -ForegroundColor Yellow
    Write-Host "1. Descarga Flutter desde: https://docs.flutter.dev/get-started/install/windows" -ForegroundColor White
    Write-Host "2. Extrae el archivo en C:\flutter\" -ForegroundColor White
    Write-Host "3. Agrega C:\flutter\bin al PATH del sistema" -ForegroundColor White
    Write-Host "4. Reinicia PowerShell y ejecuta 'flutter doctor'" -ForegroundColor White
    Write-Host ""
    Write-Host "O usando Chocolatey (como administrador):" -ForegroundColor Yellow
    Write-Host "choco install flutter" -ForegroundColor White
}

Write-Host ""
Write-Host "📋 Comandos útiles una vez instalado Flutter:" -ForegroundColor Yellow
Write-Host "• flutter pub get                    # Instalar dependencias" -ForegroundColor White
Write-Host "• flutter run                        # Ejecutar la app" -ForegroundColor White
Write-Host "• flutter run --release              # Ejecutar en modo release" -ForegroundColor White
Write-Host "• flutter build apk                  # Compilar APK para Android" -ForegroundColor White
Write-Host "• flutter build ios                  # Compilar para iOS" -ForegroundColor White
Write-Host "• flutter analyze                    # Analizar código" -ForegroundColor White
Write-Host "• flutter test                       # Ejecutar tests" -ForegroundColor White
Write-Host ""

# Verificar estructura del proyecto
Write-Host "📁 Estructura del proyecto:" -ForegroundColor Yellow
$mainFiles = @(
    "lib\main.dart",
    "pubspec.yaml",
    "lib\config\app_theme.dart",
    "lib\config\app_router.dart",
    "lib\modules\auth\views\login_screen.dart"
)

foreach ($file in $mainFiles) {
    if (Test-Path $file) {
        Write-Host "✅ $file" -ForegroundColor Green
    } else {
        Write-Host "❌ $file" -ForegroundColor Red
    }
}

Write-Host ""
Write-Host "🔧 Configuración del Backend:" -ForegroundColor Yellow
Write-Host "• Asegúrate de que tu backend NestJS esté corriendo" -ForegroundColor White
Write-Host "• URL por defecto: http://localhost:3000/api" -ForegroundColor White
Write-Host "• Cambia la URL en: lib\core\constants\app_constants.dart" -ForegroundColor White
