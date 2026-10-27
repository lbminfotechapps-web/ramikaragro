import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';

/// Shows only successfully decoded images. Both photos share one row;
/// when just one is valid it expands to full width.
class TaskImageRow extends StatefulWidget {
  const TaskImageRow({
    super.key,
    this.taskImageUrl,
    this.taskLocalPath,
    this.completedImageUrl,
  });

  final String? taskImageUrl;
  final String? taskLocalPath;
  final String? completedImageUrl;

  @override
  State<TaskImageRow> createState() => _TaskImageRowState();
}

class _TaskImageRowState extends State<TaskImageRow> {
  Future<List<_ValidTaskPhoto>>? _photos;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _photos ??= _loadPhotos();
  }

  @override
  void didUpdateWidget(covariant TaskImageRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.taskImageUrl != widget.taskImageUrl ||
        oldWidget.taskLocalPath != widget.taskLocalPath ||
        oldWidget.completedImageUrl != widget.completedImageUrl) {
      _photos = _loadPhotos();
    }
  }

  ImageProvider? _providerFor(String? url, [String? path]) {
    final remote = url?.trim() ?? '';
    final uri = Uri.tryParse(remote);
    if (uri != null && uri.hasAuthority &&
        (uri.scheme == 'https' || uri.scheme == 'http')) {
      return NetworkImage(remote);
    }
    final local = path?.trim() ?? '';
    if (local.isNotEmpty) return FileImage(File(local));
    return null;
  }

  Future<bool> _canDecode(ImageProvider provider) async {
    if (provider is FileImage && !await provider.file.exists()) return false;
    if (!mounted) return false;

    // Explicit stream success/error detection. Unlike precacheImage with
    // onError, this cannot accidentally treat a broken image as valid.
    final completer = Completer<bool>();
    final stream = provider.resolve(createLocalImageConfiguration(context));
    late ImageStreamListener listener;
    listener = ImageStreamListener(
      (_, __) {
        if (!completer.isCompleted) completer.complete(true);
      },
      onError: (_, __) {
        if (!completer.isCompleted) completer.complete(false);
      },
    );
    stream.addListener(listener);
    try {
      return await completer.future;
    } finally {
      stream.removeListener(listener);
    }
  }

  Future<List<_ValidTaskPhoto>> _loadPhotos() async {
    final candidates = <_ValidTaskPhoto>[];
    final assigned = _providerFor(widget.taskImageUrl, widget.taskLocalPath);
    final completed = _providerFor(widget.completedImageUrl);
    if (assigned != null) {
      candidates.add(_ValidTaskPhoto('Task Image', assigned, false));
    }
    if (completed != null) {
      candidates.add(_ValidTaskPhoto('Completed Image', completed, true));
    }
    final results = await Future.wait(candidates.map((photo) async {
      try {
        return await _canDecode(photo.provider) ? photo : null;
      } catch (_) {
        return null;
      }
    }));
    return results.whereType<_ValidTaskPhoto>().toList();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<_ValidTaskPhoto>>(
      future: _photos,
      builder: (context, snapshot) {
        final images = snapshot.data ?? const <_ValidTaskPhoto>[];
        if (images.isEmpty) return const SizedBox.shrink();
        return Padding(
          padding: const EdgeInsets.only(top: 10),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final sideBySide = images.length == 2;
              final width = sideBySide
                  ? (constraints.maxWidth - 8) / 2
                  : constraints.maxWidth;
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (var index = 0; index < images.length; index++) ...[
                    if (index != 0) const SizedBox(width: 8),
                    SizedBox(
                      width: width,
                      child: _PhotoTile(photo: images[index]),
                    ),
                  ],
                ],
              );
            },
          ),
        );
      },
    );
  }
}

class _ValidTaskPhoto {
  const _ValidTaskPhoto(this.label, this.provider, this.completed);
  final String label;
  final ImageProvider provider;
  final bool completed;
}

class _PhotoTile extends StatelessWidget {
  const _PhotoTile({required this.photo});
  final _ValidTaskPhoto photo;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Material(
      clipBehavior: Clip.antiAlias,
      color: colors.surfaceContainerLow,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => _ZoomImagePage(photo: photo),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              height: 118,
              child: Image(
                image: photo.provider,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const SizedBox.shrink(),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 9),
              child: Row(
                children: [
                  Icon(
                    photo.completed ? Icons.check_circle_outline : Icons.image_outlined,
                    size: 15,
                    color: colors.primary,
                  ),
                  const SizedBox(width: 5),
                  Expanded(
                    child: Text(
                      photo.label,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: colors.onSurface,
                      ),
                    ),
                  ),
                  Icon(Icons.zoom_in, size: 17, color: colors.primary),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ZoomImagePage extends StatefulWidget {
  const _ZoomImagePage({required this.photo});
  final _ValidTaskPhoto photo;

  @override
  State<_ZoomImagePage> createState() => _ZoomImagePageState();
}

class _ZoomImagePageState extends State<_ZoomImagePage> {
  final TransformationController _controller = TransformationController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _zoom(double multiplier) {
    final current = _controller.value.getMaxScaleOnAxis();
    final scale = (current * multiplier).clamp(1.0, 5.0).toDouble();
    _controller.value = Matrix4.diagonal3Values(scale, scale, 1);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(widget.photo.label),
      ),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: InteractiveViewer(
                transformationController: _controller,
                minScale: 1,
                maxScale: 5,
                child: Image(
                  image: widget.photo.provider,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => const Text(
                    'Image unavailable',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ),
          ),
          SafeArea(
            top: false,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: () => _zoom(0.8),
                  icon: const Icon(Icons.zoom_out, color: Colors.white),
                ),
                IconButton(
                  onPressed: () => _controller.value = Matrix4.identity(),
                  icon: const Icon(Icons.center_focus_strong, color: Colors.white),
                ),
                IconButton(
                  onPressed: () => _zoom(1.25),
                  icon: const Icon(Icons.zoom_in, color: Colors.white),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
