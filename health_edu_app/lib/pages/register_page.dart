import 'dart:io';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../theme/uticare_theme.dart';
import '../main.dart';
import '../utils/toast_helper.dart';
import 'login_page.dart';
import 'otp_verification_page.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _ageController = TextEditingController();
  final _schoolController = TextEditingController();
  final _classController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _ageController.dispose();
    _schoolController.dispose();
    _classController.dispose();
    super.dispose();
  }

  Future<void> _handleEmailSignUp() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final age = int.tryParse(_ageController.text.trim());
    final school = _schoolController.text.trim();
    final className = _classController.text.trim();

    try {
      if (!isSupabaseInitialized) {
        throw Exception("Supabase belum diinisialisasi.");
      }

      await Supabase.instance.client.auth.signUp(
        email: email,
        password: password,
        data: {
          'full_name': name,
          'age': age,
          'school': school,
          'class': className,
        },
      );

      if (mounted) {
        ToastHelper.showSuccess(context, 'Kode OTP telah dikirim ke email kamu!');
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => OtpVerificationPage(email: email),
          ),
        );
      }
    } catch (e) {
      debugPrint('Email Sign-Up Error: $e');
      if (mounted) {
        String errorMsg = e.toString().replaceAll('Exception: ', '');
        if (e is AuthException) {
          errorMsg = e.message;
        }
        ToastHelper.showError(context, 'Pendaftaran gagal: $errorMsg');
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

      await Supabase.instance.client.auth.signInWithOtp(
        email: googleUser.email,
      );

      if (mounted) {
        ToastHelper.showSuccess(
          context,
          'Kode OTP pendaftaran telah dikirim ke email kamu!',
        );
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => OtpVerificationPage(
              email: googleUser.email,
              isGoogleSignUp: true,
            ),
          ),
        );
      }
    } catch (e) {
      debugPrint('Google Sign-In Error: $e');
      if (mounted) {
        String errorMsg = e.toString().replaceAll('Exception: ', '');
        if (e is AuthException) {
          errorMsg = e.message;
        }
        ToastHelper.showError(context, 'Gagal memproses pendaftaran Google: $errorMsg');
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
                  'Daftar Akun UtiCare',
                  style: UtiCareTheme.heading1,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Daftarkan dirimu untuk berpartisipasi dalam program pencegahan ISK.',
                  style: UtiCareTheme.body,
                ),
                const SizedBox(height: 28),

                // Name
                const Text('Nama Lengkap', style: UtiCareTheme.bodyBold),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _nameController,
                  keyboardType: TextInputType.name,
                  decoration: const InputDecoration(
                    hintText: 'Nama lengkap kamu',
                    prefixIcon: Icon(Icons.person_outline_rounded, color: UtiCareTheme.textTertiary),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Nama tidak boleh kosong';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // School & Class Row
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Sekolah / SMA', style: UtiCareTheme.bodyBold),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _schoolController,
                            decoration: const InputDecoration(
                              hintText: 'Nama SMA',
                              prefixIcon: Icon(Icons.school_outlined, color: UtiCareTheme.textTertiary),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Kelas / Umur', style: UtiCareTheme.bodyBold),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _classController,
                            decoration: const InputDecoration(
                              hintText: 'Contoh: X-A',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

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
                const SizedBox(height: 16),

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
                const SizedBox(height: 28),

                // Button Daftar
                ElevatedButton(
                  onPressed: _isLoading ? null : _handleEmailSignUp,
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : const Text('Daftar'),
                ),
                const SizedBox(height: 24),

                // Divider
                Row(
                  children: [
                    Expanded(child: Divider(color: UtiCareTheme.border)),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.0),
                      child: Text('atau daftar dengan', style: UtiCareTheme.caption),
                    ),
                    Expanded(child: Divider(color: UtiCareTheme.border)),
                  ],
                ),
                const SizedBox(height: 24),

                // Google Sign In
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
                      Text('Daftar dengan Google', style: TextStyle(color: UtiCareTheme.textPrimary)),
                    ],
                  ),
                ),
                const SizedBox(height: 36),

                // Login Link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Sudah memiliki akun? ', style: UtiCareTheme.body),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => const LoginPage()),
                        );
                      },
                      child: Text(
                        'Masuk Sekarang',
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
