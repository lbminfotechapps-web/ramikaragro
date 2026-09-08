import 'package:flutter/material.dart';

class NotificationShimmer extends StatelessWidget {
const NotificationShimmer({
super.key,
});

@override
Widget build(BuildContext context) {
return ListView.builder(
padding: const EdgeInsets.fromLTRB(
14,
18,
14,
20,
),
itemCount: 5,
itemBuilder: (_, index) {
return Container(
margin: const EdgeInsets.only(
bottom: 14,
),
padding: const EdgeInsets.all(16),
decoration: BoxDecoration(
color: Colors.white,
borderRadius:
BorderRadius.circular(20),
),
child: Column(
crossAxisAlignment:
CrossAxisAlignment.start,
children: [
Row(
children: [
Container(
width: 48,
height: 48,
decoration: BoxDecoration(
color: Colors.grey.shade200,
borderRadius:
BorderRadius.circular(15),
),
),

              const SizedBox(width: 13),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 170,
                      height: 13,
                      decoration:
                          BoxDecoration(
                        color:
                            Colors.grey.shade200,
                        borderRadius:
                            BorderRadius.circular(
                          6,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: 70,
                      height: 9,
                      decoration:
                          BoxDecoration(
                        color:
                            Colors.grey.shade200,
                        borderRadius:
                            BorderRadius.circular(
                          5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 15),

          Container(
            width: double.infinity,
            height: 55,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius:
                  BorderRadius.circular(14),
            ),
          ),

          const SizedBox(height: 14),

          Row(
            children: [
              Container(
                width: 90,
                height: 10,
                decoration:
                    BoxDecoration(
                  color:
                      Colors.grey.shade200,
                  borderRadius:
                      BorderRadius.circular(5),
                ),
              ),
              const SizedBox(width: 18),
              Container(
                width: 70,
                height: 10,
                decoration:
                    BoxDecoration(
                  color:
                      Colors.grey.shade200,
                  borderRadius:
                      BorderRadius.circular(5),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  },
);

}
}
