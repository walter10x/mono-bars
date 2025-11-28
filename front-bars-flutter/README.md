# Front-end Flutter - Gestión de Bares

Aplicación móvil desarrollada en Flutter para la gestión de bares, menús y promociones. Este frontend está diseñado para conectarse con un backend en NestJS siguiendo una arquitectura modular escalable.

## 🏗️ Arquitectura del Proyecto

La aplicación sigue una arquitectura modular que refleja la estructura del backend, organizando el código por dominios de negocio:

```
lib/
├── main.dart                    # Punto de entrada de la aplicación
├── config/                     # Configuración global
│   ├── app_theme.dart          # Temas y estilos
│   └── app_router.dart         # Configuración de rutas
├── core/                       # Utilidades y servicios centrales
│   ├── constants/              # Constantes de la aplicación
│   ├── errors/                 # Manejo de errores
│   ├── network/                # Cliente HTTP (Dio)
│   ├── storage/                # Almacenamiento seguro
│   └── utils/                  # Utilidades y extensiones
├── modules/                    # Módulos por dominio
│   ├── auth/                   # Autenticación y autorización
│   ├── users/                  # Gestión de usuarios
│   ├── bars/                   # Gestión de bares
│   ├── menus/                  # Gestión de menús
│   └── promotions/             # Gestión de promociones
└── shared/                     # Widgets y componentes reutilizables
    ├── widgets/                # Widgets comunes
    └── components/             # Componentes específicos
```

Cada módulo contiene:
- **models/**: DTOs y modelos de datos
- **services/**: Servicios para consumir APIs
- **controllers/**: Lógica de estado con Riverpod
- **views/**: Pantallas y widgets de UI

## 🛠️ Tecnologías Utilizadas

### Core
- **Flutter**: Framework principal para desarrollo móvil
- **Dart**: Lenguaje de programación

### Gestión de Estado
- **Riverpod**: Gestión de estado reactiva y robusta
- **Riverpod Annotation**: Code generation para providers

### Navegación
- **GoRouter**: Navegación declarativa con rutas protegidas

### Networking
- **Dio**: Cliente HTTP para consumir APIs REST
- **Retrofit**: Type-safe HTTP client (code generation)
- **JSON Annotation**: Serialización/deserialización automática

### Almacenamiento
- **Flutter Secure Storage**: Almacenamiento seguro para tokens
- **SharedPreferences**: Preferencias del usuario

### UI/UX
- **Material Design 3**: Diseño moderno y adaptable
- **Cached Network Image**: Manejo optimizado de imágenes
- **Shimmer**: Efectos de carga elegantes

### Utilidades
- **Dartz**: Programación funcional (Either pattern)
- **Equatable**: Comparación de objetos
- **Formz**: Validación de formularios
- **Logger**: Sistema de logging
- **Intl**: Internacionalización

## 🚀 Configuración e Instalación

### Prerrequisitos

1. **Flutter SDK** (>=3.13.0)
2. **Dart SDK** (>=3.1.0)
3. **Android Studio** o **Xcode** (para simuladores)
4. **Backend NestJS** corriendo en el puerto configurado

### Instalación

1. **Clona el repositorio** (si aplicable):
   ```bash
   git clone <url-del-repositorio>
   cd front-bars-flutter
   ```

2. **Instala las dependencias**:
   ```bash
   flutter pub get
   ```

3. **Genera código automático**:
   ```bash
   flutter packages pub run build_runner build --delete-conflicting-outputs
   ```

4. **Configura la URL del backend**:
   Edita el archivo `lib/core/constants/app_constants.dart` y cambia:
   ```dart
   static const String baseUrl = 'http://tu-servidor:3000/api';
   ```

5. **Ejecuta la aplicación**:
   ```bash
   flutter run
   ```

## 📱 Funcionalidades Implementadas

### ✅ Módulo de Autenticación
- **Login**: Inicio de sesión con email/contraseña
- **Register**: Registro de nuevos usuarios con validación
- **JWT Management**: Manejo automático de tokens de acceso y refresh
- **Logout**: Cierre de sesión y limpieza de datos
- **Protected Routes**: Navegación con guards de autenticación
- **Auto Login**: Persistencia de sesión con tokens seguros
- **Forgot Password**: Recuperación de contraseña (estructura preparada)
- **Change Password**: Cambio de contraseña (estructura preparada)

### ✅ Pantalla de Bienvenida (Home/Dashboard)
- **Saludo Dinámico**: Saludo personalizado según la hora del día (Buenos días/tardes/noches)
- **Información del Usuario**: Muestra nombre, email y rol del usuario autenticado
- **Avatar con Iniciales**: Avatar circular con iniciales del nombre del usuario
- **Diseño Moderno**: UI atractiva con gradientes y efectos visuales
- **Cerrar Sesión**: Botón accesible para logout rápido
- **Navegación Fluida**: Transición automática después del login

### ✅ Módulo de Usuarios  
- **CRUD Operations**: Crear, leer, actualizar y eliminar usuarios
- **User Profile**: Gestión del perfil del usuario
- **Role Management**: Sistema de roles (client, owner, admin)

### ✅ Infraestructura Core
- **HTTP Client**: Cliente Dio configurado con interceptores
- **Error Handling**: Manejo robusto de errores de red y autenticación
- **Secure Storage**: Almacenamiento seguro de tokens y datos sensibles
- **State Management**: Riverpod para gestión de estado reactiva
- **Theme System**: Sistema de temas claro/oscuro
- **Navigation**: GoRouter con rutas protegidas
- **Custom Widgets**: Componentes reutilizables

### 🔄 En Desarrollo
- **Módulo Bares**: Gestión completa de bares (modelos creados, backend listo)
- **Módulo Menús**: Gestión de menús y items (modelos creados, backend listo)  
- **Módulo Promociones**: Gestión de ofertas y promociones (modelos creados)
- **Dashboard Avanzado**: Estadísticas y datos en tiempo real

## 🔧 Configuración del Backend

Asegúrate de que tu backend en NestJS tenga los siguientes endpoints:

### Autenticación (`/auth`)
- `POST /auth/login` - Inicio de sesión
- `POST /auth/refresh` - Renovar token
- `POST /auth/logout` - Cerrar sesión
- `GET /auth/me` - Obtener usuario actual
- `GET /auth/verify` - Verificar token
- `POST /auth/forgot-password` - Recuperar contraseña
- `POST /auth/reset-password` - Restablecer contraseña

### Usuarios (`/users`)
- `POST /users/register` - Registrar usuario
- `GET /users` - Listar usuarios (con paginación)
- `GET /users/:id` - Obtener usuario por ID
- `PUT /users/:id` - Actualizar usuario
- `DELETE /users/:id` - Eliminar usuario

## 🧪 Desarrollo y Testing

### Generar Código Automático
```bash
# Generar archivos .g.dart para JSON y Riverpod
flutter packages pub run build_runner build

# Observar cambios en tiempo real
flutter packages pub run build_runner watch
```

### Linting y Análisis
```bash
# Ejecutar análisis de código
flutter analyze

# Formatear código
flutter format .
```

### Testing
```bash
# Ejecutar tests
flutter test

# Ejecutar tests con coverage
flutter test --coverage
```

## 📦 Estructura de Módulos

Cada módulo sigue la misma estructura consistente:

```
modules/nombre_modulo/
├── models/                     # Modelos y DTOs
│   ├── nombre_models.dart     # Modelos principales
│   └── nombre_models.g.dart   # Código generado
├── services/                   # Servicios para API
│   └── nombre_service.dart    # Implementación del servicio
├── controllers/                # Controladores Riverpod
│   ├── nombre_controller.dart # Lógica de estado
│   └── nombre_controller.g.dart # Código generado
└── views/                     # Pantallas y widgets
    ├── nombre_screen.dart     # Pantallas principales
    └── widgets/               # Widgets específicos del módulo
```

## 🔐 Seguridad

- **Tokens JWT**: Manejo seguro con refresh automático
- **Secure Storage**: Datos sensibles encriptados localmente
- **Input Validation**: Validación robusta de formularios
- **Error Handling**: Manejo seguro de errores de red y autenticación

## 🎨 Personalización

### Cambiar Colores del Tema
Edita `lib/config/app_theme.dart`:
```dart
static const Color primaryColor = Color(0xFF2196F3); // Tu color principal
static const Color accentColor = Color(0xFFFF5722);  // Tu color de acento
```

### Agregar Nuevos Módulos
1. Crea la estructura de carpetas siguiendo el patrón existente
2. Implementa los modelos con `@JsonSerializable()`
3. Crea el servicio extendiendo el patrón de Either/Failure
4. Implementa el controlador con Riverpod
5. Diseña las vistas usando los widgets compartidos

## 🚧 Próximos Pasos

1. **Completar pantallas de autenticación**:
   - Pantalla de registro
   - Recuperación de contraseña
   - Cambio de contraseña

2. **Implementar módulos completos**:
   - Servicios y controladores para bars, menus, promotions
   - Pantallas de listado y detalle
   - Funcionalidades CRUD

3. **Mejorar UX**:
   - Animaciones y transiciones
   - Modo offline básico
   - Push notifications

4. **Testing**:
   - Unit tests para servicios
   - Widget tests para componentes
   - Integration tests

## 📝 Notas Importantes

- **URL del Backend**: Recuerda cambiar la URL base en `app_constants.dart`
- **Code Generation**: Ejecuta `build_runner` después de modificar modelos
- **Hot Reload**: Funciona perfectamente para desarrollo rápido
- **Platform Differences**: La app está configurada para Android e iOS

## 🤝 Contribución

1. Sigue la estructura modular establecida
2. Usa los widgets compartidos cuando sea posible
3. Mantén consistencia en el manejo de errores
4. Documenta nuevas funcionalidades
5. Ejecuta tests antes de hacer commits

## 📄 Licencia

[Agregar información de licencia según corresponda]

---

**Desarrollado con ❤️ usando Flutter y Riverpod**
