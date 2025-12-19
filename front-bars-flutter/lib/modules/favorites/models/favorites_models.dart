import 'package:equatable/equatable.dart';

/// Estado del módulo de favoritos
class FavoritesState extends Equatable {
  final List<String> favoriteBarIds;
  final bool isLoading;
  final String? errorMessage;

  const FavoritesState({
    this.favoriteBarIds = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  factory FavoritesState.initial() => const FavoritesState();

  factory FavoritesState.loading() => const FavoritesState(isLoading: true);

  bool isFavorite(String barId) => favoriteBarIds.contains(barId);

  @override
  List<Object?> get props => [favoriteBarIds, isLoading, errorMessage];

  FavoritesState copyWith({
    List<String>? favoriteBarIds,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
  }) {
    return FavoritesState(
      favoriteBarIds: favoriteBarIds ?? this.favoriteBarIds,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}
