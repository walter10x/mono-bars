// Configuración de la API
const API_BASE_URL = 'https://e1964d5996d5.ngrok-free.app'; // TEMPORAL - NO HACER COMMIT

// Elementos del DOM
const formCard = document.getElementById('formCard');
const successCard = document.getElementById('successCard');
const errorCard = document.getElementById('errorCard');
const noTokenCard = document.getElementById('noTokenCard');
const resetForm = document.getElementById('resetForm');
const submitBtn = document.getElementById('submitBtn');
const btnText = document.getElementById('btnText');
const btnLoader = document.getElementById('btnLoader');
const errorMessage = document.getElementById('errorMessage');

// Obtener token de la URL
function getTokenFromURL() {
    const urlParams = new URLSearchParams(window.location.search);
    return urlParams.get('token');
}

// Toggle visibilidad de contraseña
function togglePassword(inputId) {
    const input = document.getElementById(inputId);
    input.type = input.type === 'password' ? 'text' : 'password';
}

// Mostrar error
function showError(message) {
    errorMessage.textContent = message;
    errorMessage.style.display = 'block';
}

// Ocultar error
function hideError() {
    errorMessage.style.display = 'none';
}

// Validar contraseñas
function validatePasswords() {
    const password = document.getElementById('password').value;
    const confirmPassword = document.getElementById('confirmPassword').value;

    if (password.length < 6) {
        showError('La contraseña debe tener al menos 6 caracteres');
        return false;
    }

    if (password !== confirmPassword) {
        showError('Las contraseñas no coinciden');
        return false;
    }

    hideError();
    return true;
}

// Mostrar estado de carga
function setLoading(loading) {
    submitBtn.disabled = loading;
    btnText.style.display = loading ? 'none' : 'inline';
    btnLoader.style.display = loading ? 'inline-block' : 'none';
}

// Mostrar tarjeta de éxito
function showSuccess() {
    formCard.style.display = 'none';
    successCard.style.display = 'block';
}

// Mostrar tarjeta de error
function showErrorCard(title, text) {
    formCard.style.display = 'none';
    document.getElementById('errorTitle').textContent = title;
    document.getElementById('errorText').textContent = text;
    errorCard.style.display = 'block';
}

// Enviar formulario
async function handleSubmit(event) {
    event.preventDefault();

    if (!validatePasswords()) {
        return;
    }

    const token = getTokenFromURL();
    const password = document.getElementById('password').value;

    setLoading(true);
    hideError();

    try {
        const response = await fetch(`${API_BASE_URL}/auth/reset-password`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
            },
            body: JSON.stringify({
                token: token,
                newPassword: password,
            }),
        });

        const data = await response.json();

        if (response.ok) {
            showSuccess();
        } else {
            if (response.status === 400) {
                showErrorCard(
                    'Token Inválido o Expirado',
                    data.message || 'El enlace de restablecimiento ha expirado. Por favor, solicita uno nuevo desde la app.'
                );
            } else {
                showError(data.message || 'Error al restablecer la contraseña');
            }
        }
    } catch (error) {
        console.error('Error:', error);
        showError('Error de conexión. Por favor, intenta de nuevo.');
    } finally {
        setLoading(false);
    }
}

// Inicialización
document.addEventListener('DOMContentLoaded', () => {
    const token = getTokenFromURL();

    if (!token) {
        formCard.style.display = 'none';
        noTokenCard.style.display = 'block';
        return;
    }

    // Agregar event listeners
    resetForm.addEventListener('submit', handleSubmit);

    // Validación en tiempo real
    document.getElementById('confirmPassword').addEventListener('input', () => {
        const password = document.getElementById('password').value;
        const confirmPassword = document.getElementById('confirmPassword').value;

        if (confirmPassword && password !== confirmPassword) {
            showError('Las contraseñas no coinciden');
        } else {
            hideError();
        }
    });
});
