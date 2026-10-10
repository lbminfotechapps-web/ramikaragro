import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

class RotatingHomeCard extends StatefulWidget {
  const RotatingHomeCard({
    super.key,
    required this.weather,
    required this.pending,
    required this.showPending,
  });

  final Widget weather;
  final Widget pending;
  final bool showPending;

  @override
  State<RotatingHomeCard> createState() => _RotatingHomeCardState();
}

class _RotatingHomeCardState extends State<RotatingHomeCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    if (!widget.showPending) return;
    _timer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!mounted ||
          !TickerMode.valuesOf(context).enabled ||
          _controller.isAnimating) {
        return;
      }
      if (_controller.value == 0) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  @override
  void didUpdateWidget(covariant RotatingHomeCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.showPending != widget.showPending) {
      if (!widget.showPending) _controller.value = 0;
      _startTimer();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final progress = Curves.easeInOut.transform(_controller.value);
        final pendingVisible = widget.showPending && progress >= 0.5;
        final angle = pendingVisible
            ? (progress - 1) * math.pi
            : progress * math.pi;
        return IgnorePointer(
          ignoring: _controller.isAnimating,
          child: Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001)
              ..rotateY(angle),
            child: IndexedStack(
              sizing: StackFit.expand,
              index: pendingVisible ? 1 : 0,
              children: [widget.weather, widget.pending],
            ),
          ),
        );
      },
    );
  }
}
