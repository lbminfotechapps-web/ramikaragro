import 'package:solufine/features/home/doman/home_entity/menu_entity.dart';

String _normalize(String value) => value
    .toLowerCase()
    .replaceAll('&', ' and ')
    .replaceAll(RegExp(r'[^a-z0-9\s]'), ' ')
    .split(RegExp(r'\s+'))
    .where((word) => word.isNotEmpty)
    .map(
      (word) => switch (word) {
        'expenses' || 'exepense' => 'expense',
        'menus' => 'menu',
        'farmers' => 'farmer',
        'dealers' => 'dealer',
        _ => word,
      },
    )
    .join(' ');

/// Rank matches from the current user’s menus, preferring exact names and shortcuts.
List<MenuEntity> matchVoiceMenus(String spoken, List<MenuEntity> menus) {
  final command = _normalize(spoken)
      .replaceFirst(
        RegExp(r'^(please )?(open|go to|navigate to|show me|show) '),
        '',
      )
      .replaceFirst(RegExp(r'^the '), '')
      .replaceFirst(RegExp(r' (menu|page|screen)?\s*please$'), '')
      .replaceFirst(RegExp(r' (menu|page|screen)$'), '')
      .trim();
  if (command.isEmpty) return [];
  final exact = menus
      .where((menu) => _normalize(menu.menuName) == command)
      .toList();
  if (exact.isNotEmpty) return exact;
  final shortcutId = switch (command) {
    'farmer' || 'farmer list' || 'list farmer' => '8',
    'dealer' || 'dealer list' || 'list dealer' => '3',
    'expense' => '9',
    _ => null,
  };
  final shortcut = menus.where((menu) => menu.menuId == shortcutId).toList();
  if (shortcut.isNotEmpty) return shortcut;
  final words = command.split(' ').toSet();
  final matches = menus.where((menu) {
    final nameWords = _normalize(menu.menuName).split(' ').toSet();
    return nameWords.containsAll(words);
  }).toList();
  // Prefer the shortest matching menu name, then a stable ID for ties.
  matches.sort((a, b) {
    final lengthOrder = _normalize(
      a.menuName,
    ).split(' ').length.compareTo(_normalize(b.menuName).split(' ').length);
    return lengthOrder != 0 ? lengthOrder : a.menuId.compareTo(b.menuId);
  });
  return matches;
}
