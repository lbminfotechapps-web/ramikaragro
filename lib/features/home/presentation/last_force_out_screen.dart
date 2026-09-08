import 'package:demo/features/home/doman/home_entity/punch_stat_entity.dart';
import 'package:flutter/material.dart';

class LastForceOutScreen extends StatelessWidget {
  final PunchStatEntity? punchStat;
  const LastForceOutScreen(this.punchStat, {super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Center(child: Text('last force out punch')));
  }
}
