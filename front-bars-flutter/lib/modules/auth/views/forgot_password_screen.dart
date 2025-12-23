import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/utils/extensions.dart';
import '../../../shared/widgets/custom_button.dart';
import '../../../shared/widgets/custom_text_field.dart';
import '../../../shared/widgets/loading_overlay.dart';
import '../models/auth_models.dart';
import '../services/auth_service.dart';

/// Pantalla de "Olvidé mi contraseña"
class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isLoading = false;
  bool _emailSent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _handleSendReset() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final email = _emailController.text.trim();
    final request = ForgotPasswordRequest(email: email);

    final result = await ref.read(authServiceProvider).forgotPassword(request);

result.fold(
      (failure) {
        setState(() => _isLoading = false);
        if (mounted) {
          context.showErrorSnackBar(failure.message);
        }
      },
      (_) {
        setState(() {
          _isLoading = false;
          _emailSent = true;
        });
      },
    );
  }

  void _handleBackToLogin() {
    context.go('/login');
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
                height: 320,
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
                        child: Icon(
                          _emailSent ? Icons.mark_email_read : Icons.lock_reset,
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
                        child: Text(
                          _emailSent ? '¡Revisa tu Email!' : 'Recupera tu Cuenta',
                          style: const TextStyle(
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
                          _emailSent
                              ? 'Te hemos enviado un enlace para restablecer tu contraseña'
                              : 'Ingresa tu email y te enviaremos un enlace para restablecer tu contraseña',
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

              // Content Card
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
                    child: _emailSent ? _buildSuccessContent() : _buildForm(),
                  ),
                ),
              ),

              // Back to Login Button
              Padding(
                padding: const EdgeInsets.only(bottom: 40),
                child: TextButton.icon(
                  onPressed: _handleBackToLogin,
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
          CustomTextField(
            controller: _emailController,
            hint: 'Correo electrónico',
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.done,
            prefixIcon: Icons.email_rounded,
            focusedBorderColor: accentAmber,
            textStyle: const TextStyle(color: Colors.white),
            fillColor: Colors.white.withOpacity(0.05),
            borderColor: Colors.white.withOpacity(0.15),
            hintStyle: TextStyle(color: Colors.white.withOpacity(0.4)),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'El email es requerido';
              }
              if (!value.isValidEmail) {
                return 'Ingresa un email válido';
              }
              return null;
            },
            onFieldSubmitted: (_) => _handleSendReset(),
          ),
          const SizedBox(height: 28),
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
              onPressed: _handleSendReset,
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
                'ENVIAR ENLACE',
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

  Widget _buildSuccessContent() {
    const accentGold = Color(0xFFFFB84D);
    const accentAmber = Color(0xFFFFA500);
    
    return Column(
      children: [
        // Success Icon
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.green.withOpacity(0.1),
            borderRadius: BorderRadius.circular(100),
          ),
          child: const Icon(
            Icons.check_circle_outline,
            size: 60,
            color: Colors.green,
          ),
        ),
        const SizedBox(height: 20),
        Text(
          '¡Listo!',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white.withOpacity(0.95),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Hemos enviado un correo a:',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            color: Colors.white.withOpacity(0.7),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          _emailController.text.trim(),
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: accentGold,
          ),
        ),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.blue.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.info_outline,
                color: Colors.blue.shade300,
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Revisa tu bandeja de entrada y copia el código del correo',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.blue.shade200,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        // Botón para ir a ingresar el código
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
          child: ElevatedButton.icon(
            onPressed: () => context.go('/reset-password'),
            icon: const Icon(Icons.vpn_key),
            label: const Text(
              'YA TENGO EL CÓDIGO',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                letterSpacing: 1,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: accentAmber,
              foregroundColor: const Color(0xFF1A1A2E),
              minimumSize: const Size(double.infinity, 52),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              elevation: 0,
            ),
          ),
        ),
      ],
    );
  }
}
