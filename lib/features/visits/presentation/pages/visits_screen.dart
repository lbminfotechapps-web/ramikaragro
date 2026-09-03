import 'package:flutter/material.dart';

class VisitsScreen extends StatelessWidget {
   const VisitsScreen({super.key});

   @override
   Widget build(BuildContext context) {
     return Scaffold(
       backgroundColor: Colors.white,
       appBar: AppBar(
         title: const Text('Visits'),
         centerTitle: true,
       ),
       body: Center(
         child: Column(
           mainAxisAlignment: MainAxisAlignment.center,
           children: [
             const Text('Visits Screen'),
             const SizedBox(height: 20),
             ElevatedButton(
               onPressed: () {
                 Navigator.pushNamed(context, '/holding');
               },
               child: const Text('Go to Holding Screen'),
             ),
           ],
         ),
       ),
     );
   }
 }