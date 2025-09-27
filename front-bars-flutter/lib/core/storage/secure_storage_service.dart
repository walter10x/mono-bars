import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/app_constants.dart';

/// Servicio para el manejo de almacenamiento seguro y preferencias
class SecureStorageService {
  static const _secureStorage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );

  late final SharedPreferences _prefs;

  SecureStorageService(this._prefs);

  // Métodos para tokens de autenticación (almacenamiento seguro)
  Future<void> saveAccessToken(String token) async {
    await _secureStorage.write(
      key: AppConstants.accessTokenKey,
      value: token,
    );
  }

  Future<String?> getAccessToken() async {
    return await _secureStorage.read(key: AppConstants.accessTokenKey);
  }

  Future<void> saveRefreshToken(String token) async {
    await _secureStorage.write(
      key: AppConstants.refreshTokenKey,
      value: token,
    );
  }

  Future<String?> getRefreshToken() async {
    return await _secureStorage.read(key: AppConstants.refreshTokenKey);
  }

  Future<void> saveTokens({
    required String accessToken,
    String? refreshToken,
  }) async {
    await saveAccessToken(accessToken);
    if (refreshToken != null) {
      await saveRefreshToken(refreshToken);
    }
  }

  Future<void> clearTokens() async {
    await _secureStorage.delete(key: AppConstants.accessTokenKey);
    await _secureStorage.delete(key: AppConstants.refreshTokenKey);
  }

  // Métodos para datos de usuario (almacenamiento seguro)
  Future<void> saveUserData(Map<String, dynamic> userData) async {
    final userDataString = jsonEncode(userData);
    await _secureStorage.write(
      key: AppConstants.userDataKey,
      value: userDataString,
    );
  }

  Future<Map<String, dynamic>?> getUserData() async {
    final userDataString = await _secureStorage.read(key: AppConstants.userDataKey);
    if (userDataString != null) {
      try {
        return jsonDecode(userDataString) as Map<String, dynamic>;
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  Future<void> clearUserData() async {
    await _secureStorage.delete(key: AppConstants.userDataKey);
  }

  // Métodos para preferencias generales (SharedPreferences)
  Future<void> setFirstTime(bool isFirstTime) async {
    await _prefs.setBool(AppConstants.isFirstTimeKey, isFirstTime);
  }

  bool get isFirstTime {
    return _prefs.getBool(AppConstants.isFirstTimeKey) ?? true;
  }

  Future<void> setBool(String key, bool value) async {
    await _prefs.setBool(key, value);
  }

  bool getBool(String key, {bool defaultValue = false}) {
    return _prefs.getBool(key) ?? defaultValue;
  }

  Future<void> setString(String key, String value) async {
    await _prefs.setString(key, value);
  }

  String getString(String key, {String defaultValue = ''}) {
    return _prefs.getString(key) ?? defaultValue;
  }

  Future<void> setInt(String key, int value) async {
    await _prefs.setInt(key, value);
  }

  int getInt(String key, {int defaultValue = 0}) {
    return _prefs.getInt(key) ?? defaultValue;
  }

  Future<void> setDouble(String key, double value) async {
    await _prefs.setDouble(key, value);
  }

  double getDouble(String key, {double defaultValue = 0.0}) {
    return _prefs.getDouble(key) ?? defaultValue;
  }

  Future<void> setStringList(String key, List<String> value) async {
    await _prefs.setStringList(key, value);
  }

  List<String> getStringList(String key, {List<String>? defaultValue}) {
    return _prefs.getStringList(key) ?? defaultValue ?? [];
  }

  Future<void> remove(String key) async {
    await _prefs.remove(key);
  }

  Future<void> clear() async {
    await _prefs.clear();
  }

  // Método para limpiar toda la sesión del usuario
  Future<void> clearSession() async {
    await clearTokens();
    await clearUserData();
  }

  // Verificar si el usuario está autenticado
  Future<bool> isAuthenticated() async {
    final accessToken = await getAccessToken();
    return accessToken != null && accessToken.isNotEmpty;
  }
}

/// Provider para el servicio de almacenamiento seguro
final secureStorageServiceProvider = Provider<SecureStorageService>((ref) {
  throw UnimplementedError('secureStorageServiceProvider debe ser sobreescrito');
});

/// Provider para inicializar el servicio de almacenamiento
final storageInitializerProvider = FutureProvider<SecureStorageService>((ref) async {
  final prefs = await SharedPreferences.getInstance();
  return SecureStorageService(prefs);
});
