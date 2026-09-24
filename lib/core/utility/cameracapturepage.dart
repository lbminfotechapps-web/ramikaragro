import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

class CameraCapturePage extends StatefulWidget {
  const CameraCapturePage({super.key});

  @override
  State<CameraCapturePage> createState() => _CameraCapturePageState();
}

class _CameraCapturePageState extends State<CameraCapturePage>
    with WidgetsBindingObserver {
  CameraController? _controller;

  bool _initializing = true;
  bool _takingPicture = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);

    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      debugPrint('CAMERA PAGE: INITIALIZING');

      final cameras = await availableCameras();

      debugPrint('CAMERA PAGE: FOUND ${cameras.length} CAMERAS');

      if (cameras.isEmpty) {
        throw Exception('No camera available');
      }

      CameraDescription selectedCamera = cameras.first;

      for (final camera in cameras) {
        if (camera.lensDirection == CameraLensDirection.back) {
          selectedCamera = camera;
          break;
        }
      }

      final controller = CameraController(
        selectedCamera,

        // Important for Vivo / lower-memory devices
        ResolutionPreset.medium,

        enableAudio: false,

        imageFormatGroup: ImageFormatGroup.jpeg,
      );

      _controller = controller;

      await controller.initialize();

      debugPrint('CAMERA PAGE: INITIALIZED');

      if (!mounted) return;

      setState(() {
        _initializing = false;
      });
    } catch (e, stackTrace) {
      debugPrint('CAMERA INITIALIZE ERROR: $e');
      debugPrint('$stackTrace');

      if (!mounted) return;

      setState(() {
        _initializing = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unable to initialize camera: $e')),
      );
    }
  }

  Future<void> _takePicture() async {
    if (_takingPicture) return;

    final controller = _controller;

    if (controller == null ||
        !controller.value.isInitialized ||
        controller.value.isTakingPicture) {
      return;
    }

    try {
      setState(() {
        _takingPicture = true;
      });

      debugPrint('CAMERA: TAKING PICTURE');

      final XFile image = await controller.takePicture();

      debugPrint('CAMERA CAPTURED: ${image.path}');

      if (!mounted) return;

      Navigator.pop(context, image.path);
    } catch (e, stackTrace) {
      debugPrint('TAKE PICTURE ERROR: $e');
      debugPrint('$stackTrace');

      if (!mounted) return;

      setState(() {
        _takingPicture = false;
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Unable to capture image')));
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final controller = _controller;

    if (controller == null || !controller.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      controller.dispose();
      _controller = null;
    } else if (state == AppLifecycleState.resumed) {
      _initializeCamera();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);

    _controller?.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Take Photo'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: _initializing
                  ? const Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    )
                  : controller == null || !controller.value.isInitialized
                  ? const Center(
                      child: Text(
                        'Camera not available',
                        style: TextStyle(color: Colors.white),
                      ),
                    )
                  : Center(child: CameraPreview(controller)),
            ),

            Container(
              height: 110,
              width: double.infinity,
              alignment: Alignment.center,
              color: Colors.black,
              child: GestureDetector(
                onTap: _takingPicture ? null : _takePicture,
                child: Container(
                  width: 72,
                  height: 72,
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 4),
                  ),
                  child: Container(
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                    ),
                    child: _takingPicture
                        ? const Padding(
                            padding: EdgeInsets.all(17),
                            child: CircularProgressIndicator(strokeWidth: 3),
                          )
                        : null,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
