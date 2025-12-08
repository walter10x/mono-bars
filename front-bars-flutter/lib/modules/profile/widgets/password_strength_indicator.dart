import 'package:flutter/material.dart';

import '../models/profile_models.dart';

/// Widget indicador de fortaleza de contraseña
class PasswordStrengthIndicator extends StatelessWidget {
  final PasswordStrength strength;

  const PasswordStrengthIndicator({
    super.key,
    required this.strength,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Barras de indicador
        Row(
          children: List.generate(4, (index) {
            final isActive = index < (strength.value * 4).ceil();
            return Expanded(
              child: Container(
                height: 4,
                margin: EdgeInsets.only(
                  right: index < 3 ? 8 : 0,
                ),
                decoration: BoxDecoration(
                  color: isActive
                      ? Color(strength.colorValue)
                      : Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            );
          }),
        ),

        const SizedBox(height: 8),

        // Label de fortaleza
        Text(
          strength.label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Color(strength.colorValue),
          ),
        ),
      ],
    );
  }
}

/// Widget para mostrar requisitos de contraseña
class PasswordRequirementsWidget extends StatelessWidget {
  final Map<String, bool> requirements;

  const PasswordRequirementsWidget({
    super.key,
    required this.requirements,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF6366F1).withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF6366F1).withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline,
                size: 18,
                color: const Color(0xFF6366F1),
              ),
              const SizedBox(width: 8),
              Text(
                'Requisitos de contraseña:',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildRequirement(
            'Mínimo 8 caracteres',
            requirements['length'] ?? false,
          ),
          const SizedBox(height: 6),
          _buildRequirement(
            'Una letra mayúscula',
            requirements['uppercase'] ?? false,
          ),
          const SizedBox(height: 6),
          _buildRequirement(
            'Un número',
            requirements['number'] ?? false,
          ),
          const SizedBox(height: 6),
          _buildRequirement(
            'Un símbolo (!@#\$%^&*)',
            requirements['symbol'] ?? false,
          ),
        ],
      ),
    );
  }

  Widget _buildRequirement(String text, bool isMet) {
    return Row(
      children: [
        Icon(
          isMet ? Icons.check_circle : Icons.circle_outlined,
          size: 16,
          color: isMet ? const Color(0xFF10B981) : Colors.grey.shade400,
        ),
        const SizedBox(width: 8),
        Text(
          text,
          style: TextStyle(
            fontSize: 13,
            color: isMet ? Colors.grey.shade700 : Colors.grey.shade500,
            fontWeight: isMet ? FontWeight.w500 : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}
