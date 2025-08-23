import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

enum ButtonType {
  primary,
  secondary,
  outline,
  text,
  danger,
  success,
}

enum ButtonSize {
  small,
  medium,
  large,
}

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final ButtonType type;
  final ButtonSize size;
  final bool isLoading;
  final bool isFullWidth;
  final IconData? icon;
  final bool iconRight;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final Color? borderColor;
  final double? borderRadius;
  final EdgeInsetsGeometry? padding;
  final TextStyle? textStyle;
  final double? elevation;

  const CustomButton({
    super.key,
    required this.text,
    this.onPressed,
    this.type = ButtonType.primary,
    this.size = ButtonSize.medium,
    this.isLoading = false,
    this.isFullWidth = true,
    this.icon,
    this.iconRight = false,
    this.backgroundColor,
    this.foregroundColor,
    this.borderColor,
    this.borderRadius,
    this.padding,
    this.textStyle,
    this.elevation,
  });

  @override
  Widget build(BuildContext context) {
    final buttonStyle = _getButtonStyle();
    final content = _buildContent();

    Widget button;

    switch (type) {
      case ButtonType.primary:
      case ButtonType.secondary:
      case ButtonType.danger:
      case ButtonType.success:
        button = ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: buttonStyle,
          child: content,
        );
        break;
      case ButtonType.outline:
        button = OutlinedButton(
          onPressed: isLoading ? null : onPressed,
          style: buttonStyle,
          child: content,
        );
        break;
      case ButtonType.text:
        button = TextButton(
          onPressed: isLoading ? null : onPressed,
          style: buttonStyle,
          child: content,
        );
        break;
    }

    if (isFullWidth) {
      return SizedBox(
        width: double.infinity,
        child: button,
      );
    }

    return button;
  }

  ButtonStyle _getButtonStyle() {
    final colors = _getColors();
    final sizes = _getSizes();

    return ButtonStyle(
      backgroundColor: MaterialStateProperty.resolveWith<Color?>(
        (Set<MaterialState> states) {
          if (states.contains(MaterialState.disabled)) {
            return colors.backgroundColor?.withOpacity(0.5);
          }
          return colors.backgroundColor;
        },
      ),
      foregroundColor: MaterialStateProperty.resolveWith<Color?>(
        (Set<MaterialState> states) {
          if (states.contains(MaterialState.disabled)) {
            return colors.foregroundColor?.withOpacity(0.5);
          }
          return colors.foregroundColor;
        },
      ),
      side: colors.borderColor != null
          ? MaterialStateProperty.all<BorderSide>(
              BorderSide(color: colors.borderColor!),
            )
          : null,
      elevation: MaterialStateProperty.all<double>(elevation ?? sizes.elevation),
      padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
        padding ?? sizes.padding,
      ),
      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius ?? sizes.borderRadius),
        ),
      ),
      textStyle: MaterialStateProperty.all<TextStyle>(
        textStyle ?? sizes.textStyle,
      ),
      minimumSize: MaterialStateProperty.all<Size>(
        Size(0, sizes.height),
      ),
    );
  }

  _ButtonColors _getColors() {
    Color? bgColor = backgroundColor;
    Color? fgColor = foregroundColor;
    Color? bdColor = borderColor;

    if (bgColor == null || fgColor == null) {
      switch (type) {
        case ButtonType.primary:
          bgColor ??= AppTheme.primaryColor;
          fgColor ??= AppTheme.whiteColor;
          break;
        case ButtonType.secondary:
          bgColor ??= AppTheme.cardBackgroundColor;
          fgColor ??= AppTheme.primaryColor;
          break;
        case ButtonType.outline:
          bgColor ??= Colors.transparent;
          fgColor ??= AppTheme.primaryColor;
          bdColor ??= AppTheme.primaryColor;
          break;
        case ButtonType.text:
          bgColor ??= Colors.transparent;
          fgColor ??= AppTheme.primaryColor;
          break;
        case ButtonType.danger:
          bgColor ??= AppTheme.dangerColor;
          fgColor ??= AppTheme.whiteColor;
          break;
        case ButtonType.success:
          bgColor ??= AppTheme.successColor;
          fgColor ??= AppTheme.whiteColor;
          break;
      }
    }

    return _ButtonColors(
      backgroundColor: bgColor,
      foregroundColor: fgColor,
      borderColor: bdColor,
    );
  }

  _ButtonSizes _getSizes() {
    double height;
    EdgeInsetsGeometry buttonPadding;
    TextStyle buttonTextStyle;
    double buttonBorderRadius;
    double buttonElevation;

    switch (size) {
      case ButtonSize.small:
        height = 36;
        buttonPadding = const EdgeInsets.symmetric(horizontal: 16, vertical: 8);
        buttonTextStyle = AppTheme.bodySmall.copyWith(fontWeight: FontWeight.w500);
        buttonBorderRadius = 8;
        buttonElevation = 1;
        break;
      case ButtonSize.medium:
        height = 48;
        buttonPadding = const EdgeInsets.symmetric(horizontal: 24, vertical: 12);
        buttonTextStyle = AppTheme.bodyMedium.copyWith(fontWeight: FontWeight.w500);
        buttonBorderRadius = 12;
        buttonElevation = 2;
        break;
      case ButtonSize.large:
        height = 56;
        buttonPadding = const EdgeInsets.symmetric(horizontal: 32, vertical: 16);
        buttonTextStyle = AppTheme.bodyLarge.copyWith(fontWeight: FontWeight.w600);
        buttonBorderRadius = 16;
        buttonElevation = 3;
        break;
    }

    return _ButtonSizes(
      height: height,
      padding: buttonPadding,
      textStyle: buttonTextStyle,
      borderRadius: buttonBorderRadius,
      elevation: buttonElevation,
    );
  }

  Widget _buildContent() {
    if (isLoading) {
      return SizedBox(
        height: 20,
        width: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(
            _getColors().foregroundColor ?? AppTheme.whiteColor,
          ),
        ),
      );
    }

    if (icon != null) {
      final iconWidget = Icon(
        icon,
        size: _getIconSize(),
      );

      if (iconRight) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(text),
            const SizedBox(width: 8),
            iconWidget,
          ],
        );
      } else {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            iconWidget,
            const SizedBox(width: 8),
            Text(text),
          ],
        );
      }
    }

    return Text(text);
  }

  double _getIconSize() {
    switch (size) {
      case ButtonSize.small:
        return 16;
      case ButtonSize.medium:
        return 18;
      case ButtonSize.large:
        return 20;
    }
  }
}

class _ButtonColors {
  final Color? backgroundColor;
  final Color? foregroundColor;
  final Color? borderColor;

  const _ButtonColors({
    this.backgroundColor,
    this.foregroundColor,
    this.borderColor,
  });
}

class _ButtonSizes {
  final double height;
  final EdgeInsetsGeometry padding;
  final TextStyle textStyle;
  final double borderRadius;
  final double elevation;

  const _ButtonSizes({
    required this.height,
    required this.padding,
    required this.textStyle,
    required this.borderRadius,
    required this.elevation,
  });
}

// Specialized button widgets for common use cases

class PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;
  final ButtonSize size;

  const PrimaryButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.icon,
    this.size = ButtonSize.medium,
  });

  @override
  Widget build(BuildContext context) {
    return CustomButton(
      text: text,
      onPressed: onPressed,
      type: ButtonType.primary,
      size: size,
      isLoading: isLoading,
      icon: icon,
    );
  }
}

class SecondaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;
  final ButtonSize size;

  const SecondaryButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.icon,
    this.size = ButtonSize.medium,
  });

  @override
  Widget build(BuildContext context) {
    return CustomButton(
      text: text,
      onPressed: onPressed,
      type: ButtonType.secondary,
      size: size,
      isLoading: isLoading,
      icon: icon,
    );
  }
}

class OutlineButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;
  final ButtonSize size;

  const OutlineButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.icon,
    this.size = ButtonSize.medium,
  });

  @override
  Widget build(BuildContext context) {
    return CustomButton(
      text: text,
      onPressed: onPressed,
      type: ButtonType.outline,
      size: size,
      isLoading: isLoading,
      icon: icon,
    );
  }
}

class DangerButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;
  final ButtonSize size;

  const DangerButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.icon,
    this.size = ButtonSize.medium,
  });

  @override
  Widget build(BuildContext context) {
    return CustomButton(
      text: text,
      onPressed: onPressed,
      type: ButtonType.danger,
      size: size,
      isLoading: isLoading,
      icon: icon,
    );
  }
}