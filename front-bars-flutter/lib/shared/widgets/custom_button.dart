import 'package:flutter/material.dart';

import '../../core/constants/app_constants.dart';

/// Widget personalizado para botones con diferentes estilos
class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isOutlined;
  final bool isText;
  final Color? backgroundColor;
  final Color? textColor;
  final EdgeInsetsGeometry? padding;
  final double? borderRadius;
  final IconData? icon;
  final double? fontSize;
  final FontWeight? fontWeight;
  final double? elevation;
  final Size? minimumSize;

  const CustomButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.isOutlined = false,
    this.isText = false,
    this.backgroundColor,
    this.textColor,
    this.padding,
    this.borderRadius,
    this.icon,
    this.fontSize,
    this.fontWeight,
    this.elevation,
    this.minimumSize,
  });

  /// Constructor para botón primario
  const CustomButton.primary({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.icon,
    this.fontSize,
    this.fontWeight,
    this.padding,
    this.minimumSize,
  })  : isOutlined = false,
        isText = false,
        backgroundColor = null,
        textColor = null,
        borderRadius = null,
        elevation = null;

  /// Constructor para botón secundario (outlined)
  const CustomButton.secondary({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.icon,
    this.fontSize,
    this.fontWeight,
    this.padding,
    this.minimumSize,
  })  : isOutlined = true,
        isText = false,
        backgroundColor = null,
        textColor = null,
        borderRadius = null,
        elevation = null;

  /// Constructor para botón de texto
  const CustomButton.text({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.icon,
    this.fontSize,
    this.fontWeight,
    this.textColor,
    this.padding,
  })  : isOutlined = false,
        isText = true,
        backgroundColor = null,
        borderRadius = null,
        elevation = null,
        minimumSize = null;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDisabled = onPressed == null || isLoading;

    Widget child = isLoading
        ? SizedBox(
            height: 20,
            width: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(
                isText || isOutlined
                    ? theme.primaryColor
                    : Colors.white,
              ),
            ),
          )
        : _buildButtonContent(context);

    if (isText) {
      return TextButton(
        onPressed: isDisabled ? null : onPressed,
        style: TextButton.styleFrom(
          foregroundColor: textColor ?? theme.primaryColor,
          padding: padding ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          textStyle: TextStyle(
            fontSize: fontSize ?? 14,
            fontWeight: fontWeight ?? FontWeight.w500,
            fontFamily: null,
          ),
        ),
        child: child,
      );
    }

    if (isOutlined) {
      return OutlinedButton(
        onPressed: isDisabled ? null : onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: textColor ?? theme.primaryColor,
          backgroundColor: backgroundColor,
          side: BorderSide(
            color: textColor ?? theme.primaryColor,
            width: 1,
          ),
          padding: padding ?? const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          minimumSize: minimumSize ?? const Size(double.infinity, 56),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius ?? AppConstants.borderRadius),
          ),
          elevation: elevation ?? 0,
          textStyle: TextStyle(
            fontSize: fontSize ?? 16,
            fontWeight: fontWeight ?? FontWeight.w600,
            fontFamily: null,
          ),
        ),
        child: child,
      );
    }

    // Botón elevado (predeterminado)
    return ElevatedButton(
      onPressed: isDisabled ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor ?? theme.primaryColor,
        foregroundColor: textColor ?? Colors.white,
        padding: padding ?? const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        minimumSize: minimumSize ?? const Size(double.infinity, 56),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius ?? AppConstants.borderRadius),
        ),
        elevation: elevation ?? 2,
        textStyle: TextStyle(
          fontSize: fontSize ?? 16,
          fontWeight: fontWeight ?? FontWeight.w600,
          fontFamily: null,
        ),
      ),
      child: child,
    );
  }

  Widget _buildButtonContent(BuildContext context) {
    if (icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 8),
          Text(text),
        ],
      );
    }
    
    return Text(text);
  }
}

/// Widget para botón flotante personalizado
class CustomFloatingActionButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final IconData icon;
  final String? tooltip;
  final bool isExtended;
  final String? label;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double? elevation;

  const CustomFloatingActionButton({
    super.key,
    this.onPressed,
    required this.icon,
    this.tooltip,
    this.isExtended = false,
    this.label,
    this.backgroundColor,
    this.foregroundColor,
    this.elevation,
  });

  const CustomFloatingActionButton.extended({
    super.key,
    this.onPressed,
    required this.icon,
    required this.label,
    this.tooltip,
    this.backgroundColor,
    this.foregroundColor,
    this.elevation,
  }) : isExtended = true;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (isExtended && label != null) {
      return FloatingActionButton.extended(
        onPressed: onPressed,
        icon: Icon(icon),
        label: Text(label!),
        tooltip: tooltip,
        backgroundColor: backgroundColor ?? theme.colorScheme.secondary,
        foregroundColor: foregroundColor ?? Colors.white,
        elevation: elevation ?? 6,
      );
    }

    return FloatingActionButton(
      onPressed: onPressed,
      tooltip: tooltip,
      backgroundColor: backgroundColor ?? theme.colorScheme.secondary,
      foregroundColor: foregroundColor ?? Colors.white,
      elevation: elevation ?? 6,
      child: Icon(icon),
    );
  }
}

/// Widget para botones de íconos personalizados
class CustomIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final String? tooltip;
  final Color? color;
  final Color? backgroundColor;
  final double? size;
  final EdgeInsetsGeometry? padding;
  final bool hasBorder;
  final double? borderRadius;

  const CustomIconButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.tooltip,
    this.color,
    this.backgroundColor,
    this.size,
    this.padding,
    this.hasBorder = false,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Widget button = IconButton(
      onPressed: onPressed,
      icon: Icon(icon),
      tooltip: tooltip,
      color: color ?? theme.iconTheme.color,
      iconSize: size ?? 24,
      padding: padding ?? const EdgeInsets.all(8),
    );

    if (backgroundColor != null || hasBorder) {
      button = Container(
        decoration: BoxDecoration(
          color: backgroundColor,
          border: hasBorder
              ? Border.all(
                  color: theme.dividerColor,
                  width: 1,
                )
              : null,
          borderRadius: BorderRadius.circular(
            borderRadius ?? AppConstants.borderRadius / 2,
          ),
        ),
        child: button,
      );
    }

    return button;
  }
}
