import 'package:flutter_test/flutter_test.dart';
import 'package:solufine/features/home/doman/home_entity/menu_entity.dart';
import 'package:solufine/features/home/presentation/widgets/voice_menu_matcher.dart';

void main() {
  const menus = [
    MenuEntity(menuId: '9', menuName: 'Add Expense', iconImage: ''),
    MenuEntity(menuId: '13', menuName: 'Expense List', iconImage: ''),
    MenuEntity(
      menuId: '82',
      menuName: 'Sales Target & Achievement',
      iconImage: '',
    ),
    MenuEntity(menuId: '8', menuName: 'Farmer Visit', iconImage: ''),
    MenuEntity(menuId: '3', menuName: 'Dealer Visit', iconImage: ''),
    MenuEntity(menuId: '17', menuName: 'In Punch', iconImage: ''),
  ];

  test('matches commands, case, punctuation and expense variants', () {
    for (final command in [
      'add expense',
      'Please open Add Expenses!',
      'go to the add expense page',
      'add exepense',
    ]) {
      expect(matchVoiceMenus(command, menus).single.menuId, '9');
    }
  });

  test('matches every supplied menu name', () {
    for (final menu in menus) {
      expect(
        matchVoiceMenus('open ${menu.menuName}', menus).single.menuId,
        menu.menuId,
      );
    }
    expect(
      matchVoiceMenus('sales target and achievement', menus).single.menuId,
      '82',
    );
    expect(matchVoiceMenus('punch in', menus).single.menuId, '17');
  });

  test('uses shortcuts while preserving exact menu names', () {
    for (final command in ['farmer', 'farmer list', 'open farmers list']) {
      expect(matchVoiceMenus(command, menus).first.menuId, '8');
    }
    for (final command in ['dealer', 'dealer list', 'show dealers']) {
      expect(matchVoiceMenus(command, menus).first.menuId, '3');
    }
    expect(matchVoiceMenus('expense', menus).first.menuId, '9');
    expect(matchVoiceMenus('expense list', menus).first.menuId, '13');
    expect(
      matchVoiceMenus(
        'farmer list',
        menus.where((m) => m.menuId != '8').toList(),
      ),
      isEmpty,
    );
  });

  test('ranks general matches consistently regardless of menu order', () {
    final extra = [
      ...menus,
      const MenuEntity(
        menuId: '67',
        menuName: 'Team Expense List',
        iconImage: '',
      ),
    ];
    expect(matchVoiceMenus('list', extra).first.menuId, '13');
    expect(matchVoiceMenus('list', extra.reversed.toList()).first.menuId, '13');
  });

  test('does not match unavailable menus, empty speech or unrelated words', () {
    for (final command in [
      '',
      ' ',
      'weather',
      'add dealer',
      'do not add expense',
    ]) {
      expect(matchVoiceMenus(command, menus), isEmpty);
    }
    expect(matchVoiceMenus('add expense', menus.sublist(1)), isEmpty);
  });
}
