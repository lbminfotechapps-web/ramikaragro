import 'package:demo/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
class CustomTextFormField extends StatelessWidget {
  final TextEditingController? controller;
  final String? labelText;
  final String? hintText;
  final String? helperText;
  final IconData? prefixIcon;
  final Widget? prefix;
  final IconData? suffixIcon;
  final VoidCallback? onSuffixIconTap;
  final bool obscureText;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final void Function(String?)? onSaved;
  final void Function()? onTap;
  final bool readOnly;
  final int? maxLines;
  final int? minLines;
  final int? maxLength;
  final bool enabled;
  final FocusNode? focusNode;
  final TextInputAction? textInputAction;
  final void Function(String)? onFieldSubmitted;
  final EdgeInsetsGeometry? contentPadding;
  final Color? fillColor;
  final Color? borderColor;
  final Color? focusedBorderColor;
  final Color? errorBorderColor;
  final double borderRadius;
  final double borderWidth;
  final TextStyle? textStyle;
  final TextStyle? labelStyle;
  final TextStyle? hintStyle;
  final bool filled;
  final String? initialValue;

  const CustomTextFormField({
    super.key,
    this.controller,
    this.labelText,
    this.hintText,
    this.helperText,
    this.prefixIcon,
    this.suffixIcon,
    this.onSuffixIconTap,
    this.prefix,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.onChanged,
    this.onSaved,
    this.onTap,
    this.readOnly = false,
    this.maxLines = 1,
    this.minLines,
    this.maxLength,
    this.enabled = true,
    this.focusNode,
    this.textInputAction,
    this.onFieldSubmitted,
    this.contentPadding,
    this.fillColor,
    this.borderColor,
    this.focusedBorderColor,
    this.errorBorderColor,
    this.borderRadius = 12.0,
    this.borderWidth = 1.0,
    this.textStyle,
    this.labelStyle,
    this.hintStyle,
    this.filled = true,
    this.initialValue,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final backgroundColor =
        fillColor ?? Colors.transparent;

    // Always white border
    final Color normalBorderColor =
        borderColor ?? Colors.white;

    final Color focusColor =
        focusedBorderColor ?? Colors.white;

    final Color errorColor =
        errorBorderColor ?? Colors.white;

    final OutlineInputBorder normalBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(borderRadius),
      borderSide: BorderSide(
        color: normalBorderColor,
        width: borderWidth,
      ),
    );

    final OutlineInputBorder focusedBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(borderRadius),
      borderSide: BorderSide(
        color: focusColor,
        width: borderWidth,
      ),
    );

    final OutlineInputBorder errorBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(borderRadius),
      borderSide: BorderSide(
        color: errorColor,
        width: borderWidth,
      ),
    );

    return TextFormField(
      controller: controller,
      initialValue: initialValue,
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: validator,
      onChanged: onChanged,
      onSaved: onSaved,
      onTap: onTap,
      readOnly: readOnly,
      maxLines: maxLines,
      minLines: minLines,
      maxLength: maxLength,
      enabled: enabled,
      focusNode: focusNode,
      textInputAction: textInputAction,
      onFieldSubmitted: onFieldSubmitted,

      style: textStyle ??
          theme.textTheme.bodyLarge?.copyWith(
            color: Colors.white,
          ),

      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        helperText: helperText,

        // Normal border
        border: normalBorder,

        // Important: explicitly define enabled border
        enabledBorder: normalBorder,

        // Focused border
        focusedBorder: focusedBorder,

        // Error border - WHITE instead of red
        errorBorder: errorBorder,

        // Error + focused - WHITE instead of red
        focusedErrorBorder: errorBorder,

        // Disabled border
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadius),
          borderSide: BorderSide(
            color: Colors.white.withValues(alpha: 0.5),
            width: borderWidth,
          ),
        ),

        filled: filled,
        fillColor: backgroundColor,

        contentPadding: contentPadding ??
            const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),

        labelStyle: labelStyle ??
            theme.textTheme.bodyMedium?.copyWith(
              color: Colors.white,
            ),

        hintStyle: hintStyle ??
            theme.textTheme.bodyMedium?.copyWith(
              color: Colors.white.withValues(alpha: 0.7),
            ),

        // Error text also white
        errorStyle: const TextStyle(
          color: Colors.white,
          fontSize: 12,
        ),

        prefixIcon: prefixIcon != null && prefix == null
            ? Icon(
                prefixIcon,
                color: Colors.white,
              )
            : null,

        prefix: prefix,

        suffixIcon: suffixIcon != null
            ? GestureDetector(
                onTap: onSuffixIconTap,
                child: Icon(
                  suffixIcon,
                  color: Colors.white,
                ),
              )
            : null,
      ),
    );
  }
}