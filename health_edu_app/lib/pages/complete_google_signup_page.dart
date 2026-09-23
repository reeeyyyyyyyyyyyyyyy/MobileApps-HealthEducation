import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../theme/uticare_theme.dart';
import '../main.dart';
import '../utils/toast_helper.dart';
import 'pretest_page.dart';

class CompleteGoogleSignUpPage extends StatefulWidget {
  final String email;

  const CompleteGoogleSignUpPage({super.key, required this.email});

  @override
  State<CompleteGoogleSignUpPage> createState() => _CompleteGoogleSignUpPageState();
}

class _CompleteGoogleSignUpPageState extends State<CompleteGoogleSignUpPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _schoolController = TextEditingController();
  final _classController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _schoolController.dispose();
    _classController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleCompleteSignUp() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final fullName = _nameController.text.trim();
    final school = _schoolController.text.trim();
    final className = _classController.text.trim();
    final password = _passwordController.text;

    try {
      if (!isSupabaseInitialized) {
        throw Exception("Supabase belum diinisialisasi.");
      }

      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) {
        throw Exception("Pengguna tidak terautentikasi.");
      }

      // Update password
      if (password.isNotEmpty) {
        await Supabase.instance.client.auth.updateUser(
          UserAttributes(password: password),
        );
      }

      // Update profile
      await Supabase.instance.client.from('profiles').update({
        'full_name': fullName,
        'school': school,
        'class': className,
      }).eq('id', user.id);

      if (mounted) {
        ToastHelper.showSuccess(context, 'Profil berhasil dilengkapi!');
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const PretestPage()),
          (route) => false,
        );
      }
    } catch (e) {
      debugPrint('Complete Google Sign-Up Error: $e');
      if (mounted) {
        String errorMsg = e.toString().replaceAll('Exception: ', '');
        if (e is AuthException) {
          errorMsg = e.message;
        }
        ToastHelper.showError(context, 'Gagal menyimpan profil: $errorMsg');
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
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 20),

                Center(
                  child: Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: UtiCareTheme.primarySubtle,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.person_add_alt_1_rounded,
                      size: 36,
                      color: UtiCareTheme.primary,
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                const Text(
                  'Lengkapi Profil Kamu',
                  textAlign: TextAlign.center,
                  style: UtiCareTheme.heading2,
                ),
                const SizedBox(height: 8),

                Text(
                  'Selamat! Email ${widget.email} telah terverifikasi. Masukkan data diri kamu untuk melanjutkan ke UtiCare.',
                  textAlign: TextAlign.center,
                  style: UtiCareTheme.body,
                ),
                const SizedBox(height: 32),

                // Nama Lengkap
                TextFormField(
                  controller: _nameController,
                  textCapitalization: TextCapitalization.words,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Nama lengkap wajib diisi';
                    }
                    return null;
                  },
                  decoration: const InputDecoration(
                    labelText: 'Nama Lengkap',
                    prefixIcon: Icon(Icons.person_outline_rounded, color: UtiCareTheme.textTertiary),
                  ),
                ),
                const SizedBox(height: 16),

                // School
                TextFormField(
                  controller: _schoolController,
                  decoration: const InputDecoration(
                    labelText: 'Nama SMA / Sekolah',
                    prefixIcon: Icon(Icons.school_outlined, color: UtiCareTheme.textTertiary),
                  ),
                ),
                const SizedBox(height: 16),

                // Class
                TextFormField(
                  controller: _classController,
                  decoration: const InputDecoration(
                    labelText: 'Kelas (contoh: X-B)',
                    prefixIcon: Icon(Icons.class_outlined, color: UtiCareTheme.textTertiary),
                  ),
                ),
                const SizedBox(height: 16),

                // Password
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  validator: (value) {
                    if (value != null && value.isNotEmpty && value.length < 6) {
                      return 'Kata sandi minimal 6 karakter';
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    labelText: 'Kata Sandi (Opsional)',
                    prefixIcon: const Icon(Icons.lock_outline_rounded, color: UtiCareTheme.textTertiary),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                        color: UtiCareTheme.textTertiary,
                      ),
                      onPressed: () {
                        setState(() => _obscurePassword = !_obscurePassword);
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                ElevatedButton(
                  onPressed: _isLoading ? null : _handleCompleteSignUp,
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : const Text('Simpan & Mulai'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
