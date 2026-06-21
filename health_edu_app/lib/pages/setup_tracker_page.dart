import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../main.dart';
import '../utils/toast_helper.dart';

class SetupTrackerPage extends StatefulWidget {
  const SetupTrackerPage({super.key});

  @override
  State<SetupTrackerPage> createState() => _SetupTrackerPageState();
}

class _SetupTrackerPageState extends State<SetupTrackerPage> {
  int _currentStep = 0;
  bool? _hasMenstruated;
  DateTime? _lastPeriodDate;
  int _avgPeriodDuration = 5;
  int _avgCycleLength = 28;
  bool _isLoading = false;

  final SupabaseClient _supabase = Supabase.instance.client;

  void _nextStep() {
    if (_currentStep == 0 && _hasMenstruated == false) {
      // If not menstruated yet, save directly
      _saveSettings();
      return;
    }
    
    if (_currentStep == 0 && _hasMenstruated == null) {
      ToastHelper.showInfo(context, 'Pilih salah satu jawaban dulu ya!');
      return;
    }

    if (_currentStep == 1 && _lastPeriodDate == null) {
      ToastHelper.showInfo(context, 'Pilih tanggal haid terakhirmu dulu ya!');
      return;
    }

    if (_currentStep == 3) {
      _saveSettings();
      return;
    }

    setState(() {
      _currentStep++;
    });
  }

  void _prevStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _lastPeriodDate ?? DateTime.now(),
      firstDate: DateTime.now().subtract(const Duration(days: 90)),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFFD946EF), // Pink/Magenta accent
              onPrimary: Colors.white,
              onSurface: Colors.black87,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _lastPeriodDate) {
      setState(() {
        _lastPeriodDate = picked;
      });
    }
  }

  Future<void> _saveSettings() async {
    final user = _supabase.auth.currentUser;
    if (user == null) {
      ToastHelper.showError(context, 'Kamu belum login.');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final updateData = {
        'has_menstruated': _hasMenstruated,
        'last_period_date': _hasMenstruated == true && _lastPeriodDate != null
            ? _lastPeriodDate!.toIso8601String().split('T')[0]
            : null,
        'avg_period_duration': _hasMenstruated == true ? _avgPeriodDuration : null,
        'avg_cycle_length': _hasMenstruated == true ? _avgCycleLength : null,
      };

      await _supabase.from('profiles').update(updateData).eq('id', user.id);

      if (mounted) {
        ToastHelper.showSuccess(context, 'Pengaturan siklus berhasil disimpan! ✨');
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MainScreen()),
        );
      }
    } catch (e) {
      debugPrint('Error saving tracker settings: $e');
      if (mounted) {
        ToastHelper.showError(context, 'Gagal menyimpan pengaturan: $e');
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
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFFDF4FF), // Soft violet pink
              Color(0xFFF5F3FF), // Soft purple tint
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header & Progress Indicator
                _buildHeader(),
                const SizedBox(height: 32),
                
                // Active Wizard Step Content
                Expanded(
                  child: SingleChildScrollView(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: _buildStepContent(),
                    ),
                  ),
                ),

                // Navigation Buttons
                _buildNavigationButtons(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    double progress = (_hasMenstruated == false)
        ? 1.0
        : (_hasMenstruated == true ? (_currentStep + 1) / 4 : 0.15);
        
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            if (_currentStep > 0 && _hasMenstruated == true)
              IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.grey),
                onPressed: _prevStep,
              )
            else
              const SizedBox(width: 48),
            const Text(
              'BloomFem Tracker',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF6B21A8),
              ),
            ),
            const SizedBox(width: 48),
          ],
        ),
        const SizedBox(height: 16),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.purple.shade50,
            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFD946EF)),
            minHeight: 8,
          ),
        ),
      ],
    );
  }

  Widget _buildStepContent() {
    switch (_currentStep) {
      case 0:
        return _buildStepHasMenstruated();
      case 1:
        return _buildStepLastPeriodDate();
      case 2:
        return _buildStepPeriodDuration();
      case 3:
        return _buildStepCycleLength();
      default:
        return const SizedBox();
    }
  }

  Widget _buildStepHasMenstruated() {
    return Column(
      key: const ValueKey(0),
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Text(
          'Halo! Kami ingin mengenalmu lebih baik 🌸',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Color(0xFF581C87),
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          'Pertanyaan ini membantu kami menyesuaikan fitur pelacak siklus kesehatan untukmu.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            color: Colors.black54,
          ),
        ),
        const SizedBox(height: 48),
        _buildSelectionCard(
          title: 'Ya, sudah pernah haid',
          subtitle: 'Saya ingin memantau dan melacak siklus menstruasi bulanan saya.',
          icon: Icons.calendar_month_rounded,
          isSelected: _hasMenstruated == true,
          onTap: () {
            setState(() {
              _hasMenstruated = true;
            });
          },
        ),
        const SizedBox(height: 16),
        _buildSelectionCard(
          title: 'Belum pernah haid',
          subtitle: 'Belum waktunya, atau saya ingin belajar dan mempersiapkan diri saja.',
          icon: Icons.favorite_rounded,
          isSelected: _hasMenstruated == false,
          onTap: () {
            setState(() {
              _hasMenstruated = false;
            });
          },
        ),
      ],
    );
  }

  Widget _buildStepLastPeriodDate() {
    final dateString = _lastPeriodDate != null
        ? '${_lastPeriodDate!.day}/${_lastPeriodDate!.month}/${_lastPeriodDate!.year}'
        : 'Pilih Tanggal';

    return Column(
      key: const ValueKey(1),
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Text(
          'Kapan hari pertama haid terakhirmu? 🗓️',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Color(0xFF581C87),
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          'Pilih tanggal hari pertama kamu mulai haid di bulan ini atau bulan lalu.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            color: Colors.black54,
          ),
        ),
        const SizedBox(height: 60),
        GestureDetector(
          onTap: () => _selectDate(context),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 32),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.purple.withValues(alpha: 0.05),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                )
              ],
              border: Border.all(
                color: _lastPeriodDate != null ? const Color(0xFFD946EF) : Colors.transparent,
                width: 2,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.event_note_rounded,
                  color: Color(0xFFD946EF),
                  size: 28,
                ),
                const SizedBox(width: 16),
                Text(
                  dateString,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: _lastPeriodDate != null ? Colors.black87 : Colors.black38,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStepPeriodDuration() {
    return Column(
      key: const ValueKey(2),
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Text(
          'Berapa lama biasanya haid berlangsung? ⏳',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Color(0xFF581C87),
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          'Hitung sejak hari pertama keluar bercak hingga hari terakhir menstruasi bersih.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            color: Colors.black54,
          ),
        ),
        const SizedBox(height: 60),
        Text(
          '$_avgPeriodDuration Hari',
          style: const TextStyle(
            fontSize: 48,
            fontWeight: FontWeight.bold,
            color: Color(0xFFD946EF),
          ),
        ),
        const SizedBox(height: 24),
        Slider(
          value: _avgPeriodDuration.toDouble(),
          min: 3.0,
          max: 7.0,
          divisions: 4,
          label: '$_avgPeriodDuration Hari',
          activeColor: const Color(0xFFD946EF),
          inactiveColor: Colors.purple.shade50,
          onChanged: (value) {
            setState(() {
              _avgPeriodDuration = value.round();
            });
          },
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const [
            Text('3 Hari (Singkat)', style: TextStyle(color: Colors.grey, fontSize: 12)),
            Text('7 Hari (Lama)', style: TextStyle(color: Colors.grey, fontSize: 12)),
          ],
        ),
      ],
    );
  }

  Widget _buildStepCycleLength() {
    return Column(
      key: const ValueKey(3),
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Text(
          'Berapa jarak antar siklus haidmu? 🔄',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Color(0xFF581C87),
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          'Jumlah hari dari hari pertama haid bulan ini sampai hari pertama haid bulan berikutnya.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            color: Colors.black54,
          ),
        ),
        const SizedBox(height: 60),
        Text(
          '$_avgCycleLength Hari',
          style: const TextStyle(
            fontSize: 48,
            fontWeight: FontWeight.bold,
            color: Color(0xFF8B5CF6),
          ),
        ),
        const SizedBox(height: 24),
        Slider(
          value: _avgCycleLength.toDouble(),
          min: 21.0,
          max: 35.0,
          divisions: 14,
          label: '$_avgCycleLength Hari',
          activeColor: const Color(0xFF8B5CF6),
          inactiveColor: Colors.purple.shade50,
          onChanged: (value) {
            setState(() {
              _avgCycleLength = value.round();
            });
          },
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const [
            Text('21 Hari', style: TextStyle(color: Colors.grey, fontSize: 12)),
            Text('28 Hari (Normal)', style: TextStyle(color: Colors.grey, fontSize: 12)),
            Text('35 Hari', style: TextStyle(color: Colors.grey, fontSize: 12)),
          ],
        ),
      ],
    );
  }

  Widget _buildSelectionCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.purple.withValues(alpha: isSelected ? 0.08 : 0.03),
              blurRadius: 15,
              offset: const Offset(0, 8),
            )
          ],
          border: Border.all(
            color: isSelected ? const Color(0xFFD946EF) : Colors.transparent,
            width: 2.5,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFFFDF4FF) : const Color(0xFFF5F3FF),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: isSelected ? const Color(0xFFD946EF) : const Color(0xFF8B5CF6),
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF3B0764),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavigationButtons() {
    final isLastStep = _currentStep == 3;
    final buttonText = _isLoading
        ? 'Menyimpan...'
        : (isLastStep || _hasMenstruated == false ? 'Simpan Pengaturan' : 'Lanjutkan');

    return Container(
      padding: const EdgeInsets.only(top: 16.0),
      child: ElevatedButton(
        onPressed: _isLoading ? null : _nextStep,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF8B5CF6),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 2,
        ),
        child: Text(
          buttonText,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
