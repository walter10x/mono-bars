import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:front_bars_flutter/core/utils/extensions.dart';
import 'package:front_bars_flutter/shared/widgets/custom_button.dart';
import 'package:front_bars_flutter/shared/widgets/custom_text_field.dart';
import 'package:front_bars_flutter/shared/widgets/image_picker_widget.dart';
import 'package:front_bars_flutter/shared/widgets/loading_overlay.dart';
import 'package:front_bars_flutter/modules/bars/controllers/bars_controller.dart';
import 'package:front_bars_flutter/modules/menus/controllers/menus_controller.dart';
import 'package:front_bars_flutter/modules/menus/models/menu_models.dart';
import 'package:front_bars_flutter/core/services/image_upload_service.dart';

/// Pantalla para crear o editar un menú
class MenuFormScreen extends ConsumerStatefulWidget {
  final String? barId; // Bar pre-seleccionado (opcional)
  final String? menuId; // null = crear, non-null = editar

  const MenuFormScreen({
    super.key,
    this.barId,
    this.menuId,
  });

  @override
  ConsumerState<MenuFormScreen> createState() => _MenuFormScreenState();
}

class _MenuFormScreenState extends ConsumerState<MenuFormScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Controllers
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _photoController = TextEditingController();

  // Lista dinámica de items
  final List<MenuItemForm> _items = [];

  String? _selectedBarId;
  bool _isEditMode = false;
  File? _selectedImage; // Imagen seleccionada para subir
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    _selectedBarId = widget.barId;
    _isEditMode = widget.menuId != null;
    
    // Cargar bares si no hay uno pre-seleccionado
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

    // Cargar items
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
    // Dispose de controllers de items
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

    // Convertir items del formulario a MenuItem
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
      // Actualizar menú
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

      // Si se actualizó y hay imagen nueva, subirla
      if (success && _selectedImage != null && widget.menuId != null) {
        await _uploadImage(widget.menuId!);
      }

      if (success && mounted) {
        context.showSuccessSnackBar('Menú actualizado exitosamente');
        context.pop();
      }
    } else {
      // Crear menú
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


      success = await ref
          .read(menusControllerProvider.notifier)
          .createMenu(request);

      // Si se creó y hay imagen seleccionada, obtener el ID del menú y subir imagen
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
    final isLoading = _isEditMode ? menusState.isUpdating : menusState.isCreating;

    // Listener para errores
    ref.listen(menusControllerProvider, (previous, current) {
      if (current.hasError) {
        context.showErrorSnackBar(current.errorMessage!);
        ref.read(menusControllerProvider.notifier).clearError();
      }
    });

    return LoadingOverlay(
      isLoading: isLoading || _isUploading,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text(_isEditMode ? 'Editar Menú' : 'Crear Nuevo Menú'),
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
                  label: 'Nombre del Menú',
                  hint: 'Ej: Carta de Bebidas',
                  prefixIcon: Icons.restaurant_menu,
                  textInputAction: TextInputAction.next,
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

                // Selector de Bar (solo si no está pre-seleccionado)
                if (widget.barId == null && barsState.status == BarsStatus.loaded)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Bar',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: DropdownButton<String>(
                          value: _selectedBarId,
                          hint: const Text('Selecciona un bar'),
                          isExpanded: true,
                          underline: const SizedBox(),
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
                  ),
                
                CustomTextField(
                  controller: _descriptionController,
                  label: 'Descripción',
                  hint: 'Describe el menú...',
                  prefixIcon: Icons.description,
                  textInputAction: TextInputAction.next,
                  maxLines: 3,
                ),
                
                const SizedBox(height: 32),
                
                // Foto
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
                
                // Items del menú
                _buildSectionTitle('Productos del Menú', Icons.inventory_2),
                const SizedBox(height: 8),
                Text(
                  'Agrega los productos que incluye este menú',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
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
                }).toList(),
                
                OutlinedButton.icon(
                  onPressed: _addItem,
                  icon: const Icon(Icons.add),
                  label: const Text('Agregar Producto'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF6366F1),
                    side: const BorderSide(color: Color(0xFF6366F1)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
                
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
                        text: _isEditMode ? 'Actualizar Menú' : 'Crear Menú',
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

  Widget _buildItemEditor(MenuItemForm item, int index) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Producto ${index + 1}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                onPressed: () => _removeItem(index),
                icon: const Icon(Icons.delete, color: Colors.red),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          TextFormField(
            controller: item.nameController,
            decoration: const InputDecoration(
              labelText: 'Nombre *',
              hintText: 'Ej: Cerveza Artesanal',
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 12,
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'El nombre es requerido';
              }
              return null;
            },
          ),
          
          const SizedBox(height: 12),
          
          TextFormField(
            controller: item.priceController,
            decoration: const InputDecoration(
              labelText: 'Precio *',
              hintText: '0.00',
              prefixText: '€ ',
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 12,
              ),
            ),
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
          
          TextFormField(
            controller: item.descriptionController,
            decoration: const InputDecoration(
              labelText: 'Descripción',
              hintText: 'Descripción del producto...',
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 12,
              ),
            ),
            maxLines: 2,
          ),
          
          const SizedBox(height: 12),
          
          TextFormField(
            controller: item.photoController,
            decoration: const InputDecoration(
              labelText: 'Foto URL',
              hintText: 'https://...',
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 12,
              ),
            ),
            keyboardType: TextInputType.url,
          ),
        ],
      ),
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
