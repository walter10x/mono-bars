# 📱 CÓMO EJECUTAR LA APLICACIÓN FLUTTER

## 🚀 COMANDOS BÁSICOS

### Ver dispositivos disponibles
```bash
flutter devices
```

### Ejecutar la aplicación
```bash
# En cualquier dispositivo Android disponible
flutter run -d android

# En un emulador específico  
flutter run -d emulator-5554

# En Chrome (desarrollo web)
flutter run -d chrome

# En Windows (aplicación de escritorio)
flutter run -d windows
```

## ⚡ COMANDOS DURANTE LA EJECUCIÓN

Una vez que la app está corriendo, puedes usar estos atajos en la terminal:

- **`r`** → Hot reload (cambios instantáneos sin perder estado)
- **`R`** → Hot restart (reinicio completo de la app)
- **`q`** → Cerrar aplicación
- **`h`** → Ver ayuda completa con todos los comandos
- **`c`** → Limpiar la consola
- **`d`** → Desconectar (la app sigue corriendo)

## 🛠️ COMANDOS DE MANTENIMIENTO

### Si hay problemas o errores
```bash
# Limpiar proyecto completamente
flutter clean

# Reinstalar dependencias
flutter pub get

# Regenerar código automático (build_runner)
flutter packages pub run build_runner build --delete-conflicting-outputs
```

### Verificar instalación de Flutter
```bash
# Ver versión instalada
flutter --version

# Diagnosticar problemas
flutter doctor

# Ver información detallada del doctor
flutter doctor -v
```

## 📋 PRERREQUISITOS

### ✅ Para Android
1. **Android Studio** instalado con SDK
2. **Emulador Android** creado y ejecutándose
3. O **dispositivo físico** con modo desarrollador activado

### ✅ Para Web  
1. **Google Chrome** instalado
2. **Extensión de Flutter** habilitada

### ✅ Para Windows
1. **Visual Studio 2022** con herramientas de C++ (opcional)
2. **Windows 10 SDK** (se instala automáticamente)

## 🔍 VERIFICAR QUE TODO FUNCIONA

### 1. Verificar Flutter
```bash
flutter doctor
```
Debe mostrar ✓ en la mayoría de elementos.

### 2. Verificar dispositivos
```bash
flutter devices
```
Debe mostrar al menos un dispositivo disponible.

### 3. Ejecutar la aplicación
```bash
flutter run -d android
```

## 📁 ESTRUCTURA DEL PROYECTO

```
front-bars-flutter/
├── lib/
│   ├── main.dart              # Punto de entrada
│   ├── core/                  # Configuraciones principales
│   ├── modules/               # Módulos de funcionalidad
│   └── shared/                # Componentes reutilizables
├── android/                   # Configuración Android
├── web/                       # Configuración Web  
├── windows/                   # Configuración Windows
└── pubspec.yaml              # Dependencias del proyecto
```

## 🐛 SOLUCIÓN DE PROBLEMAS COMUNES

### Error: "No devices found"
```bash
# Verificar que Android Studio esté abierto
# Iniciar un emulador desde AVD Manager
# O conectar dispositivo físico con USB debugging
```

### Error: "Build failed"
```bash
flutter clean
flutter pub get
flutter run -d android
```

### Error: "Connection refused" (Backend)
- La app funciona, pero no puede conectar al servidor
- Esto es normal sin backend corriendo
- La UI y navegación funcionan perfectamente

## 🎯 PRÓXIMOS PASOS

1. ✅ **App funcionando** en emulador Android
2. 🔜 **Configurar backend** NestJS en `localhost:3000`
3. 🔜 **Agregar rutas faltantes** (`/forgot-password`, `/register`)
4. 🔜 **Desarrollar más pantallas** según necesidades

---

## 📞 COMANDOS DE REFERENCIA RÁPIDA

```bash
# Lo más usado para desarrollo diario:
flutter devices                    # Ver dispositivos
flutter run -d android            # Ejecutar en Android  
flutter run -d chrome             # Ejecutar en web
flutter clean && flutter pub get  # Limpiar si hay problemas
```

¡Tu aplicación Flutter está lista para desarrollo! 🚀
