import 'package:flutter/material.dart';

class Holding extends StatelessWidget {
  const Holding({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Holding'), centerTitle: true),
      body: Center(child: Text('Holding')),
    );
  }
}
