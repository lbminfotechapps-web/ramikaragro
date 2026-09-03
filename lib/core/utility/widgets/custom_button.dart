import 'package:demo/core/theme/app_colors.dart';
import 'package:demo/core/utility/widgets/custom_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final Color? backgroundColor;
  final Color? textColor;
  final double? width;
  final double? height;
  final double? textSize;
  final double? borderRadius;
  final bool isLoading;
  final Widget? icon;
  final EdgeInsetsGeometry? padding;
  final TextStyle? textStyle;
  final Color? borderColor;
  final double? borderWidth;
  final LinearGradient? gradient;

  const CustomButton({
    super.key,
    required this.text,
    this.onPressed,
    this.backgroundColor,
    this.textColor,
    this.textSize,
    this.width,
    this.height,
    this.borderRadius,
    this.isLoading = false,
    this.icon,
    this.padding,
    this.textStyle,
    this.borderColor,
    this.borderWidth,
    this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular((borderRadius ?? 12).r);

    return SizedBox(
      width: width ?? double.infinity,
      height: (height ?? 52).h,
      child: Container(
        decoration: BoxDecoration(
          gradient: gradient ?? AppColors.appGradient,
          color: backgroundColor,
          borderRadius: radius,
          border: borderColor != null
              ? Border.all(color: borderColor!, width: borderWidth ?? 1)
              : null,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            foregroundColor: textColor ?? Colors.white,
            shadowColor: Colors.transparent,
            elevation: 0,
            padding:
                padding ??
                EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            shape: RoundedRectangleBorder(borderRadius: radius),
          ),
          child: isLoading
              ? SizedBox(
                  width: 20.w,
                  height: 20.h,
                  child: const CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    if (icon != null) ...[icon!, SizedBox(width: 8.w)],
                    CustomText(
                      text: text,
                      fontSize: textSize ?? 15.sp,
                      fontWeight: FontWeight.w600,
                      color: textStyle?.color ?? Colors.white,
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

// Variant with different styles
class CustomButtonVariant extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final ButtonVariant variant;
  final double? width;
  final double? height;
  final bool isLoading;
  final Widget? icon;

  const CustomButtonVariant({
    super.key,
    required this.text,
    this.onPressed,
    this.variant = ButtonVariant.primary,
    this.width,
    this.height,
    this.isLoading = false,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    Color backgroundColor;
    Color textColor;
    Color borderColor;

    switch (variant) {
      case ButtonVariant.primary:
        backgroundColor = const Color(0xFF1C6D2B);
        textColor = Colors.white;
        borderColor = const Color(0xFF1C6D2B);
        break;
      case ButtonVariant.secondary:
        backgroundColor = Colors.transparent;
        textColor = const Color(0xFF1C6D2B);
        borderColor = const Color(0xFF1C6D2B);
        break;
      case ButtonVariant.outline:
        backgroundColor = Colors.transparent;
        textColor = const Color(0xFF1C6D2B);
        borderColor = const Color(0xFF1C6D2B);
        break;
    }

    return SizedBox(
      width: width ?? 192,
      height: height ?? 55,
      child: variant == ButtonVariant.outline
          ? OutlinedButton(
              onPressed: isLoading ? null : onPressed,
              style: OutlinedButton.styleFrom(
                foregroundColor: textColor,
                side: BorderSide(color: borderColor, width: 1.5),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(7),
                ),
              ),
              child: _buildChild(),
            )
          : ElevatedButton(
              onPressed: isLoading ? null : onPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: backgroundColor,
                foregroundColor: textColor,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(7),
                ),
                elevation: variant == ButtonVariant.primary ? 2 : 0,
                shadowColor: Colors.black.withValues(alpha: 0.2),
              ),
              child: _buildChild(),
            ),
    );
  }

  Widget _buildChild() {
    return isLoading
        ? const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryColor),
            ),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[icon!, const SizedBox(width: 8)],
              CustomText(
                text: text,
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ],
          );
  }
}

enum ButtonVariant { primary, secondary, outline }
