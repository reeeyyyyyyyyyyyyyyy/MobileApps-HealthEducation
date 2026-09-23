import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/uticare_theme.dart';
import 'login_page.dart';
import 'register_page.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, String>> _slides = [
    {
      'title': 'Edukasi Seru & Interaktif',
      'desc': 'Pelajari cara mencegah ISK dengan materi bergambar yang mudah dipahami.',
      'image': 'assets/images/onboarding_edukasi.jpg',
      'tag': 'Edukasi',
    },
    {
      'title': 'Pengingat Pintar',
      'desc': 'Ingatkan kebiasaan baik setiap hari seperti minum air dan kebersihan diri.',
      'image': 'assets/images/onboarding_pengingat.jpg',
      'tag': 'Pengingat',
    },
    {
      'title': 'Pantau Dirimu',
      'desc': 'Cek risiko ISK mandiri dan pantau progres kebiasaan sehat harianmu.',
      'image': 'assets/images/onboarding_tracking.jpg',
      'tag': 'Monitoring',
    },
    {
      'title': 'Privasi Aman & Terpercaya',
      'desc': 'Data kesehatanmu rahasia dan aman. Hanya kamu yang dapat mengaksesnya.',
      'image': 'assets/images/onboarding_privasi.jpg',
      'tag': 'Privasi',
    },
  ];

  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('has_onboarded', true);
  }

  void _onRegisterTap() async {
    await _completeOnboarding();
    if (!mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const RegisterPage()),
    );
  }

  void _onLoginTap() async {
    await _completeOnboarding();
    if (!mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: UtiCareTheme.background,
      body: SafeArea(
        child: Column(
          children: [
            // Top branding
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: UtiCareTheme.primarySubtle,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.water_drop_rounded, size: 16, color: UtiCareTheme.primary),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'UtiCare',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: UtiCareTheme.primary,
                        ),
                      ),
                    ],
                  ),
                  if (_currentPage < _slides.length - 1)
                    TextButton(
                      onPressed: () {
                        _pageController.animateToPage(
                          _slides.length - 1,
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      },
                      child: const Text('Lewati', style: TextStyle(color: UtiCareTheme.textTertiary)),
                    ),
                ],
              ),
            ),

            // Page View
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() => _currentPage = index);
                },
                itemCount: _slides.length,
                itemBuilder: (context, index) {
                  final slide = _slides[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Image illustration
                        Container(
                          height: 280,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(UtiCareTheme.radiusXl),
                            boxShadow: UtiCareTheme.cardShadow,
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(UtiCareTheme.radiusXl),
                            child: Image.asset(
                              slide['image']!,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => Container(
                                color: UtiCareTheme.primarySubtle,
                                child: const Icon(Icons.health_and_safety_rounded, size: 80, color: UtiCareTheme.primary),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 28),

                        // Tag
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                          decoration: BoxDecoration(
                            color: UtiCareTheme.primarySubtle,
                            borderRadius: BorderRadius.circular(UtiCareTheme.radiusRound),
                          ),
                          child: Text(
                            slide['tag']!,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: UtiCareTheme.primary,
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),

                        // Title
                        Text(
                          slide['title']!,
                          textAlign: TextAlign.center,
                          style: UtiCareTheme.heading2,
                        ),
                        const SizedBox(height: 10),

                        // Desc
                        Text(
                          slide['desc']!,
                          textAlign: TextAlign.center,
                          style: UtiCareTheme.body.copyWith(height: 1.5),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // Page Indicator
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_slides.length, (index) {
                final isActive = _currentPage == index;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: isActive ? 24 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: isActive ? UtiCareTheme.primary : UtiCareTheme.border,
                    borderRadius: BorderRadius.circular(UtiCareTheme.radiusRound),
                  ),
                );
              }),
            ),
            const SizedBox(height: 24),

            // Bottom Buttons
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ElevatedButton(
                    onPressed: _onRegisterTap,
                    child: const Text('Mulai Sekarang'),
                  ),
                  const SizedBox(height: 10),
                  OutlinedButton(
                    onPressed: _onLoginTap,
                    child: const Text('Sudah punya akun? Masuk'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
