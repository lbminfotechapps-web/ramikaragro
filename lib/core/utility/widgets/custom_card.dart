import 'package:demo/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

class CustomCard extends StatelessWidget {
  final Widget child;
  final Color? color;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double borderRadius;
  final double? elevation;
  final VoidCallback? onTap;

  const CustomCard({
    super.key,
    required this.child,
    this.color,
    this.padding,
    this.margin,
    this.borderRadius = 24,
    this.elevation = 0,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: margin ?? EdgeInsets.zero,
      elevation: elevation,
      color: color ?? Colors.white,

      shape: RoundedRectangleBorder(
        side: BorderSide(color: AppColors.borderColor, width: 1),
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(borderRadius),
        child: Padding(
          padding: padding ?? const EdgeInsets.all(16),
          child: child,
        ),
      ),
    );
  }
}
