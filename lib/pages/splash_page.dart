import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../main.dart';
import 'onboarding_page.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  double _opacity = 0.0;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _startAnimationAndNavigate();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _startAnimationAndNavigate() async {
    await Future.delayed(const Duration(milliseconds: 100));
    if (!mounted) return;

    setState(() {
      _opacity = 1.0;
    });

    await Future.delayed(const Duration(milliseconds: 2500));
    if (!mounted) return;

    _checkSessionAndNavigate();
  }

  void _checkSessionAndNavigate() {
    Session? session;
    if (isSupabaseInitialized) {
      try {
        session = Supabase.instance.client.auth.currentSession;
      } catch (e) {
        debugPrint('Failed to fetch session: $e');
      }
    }

    if (session != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MainScreen()),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const OnboardingPage()),
      );
    }
  }

  /// Attempts to load logo.png, falls back to an animated flower icon widget
  Widget _buildLogo() {
    return FutureBuilder(
      future: _checkAssetExists('assets/logo.png'),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done &&
            snapshot.data == true) {
          return ClipOval(
            child: Image.asset(
              'assets/logo.png',
              width: 300,
              height: 300,
              fit: BoxFit.cover,
            ),
          );
        }
        // Fallback: animated flower/medical icon
        return ScaleTransition(
          scale: _pulseAnimation,
          child: Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: const Icon(
              Icons.local_florist_rounded,
              size: 54,
              color: Color(0xFF8B5CF6),
            ),
          ),
        );
      },
    );
  }

  Future<bool> _checkAssetExists(String assetPath) async {
    try {
      await DefaultAssetBundle.of(context).load(assetPath);
      return true;
    } catch (_) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF8B5CF6),
      body: Center(
        child: AnimatedOpacity(
          opacity: _opacity,
          duration: const Duration(milliseconds: 2000),
          curve: Curves.easeIn,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo with fallback
              _buildLogo(),
              const SizedBox(height: 24),
              // App Name — Rebranded to BloomFem
              const Text(
                'BloomFem',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 8),
              // Slogan
              Text(
                'Pahami Menstruasi, Sayangi Diri',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.8),
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
