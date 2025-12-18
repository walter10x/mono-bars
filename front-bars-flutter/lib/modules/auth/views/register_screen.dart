import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/utils/extensions.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/custom_text_field.dart';
import '../../../shared/widgets/loading_overlay.dart';
import '../controllers/auth_controller.dart';

/// Pantalla de registro de nuevos usuarios
class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _nameController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  String _selectedRole = 'client';
  bool _acceptTerms = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  void _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    if (!_acceptTerms) {
      context.showErrorSnackBar('Debes aceptar los términos y condiciones');
      return;
    }

    // Validar que las contraseñas coincidan
    if (_passwordController.text != _confirmPasswordController.text) {
      context.showErrorSnackBar('Las contraseñas no coinciden');
      return;
    }

    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final name = _nameController.text.trim();

    final success = await ref.read(authControllerProvider.notifier).register(
      email: email,
      password: password,
      name: name,
      role: _selectedRole,
    );

    if (success) {
      if (mounted) {
        context.showSuccessSnackBar(
          '¡Registro exitoso! Ahora puedes iniciar sesión.',
        );
        context.go('/login');
      }
    }
  }

  void _handleLogin() {
    context.go('/login');
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);
    final isLoading = authState.isLoadingState;

    // Listener para manejar errores
    ref.listen(authStateProvider, (previous, current) {
      if (current.hasError && current.errorMessage != null) {
        context.showErrorSnackBar(current.errorMessage!);
        // Limpiar error después de mostrarlo
        Future.delayed(Duration.zero, () {
          ref.read(authControllerProvider.notifier).clearError();
        });
      }
    });

    // Paleta de colores premium - igual que login
    const primaryDark = Color(0xFF1A1A2E);
    const secondaryDark = Color(0xFF16213E);
    const accentAmber = Color(0xFFFFA500);
    const accentGold = Color(0xFFFFB84D);

    return LoadingOverlay(
      isLoading: isLoading,
      child: Scaffold(
        backgroundColor: const Color(0xFF0F0F1E),
        body: SingleChildScrollView(
          child: Column(
            children: [
              // Header Premium con gradiente oscuro elegante
              Container(
                height: 260,
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
                  child: Stack(
                    children: [
                      // Botón de volver
                      Positioned(
                        left: 8,
                        top: 8,
                        child: IconButton(
                          onPressed: () => context.go('/login'),
                          icon: Icon(
                            Icons.arrow_back,
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ),
                      ),
                      // Contenido centrado
                      Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SizedBox(height: 10),
                            // Logo de la App más pequeño
                            Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: accentAmber.withOpacity(0.3),
                                    blurRadius: 20,
                                    offset: const Offset(0, 6),
                                  ),
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(20),
                                child: Image.asset(
                                  'assets/images/app_icon.png',
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            // Título con efecto dorado
                            ShaderMask(
                              shaderCallback: (bounds) => const LinearGradient(
                                colors: [accentAmber, accentGold],
                              ).createShader(bounds),
                              child: const Text(
                                'Crear Cuenta',
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  letterSpacing: 1.2,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            // Subtítulo simple sin overflow
                            Text(
                              'Únete a TourBar',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 12,
                                color: accentGold,
                                fontWeight: FontWeight.w500,
                                letterSpacing: 0.8,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Formulario en Tarjeta Premium Oscura - superpuesto sobre header
              Transform.translate(
                offset: const Offset(0, -30),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E1E2D),
                      borderRadius: BorderRadius.circular(24),
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
                        _buildRegisterForm(),
                        
                        const SizedBox(height: 14),
                        
                        _buildRoleSelector(),
                        
                        const SizedBox(height: 14),
                        
                        _buildTermsCheckbox(),
                        
                        const SizedBox(height: 16),
                        
                        _buildRegisterButton(),
                      ],
                    ),
                  ),
                ),
              ),

              // Link de Login
              Padding(
                padding: const EdgeInsets.only(bottom: 30),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '¿Ya tienes cuenta? ',
                      style: TextStyle(color: Colors.white.withOpacity(0.7)),
                    ),
                    TextButton(
                      onPressed: _handleLogin,
                      child: const Text(
                        'Inicia sesión',
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

  Widget _buildHeader() {
    return Column(
      children: [
        Row(
          children: [
            IconButton(
              onPressed: () => context.go('/login'),
              icon: const Icon(Icons.arrow_back),
            ),
            const Expanded(
              child: SizedBox(),
            ),
          ],
        ),
        
        const SizedBox(height: 20),

        // Logo
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor,
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Icon(
            Icons.person_add,
            color: Colors.white,
            size: 40,
          ),
        ),

        const SizedBox(height: 24),

        Text(
          'Crear Cuenta',
          style: context.textTheme.headlineLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 8),

        Text(
          'Completa la información para registrarte',
          style: context.textTheme.bodyLarge?.copyWith(
            color: context.colors.onSurface.withOpacity(0.6),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildRegisterForm() {
    const accentAmber = Color(0xFFFFA500);
    
    return Form(
      key: _formKey,
      child: Column(
        children: [
          // Nombre completo
          CustomTextField(
            controller: _nameController,
            hint: 'Nombre completo',
            textInputAction: TextInputAction.next,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            prefixIcon: Icons.person_outline,
            focusedBorderColor: accentAmber,
            textStyle: const TextStyle(color: Colors.white, fontSize: 14),
            fillColor: Colors.white.withOpacity(0.05),
            borderColor: Colors.white.withOpacity(0.15),
            hintStyle: TextStyle(color: Colors.white.withOpacity(0.4)),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'El nombre es requerido';
              }
              if (value.length > 50) {
                return 'El nombre no puede tener más de 50 caracteres';
              }
              return null;
            },
          ),

          const SizedBox(height: 12),

          // Email
          CustomTextField(
            controller: _emailController,
            hint: 'Correo electrónico',
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            prefixIcon: Icons.email_outlined,
            focusedBorderColor: accentAmber,
            textStyle: const TextStyle(color: Colors.white, fontSize: 14),
            fillColor: Colors.white.withOpacity(0.05),
            borderColor: Colors.white.withOpacity(0.15),
            hintStyle: TextStyle(color: Colors.white.withOpacity(0.4), fontSize: 13),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'El email es requerido';
              }
              if (!value.isValidEmail) {
                return 'Ingresa un email válido';
              }
              return null;
            },
          ),

          const SizedBox(height: 12),

          // Contraseña
          CustomTextField(
            controller: _passwordController,
            hint: 'Contraseña (mín. ${AppConstants.minPasswordLength} caracteres)',
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            obscureText: _obscurePassword,
            textInputAction: TextInputAction.next,
            prefixIcon: Icons.lock_outline,
            focusedBorderColor: accentAmber,
            textStyle: const TextStyle(color: Colors.white),
            fillColor: Colors.white.withOpacity(0.05),
            borderColor: Colors.white.withOpacity(0.15),
            hintStyle: TextStyle(color: Colors.white.withOpacity(0.4)),
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
              if (value == null || value.isEmpty) {
                return 'La contraseña es requerida';
              }
              if (value.length < AppConstants.minPasswordLength) {
                return 'Mínimo ${AppConstants.minPasswordLength} caracteres';
              }
              return null;
            },
          ),

          const SizedBox(height: 12),

          // Confirmar contraseña
          CustomTextField(
            controller: _confirmPasswordController,
            hint: 'Confirmar contraseña',
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            obscureText: _obscureConfirmPassword,
            textInputAction: TextInputAction.done,
            prefixIcon: Icons.lock_outline,
            focusedBorderColor: accentAmber,
            textStyle: const TextStyle(color: Colors.white),
            fillColor: Colors.white.withOpacity(0.05),
            borderColor: Colors.white.withOpacity(0.15),
            hintStyle: TextStyle(color: Colors.white.withOpacity(0.4)),
            suffixIcon: IconButton(
              icon: Icon(
                _obscureConfirmPassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                color: Colors.white.withOpacity(0.6),
              ),
              onPressed: () {
                setState(() {
                  _obscureConfirmPassword = !_obscureConfirmPassword;
                });
              },
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Confirma tu contraseña';
              }
              if (value != _passwordController.text) {
                return 'Las contraseñas no coinciden';
              }
              return null;
            },
            onFieldSubmitted: (_) => _handleRegister(),
          ),
        ],
      ),
    );
  }

  Widget _buildRoleSelector() {
    const accentAmber = Color(0xFFFFA500);
    
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tipo de cuenta',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Colors.white.withOpacity(0.9),
            ),
          ),
          const SizedBox(height: 12),
          
          // Cliente
          RadioListTile<String>(
            value: 'client',
            groupValue: _selectedRole,
            activeColor: accentAmber,
            contentPadding: EdgeInsets.zero,
            onChanged: (value) {
              setState(() {
                _selectedRole = value!;
              });
            },
            title: Text(
              'Cliente',
              style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 14),
            ),
            subtitle: Text(
              'Para explorar bares, ver menús y promociones',
              style: TextStyle(
                color: Colors.white.withOpacity(0.5),
                fontSize: 11,
              ),
            ),
            secondary: Icon(
              Icons.person,
              color: _selectedRole == 'client' ? accentAmber : Colors.white.withOpacity(0.5),
            ),
          ),

          const SizedBox(height: 4),

          // Propietario
          RadioListTile<String>(
            value: 'owner',
            groupValue: _selectedRole,
            activeColor: accentAmber,
            contentPadding: EdgeInsets.zero,
            onChanged: (value) {
              setState(() {
                _selectedRole = value!;
              });
            },
            title: Text(
              'Propietario de Bar',
              style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 14),
            ),
            subtitle: Text(
              'Para gestionar tu bar, menús y promociones',
              style: TextStyle(
                color: Colors.white.withOpacity(0.5),
                fontSize: 11,
              ),
            ),
            secondary: Icon(
              Icons.store,
              color: _selectedRole == 'owner' ? accentAmber : Colors.white.withOpacity(0.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTermsCheckbox() {
    const accentAmber = Color(0xFFFFA500);
    
    return Row(
      children: [
        SizedBox(
          height: 24,
          width: 24,
          child: Checkbox(
            value: _acceptTerms,
            activeColor: accentAmber,
            checkColor: const Color(0xFF1A1A2E),
            side: BorderSide(color: Colors.white.withOpacity(0.3)),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
            onChanged: (value) {
              setState(() {
                _acceptTerms = value ?? false;
              });
            },
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: GestureDetector(
            onTap: () {
              setState(() {
                _acceptTerms = !_acceptTerms;
              });
            },
            child: Text.rich(
              TextSpan(
                text: 'Acepto los ',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 13,
                ),
                children: [
                  TextSpan(
                    text: 'Términos y Condiciones',
                    style: TextStyle(
                      color: accentAmber,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const TextSpan(text: ' y '),
                  TextSpan(
                    text: 'Política de Privacidad',
                    style: TextStyle(
                      color: accentAmber,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRegisterButton() {
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
        onPressed: _handleRegister,
        style: ElevatedButton.styleFrom(
          backgroundColor: accentAmber,
          foregroundColor: const Color(0xFF1A1A2E),
          minimumSize: const Size(double.infinity, 50),
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
                'CREAR CUENTA',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
      ),
    );
  }
}