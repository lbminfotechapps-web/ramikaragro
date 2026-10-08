import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:share_plus/share_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:solufine/core/api_constant/api_client.dart';
import 'package:solufine/core/router/app_router.dart';
import 'package:solufine/core/theme/app_colors.dart';
import 'package:solufine/core/utility/widgets/custom_appbar.dart';
import 'package:solufine/features/quickchartreport/presentation/bloc/gallerybloc.dart';
import 'package:solufine/features/quickchartreport/presentation/bloc/galleryevent.dart';
import 'package:solufine/features/quickchartreport/presentation/bloc/gallerystate.dart';

class QuickReferencePage extends StatefulWidget {
  const QuickReferencePage({super.key});

  @override
  State<QuickReferencePage> createState() => _QuickReferencePageState();
}

class _QuickReferencePageState extends State<QuickReferencePage> {
  static const String baseFileUrl = ApiClient.imageGalleryUrl;

  @override
  void initState() {
    super.initState();

    context.read<GalleryBloc>().add(const GetGalleryEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: CustomAppBar(
        title: 'Quick Reference Chart Report',

        showBackButton: true,

        onBackTap: () {
          context.go(AppRouter.home);
        },
      ),
      // appBar: AppBar(
      //   elevation: 0,
      //   backgroundColor: Colors.white,
      //   surfaceTintColor: Colors.white,
      //   title: const Text(
      //     'Quick Reference',
      //     style: TextStyle(
      //       fontSize: 20,
      //       fontWeight: FontWeight.w700,
      //       color: Color(0xFF1F2937),
      //     ),
      //   ),
      // ),
      body: BlocBuilder<GalleryBloc, GalleryState>(
        builder: (context, state) {
          if (state.status == GalleryStatus.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.status == GalleryStatus.failure) {
            return _buildError(state.message);
          }

          if (state.galleryList.isEmpty) {
            return _buildEmpty();
          }

          return RefreshIndicator(
            onRefresh: () async {
              context.read<GalleryBloc>().add(const GetGalleryEvent());
            },
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 30),
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: state.galleryList.length,
              separatorBuilder: (_, __) => const SizedBox(height: 14),
              itemBuilder: (context, index) {
                final gallery = state.galleryList[index];

                return _QuickReferenceCard(
                  title: gallery.title,
                  date: gallery.date,
                  files: gallery.data,
                  baseFileUrl: baseFileUrl,
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmpty() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.menu_book_outlined, size: 70, color: Colors.grey),
          SizedBox(height: 12),
          Text(
            'No quick reference found',
            style: TextStyle(fontSize: 15, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildError(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              size: 60,
              color: Colors.redAccent,
            ),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                context.read<GalleryBloc>().add(const GetGalleryEvent());
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickReferenceCard extends StatelessWidget {
  final String title;
  final String date;
  final List files;
  final String baseFileUrl;

  const _QuickReferenceCard({
    required this.title,
    required this.date,
    required this.files,
    required this.baseFileUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F5EE),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.menu_book_rounded,
                    color: Color(0xFF17864B),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          height: 1.3,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1F2937),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(
                            Icons.calendar_today_outlined,
                            size: 14,
                            color: Colors.grey,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            date,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 14),

            const Divider(height: 1, color: Color(0xFFEEEEEE)),

            const SizedBox(height: 14),

            Text(
              files.length > 1 ? 'Available References' : 'Available Reference',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF6B7280),
              ),
            ),

            const SizedBox(height: 10),

            SizedBox(
              height: 82,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: files.length,
                separatorBuilder: (_, _) => const SizedBox(width: 10),
                itemBuilder: (context, index) {
                  final file = files[index];
                  final fileUrl = '$baseFileUrl${file.file}';
                  return SizedBox(
                    width: 270,
                    child: _ReferenceFileTile(
                      language: file.language,
                      fileUrl: fileUrl,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReferenceFileTile extends StatelessWidget {
  final String language;
  final String fileUrl;

  const _ReferenceFileTile({required this.language, required this.fileUrl});

  bool get isPdf => fileUrl.toLowerCase().endsWith('.pdf');

  bool get isImage {
    final value = fileUrl.toLowerCase();

    return value.endsWith('.png') ||
        value.endsWith('.jpg') ||
        value.endsWith('.jpeg') ||
        value.endsWith('.webp');
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () {
        if (isImage) {
          final images = <String>[];
          final titles = <String>[];
          for (final gallery in context.read<GalleryBloc>().state.galleryList) {
            for (final file in gallery.data) {
              final url = '${ApiClient.imageGalleryUrl}${file.file}';
              if (_isImageUrl(url)) {
                images.add(url);
                titles.add('${gallery.title} (${file.language})');
              }
            }
          }
          final index = images.indexOf(fileUrl);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => QuickReferenceImagePage(
                imageUrl: fileUrl,
                title: language,
                imageUrls: images,
                titles: titles,
                initialIndex: index < 0 ? 0 : index,
              ),
            ),
          );
        }

        if (isPdf) {
          // Open PDF page here.
        }
      },
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Row(
          children: [
            _buildPreview(),

            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    language,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    isPdf
                        ? 'PDF Document'
                        : isImage
                        ? 'Image Reference'
                        : 'Reference File',
                    style: const TextStyle(fontSize: 11, color: Colors.grey),
                  ),
                ],
              ),
            ),

            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: const Color(0xFFE8F5EE),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.visibility_outlined,
                size: 19,
                color: Color(0xFF17864B),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreview() {
    if (isImage) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Image.network(
          fileUrl,
          width: 58,
          height: 58,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return _buildIconBox(Icons.broken_image_outlined);
          },
        ),
      );
    }

    if (isPdf) {
      return _buildIconBox(Icons.picture_as_pdf_outlined);
    }

    return _buildIconBox(Icons.insert_drive_file_outlined);
  }

  Widget _buildIconBox(IconData icon) {
    return Container(
      width: 58,
      height: 58,
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(icon, size: 28, color: Colors.grey.shade600),
    );
  }
}

bool _isImageUrl(String url) {
  final path = Uri.parse(url).path.toLowerCase();
  return ['.png', '.jpg', '.jpeg', '.webp'].any(path.endsWith);
}

class QuickReferenceImagePage extends StatefulWidget {
  final String imageUrl;
  final String title;
  final List<String> imageUrls;
  final List<String> titles;
  final int initialIndex;

  const QuickReferenceImagePage({
    super.key,
    required this.imageUrl,
    required this.title,
    this.imageUrls = const [],
    this.titles = const [],
    this.initialIndex = 0,
  });

  @override
  State<QuickReferenceImagePage> createState() =>
      _QuickReferenceImagePageState();
}

class _QuickReferenceImagePageState extends State<QuickReferenceImagePage> {
  late final List<String> _images;
  late final PageController _pageController;
  late int _index;
  bool _sharing = false;

  @override
  void initState() {
    super.initState();
    _images = widget.imageUrls.isEmpty ? [widget.imageUrl] : widget.imageUrls;
    _index = widget.initialIndex.clamp(0, _images.length - 1);
    _pageController = PageController(initialPage: _index);
  }

  String get _title =>
      _index < widget.titles.length ? widget.titles[_index] : widget.title;

  Future<void> _shareImage(BuildContext buttonContext) async {
    if (_sharing) return;
    final uri = Uri.parse(_images[_index]);
    final title = _title;
    final box = buttonContext.findRenderObject() as RenderBox?;
    final origin = box == null
        ? null
        : box.localToGlobal(Offset.zero) & box.size;
    setState(() => _sharing = true);
    try {
      final response = await http.get(uri).timeout(const Duration(seconds: 30));
      final mimeType = response.headers['content-type']
          ?.split(';')
          .first
          .trim();
      if (response.statusCode != 200 ||
          response.bodyBytes.isEmpty ||
          (mimeType != null && !mimeType.startsWith('image/'))) {
        throw Exception('Image download failed');
      }
      if (!mounted) return;
      await SharePlus.instance.share(
        ShareParams(
          text: title,
          files: [XFile.fromData(response.bodyBytes, mimeType: mimeType)],
          fileNameOverrides: [uri.pathSegments.last],
          sharePositionOrigin: origin,
        ),
      );
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Unable to share image. Please try again.'),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _sharing = false);
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(_title),
        actions: [
          Builder(
            builder: (buttonContext) => IconButton(
              tooltip: 'Share image',
              onPressed: _sharing ? null : () => _shareImage(buttonContext),
              icon: _sharing
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.share_outlined),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              itemCount: _images.length,
              onPageChanged: (index) => setState(() => _index = index),
              itemBuilder: (context, index) => InteractiveViewer(
                minScale: 1,
                maxScale: 5,
                child: Center(
                  child: Image.network(
                    _images[index],
                    fit: BoxFit.contain,
                    loadingBuilder: (context, child, progress) =>
                        progress == null
                        ? child
                        : const Center(
                            child: CircularProgressIndicator(
                              color: Colors.white,
                            ),
                          ),
                    errorBuilder: (context, error, stackTrace) => const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.broken_image_outlined,
                          size: 60,
                          color: Colors.white54,
                        ),
                        SizedBox(height: 10),
                        Text(
                          'Unable to load image',
                          style: TextStyle(color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          if (_images.length > 1)
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Text(
                  '${_index + 1} / ${_images.length} · Swipe to browse',
                  style: const TextStyle(color: Colors.white70),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
