import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../theme/uticare_theme.dart';
import '../main.dart';
import '../utils/toast_helper.dart';
import 'complete_google_signup_page.dart';
import 'pretest_page.dart';

class OtpVerificationPage extends StatefulWidget {
  final String email;
  final bool isGoogleSignUp;

  const OtpVerificationPage({
    super.key,
    required this.email,
    this.isGoogleSignUp = false,
  });

  @override
  State<OtpVerificationPage> createState() => _OtpVerificationPageState();
}

class _OtpVerificationPageState extends State<OtpVerificationPage> {
  final _otpController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _handleVerifyOtp() async {
    final otpCode = _otpController.text.trim();

    if (otpCode.length < 6) {
      ToastHelper.showError(context, 'Masukkan kode OTP yang valid');
      return;
    }

    setState(() => _isLoading = true);

    try {
      if (!isSupabaseInitialized) {
        throw Exception("Supabase belum diinisialisasi.");
      }

      await Supabase.instance.client.auth.verifyOTP(
        token: otpCode,
        type: widget.isGoogleSignUp ? OtpType.email : OtpType.signup,
        email: widget.email,
      );

      final currentUser = Supabase.instance.client.auth.currentUser;
      if (currentUser != null) {
        final profile = await Supabase.instance.client
            .from('profiles')
            .select('full_name')
            .eq('id', currentUser.id)
            .maybeSingle();

        final String? fullName = profile?['full_name'];

        if (widget.isGoogleSignUp && (fullName == null || fullName.trim().isEmpty)) {
          if (mounted) {
            ToastHelper.showSuccess(context, 'Verifikasi Berhasil! Lengkapi profil.');
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => CompleteGoogleSignUpPage(email: widget.email),
              ),
            );
          }
          return;
        }
      }

      if (mounted) {
        ToastHelper.showSuccess(context, 'Verifikasi Berhasil! Selamat datang di UtiCare.');
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const PretestPage()),
          (route) => false,
        );
      }
    } catch (e) {
      debugPrint('OTP Verification Error: $e');
      if (mounted) {
        String errorMsg = e.toString().replaceAll('Exception: ', '');
        if (e is AuthException) {
          errorMsg = e.message;
        }
        ToastHelper.showError(context, 'Verifikasi gagal: $errorMsg');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _handleResendOtp() async {
    setState(() => _isLoading = true);

    try {
      if (!isSupabaseInitialized) {
        throw Exception("Supabase belum diinisialisasi.");
      }

      if (widget.isGoogleSignUp) {
        await Supabase.instance.client.auth.signInWithOtp(
          email: widget.email,
        );
      } else {
        await Supabase.instance.client.auth.resend(
          type: OtpType.signup,
          email: widget.email,
        );
      }

      if (mounted) {
        ToastHelper.showSuccess(context, 'Kode OTP baru telah dikirim ke email kamu.');
      }
    } catch (e) {
      debugPrint('Resend OTP Error: $e');
      if (mounted) {
        ToastHelper.showError(
          context,
          'Gagal mengirim ulang: ${e.toString().replaceAll('Exception: ', '')}',
        );
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),

              Center(
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: UtiCareTheme.primarySubtle,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: UtiCareTheme.primary.withValues(alpha: 0.15),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.mark_email_read_rounded,
                    size: 40,
                    color: UtiCareTheme.primary,
                  ),
                ),
              ),
              const SizedBox(height: 28),

              const Text(
                'Verifikasi Email',
                textAlign: TextAlign.center,
                style: UtiCareTheme.heading2,
              ),
              const SizedBox(height: 10),

              const Text(
                'Masukkan kode OTP yang telah dikirim ke:',
                textAlign: TextAlign.center,
                style: UtiCareTheme.body,
              ),
              const SizedBox(height: 4),
              Text(
                widget.email,
                textAlign: TextAlign.center,
                style: UtiCareTheme.bodyBold.copyWith(color: UtiCareTheme.primary),
              ),
              const SizedBox(height: 28),

              // OTP Field
              TextFormField(
                controller: _otpController,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                maxLength: 8,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: UtiCareTheme.textPrimary,
                  letterSpacing: 8,
                ),
                decoration: const InputDecoration(
                  counterText: '',
                  hintText: '••••••••',
                ),
              ),
              const SizedBox(height: 28),

              // Button Verifikasi
              ElevatedButton(
                onPressed: _isLoading ? null : _handleVerifyOtp,
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : const Text('Verifikasi Akun'),
              ),
              const SizedBox(height: 24),

              // Resend OTP
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Belum menerima kode? ', style: UtiCareTheme.body),
                  GestureDetector(
                    onTap: _isLoading ? null : _handleResendOtp,
                    child: Text(
                      'Kirim Ulang',
                      style: UtiCareTheme.bodyBold.copyWith(color: UtiCareTheme.primary),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
