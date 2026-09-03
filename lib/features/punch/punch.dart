import 'package:flutter/material.dart'
    show StatelessWidget, Widget, Scaffold, BuildContext, Text, AppBar, Center;

class Punch extends StatelessWidget {
  const Punch({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Punch')),
      body: Center(child: Text('Punch')),
    );
  }
}
