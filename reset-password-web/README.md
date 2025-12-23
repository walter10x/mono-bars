# Reset Password Web - TourBar

Página web para restablecer contraseñas de usuarios de TourBar.

## 🚀 Deploy en Vercel

### Opción 1: Deploy desde GitHub

1. Sube esta carpeta a un repositorio de GitHub
2. Ve a [vercel.com](https://vercel.com) y crea una cuenta (gratis)
3. Conecta tu repositorio de GitHub
4. Selecciona la carpeta `reset-password-web`
5. Click en "Deploy"

### Opción 2: Deploy con CLI

```bash
# Instalar Vercel CLI
npm i -g vercel

# En esta carpeta, ejecutar:
vercel

# Seguir las instrucciones
```

## ⚙️ Configuración

Después del deploy, edita `script.js` y cambia:

```javascript
const API_BASE_URL = 'https://your-backend-api.com'; // Tu URL del backend
```

Por la URL real de tu backend en producción.

## 📝 Actualizar Backend

Después de obtener la URL de Vercel, actualiza el `.env` del backend:

```env
FRONTEND_URL=https://tu-app.vercel.app
```

Y reinicia el backend para que los emails apunten a la URL correcta.

## 🎨 Diseño

- Premium dark theme matching la app Flutter
- Responsive design para móvil y desktop
- Animaciones y feedback visual
- Validación de formularios en tiempo real

---

**Desarrollado para TourBar**
