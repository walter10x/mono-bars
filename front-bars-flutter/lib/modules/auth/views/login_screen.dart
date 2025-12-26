import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:formz/formz.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/utils/extensions.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/custom_text_field.dart';
import '../../../shared/widgets/loading_overlay.dart';
import '../controllers/auth_controller.dart';
import '../services/google_auth_service.dart';

/// Pantalla de inicio de sesión
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  
  bool _obscurePassword = true;
  bool _rememberMe = false;
  bool _isGoogleSignInInProgress = false; // Flag para evitar redirección automática

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    final email = _emailController.text.trim();
    final password = _passwordController.text;

    await ref.read(authControllerProvider.notifier).login(
      email: email,
      password: password,
    );
  }

  void _handleForgotPassword() {
    // Navegar a pantalla de recuperación de contraseña
    context.go('/forgot-password');
  }

  void _handleRegister() {
    // Navegar a pantalla de registro
    context.go('/register');
  }

  Future<void> _handleGoogleSignIn() async {
    setState(() => _isGoogleSignInInProgress = true);
    
    final googleAuthService = ref.read(googleAuthServiceProvider);
    
    // Obtener ID Token de Google
    final idToken = await googleAuthService.signIn();
    
    if (idToken == null) {
      // Usuario canceló el login
      setState(() => _isGoogleSignInInProgress = false);
      return;
    }
    
    // Enviar token al backend
    final isNewUser = await ref.read(authControllerProvider.notifier).loginWithGoogle(idToken);
    
    // Si es usuario nuevo, navegar a pantalla de selección de rol
    if (mounted) {
      if (isNewUser) {
        context.go('/role-selection');
      } else {
        // Usuario existente: navegar según rol
        final user = ref.read(currentUserProvider);
        if (user != null) {
          final isOwner = user.role == 'owner' || user.roles.contains('owner');
          if (isOwner) {
            context.go('/owner/dashboard');
          } else {
            context.go('/client/home');
          }
        }
      }
      setState(() => _isGoogleSignInInProgress = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);
    final isLoading = authState.isLoadingState;

    // Listener para manejar cambios de estado
    ref.listen(authStateProvider, (previous, current) {
      if (current.hasError && current.errorMessage != null) {
        context.showErrorSnackBar(current.errorMessage!);
        // Limpiar error después de mostrarlo
        Future.delayed(Duration.zero, () {
          ref.read(authControllerProvider.notifier).clearError();
        });
      } else if (current.isAuthenticated && current.user != null) {
        // NO navegar automáticamente si estamos en flujo de Google Sign-In
        // El método _handleGoogleSignIn manejará la navegación
        if (_isGoogleSignInInProgress) {
          print('🔍 DEBUG: Saltando navegación automática (Google Sign-In en progreso)');
          return;
        }
        
        // Navegar según el rol del usuario (solo para login normal)
        final user = current.user!;
        final userRole = user.role?.toLowerCase() ?? 'client';
        
        print('🔍 DEBUG: Usuario autenticado con rol: $userRole');
        
        // Verificar si es owner
        final isOwner = userRole == 'owner' || user.roles.contains('owner');
        
        // Agregar delay para asegurar que el contexto esté listo
        Future.delayed(const Duration(milliseconds: 100), () {
          if (!mounted) return;
          
          if (isOwner) {
            print('✅ Navegando a /owner/dashboard');
            context.go('/owner/dashboard');
          } else {
            print('✅ Navegando a /client/home');
            context.go('/client/home');
          }
        });
      }
    });

    // Paleta de colores premium - Oscura y elegante para app de bares
    const primaryDark = Color(0xFF1A1A2E); // Azul oscuro casi negro
    const secondaryDark = Color(0xFF16213E); // Azul profundo
    const accentAmber = Color(0xFFFFA500); // Amber/Naranja cálido
    const accentGold = Color(0xFFFFB84D); // Dorado suave

    return LoadingOverlay(
      isLoading: isLoading,
      child: Scaffold(
        backgroundColor: const Color(0xFF0F0F1E), // Fondo muy oscuro
        body: SingleChildScrollView(
          child: Column(
            children: [
              // Header Premium con gradiente oscuro elegante
              Container(
                height: 380,
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      primaryDark,
                      secondaryDark,
                      primaryDark.withOpacity(0.9),
                    ],
                  ),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(50),
                    bottomRight: Radius.circular(50),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: accentAmber.withOpacity(0.1),
                      blurRadius: 30,
                      offset: const Offset(0, 15),
                    ),
                  ],
                ),
                child: SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 20),
                      // Logo profesional sin bordes
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(28),
                          boxShadow: [
                            BoxShadow(
                              color: accentAmber.withOpacity(0.3),
                              blurRadius: 25,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(28),
                          child: Image.asset(
                            'assets/images/app_icon.png',
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Título con efecto dorado
                      ShaderMask(
                        shaderCallback: (bounds) => const LinearGradient(
                          colors: [accentAmber, accentGold],
                        ).createShader(bounds),
                        child: const Text(
                          'TourBar',
                          style: TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 2,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Subtítulo con diseño mejorado
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: accentGold.withOpacity(0.2),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          'Tu guía para la mejor experiencia',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 13,
                            color: accentGold,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 1,
                            height: 1.2,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Formulario en Tarjeta Premium Oscura
              Transform.translate(
                offset: const Offset(0, -30),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 28),
                  child: Container(
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E1E2D),
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(
                        color: accentAmber.withOpacity(0.2),
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 30,
                          offset: const Offset(0, 15),
                        ),
                        BoxShadow(
                          color: accentAmber.withOpacity(0.05),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'Bienvenido',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.white.withOpacity(0.95),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Inicia sesión para continuar',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 13,
                            color: accentGold.withOpacity(0.7),
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 28),
                        
                        _buildLoginForm(),
                        
                        const SizedBox(height: 20),
                        
                        _buildLoginButton(),
                        
                        const SizedBox(height: 14),
                        
                        _buildForgotPasswordButton(),
                        
                        const SizedBox(height: 20),
                        
                        // Divider con texto "o"
                        Row(
                          children: [
                            Expanded(
                              child: Divider(
                                color: Colors.white.withOpacity(0.2),
                                thickness: 1,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: Text(
                                'o',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.5),
                                  fontSize: 14,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Divider(
                                color: Colors.white.withOpacity(0.2),
                                thickness: 1,
                              ),
                            ),
                          ],
                        ),
                        
                        const SizedBox(height: 20),
                        
                        // Botón de Google Sign-In
                        _buildGoogleSignInButton(),
                      ],
                    ),
                  ),
                ),
              ),

              // Registro
              Padding(
                padding: const EdgeInsets.only(bottom: 30),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '¿No tienes cuenta? ',
                      style: TextStyle(color: Colors.white.withOpacity(0.7)),
                    ),
                    TextButton(
                      onPressed: _handleRegister,
                      child: const Text(
                        'Regístrate aquí',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: accentAmber,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Eliminamos _buildHeader antiguo ya que ahora está integrado en el build principal

  Widget _buildLoginForm() {
    const accentAmber = Color(0xFFFFA500);
    
    return Form(
      key: _formKey,
      child: Column(
        children: [
          CustomTextField(
            controller: _emailController,
            hint: 'Correo electrónico',
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            prefixIcon: Icons.email_rounded,
            focusedBorderColor: accentAmber,
            textStyle: const TextStyle(
              color: Colors.white,
            ),
            fillColor: Colors.white.withOpacity(0.05),
            borderColor: Colors.white.withOpacity(0.15),
            hintStyle: TextStyle(
              color: Colors.white.withOpacity(0.4),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) return 'El email es requerido';
              if (!value.isValidEmail) return 'Ingresa un email válido';
              return null;
            },
          ),
          const SizedBox(height: 14),
          CustomTextField(
            controller: _passwordController,
            hint: 'Contraseña',
            obscureText: _obscurePassword,
            textInputAction: TextInputAction.done,
            prefixIcon: Icons.lock_rounded,
            focusedBorderColor: accentAmber,
            textStyle: const TextStyle(
              color: Colors.white,
            ),
            fillColor: Colors.white.withOpacity(0.05),
            borderColor: Colors.white.withOpacity(0.15),
            hintStyle: TextStyle(
              color: Colors.white.withOpacity(0.4),
            ),
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                color: Colors.white.withOpacity(0.6),
              ),
              onPressed: () {
                setState(() {
                  _obscurePassword = !_obscurePassword;
                });
              },
            ),
            validator: (value) {
              if (value == null || value.isEmpty) return 'La contraseña es requerida';
              if (value.length < AppConstants.minPasswordLength) {
                return 'Mínimo ${AppConstants.minPasswordLength} caracteres';
              }
              return null;
            },
            onFieldSubmitted: (_) => _handleLogin(),
          ),
          const SizedBox(height: 10),
          // Recordarme alineado a la izquierda
          Row(
            children: [
              SizedBox(
                height: 24,
                width: 24,
                child: Checkbox(
                  value: _rememberMe,
                  activeColor: const Color(0xFFFFA500),
                  checkColor: const Color(0xFF1A1A2E),
                  side: BorderSide(color: Colors.white.withOpacity(0.3)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                  onChanged: (value) {
                    setState(() {
                      _rememberMe = value ?? false;
                    });
                  },
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Recordarme',
                style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 14),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLoginButton() {
    const accentAmber = Color(0xFFFFA500);
    
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: accentAmber.withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: _handleLogin,
        style: ElevatedButton.styleFrom(
          backgroundColor: accentAmber,
          foregroundColor: const Color(0xFF1A1A2E),
          minimumSize: const Size(double.infinity, 56),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          elevation: 0,
        ),
        child: ref.watch(authLoadingProvider)
            ? const SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF1A1A2E)),
                ),
              )
            : const Text(
                'INICIAR SESIÓN',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
      ),
    );
  }

  Widget _buildForgotPasswordButton() {
    return Center(
      child: TextButton(
        onPressed: _handleForgotPassword,
        style: TextButton.styleFrom(
          foregroundColor: const Color(0xFFFFB84D),
        ),
        child: const Text(
          '¿Olvidaste tu contraseña?',
          style: TextStyle(fontSize: 14),
        ),
      ),
    );
  }

  Widget _buildGoogleSignInButton() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
          width: 1.5,
        ),
        gradient: LinearGradient(
          colors: [
            Colors.white.withOpacity(0.1),
            Colors.white.withOpacity(0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _handleGoogleSignIn,
          borderRadius: BorderRadius.circular(14),
          splashColor: Colors.white.withOpacity(0.1),
          highlightColor: Colors.white.withOpacity(0.05),
          child: Container(
            height: 56,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: ref.watch(authLoadingProvider)
                ? const Center(
                    child: SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Logo oficial de Google usando SVG
                      SvgPicture.asset(
                        'assets/images/google_logo.svg',
                        width: 24,
                        height: 24,
                      ),
                      const SizedBox(width: 14),
                      const Text(
                        'Continuar con Google',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  // Eliminamos _buildDivider y _buildRegisterButton antiguos ya que se integraron de otra forma
}

/// Clase para validar email usando Formz
class EmailInput extends FormzInput<String, EmailValidationError> {
  const EmailInput.pure() : super.pure('');
  const EmailInput.dirty([super.value = '']) : super.dirty();

  @override
  EmailValidationError? validator(String value) {
    if (value.isEmpty) return EmailValidationError.empty;
    if (!value.isValidEmail) return EmailValidationError.invalid;
    return null;
  }
}

/// Errores de validación de email
enum EmailValidationError { empty, invalid }

extension EmailValidationErrorX on EmailValidationError {
  String get message {
    switch (this) {
      case EmailValidationError.empty:
        return 'El email es requerido';
      case EmailValidationError.invalid:
        return 'Ingresa un email válido';
    }
  }
}

/// Clase para validar contraseña usando Formz
class PasswordInput extends FormzInput<String, PasswordValidationError> {
  const PasswordInput.pure() : super.pure('');
  const PasswordInput.dirty([super.value = '']) : super.dirty();

  @override
  PasswordValidationError? validator(String value) {
    if (value.isEmpty) return PasswordValidationError.empty;
    if (value.length < AppConstants.minPasswordLength) {
      return PasswordValidationError.tooShort;
    }
    return null;
  }
}

/// Errores de validación de contraseña
enum PasswordValidationError { empty, tooShort }

extension PasswordValidationErrorX on PasswordValidationError {
  String get message {
    switch (this) {
      case PasswordValidationError.empty:
        return 'La contraseña es requerida';
      case PasswordValidationError.tooShort:
        return 'La contraseña debe tener al menos ${AppConstants.minPasswordLength} caracteres';
    }
  }
}
