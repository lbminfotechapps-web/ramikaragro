import 'package:flutter/material.dart';

class CustomDropdown<T> extends StatelessWidget {
  final String hintText;
  final IconData prefixIcon;
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?>? onChanged;
  final bool enabled;
  final String? Function(T?)? validator;

  const CustomDropdown({
    super.key,
    required this.hintText,
    required this.prefixIcon,
    required this.value,
    required this.items,
    required this.onChanged,
    this.enabled = true,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: enabled
            ? Colors.white
            : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(22),
        boxShadow: enabled
            ? [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : [],
      ),
      child: DropdownButtonFormField<T>(
        value: value,

        isExpanded: true,

        onChanged: enabled ? onChanged : null,

        validator: validator,

        style: TextStyle(
          fontSize: 16,
          color: enabled
              ? Colors.black87
              : Colors.grey.shade500,
        ),

        icon: Icon(
          Icons.keyboard_arrow_down_rounded,
          color: enabled
              ? Colors.grey.shade600
              : Colors.grey.shade400,
        ),

        decoration: InputDecoration(
          hintText: hintText,

          hintStyle: TextStyle(
            color: enabled
                ? Colors.grey.shade500
                : Colors.grey.shade400,
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
                color: enabled
                    ? const Color(0xFF087C3A)
                    : Colors.grey.shade400,
                size: 22,
              ),
            ),
          ),

          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(
              color: Colors.grey.shade200,
            ),
          ),

          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(
              color: Colors.grey.shade200,
            ),
          ),

          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(
              color: Color(0xFF087C3A),
              width: 1.5,
            ),
          ),

          disabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(
              color: Colors.grey.shade200,
            ),
          ),

          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(22),
            borderSide: const BorderSide(
              color: Colors.red,
            ),
          ),

          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(22),
            borderSide: const BorderSide(
              color: Colors.red,
              width: 1.5,
            ),
          ),

          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),

        items: items,
      ),
    );
  }
}