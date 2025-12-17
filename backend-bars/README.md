# TourBar Backend API

API REST para la aplicación TourBar, desarrollada con NestJS y MongoDB. Gestiona bares, menús, promociones y usuarios.

## 🚀 Tecnologías

- **NestJS** - Framework Node.js
- **MongoDB** - Base de datos NoSQL
- **Mongoose** - ODM para MongoDB
- **JWT** - Autenticación con tokens
- **Passport** - Estrategias de autenticación
- **Multer** - Subida de archivos/imágenes

## 📦 Instalación

```bash
# Instalar dependencias
npm install

# Configurar variables de entorno
cp .env.example .env
# Editar .env con tus configuraciones

# Ejecutar en desarrollo
npm run start:dev

# Ejecutar en producción
npm run start:prod
```

## 🔧 Variables de Entorno

```env
PORT=3000
MONGODB_URI=mongodb://localhost:27017/tourbar
JWT_SECRET=tu_secreto_jwt
JWT_REFRESH_SECRET=tu_secreto_refresh
```

## 📁 Estructura del Proyecto

```
src/
├── auth/                 # Módulo de autenticación
│   ├── auth.controller.ts
│   ├── auth.service.ts
│   ├── jwt.strategy.ts
│   ├── jwt-auth.guard.ts
│   └── roles.guard.ts
├── users/                # Gestión de usuarios
│   ├── user.schema.ts
│   ├── users.controller.ts
│   └── users.service.ts
├── bars/                 # Gestión de bares
│   └── bars/
│       ├── bar.schema.ts
│       ├── bars.controller.ts
│       ├── bars.service.ts
│       └── create-bar.dto.ts
├── menus/                # Gestión de menús
│   ├── menu.schema.ts
│   ├── menus.controller.ts
│   └── menus.service.ts
├── promotions/           # Gestión de promociones
│   ├── promotion.schema.ts
│   ├── promotions.controller.ts
│   └── promotions.service.ts
└── uploads/              # Archivos subidos
```

## 🔌 API Endpoints

### Autenticación (`/auth`)

| Método | Endpoint | Descripción |
|--------|----------|-------------|
| POST | `/auth/login` | Iniciar sesión |
| POST | `/auth/refresh` | Renovar token |
| POST | `/auth/logout` | Cerrar sesión |
| GET | `/auth/me` | Usuario actual |
| GET | `/auth/verify` | Verificar token |

### Usuarios (`/users`)

| Método | Endpoint | Descripción |
|--------|----------|-------------|
| POST | `/users/register` | Registrar usuario |
| GET | `/users` | Listar usuarios |
| GET | `/users/:id` | Obtener usuario |
| PUT | `/users/:id` | Actualizar usuario |
| DELETE | `/users/:id` | Eliminar usuario |

### Bares (`/bars`)

| Método | Endpoint | Descripción |
|--------|----------|-------------|
| GET | `/bars` | Listar todos los bares |
| GET | `/bars/search?q=` | **Buscar bares por nombre/ubicación** |
| GET | `/bars/my-bars` | Bares del propietario (auth) |
| GET | `/bars/:id` | Obtener bar por ID |
| POST | `/bars` | Crear bar (auth: owner) |
| PUT | `/bars/:id` | Actualizar bar (auth: owner) |
| DELETE | `/bars/:id` | Eliminar bar (auth: owner) |
| POST | `/bars/:id/photo` | Subir foto del bar |
| DELETE | `/bars/:id/photo` | Eliminar foto del bar |

### Menús (`/menus`)

| Método | Endpoint | Descripción |
|--------|----------|-------------|
| GET | `/menus` | Listar menús |
| GET | `/menus/bar/:barId` | Menús de un bar |
| GET | `/menus/:id` | Obtener menú |
| POST | `/menus` | Crear menú (auth: owner) |
| PUT | `/menus/:id` | Actualizar menú |
| DELETE | `/menus/:id` | Eliminar menú |

### Promociones (`/promotions`)

| Método | Endpoint | Descripción |
|--------|----------|-------------|
| GET | `/promotions` | Listar promociones |
| GET | `/promotions/bar/:barId` | Promociones de un bar |
| GET | `/promotions/:id` | Obtener promoción |
| POST | `/promotions` | Crear promoción (auth: owner) |
| PUT | `/promotions/:id` | Actualizar promoción |
| DELETE | `/promotions/:id` | Eliminar promoción |
| POST | `/promotions/:id/photo` | Subir foto de promoción |

## 🔐 Roles y Permisos

| Rol | Permisos |
|-----|----------|
| **client** | Ver bares, menús, promociones. Buscar. |
| **owner** | Todo lo anterior + CRUD de sus propios bares |
| **admin** | Acceso completo a todo el sistema |

## 🧪 Testing

```bash
# Tests unitarios
npm run test

# Tests e2e
npm run test:e2e

# Coverage
npm run test:cov
```

## 📝 Características Recientes

- ✅ Búsqueda de bares por nombre, ubicación y descripción
- ✅ Gestión de promociones con fechas de validez
- ✅ Subida de fotos para bares y promociones
- ✅ Sistema de roles (client/owner/admin)
- ✅ Autenticación JWT con refresh tokens

---

**Desarrollado con ❤️ para TourBar**
