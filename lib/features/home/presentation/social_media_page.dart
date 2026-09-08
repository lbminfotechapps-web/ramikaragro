import 'package:demo/core/router/app_router.dart';
import 'package:demo/core/theme/app_colors.dart';
import 'package:demo/features/home/presentation/home_bloc/social_media_bloc.dart';
import 'package:demo/features/home/presentation/home_bloc/social_media_event.dart';
import 'package:demo/features/home/presentation/home_bloc/social_media_state.dart';
import 'package:demo/features/home/presentation/widgets/social_media_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/di/social_media_di.dart';
import '../../../../core/secure_storage/secure_storage.dart';


class SocialMediaPage extends StatefulWidget {
  const SocialMediaPage({
    super.key,
  });

  @override
  State<SocialMediaPage> createState() =>
      _SocialMediaPageState();
}

class _SocialMediaPageState
    extends State<SocialMediaPage> {

  late final SocialMediaBloc bloc;

  @override
  void initState() {
    super.initState();

    bloc = sl<SocialMediaBloc>();

    _loadSocialMedia();
  }

  Future<void> _loadSocialMedia() async {
    final userData =
        await SecureStorage.instance.getUserData();

    final userId =
        userData?['user_id']?.toString() ?? '';

    debugPrint(
      'SOCIAL MEDIA USER ID = $userId',
    );

    if (!mounted) return;

    bloc.add(
      GetSocialMediaEvent(
        userId: userId,
      ),
    );
  }

  @override
  void dispose() {
    bloc.close();
    super.dispose();
  }

  Future<void> _openSocialLink(
    String link,
  ) async {
    final cleanLink = link.trim();

    if (cleanLink.isEmpty) {
      _showMessage(
        'Social media link is not available',
      );
      return;
    }

    try {
      final uri = Uri.parse(cleanLink);

      if (!uri.hasScheme) {
        _showMessage(
          'Invalid social media URL',
        );
        return;
      }

      final opened = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );

      if (!opened) {
        _showMessage(
          'Unable to open this link',
        );
      }
    } catch (e) {
      debugPrint(
        'OPEN SOCIAL LINK ERROR = $e',
      );

      _showMessage(
        'Unable to open link',
      );
    }
  }

  void _showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: bloc,
      child: BlocConsumer<
          SocialMediaBloc,
          SocialMediaState>(
        listener: (context, state) {
          if (state.status ==
              SocialMediaStatus.failure) {
            _showMessage(
              state.errorMessage ??
                  'Something went wrong',
            );
          }
        },
        builder: (context, state) {
          return Scaffold(
            backgroundColor:
                const Color(0xfff5f7f9),

            appBar: AppBar(

            leading: IconButton(
              icon: const Icon(
                Icons.arrow_back_ios_new,
                size: 19,
                color: AppColors.backgroundColor,
              ),
              onPressed: () {
                context.go(AppRouter.home);
              },
            ),

              title: const Text(
                'Social Media',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              elevation: 0,
            ),

            body: RefreshIndicator(
              color: Colors.green,

              onRefresh: () async {
                await _loadSocialMedia();
              },

              child: _buildBody(state),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBody(
    SocialMediaState state,
  ) {
    if (state.status ==
        SocialMediaStatus.loading) {
      return const Center(
        child: CircularProgressIndicator(
          color: Colors.green,
        ),
      );
    }

    if (state.status ==
        SocialMediaStatus.failure) {
      return _buildError(
        state.errorMessage,
      );
    }

    if (state.socialMedia.isEmpty) {
      return ListView(
        physics:
            const AlwaysScrollableScrollPhysics(),
        children: const [
          SizedBox(height: 250),
          Center(
            child: Text(
              'Social media links not available',
              style: TextStyle(
                color: Colors.grey,
                fontSize: 15,
              ),
            ),
          ),
        ],
      );
    }

    return ListView(
      physics:
          const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      children: [
        _buildHeader(),

        const SizedBox(height: 20),

        ...state.socialMedia.map(
          (social) => SocialMediaCard(
            title: social.type,
            subtitle: _getSubtitle(
              social.type,
            ),
            link: social.link,
            icon: _getIcon(
              social.type,
            ),
            iconColor: _getIconColor(
              social.type,
            ),
            onTap: () {
              _openSocialLink(
                social.link,
              );
            },
          ),
        ),

        const SizedBox(height: 15),
      ],
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.green.shade700,
            Colors.green.shade500,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withOpacity(0.20),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: const Column(
        children: [
          Icon(
            Icons.share,
            color: Colors.white,
            size: 45,
          ),

          SizedBox(height: 10),

          Text(
            'Connect With Us',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),

          SizedBox(height: 5),

          Text(
            'Follow Ramikar Agro Industries',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildError(
    String? error,
  ) {
    return ListView(
      physics:
          const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(20),
      children: [
        const SizedBox(height: 120),

        const Icon(
          Icons.error_outline,
          size: 55,
          color: Colors.red,
        ),

        const SizedBox(height: 15),

        const Center(
          child: Text(
            'Unable to load social media',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),

        const SizedBox(height: 8),

        Center(
          child: Text(
            error ?? 'Something went wrong',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.grey,
            ),
          ),
        ),

        const SizedBox(height: 20),

        Center(
          child: ElevatedButton.icon(
            onPressed: _loadSocialMedia,
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  String _getSubtitle(String type) {
    switch (type.toLowerCase()) {
      case 'facebook':
        return 'Follow us on Facebook';

      case 'instagram':
        return 'Follow us on Instagram';

      case 'twitter':
      case 'x':
        return 'Follow us on Twitter / X';

      case 'youtube':
        return 'Subscribe to our YouTube channel';

      case 'linkedin':
        return 'Connect with us on LinkedIn';

      case 'telegram':
        return 'Join us on Telegram';

      case 'whatsapp':
        return 'Chat with us on WhatsApp';

      case 'snapchat':
        return 'Follow us on Snapchat';

      default:
        return 'Connect with us';
    }
  }

  IconData _getIcon(String type) {
    switch (type.toLowerCase()) {
      case 'facebook':
        return Icons.facebook;

      case 'instagram':
        return Icons.camera_alt;

      case 'twitter':
      case 'x':
        return Icons.alternate_email;

      case 'youtube':
        return Icons.play_circle_fill;

      case 'linkedin':
        return Icons.business;

      case 'telegram':
        return Icons.send;

      case 'whatsapp':
        return Icons.chat;

      case 'snapchat':
        return Icons.camera;

      default:
        return Icons.public;
    }
  }

  Color _getIconColor(String type) {
    switch (type.toLowerCase()) {
      case 'facebook':
        return const Color(0xff1877F2);

      case 'instagram':
        return const Color(0xffE4405F);

      case 'twitter':
      case 'x':
        return Colors.black;

      case 'youtube':
        return const Color(0xffFF0000);

      case 'linkedin':
        return const Color(0xff0A66C2);

      case 'telegram':
        return const Color(0xff229ED9);

      case 'whatsapp':
        return const Color(0xff25D366);

      case 'snapchat':
        return Colors.yellow.shade700;

      default:
        return Colors.green;
    }
  }
}