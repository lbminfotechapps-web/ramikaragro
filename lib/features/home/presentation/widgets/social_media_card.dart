import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

class SocialMediaCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String link;
  final IconData icon;
  final Color iconColor;
  final VoidCallback onTap;

  const SocialMediaCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.link,
    required this.icon,
    required this.iconColor,
    required this.onTap,
  });

  Future<void> _share(BuildContext context) async {
    final box = context.findRenderObject() as RenderBox?;
    final origin = box != null && box.hasSize
        ? box.localToGlobal(Offset.zero) & box.size
        : null;

    try {
      await SharePlus.instance.share(
        ShareParams(
          subject: 'Connect with Solufine on $title',
          text:
              'Grow together with Solufine! 🌱\n\n'
              'Connect with us on $title for farming updates, inspiration, '
              'and the latest from Solufine:\n${link.trim()}\n\n'
              'Explore more with the Solufine app. Download it on Google Play:\n'
              'https://play.google.com/store/apps/details?id=com.lbm.solufine',
          sharePositionOrigin: origin,
        ),
      );
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to share. Please try again.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                height: 50,
                width: 50,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: iconColor, size: 28),
              ),

              const SizedBox(width: 14),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      subtitle,
                      style: const TextStyle(fontSize: 13, color: Colors.grey),
                    ),
                  ],
                ),
              ),

              Builder(
                builder: (shareContext) => IconButton(
                  tooltip: 'Share $title',
                  onPressed: () => _share(shareContext),
                  style: IconButton.styleFrom(
                    foregroundColor: iconColor,
                    backgroundColor: iconColor.withValues(alpha: 0.08),
                  ),
                  icon: const Icon(Icons.share_outlined, size: 20),
                ),
              ),
              const SizedBox(width: 8),
            ],
          ),
        ),
      ),
    );
  }
}
