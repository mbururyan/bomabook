import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../firebase_options.dart';
import '../theme/app_colors.dart';
import '../widgets/boma_mark.dart';
import 'login_screen.dart';

/// The animated splash. Its first frame is identical to Android's native
/// splash image (same green, same mark, same size and position, posts dim, no
/// bars), so the hand-over looks like the native splash coming alive.
///
/// It runs the app's real start-up work and moves on as soon as that's done
/// and a short minimum has passed.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  // On phones: long enough for the ring to visibly fill, short enough not to
  // annoy staff who open the app many times a day. On web, index.html has
  // already been animating while the app downloaded, so don't add a second wait.
  static const _minimumShow =
      kIsWeb ? Duration.zero : Duration(milliseconds: 1200);

  Object? _error;

  @override
  void initState() {
    super.initState();
    _start();
  }

  Future<void> _start() async {
    try {
      await Future.wait([
        _startUp(),
        Future<void>.delayed(_minimumShow),
      ]);
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 350),
          pageBuilder: (_, __, ___) => const LoginScreen(),
          transitionsBuilder: (_, animation, __, child) =>
              FadeTransition(opacity: animation, child: child),
        ),
      );
    } catch (e) {
      // Without this the splash would spin forever with no explanation
      if (mounted) setState(() => _error = e);
    }
  }

  /// Everything the app needs before its first real screen. Checking for a
  /// signed-in user gets added here when real login is built.
  Future<void> _startUp() async {
    // After a hot restart the native side still has Firebase running, and
    // initialising it twice throws
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    }
  }

  void _retry() {
    setState(() => _error = null);
    _start();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      // White status-bar icons on the green
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: AppColors.brand,
        body: Stack(
          children: [
            // Mark dead centre, exactly where the native splash puts its image
            Center(child: BomaMark(animate: _error == null)),
            // Name sits below the mark without nudging it off centre
            Center(
              child: Transform.translate(
                offset: const Offset(0, 104),
                child: _error == null ? const _FadingName() : _ErrorMessage(onRetry: _retry),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FadingName extends StatelessWidget {
  const _FadingName();

  @override
  Widget build(BuildContext context) {
    // The native splash can't show text, so the name fades in rather than popping
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 450),
      builder: (_, opacity, child) => Opacity(opacity: opacity, child: child),
      child: const Text.rich(
        TextSpan(
          style: TextStyle(fontSize: 28, color: Colors.white, letterSpacing: -0.3),
          children: [
            TextSpan(text: 'Boma', style: TextStyle(fontWeight: FontWeight.w800)),
            TextSpan(text: 'Book', style: TextStyle(fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}

class _ErrorMessage extends StatelessWidget {
  const _ErrorMessage({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          "BomaBook couldn't start",
          style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 4),
        const Text(
          'Close the app and open it again.',
          style: TextStyle(color: Colors.white70, fontSize: 13.5),
        ),
        const SizedBox(height: 8),
        TextButton(
          onPressed: onRetry,
          style: TextButton.styleFrom(foregroundColor: Colors.white),
          child: const Text('Try again'),
        ),
      ],
    );
  }
}