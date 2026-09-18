import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class LocationPermissionDialog extends StatelessWidget {
  const LocationPermissionDialog({super.key, required this.onPermissionResult});

  final VoidCallback onPermissionResult;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Location icon
              SizedBox(
                height: 70,
                width: double.infinity,
                child: Image.asset(
                  'assets/icons/logo.jpg',
                  fit: BoxFit.contain,
                ),
              ),

              const SizedBox(height: 12),

              const Text(
                'Location Permission',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),

              const SizedBox(height: 12),

              const Text(
                'This app needs your location to provide '
                'location-based services and record your activities.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 17,
                  height: 1.4,
                  color: Colors.black87,
                ),
              ),

              const SizedBox(height: 20),

              SizedBox(
                height: 180,
                width: double.infinity,
                child: Image.asset(
                  'assets/images/map.png',
                  fit: BoxFit.contain,
                ),
              ),

              const SizedBox(height: 15),

              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text(
                        'No Thanks',
                        style: TextStyle(
                          fontSize: 18,
                          color: Color(0xFF388E3C),
                        ),
                      ),
                    ),
                  ),

                  Expanded(
                    child: TextButton(
                      onPressed: () async {
                        final status = await Permission.location.request();

                        if (context.mounted) {
                          Navigator.pop(context);
                          onPermissionResult();
                        }
                      },
                      child: const Text(
                        'Use Location',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF388E3C),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
