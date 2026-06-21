import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../main.dart';
import '../utils/toast_helper.dart';
import 'complete_google_signup_page.dart';
import 'setup_tracker_page.dart';

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

  // === Design System Colors ===
  static const Color primaryColor = Color(0xFF8B5CF6);
  static const Color textPrimary = Color(0xFF1E293B);
  static const Color textSecondary = Color(0xFF64748B);

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _handleVerifyOtp() async {
    final otpCode = _otpController.text.trim();

    if (otpCode.length != 8) {
      ToastHelper.showError(context, 'Masukkan 8 digit kode OTP');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      if (!isSupabaseInitialized) {
        throw Exception("Supabase is not initialized.");
      }

      await Supabase.instance.client.auth.verifyOTP(
        token: otpCode,
        type: widget.isGoogleSignUp ? OtpType.email : OtpType.signup,
        email: widget.email,
      );

      final currentUser = Supabase.instance.client.auth.currentUser;
      if (currentUser != null) {
        // Ambil profil dari database
        final profile = await Supabase.instance.client
            .from('profiles')
            .select('full_name')
            .eq('id', currentUser.id)
            .maybeSingle();

        final String? fullName = profile?['full_name'];

        if (widget.isGoogleSignUp && (fullName == null || fullName.trim().isEmpty)) {
          if (mounted) {
            ToastHelper.showSuccess(context, 'Verifikasi Berhasil! Silakan lengkapi profil Anda.');
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
        ToastHelper.showSuccess(context, 'Verifikasi Berhasil! Selamat datang di BloomFem.');
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const SetupTrackerPage()),
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
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _handleResendOtp() async {
    setState(() {
      _isLoading = true;
    });

    try {
      if (!isSupabaseInitialized) {
        throw Exception("Supabase is not initialized.");
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
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: textPrimary),
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

              // Ikon amplop besar
              Center(
                child: Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEDE9FE),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: primaryColor.withValues(alpha: 0.15),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.mark_email_read_rounded,
                    size: 44,
                    color: primaryColor,
                  ),
                ),
              ),
              const SizedBox(height: 28),

              // Header
              const Text(
                'Verifikasi Email',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: textPrimary,
                ),
              ),
              const SizedBox(height: 10),

              // Sub-description
              const Text(
                'Masukkan 8 digit kode OTP yang telah dikirim ke:',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: textSecondary,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                widget.email,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: primaryColor,
                ),
              ),
              const SizedBox(height: 20),

              // Info card: cek email
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: const Color(0xFFF59E0B).withValues(alpha: 0.3),
                  ),
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.info_outline_rounded,
                      color: Color(0xFFF59E0B),
                      size: 22,
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Cek kotak masuk email kamu. Jika tidak ditemukan, periksa juga folder Spam.',
                        style: TextStyle(
                          fontSize: 13,
                          color: Color(0xFF92400E),
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              // OTP Input Field
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
                  color: textPrimary,
                  letterSpacing: 8,
                ),
                decoration: InputDecoration(
                  counterText: '',
                  hintText: '••••••••',
                  hintStyle: TextStyle(
                    fontSize: 24,
                    color: const Color(0xFF64748B).withValues(alpha: 0.4),
                    letterSpacing: 8,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 20,
                    horizontal: 24,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: Colors.grey.withValues(alpha: 0.15)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: primaryColor, width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 28),

              // Tombol Verifikasi
              ElevatedButton(
                onPressed: _isLoading ? null : _handleVerifyOtp,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 2,
                  shadowColor: primaryColor.withValues(alpha: 0.4),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        'Verifikasi Akun',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
              ),
              const SizedBox(height: 24),

              // Link kirim ulang
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Belum menerima kode? ',
                    style: TextStyle(fontSize: 14, color: textSecondary),
                  ),
                  GestureDetector(
                    onTap: _isLoading ? null : _handleResendOtp,
                    child: const Text(
                      'Kirim Ulang',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: primaryColor,
                      ),
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
