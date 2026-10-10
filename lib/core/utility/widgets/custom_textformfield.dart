import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:solufine/core/theme/app_dynamic_colors.dart';

class CustomTextFormField extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode? focusNode;
  final GlobalKey<FormFieldState>? fieldKey;
  final bool isValid;
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

  final TextInputAction? textInputAction;
  final ValueChanged<String>? onFieldSubmitted;

  final bool showKeyboardDone;

  const CustomTextFormField({
    super.key,
    this.focusNode,
    this.fieldKey,
    this.isValid = false,
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
    this.textInputAction,
    this.onFieldSubmitted,
    this.showKeyboardDone = true,
  });

  @override
  Widget build(BuildContext context) {
    final textField = TextFormField(
      key: fieldKey,
      focusNode: focusNode,
      controller: controller,
      maxLength: maxLength,
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: validator,
      enabled: enabled,
      maxLines: maxLines,
      readOnly: readOnly,
      onTap: onTap,
      onChanged: onChanged,

      textInputAction: textInputAction,

      onFieldSubmitted: (value) {
        if (onFieldSubmitted != null) {
          onFieldSubmitted!(value);
        } else {
          FocusScope.of(context).unfocus();
        }
      },

      style: TextStyle(fontSize: 14, color: context.appText),

      decoration: InputDecoration(
        hintText: hintText,
        labelText: labelText,

        labelStyle: TextStyle(
          color: context.appSubText,
          fontSize: 16,
          fontWeight: FontWeight.w400,
        ),

        floatingLabelStyle: TextStyle(
          color: context.appPrimary,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),

        hintStyle: TextStyle(
          color: context.appSubText,
          fontSize: 16,
          fontWeight: FontWeight.w400,
        ),

        prefixIcon: Padding(
          padding: const EdgeInsets.all(10),
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Color.alphaBlend(context.appPrimary.withValues(alpha: 0.1), context.appCard),
            ),
            child: Icon(prefixIcon, color: context.appPrimary, size: 22),
          ),
        ),

        suffixIcon: suffixIcon != null
            ? IconButton(
                onPressed: onSuffixIconTap,
                icon: Icon(suffixIcon, color: context.appSubText),
              )
            : null,

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

        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: context.appError),
        ),

        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: context.appError, width: 1.5),
        ),

        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
    );

    if (!showKeyboardDone) {
      return textField;
    }

    return _KeyboardDoneOverlay(child: textField);
  }
}

class _KeyboardDoneOverlay extends StatefulWidget {
  final Widget child;

  const _KeyboardDoneOverlay({required this.child});

  @override
  State<_KeyboardDoneOverlay> createState() => _KeyboardDoneOverlayState();
}

class _KeyboardDoneOverlayState extends State<_KeyboardDoneOverlay>
    with WidgetsBindingObserver {
  OverlayEntry? _entry;
  bool _focused = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  void _updateToolbar() {
    if (!mounted) return;
    final keyboardHeight =
        View.of(context).viewInsets.bottom / View.of(context).devicePixelRatio;
    final routeVisible = ModalRoute.of(context)?.isCurrent ?? true;
    if (kIsWeb ||
        defaultTargetPlatform != TargetPlatform.iOS ||
        !_focused ||
        keyboardHeight <= 0 ||
        !routeVisible) {
      _removeToolbar();
      return;
    }
    if (_entry != null) {
      _entry!.markNeedsBuild();
      return;
    }
    _entry = OverlayEntry(
      builder: (overlayContext) {
        final view = View.of(overlayContext);
        final inset = view.viewInsets.bottom / view.devicePixelRatio;
        return Positioned(
          left: 0,
          right: 0,
          bottom: inset,
          child: ExcludeFocus(
            child: TextFieldTapRegion(
              child: Material(
                color: Theme.of(overlayContext).colorScheme.surface,
                elevation: 2,
                child: Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => FocusScope.of(context).unfocus(),
                    style: TextButton.styleFrom(
                      foregroundColor: Theme.of(overlayContext).colorScheme.primary,
                      textStyle: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    child: const Text('Done'),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
    Overlay.of(context, rootOverlay: true).insert(_entry!);
  }

  void _removeToolbar() {
    _entry?.remove();
    _entry?.dispose();
    _entry = null;
  }

  @override
  void didChangeMetrics() {
    WidgetsBinding.instance.addPostFrameCallback((_) => _updateToolbar());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    WidgetsBinding.instance.addPostFrameCallback((_) => _updateToolbar());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _removeToolbar();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      canRequestFocus: false,
      onFocusChange: (focused) {
        _focused = focused;
        WidgetsBinding.instance.addPostFrameCallback((_) => _updateToolbar());
      },
      child: widget.child,
    );
  }
}
