import 'dart:async';
import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

enum PlotMode { manual, walking }

class PlotMeasurementPage extends StatefulWidget {
  final String? cropId;
  final String? farmerName;
  final String? lotNumber;

  const PlotMeasurementPage({
    super.key,
    this.cropId,
    this.farmerName,
    this.lotNumber,
  });

  @override
  State<PlotMeasurementPage> createState() => _PlotMeasurementPageState();
}

class _PlotMeasurementPageState extends State<PlotMeasurementPage> {
  static const Color primary = Color(0xFF176B48);
  static const Color dark = Color(0xFF143B2B);
  static const Color bg = Color(0xFFF6F8F5);

  static const double gunthaSqMeters = 101.17141056;
  static const double acreSqMeters = 4046.8564224;

  GoogleMapController? _mapController;
  StreamSubscription<Position>? _locationSubscription;

  final List<LatLng> _points = [];

  PlotMode _mode = PlotMode.manual;

  bool _tracking = false;
  bool _closed = false;
  bool _loadingLocation = false;
  bool _hasLocation = false;

  LatLng? _currentLocation;

  double _areaSqMeters = 0;
  double _perimeterMeters = 0;

  static const LatLng _initialCamera = LatLng(20.5937, 78.9629);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _getCurrentLocation();
    });
  }

  @override
  void dispose() {
    _locationSubscription?.cancel();
    _mapController?.dispose();
    super.dispose();
  }

  void _message(String value) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text(value), behavior: SnackBarBehavior.floating),
      );
  }

  // ---------------------------------------------------
  // LOCATION PERMISSIONS
  // ---------------------------------------------------

  Future<bool> _checkPermission() async {
    final enabled = await Geolocator.isLocationServiceEnabled();

    if (!enabled) {
      _message('Please enable device location.');
      return false;
    }

    var permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      _message('Location permission is required.');
      return false;
    }

    return true;
  }

  Future<void> _getCurrentLocation() async {
    if (_loadingLocation) return;

    setState(() => _loadingLocation = true);

    try {
      if (!await _checkPermission()) return;

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      final point = LatLng(position.latitude, position.longitude);

      if (!mounted) return;

      setState(() {
        _currentLocation = point;
        _hasLocation = true;
      });

      await _mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(point, 19),
      );
    } catch (e) {
      _message('Unable to get current location: $e');
    } finally {
      if (mounted) {
        setState(() => _loadingLocation = false);
      }
    }
  }

  // ---------------------------------------------------
  // CHANGE MEASUREMENT MODE
  // ---------------------------------------------------

  Future<void> _changeMode(PlotMode mode) async {
    await _stopTracking();

    if (!mounted) return;

    setState(() {
      _mode = mode;
      _points.clear();
      _closed = false;
      _areaSqMeters = 0;
      _perimeterMeters = 0;
    });
  }

  // ---------------------------------------------------
  // MANUAL POINTS
  // ---------------------------------------------------

  void _onMapTap(LatLng point) {
    if (_mode != PlotMode.manual) {
      _message('Select Manual mode to add points.');
      return;
    }

    if (_closed) {
      _message('Plot already closed. Undo to edit.');
      return;
    }

    // Close by tapping near the first point.
    if (_points.length >= 3) {
      final distance = Geolocator.distanceBetween(
        point.latitude,
        point.longitude,
        _points.first.latitude,
        _points.first.longitude,
      );

      if (distance <= 5) {
        _closePlot();
        return;
      }
    }

    _addPoint(point);
  }

  void _addPoint(LatLng point) {
    if (_closed) return;

    setState(() {
      _points.add(point);
      _calculate();
    });
  }

  void _closePlot() {
    if (_points.length < 3) {
      _message('At least 3 points are required.');
      return;
    }

    setState(() {
      _closed = true;
      _calculate();
    });

    _message('Plot boundary closed successfully.');
  }

  // ---------------------------------------------------
  // WALKING GPS TRACKING
  // ---------------------------------------------------

  Future<void> _startTracking() async {
    if (_tracking) return;

    if (!await _checkPermission()) return;

    await _locationSubscription?.cancel();

    if (!mounted) return;

    setState(() {
      _points.clear();
      _closed = false;
      _areaSqMeters = 0;
      _perimeterMeters = 0;
      _tracking = true;
    });

    try {
      final initial = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.best,
        ),
      );

      if (!mounted || !_tracking) return;

      _handlePosition(initial);

      // The location stream is intentionally foreground only.
      _locationSubscription =
          Geolocator.getPositionStream(
            locationSettings: const LocationSettings(
              accuracy: LocationAccuracy.best,
              distanceFilter: 3,
            ),
          ).listen(
            _handlePosition,
            onError: (Object error) {
              _message('GPS error: $error');
              _stopTracking();
            },
          );

      _message('Walking measurement started.');
    } catch (e) {
      await _stopTracking();
      _message('Unable to start tracking: $e');
    }
  }

  void _handlePosition(Position position) {
    if (!mounted || !_tracking) return;

    // Ignore low-accuracy GPS readings.
    if (position.accuracy > 25) return;

    final point = LatLng(position.latitude, position.longitude);

    if (_points.isNotEmpty) {
      final last = _points.last;

      final distance = Geolocator.distanceBetween(
        last.latitude,
        last.longitude,
        point.latitude,
        point.longitude,
      );

      if (distance < 3) return;

      // Avoid automatic closure until enough perimeter
      // has been traversed.
      if (_points.length >= 4 && _perimeterMeters >= 20) {
        final first = _points.first;

        final distanceFromStart = Geolocator.distanceBetween(
          first.latitude,
          first.longitude,
          point.latitude,
          point.longitude,
        );

        if (distanceFromStart <= 5) {
          _finishWalking(closeBoundary: true);
          return;
        }
      }
    }

    _addPoint(point);

    _mapController?.animateCamera(CameraUpdate.newLatLng(point));
  }

  Future<void> _stopTracking() async {
    setStateIfMounted(() => _tracking = false);

    final subscription = _locationSubscription;
    _locationSubscription = null;

    await subscription?.cancel();
  }

  Future<void> _finishWalking({bool closeBoundary = false}) async {
    await _stopTracking();

    if (!mounted) return;

    if (closeBoundary && _points.length >= 3) {
      _closePlot();
    } else {
      _message('Walking measurement stopped.');
    }
  }

  void setStateIfMounted(VoidCallback callback) {
    if (mounted) setState(callback);
  }

  // ---------------------------------------------------
  // AREA AND PERIMETER
  // ---------------------------------------------------

  void _calculate() {
    _perimeterMeters = 0;
    _areaSqMeters = 0;

    if (_points.length < 2) return;

    for (int i = 0; i < _points.length - 1; i++) {
      _perimeterMeters += Geolocator.distanceBetween(
        _points[i].latitude,
        _points[i].longitude,
        _points[i + 1].latitude,
        _points[i + 1].longitude,
      );
    }

    if (_points.length < 3) return;

    // Include closing side for a completed polygon.
    if (_closed) {
      _perimeterMeters += Geolocator.distanceBetween(
        _points.last.latitude,
        _points.last.longitude,
        _points.first.latitude,
        _points.first.longitude,
      );
    }

    // Local geographic projection for small field plots.
    const radius = 6378137.0;

    final origin = _points.first;
    final latitudeOrigin = origin.latitude * math.pi / 180;

    final coordinates = _points.map((p) {
      final x =
          (p.longitude - origin.longitude) *
          math.pi /
          180 *
          radius *
          math.cos(latitudeOrigin);

      final y = (p.latitude - origin.latitude) * math.pi / 180 * radius;

      return math.Point<double>(x, y);
    }).toList();

    double twiceArea = 0;

    for (int i = 0; i < coordinates.length; i++) {
      final j = (i + 1) % coordinates.length;

      twiceArea +=
          coordinates[i].x * coordinates[j].y -
          coordinates[j].x * coordinates[i].y;
    }

    _areaSqMeters = twiceArea.abs() / 2;
  }

  double get _acres => _areaSqMeters / acreSqMeters;

  double get _guntha => _areaSqMeters / gunthaSqMeters;

  // ---------------------------------------------------
  // UNDO, RESET
  // ---------------------------------------------------

  void _undoPoint() {
    if (_tracking) {
      _message('Stop walking before editing points.');
      return;
    }

    if (_points.isEmpty) return;

    setState(() {
      _closed = false;
      _points.removeLast();
      _calculate();
    });
  }

  Future<void> _resetMap() async {
    await _stopTracking();

    if (!mounted) return;

    setState(() {
      _points.clear();
      _closed = false;
      _areaSqMeters = 0;
      _perimeterMeters = 0;
    });
  }

  // ---------------------------------------------------
  // MAP MARKERS AND POLYGON
  // ---------------------------------------------------

  Set<Marker> get _markers {
    final markers = <Marker>{};

    for (int i = 0; i < _points.length; i++) {
      markers.add(
        Marker(
          markerId: MarkerId('point_$i'),
          position: _points[i],
          infoWindow: InfoWindow(
            title: 'Point ${i + 1}',
            snippet: i == 0 ? 'Starting point' : null,
          ),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            i == 0 ? BitmapDescriptor.hueGreen : BitmapDescriptor.hueOrange,
          ),
          onTap: () {
            if (i == 0 && _points.length >= 3 && !_tracking) {
              _closePlot();
            }
          },
        ),
      );
    }

    return markers;
  }

  Set<Polyline> get _polylines {
    if (_points.length < 2) return {};

    return {
      Polyline(
        polylineId: const PolylineId('boundary'),
        points: [..._points, if (_closed) _points.first],
        color: primary,
        width: 5,
      ),
    };
  }

  Set<Polygon> get _polygons {
    if (!_closed || _points.length < 3) return {};

    return {
      Polygon(
        polygonId: const PolygonId('plot'),
        points: _points,
        fillColor: primary.withValues(alpha: 0.18),
        strokeColor: primary,
        strokeWidth: 3,
      ),
    };
  }

  // ---------------------------------------------------
  // SHARE MAP SCREENSHOT
  // ---------------------------------------------------

  Future<void> _shareMap() async {
    if (_mapController == null) return;

    try {
      final Uint8List? bytes = await _mapController!.takeSnapshot();

      if (bytes == null) {
        _message('Unable to capture map.');
        return;
      }

      final dir = await getTemporaryDirectory();

      final file = File('${dir.path}/plot_measurement.png');

      await file.writeAsBytes(bytes);

      final text =
          '''
Plot Measurement
Farmer: ${widget.farmerName ?? '-'}
Lot: ${widget.lotNumber ?? '-'}
Area: ${_acres.toStringAsFixed(4)} Acres
Guntha: ${_guntha.toStringAsFixed(2)}
Square Meters: ${_areaSqMeters.toStringAsFixed(2)}
Perimeter: ${_perimeterMeters.toStringAsFixed(2)} m
''';

      await SharePlus.instance.share(
        ShareParams(
          text: text,
          files: [XFile(file.path)],
          subject: 'Plot Measurement',
        ),
      );
    } catch (e) {
      _message('Unable to share map: $e');
    }
  }

  // ---------------------------------------------------
  // RESULT DIALOG
  // ---------------------------------------------------

  void _showResult() {
    if (_points.length < 3) {
      _message('Please add at least 3 points.');
      return;
    }

    if (_tracking) {
      _message('Stop walking measurement first.');
      return;
    }

    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        title: const Text('Plot Measurement Result'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _resultLine('Area in Acres', _acres.toStringAsFixed(4)),
            _resultLine('Area in Guntha', _guntha.toStringAsFixed(2)),
            _resultLine('Square Meters', _areaSqMeters.toStringAsFixed(2)),
            _resultLine(
              _closed ? 'Perimeter' : 'Traced distance',
              '${_perimeterMeters.toStringAsFixed(2)} m',
            ),
            _resultLine('Total Points', '${_points.length}'),
            _resultLine('Status', _closed ? 'Closed' : 'Not closed'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          FilledButton.icon(
            onPressed: () {
              Navigator.pop(context);
              _shareMap();
            },
            icon: const Icon(Icons.share),
            label: const Text('Share'),
          ),
        ],
      ),
    );
  }

  Widget _resultLine(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(child: Text(label)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  // ---------------------------------------------------
  // UI
  // ---------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        foregroundColor: dark,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Plot Measurement',
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w800,
                color: Color(0xFF718078),
              ),
            ),
            Text(
              'Map your land with precision',
              style: TextStyle(fontSize: 12, color: Color(0xFF718078)),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Share',
            onPressed: _shareMap,
            icon: const Icon(Icons.ios_share_rounded, size: 21),
          ),
          IconButton(
            tooltip: 'Reset',
            onPressed: _resetMap,
            icon: const Icon(Icons.restart_alt_rounded),
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              child: _modeSelector(),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: GoogleMap(
                          initialCameraPosition: const CameraPosition(
                            target: _initialCamera,
                            zoom: 5,
                          ),
                          onMapCreated: (controller) {
                            _mapController = controller;
                            if (_currentLocation != null) {
                              controller.animateCamera(
                                CameraUpdate.newLatLngZoom(
                                  _currentLocation!,
                                  19,
                                ),
                              );
                            }
                          },
                          mapType: MapType.hybrid,
                          myLocationEnabled: _hasLocation,
                          myLocationButtonEnabled: false,
                          zoomControlsEnabled: false,
                          mapToolbarEnabled: false,
                          markers: _markers,
                          polylines: _polylines,
                          polygons: _polygons,
                          onTap: _onMapTap,
                        ),
                      ),
                      Positioned(
                        left: 12,
                        top: 12,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                _tracking
                                    ? Icons.radio_button_checked
                                    : _closed
                                    ? Icons.check_circle_rounded
                                    : Icons.layers_outlined,
                                size: 15,
                                color: primary,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                _tracking
                                    ? 'Recording GPS'
                                    : _closed
                                    ? 'Boundary complete'
                                    : 'Satellite view',
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: dark,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        right: 12,
                        bottom: 12,
                        child: Column(
                          children: [
                            _mapAction(
                              Icons.my_location_rounded,
                              _getCurrentLocation,
                              tooltip: _loadingLocation
                                  ? 'Locating…'
                                  : 'Current location',
                            ),
                            const SizedBox(height: 8),
                            _mapAction(
                              Icons.undo_rounded,
                              _undoPoint,
                              tooltip: 'Undo point',
                            ),
                            const SizedBox(height: 8),
                            _mapAction(
                              Icons.delete_outline_rounded,
                              _resetMap,
                              tooltip: 'Clear points',
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.sizeOf(context).height * 0.28,
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
                child: _measurementPanel(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _modeSelector() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFE8EEE8),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Expanded(
            child: _modeButton(
              'Manual',
              Icons.touch_app_outlined,
              PlotMode.manual,
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: _modeButton(
              'Walking',
              Icons.directions_walk_rounded,
              PlotMode.walking,
            ),
          ),
        ],
      ),
    );
  }

  Widget _modeButton(String title, IconData icon, PlotMode mode) {
    final selected = _mode == mode;
    return Material(
      color: selected ? Colors.white : Colors.transparent,
      borderRadius: BorderRadius.circular(14),
      elevation: selected ? 1 : 0,
      child: InkWell(
        onTap: () {
          if (!selected) _changeMode(mode);
        },
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 18,
                color: selected ? primary : const Color(0xFF718078),
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: selected ? primary : const Color(0xFF718078),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _mapAction(IconData icon, VoidCallback onPressed, {String? tooltip}) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      elevation: 2,
      child: IconButton(
        tooltip: tooltip,
        icon: Icon(icon, color: dark, size: 21),
        onPressed: onPressed,
      ),
    );
  }

  Widget _measurementPanel() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE5EBE5)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(9),
                decoration: BoxDecoration(
                  color: const Color(0xFFEAF4ED),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.space_dashboard_outlined,
                  color: primary,
                  size: 21,
                ),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'Land overview',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                    color: dark,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: bg,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${_points.length} points',
                  style: const TextStyle(
                    color: Color(0xFF718078),
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _metric('ACRES', _acres.toStringAsFixed(4), primary),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _metric(
                  'GUNTHA',
                  _guntha.toStringAsFixed(2),
                  const Color(0xFFAC762F),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(
                Icons.straighten_rounded,
                size: 17,
                color: Color(0xFF718078),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'Distance: ${_perimeterMeters.toStringAsFixed(2)} m',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF718078),
                  ),
                ),
              ),
              Flexible(
                child: Text(
                  '${_areaSqMeters.toStringAsFixed(2)} m²',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: dark,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: _mode == PlotMode.walking && _tracking
                    ? const Color(0xFFC44949)
                    : primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              onPressed: _mode == PlotMode.walking
                  ? (_tracking ? () => _finishWalking() : _startTracking)
                  : (_closed ? null : _closePlot),
              icon: Icon(
                _mode == PlotMode.walking
                    ? (_tracking
                          ? Icons.stop_circle_outlined
                          : Icons.play_arrow_rounded)
                    : Icons.check_circle_outline_rounded,
                size: 20,
              ),
              label: Text(
                _mode == PlotMode.walking
                    ? (_tracking ? 'Stop Walking' : 'Start Walking')
                    : 'Close Plot Boundary',
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: primary,
                side: const BorderSide(color: Color(0xFFD5E4D9)),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              onPressed: _showResult,
              icon: const Icon(Icons.calculate_outlined, size: 20),
              label: const Text(
                'Calculate Area',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            _mode == PlotMode.manual
                ? 'Tap on the map to add plot boundary points.'
                : 'Walk along your plot boundary to record GPS points.',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 11, color: Color(0xFF718078)),
          ),
        ],
      ),
    );
  }

  Widget _metric(String label, String value, Color accent) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: accent.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: accent,
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 3),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.8,
                color: accent,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
