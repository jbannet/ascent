import 'package:flutter/material.dart';

/// Platform-agnostic progress indicator that works consistently on iOS and Android
class UniversalProgressIndicator extends StatelessWidget {
  final double? value;
  final Color? backgroundColor;
  final Color? valueColor;
  final double height;
  final BorderRadius? borderRadius;

  const UniversalProgressIndicator({
    super.key,
    this.value,
    this.backgroundColor,
    this.valueColor,
    this.height = 4.0,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.grey.shade200,
        borderRadius: borderRadius ?? BorderRadius.circular(height / 2),
      ),
      child: ClipRRect(
        borderRadius: borderRadius ?? BorderRadius.circular(height / 2),
        child: LinearProgressIndicator(
          value: value,
          backgroundColor: Colors.transparent,
          valueColor: AlwaysStoppedAnimation<Color>(
            valueColor ?? Theme.of(context).primaryColor,
          ),
        ),
      ),
    );
  }
}