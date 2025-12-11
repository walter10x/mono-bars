import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:front_bars_flutter/core/utils/extensions.dart';
import 'package:front_bars_flutter/shared/widgets/custom_button.dart';
import 'package:front_bars_flutter/shared/widgets/custom_text_field.dart';
import 'package:front_bars_flutter/shared/widgets/loading_overlay.dart';
import 'package:front_bars_flutter/modules/bars/controllers/bars_controller.dart';
import 'package:front_bars_flutter/modules/bars/models/bar_models.dart';

/// Pantalla para crear o editar un bar
class BarFormScreen extends ConsumerStatefulWidget {
  final String? barId; // null = crear, non-null = editar

  const BarFormScreen({
    super.key,
    this.barId,
  });

  @override
  ConsumerState<BarFormScreen> createState() => _BarFormScreenState();
}

class _BarFormScreenState extends ConsumerState<BarFormScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Controllers
  final _nameController = TextEditingController();
  final _locationController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _phoneController = TextEditingController();
  final _facebookController = TextEditingController();
  final _instagramController = TextEditingController();
  final _photoController = TextEditingController();

  // Horarios por día
  final Map<String, DayHours?> _hours = {
    'monday': null,
    'tuesday': null,
    'wednesday': null,
    'thursday': null,
    'friday': null,
    'saturday': null,
    'sunday': null,
  };

  bool _isEditMode = false;
  Bar? _currentBar;

  @override
  void initState() {
    super.initState();
    _isEditMode = widget.barId != null;
    
    if (_isEditMode) {
      // Cargar datos del bar para editar
      Future.microtask(() => _loadBarData());
    }
  }

  Future<void> _loadBarData() async {
    if (widget.barId == null) return;
    
    await ref.read(barsControllerProvider.notifier).loadBar(widget.barId!);
    final barsState = ref.read(barsControllerProvider);
    
    if (barsState.selectedBar != null) {
      _currentBar = barsState.selectedBar;
      _populateForm(_currentBar!);
    }
  }

  void _populateForm(Bar bar) {
    _nameController.text = bar.nameBar;
    _locationController.text = bar.location;
    _descriptionController.text = bar.description ?? '';
    _phoneController.text = bar.phone ?? '';
    _facebookController.text = bar.socialLinks?.facebook ?? '';
    _instagramController.text = bar.socialLinks?.instagram ?? '';
    _photoController.text = bar.photo ?? '';

    // Cargar horarios
    if (bar.hours != null) {
      setState(() {
        _hours['monday'] = bar.hours!.monday;
        _hours['tuesday'] = bar.hours!.tuesday;
        _hours['wednesday'] = bar.hours!.wednesday;
        _hours['thursday'] = bar.hours!.thursday;
        _hours['friday'] = bar.hours!.friday;
        _hours['saturday'] = bar.hours!.saturday;
        _hours['sunday'] = bar.hours!.sunday;
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _locationController.dispose();
    _descriptionController.dispose();
    _phoneController.dispose();
    _facebookController.dispose();
    _instagramController.dispose();
    _photoController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    // Crear social links
    SocialLinks? socialLinks;
    if (_facebookController.text.isNotEmpty ||
        _instagramController.text.isNotEmpty) {
      socialLinks = SocialLinks(
        facebook: _facebookController.text.isEmpty
            ? null
            : _facebookController.text,
        instagram: _instagramController.text.isEmpty
            ? null
            : _instagramController.text,
      );
    }

    // Crear horarios
    WeekHours? weekHours;
    if (_hours.values.any((h) => h != null)) {
      weekHours = WeekHours(
        monday: _hours['monday'],
        tuesday: _hours['tuesday'],
        wednesday: _hours['wednesday'],
        thursday: _hours['thursday'],
        friday: _hours['friday'],
        saturday: _hours['saturday'],
        sunday: _hours['sunday'],
      );
    }

    bool success = false;

    if (_isEditMode) {
      // Actualizar bar
      final request = UpdateBarRequest(
        nameBar: _nameController.text.trim(),
        location: _locationController.text.trim(),
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        phone: _phoneController.text.trim().isEmpty
            ? null
            : _phoneController.text.trim(),
        photo: _photoController.text.trim().isEmpty
            ? null
            : _photoController.text.trim(),
        socialLinks: socialLinks,
        hours: weekHours,
      );

      success = await ref
          .read(barsControllerProvider.notifier)
          .updateBar(widget.barId!, request);

      if (success && mounted) {
        context.showSuccessSnackBar('Bar actualizado exitosamente');
        context.pop();
      }
    } else {
      // Crear bar
      final request = CreateBarRequest(
        nameBar: _nameController.text.trim(),
        location: _locationController.text.trim(),
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        phone: _phoneController.text.trim().isEmpty
            ? null
            : _phoneController.text.trim(),
        photo: _photoController.text.trim().isEmpty
            ? null
            : _photoController.text.trim(),
        socialLinks: socialLinks,
        hours: weekHours,
      );

      success = await ref
          .read(barsControllerProvider.notifier)
          .createBar(request);

      if (success && mounted) {
        context.showSuccessSnackBar('Bar creado exitosamente');
        context.pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final barsState = ref.watch(barsControllerProvider);
    final isLoading = _isEditMode ? barsState.isUpdating : barsState.isCreating;

    // Listener para errores
    ref.listen(barsControllerProvider, (previous, current) {
      if (current.hasError) {
        context.showErrorSnackBar(current.errorMessage!);
        ref.read(barsControllerProvider.notifier).clearError();
      }
    });

    return LoadingOverlay(
      isLoading: isLoading,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text(_isEditMode ? 'Editar Bar' : 'Crear Nuevo Bar'),
          backgroundColor: const Color(0xFF6366F1),
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        body: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Información básica
                _buildSectionTitle('Información Básica', Icons.info_outline),
                const SizedBox(height: 16),
                
                CustomTextField(
                  controller: _nameController,
                  label: 'Nombre del Bar',
                  hint: 'Ej: El Rincón del Jazz',
                  prefixIcon: Icons.storefront,
                  textInputAction: TextInputAction.next,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'El nombre es requerido';
                    }
                    if (value.length < 3) {
                      return 'El nombre debe tener al menos 3 caracteres';
                    }
                    if (value.length > 100) {
                      return 'El nombre no puede tener más de 100 caracteres';
                    }
                    return null;
                  },
                ),
                
                const SizedBox(height: 16),
                
                CustomTextField(
                  controller: _locationController,
                  label: 'Ubicación',
                  hint: 'Ej: Calle Mayor 45, Madrid',
                  prefixIcon: Icons.location_on,
                  textInputAction: TextInputAction.next,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'La ubicación es requerida';
                    }
                    if (value.length < 5) {
                      return 'La ubicación debe ser más específica';
                    }
                    return null;
                  },
                ),
                
                const SizedBox(height: 16),
                
                CustomTextField(
                  controller: _descriptionController,
                  label: 'Descripción',
                  hint: 'Describe tu bar...',
                  prefixIcon: Icons.description,
                  textInputAction: TextInputAction.next,
                  maxLines: 3,
                  validator: (value) {
                    if (value != null && value.length > 500) {
                      return 'La descripción no puede tener más de 500 caracteres';
                    }
                    return null;
                  },
                ),
                
                const SizedBox(height: 32),
                
                // Contacto
                _buildSectionTitle('Información de Contacto', Icons.contact_phone),
                const SizedBox(height: 16),
                
                CustomTextField(
                  controller: _phoneController,
                  label: 'Teléfono',
                  hint: '+34 123 456 789',
                  prefixIcon: Icons.phone,
                  keyboardType: TextInputType.phone,
                  textInputAction: TextInputAction.next,
                  validator: (value) {
                    if (value != null && value.isNotEmpty) {
                      if (value.length < 9) {
                        return 'Ingresa un teléfono válido';
                      }
                    }
                    return null;
                  },
                ),
                
                const SizedBox(height: 32),
                
                // Redes sociales
                _buildSectionTitle('Redes Sociales', Icons.share),
                const SizedBox(height: 16),
                
                CustomTextField(
                  controller: _facebookController,
                  label: 'Facebook',
                  hint: 'URL de tu página de Facebook',
                  prefixIcon: Icons.facebook,
                  keyboardType: TextInputType.url,
                  textInputAction: TextInputAction.next,
                ),
                
                const SizedBox(height: 16),
                
                CustomTextField(
                  controller: _instagramController,
                  label: 'Instagram',
                  hint: 'URL de tu perfil de Instagram',
                  prefixIcon: Icons.camera_alt,
                  keyboardType: TextInputType.url,
                  textInputAction: TextInputAction.next,
                ),
                
                const SizedBox(height: 32),
                
                // Foto
                _buildSectionTitle('Foto del Bar', Icons.image),
                const SizedBox(height: 16),
                
                CustomTextField(
                  controller: _photoController,
                  label: 'URL de la Foto',
                  hint: 'https://ejemplo.com/foto.jpg',
                  prefixIcon: Icons.link,
                  keyboardType: TextInputType.url,
                  textInputAction: TextInputAction.done,
                ),
                
                const SizedBox(height: 8),
                Text(
                  'Próximamente: Subir foto desde tu dispositivo',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                
                const SizedBox(height: 32),
                
                // Horarios (collapsed por defecto)
                _buildHoursSection(),
                
                const SizedBox(height: 32),
                
                // Botones de acción
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => context.pop(),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          side: const BorderSide(color: Colors.grey),
                        ),
                        child: const Text('Cancelar'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 2,
                      child: CustomButton(
                        onPressed: _handleSubmit,
                        text: _isEditMode ? 'Actualizar Bar' : 'Crear Bar',
                        isLoading: isLoading,
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(
          icon,
          color: const Color(0xFF6366F1),
          size: 24,
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1F2937),
          ),
        ),
      ],
    );
  }

  Widget _buildHoursSection() {
    return ExpansionTile(
      tilePadding: EdgeInsets.zero,
      title: Row(
        children: [
          const Icon(
            Icons.access_time,
            color: Color(0xFF6366F1),
            size: 24,
          ),
          const SizedBox(width: 8),
          const Text(
            'Horarios de Apertura',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1F2937),
            ),
          ),
        ],
      ),
      subtitle: const Text(
        'Opcional - Expande para configurar',
        style: TextStyle(fontSize: 12),
      ),
      children: [
        const SizedBox(height: 16),
        ..._buildDayHoursFields(),
        const SizedBox(height: 16),
      ],
    );
  }

  List<Widget> _buildDayHoursFields() {
    final days = {
      'monday': 'Lunes',
      'tuesday': 'Martes',
      'wednesday': 'Miércoles',
      'thursday': 'Jueves',
      'friday': 'Viernes',
      'saturday': 'Sábado',
      'sunday': 'Domingo',
    };

    return days.entries.map((entry) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: _buildDayHourRow(entry.key, entry.value),
      );
    }).toList();
  }

  Widget _buildDayHourRow(String dayKey, String dayName) {
    final isActive = _hours[dayKey] != null;
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isActive ? const Color(0xFF6366F1) : Colors.grey.shade300,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                dayName,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isActive ? const Color(0xFF1F2937) : Colors.grey.shade600,
                ),
              ),
              Switch(
                value: isActive,
                onChanged: (value) {
                  setState(() {
                    if (value) {
                      _hours[dayKey] = const DayHours(open: '09:00', close: '22:00');
                    } else {
                      _hours[dayKey] = null;
                    }
                  });
                },
                activeColor: const Color(0xFF6366F1),
              ),
            ],
          ),
          if (isActive) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildTimeField(
                    label: 'Apertura',
                    initialValue: _hours[dayKey]?.open ?? '09:00',
                    onChanged: (value) {
                      setState(() {
                        _hours[dayKey] = DayHours(
                          open: value,
                          close: _hours[dayKey]?.close ?? '22:00',
                        );
                      });
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildTimeField(
                    label: 'Cierre',
                    initialValue: _hours[dayKey]?.close ?? '22:00',
                    onChanged: (value) {
                      setState(() {
                        _hours[dayKey] = DayHours(
                          open: _hours[dayKey]?.open ?? '09:00',
                          close: value,
                        );
                      });
                    },
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTimeField({
    required String label,
    required String initialValue,
    required Function(String) onChanged,
  }) {
    final controller = TextEditingController(text: initialValue);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade700,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: 'HH:MM',
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 8,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          keyboardType: TextInputType.datetime,
          onChanged: onChanged,
        ),
      ],
    );
  }
}
