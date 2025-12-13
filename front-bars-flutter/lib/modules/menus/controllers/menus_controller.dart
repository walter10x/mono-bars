import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:front_bars_flutter/modules/menus/models/menu_models.dart';
import 'package:front_bars_flutter/modules/menus/services/menus_service.dart';

part 'menus_controller.g.dart';

/// Estados del controlador de menús
enum MenusStatus {
  initial,
  loading,
  loaded,
  error,
}

/// Estado del controlador de menús
class MenusState {
  final MenusStatus status;
  final List<Menu> menus;
  final Menu? selectedMenu;
  final String? selectedBarId; // Bar actualmente seleccionado para filtrar
  final String? errorMessage;
  final bool isCreating;
  final bool isUpdating;
  final bool isDeleting;

  const MenusState({
    this.status = MenusStatus.initial,
    this.menus = const [],
    this.selectedMenu,
    this.selectedBarId,
    this.errorMessage,
    this.isCreating = false,
    this.isUpdating = false,
    this.isDeleting = false,
  });

  MenusState copyWith({
    MenusStatus? status,
    List<Menu>? menus,
    Menu? selectedMenu,
    String? selectedBarId,
    String? errorMessage,
    bool? isCreating,
    bool? isUpdating,
    bool? isDeleting,
    bool clearSelectedMenu = false,
    bool clearSelectedBarId = false,
    bool clearError = false,
  }) {
    return MenusState(
      status: status ?? this.status,
      menus: menus ?? this.menus,
      selectedMenu: clearSelectedMenu ? null : (selectedMenu ?? this.selectedMenu),
      selectedBarId: clearSelectedBarId ? null : (selectedBarId ?? this.selectedBarId),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      isCreating: isCreating ?? this.isCreating,
      isUpdating: isUpdating ?? this.isUpdating,
      isDeleting: isDeleting ?? this.isDeleting,
    );
  }

  bool get isLoading => status == MenusStatus.loading || isCreating || isUpdating || isDeleting;
  bool get hasError => status == MenusStatus.error && errorMessage != null;
  bool get isEmpty => menus.isEmpty && status == MenusStatus.loaded;
}

/// Controlador de menús usando Riverpod
@riverpod
class MenusController extends _$MenusController {
  late final MenusService _menusService;

  @override
  MenusState build() {
    _menusService = ref.watch(menusServiceProvider);
    return const MenusState();
  }

  /// Cargar todos los menús del propietario autenticado
  Future<void> loadMyMenus() async {
    state = state.copyWith(status: MenusStatus.loading);

    try {
      final result = await _menusService.getMyMenus();

      result.fold(
        (failure) {
          state = state.copyWith(
            status: MenusStatus.error,
            errorMessage: failure.message,
          );
        },
        (menus) {
          state = state.copyWith(
            status: MenusStatus.loaded,
            menus: menus,
            clearError: true,
          );
        },
      );
    } catch (e) {
      state = state.copyWith(
        status: MenusStatus.error,
        errorMessage: 'Error inesperado: ${e.toString()}',
      );
    }
  }

  /// Cargar menús de un bar específico
  Future<void> loadMenusByBar(String barId) async {
    print('🟢 MenusController.loadMenusByBar() INICIADO');
    print('   Bar ID recibido: $barId');
    
    state = state.copyWith(
      status: MenusStatus.loading,
      selectedBarId: barId,
    );
    
    print('   Estado cambiado a LOADING');

    try {
      print('   Llamando a _menusService.getMenusByBar($barId)...');
      final result = await _menusService.getMenusByBar(barId);
      
      print('   Respuesta recibida del servicio');

      result.fold(
        (failure) {
          print('   ❌ ERROR en respuesta:');
          print('      Mensaje: ${failure.message}');
          print('      Tipo: ${failure.runtimeType}');
          
          state = state.copyWith(
            status: MenusStatus.error,
            errorMessage: failure.message,
          );
        },
        (menus) {
          print('   ✅ EXITO: ${menus.length} menús recibidos');
          for (var i = 0; i < menus.length; i++) {
            print('      Menu $i: ${menus[i].name} (${menus[i].photoUrl ?? "sin foto"})');
          }
          
          state = state.copyWith(
            status: MenusStatus.loaded,
            menus: menus,
            clearError: true,
          );
          
          print('   Estado cambiado a LOADED con ${menus.length} menús');
        },
      );
    } catch (e) {
      print('   ❌ EXCEPCION CAPTURADA:');
      print('      Error: ${e.toString()}');
      print('      StackTrace: ${StackTrace.current}');
      
      state = state.copyWith(
        status: MenusStatus.error,
        errorMessage: 'Error inesperado: ${e.toString()}',
      );
    }
    
    print('🟢 MenusController.loadMenusByBar() FINALIZADO');
    print('   Estado final: ${state.status}');
    print('   Menús en estado: ${state.menus.length}');
  }

  /// Cargar un menú específico
  Future<void> loadMenu(String id) async {
    state = state.copyWith(status: MenusStatus.loading);

    try {
      final result = await _menusService.getMenu(id);

      result.fold(
        (failure) {
          state = state.copyWith(
            status: MenusStatus.error,
            errorMessage: failure.message,
          );
        },
        (menu) {
          state = state.copyWith(
            status: MenusStatus.loaded,
            selectedMenu: menu,
            clearError: true,
          );
        },
      );
    } catch (e) {
      state = state.copyWith(
        status: MenusStatus.error,
        errorMessage: 'Error inesperado: ${e.toString()}',
      );
    }
  }

  /// Crear un nuevo menú
  Future<bool> createMenu(CreateMenuRequest request) async {
    state = state.copyWith(isCreating: true, clearError: true);

    try {
      final result = await _menusService.createMenu(request);

      bool success = false;
      result.fold(
        (failure) {
          state = state.copyWith(
            status: MenusStatus.error,
            errorMessage: failure.message,
            isCreating: false,
          );
          success = false;
        },
        (menu) {
          // Agregar el nuevo menú a la lista
          final updatedMenus = [...state.menus, menu];
          state = state.copyWith(
            status: MenusStatus.loaded,
            menus: updatedMenus,
            selectedMenu: menu,
            isCreating: false,
            clearError: true,
          );
          success = true;
        },
      );

      return success;
    } catch (e) {
      state = state.copyWith(
        status: MenusStatus.error,
        errorMessage: 'Error inesperado: ${e.toString()}',
        isCreating: false,
      );
      return false;
    }
  }

  /// Actualizar un menú existente
  Future<bool> updateMenu(String id, UpdateMenuRequest request) async {
    state = state.copyWith(isUpdating: true, clearError: true);

    try {
      final result = await _menusService.updateMenu(id, request);

      bool success = false;
      result.fold(
        (failure) {
          state = state.copyWith(
            status: MenusStatus.error,
            errorMessage: failure.message,
            isUpdating: false,
          );
          success = false;
        },
        (updatedMenu) {
          // Actualizar el menú en la lista
          final updatedMenus = state.menus
              .map((menu) => menu.id == id ? updatedMenu : menu)
              .toList();
          state = state.copyWith(
            status: MenusStatus.loaded,
            menus: updatedMenus,
            selectedMenu: updatedMenu,
            isUpdating: false,
            clearError: true,
          );
          success = true;
        },
      );

      return success;
    } catch (e) {
      state = state.copyWith(
        status: MenusStatus.error,
        errorMessage: 'Error inesperado: ${e.toString()}',
        isUpdating: false,
      );
      return false;
    }
  }

  /// Eliminar un menú
  Future<bool> deleteMenu(String id) async {
    state = state.copyWith(isDeleting: true, clearError: true);

    try {
      final result = await _menusService.deleteMenu(id);

      bool success = false;
      result.fold(
        (failure) {
          state = state.copyWith(
            status: MenusStatus.error,
            errorMessage: failure.message,
            isDeleting: false,
          );
          success = false;
        },
        (_) {
          // Eliminar el menú de la lista
          final updatedMenus = state.menus.where((menu) => menu.id != id).toList();
          state = state.copyWith(
            status: MenusStatus.loaded,
            menus: updatedMenus,
            isDeleting: false,
            clearSelectedMenu: true,
            clearError: true,
          );
          success = true;
        },
      );

      return success;
    } catch (e) {
      state = state.copyWith(
        status: MenusStatus.error,
        errorMessage: 'Error inesperado: ${e.toString()}',
        isDeleting: false,
      );
      return false;
    }
  }

  /// Seleccionar un menú para ver/editar
  void selectMenu(Menu menu) {
    state = state.copyWith(selectedMenu: menu);
  }

  /// Seleccionar un bar para filtrar menús
  void selectBar(String? barId) {
    state = state.copyWith(
      selectedBarId: barId,
      clearSelectedBarId: barId == null,
    );
    
    // Cargar menús del bar seleccionado
    if (barId != null) {
      loadMenusByBar(barId);
    }
  }

  /// Limpiar el menú seleccionado
  void clearSelection() {
    state = state.copyWith(clearSelectedMenu: true);
  }

  /// Limpiar error
  void clearError() {
    state = state.copyWith(clearError: true);
  }
}

/// Providers derivados

/// Provider para la lista de menús
final myMenusProvider = Provider<List<Menu>>((ref) {
  final menusState = ref.watch(menusControllerProvider);
  return menusState.menus;
});

/// Provider para el menú seleccionado
final selectedMenuProvider = Provider<Menu?>((ref) {
  final menusState = ref.watch(menusControllerProvider);
  return menusState.selectedMenu;
});

/// Provider para el bar seleccionado
final selectedBarIdProvider = Provider<String?>((ref) {
  final menusState = ref.watch(menusControllerProvider);
  return menusState.selectedBarId;
});

/// Provider para el estado de carga
final menusLoadingProvider = Provider<bool>((ref) {
  final menusState = ref.watch(menusControllerProvider);
  return menusState.isLoading;
});

/// Provider para verificar si hay error
final menusErrorProvider = Provider<String?>((ref) {
  final menusState = ref.watch(menusControllerProvider);
  return menusState.errorMessage;
});

/// Provider para verificar si la lista está vacía
final menusEmptyProvider = Provider<bool>((ref) {
  final menusState = ref.watch(menusControllerProvider);
  return menusState.isEmpty;
});
