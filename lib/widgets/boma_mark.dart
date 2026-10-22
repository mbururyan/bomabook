import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// The BomaBook mark (pig with bars, inside a ring of boma posts), drawn in
/// code so it can animate: posts fill clockwise from 12 o'clock and a bar
/// rises inside the pig at each quarter, then everything resets and loops.
///
/// Same geometry and timing as the web boot screen in web/index.html,
/// so web and Android look identical. Change one, change both.
class BomaMark extends StatefulWidget {
  const BomaMark({
    super.key,
    this.size = 132,
    this.color = Colors.white,
    this.cutOutColor = AppColors.brand,
    this.animate = true,
  });

  final double size;

  /// The pig and the posts.
  final Color color;

  /// The bars, eye and nostrils: should match whatever is behind the mark,
  /// so they read as holes cut out of the pig.
  final Color cutOutColor;

  /// false draws the finished mark, still.
  final bool animate;

  @override
  State<BomaMark> createState() => _BomaMarkState();
}

class _BomaMarkState extends State<BomaMark>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: Duration(milliseconds: _BomaMarkPainter.cycleMs.round()),
  );

  bool get _still =>
      !widget.animate || MediaQuery.disableAnimationsOf(context);

  // Respect "remove animations" in the phone's accessibility settings,
  // and don't burn frames on an animation nobody sees
  void _syncPlayback() {
    if (_still) {
      _controller.stop();
    } else if (!_controller.isAnimating) {
      _controller.repeat();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncPlayback();
  }

  @override
  void didUpdateWidget(BomaMark oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.animate != widget.animate) _syncPlayback();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: widget.size,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) => CustomPaint(
          painter: _BomaMarkPainter(
            ms: _controller.value * _BomaMarkPainter.cycleMs,
            complete: _still,
            color: widget.color,
            cutOut: widget.cutOutColor,
          ),
        ),
      ),
    );
  }
}

class _BomaMarkPainter extends CustomPainter {
  _BomaMarkPainter({
    required this.ms,
    required this.complete,
    required this.color,
    required this.cutOut,
  });

  final double ms;
  final bool complete;
  final Color color;
  final Color cutOut;

  // Everything below is in the icon's 64x64 coordinate box
  static const int _slots = 26;
  static const Set<int> _gate = {0, 1, 25}; // empty slots at the bottom
  static const double _ringRadius = 27;

  static const double stepMs = 70; // per post
  static const double holdMs = 380; // ring full
  static const double restMs = 200; // ring empty, before the next loop
  static const double fadeMs = 180; // each post's fade-in

  static const List<double> _barX = [16, 23, 30, 37];
  static const List<double> _barH = [6, 10, 8, 13];

  // Slot 13 is the top of the ring and slots are numbered clockwise, so
  // starting the list at 13 makes the fill run like a clock
  static final List<int> order = () {
    final posts = [
      for (var i = 0; i < _slots; i++)
        if (!_gate.contains(i)) i
    ];
    final top = posts.indexOf(13);
    return [...posts.sublist(top), ...posts.sublist(0, top)];
  }();

  static double get cycleMs => order.length * stepMs + holdMs + restMs;

  static double _ease(double x) {
    final t = x.clamp(0.0, 1.0).toDouble();
    return 1 - math.pow(1 - t, 3).toDouble();
  }

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(size.width / 64, size.height / 64);

    final posts = order.length;
    final fillEnd = posts * stepMs;
    final resetting = !complete && ms > fillEnd + holdMs;
    final fadeOut =
        resetting ? ((ms - fillEnd - holdMs) / fadeMs).clamp(0.0, 1.0).toDouble() : 0.0;

    // Posts
    final dot = Paint()..isAntiAlias = true;
    for (var k = 0; k < posts; k++) {
      final slot = order[k];
      final a = slot / _slots * 2 * math.pi + math.pi;
      final centre = Offset(
        32 + _ringRadius * math.sin(a),
        32 - _ringRadius * math.cos(a),
      );
      final double on = complete
          ? 1.0
          : resetting
              ? 1 - fadeOut
              : ((ms - k * stepMs) / fadeMs).clamp(0.0, 1.0).toDouble();
      dot.color = color.withValues(alpha: 0.18 + 0.82 * on);
      canvas.drawCircle(centre, 2.3 + 0.3 * on, dot);
    }

    // Pig, positioned exactly as in the icon
    canvas.save();
    canvas.translate(32, 33);
    canvas.scale(0.62);
    canvas.translate(-33, -32);

    final body = Paint()..color = color;
    final tail = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.4
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(
      Path()
        ..moveTo(10, 30)
        ..relativeQuadraticBezierTo(-6, -2, -4, -7)
        ..relativeQuadraticBezierTo(4, -1, 2, 3),
      tail,
    );
    canvas.drawPath(
      Path()
        ..moveTo(42, 21)
        ..lineTo(46, 12)
        ..lineTo(50, 21)
        ..close(),
      body,
    );
    RRect r(double x, double y, double w, double h, double rad) =>
        RRect.fromRectAndRadius(Rect.fromLTWH(x, y, w, h), Radius.circular(rad));
    canvas.drawRRect(r(10, 22, 38, 22, 11), body);
    canvas.drawCircle(const Offset(47, 29), 9, body);
    canvas.drawRRect(r(51, 25, 9, 9, 3), body);
    canvas.drawRRect(r(15, 40, 6, 12, 2), body);
    canvas.drawRRect(r(38, 40, 6, 12, 2), body);

    // Bars: each one starts rising just before the ring reaches its quarter
    final hole = Paint()..color = cutOut;
    final double lit = complete
        ? posts.toDouble()
        : (ms / stepMs + 1).clamp(0.0, posts.toDouble()).toDouble();
    for (var i = 0; i < 4; i++) {
      final double grow = complete
          ? 1.0
          : _ease((lit - (i + 1) * posts / 4 + 3) / 3) * (1 - fadeOut);
      final h = _barH[i] * grow;
      if (h > 0.05) canvas.drawRRect(r(_barX[i], 40 - h, 5, h, 1), hole);
    }
    canvas.drawCircle(const Offset(48, 26.5), 1.5, hole);
    canvas.drawOval(
        Rect.fromCenter(center: const Offset(54.3, 29.5), width: 2, height: 3.2),
        hole);
    canvas.drawOval(
        Rect.fromCenter(center: const Offset(57, 29.5), width: 2, height: 3.2),
        hole);

    canvas.restore();
    canvas.restore();
  }

  @override
  bool shouldRepaint(_BomaMarkPainter old) =>
      old.ms != ms ||
      old.complete != complete ||
      old.color != color ||
      old.cutOut != cutOut;
}