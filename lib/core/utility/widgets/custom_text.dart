
import 'package:demo/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil_plus/flutter_screenutil_plus.dart';

class CustomText extends StatelessWidget {
  final String text;
  final double? fontSize;
  final FontWeight? fontWeight;
  final Color? color;
  final List<Shadow>? shadow;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;
  final double? height;
  final TextDecoration? decoration;
  final Color? decorationColor;
  final TextDecorationStyle? decorationStyle;
  final double? decorationThickness;

  const CustomText({
    super.key,
    required this.text,
    this.fontSize,
    this.fontWeight,
    this.color,
    this.shadow,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.height,
    this.decoration,
    this.decorationColor,
    this.decorationStyle,
    this.decorationThickness,
  });

  @override
  Widget build(BuildContext context) {
    final resolvedColor = color ?? Theme.of(context).colorScheme.onSurface;

    return Text(
      text,
      style: TextStyle(
        fontSize: (fontSize ?? 14).sp,
        fontWeight: fontWeight ?? FontWeight.normal,
        color: resolvedColor,
        height: height,
        decoration: decoration,
        decorationColor: decorationColor,
        decorationStyle: decorationStyle,
        decorationThickness: decorationThickness,
        shadows: shadow,
      ),
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
    );
  }
}

// Predefined text styles for common use cases
class CustomTextStyles {
  static CustomText heading({
    required String text,
    double fontSize = 24,
    FontWeight fontWeight = FontWeight.bold,
    Color? color,
    TextAlign? textAlign,
  }) {
    return CustomText(
      text: text,
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      textAlign: textAlign,
    );
  }

  static CustomText title({
    required String text,
    double fontSize = 18,
    FontWeight fontWeight = FontWeight.w600,
    Color? color,
    TextAlign? textAlign,
  }) {
    return CustomText(
      text: text,
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      textAlign: textAlign,
    );
  }

  static CustomText body({
    required String text,
    double fontSize = 14,
    FontWeight fontWeight = FontWeight.normal,
    Color? color,
    TextAlign? textAlign,
    int? maxLines,
    TextOverflow? overflow,
  }) {
    return CustomText(
      text: text,
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
    );
  }

  static CustomText caption({
    required String text,
    double fontSize = 12,
    FontWeight fontWeight = FontWeight.w500,
    Color? color,
    TextAlign? textAlign,
  }) {
    return CustomText(
      text: text,
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      textAlign: textAlign,
    );
  }

  static CustomText button({
    required String text,
    double fontSize = 16,
    FontWeight fontWeight = FontWeight.w600,
    Color? color,
    TextAlign? textAlign,
  }) {
    return CustomText(
      text: text,
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      textAlign: textAlign,
    );
  }
}
