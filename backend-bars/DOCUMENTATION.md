Documentación del Proyecto Backend-bars
1. Arranque y entorno de desarrollo
Levantar base de datos MongoDB con Docker Compose

En la terminal dentro de la carpeta raíz del proyecto:

bash
docker-compose -f docker-compose.dev.yml up -d

Este comando iniciará el contenedor con MongoDB en segundo plano.
Iniciar servidor backend con hot reload (modo desarrollo)

En otra terminal, en la misma carpeta:

bash
yarn start:dev

Se arrancará el servidor de NestJS con recarga automática ante cambios en el código (hot reload).
Detener aplicaciones

    Para detener el servidor NestJS:
    Presiona Ctrl + C en la terminal donde se ejecuta.

    Para detener y eliminar contenedores Docker:

bash
docker-compose -f docker-compose.dev.yml down

2. Estructura del proyecto

text
backend-bars/
│
├── src/
│   ├── app.module.ts             # Módulo raíz de NestJS
│   ├── main.ts                  # Punto de entrada de la aplicación
│   ├── bars/                    # Módulo bares: esquemas, servicios, controladores
│   ├── auth/                    # Módulo autenticación: JWT, guards, estrategias
│   ├── users/                   # Módulo usuarios: usuario y roles
│   ├── common/                  # Código común y utilidades compartidas
│   ├── config/                  # Configuraciones de entorno y proyecto
│   ├── menus/                   # (Futuro) menús
│   ├── promotions/              # (Futuro) promociones
│   └── images/                  # Gestión de imágenes y uploads
│
├── test/                       # Pruebas automatizadas
├── .env                        # Variables de entorno
├── Dockerfile                  # Imagen Docker producción
├── docker-compose.yml          # Configuración Docker general
├── docker-compose.dev.yml      # Configuración Docker para desarrollo
└── README.md / DOCUMENTATION.md # Documentación principal

3. Tecnologías y dependencias principales

    Framework: NestJS con TypeScript

    Base de datos: MongoDB con Mongoose

    Contenedores: Docker y Docker Compose

    Gestor de paquetes: Yarn

    Librerías claves:
    @nestjs/mongoose, mongoose,
    @nestjs/config,
    @nestjs/passport, passport, passport-local, @nestjs/jwt, passport-jwt, bcrypt,
    class-validator, class-transformer,
    @nestjs/platform-express, multer

4. Funcionalidades principales implementadas
Usuarios

    Registro con rol asignado automáticamente (client por defecto, owner, admin).

    Contraseñas almacenadas hasheadas con bcrypt.

    Validación estricta con class-validator.

    Operaciones CRUD completas.

    Control básico para que solo usuarios autorizados modifiquen o eliminen su propia cuenta.

Roles de usuarios

    client: usuario normal, lee bares, guarda favoritos, etc.

    owner: propietario que puede gestionar sus bares.

    admin: acceso completo (pendiente implementación).

Bares

    Creación y gestión de bares vinculados a un usuario owner.

    Validaciones estrictas para evitar duplicados en campos clave:

        nameBar

        phone (teléfono)

        socialLinks.facebook y socialLinks.instagram

    Asociación del bar con su propietario mediante ownerId.

    Estructura cuidada para horarios, fotos, ubicación y redes sociales.

    Control detallado en el servicio BarsService con logs para trazabilidad.

5. API REST — Endpoints resumen principales
Endpoint	Método	Descripción	Notas importantes
/users/register	POST	Registrar nuevo usuario	Rol opcional, contraseña mínima 6
/users	GET	Listar todos los usuarios	Requiere rol admin (pendiente activar)
/users/:id	GET	Obtener usuario por ID	
/users/:id	PUT	Actualizar usuario (solo su propia cuenta)	No permite cambiar email ni rol
/users/:id	DELETE	Eliminar cuenta (auto-baja)	Solo el propio usuario puede eliminar
/bars	POST	Crear un bar vinculado a un owner	ownerId obligatorio
/bars	GET	Listar todos los bares	
/bars/:id	GET	Obtener bar por ID	
/bars/:id	PUT	Actualizar bar	Validación personalizada y control duplicados
/bars/:id	DELETE	Eliminar bar	
6. Validaciones importantes en la lógica de negocio

    Campos únicos: emails en usuarios; y en bares nameBar, teléfono, Facebook e Instagram.

    Las validaciones para evitar duplicados se aplican tanto en creación como en actualización.

    En la actualización, solo se valida si el campo cambia respecto al valor actual.

    En consultas de duplicados, el documento actualmente actualizado se excluye para evitar falsos positivos.

    ownerId debe ser un ObjectId válido para asociar bares con sus dueños.

    Logs detallados en servicios para facilitar seguimiento y depuración.

    Manejo robusto de errores: ConflictException, NotFoundException, ForbiddenException donde aplican.

7. Flujo detallado: actualización segura de un bar

    El controlador recibe la petición PUT a /bars/:id con los datos a modificar y el token JWT en headers.

    Se activan los Guards (JwtAuthGuard, RolesGuard) para validar que el token es válido y que el usuario tiene rol owner o admin.

    En el servicio BarsService.update():

        Se obtiene el bar actual por ID.

        Se valida que el bar existe; si no, error 404.

        Para cada campo único enviado en la actualización:

            Se verifica si el valor nuevo es diferente al actual.

            Si es diferente, se busca si existe otro bar distinto con ese valor.

            Si se encuentra, se lanza error de conflicto para evitar duplicados.

        Se aplican cambios y se guarda el bar actualizado.

    Se devuelve al cliente el bar modificado o el error específico si ocurre.

8. Estado Actual del Proyecto

    ✅ Autenticación JWT completa y funcional

        Login, registro, logout implementados
        Validación de tokens
        Guards y estrategias JWT activas
        Integración completa con frontend Flutter

    ✅ Integración Frontend-Backend Funcionando

        Frontend Flutter conectado exitosamente
        Flujo completo de autenticación operativo
        Usuario puede registrarse → iniciar sesión → ver dashboard → cerrar sesión
        Pantalla de bienvenida mostrando datos del usuario en tiempo real
        Tokens JWT almacenados de forma segura

    ✅ Pantalla de Bienvenida Implementada (Frontend)

        Muestra nombre del usuario autenticado
        Saludo dinámico según hora del día
        Información de perfil (email, rol)
        Avatar con iniciales
        Diseño moderno y profesional

    ✅ Módulos Backend Listos para Integración

        Bares: CRUD completo, listo para pantallas frontend
        Menús: CRUD completo, listo para pantallas frontend
        Usuarios: Gestión completa

9. Próximos pasos recomendados

    Implementar pantallas de bares en frontend (backend ya listo).

    Implementar pantallas de menús en frontend (backend ya listo).

    Completar módulo de promociones en backend.

    Añadir endpoints de estadísticas (GET /bars/stats, GET /bars/popular).

    Implementar sistema de favoritos.

    Documentar API con Swagger / OpenAPI para facilitar pruebas y uso.

    Potenciar testing automatizado con pruebas unitarias y de integración.
