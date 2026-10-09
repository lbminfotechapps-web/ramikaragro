
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:solufine/core/theme/app_theme_colors.dart';
import 'package:solufine/core/theme/app_theme_palette.dart';
import 'package:solufine/core/theme/cubit/theme_cubit.dart';
import 'package:solufine/core/theme/cubit/theme_state.dart';



class ThemePickerSheet extends StatelessWidget {
  const ThemePickerSheet({super.key});

  // ============================================================
  // SHOW THEME BOTTOM SHEET
  // ============================================================

  static Future<void> show(BuildContext context) async {
    // Capture the existing cubit before opening the modal.
    final themeCubit = context.read<ThemeCubit>();

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return BlocProvider<ThemeCubit>.value(
          value: themeCubit,
          child: const ThemePickerSheet(),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeState>(
      builder: (context, state) {
        final colors = Theme.of(context).colorScheme;
        final theme = Theme.of(context);

        return SafeArea(
          top: false,
          child: Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.sizeOf(context).height * 0.85,
            ),
            decoration: BoxDecoration(
              color: colors.surface,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(28),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ============================================
                // HEADER
                // ============================================
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
                  child: Row(
                    children: [
                      Container(
                        width: 46,
                        height: 46,
                        decoration: BoxDecoration(
                          color: colors.primary.withValues(alpha: 0.10),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(
                          Icons.palette_outlined,
                          color: colors.primary,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Choose App Theme',
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontSize: 19,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              'Select your favorite color combination',
                              style: theme.textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        tooltip: 'Close',
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.close_rounded),
                      ),
                    ],
                  ),
                ),

                Divider(height: 1, color: theme.dividerColor),

                // ============================================
                // THEME GRID
                // ============================================
                Flexible(
                  child: GridView.builder(
                    shrinkWrap: true,
                    padding: const EdgeInsets.all(18),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 14,
                          mainAxisSpacing: 14,
                          childAspectRatio: 1.25,
                        ),
                    itemCount: AppThemeColors.all.length,
                    itemBuilder: (context, index) {
                      final palette = AppThemeColors.all[index];

                      final isSelected =
                          state.selectedTheme.id == palette.id;

                      return _ThemeOptionCard(
                        palette: palette,
                        isSelected: isSelected,
                        onTap: () {
                          context.read<ThemeCubit>().changeTheme(palette);

                          // The selected theme applies immediately.
                          // Keep the sheet open to allow comparison.
                        },
                      );
                    },
                  ),
                ),

                // ============================================
                // FOOTER
                // ============================================
                Padding(
                  padding: const EdgeInsets.fromLTRB(18, 8, 18, 18),
                  child: Column(
                    children: [
                      Text(
                        'Current theme: ${state.selectedTheme.name}',
                        style: theme.textTheme.bodySmall,
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: const Text('Done'),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ============================================================
// INDIVIDUAL THEME PREVIEW CARD
// ============================================================

class _ThemeOptionCard extends StatelessWidget {
  final AppThemePalette palette;
  final bool isSelected;
  final VoidCallback onTap;

  const _ThemeOptionCard({
    required this.palette,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    // Use the palette's actual foreground for readable text.
    final previewBackground = palette.appBarBackground;
    final previewForeground = palette.appBarForeground;

    return Material(
      color: colors.surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected
                  ? colors.primary
                  : colors.outlineVariant,
              width: isSelected ? 2.5 : 1,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(13),
            child: Column(
              children: [
                Expanded(
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    color: previewBackground,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Aa',
                              style: TextStyle(
                                color: previewForeground,
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            if (isSelected)
                              Icon(
                                Icons.check_circle_rounded,
                                color: previewForeground,
                                size: 23,
                              ),
                          ],
                        ),
                        const Spacer(),
                        Container(
                          width: 58,
                          height: 9,
                          decoration: BoxDecoration(
                            color: previewForeground,
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                        const SizedBox(height: 5),
                        Container(
                          width: 38,
                          height: 6,
                          decoration: BoxDecoration(
                            color: previewForeground.withValues(
                              alpha: 0.55,
                            ),
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: colors.surface,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          palette.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: colors.onSurface,
                            fontSize: 12,
                            fontWeight: isSelected
                                ? FontWeight.w700
                                : FontWeight.w500,
                          ),
                        ),
                      ),
                      if (isSelected)
                        Icon(
                          Icons.check_rounded,
                          color: colors.primary,
                          size: 17,
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
