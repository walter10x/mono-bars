# 🍻 Mono-Bars - Plataforma de Gestión de Bares

**Versión**: 1.0.0  
**Estado**: En Desarrollo Activo

Plataforma full-stack para la gestión y descubrimiento de bares, menús y promociones. Conecta propietarios de bares con clientes ofreciendo una experiencia moderna y completa.

---

## 📋 Tabla de Contenidos

- [Descripción General](#-descripción-general)
- [Tecnologías](#-tecnologías)
- [Estado Actual](#-estado-actual)
- [Instalación y Ejecución](#-instalación-y-ejecución)
- [Estructura del Proyecto](#-estructura-del-proyecto)
- [Funcionalidades](#-funcionalidades)
- [Próximos Pasos](#-próximos-pasos)
- [Contribución](#-contribución)

---

## 🎯 Descripción General

Mono-Bars es una aplicación completa que permite:

- **Para Clientes**: Descubrir bares, ver menús, aprovechar promociones y gestionar favoritos
- **Para Propietarios**: Administrar sus establecimientos, actualizar menús y crear promociones
- **Para Administradores**: Gestión completa de la plataforma

---

## 🛠️ Tecnologías

### Backend
- **Framework**: NestJS (Node.js + TypeScript)
- **Base de Datos**: MongoDB con Mongoose
- **Autenticación**: JWT (JSON Web Tokens)
- **Validación**: class-validator, class-transformer
- **Seguridad**: bcrypt, passport
- **Contenedores**: Docker, Docker Compose

### Frontend
- **Framework**: Flutter (Dart)
- **Estado**: Riverpod + Riverpod Annotation
- **Navegación**: GoRouter
- **HTTP Client**: Dio + Retrofit
- **Almacenamiento**: Flutter Secure Storage
- **UI**: Material Design 3

---

## ✅ Estado Actual

### 🎉 Funcionando Completamente

#### Backend (NestJS)
- ✅ **Autenticación JWT**: Login, registro, logout, validación de tokens
- ✅ **Usuarios**: CRUD completo con roles (client, owner, admin)
- ✅ **Bares**: CRUD completo con validaciones y asociación a propietarios
- ✅ **Menús**: CRUD completo vinculado a bares
- ✅ **Imágenes**: Sistema de upload y gestión
- ✅ **Base de Datos**: MongoDB con Docker Compose

#### Frontend (Flutter)
- ✅ **Autenticación**: Login y registro funcionales
- ✅ **Pantalla de Bienvenida**: Dashboard con información del usuario
  - Saludo dinámico según hora del día
  - Nombre, email y rol del usuario
  - Avatar con iniciales
  - Diseño moderno con gradientes
- ✅ **Navegación**: Rutas protegidas con guards
- ✅ **State Management**: Riverpod completamente configurado
- ✅ **Almacenamiento Seguro**: Tokens JWT encriptados

#### Integración
- ✅ **Backend ↔ Frontend**: Conexión completa y funcional
- ✅ **Flujo de Autenticación**: Registro → Login → Dashboard → Logout
- ✅ **Persistencia de Sesión**: Auto-login con tokens guardados

### 🚧 En Desarrollo

- 🔄 **Frontend - Bares**: Pantallas pendientes (backend listo)
- 🔄 **Frontend - Menús**: Pantallas pendientes (backend listo)
- 🔄 **Promociones**: Módulo completo pendiente (backend + frontend)
- 🔄 **Dashboard Avanzado**: Estadísticas y datos en tiempo real

---

## 🚀 Instalación y Ejecución

### Prerrequisitos

- **Node.js** (v18+)
- **Yarn** o **npm**
- **Docker** y **Docker Compose**
- **Flutter SDK** (v3.13+)
- **Android Studio** o **Xcode** (para móvil)

### 1. Clonar el Repositorio

```bash
git clone <url-repositorio>
cd Mono-Bars
```

### 2. Configurar Backend

```bash
# Ir a la carpeta del backend
cd backend-bars

# Instalar dependencias
yarn install

# Iniciar MongoDB con Docker
docker-compose -f docker-compose.dev.yml up -d

# Copiar variables de entorno (y configurar)
cp .env.example .env

# Ejecutar en modo desarrollo
yarn start:dev
```

El backend estará disponible en `http://localhost:3000`

### 3. Configurar Frontend

```bash
# Ir a la carpeta del frontend
cd front-bars-flutter

# Instalar dependencias
flutter pub get

# Generar código automático
flutter packages pub run build_runner build --delete-conflicting-outputs

# Ejecutar la aplicación
flutter run
```

Para más detalles, consulta:
- [Documentación del Backend](./backend-bars/DOCUMENTATION.md)
- [README del Frontend](./front-bars-flutter/README.md)

---

## 📁 Estructura del Proyecto

```
Mono-Bars/
├── backend-bars/           # Backend NestJS
│   ├── src/
│   │   ├── auth/          # ✅ Autenticación JWT
│   │   ├── users/         # ✅ Gestión de usuarios
│   │   ├── bars/          # ✅ Gestión de bares
│   │   ├── menus/         # ✅ Gestión de menús
│   │   ├── promotions/    # 🔄 Promociones (pendiente)
│   │   ├── images/        # ✅ Upload de imágenes
│   │   ├── common/        # Utilidades comunes
│   │   └── config/        # Configuración
│   ├── .env              # Variables de entorno
│   ├── docker-compose.yml # Docker para producción
│   └── docker-compose.dev.yml # Docker para desarrollo
│
└── front-bars-flutter/    # Frontend Flutter
    ├── lib/
    │   ├── config/        # Configuración (rutas, tema)
    │   ├── core/          # Servicios core (HTTP, storage)
    │   └── modules/       # Módulos por dominio
    │       ├── auth/      # ✅ Login/Register
    │       ├── home/      # ✅ Dashboard/Bienvenida
    │       ├── users/     # ⚠️ Parcial
    │       ├── bars/      # 🔄 Pendiente
    │       ├── menus/     # 🔄 Pendiente
    │       └── promotions/ # 🔄 Pendiente
    └── pubspec.yaml
```

**Leyenda**: ✅ Completo | ⚠️ Parcial | 🔄 Pendiente

---

## 🎯 Funcionalidades

### Implementadas

#### Autenticación y Usuarios
- ✅ Registro de usuarios con validación
- ✅ Login con JWT
- ✅ Logout y limpieza de sesión
- ✅ Persistencia de sesión
- ✅ Sistema de roles (client, owner, admin)
- ✅ Rutas protegidas

#### Dashboard
- ✅ Pantalla de bienvenida personalizada
- ✅ Saludo dinámico según hora
- ✅ Información del perfil del usuario
- ✅ Avatar con iniciales

#### Backend - Bares y Menús
- ✅ CRUD completo de bares
- ✅ CRUD completo de menús
- ✅ Validaciones robustas
- ✅ Asociación bar ↔ propietario

### En Desarrollo

- 🔄 Listado de bares (frontend)
- 🔄 Detalle de bar (frontend)
- 🔄 Listado de menús (frontend)
- 🔄 Sistema de promociones completo
- 🔄 Dashboard con estadísticas reales
- 🔄 Sistema de favoritos
- 🔄 Búsqueda y filtros

---

## 📝 Próximos Pasos (Priorizado)

### Alta Prioridad
1. **Implementar pantallas de bares en Flutter** (backend ya listo)
2. **Dashboard con datos reales** (añadir endpoints de estadísticas)
3. **Módulo de promociones completo** (backend + frontend)

### Media Prioridad
4. **Pantallas de menús en Flutter** (backend ya listo)
5. **Perfil de usuario editable**
6. **Sistema de favoritos**

### Baja Prioridad
7. **Búsqueda y filtros avanzados**
8. **Geolocalización y mapas**
9. **Ratings y reseñas**
10. **Notificaciones push**

---

## 📝 Documentación Adicional

- [Documentación Completa del Backend](./backend-bars/DOCUMENTATION.md)
- [README del Frontend Flutter](./front-bars-flutter/README.md)
- [Análisis del Proyecto](./docs/analisis_proyecto.md) *(si existe)*

---

## 🤝 Contribución

1. Fork el proyecto
2. Crea una rama para tu feature (`git checkout -b feature/AmazingFeature`)
3. Commit tus cambios (`git commit -m 'Add some AmazingFeature'`)
4. Push a la rama (`git push origin feature/AmazingFeature`)
5. Abre un Pull Request

### Convenciones
- Código en inglés (variables, funciones, comentarios)
- Commits descriptivos en español o inglés
- Seguir la estructura modular establecida
- Agregar tests para nuevas funcionalidades

---

## 📊 Estado del Proyecto

- **Backend**: ~70% completado
- **Frontend**: ~45% completado
- **General**: ~55% completado

**Última actualización**: Noviembre 2025

---

## 📄 Licencia

[Especificar licencia]

---

## 👨‍💻 Autor

[Tu nombre/equipo]

---

**Desarrollado con ❤️ usando NestJS, Flutter y MongoDB**

🍻 ¡Salud!
