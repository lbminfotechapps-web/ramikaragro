import 'dart:async';

import 'package:solufine/core/theme/app_colors.dart';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

String formatNetworkSpeed(double? bytesPerSecond) {
  if (bytesPerSecond == null) return '— KB/s';
  if (bytesPerSecond >= 1000000) {
    return '${(bytesPerSecond / 1000000).toStringAsFixed(1)} MB/s';
  }
  return '${(bytesPerSecond / 1000).toStringAsFixed(1)} KB/s';
}

class ConnectionStatusRow extends StatefulWidget {
  const ConnectionStatusRow({super.key, this.userId = 0});

  final int userId;

  @override
  State<ConnectionStatusRow> createState() => _ConnectionStatusRowState();
}

class _ConnectionStatusRowState extends State<ConnectionStatusRow>
    with WidgetsBindingObserver {
  static const _channel = MethodChannel('solufine/network_traffic');
  final _connectivity = Connectivity();
  final _clock = Stopwatch()..start();
  Timer? _timer;
  Timer? _timeTimer;
  StreamSubscription<List<ConnectivityResult>>? _subscription;
  DateTime _now = DateTime.now();
  String _network = 'Checking…';
  IconData _icon = Icons.network_check;
  int? _previousBytes;
  int? _previousTime;
  double? _speed;
  bool _reading = false;
  bool _active = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _subscription = _connectivity.onConnectivityChanged.listen(
      _updateConnection,
      onError: (Object _) => _updateConnection([]),
    );
    _start();
  }

  void _start() {
    _previousBytes = null;
    _previousTime = null;
    unawaited(_refreshConnection());
    unawaited(_tick());
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 5), (_) => _tick());
    _timeTimer?.cancel();
    setState(() => _now = DateTime.now());
    _timeTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted && _active) setState(() => _now = DateTime.now());
    });
  }

  Future<void> _refreshConnection() async {
    try {
      _updateConnection(await _connectivity.checkConnectivity());
    } catch (_) {
      _updateConnection([]);
    }
  }

  void _updateConnection(List<ConnectivityResult> connections) {
    if (!mounted) return;
    final (label, icon) = connections.contains(ConnectivityResult.wifi)
        ? ('Wi-Fi', Icons.wifi)
        : connections.contains(ConnectivityResult.mobile)
        ? ('Mobile data', Icons.signal_cellular_alt)
        : connections.contains(ConnectivityResult.ethernet)
        ? ('Ethernet', Icons.settings_ethernet)
        : connections.contains(ConnectivityResult.vpn)
        ? ('VPN', Icons.vpn_lock)
        : connections.contains(ConnectivityResult.none)
        ? ('Offline', Icons.wifi_off)
        : ('Unknown', Icons.network_check);
    setState(() {
      if (_network != label) {
        _previousBytes = null;
        _previousTime = null;
        _speed = null;
      }
      _network = label;
      _icon = icon;
    });
  }

  Future<void> _tick() async {
    if (!mounted || !_active || _reading) return;
    _reading = true;
    try {
      final bytes = await _channel.invokeMethod<int>('readBytes');
      if (!mounted || !_active) return;
      final time = _clock.elapsedMicroseconds;
      double? speed;
      if (bytes != null &&
          _previousBytes != null &&
          _previousTime != null &&
          bytes >= _previousBytes! &&
          time > _previousTime!) {
        speed = (bytes - _previousBytes!) * 1000000 / (time - _previousTime!);
      }
      _previousBytes = bytes;
      _previousTime = time;
      setState(() => _speed = _network == 'Offline' ? 0 : speed);
    } on PlatformException {
      _clearSpeed();
    } on MissingPluginException {
      _clearSpeed();
    } finally {
      _reading = false;
    }
  }

  void _clearSpeed() {
    if (!mounted) return;
    setState(() {
      _previousBytes = null;
      _previousTime = null;
      _speed = null;
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _active = state == AppLifecycleState.resumed;
    if (_active) {
      _start();
    } else {
      _timer?.cancel();
      _timeTimer?.cancel();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    _timeTimer?.cancel();
    _subscription?.cancel();
    _clock.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    decoration: const BoxDecoration(color: AppColors.primary),
    child: DefaultTextStyle(
      style: const TextStyle(fontSize: 10, color: Colors.white),
      child: Wrap(
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: 10,
        runSpacing: 6,
        children: [
          Text(widget.userId > 0 ? 'User ID: ${widget.userId}' : 'Guest'),
          Text(DateFormat('dd MMM yyyy').format(_now)),
          Text(DateFormat('hh:mm:ss a').format(_now)),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(_icon, size: 13, color: Colors.white),
              const SizedBox(width: 4),
              Text(_network),
            ],
          ),
          Tooltip(
            message: 'Current device download + upload traffic',
            child: Text('↕ ${formatNetworkSpeed(_speed)}'),
          ),
        ],
      ),
    ),
  );
}
