import 'dart:io';

import 'package:demo/core/api_constant/api_client.dart';
import 'package:demo/features/home/doman/home_entity/crop_schedule.dart';
import 'package:demo/features/home/doman/home_entity/crop_schedule_detail.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';

class CropScheduleDetailCard extends StatefulWidget {
  final CropScheduleDetail detail;

  const CropScheduleDetailCard({
    super.key,
    required this.detail,
  });

  @override
  State<CropScheduleDetailCard> createState() =>
      _CropScheduleDetailCardState();
}

class _CropScheduleDetailCardState
    extends State<CropScheduleDetailCard> {
  bool _isDownloading = false;
  double _downloadProgress = 0.0;

  // ---------------------------------------------------------------------------
  // IMAGE NAME
  // ---------------------------------------------------------------------------

  String get imageName {
    return widget.detail.imageName.trim();
  }

  // ---------------------------------------------------------------------------
  // FILE URL
  // ---------------------------------------------------------------------------

  String get fileUrl {
    if (imageName.isNotEmpty) {
      return '${ApiClient.imageCropscheduleUrl}$imageName';
    }

    return '';
  }

  // ---------------------------------------------------------------------------
  // CHECK PDF
  // ---------------------------------------------------------------------------

  bool get isPdf {
    return imageName.toLowerCase().endsWith('.pdf');
  }

  @override
  Widget build(BuildContext context) {
    if (imageName.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFE5ECE7),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: _onAttachmentTap,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                // Preview
                _buildPreview(),

                const SizedBox(width: 14),

                // Details
                Expanded(
                  child: _buildAttachmentInfo(),
                ),

                const SizedBox(width: 8),

                // Action
                _buildActionIcon(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ===========================================================================
  // PREVIEW
  // ===========================================================================

  Widget _buildPreview() {
    // PDF preview
    if (isPdf) {
      return Container(
        width: 70,
        height: 70,
        decoration: BoxDecoration(
          color: const Color(0xFFFFEBEE),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Center(
          child: Icon(
            Icons.picture_as_pdf_rounded,
            color: Color(0xFFD32F2F),
            size: 38,
          ),
        ),
      );
    }

    // Image preview
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Image.network(
        fileUrl,
        width: 70,
        height: 70,
        fit: BoxFit.cover,

        loadingBuilder: (
          context,
          child,
          loadingProgress,
        ) {
          if (loadingProgress == null) {
            return child;
          }

          return Container(
            width: 70,
            height: 70,
            color: const Color(0xFFF1F5F2),
            child: const Center(
              child: SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: Color(0xFF2E7D32),
                ),
              ),
            ),
          );
        },

        errorBuilder: (
          context,
          error,
          stackTrace,
        ) {
          return Container(
            width: 70,
            height: 70,
            color: const Color(0xFFF1F5F2),
            child: const Icon(
              Icons.image_not_supported_outlined,
              color: Color(0xFF78909C),
              size: 30,
            ),
          );
        },
      ),
    );
  }

  // ===========================================================================
  // ATTACHMENT INFO
  // ===========================================================================

  Widget _buildAttachmentInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Type badge
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 9,
            vertical: 5,
          ),
          decoration: BoxDecoration(
            color: isPdf
                ? const Color(0xFFFFEBEE)
                : const Color(0xFFE8F5E9),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            isPdf ? 'PDF DOCUMENT' : 'IMAGE',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.5,
              color: isPdf
                  ? const Color(0xFFC62828)
                  : const Color(0xFF2E7D32),
            ),
          ),
        ),

        const SizedBox(height: 8),

        // File name
        Text(
          imageName,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: Color(0xFF263238),
          ),
        ),

        const SizedBox(height: 5),

        // Description
        Text(
          isPdf
              ? (_isDownloading
                  ? 'Downloading PDF...'
                  : 'Tap to download / open')
              : 'Tap to view image',
          style: const TextStyle(
            fontSize: 12,
            color: Color(0xFF78909C),
            fontWeight: FontWeight.w500,
          ),
        ),

        // Download progress
        if (_isDownloading) ...[
          const SizedBox(height: 8),
          _buildDownloadProgress(),
        ],
      ],
    );
  }

  // ===========================================================================
  // DOWNLOAD PROGRESS
  // ===========================================================================

  Widget _buildDownloadProgress() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: _downloadProgress > 0
                ? _downloadProgress
                : null,
            minHeight: 5,
            backgroundColor: const Color(0xFFE8F0E9),
            color: const Color(0xFF2E7D32),
          ),
        ),

        const SizedBox(height: 5),

        Text(
          _downloadProgress > 0
              ? '${(_downloadProgress * 100).toStringAsFixed(0)}%'
              : 'Preparing download...',
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: Color(0xFF2E7D32),
          ),
        ),
      ],
    );
  }

  // ===========================================================================
  // ACTION ICON
  // ===========================================================================

  Widget _buildActionIcon() {
    if (_isDownloading) {
      return Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: const Color(0xFFE8F5E9),
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Center(
          child: Icon(
            Icons.downloading_rounded,
            color: Color(0xFF2E7D32),
            size: 22,
          ),
        ),
      );
    }

    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: isPdf
            ? const Color(0xFFFFEBEE)
            : const Color(0xFFE8F5E9),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Icon(
        isPdf
            ? Icons.download_rounded
            : Icons.open_in_full_rounded,
        color: isPdf
            ? const Color(0xFFD32F2F)
            : const Color(0xFF2E7D32),
        size: 21,
      ),
    );
  }

  // ===========================================================================
  // TAP
  // ===========================================================================

  Future<void> _onAttachmentTap() async {
    if (imageName.isEmpty) {
      return;
    }

    if (isPdf) {
      await _handlePdf();
    } else {
      await _openImage();
    }
  }

  // ===========================================================================
  // OPEN IMAGE
  // ===========================================================================

  Future<void> _openImage() async {
    if (fileUrl.isEmpty) {
      _showMessage(
        'Image URL not available',
        isError: true,
      );
      return;
    }

    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) {
          return FullScreenImagePage(
            imageUrl: fileUrl,
            title: imageName,
          );
        },
      ),
    );
  }

  // ===========================================================================
  // HANDLE PDF
  // ===========================================================================

  Future<void> _handlePdf() async {
    if (_isDownloading) {
      return;
    }

    try {
      final file = await _getPdfFile();

      // ---------------------------------------------------------------
      // PDF ALREADY DOWNLOADED
      // ---------------------------------------------------------------

      if (await file.exists()) {
        await _openPdfFile(file);
        return;
      }

      // ---------------------------------------------------------------
      // PDF NOT DOWNLOADED
      // ---------------------------------------------------------------

      await _downloadPdf(file);
    } catch (e) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isDownloading = false;
        _downloadProgress = 0.0;
      });

      _showMessage(
        'Unable to open PDF',
        isError: true,
      );
    }
  }

  // ===========================================================================
  // GET PDF FILE
  // ===========================================================================

  Future<File> _getPdfFile() async {
    final directory =
        await getApplicationDocumentsDirectory();

    final safeFileName = _getSafeFileName(imageName);

    return File(
      '${directory.path}/$safeFileName',
    );
  }

  // ===========================================================================
  // DOWNLOAD PDF
  // ===========================================================================

  Future<void> _downloadPdf(File file) async {
    if (!mounted) {
      return;
    }

    setState(() {
      _isDownloading = true;
      _downloadProgress = 0.0;
    });

    try {
      final request = http.Request(
        'GET',
        Uri.parse(fileUrl),
      );

      final response = await request.send();

      if (response.statusCode != 200) {
        throw Exception(
          'PDF download failed: ${response.statusCode}',
        );
      }

      final contentLength =
          response.contentLength ?? 0;

      final List<int> bytes = [];

      int receivedBytes = 0;

      await for (final chunk in response.stream) {
        bytes.addAll(chunk);

        receivedBytes += chunk.length;

        if (mounted && contentLength > 0) {
          setState(() {
            _downloadProgress =
                receivedBytes / contentLength;
          });
        }
      }

      if (bytes.isEmpty) {
        throw Exception(
          'Downloaded PDF is empty',
        );
      }

      await file.writeAsBytes(
        bytes,
        flush: true,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _isDownloading = false;
        _downloadProgress = 1.0;
      });

      _showMessage(
        'PDF downloaded successfully',
      );

      // Open PDF automatically after download.
      await Future.delayed(
        const Duration(milliseconds: 300),
      );

      if (mounted) {
        await _openPdfFile(file);
      }
    } catch (e) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isDownloading = false;
        _downloadProgress = 0.0;
      });

      _showMessage(
        'PDF download failed',
        isError: true,
      );
    }
  }

  // ===========================================================================
  // OPEN PDF
  // ===========================================================================

  Future<void> _openPdfFile(File file) async {
    if (!await file.exists()) {
      _showMessage(
        'PDF file not found',
        isError: true,
      );
      return;
    }

    final result = await OpenFilex.open(
      file.path,
      type: 'application/pdf',
    );

    if (!mounted) {
      return;
    }

    if (result.type != ResultType.done) {
      _showMessage(
        'No PDF viewer available on this device',
        isError: true,
      );
    }
  }

  // ===========================================================================
  // SAFE FILE NAME
  // ===========================================================================

  String _getSafeFileName(String fileName) {
    String name = fileName.trim();

    if (name.isEmpty) {
      name = 'crop_schedule.pdf';
    }

    name = name.replaceAll(
      RegExp(r'[\\/:*?"<>|]'),
      '_',
    );

    if (!name.toLowerCase().endsWith('.pdf')) {
      name = '$name.pdf';
    }

    return name;
  }

  // ===========================================================================
  // SNACKBAR
  // ===========================================================================

  void _showMessage(
    String message, {
    bool isError = false,
  }) {
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(
                isError
                    ? Icons.error_outline_rounded
                    : Icons.check_circle_outline_rounded,
                color: Colors.white,
                size: 20,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          behavior: SnackBarBehavior.floating,
          backgroundColor: isError
              ? const Color(0xFFC62828)
              : const Color(0xFF2E7D32),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          margin: const EdgeInsets.all(16),
        ),
      );
  }
}

// =============================================================================
// FULL SCREEN IMAGE PAGE
// =============================================================================

class FullScreenImagePage extends StatelessWidget {
  final String imageUrl;
  final String title;

  const FullScreenImagePage({
    super.key,
    required this.imageUrl,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(
          title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SafeArea(
        child: InteractiveViewer(
          minScale: 0.8,
          maxScale: 5.0,
          panEnabled: true,
          scaleEnabled: true,
          child: Center(
            child: Image.network(
              imageUrl,
              fit: BoxFit.contain,
              loadingBuilder: (
                context,
                child,
                loadingProgress,
              ) {
                if (loadingProgress == null) {
                  return child;
                }

                return const Center(
                  child: CircularProgressIndicator(
                    color: Colors.white,
                  ),
                );
              },
              errorBuilder: (
                context,
                error,
                stackTrace,
              ) {
                return const Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.broken_image_outlined,
                        color: Colors.white70,
                        size: 60,
                      ),
                      SizedBox(height: 12),
                      Text(
                        'Unable to load image',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}