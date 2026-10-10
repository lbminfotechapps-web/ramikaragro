import 'package:solufine/core/theme/app_dynamic_colors.dart';
import 'package:flutter/material.dart';

class CustomDropdown<T> extends StatelessWidget {
  final FocusNode? focusNode;
  final GlobalKey<FormFieldState>? fieldKey;
  final bool isValid;
  final String hintText;
  final IconData prefixIcon;
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?>? onChanged;
  final bool enabled;
  final bool compactItems;
  final String? Function(T?)? validator;

  const CustomDropdown({
    super.key,
    this.focusNode,
    this.fieldKey,
    this.isValid = false,
    required this.hintText,
    required this.prefixIcon,
    required this.value,
    required this.items,
    required this.onChanged,
    this.enabled = true,
    this.compactItems = false,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<T>(
      key: fieldKey,
      focusNode: focusNode,
      value: value,
      itemHeight: compactItems ? null : kMinInteractiveDimension,
      // Keep menu padding out of the shorter selected-value display.
      selectedItemBuilder: compactItems
          ? (context) => items
                .map(
                  (item) => Align(alignment: item.alignment, child: item.child),
                )
                .toList()
          : null,

      isExpanded: true,

      onChanged: enabled ? onChanged : null,

      validator: validator,

      style: TextStyle(
        fontSize: 16,
        color: enabled ? context.appOnCard : context.appSubText,
      ),

      icon: Icon(
        Icons.keyboard_arrow_down_rounded,
        color: enabled ? context.appSubText : context.appSubText,
      ),

      decoration: InputDecoration(
        hintText: hintText,

        hintStyle: TextStyle(
          color: enabled ? context.appSubText : context.appSubText,
          fontSize: 17,
        ),

        prefixIcon: Padding(
          padding: const EdgeInsets.all(10),

          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Color.alphaBlend(context.appPrimary.withValues(alpha: 0.1), context.appCard),
            ),

            child: Icon(
              prefixIcon,
              color: enabled ? context.appPrimary : context.appSubText,
              size: 22,
            ),
          ),
        ),

        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: context.appBorder),
        ),

        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(
            color: isValid ? context.appPrimary : context.appBorder,
          ),
        ),

        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: context.appPrimary, width: 1.5),
        ),

        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: context.appBorder),
        ),

        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(22),
          borderSide: BorderSide(color: context.appError),
        ),

        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(22),
          borderSide: BorderSide(color: context.appError, width: 1.5),
        ),

        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),

      items: compactItems
          ? items.map((item) => _CompactDropdownMenuItem<T>(item)).toList()
          : items,
    );
  }
}

// Natural row height keeps the menu compact while allowing larger text to grow.
class _CompactDropdownMenuItem<T> extends DropdownMenuItem<T> {
  _CompactDropdownMenuItem(DropdownMenuItem<T> item)
    : super(
        key: item.key,
        value: item.value,
        onTap: item.onTap,
        enabled: item.enabled,
        alignment: item.alignment,
        child: item.child,
      );

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Align(alignment: alignment, heightFactor: 1, child: child),
    );
  }
}
