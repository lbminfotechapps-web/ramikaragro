
import 'package:flutter/material.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: const Text('Home'), centerTitle: true),
      body: Center(child: Text('home')),

      // FutureBuilder<Map<String, dynamic>?>(
      //   future: SecureStorage.instance.getUserData(),
      //   builder: (context, snapshot) {
      //     if (snapshot.connectionState == ConnectionState.waiting) {
      //       return const Center(child: CircularProgressIndicator());
      //     }

      //     if (snapshot.hasError) {
      //       return Center(
      //         child: Text('Error loading user data: ${snapshot.error}'),
      //       );
      //     }

      //     final user = snapshot.data;

      //     if (user == null || user.isEmpty) {
      //       return const Center(child: Text('No stored user data found.'));
      //     }

      //     final userName = user['user_name'] ?? 'N/A';
      //     final userEmail = user['user_email'] ?? 'N/A';
      //     final userId = user['user_id'] ?? 'N/A';
      //     final mobile = user['fld_mobile_no'] ?? 'N/A';
      //     final designation = user['designation'] ?? 'N/A';

      //     final items = <MapEntry<String, String>>[
      //       MapEntry('User Name', userName.toString()),
      //       MapEntry('Email', userEmail.toString()),
      //       MapEntry('User ID', userId.toString()),
      //       MapEntry('Mobile', mobile.toString()),
      //       MapEntry('Designation', designation.toString()),
      //     ];

      //     return Padding(
      //       padding: const EdgeInsets.all(20),
      //       child: Column(
      //         crossAxisAlignment: CrossAxisAlignment.start,
      //         children: [
      //           const SizedBox(height: 12),

      //           Text(
      //             'Welcome, $userName',
      //             style: const TextStyle(
      //               fontSize: 24,
      //               fontWeight: FontWeight.bold,
      //             ),
      //           ),

      //           const SizedBox(height: 20),

      //           Card(
      //             elevation: 2,
      //             child: Padding(
      //               padding: const EdgeInsets.all(16),
      //               child: ListView.separated(
      //                 shrinkWrap: true,
      //                 physics: const NeverScrollableScrollPhysics(),
      //                 itemCount: items.length,
      //                 separatorBuilder: (_, __) => const Divider(),
      //                 itemBuilder: (context, index) {
      //                   final item = items[index];

      //                   return Row(
      //                     crossAxisAlignment: CrossAxisAlignment.start,
      //                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
      //                     children: [
      //                       Text(
      //                         item.key,
      //                         style: const TextStyle(
      //                           fontWeight: FontWeight.w600,
      //                         ),
      //                       ),

      //                       const SizedBox(width: 12),

      //                       Expanded(
      //                         child: Text(
      //                           item.value,
      //                           textAlign: TextAlign.right,
      //                         ),
      //                       ),
      //                     ],
      //                   );
      //                 },
      //               ),
      //             ),
      //           ),
      //         ],
      //       ),
      //     );
      //   },
      // ),
    );
  }
}
