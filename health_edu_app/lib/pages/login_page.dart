import 'dart:io';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../theme/uticare_theme.dart';
import '../main.dart';
import '../utils/toast_helper.dart';
import 'complete_google_signup_page.dart';
import 'register_page.dart';
import 'pretest_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _checkProfileAndNavigate(String userId) async {
    try {
      final profile = await Supabase.instance.client
          .from('profiles')
          .select('has_completed_pretest')
          .eq('id', userId)
          .maybeSingle();

      if (mounted) {
        if (profile == null || profile['has_completed_pretest'] != true) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const PretestPage()),
            (route) => false,
          );
        } else {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const MainScreen()),
            (route) => false,
          );
        }
      }
    } catch (e) {
      debugPrint('Error checking profile after login: $e');
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const MainScreen()),
          (route) => false,
        );
      }
    }
  }

  Future<void> _handleEmailSignIn() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final email = _emailController.text.trim();
    final password = _passwordController.text;

    try {
      if (!isSupabaseInitialized) {
        throw Exception("Supabase belum diinisialisasi.");
      }

      final authResponse = await Supabase.instance.client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (mounted) {
        ToastHelper.showSuccess(context, 'Berhasil masuk!');
        if (authResponse.user != null) {
          await _checkProfileAndNavigate(authResponse.user!.id);
        } else {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const MainScreen()),
            (route) => false,
          );
        }
      }
    } catch (e) {
      debugPrint('Email Sign-In Error: $e');
      if (mounted) {
        String errorMsg = e.toString().replaceAll('Exception: ', '');
        if (e is AuthException) {
          errorMsg = e.message;
        }
        ToastHelper.showError(context, 'Gagal masuk: $errorMsg');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _handleGoogleSignIn() async {
    setState(() => _isLoading = true);

    try {
      if (!isSupabaseInitialized) {
        throw Exception("Supabase belum diinisialisasi.");
      }

      final GoogleSignIn googleSignIn = GoogleSignIn(
        clientId: Platform.isIOS
            ? '53267466425-6dpv3sj1eba1vm7sl0dbrm2siinb775g.apps.googleusercontent.com'
            : null,
        serverClientId: '53267466425-eovc6r5cflkjd1nonqr69bphi8lhqt9k.apps.googleusercontent.com',
      );

      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      if (googleUser == null) {
        setState(() => _isLoading = false);
        return;
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final accessToken = googleAuth.accessToken;
      final idToken = googleAuth.idToken;

      if (idToken == null) {
        throw Exception('ID Token tidak ditemukan.');
      }

      await Supabase.instance.client.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
        accessToken: accessToken,
      );

      final currentUser = Supabase.instance.client.auth.currentUser;
      if (currentUser != null) {
        final profile = await Supabase.instance.client
            .from('profiles')
            .select('full_name, school')
            .eq('id', currentUser.id)
            .maybeSingle();

        final String? fullName = profile?['full_name'];

        if (fullName == null || fullName.trim().isEmpty) {
          if (mounted) {
            ToastHelper.showSuccess(context, 'Berhasil masuk Google! Silakan lengkapi profil.');
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => CompleteGoogleSignUpPage(email: googleUser.email),
              ),
            );
          }
          return;
        }
      }

      if (mounted) {
        ToastHelper.showSuccess(context, 'Berhasil masuk dengan Google!');
        if (currentUser != null) {
          await _checkProfileAndNavigate(currentUser.id);
        } else {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const MainScreen()),
            (route) => false,
          );
        }
      }
    } catch (e) {
      debugPrint('Google Sign-In Error: $e');
      if (mounted) {
        String errorMsg = e.toString().replaceAll('Exception: ', '');
        if (e is AuthException) {
          errorMsg = e.message;
        }
        ToastHelper.showError(context, 'Gagal masuk dengan Google: $errorMsg');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: UtiCareTheme.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 10),
                const Text(
                  'Selamat Datang di UtiCare',
                  style: UtiCareTheme.heading1,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Masuk ke akunmu untuk memantau kesehatan dan belajar pencegahan ISK.',
                  style: UtiCareTheme.body,
                ),
                const SizedBox(height: 36),

                // Email
                const Text('Email', style: UtiCareTheme.bodyBold),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    hintText: 'nama@email.com',
                    prefixIcon: Icon(Icons.email_outlined, color: UtiCareTheme.textTertiary),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Email tidak boleh kosong';
                    }
                    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                      return 'Format email tidak valid';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Password
                const Text('Kata Sandi', style: UtiCareTheme.bodyBold),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    hintText: '••••••••',
                    prefixIcon: const Icon(Icons.lock_outline_rounded, color: UtiCareTheme.textTertiary),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                        color: UtiCareTheme.textTertiary,
                      ),
                      onPressed: () {
                        setState(() => _obscurePassword = !_obscurePassword);
                      },
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Kata sandi tidak boleh kosong';
                    }
                    if (value.length < 6) {
                      return 'Kata sandi minimal 6 karakter';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 36),

                // Button Masuk
                ElevatedButton(
                  onPressed: _isLoading ? null : _handleEmailSignIn,
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : const Text('Masuk'),
                ),
                const SizedBox(height: 24),

                // Divider
                Row(
                  children: [
                    Expanded(child: Divider(color: UtiCareTheme.border)),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.0),
                      child: Text('atau masuk dengan', style: UtiCareTheme.caption),
                    ),
                    Expanded(child: Divider(color: UtiCareTheme.border)),
                  ],
                ),
                const SizedBox(height: 24),

                // Google Sign In Button
                OutlinedButton(
                  onPressed: _isLoading ? null : _handleGoogleSignIn,
                  style: OutlinedButton.styleFrom(
                    backgroundColor: UtiCareTheme.surface,
                    side: const BorderSide(color: UtiCareTheme.border),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.g_mobiledata_rounded, size: 28, color: UtiCareTheme.primary),
                      SizedBox(width: 8),
                      Text('Masuk dengan Google', style: TextStyle(color: UtiCareTheme.textPrimary)),
                    ],
                  ),
                ),
                const SizedBox(height: 36),

                // Register Link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Belum memiliki akun? ', style: UtiCareTheme.body),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => const RegisterPage()),
                        );
                      },
                      child: Text(
                        'Daftar Sekarang',
                        style: UtiCareTheme.bodyBold.copyWith(color: UtiCareTheme.primary),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
