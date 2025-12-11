import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import 'package:front_bars_flutter/core/utils/extensions.dart';
import 'package:front_bars_flutter/modules/bars/controllers/bars_controller.dart';
import 'package:front_bars_flutter/modules/promotions/controllers/promotions_controller.dart';
import 'package:front_bars_flutter/modules/promotions/models/promotion_models.dart';

/// Pantalla de formulario para crear/editar promociones
class PromotionFormScreen extends ConsumerStatefulWidget {
  final String? promotionId;
  final String? barId;

  const PromotionFormScreen({
    super.key,
    this.promotionId,
    this.barId,
  });

  @override
  ConsumerState<PromotionFormScreen> createState() => _PromotionFormScreenState();
}

class _PromotionFormScreenState extends ConsumerState<PromotionFormScreen> {
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
            colorScheme: const ColorScheme.light(
              primary: Color(0xFFEC4899),
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _validFrom = picked;
          // Si la fecha de fin es antes que la de inicio, ajustarla
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
    if (!_formKey.currentState!.validate()) {
      return;
    }

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
            ? _titleController.text.trim()  // Si no hay descripción, usar el título
            : _descriptionController.text.trim(),
        type: PromotionType.discount,  // Por defecto tipo descuento
        barId: _selectedBarId!,
        discountPercentage: _discountController.text.isNotEmpty
            ? double.tryParse(_discountController.text)
            : null,
        startDate: _validFrom!,
        endDate: _validUntil!,
      );

      await ref.read(promotionsControllerProvider.notifier).createPromotion(request);

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
      appBar: AppBar(
        title: Text(widget.promotionId == null ? 'Nueva Promoción' : 'Editar Promoción'),
        backgroundColor: const Color(0xFFEC4899),
        foregroundColor: Colors.white,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(24.0),
          children: [
            // Título
            TextFormField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: 'Título *',
                hintText: 'Ej: 2x1 en cervezas',
                prefixIcon: const Icon(Icons.title, color: Color(0xFFEC4899)),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFEC4899), width: 2),
                ),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'El título es obligatorio';
                }
                return null;
              },
            ),

            const SizedBox(height: 16),

            // Descripción
            TextFormField(
              controller: _descriptionController,
              decoration: InputDecoration(
                labelText: 'Descripción',
                hintText: 'Describe la promoción',
                prefixIcon: const Icon(Icons.description, color: Color(0xFFEC4899)),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFEC4899), width: 2),
                ),
              ),
              maxLines: 3,
            ),

            const SizedBox(height: 16),

            // Selector de Bar
            if (barsState.status == BarsStatus.loaded && barsState.bars.isNotEmpty)
              DropdownButtonFormField<String>(
                value: _selectedBarId,
                decoration: InputDecoration(
                  labelText: 'Bar *',
                  prefixIcon: const Icon(Icons.store, color: Color(0xFFEC4899)),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Color(0xFFEC4899), width: 2),
                  ),
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

            const SizedBox(height: 16),

            // Porcentaje de descuento
            TextFormField(
              controller: _discountController,
              decoration: InputDecoration(
                labelText: 'Descuento (%)',
                hintText: 'Ej: 20',
                prefixIcon: const Icon(Icons.percent, color: Color(0xFFEC4899)),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFEC4899), width: 2),
                ),
              ),
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
                  child: InkWell(
                    onTap: () => _selectDate(context, true),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.calendar_today, size: 16, color: Color(0xFFEC4899)),
                              SizedBox(width: 8),
                              Text(
                                'Fecha inicio *',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _validFrom != null
                                ? dateFormat.format(_validFrom!)
                                : 'Seleccionar',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: InkWell(
                    onTap: () => _selectDate(context, false),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.calendar_today, size: 16, color: Color(0xFFEC4899)),
                              SizedBox(width: 8),
                              Text(
                                'Fecha fin *',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _validUntil != null
                                ? dateFormat.format(_validUntil!)
                                : 'Seleccionar',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Términos y condiciones
            TextFormField(
              controller: _termsController,
              decoration: InputDecoration(
                labelText: 'Términos y condiciones',
                hintText: 'Condiciones de la promoción',
                prefixIcon: const Icon(Icons.article, color: Color(0xFFEC4899)),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFEC4899), width: 2),
                ),
              ),
              maxLines: 4,
            ),

            const SizedBox(height: 32),

            // Botón guardar
            ElevatedButton(
              onPressed: _isLoading ? null : _savePromotion,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFEC4899),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
              ),
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text(
                      'Guardar Promoción',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
