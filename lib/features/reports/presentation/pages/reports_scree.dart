import 'package:flutter/material.dart';

class ReportsScree extends StatelessWidget {
  const ReportsScree({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: const Text('Reports'), centerTitle: true),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Reports Screen'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/holding');
              },
              child: const Text('Go to Holding'),
            ),
          ],
        ),
      ),
    );
  }
}
