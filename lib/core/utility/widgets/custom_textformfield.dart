import 'package:demo/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

class CustomTextFormField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final String? labelText;
  final IconData prefixIcon;
  final IconData? suffixIcon;
  final VoidCallback? onSuffixIconTap;
  final bool obscureText;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final bool enabled;
  final int maxLines;
  final int? maxLength;
  final bool readOnly;
  final VoidCallback? onTap;
  final ValueChanged<String>? onChanged;

  const CustomTextFormField({
    super.key,
    required this.controller,
    required this.hintText,
    this.labelText,
    required this.prefixIcon,
    this.suffixIcon,
    this.onSuffixIconTap,
    this.obscureText = false,
    this.keyboardType,
    this.validator,
    this.enabled = true,
    this.maxLines = 1,
    this.readOnly = false,
    this.onTap,
    this.onChanged,
    this.maxLength,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      maxLength: maxLength,
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: validator,
      enabled: enabled,
      maxLines: maxLines,
      readOnly: readOnly,
      onTap: onTap,
      onChanged: onChanged,
    
      style: const TextStyle(fontSize: 16, color: Colors.black87),
    
      decoration: InputDecoration(
        hintText: hintText,
        labelText: labelText,
    
        // Normal label
        labelStyle: TextStyle(
          color: Colors.grey.shade500, // inside field
          fontSize: 16,
          fontWeight: FontWeight.w400,
        ),
    
        floatingLabelStyle: TextStyle(
          color: AppColors.accentGreen, // floating at top
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
    
        // Floating label when focused / text entered
        // floatingLabelStyle: TextStyle(
        //   color: AppColors.accentGreen,
        //   fontSize: 14,
        //   fontWeight: FontWeight.w600,
        // ),
    
        // Hint remains grey
        hintStyle: TextStyle(
          color: Colors.grey.shade500,
          fontSize: 16,
          fontWeight: FontWeight.w400,
        ),
    
        prefixIcon: Padding(
          padding: const EdgeInsets.all(10),
          child: Container(
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFFE4F4E9),
            ),
            child: Icon(prefixIcon, color: AppColors.accentGreen, size: 22),
          ),
        ),
    
        suffixIcon: suffixIcon != null
            ? IconButton(
                onPressed: onSuffixIconTap,
                icon: Icon(suffixIcon, color: Colors.grey.shade500),
              )
            : null,
    
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
    
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
    
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFF087C3A), width: 1.5),
        ),
    
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.red),
        ),
    
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.red, width: 1.5),
        ),
    
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
    );
  }
}
