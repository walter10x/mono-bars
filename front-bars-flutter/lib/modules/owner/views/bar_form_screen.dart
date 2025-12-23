import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:front_bars_flutter/core/utils/extensions.dart';
import 'package:front_bars_flutter/shared/widgets/image_picker_widget.dart';
import 'package:front_bars_flutter/shared/widgets/loading_overlay.dart';
import 'package:front_bars_flutter/modules/bars/controllers/bars_controller.dart';
import 'package:front_bars_flutter/modules/bars/models/bar_models.dart';
import 'package:front_bars_flutter/core/services/image_upload_service.dart';

/// Pantalla para crear o editar un bar
/// Rediseñada con tema oscuro premium
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
  // Colores del tema oscuro premium
  static const backgroundColor = Color(0xFF0F0F1E);
  static const primaryDark = Color(0xFF1A1A2E);
  static const secondaryDark = Color(0xFF16213E);
  static const accentAmber = Color(0xFFFFA500);
  static const accentGold = Color(0xFFFFB84D);

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
  File? _selectedImage;
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    _isEditMode = widget.barId != null;

    if (_isEditMode) {
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

    setState(() => _isUploading = true);

    SocialLinks? socialLinks;
    if (_facebookController.text.isNotEmpty ||
        _instagramController.text.isNotEmpty) {
      socialLinks = SocialLinks(
        facebook:
            _facebookController.text.isEmpty ? null : _facebookController.text,
        instagram: _instagramController.text.isEmpty
            ? null
            : _instagramController.text,
      );
    }

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

      if (success && _selectedImage != null && widget.barId != null) {
        await _uploadImage(widget.barId!);
      }

      if (success && mounted) {
        context.showSuccessSnackBar('Bar actualizado exitosamente');
        context.pop();
      }
    } else {
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

      success =
          await ref.read(barsControllerProvider.notifier).createBar(request);

      if (success && _selectedImage != null) {
        final createdBar = ref.read(barsControllerProvider).bars.lastOrNull;
        if (createdBar != null) {
          await _uploadImage(createdBar.id);
        }
      }

      if (success && mounted) {
        context.showSuccessSnackBar('Bar creado exitosamente');
        context.pop();
      }
    }

    if (!success && mounted) {
      context.showErrorSnackBar('Error al guardar el bar');
    }

    setState(() => _isUploading = false);
  }

  Future<void> _uploadImage(String barId) async {
    if (_selectedImage == null) return;

    try {
      final uploadService = ref.read(imageUploadServiceProvider);
      await uploadService.uploadBarImage(barId, _selectedImage!);

      if (mounted) {
        context.showSuccessSnackBar('Foto subida exitosamente');
      }
    } catch (e) {
      if (mounted) {
        context.showErrorSnackBar('Error al subir foto: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final barsState = ref.watch(barsControllerProvider);
    final isLoading =
        _isEditMode ? barsState.isUpdating : barsState.isCreating;

    ref.listen(barsControllerProvider, (previous, current) {
      if (current.hasError) {
        context.showErrorSnackBar(current.errorMessage!);
        ref.read(barsControllerProvider.notifier).clearError();
      }
    });

    return LoadingOverlay(
      isLoading: isLoading || _isUploading,
      child: Scaffold(
        backgroundColor: backgroundColor,
        body: SafeArea(
          child: Column(
            children: [
              // Header
              _buildHeader(),

              // Form content
              Expanded(
                child: Form(
                  key: _formKey,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 8),

                        // Información básica
                        _buildSectionTitle(
                            'Información Básica', Icons.info_outline),
                        const SizedBox(height: 16),

                        _buildTextField(
                          controller: _nameController,
                          label: 'Nombre del Bar',
                          hint: 'Ej: El Rincón del Jazz',
                          icon: Icons.storefront,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'El nombre es requerido';
                            }
                            if (value.length < 3) {
                              return 'El nombre debe tener al menos 3 caracteres';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 16),

                        _buildTextField(
                          controller: _locationController,
                          label: 'Ubicación',
                          hint: 'Ej: Calle Mayor 45, Madrid',
                          icon: Icons.location_on,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'La ubicación es requerida';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 16),

                        _buildTextField(
                          controller: _descriptionController,
                          label: 'Descripción',
                          hint: 'Describe tu bar...',
                          icon: Icons.description,
                          maxLines: 3,
                        ),

                        const SizedBox(height: 32),

                        // Contacto
                        _buildSectionTitle(
                            'Información de Contacto', Icons.contact_phone),
                        const SizedBox(height: 16),

                        _buildTextField(
                          controller: _phoneController,
                          label: 'Teléfono',
                          hint: '+34 123 456 789',
                          icon: Icons.phone,
                          keyboardType: TextInputType.phone,
                        ),

                        const SizedBox(height: 32),

                        // Redes sociales
                        _buildSectionTitle('Redes Sociales', Icons.share),
                        const SizedBox(height: 16),

                        _buildTextField(
                          controller: _facebookController,
                          label: 'Facebook',
                          hint: 'URL de tu página de Facebook',
                          icon: Icons.facebook,
                          keyboardType: TextInputType.url,
                        ),

                        const SizedBox(height: 16),

                        _buildTextField(
                          controller: _instagramController,
                          label: 'Instagram',
                          hint: 'URL de tu perfil de Instagram',
                          icon: Icons.camera_alt,
                          keyboardType: TextInputType.url,
                        ),

                        const SizedBox(height: 32),

                        // Foto
                        _buildSectionTitle('Foto del Bar', Icons.image),
                        const SizedBox(height: 16),

                        ImagePickerWidget(
                          initialImageUrl: _photoController.text.isNotEmpty
                              ? _photoController.text
                              : null,
                          label: 'Foto del Bar',
                          onImageSelected: (file) {
                            setState(() {
                              _selectedImage = file;
                            });
                          },
                        ),

                        const SizedBox(height: 32),

                        // Horarios
                        _buildHoursSection(),

                        const SizedBox(height: 32),

                        // Botones de acción
                        _buildActionButtons(isLoading),

                        const SizedBox(height: 32),
                      ],
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

  Widget _buildHeader() {
    return Container(
      margin: const EdgeInsets.all(24.0),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            primaryDark,
            secondaryDark,
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: accentAmber.withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: accentAmber.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          // Back button
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => context.pop(),
              borderRadius: BorderRadius.circular(10),
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: accentAmber.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.arrow_back,
                  color: accentAmber,
                  size: 20,
                ),
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
                    colors: [accentAmber, accentGold],
                  ).createShader(bounds),
                  child: Text(
                    _isEditMode ? 'Editar Bar' : 'Crear Nuevo Bar',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _isEditMode
                      ? 'Actualiza la información de tu bar'
                      : 'Completa los datos de tu nuevo bar',
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

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: accentAmber.withOpacity(0.15),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: accentAmber,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
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
            prefixIcon: Icon(icon, color: Colors.white.withOpacity(0.5)),
            filled: true,
            fillColor: primaryDark,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: accentAmber.withOpacity(0.2),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: accentAmber.withOpacity(0.2),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: accentAmber,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Color(0xFFEF4444),
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Color(0xFFEF4444),
                width: 2,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHoursSection() {
    return Container(
      decoration: BoxDecoration(
        color: primaryDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: accentAmber.withOpacity(0.2),
        ),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(
          dividerColor: Colors.transparent,
        ),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          iconColor: accentAmber,
          collapsedIconColor: Colors.white.withOpacity(0.5),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: accentAmber.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.access_time,
                  color: accentAmber,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Horarios de Apertura',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(left: 44, top: 4),
            child: Text(
              'Opcional - Expande para configurar',
              style: TextStyle(
                fontSize: 12,
                color: Colors.white.withOpacity(0.5),
              ),
            ),
          ),
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: _buildDayHoursFields(),
              ),
            ),
          ],
        ),
      ),
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
        color: secondaryDark,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isActive ? accentAmber.withOpacity(0.5) : Colors.transparent,
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
                  color: isActive ? Colors.white : Colors.white.withOpacity(0.5),
                ),
              ),
              Switch(
                value: isActive,
                onChanged: (value) {
                  setState(() {
                    if (value) {
                      _hours[dayKey] =
                          const DayHours(open: '09:00', close: '22:00');
                    } else {
                      _hours[dayKey] = null;
                    }
                  });
                },
                activeColor: accentAmber,
                activeTrackColor: accentAmber.withOpacity(0.3),
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
            color: Colors.white.withOpacity(0.6),
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        TextField(
          controller: controller,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'HH:MM',
            hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 10,
            ),
            filled: true,
            fillColor: primaryDark,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: accentAmber.withOpacity(0.3)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: accentAmber.withOpacity(0.3)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: accentAmber),
            ),
          ),
          keyboardType: TextInputType.datetime,
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildActionButtons(bool isLoading) {
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
                  border: Border.all(
                    color: Colors.white.withOpacity(0.2),
                  ),
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
              onTap: isLoading ? null : _handleSubmit,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [accentAmber, accentGold],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: accentAmber.withOpacity(0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Center(
                  child: isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.black,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          _isEditMode ? 'Actualizar Bar' : 'Crear Bar',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
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
