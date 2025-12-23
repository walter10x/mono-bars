import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_constants.dart';
import '../../../shared/widgets/custom_text_field.dart';
import '../../../shared/widgets/loading_overlay.dart';
import '../models/auth_models.dart';
import '../services/auth_service.dart';

/// Pantalla para restablecer contraseña con token
class ResetPasswordScreen extends ConsumerStatefulWidget {
  final String? token;
  
  const ResetPasswordScreen({
    super.key,
    this.token,
  });

  @override
  ConsumerState<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends ConsumerState<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _tokenController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Si viene con token por query param, auto-llenarlo
    if (widget.token != null && widget.token!.isNotEmpty) {
      _tokenController.text = widget.token!;
    }
  }

  @override
  void dispose() {
    _tokenController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleResetPassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final token = _tokenController.text.trim();
    final newPassword = _passwordController.text;
    
    final request = ResetPasswordRequest(
      token: token,
      newPassword: newPassword,
      confirmPassword: newPassword,
    );

    final result = await ref.read(authServiceProvider).resetPassword(request);

    setState(() => _isLoading = false);

    result.fold(
      (failure) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(failure.message),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      (_) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Contraseña restablecida exitosamente'),
              backgroundColor: Colors.green,
            ),
          );
          // Navegar al login después de 1 segundo
          Future.delayed(const Duration(seconds: 1), () {
            if (mounted) {
              context.go('/login');
            }
          });
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    const primaryDark = Color(0xFF1A1A2E);
    const secondaryDark = Color(0xFF16213E);
    const accentAmber = Color(0xFFFFA500);
    const accentGold = Color(0xFFFFB84D);

    return LoadingOverlay(
      isLoading: _isLoading,
      child: Scaffold(
        backgroundColor: const Color(0xFF0F0F1E),
        body: SingleChildScrollView(
          child: Column(
            children: [
              // Header Premium
              Container(
                height: 300,
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
                      // Ícono
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: accentAmber.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(50),
                          boxShadow: [
                            BoxShadow(
                              color: accentAmber.withOpacity(0.3),
                              blurRadius: 25,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.vpn_key,
                          size: 50,
                          color: accentAmber,
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Título
                      ShaderMask(
                        shaderCallback: (bounds) => const LinearGradient(
                          colors: [accentAmber, accentGold],
                        ).createShader(bounds),
                        child: const Text(
                          'Nueva Contraseña',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Subtítulo
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 30),
                        child: Text(
                          'Ingresa tu nueva contraseña y el código de verificación',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white.withOpacity(0.8),
                            height: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Form Card
              Transform.translate(
                offset: const Offset(0, -30),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 28),
                  child: Container(
                    padding: const EdgeInsets.all(28),
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
                    child: _buildForm(),
                  ),
                ),
              ),

              // Back to Login Button
              Padding(
                padding: const EdgeInsets.only(bottom: 40),
                child: TextButton.icon(
                  onPressed: () => context.go('/login'),
                  icon: const Icon(Icons.arrow_back, color: accentAmber),
                  label: const Text(
                    'Volver al Login',
                    style: TextStyle(
                      color: accentAmber,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildForm() {
    const accentAmber = Color(0xFFFFA500);
    
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Token Input (solo si no viene por query param)
          if (widget.token == null || widget.token!.isEmpty)
            Column(
              children: [
                CustomTextField(
                  controller: _tokenController,
                  hint: 'Código de verificación',
                  textInputAction: TextInputAction.next,
                  prefixIcon: Icons.key,
                  focusedBorderColor: accentAmber,
                  textStyle: const TextStyle(color: Colors.white),
                  fillColor: Colors.white.withOpacity(0.05),
                  borderColor: Colors.white.withOpacity(0.15),
                  hintStyle: TextStyle(color: Colors.white.withOpacity(0.4)),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'El código es requerido';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
              ],
            ),
          
          // Nueva Contraseña
          CustomTextField(
            controller: _passwordController,
            hint: 'Nueva contraseña',
            obscureText: _obscurePassword,
            textInputAction: TextInputAction.next,
            prefixIcon: Icons.lock_rounded,
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
          const SizedBox(height: 16),
          
          // Confirmar Contraseña
          CustomTextField(
            controller: _confirmPasswordController,
            hint: 'Confirmar contraseña',
            obscureText: _obscureConfirmPassword,
            textInputAction: TextInputAction.done,
            prefixIcon: Icons.lock_outline_rounded,
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
                return 'Por favor confirma tu contraseña';
              }
              if (value != _passwordController.text) {
                return 'Las contraseñas no coinciden';
              }
              return null;
            },
            onFieldSubmitted: (_) => _handleResetPassword(),
          ),
          const SizedBox(height: 28),
          
          // Botón de restablecer
          Container(
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
              onPressed: _handleResetPassword,
              style: ElevatedButton.styleFrom(
                backgroundColor: accentAmber,
                foregroundColor: const Color(0xFF1A1A2E),
                minimumSize: const Size(double.infinity, 56),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 0,
              ),
              child: const Text(
                'RESTABLECER CONTRASEÑA',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
