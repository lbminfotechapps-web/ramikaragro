import 'package:flutter/material.dart';


class Dealerlistscreen extends StatefulWidget {
  const Dealerlistscreen({super.key});

  @override
  State<Dealerlistscreen> createState() => _DealerScreenState();
}

class _DealerScreenState extends State<Dealerlistscreen> {
  // Dealer data
  final List<Map<String, String>> dealers = [
    {
      'name': 'ABC Agro Agency',
      'phone': '9876543210',
      'location': 'Pune',
    },
    {
      'name': 'Shree Ganesh Traders',
      'phone': '9876543211',
      'location': 'Mumbai',
    },
    {
      'name': 'Kisan Krushi Seva',
      'phone': '9876543212',
      'location': 'Nashik',
    },
    {
      'name': 'Green Field Agro',
      'phone': '9876543213',
      'location': 'Kolhapur',
    },
    {
      'name': 'Sai Agro Center',
      'phone': '9876543214',
      'location': 'Satara',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF5F7FA),

      appBar: AppBar(
        title: const Text(
          'Dealer List',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),

      body: ListView.builder(
        padding: const EdgeInsets.all(12),

        itemCount: dealers.length,

        itemBuilder: (context, index) {
          final dealer = dealers[index];

          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),

            child: Padding(
              padding: const EdgeInsets.all(16),

              child: Row(
                children: [

                  // Dealer icon
                  CircleAvatar(
                    radius: 25,
                    backgroundColor: Colors.green.shade100,
                    child: const Icon(
                      Icons.store,
                      color: Colors.green,
                    ),
                  ),

                  const SizedBox(width: 14),

                  // Dealer information
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [

                        Text(
                          dealer['name']!,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 6),

                        Row(
                          children: [
                            const Icon(
                              Icons.phone,
                              size: 16,
                              color: Colors.grey,
                            ),

                            const SizedBox(width: 5),

                            Text(
                              dealer['phone']!,
                              style: const TextStyle(
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 4),

                        Row(
                          children: [
                            const Icon(
                              Icons.location_on,
                              size: 16,
                              color: Colors.grey,
                            ),

                            const SizedBox(width: 5),

                            Text(
                              dealer['location']!,
                              style: const TextStyle(
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // More button
                  IconButton(
                    onPressed: () {
                      print('Clicked dealer $index');
                    },
                    icon: const Icon(
                      Icons.arrow_forward_ios,
                      size: 18,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}