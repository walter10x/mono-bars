import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:formz/formz.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/utils/extensions.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/custom_text_field.dart';
import '../../../shared/widgets/loading_overlay.dart';
import '../controllers/auth_controller.dart';

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
    Navigator.pushNamed(context, '/forgot-password');
  }

  void _handleRegister() {
    // Navegar a pantalla de registro
    Navigator.pushNamed(context, '/register');
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
      } else if (current.isAuthenticated) {
        // Navegar a la pantalla principal
        Navigator.pushReplacementNamed(context, '/home');
      }
    });

    return LoadingOverlay(
      isLoading: isLoading,
      child: Scaffold(
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppConstants.defaultPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 60),
                
                // Logo y título
                _buildHeader(),
                
                const SizedBox(height: 60),
                
                // Formulario de login
                _buildLoginForm(),
                
                const SizedBox(height: 24),
                
                // Botón de login
                _buildLoginButton(),
                
                const SizedBox(height: 16),
                
                // ¿Olvidaste tu contraseña?
                _buildForgotPasswordButton(),
                
                const SizedBox(height: 32),
                
                // Divisor
                _buildDivider(),
                
                const SizedBox(height: 32),
                
                // Botón de registro
                _buildRegisterButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        // Logo (puedes agregar tu logo aquí)
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor,
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Icon(
            Icons.local_bar,
            color: Colors.white,
            size: 40,
          ),
        ),
        
        const SizedBox(height: 24),
        
        Text(
          'Bienvenido',
          style: context.textTheme.headlineLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        
        const SizedBox(height: 8),
        
        Text(
          'Inicia sesión para continuar',
          style: context.textTheme.bodyLarge?.copyWith(
            color: context.colors.onSurface.withOpacity(0.6),
          ),
        ),
      ],
    );
  }

  Widget _buildLoginForm() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          // Campo de email
          CustomTextField(
            controller: _emailController,
            label: 'Email',
            hint: 'Ingresa tu email',
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            prefixIcon: Icons.email_outlined,
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
          
          const SizedBox(height: 16),
          
          // Campo de contraseña
          CustomTextField(
            controller: _passwordController,
            label: 'Contraseña',
            hint: 'Ingresa tu contraseña',
            obscureText: _obscurePassword,
            textInputAction: TextInputAction.done,
            prefixIcon: Icons.lock_outline,
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword ? Icons.visibility : Icons.visibility_off,
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
                return 'La contraseña debe tener al menos ${AppConstants.minPasswordLength} caracteres';
              }
              return null;
            },
            onFieldSubmitted: (_) => _handleLogin(),
          ),
          
          const SizedBox(height: 16),
          
          // Recordarme
          Row(
            children: [
              Checkbox(
                value: _rememberMe,
                onChanged: (value) {
                  setState(() {
                    _rememberMe = value ?? false;
                  });
                },
              ),
              Text(
                'Recordarme',
                style: context.textTheme.bodyMedium,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLoginButton() {
    return CustomButton(
      onPressed: _handleLogin,
      text: 'Iniciar Sesión',
      isLoading: ref.watch(authLoadingProvider),
    );
  }

  Widget _buildForgotPasswordButton() {
    return TextButton(
      onPressed: _handleForgotPassword,
      child: const Text('¿Olvidaste tu contraseña?'),
    );
  }

  Widget _buildDivider() {
    return Row(
      children: [
        const Expanded(child: Divider()),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'O',
            style: context.textTheme.bodyMedium?.copyWith(
              color: context.colors.onSurface.withOpacity(0.6),
            ),
          ),
        ),
        const Expanded(child: Divider()),
      ],
    );
  }

  Widget _buildRegisterButton() {
    return OutlinedButton(
      onPressed: _handleRegister,
      child: const Text('Crear Cuenta Nueva'),
    );
  }
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
