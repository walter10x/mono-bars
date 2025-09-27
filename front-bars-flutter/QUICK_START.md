# 🚀 Guía Rápida de Inicio

## ❓ **¿Necesito archivo .env?**

**NO** - Flutter no usa archivos `.env` como Node.js. La configuración se maneja en:
- `lib/core/constants/app_constants.dart` (constantes)
- `lib/config/environment.dart` (configuración por ambiente)

## 🔧 **Instalación de Flutter (Una vez)**

1. **Descarga Flutter**: https://docs.flutter.dev/get-started/install/windows
2. **Extrae en**: `C:\flutter\`
3. **Agrega al PATH**: `C:\flutter\bin`
4. **Reinicia terminal**

## ⚡ **Ejecutar el Proyecto (4 comandos)**

```bash
# 1. Instalar dependencias
flutter pub get

# 2. Generar código automático  
flutter packages pub run build_runner build

# 3. Verificar dispositivos disponibles
flutter devices

# 4. Ejecutar la aplicación
flutter run
```

## 🎯 **¿Cómo sé que funciona?**

### ✅ **Proyecto funcional si...**
- `flutter doctor` muestra todo OK
- `flutter analyze` sin errores
- `flutter run` abre la pantalla de login
- Puedes navegar entre pantallas

### 📱 **Lo que verás:**
1. **Pantalla de Login** con formulario funcional
2. **Navegación inferior** tras autenticarse
3. **Manejo de errores** automático
4. **UI moderna** con Material Design 3

## 🔗 **Conexión con Backend**

### 📡 **Configurar URL del Backend:**
Edita `lib/core/constants/app_constants.dart`:
```dart
static const String baseUrl = 'http://localhost:3000/api';
// O cambia por la IP de tu servidor NestJS
```

### 🔑 **Endpoints que necesita tu backend:**
- `POST /auth/login` - Login
- `POST /auth/refresh` - Refresh token
- `GET /auth/me` - Usuario actual
- `POST /users/register` - Registro

## 🏃‍♂️ **Próximo Paso**

1. **Instala Flutter** (solo una vez)
2. **Ejecuta los 4 comandos** de arriba
3. **¡Prueba tu app!** 🎉

---

**💡 Tip**: Si no tienes dispositivo físico, instala Android Studio para crear un emulador Android, o ejecuta `flutter run -d chrome` para probar en el navegador.
