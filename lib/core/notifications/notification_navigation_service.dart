import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';

class NotificationNavigationService {
  NotificationNavigationService._();

  static final NotificationNavigationService instance =
      NotificationNavigationService._();

  GoRouter? _router;

  // ============================================================
  // SET ROUTER
  // ============================================================

  void setRouter(GoRouter router) {
    _router = router;

    debugPrint(
      'NotificationNavigationService router registered',
    );
  }

  // ============================================================
  // HANDLE NAVIGATION
  // ============================================================

  void handleNotification(
    Map<String, dynamic> data,
  ) {
    debugPrint('======================================');
    debugPrint('NOTIFICATION NAVIGATION');
    debugPrint('DATA: $data');
    debugPrint('======================================');

    final String type =
        data['type']?.toString() ?? '';

    final String id =
        data['id']?.toString() ?? '';

    debugPrint('TYPE : $type');
    debugPrint('ID   : $id');

    if (_router == null) {
      debugPrint(
        'ERROR: GoRouter is not registered',
      );

      return;
    }

    switch (type) {
      // ========================================================
      // COMPLAINT
      // ========================================================

      case 'complaint':
        debugPrint(
          'Opening complaint: $id',
        );

        /*
        _router!.push(
          '/complaint-details/$id',
        );
        */

        break;

      // ========================================================
      // FOLLOWUP
      // ========================================================

      case 'followup':
        debugPrint(
          'Opening followup: $id',
        );

        /*
        _router!.push(
          '/followup-details/$id',
        );
        */

        break;

      // ========================================================
      // LEAVE
      // ========================================================

      case 'leave':
        debugPrint(
          'Opening leave: $id',
        );

        /*
        _router!.push(
          '/leave-details/$id',
        );
        */

        break;

      // ========================================================
      // DEFAULT
      // ========================================================

      default:
        debugPrint(
          'Unknown notification type: $type',
        );

        /*
        _router!.go('/home');
        */
    }
  }
}