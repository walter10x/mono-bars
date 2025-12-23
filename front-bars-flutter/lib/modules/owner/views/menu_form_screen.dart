import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:front_bars_flutter/core/utils/extensions.dart';
import 'package:front_bars_flutter/shared/widgets/image_picker_widget.dart';
import 'package:front_bars_flutter/shared/widgets/loading_overlay.dart';
import 'package:front_bars_flutter/modules/bars/controllers/bars_controller.dart';
import 'package:front_bars_flutter/modules/menus/controllers/menus_controller.dart';
import 'package:front_bars_flutter/modules/menus/models/menu_models.dart';
import 'package:front_bars_flutter/core/services/image_upload_service.dart';

/// Pantalla para crear o editar un menú
/// Rediseñada con tema oscuro premium
class MenuFormScreen extends ConsumerStatefulWidget {
  final String? barId;
  final String? menuId;

  const MenuFormScreen({
    super.key,
    this.barId,
    this.menuId,
  });

  @override
  ConsumerState<MenuFormScreen> createState() => _MenuFormScreenState();
}

class _MenuFormScreenState extends ConsumerState<MenuFormScreen> {
  // Colores del tema oscuro premium
  static const backgroundColor = Color(0xFF0F0F1E);
  static const primaryDark = Color(0xFF1A1A2E);
  static const secondaryDark = Color(0xFF16213E);
  static const accentAmber = Color(0xFFFFA500);
  static const accentGold = Color(0xFFFFB84D);

  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _photoController = TextEditingController();

  final List<MenuItemForm> _items = [];

  String? _selectedBarId;
  bool _isEditMode = false;
  File? _selectedImage;
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    _selectedBarId = widget.barId;
    _isEditMode = widget.menuId != null;

    Future.microtask(() {
      ref.read(barsControllerProvider.notifier).loadMyBars();
      if (_isEditMode) {
        _loadMenuData();
      }
    });
  }

  Future<void> _loadMenuData() async {
    if (widget.menuId == null) return;

    await ref.read(menusControllerProvider.notifier).loadMenu(widget.menuId!);
    final menusState = ref.read(menusControllerProvider);

    if (menusState.selectedMenu != null) {
      final menu = menusState.selectedMenu!;
      _populateForm(menu);
    }
  }

  void _populateForm(Menu menu) {
    _nameController.text = menu.name;
    _descriptionController.text = menu.description ?? '';
    _photoController.text = menu.photoUrl ?? '';
    _selectedBarId = menu.barId;

    setState(() {
      _items.clear();
      for (final item in menu.items) {
        _items.add(MenuItemForm.fromMenuItem(item));
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _photoController.dispose();
    for (final item in _items) {
      item.dispose();
    }
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedBarId == null) {
      context.showErrorSnackBar('Debes seleccionar un bar');
      return;
    }

    setState(() => _isUploading = true);

    final items = _items
        .map((itemForm) => MenuItem(
              name: itemForm.nameController.text.trim(),
              description: itemForm.descriptionController.text.trim().isEmpty
                  ? null
                  : itemForm.descriptionController.text.trim(),
              price: double.parse(itemForm.priceController.text.trim()),
              photoUrl: itemForm.photoController.text.trim().isEmpty
                  ? null
                  : itemForm.photoController.text.trim(),
            ))
        .toList();

    bool success = false;

    if (_isEditMode) {
      final request = UpdateMenuRequest(
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        photoUrl: _photoController.text.trim().isEmpty
            ? null
            : _photoController.text.trim(),
        items: items,
      );

      success = await ref
          .read(menusControllerProvider.notifier)
          .updateMenu(widget.menuId!, request);

      if (success && _selectedImage != null && widget.menuId != null) {
        await _uploadImage(widget.menuId!);
      }

      if (success && mounted) {
        context.showSuccessSnackBar('Menú actualizado exitosamente');
        context.pop();
      }
    } else {
      final request = CreateMenuRequest(
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim().isEmpty
            ? null
            : _descriptionController.text.trim(),
        barId: _selectedBarId!,
        photoUrl: _photoController.text.trim().isEmpty
            ? null
            : _photoController.text.trim(),
        items: items.isEmpty ? null : items,
      );

      success =
          await ref.read(menusControllerProvider.notifier).createMenu(request);

      if (success && _selectedImage != null) {
        final createdMenu = ref.read(menusControllerProvider).menus.lastOrNull;
        if (createdMenu != null) {
          await _uploadImage(createdMenu.id);
        }
      }

      if (success && mounted) {
        context.showSuccessSnackBar('Menú creado exitosamente');
        context.pop();
      }
    }

    if (!success && mounted) {
      context.showErrorSnackBar('Error al guardar el menú');
    }

    setState(() => _isUploading = false);
  }

  Future<void> _uploadImage(String menuId) async {
    if (_selectedImage == null) return;

    try {
      final uploadService = ref.read(imageUploadServiceProvider);
      await uploadService.uploadMenuImage(menuId, _selectedImage!);

      if (mounted) {
        context.showSuccessSnackBar('Foto subida exitosamente');
      }
    } catch (e) {
      if (mounted) {
        context.showErrorSnackBar('Error al subir foto: $e');
      }
    }
  }

  void _addItem() {
    setState(() {
      _items.add(MenuItemForm());
    });
  }

  void _removeItem(int index) {
    setState(() {
      _items[index].dispose();
      _items.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    final menusState = ref.watch(menusControllerProvider);
    final barsState = ref.watch(barsControllerProvider);
    final isLoading =
        _isEditMode ? menusState.isUpdating : menusState.isCreating;

    ref.listen(menusControllerProvider, (previous, current) {
      if (current.hasError) {
        context.showErrorSnackBar(current.errorMessage!);
        ref.read(menusControllerProvider.notifier).clearError();
      }
    });

    return LoadingOverlay(
      isLoading: isLoading || _isUploading,
      child: Scaffold(
        backgroundColor: backgroundColor,
        body: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: Form(
                  key: _formKey,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 8),
                        _buildSectionTitle(
                            'Información Básica', Icons.info_outline),
                        const SizedBox(height: 16),
                        _buildTextField(
                          controller: _nameController,
                          label: 'Nombre del Menú',
                          hint: 'Ej: Carta de Bebidas',
                          icon: Icons.restaurant_menu,
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
                        if (widget.barId == null &&
                            barsState.status == BarsStatus.loaded)
                          _buildBarSelector(barsState),
                        _buildTextField(
                          controller: _descriptionController,
                          label: 'Descripción',
                          hint: 'Describe el menú...',
                          icon: Icons.description,
                          maxLines: 3,
                        ),
                        const SizedBox(height: 32),
                        _buildSectionTitle('Foto del Menú', Icons.image),
                        const SizedBox(height: 16),
                        ImagePickerWidget(
                          initialImageUrl: _photoController.text.isNotEmpty
                              ? _photoController.text
                              : null,
                          label: 'Foto del Menú',
                          onImageSelected: (file) {
                            setState(() {
                              _selectedImage = file;
                            });
                          },
                        ),
                        const SizedBox(height: 32),
                        _buildSectionTitle(
                            'Productos del Menú', Icons.inventory_2),
                        const SizedBox(height: 8),
                        Text(
                          'Agrega los productos que incluye este menú',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white.withOpacity(0.6),
                          ),
                        ),
                        const SizedBox(height: 16),
                        ..._items.asMap().entries.map((entry) {
                          final index = entry.key;
                          final item = entry.value;
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 16),
                            child: _buildItemEditor(item, index),
                          );
                        }),
                        _buildAddProductButton(),
                        const SizedBox(height: 32),
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
          colors: [primaryDark, secondaryDark],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: accentAmber.withOpacity(0.2), width: 1),
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
                child: Icon(Icons.arrow_back, color: accentAmber, size: 20),
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
                    _isEditMode ? 'Editar Menú' : 'Crear Nuevo Menú',
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
                      ? 'Actualiza la información del menú'
                      : 'Completa los datos del nuevo menú',
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
          child: Icon(icon, color: accentAmber, size: 20),
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
              borderSide: BorderSide(color: accentAmber.withOpacity(0.2)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: accentAmber.withOpacity(0.2)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: accentAmber, width: 2),
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
          'Bar',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.white.withOpacity(0.8),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: primaryDark,
            border: Border.all(color: accentAmber.withOpacity(0.2)),
            borderRadius: BorderRadius.circular(12),
          ),
          child: DropdownButton<String>(
            value: _selectedBarId,
            hint: Text(
              'Selecciona un bar',
              style: TextStyle(color: Colors.white.withOpacity(0.5)),
            ),
            isExpanded: true,
            underline: const SizedBox(),
            dropdownColor: primaryDark,
            icon: Icon(Icons.keyboard_arrow_down, color: accentAmber),
            style: const TextStyle(color: Colors.white, fontSize: 16),
            items: barsState.bars.map((bar) {
              return DropdownMenuItem(
                value: bar.id,
                child: Text(bar.nameBar),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedBarId = value;
              });
            },
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildItemEditor(MenuItemForm item, int index) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: secondaryDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: accentAmber.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: accentAmber.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '${index + 1}',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: accentAmber,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'Producto',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => _removeItem(index),
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEF4444).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.delete,
                      color: Color(0xFFEF4444),
                      size: 18,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildItemTextField(
            controller: item.nameController,
            label: 'Nombre *',
            hint: 'Ej: Cerveza Artesanal',
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'El nombre es requerido';
              }
              return null;
            },
          ),
          const SizedBox(height: 12),
          _buildItemTextField(
            controller: item.priceController,
            label: 'Precio *',
            hint: '0.00',
            prefix: '€ ',
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
            ],
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'El precio es requerido';
              }
              final price = double.tryParse(value);
              if (price == null || price <= 0) {
                return 'Ingresa un precio válido';
              }
              return null;
            },
          ),
          const SizedBox(height: 12),
          _buildItemTextField(
            controller: item.descriptionController,
            label: 'Descripción',
            hint: 'Descripción del producto...',
            maxLines: 2,
          ),
        ],
      ),
    );
  }

  Widget _buildItemTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    String? prefix,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      maxLines: maxLines,
      style: const TextStyle(color: Colors.white),
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.white.withOpacity(0.6)),
        hintText: hint,
        hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
        prefixText: prefix,
        prefixStyle: TextStyle(color: accentAmber),
        filled: true,
        fillColor: primaryDark,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: accentAmber.withOpacity(0.3)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: accentAmber.withOpacity(0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: accentAmber),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      ),
    );
  }

  Widget _buildAddProductButton() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: _addItem,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: accentAmber.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: accentAmber.withOpacity(0.3)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.add, color: accentAmber, size: 20),
              const SizedBox(width: 8),
              Text(
                'Agregar Producto',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: accentAmber,
                ),
              ),
            ],
          ),
        ),
      ),
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
                          _isEditMode ? 'Actualizar Menú' : 'Crear Menú',
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

/// Clase para manejar los campos de un item del menú
class MenuItemForm {
  final TextEditingController nameController;
  final TextEditingController descriptionController;
  final TextEditingController priceController;
  final TextEditingController photoController;

  MenuItemForm({
    String? name,
    String? description,
    String? price,
    String? photoUrl,
  })  : nameController = TextEditingController(text: name),
        descriptionController = TextEditingController(text: description),
        priceController = TextEditingController(text: price),
        photoController = TextEditingController(text: photoUrl);

  factory MenuItemForm.fromMenuItem(MenuItem item) {
    return MenuItemForm(
      name: item.name,
      description: item.description,
      price: item.price.toString(),
      photoUrl: item.photoUrl,
    );
  }

  void dispose() {
    nameController.dispose();
    descriptionController.dispose();
    priceController.dispose();
    photoController.dispose();
  }
}
