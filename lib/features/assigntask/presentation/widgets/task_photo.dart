
import 'dart:io';

import 'package:flutter/material.dart';

class TaskPhoto extends StatefulWidget {
  final String? url;
  final String? localPath;
  final String title;
  final double height;

  const TaskPhoto({
    super.key,
    this.url,
    this.localPath,
    required this.title,
    this.height = 125,
  });

  @override
  State<TaskPhoto> createState() => _TaskPhotoState();
}

class _TaskPhotoState extends State<TaskPhoto> {
  ImageProvider? _provider;
  ImageStream? _stream;
  ImageStreamListener? _listener;

  bool _loaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _resolveImage();
  }

  @override
  void didUpdateWidget(covariant TaskPhoto oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.url != widget.url ||
        oldWidget.localPath != widget.localPath) {
      _resolveImage();
    }
  }

  void _resolveImage() {
    _stream?.removeListener(_listener!);
    _stream = null;
    _listener = null;
    _loaded = false;

    final url = widget.url?.trim() ?? '';
    final path = widget.localPath?.trim() ?? '';

    if (url.startsWith('https://') ||
        url.startsWith('http://')) {
      _provider = NetworkImage(url);
    } else if (path.isNotEmpty &&
        File(path).existsSync()) {
      _provider = FileImage(File(path));
    } else {
      _provider = null;
    }

    if (_provider == null) return;

    final stream = _provider!.resolve(
      createLocalImageConfiguration(context),
    );

    _listener = ImageStreamListener(
      (info, synchronous) {
        if (mounted && !_loaded) {
          setState(() => _loaded = true);
        }
      },
      onError: (error, stack) {
        if (mounted) {
          setState(() => _loaded = false);
        }
      },
    );

    _stream = stream;
    stream.addListener(_listener!);
  }

  @override
  void dispose() {
    if (_stream != null && _listener != null) {
      _stream!.removeListener(_listener!);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_loaded || _provider == null) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(top: 9),
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => TaskPhotoViewer(
                image: _provider!,
                title: widget.title,
              ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(11),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(11),
          child: Stack(
            children: [
              Image(
                image: _provider!,
                width: double.infinity,
                height: widget.height,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) =>
                    const SizedBox.shrink(),
              ),
              Positioned(
                right: 7,
                bottom: 7,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 9,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(
                      alpha: 0.7,
                    ),
                    borderRadius:
                        BorderRadius.circular(7),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.zoom_in,
                        size: 15,
                        color: Colors.white,
                      ),
                      SizedBox(width: 4),
                      Text(
                        'View photo',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class TaskPhotoViewer extends StatefulWidget {
  final ImageProvider image;
  final String title;

  const TaskPhotoViewer({
    super.key,
    required this.image,
    required this.title,
  });

  @override
  State<TaskPhotoViewer> createState() =>
      _TaskPhotoViewerState();
}

class _TaskPhotoViewerState extends State<TaskPhotoViewer> {
  final TransformationController _controller =
      TransformationController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _setScale(double scale) {
    final value = scale.clamp(1.0, 5.0).toDouble();
    _controller.value = Matrix4.identity()
      ..setEntry(0, 0, value)
      ..setEntry(1, 1, value);
  }

  void _zoomIn() {
    final current =
        _controller.value.getMaxScaleOnAxis();
    _setScale(current * 1.5);
  }

  void _zoomOut() {
    final current =
        _controller.value.getMaxScaleOnAxis();
    _setScale(current / 1.5);
  }

  void _reset() => _setScale(1);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(
          widget.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 15),
        ),
        actions: [
          IconButton(
            onPressed: _zoomIn,
            tooltip: 'Zoom in',
            icon: const Icon(Icons.zoom_in),
          ),
          IconButton(
            onPressed: _zoomOut,
            tooltip: 'Zoom out',
            icon: const Icon(Icons.zoom_out),
          ),
          IconButton(
            onPressed: _reset,
            tooltip: 'Reset',
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Center(
        child: InteractiveViewer(
          transformationController: _controller,
          minScale: 1,
          maxScale: 5,
          panEnabled: true,
          scaleEnabled: true,
          child: Image(
            image: widget.image,
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) =>
                const Text(
              'Unable to load photo',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }
}
