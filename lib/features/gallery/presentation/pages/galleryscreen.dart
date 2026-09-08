import 'package:demo/core/api_constant/api_client.dart';
import 'package:demo/core/utility/fullimage.dart';
import 'package:demo/features/gallery/presentation/boc/gallery_bloc.dart';
import 'package:demo/features/gallery/presentation/boc/gallery_event.dart';
import 'package:demo/features/gallery/presentation/boc/gallery_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../domain/entities/gallery_entity.dart';

class GalleryScreen extends StatefulWidget {
  const GalleryScreen({super.key});

  @override
  State<GalleryScreen> createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();

    _tabController = TabController(length: 3, vsync: this);

    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        return;
      }

      _loadCurrentTab();
    });

    // First tab = Images
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<GalleryBloc>().add(const GetGalleryEvent(type: 'gallery'));
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  String _currentType() {
    switch (_tabController.index) {
      case 0:
        return 'gallery';

      case 1:
        return 'video';

      case 2:
        return 'CERTIFICATES';

      default:
        return 'gallery';
    }
  }

  void _loadCurrentTab() {
    context.read<GalleryBloc>().add(GetGalleryEvent(type: _currentType()));
  }

  void _refreshCurrentTab() {
    context.read<GalleryBloc>().add(RefreshGalleryEvent(type: _currentType()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        centerTitle: true,

        title: const Text(
          'Gallery',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),

        iconTheme: const IconThemeData(color: Colors.black),
      ),

      body: Column(
        children: [
          _buildTabBar(),

          const SizedBox(height: 8),

          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildGalleryTab('gallery'),
                _buildGalleryTab('video'),
                _buildGalleryTab('CERTIFICATES'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // TAB BAR
  // ---------------------------------------------------------------------------

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),

      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),

      child: TabBar(
        controller: _tabController,

        indicator: BoxDecoration(
          color: const Color(0xFF218838),
          borderRadius: BorderRadius.circular(10),
        ),

        indicatorSize: TabBarIndicatorSize.tab,

        dividerColor: Colors.transparent,

        labelColor: Colors.white,

        unselectedLabelColor: Colors.black87,

        labelStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),

        unselectedLabelStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),

        tabs: const [
          Tab(text: 'Images'),
          Tab(text: 'Videos'),
          Tab(text: 'Certificates'),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // TAB CONTENT
  // ---------------------------------------------------------------------------

  Widget _buildGalleryTab(String type) {
    return BlocBuilder<GalleryBloc, GalleryState>(
      builder: (context, state) {
        List<GalleryEntity> list;

        if (type == 'gallery') {
          list = state.galleryList;
        } else if (type == 'video') {
          list = state.videoList;
        } else {
          list = state.certificateList;
        }

        final bool isCurrentTab = state.currentType == type;

        // Loading
        if (isCurrentTab && state.status == GalleryStatus.loading) {
          return _buildLoading();
        }

        // Error
        if (isCurrentTab && state.status == GalleryStatus.failure) {
          return _buildError(
            type,
            state.errorMessage ?? 'Something went wrong',
          );
        }

        // Empty
        if (list.isEmpty) {
          return _buildEmptyState(type);
        }

        // Data
        return RefreshIndicator(
          color: const Color(0xFF218838),

          onRefresh: () async {
            context.read<GalleryBloc>().add(RefreshGalleryEvent(type: type));
          },

          child: GridView.builder(
            padding: const EdgeInsets.fromLTRB(18, 4, 18, 25),

            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),

            itemCount: list.length,

            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 13,
              mainAxisSpacing: 14,
              childAspectRatio: 0.78,
            ),

            itemBuilder: (context, index) {
              final item = list[index];

              return _buildGalleryCard(item: item, type: type);
            },
          ),
        );
      },
    );
  }

  // ---------------------------------------------------------------------------
  // GALLERY CARD
  // ---------------------------------------------------------------------------

  Widget _buildGalleryCard({
    required GalleryEntity item,
    required String type,
  }) {
    final String imageUrl = _getImagePath(item.galleryPath);

    final bool pdf = _isPdf(item.galleryPath);

    final bool youtube = _extractYoutubeId(item.galleryPath) != null;

    return GestureDetector(
      onTap: () {
        _openGalleryItem(item);
      },

      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,

          borderRadius: BorderRadius.circular(14),

          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            // ---------------------------------------------------------------
            // IMAGE
            // ---------------------------------------------------------------
            Expanded(
              flex: 7,

              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(14),
                    ),

                    child: SizedBox(
                      width: double.infinity,
                      height: double.infinity,

                      child: pdf
                          ? _buildPdfPreview()
                          : Image.network(
                              imageUrl,

                              fit: BoxFit.cover,

                              loadingBuilder: _imageLoading,

                              errorBuilder: _imageError,
                            ),
                    ),
                  ),

                  // ---------------------------------------------------------
                  // VIDEO PLAY BUTTON
                  // ---------------------------------------------------------
                  if (youtube)
                    Center(
                      child: Container(
                        width: 48,
                        height: 48,

                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.65),
                          shape: BoxShape.circle,
                        ),

                        child: const Icon(
                          Icons.play_arrow,
                          color: Colors.white,
                          size: 30,
                        ),
                      ),
                    ),

                  // ---------------------------------------------------------
                  // CERTIFICATE BADGE
                  // ---------------------------------------------------------
                  if (type == 'certificate')
                    Positioned(
                      top: 10,
                      left: 10,

                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 5,
                        ),

                        decoration: BoxDecoration(
                          color: const Color(0xFF218838),
                          borderRadius: BorderRadius.circular(6),
                        ),

                        child: const Text(
                          'Certificate',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // ---------------------------------------------------------------
            // TITLE
            // ---------------------------------------------------------------
            Expanded(
              flex: 3,

              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 9, 8, 8),

                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    Expanded(
                      child: Text(
                        item.galleryTitle.isNotEmpty
                            ? item.galleryTitle
                            : 'Gallery',

                        maxLines: 2,

                        overflow: TextOverflow.ellipsis,

                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                    ),

                    const SizedBox(width: 4),

                    const Icon(
                      Icons.arrow_forward_ios,
                      size: 13,
                      color: Color(0xFF218838),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // OPEN ITEM
  // ---------------------------------------------------------------------------

  Future<void> _openGalleryItem(GalleryEntity item) async {
    final String path = item.galleryPath.trim();

    if (path.isEmpty) {
      return;
    }

    // YouTube
    final String? youtubeId = _extractYoutubeId(path);

    if (youtubeId != null) {
      final Uri uri = Uri.parse(path);

      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }

      return;
    }

    // PDF
    if (_isPdf(path)) {
      await _openPdf(path);
      return;
    }

    // Image
    final String fullPath = _getImagePath(path);

    if (!mounted) {
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => FullImageScreen(imageUrl: fullPath)),
    );
  }

  // ---------------------------------------------------------------------------
  // IMAGE PATH
  // ---------------------------------------------------------------------------

  String _getImagePath(String path) {
    final String value = path.trim();

    // YouTube thumbnail
    final String? youtubeId = _extractYoutubeId(value);

    if (youtubeId != null) {
      return 'https://img.youtube.com/vi/$youtubeId/0.jpg';
    }

    // Already complete URL
    if (value.startsWith('http://') || value.startsWith('https://')) {
      return value;
    }
    print("Path is. :" + '${ApiClient.imageBaseUrl}$value');
    // Your existing gallery API path
    return '${ApiClient.imageGalleryUrl}$value';
  }

  // ---------------------------------------------------------------------------
  // YOUTUBE ID
  // ---------------------------------------------------------------------------

  String? _extractYoutubeId(String url) {
    try {
      final Uri uri = Uri.parse(url);

      // youtube.com/watch?v=xxxx
      if (uri.host.contains('youtube.com')) {
        return uri.queryParameters['v'];
      }

      // youtu.be/xxxx
      if (uri.host.contains('youtu.be')) {
        if (uri.pathSegments.isNotEmpty) {
          return uri.pathSegments.first;
        }
      }

      return null;
    } catch (_) {
      return null;
    }
  }

  // ---------------------------------------------------------------------------
  // PDF
  // ---------------------------------------------------------------------------

  bool _isPdf(String path) {
    return path.toLowerCase().endsWith('.pdf');
  }

  Future<void> _openPdf(String path) async {
    final Uri uri = Uri.parse(
      path.startsWith('http') ? path : _getImagePath(path),
    );

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  // ---------------------------------------------------------------------------
  // PDF PREVIEW
  // ---------------------------------------------------------------------------

  Widget _buildPdfPreview() {
    return Container(
      width: double.infinity,
      height: double.infinity,

      color: Colors.grey.shade100,

      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,

          children: [
            Icon(Icons.picture_as_pdf, size: 55, color: Colors.red),

            SizedBox(height: 8),

            Text(
              'PDF',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.black54,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // IMAGE LOADING
  // ---------------------------------------------------------------------------

  Widget _imageLoading(
    BuildContext context,
    Widget child,
    ImageChunkEvent? loadingProgress,
  ) {
    if (loadingProgress == null) {
      return child;
    }

    return _imageLoadingWidget();
  }

  Widget _imageLoadingWidget() {
    return Container(
      color: Colors.grey.shade100,

      child: const Center(
        child: SizedBox(
          width: 25,
          height: 25,

          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: Color(0xFF218838),
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // IMAGE ERROR
  // ---------------------------------------------------------------------------

  Widget _imageError(
    BuildContext context,
    Object error,
    StackTrace? stackTrace,
  ) {
    return Container(
      color: Colors.grey.shade100,

      child: const Center(
        child: Icon(
          Icons.image_not_supported_outlined,
          size: 40,
          color: Colors.grey,
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // LOADING
  // ---------------------------------------------------------------------------

  Widget _buildLoading() {
    return const Center(
      child: CircularProgressIndicator(color: Color(0xFF218838)),
    );
  }

  // ---------------------------------------------------------------------------
  // ERROR
  // ---------------------------------------------------------------------------

  Widget _buildError(String type, String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(25),

        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,

          children: [
            const Icon(Icons.error_outline, size: 55, color: Colors.redAccent),

            const SizedBox(height: 15),

            Text(
              message,
              textAlign: TextAlign.center,

              style: const TextStyle(fontSize: 14, color: Colors.black54),
            ),

            const SizedBox(height: 18),

            ElevatedButton.icon(
              onPressed: () {
                context.read<GalleryBloc>().add(GetGalleryEvent(type: type));
              },

              icon: const Icon(Icons.refresh),

              label: const Text('Retry'),

              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF218838),
                foregroundColor: Colors.white,

                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // EMPTY
  // ---------------------------------------------------------------------------

  Widget _buildEmptyState(String type) {
    String title;

    if (type == 'gallery') {
      title = 'No images available';
    } else if (type == 'video') {
      title = 'No videos available';
    } else {
      title = 'No certificates available';
    }

    return RefreshIndicator(
      color: const Color(0xFF218838),

      onRefresh: () async {
        context.read<GalleryBloc>().add(RefreshGalleryEvent(type: type));
      },

      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),

        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.55,

            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,

                children: [
                  Icon(
                    type == 'video'
                        ? Icons.video_library_outlined
                        : type == 'certificate'
                        ? Icons.workspace_premium_outlined
                        : Icons.photo_library_outlined,

                    size: 65,

                    color: Colors.grey.shade400,
                  ),

                  const SizedBox(height: 15),

                  Text(
                    title,

                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),

                  const SizedBox(height: 15),

                  OutlinedButton.icon(
                    onPressed: () {
                      context.read<GalleryBloc>().add(
                        GetGalleryEvent(type: type),
                      );
                    },

                    icon: const Icon(Icons.refresh),

                    label: const Text('Refresh'),

                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF218838),

                      side: const BorderSide(color: Color(0xFF218838)),

                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
