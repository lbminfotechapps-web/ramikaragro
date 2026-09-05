import 'package:flutter/material.dart';

class CustomTextFormField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final IconData prefixIcon;
  final IconData? suffixIcon;
  final VoidCallback? onSuffixIconTap;
  final bool obscureText;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final bool enabled;
  final int maxLines;

  const CustomTextFormField({
    super.key,
    required this.controller,
    required this.hintText,
    required this.prefixIcon,
    this.suffixIcon,
    this.onSuffixIconTap,
    this.obscureText = false,
    this.keyboardType,
    this.validator,
    this.enabled = true,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        validator: validator,
        enabled: enabled,
        maxLines: maxLines,

        style: const TextStyle(
          fontSize: 16,
          color: Colors.black87,
        ),

        decoration: InputDecoration(
          hintText: hintText,

          hintStyle: TextStyle(
            color: Colors.grey.shade500,
            fontSize: 17,
          ),

          prefixIcon: Padding(
            padding: const EdgeInsets.all(10),
            child: Container(
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFFE4F4E9),
              ),
              child: Icon(
                prefixIcon,
                color: Color(0xFF087C3A),
                size: 22,
              ),
            ),
          ),

          suffixIcon: suffixIcon != null
              ? IconButton(
                  onPressed: onSuffixIconTap,
                  icon: Icon(
                    suffixIcon,
                    color: Colors.grey.shade500,
                  ),
                )
              : null,

          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(22),
            borderSide: BorderSide(
              color: Colors.grey.shade200,
            ),
          ),

          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(22),
            borderSide: BorderSide(
              color: Colors.grey.shade200,
            ),
          ),

          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(22),
            borderSide: const BorderSide(
              color: Color(0xFF087C3A),
              width: 1.5,
            ),
          ),

          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(22),
            borderSide: const BorderSide(
              color: Colors.red,
            ),
          ),

          contentPadding: const EdgeInsets.symmetric(
            horizontal: 18,
            vertical: 20,
          ),
        ),
      ),
    );
  }
}