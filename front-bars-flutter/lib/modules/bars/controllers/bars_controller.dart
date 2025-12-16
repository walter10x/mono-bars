import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../models/bar_models.dart';
import '../services/bars_service.dart';

part 'bars_controller.g.dart';

/// Estados del controlador de bares
enum BarsStatus {
  initial,
  loading,
  loaded,
  error,
}

/// Estado del controlador de bares
class BarsState {
  final BarsStatus status;
  final List<Bar> bars;
  final Bar? selectedBar;
  final String? errorMessage;
  final bool isCreating;
  final bool isUpdating;
  final bool isDeleting;

  const BarsState({
    this.status = BarsStatus.initial,
    this.bars = const [],
    this.selectedBar,
    this.errorMessage,
    this.isCreating = false,
    this.isUpdating = false,
    this.isDeleting = false,
  });

  BarsState copyWith({
    BarsStatus? status,
    List<Bar>? bars,
    Bar? selectedBar,
    String? errorMessage,
    bool? isCreating,
    bool? isUpdating,
    bool? isDeleting,
    bool clearSelectedBar = false,
    bool clearError = false,
  }) {
    return BarsState(
      status: status ?? this.status,
      bars: bars ?? this.bars,
      selectedBar: clearSelectedBar ? null : (selectedBar ?? this.selectedBar),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      isCreating: isCreating ?? this.isCreating,
      isUpdating: isUpdating ?? this.isUpdating,
      isDeleting: isDeleting ?? this.isDeleting,
    );
  }

  bool get isLoading => status == BarsStatus.loading || isCreating || isUpdating || isDeleting;
  bool get hasError => status == BarsStatus.error && errorMessage != null;
  bool get isEmpty => bars.isEmpty && status == BarsStatus.loaded;
}

/// Controlador de bares usando Riverpod
@riverpod
class BarsController extends _$BarsController {
  late final BarsService _barsService;

  @override
  BarsState build() {
    _barsService = ref.watch(barsServiceProvider);
    return const BarsState();
  }

  /// Cargar los bares del propietario autenticado
  Future<void> loadMyBars() async {
    state = state.copyWith(status: BarsStatus.loading);

    try {
      final result = await _barsService.getMyBars();

      result.fold(
        (failure) {
          state = state.copyWith(
            status: BarsStatus.error,
            errorMessage: failure.message,
          );
        },
        (bars) {
          state = state.copyWith(
            status: BarsStatus.loaded,
            bars: bars,
            clearError: true,
          );
        },
      );
    } catch (e) {
      state = state.copyWith(
        status: BarsStatus.error,
        errorMessage: 'Error inesperado: ${e.toString()}',
      );
    }
  }

  /// Cargar todos los bares (para clientes)
  Future<void> loadAllBars() async {
    state = state.copyWith(status: BarsStatus.loading);

    try {
      final result = await _barsService.getAllBars();

      result.fold(
        (failure) {
          state = state.copyWith(
            status: BarsStatus.error,
            errorMessage: failure.message,
          );
        },
        (bars) {
          state = state.copyWith(
            status: BarsStatus.loaded,
            bars: bars,
            clearError: true,
          );
        },
      );
    } catch (e) {
      state = state.copyWith(
        status: BarsStatus.error,
        errorMessage: 'Error inesperado: ${e.toString()}',
      );
    }
  }

  /// Buscar bares por texto (nombre, ubicación, descripción)
  Future<void> searchBars(String query) async {
    state = state.copyWith(status: BarsStatus.loading);

    try {
      final result = await _barsService.searchBars(query);

      result.fold(
        (failure) {
          state = state.copyWith(
            status: BarsStatus.error,
            errorMessage: failure.message,
          );
        },
        (bars) {
          state = state.copyWith(
            status: BarsStatus.loaded,
            bars: bars,
            clearError: true,
          );
        },
      );
    } catch (e) {
      state = state.copyWith(
        status: BarsStatus.error,
        errorMessage: 'Error inesperado: ${e.toString()}',
      );
    }
  }

  /// Cargar un bar específico
  Future<void> loadBar(String id) async {
    state = state.copyWith(status: BarsStatus.loading);

    try {
      final result = await _barsService.getBar(id);

      result.fold(
        (failure) {
          state = state.copyWith(
            status: BarsStatus.error,
            errorMessage: failure.message,
          );
        },
        (bar) {
          state = state.copyWith(
            status: BarsStatus.loaded,
            selectedBar: bar,
            clearError: true,
          );
        },
      );
    } catch (e) {
      state = state.copyWith(
        status: BarsStatus.error,
        errorMessage: 'Error inesperado: ${e.toString()}',
      );
    }
  }

  /// Crear un nuevo bar
  Future<bool> createBar(CreateBarRequest request) async {
    state = state.copyWith(isCreating: true, clearError: true);

    try {
      final result = await _barsService.createBar(request);

      bool success = false;
      result.fold(
        (failure) {
          state = state.copyWith(
            status: BarsStatus.error,
            errorMessage: failure.message,
            isCreating: false,
          );
          success = false;
        },
        (bar) {
          // Agregar el nuevo bar a la lista
          final updatedBars = [...state.bars, bar];
          state = state.copyWith(
            status: BarsStatus.loaded,
            bars: updatedBars,
            selectedBar: bar,
            isCreating: false,
            clearError: true,
          );
          success = true;
        },
      );

      return success;
    } catch (e) {
      state = state.copyWith(
        status: BarsStatus.error,
        errorMessage: 'Error inesperado: ${e.toString()}',
        isCreating: false,
      );
      return false;
    }
  }

  /// Actualizar un bar existente
  Future<bool> updateBar(String id, UpdateBarRequest request) async {
    state = state.copyWith(isUpdating: true, clearError: true);

    try {
      final result = await _barsService.updateBar(id, request);

      bool success = false;
      result.fold(
        (failure) {
          state = state.copyWith(
            status: BarsStatus.error,
            errorMessage: failure.message,
            isUpdating: false,
          );
          success = false;
        },
        (updatedBar) {
          // Actualizar el bar en la lista
          final updatedBars = state.bars
              .map((bar) => bar.id == id ? updatedBar : bar)
              .toList();
          state = state.copyWith(
            status: BarsStatus.loaded,
            bars: updatedBars,
            selectedBar: updatedBar,
            isUpdating: false,
            clearError: true,
          );
          success = true;
        },
      );

      return success;
    } catch (e) {
      state = state.copyWith(
        status: BarsStatus.error,
        errorMessage: 'Error inesperado: ${e.toString()}',
        isUpdating: false,
      );
      return false;
    }
  }

  /// Eliminar un bar
  Future<bool> deleteBar(String id) async {
    state = state.copyWith(isDeleting: true, clearError: true);

    try {
      final result = await _barsService.deleteBar(id);

      bool success = false;
      result.fold(
        (failure) {
          state = state.copyWith(
            status: BarsStatus.error,
            errorMessage: failure.message,
            isDeleting: false,
          );
          success = false;
        },
        (_) {
          // Eliminar el bar de la lista
          final updatedBars = state.bars.where((bar) => bar.id != id).toList();
          state = state.copyWith(
            status: BarsStatus.loaded,
            bars: updatedBars,
            isDeleting: false,
            clearSelectedBar: true,
            clearError: true,
          );
          success = true;
        },
      );

      return success;
    } catch (e) {
      state = state.copyWith(
        status: BarsStatus.error,
        errorMessage: 'Error inesperado: ${e.toString()}',
        isDeleting: false,
      );
      return false;
    }
  }

  /// Seleccionar un bar para ver/editar
  void selectBar(Bar bar) {
    state = state.copyWith(selectedBar: bar);
  }

  /// Limpiar el bar seleccionado
  void clearSelection() {
    state = state.copyWith(clearSelectedBar: true);
  }

  /// Limpiar error
  void clearError() {
    state = state.copyWith(clearError: true);
  }
}

/// Providers derivados

/// Provider para la lista de bares
final myBarsProvider = Provider<List<Bar>>((ref) {
  final barsState = ref.watch(barsControllerProvider);
  return barsState.bars;
});

/// Provider para el bar seleccionado
final selectedBarProvider = Provider<Bar?>((ref) {
  final barsState = ref.watch(barsControllerProvider);
  return barsState.selectedBar;
});

/// Provider para el estado de carga
final barsLoadingProvider = Provider<bool>((ref) {
  final barsState = ref.watch(barsControllerProvider);
  return barsState.isLoading;
});

/// Provider para verificar si hay error
final barsErrorProvider = Provider<String?>((ref) {
  final barsState = ref.watch(barsControllerProvider);
  return barsState.errorMessage;
});

/// Provider para verificar si la lista está vacía
final barsEmptyProvider = Provider<bool>((ref) {
  final barsState = ref.watch(barsControllerProvider);
  return barsState.isEmpty;
});
