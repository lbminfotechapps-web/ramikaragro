import 'package:flutter/material.dart';

import '../../domain/entities/notification.dart';

class NotificationCard extends StatelessWidget {
final NotificationEntity notification;

const NotificationCard({
super.key,
required this.notification,
});

static const Color primaryGreen =
Color(0xFF0F723A);

static const Color darkGreen =
Color(0xFF084D28);

@override
Widget build(BuildContext context) {
return Container(
margin: const EdgeInsets.only(
bottom: 13,
),
decoration: BoxDecoration(
color: Colors.white,
borderRadius: BorderRadius.circular(20),
boxShadow: [
BoxShadow(
color: Colors.black.withOpacity(0.055),
blurRadius: 18,
offset: const Offset(0, 6),
),
],
),
child: Padding(
padding: const EdgeInsets.all(16),
child: Column(
crossAxisAlignment:
CrossAxisAlignment.start,
children: [
Row(
crossAxisAlignment:
CrossAxisAlignment.start,
children: [
_buildNotificationIcon(),


            const SizedBox(width: 13),

            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    notification.title,
                    maxLines: 2,
                    overflow:
                        TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 15.5,
                      fontWeight:
                          FontWeight.w700,
                      color: Color(0xFF1D241F),
                    ),
                  ),

                  const SizedBox(height: 5),

                  Text(
                    '#${notification.notificationId}',
                    style: TextStyle(
                      fontSize: 10.5,
                      fontWeight:
                          FontWeight.w500,
                      color: primaryGreen
                          .withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 8),

            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: primaryGreen
                    .withOpacity(0.07),
                borderRadius:
                    BorderRadius.circular(11),
              ),
              child: const Icon(
                Icons.chevron_right_rounded,
                size: 21,
                color: primaryGreen,
              ),
            ),
          ],
        ),

        const SizedBox(height: 14),

        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(13),
          decoration: BoxDecoration(
            color: const Color(0xFFF7FAF8),
            borderRadius:
                BorderRadius.circular(14),
          ),
          child: Text(
            notification.message,
            style: const TextStyle(
              fontSize: 13.5,
              height: 1.55,
              color: Color(0xFF555D58),
            ),
          ),
        ),

        const SizedBox(height: 14),

        Row(
          children: [
            _buildInfoItem(
              icon: Icons.calendar_today_rounded,
              value:
                  notification.notificationDate,
            ),

            const SizedBox(width: 18),

            _buildInfoItem(
              icon: Icons.access_time_rounded,
              value:
                  notification.notificationTime,
            ),
          ],
        ),
      ],
    ),
  ),
);

}

Widget _buildNotificationIcon() {
return Container(
width: 48,
height: 48,
decoration: BoxDecoration(
gradient: const LinearGradient(
colors: [
primaryGreen,
darkGreen,
],
begin: Alignment.topLeft,
end: Alignment.bottomRight,
),
borderRadius: BorderRadius.circular(15),
),
child: const Icon(
Icons.notifications_active_rounded,
color: Colors.white,
size: 23,
),
);
}

Widget _buildInfoItem({
required IconData icon,
required String value,
}) {
return Flexible(
child: Row(
mainAxisSize: MainAxisSize.min,
children: [
Icon(
icon,
size: 14,
color: primaryGreen,
),


      const SizedBox(width: 6),

      Flexible(
        child: Text(
          value,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 11.5,
            fontWeight: FontWeight.w500,
            color: Color(0xFF737A76),
          ),
        ),
      ),
    ],
  ),
);

}
}
