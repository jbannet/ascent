import 'package:flutter/material.dart';

/// Platform-agnostic outlined button that works consistently on iOS and Android
class UniversalOutlinedButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget child;
  final Color? borderColor;
  final Color? foregroundColor;
  final EdgeInsetsGeometry? padding;
  final double? borderWidth;
  final BorderRadius? borderRadius;

  const UniversalOutlinedButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.borderColor,
    this.foregroundColor,
    this.padding,
    this.borderWidth,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: foregroundColor,
        padding: padding ?? const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        side: BorderSide(
          color: borderColor ?? Theme.of(context).primaryColor,
          width: borderWidth ?? 1,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: borderRadius ?? BorderRadius.circular(8),
        ),
      ),
      child: child,
    );
  }
}