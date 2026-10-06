import 'package:flutter/foundation.dart';

/// Refreshes an existing tab without recreating its navigation stack.
class TabRefresh extends ChangeNotifier {
  static final home = TabRefresh();
  static final followup = TabRefresh();
  static final products = TabRefresh();

  void refresh() => notifyListeners();
}
