import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

class AppTutorialService {
  AppTutorialService._();

  static const String _dealerListTutorialKey = 'dealer_list_tutorial_completed';

  static const String _expenseTutorialKey = 'expense_tutorial_completed';

  static TutorialCoachMark? _tutorial;

  static TutorialCoachMark? _placeOrderTutorial;
  static Completer<bool>? _placeOrderCompletion;

  static Future<void> resetPlaceOrderTutorial() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('place_order_setup_tutorial_completed');
    await prefs.remove('place_order_products_tutorial_completed');
  }

  // Returns when the stage closes, so the next stage cannot overlap it.
  static Future<bool> showPlaceOrderTutorial({
    required BuildContext context,
    required List<TargetFocus> targets,
    required bool productStage,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final key = productStage
        ? 'place_order_products_tutorial_completed'
        : 'place_order_setup_tutorial_completed';
    if (prefs.getBool(key) ?? false) return true;
    if (!context.mounted || targets.isEmpty || _tutorial != null) return false;
    if (targets.any((target) => target.keyTarget?.currentContext == null)) {
      return false;
    }

    final completion = Completer<bool>();
    _placeOrderCompletion = completion;
    void completeStage() {
      prefs.setBool(key, true);
      _tutorial = null;
      _placeOrderTutorial = null;
      _placeOrderCompletion = null;
      if (!completion.isCompleted) completion.complete(true);
    }

    final tutorial = TutorialCoachMark(
      targets: targets,
      colorShadow: Colors.black,
      opacityShadow: 0.84,
      paddingFocus: 8,
      pulseEnable: true,
      hideSkip: true,
      onFinish: completeStage,
      onSkip: () {
        completeStage();
        return true;
      },
    );
    _tutorial = tutorial;
    _placeOrderTutorial = tutorial;
    tutorial.show(context: context);
    return completion.future;
  }

  static void dismissPlaceOrderTutorial() {
    final tutorial = _placeOrderTutorial;
    if (tutorial == null) return;
    tutorial.removeOverlayEntry();
    if (identical(_tutorial, tutorial)) _tutorial = null;
    _placeOrderTutorial = null;
    final completion = _placeOrderCompletion;
    _placeOrderCompletion = null;
    if (completion != null && !completion.isCompleted) {
      completion.complete(false);
    }
  }

  // ============================================================
  // CHECK COMPLETED
  // ============================================================

  static Future<bool> isDealerListTutorialCompleted() async {
    final prefs = await SharedPreferences.getInstance();

    return prefs.getBool(_dealerListTutorialKey) ?? false;
  }

  // ============================================================
  // SAVE COMPLETED
  // ============================================================

  static Future<void> _markDealerListCompleted() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setBool(_dealerListTutorialKey, true);
  }

  static Future<void> resetExpenseTutorial() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove(_expenseTutorialKey);
  }

  static Future<void> showExpenseTutorial({
    required BuildContext context,
    required List<TargetFocus> targets,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    final bool alreadyCompleted = prefs.getBool(_expenseTutorialKey) ?? false;

    if (alreadyCompleted) {
      debugPrint('Expense tutorial already completed');

      return;
    }

    if (!context.mounted || targets.isEmpty) {
      return;
    }

    _tutorial = TutorialCoachMark(
      targets: targets,

      colorShadow: Colors.black,

      opacityShadow: 0.84,

      paddingFocus: 8,

      pulseEnable: true,

      hideSkip: true,

      focusAnimationDuration: const Duration(milliseconds: 400),

      unFocusAnimationDuration: const Duration(milliseconds: 300),

      onFinish: () async {
        final prefs = await SharedPreferences.getInstance();

        await prefs.setBool(_expenseTutorialKey, true);

        _tutorial = null;
      },

      onSkip: () {
        SharedPreferences.getInstance().then((prefs) {
          prefs.setBool(_expenseTutorialKey, true);
        });

        _tutorial = null;

        return true;
      },
    );

    _tutorial!.show(context: context);
  }
  // ============================================================
  // NEXT
  // ============================================================

  static void next() {
    _tutorial?.next();
  }

  // ============================================================
  // SKIP
  // ============================================================

  static void skip() {
    _tutorial?.skip();
  }

  // ============================================================
  // SHOW DEALER LIST TUTORIAL
  // ============================================================

  static Future<void> showDealerListTutorial({
    required BuildContext context,
    required List<TargetFocus> targets,
  }) async {
    final alreadyCompleted = await isDealerListTutorialCompleted();

    if (alreadyCompleted) {
      debugPrint('Dealer list tutorial already completed');

      return;
    }

    if (!context.mounted) {
      return;
    }

    if (targets.isEmpty) {
      return;
    }

    _tutorial = TutorialCoachMark(
      targets: targets,

      colorShadow: Colors.black,
      opacityShadow: 0.84,

      paddingFocus: 8,

      pulseEnable: true,

      focusAnimationDuration: const Duration(milliseconds: 400),

      unFocusAnimationDuration: const Duration(milliseconds: 300),

      pulseAnimationDuration: const Duration(milliseconds: 800),

      // We are making our own SKIP button
      hideSkip: true,

      // Prevent accidental overlay taps.
      // User must press NEXT or SKIP.
      onFinish: () async {
        await _markDealerListCompleted();

        _tutorial = null;

        debugPrint('Dealer tutorial completed');
      },

      onSkip: () {
        _markDealerListCompleted();

        _tutorial = null;

        return true;
      },
    );

    _tutorial!.show(context: context);
  }

  // ============================================================
  // RESET - ONLY FOR DEVELOPMENT
  // ============================================================

  static Future<void> resetDealerListTutorial() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove(_dealerListTutorialKey);
  }
}
