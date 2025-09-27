import 'dart:math' show pow;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Extensiones para String
extension StringExtensions on String {
  /// Capitaliza la primera letra
  String capitalize() {
    if (isEmpty) return this;
    return this[0].toUpperCase() + substring(1);
  }

  /// Capitaliza cada palabra
  String capitalizeWords() {
    if (isEmpty) return this;
    return split(' ').map((word) => word.capitalize()).join(' ');
  }

  /// Valida si es un email válido
  bool get isValidEmail {
    return RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$').hasMatch(this);
  }

  /// Valida si es un teléfono válido
  bool get isValidPhone {
    return RegExp(r'^\+?[1-9]\d{1,14}$').hasMatch(this);
  }

  /// Remueve todos los espacios en blanco
  String removeAllWhitespace() {
    return replaceAll(RegExp(r'\s+'), '');
  }

  /// Trunca el string a una longitud específica
  String truncate(int length, {String suffix = '...'}) {
    if (this.length <= length) return this;
    return substring(0, length) + suffix;
  }
}

/// Extensiones para DateTime
extension DateTimeExtensions on DateTime {
  /// Formatea la fecha como dd/MM/yyyy
  String get toDateString {
    return DateFormat('dd/MM/yyyy').format(this);
  }

  /// Formatea la fecha y hora como dd/MM/yyyy HH:mm
  String get toDateTimeString {
    return DateFormat('dd/MM/yyyy HH:mm').format(this);
  }

  /// Formatea la hora como HH:mm
  String get toTimeString {
    return DateFormat('HH:mm').format(this);
  }

  /// Retorna la diferencia en días desde hoy
  int get daysSinceToday {
    final now = DateTime.now();
    final difference = DateTime(now.year, now.month, now.day)
        .difference(DateTime(year, month, day));
    return difference.inDays;
  }

  /// Verifica si la fecha es hoy
  bool get isToday {
    final now = DateTime.now();
    return year == now.year && month == now.month && day == now.day;
  }

  /// Verifica si la fecha es ayer
  bool get isYesterday {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return year == yesterday.year && month == yesterday.month && day == yesterday.day;
  }

  /// Retorna una descripción relativa de la fecha
  String get relativeTime {
    final now = DateTime.now();
    final difference = now.difference(this);

    if (difference.inDays > 0) {
      if (difference.inDays == 1) {
        return 'Ayer';
      } else if (difference.inDays < 7) {
        return 'Hace ${difference.inDays} días';
      } else {
        return toDateString;
      }
    } else if (difference.inHours > 0) {
      return 'Hace ${difference.inHours} horas';
    } else if (difference.inMinutes > 0) {
      return 'Hace ${difference.inMinutes} minutos';
    } else {
      return 'Ahora';
    }
  }
}

/// Extensiones para BuildContext
extension BuildContextExtensions on BuildContext {
  /// Acceso rápido al Theme
  ThemeData get theme => Theme.of(this);

  /// Acceso rápido a los colores del tema
  ColorScheme get colors => theme.colorScheme;

  /// Acceso rápido al TextTheme
  TextTheme get textTheme => theme.textTheme;

  /// Acceso rápido al MediaQuery
  MediaQueryData get mediaQuery => MediaQuery.of(this);

  /// Acceso rápido al tamaño de la pantalla
  Size get screenSize => mediaQuery.size;

  /// Acceso rápido al ancho de la pantalla
  double get screenWidth => screenSize.width;

  /// Acceso rápido al alto de la pantalla
  double get screenHeight => screenSize.height;

  /// Verifica si es una pantalla pequeña (< 600px)
  bool get isSmallScreen => screenWidth < 600;

  /// Verifica si es una pantalla mediana (600-1024px)
  bool get isMediumScreen => screenWidth >= 600 && screenWidth < 1024;

  /// Verifica si es una pantalla grande (>= 1024px)
  bool get isLargeScreen => screenWidth >= 1024;

  /// Muestra un SnackBar
  void showSnackBar(
    String message, {
    Color? backgroundColor,
    Duration duration = const Duration(seconds: 3),
    SnackBarAction? action,
  }) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
        duration: duration,
        action: action,
      ),
    );
  }

  /// Muestra un SnackBar de error
  void showErrorSnackBar(String message) {
    showSnackBar(
      message,
      backgroundColor: colors.error,
    );
  }

  /// Muestra un SnackBar de éxito
  void showSuccessSnackBar(String message) {
    showSnackBar(
      message,
      backgroundColor: Colors.green,
    );
  }

  /// Navega a una ruta
  void pushNamed(String routeName, {Object? arguments}) {
    Navigator.of(this).pushNamed(routeName, arguments: arguments);
  }

  /// Navega y reemplaza la ruta actual
  void pushReplacementNamed(String routeName, {Object? arguments}) {
    Navigator.of(this).pushReplacementNamed(routeName, arguments: arguments);
  }

  /// Navega y limpia el stack
  void pushNamedAndRemoveUntil(String routeName, {Object? arguments}) {
    Navigator.of(this).pushNamedAndRemoveUntil(
      routeName,
      (route) => false,
      arguments: arguments,
    );
  }

  /// Regresa a la pantalla anterior
  void pop([Object? result]) {
    Navigator.of(this).pop(result);
  }
}

/// Extensiones para List
extension ListExtensions<T> on List<T> {
  /// Verifica si la lista no es null ni está vacía
  bool get isNotNullOrEmpty => isNotEmpty;

  /// Obtiene un elemento de forma segura por índice
  T? safeGet(int index) {
    if (index >= 0 && index < length) {
      return this[index];
    }
    return null;
  }

  /// Divide la lista en chunks de tamaño específico
  List<List<T>> chunk(int size) {
    final chunks = <List<T>>[];
    for (int i = 0; i < length; i += size) {
      chunks.add(sublist(i, i + size > length ? length : i + size));
    }
    return chunks;
  }
}

/// Extensiones para double
extension DoubleExtensions on double {
  /// Convierte a moneda con formato
  String toCurrency({String symbol = '\$', int decimals = 2}) {
    return NumberFormat.currency(
      symbol: symbol,
      decimalDigits: decimals,
    ).format(this);
  }

  /// Redondea a decimales específicos
  double roundToDecimals(int decimals) {
    final factor = pow(10, decimals).toDouble();
    return (this * factor).round() / factor;
  }
}

/// Extensiones para int
extension IntExtensions on int {
  /// Convierte a moneda con formato
  String toCurrency({String symbol = '\$'}) {
    return NumberFormat.currency(
      symbol: symbol,
      decimalDigits: 0,
    ).format(this);
  }

  /// Formatea con separadores de miles
  String get formatted {
    return NumberFormat('#,###').format(this);
  }
}
