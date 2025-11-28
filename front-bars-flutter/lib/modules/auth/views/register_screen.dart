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

    return LoadingOverlay(
      isLoading: isLoading,
      child: Scaffold(
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppConstants.defaultPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 20),

                // Header con botón de volver
                _buildHeader(),

                const SizedBox(height: 40),

                // Formulario de registro
                _buildRegisterForm(),

                const SizedBox(height: 24),

                // Selector de tipo de cuenta
                _buildRoleSelector(),

                const SizedBox(height: 24),

                // Términos y condiciones
                _buildTermsCheckbox(),

                const SizedBox(height: 24),

                // Botón de registro
                _buildRegisterButton(),

                const SizedBox(height: 16),

                // Divisor
                _buildDivider(),

                const SizedBox(height: 16),

                // Botón de login
                _buildLoginButton(),
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
    return Form(
      key: _formKey,
      child: Column(
        children: [
          // Nombre completo
          CustomTextField(
            controller: _nameController,
            label: 'Nombre Completo',
            hint: 'Tu nombre completo',
            textInputAction: TextInputAction.next,
            prefixIcon: Icons.person_outline,
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

          const SizedBox(height: 16),

          // Email
          CustomTextField(
            controller: _emailController,
            label: 'Email',
            hint: 'tu@email.com',
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

          // Contraseña
          CustomTextField(
            controller: _passwordController,
            label: 'Contraseña',
            hint: 'Mínimo ${AppConstants.minPasswordLength} caracteres',
            obscureText: _obscurePassword,
            textInputAction: TextInputAction.next,
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
          ),

          const SizedBox(height: 16),

          // Confirmar contraseña
          CustomTextField(
            controller: _confirmPasswordController,
            label: 'Confirmar Contraseña',
            hint: 'Repite tu contraseña',
            obscureText: _obscureConfirmPassword,
            textInputAction: TextInputAction.done,
            prefixIcon: Icons.lock_outline,
            suffixIcon: IconButton(
              icon: Icon(
                _obscureConfirmPassword ? Icons.visibility : Icons.visibility_off,
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
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tipo de cuenta',
              style: context.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            // Cliente
            RadioListTile<String>(
              value: 'client',
              groupValue: _selectedRole,
              onChanged: (value) {
                setState(() {
                  _selectedRole = value!;
                });
              },
              title: const Text('Cliente'),
              subtitle: const Text(
                'Para explorar bares, ver menús y promociones',
              ),
              secondary: const Icon(Icons.person),
            ),

            // Propietario
            RadioListTile<String>(
              value: 'owner',
              groupValue: _selectedRole,
              onChanged: (value) {
                setState(() {
                  _selectedRole = value!;
                });
              },
              title: const Text('Propietario de Bar'),
              subtitle: const Text(
                'Para gestionar tu bar, menús y promociones',
              ),
              secondary: const Icon(Icons.store),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTermsCheckbox() {
    return Row(
      children: [
        Checkbox(
          value: _acceptTerms,
          onChanged: (value) {
            setState(() {
              _acceptTerms = value ?? false;
            });
          },
        ),
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
                children: [
                  TextSpan(
                    text: 'Términos y Condiciones',
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const TextSpan(text: ' y '),
                  TextSpan(
                    text: 'Política de Privacidad',
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              style: context.textTheme.bodyMedium,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRegisterButton() {
    return CustomButton(
      onPressed: _handleRegister,
      text: 'Crear Cuenta',
      isLoading: ref.watch(authLoadingProvider),
    );
  }

  Widget _buildDivider() {
    return Row(
      children: [
        const Expanded(child: Divider()),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            '¿Ya tienes cuenta?',
            style: context.textTheme.bodyMedium?.copyWith(
              color: context.colors.onSurface.withOpacity(0.6),
            ),
          ),
        ),
        const Expanded(child: Divider()),
      ],
    );
  }

  Widget _buildLoginButton() {
    return OutlinedButton(
      onPressed: _handleLogin,
      child: const Text('Iniciar Sesión'),
    );
  }
}