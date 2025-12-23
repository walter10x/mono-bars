import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import 'package:front_bars_flutter/core/utils/extensions.dart';
import 'package:front_bars_flutter/modules/bars/controllers/bars_controller.dart';
import 'package:front_bars_flutter/modules/promotions/controllers/promotions_controller.dart';
import 'package:front_bars_flutter/modules/promotions/models/promotion_models.dart';

/// Pantalla de formulario para crear/editar promociones
/// Rediseñada con tema oscuro premium
class PromotionFormScreen extends ConsumerStatefulWidget {
  final String? promotionId;
  final String? barId;

  const PromotionFormScreen({
    super.key,
    this.promotionId,
    this.barId,
  });

  @override
  ConsumerState<PromotionFormScreen> createState() =>
      _PromotionFormScreenState();
}

class _PromotionFormScreenState extends ConsumerState<PromotionFormScreen> {
  // Colores del tema oscuro premium
  static const backgroundColor = Color(0xFF0F0F1E);
  static const primaryDark = Color(0xFF1A1A2E);
  static const secondaryDark = Color(0xFF16213E);
  static const accentAmber = Color(0xFFFFA500);
  static const accentGold = Color(0xFFFFB84D);
  static const promoAccent = Color(0xFFEC4899);

  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _discountController = TextEditingController();
  final _termsController = TextEditingController();

  String? _selectedBarId;
  DateTime? _validFrom;
  DateTime? _validUntil;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _selectedBarId = widget.barId;

    Future.microtask(() {
      ref.read(barsControllerProvider.notifier).loadMyBars();
      if (widget.promotionId != null) {
        // TODO: Cargar promoción existente para editar
      }
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _discountController.dispose();
    _termsController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStartDate
          ? (_validFrom ?? DateTime.now())
          : (_validUntil ?? DateTime.now().add(const Duration(days: 7))),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: promoAccent,
              onPrimary: Colors.white,
              surface: primaryDark,
              onSurface: Colors.white,
            ),
            dialogBackgroundColor: primaryDark,
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _validFrom = picked;
          if (_validUntil != null && _validUntil!.isBefore(picked)) {
            _validUntil = picked.add(const Duration(days: 7));
          }
        } else {
          _validUntil = picked;
        }
      });
    }
  }

  Future<void> _savePromotion() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedBarId == null) {
      context.showErrorSnackBar('Debes seleccionar un bar');
      return;
    }

    if (_validFrom == null || _validUntil == null) {
      context.showErrorSnackBar('Debes seleccionar las fechas de validez');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final request = CreatePromotionRequest(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim().isEmpty
            ? _titleController.text.trim()
            : _descriptionController.text.trim(),
        type: PromotionType.discount,
        barId: _selectedBarId!,
        discountPercentage: _discountController.text.isNotEmpty
            ? double.tryParse(_discountController.text)
            : null,
        startDate: _validFrom!,
        endDate: _validUntil!,
      );

      await ref
          .read(promotionsControllerProvider.notifier)
          .createPromotion(request);

      if (mounted) {
        context.showSuccessSnackBar('Promoción creada exitosamente');
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        context.showErrorSnackBar('Error al crear promoción: $e');
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final barsState = ref.watch(barsControllerProvider);
    final dateFormat = DateFormat('dd/MM/yyyy');

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: Form(
                key: _formKey,
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  children: [
                    const SizedBox(height: 8),
                    // Título
                    _buildTextField(
                      controller: _titleController,
                      label: 'Título',
                      hint: 'Ej: 2x1 en cervezas',
                      icon: Icons.title,
                      isRequired: true,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'El título es obligatorio';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    // Descripción
                    _buildTextField(
                      controller: _descriptionController,
                      label: 'Descripción',
                      hint: 'Describe la promoción',
                      icon: Icons.description,
                      maxLines: 3,
                    ),

                    const SizedBox(height: 16),

                    // Selector de Bar
                    if (barsState.status == BarsStatus.loaded &&
                        barsState.bars.isNotEmpty)
                      _buildBarSelector(barsState),

                    const SizedBox(height: 16),

                    // Porcentaje de descuento
                    _buildTextField(
                      controller: _discountController,
                      label: 'Descuento (%)',
                      hint: 'Ej: 20',
                      icon: Icons.percent,
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value != null && value.isNotEmpty) {
                          final number = double.tryParse(value);
                          if (number == null || number < 0 || number > 100) {
                            return 'Ingresa un porcentaje válido (0-100)';
                          }
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 24),

                    // Fechas
                    Row(
                      children: [
                        Expanded(
                          child: _buildDateSelector(
                            label: 'Fecha inicio',
                            value: _validFrom,
                            dateFormat: dateFormat,
                            onTap: () => _selectDate(context, true),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildDateSelector(
                            label: 'Fecha fin',
                            value: _validUntil,
                            dateFormat: dateFormat,
                            onTap: () => _selectDate(context, false),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Términos y condiciones
                    _buildTextField(
                      controller: _termsController,
                      label: 'Términos y condiciones',
                      hint: 'Condiciones de la promoción',
                      icon: Icons.article,
                      maxLines: 4,
                    ),

                    const SizedBox(height: 32),

                    // Botones de acción
                    _buildActionButtons(),

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      margin: const EdgeInsets.all(24.0),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [primaryDark, secondaryDark],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: promoAccent.withOpacity(0.2), width: 1),
        boxShadow: [
          BoxShadow(
            color: promoAccent.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => context.pop(),
              borderRadius: BorderRadius.circular(10),
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: promoAccent.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.arrow_back, color: promoAccent, size: 20),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShaderMask(
                  shaderCallback: (bounds) => const LinearGradient(
                    colors: [promoAccent, accentAmber],
                  ).createShader(bounds),
                  child: Text(
                    widget.promotionId == null
                        ? 'Nueva Promoción'
                        : 'Editar Promoción',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Crea ofertas irresistibles para tus clientes',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    bool isRequired = false,
    TextInputType? keyboardType,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          isRequired ? '$label *' : label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.white.withOpacity(0.8),
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          style: const TextStyle(color: Colors.white),
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
            prefixIcon: Icon(icon, color: promoAccent.withOpacity(0.7)),
            filled: true,
            fillColor: primaryDark,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: promoAccent.withOpacity(0.2)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: promoAccent.withOpacity(0.2)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: promoAccent, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFEF4444)),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
        ),
      ],
    );
  }

  Widget _buildBarSelector(BarsState barsState) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Bar *',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.white.withOpacity(0.8),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: primaryDark,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: promoAccent.withOpacity(0.2)),
          ),
          child: DropdownButtonFormField<String>(
            value: _selectedBarId,
            dropdownColor: primaryDark,
            style: const TextStyle(color: Colors.white, fontSize: 16),
            icon: Icon(Icons.keyboard_arrow_down, color: promoAccent),
            decoration: InputDecoration(
              prefixIcon:
                  Icon(Icons.store, color: promoAccent.withOpacity(0.7)),
              border: InputBorder.none,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            items: barsState.bars.map((bar) {
              return DropdownMenuItem<String>(
                value: bar.id,
                child: Text(bar.nameBar),
              );
            }).toList(),
            onChanged: widget.barId == null
                ? (value) {
                    setState(() {
                      _selectedBarId = value;
                    });
                  }
                : null,
            validator: (value) {
              if (value == null) {
                return 'Debes seleccionar un bar';
              }
              return null;
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDateSelector({
    required String label,
    required DateTime? value,
    required DateFormat dateFormat,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: primaryDark,
            border: Border.all(color: promoAccent.withOpacity(0.2)),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.calendar_today,
                      size: 16, color: promoAccent.withOpacity(0.7)),
                  const SizedBox(width: 8),
                  Text(
                    '$label *',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withOpacity(0.5),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                value != null ? dateFormat.format(value) : 'Seleccionar',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: value != null ? Colors.white : Colors.white.withOpacity(0.4),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => context.pop(),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: primaryDark,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white.withOpacity(0.2)),
                ),
                child: Center(
                  child: Text(
                    'Cancelar',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white.withOpacity(0.7),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          flex: 2,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: _isLoading ? null : _savePromotion,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [promoAccent, accentAmber],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: promoAccent.withOpacity(0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Center(
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Guardar Promoción',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
