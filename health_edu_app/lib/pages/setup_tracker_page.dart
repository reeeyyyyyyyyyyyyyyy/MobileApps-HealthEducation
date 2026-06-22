import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../main.dart';
import '../utils/toast_helper.dart';
import '../utils/time_helper.dart';

class SetupTrackerPage extends StatefulWidget {
  const SetupTrackerPage({super.key});

  @override
  State<SetupTrackerPage> createState() => _SetupTrackerPageState();
}

class _SetupTrackerPageState extends State<SetupTrackerPage> {
  int _currentStep = 0;
  bool? _hasMenstruated;
  bool? _isFirstTime; // Apakah baru pertama kali atau sudah beberapa kali

  // Alur baru pertama kali
  DateTime? _lastPeriodDate;
  int _avgPeriodDuration = 5;
  int _avgCycleLength = 28;

  // Alur sudah beberapa kali
  DateTime? _lastPeriodStartDate;
  DateTime? _lastPeriodEndDate;
  DateTime? _prevPeriodStartDate;
  DateTime? _prevPeriodEndDate;

  bool _isLoading = false;

  final SupabaseClient _supabase = Supabase.instance.client;

  void _nextStep() {
    if (_currentStep == 0) {
      if (_hasMenstruated == null) {
        ToastHelper.showInfo(context, 'Pilih salah satu jawaban dulu ya!');
        return;
      }
      if (_hasMenstruated == false) {
        _saveSettings();
        return;
      }
      setState(() {
        _currentStep = 1;
      });
      return;
    }

    if (_currentStep == 1) {
      if (_isFirstTime == null) {
        ToastHelper.showInfo(context, 'Pilih salah satu jawaban dulu ya!');
        return;
      }
      setState(() {
        _currentStep = 2;
      });
      return;
    }

    if (_currentStep == 2) {
      if (_isFirstTime == true) {
        if (_lastPeriodDate == null) {
          ToastHelper.showInfo(context, 'Pilih tanggal haid pertamamu dulu ya!');
          return;
        }
        
        final today = DateTime(TimeHelper.nowWIB().year, TimeHelper.nowWIB().month, TimeHelper.nowWIB().day);
        final start = DateTime(_lastPeriodDate!.year, _lastPeriodDate!.month, _lastPeriodDate!.day);
        if (today.difference(start).inDays <= 7) {
          _avgPeriodDuration = 5;
          _saveSettings();
          return;
        }
      } else {
        if (_lastPeriodStartDate == null) {
          ToastHelper.showInfo(context, 'Pilih tanggal mulai haid terakhirmu dulu ya!');
          return;
        }
        if (_lastPeriodEndDate == null) {
          ToastHelper.showInfo(context, 'Pilih tanggal selesai haid terakhirmu dulu ya!');
          return;
        }
        if (_lastPeriodEndDate!.isBefore(_lastPeriodStartDate!)) {
          ToastHelper.showInfo(context, 'Tanggal selesai tidak boleh sebelum tanggal mulai!');
          return;
        }
      }
      setState(() {
        _currentStep = 3;
      });
      return;
    }

    if (_currentStep == 3) {
      if (_isFirstTime == true) {
        if (_avgPeriodDuration == 0) {
          ToastHelper.showInfo(context, 'Pilih berapa hari haidmu berlangsung dulu ya!');
          return;
        }
      } else {
        if (_prevPeriodStartDate == null) {
          ToastHelper.showInfo(context, 'Pilih tanggal mulai haid sebelumnya dulu ya!');
          return;
        }
        if (_prevPeriodEndDate == null) {
          ToastHelper.showInfo(context, 'Pilih tanggal selesai haid sebelumnya dulu ya!');
          return;
        }
        if (_prevPeriodEndDate!.isBefore(_prevPeriodStartDate!)) {
          ToastHelper.showInfo(context, 'Tanggal selesai tidak boleh sebelum tanggal mulai!');
          return;
        }
        if (_lastPeriodStartDate!.isBefore(_prevPeriodStartDate!)) {
          ToastHelper.showInfo(context, 'Tanggal haid terakhir harus setelah haid sebelumnya!');
          return;
        }

        // Hitung otomatis siklus & rata-rata durasi
        final lastDuration = _lastPeriodEndDate!.difference(_lastPeriodStartDate!).inDays + 1;
        final prevDuration = _prevPeriodEndDate!.difference(_prevPeriodStartDate!).inDays + 1;
        _avgPeriodDuration = ((lastDuration + prevDuration) / 2).round();

        final cycleLength = _lastPeriodStartDate!.difference(_prevPeriodStartDate!).inDays;
        if (cycleLength >= 15 && cycleLength <= 45) {
          _avgCycleLength = cycleLength;
        } else {
          _avgCycleLength = 28; // Default normal jika terdeteksi outlier/aneh
        }
        _lastPeriodDate = _lastPeriodStartDate;
      }
      _saveSettings();
      return;
    }
  }

  void _prevStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
    }
  }

  Future<DateTime?> _selectCustomDate(BuildContext context, DateTime? initialDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate ?? TimeHelper.nowWIB(),
      firstDate: TimeHelper.nowWIB().subtract(const Duration(days: 120)),
      lastDate: TimeHelper.nowWIB(),
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
    return picked;
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
      DateTime? resolvedLastPeriodDate;
      if (_hasMenstruated == true) {
        if (_isFirstTime == true) {
          resolvedLastPeriodDate = _lastPeriodDate;
        } else {
          resolvedLastPeriodDate = _lastPeriodStartDate;
        }
      }

      final updateData = {
        'has_menstruated': _hasMenstruated,
        'last_period_date': _hasMenstruated == true && resolvedLastPeriodDate != null
            ? resolvedLastPeriodDate.toIso8601String().split('T')[0]
            : null,
        'avg_period_duration': _hasMenstruated == true ? _avgPeriodDuration : null,
        'avg_cycle_length': _hasMenstruated == true ? _avgCycleLength : null,
      };

      await _supabase.from('profiles').update(updateData).eq('id', user.id);

      // Seed tanggal haid ke daily_logs agar langsung terdeteksi di kalender
      if (_hasMenstruated == true) {
        final List<Map<String, dynamic>> logsToUpsert = [];

        if (_isFirstTime == true && resolvedLastPeriodDate != null) {
          final start = DateTime(resolvedLastPeriodDate.year, resolvedLastPeriodDate.month, resolvedLastPeriodDate.day);
          for (int i = 0; i < _avgPeriodDuration; i++) {
            final date = start.add(Duration(days: i));
            logsToUpsert.add({
              'user_id': user.id,
              'log_date': date.toIso8601String().split('T')[0],
              'is_period_day': true,
              'symptoms': ['Menstruasi (Haid)'],
            });
          }
        } else if (_isFirstTime == false) {
          // Haid Terakhir
          if (_lastPeriodStartDate != null && _lastPeriodEndDate != null) {
            final start = DateTime(_lastPeriodStartDate!.year, _lastPeriodStartDate!.month, _lastPeriodStartDate!.day);
            final days = _lastPeriodEndDate!.difference(_lastPeriodStartDate!).inDays + 1;
            for (int i = 0; i < days; i++) {
              final date = start.add(Duration(days: i));
              logsToUpsert.add({
                'user_id': user.id,
                'log_date': date.toIso8601String().split('T')[0],
                'is_period_day': true,
                'symptoms': ['Menstruasi (Haid)'],
              });
            }
          }
          // Haid Sebelumnya
          if (_prevPeriodStartDate != null && _prevPeriodEndDate != null) {
            final start = DateTime(_prevPeriodStartDate!.year, _prevPeriodStartDate!.month, _prevPeriodStartDate!.day);
            final days = _prevPeriodEndDate!.difference(_prevPeriodStartDate!).inDays + 1;
            for (int i = 0; i < days; i++) {
              final date = start.add(Duration(days: i));
              logsToUpsert.add({
                'user_id': user.id,
                'log_date': date.toIso8601String().split('T')[0],
                'is_period_day': true,
                'symptoms': ['Menstruasi (Haid)'],
              });
            }
          }
        }

        if (logsToUpsert.isNotEmpty) {
          await _supabase.from('daily_logs').upsert(logsToUpsert, onConflict: 'user_id,log_date');
        }
      }

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
        return _buildStepFirstTimeQuestion();
      case 2:
        return _isFirstTime == true
            ? _buildStepLastPeriodDate()
            : _buildStepLastPeriodDateExperienced();
      case 3:
        return _isFirstTime == true
            ? _buildStepPeriodDurationFirstTime()
            : _buildStepPrevPeriodDateExperienced();
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

  Widget _buildStepFirstTimeQuestion() {
    return Column(
      key: const ValueKey(1),
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Text(
          'Apakah ini pertama kali kamu haid? 🌸',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Color(0xFF581C87),
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          'Membantu kami memberikan prediksi yang lebih tepat sesuai pengalamanmu.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            color: Colors.black54,
          ),
        ),
        const SizedBox(height: 48),
        _buildSelectionCard(
          title: 'Baru pertama kali haid 🌱',
          subtitle: 'Ini adalah haid pertamaku dan saya baru mulai mencatat.',
          icon: Icons.spa_rounded,
          isSelected: _isFirstTime == true,
          onTap: () {
            setState(() {
              _isFirstTime = true;
            });
          },
        ),
        const SizedBox(height: 16),
        _buildSelectionCard(
          title: 'Sudah pernah beberapa kali 🔄',
          subtitle: 'Saya sudah beberapa kali haid sebelumnya.',
          icon: Icons.loop_rounded,
          isSelected: _isFirstTime == false,
          onTap: () {
            setState(() {
              _isFirstTime = false;
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
      key: const ValueKey(2),
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Text(
          'Kapan tanggal mulai haid pertamamu? 🗓️',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Color(0xFF581C87),
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          'Pilih tanggal hari pertama haid pertamamu dimulai.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            color: Colors.black54,
          ),
        ),
        const SizedBox(height: 60),
        GestureDetector(
          onTap: () async {
            final date = await _selectCustomDate(context, _lastPeriodDate);
            if (date != null) {
              setState(() {
                _lastPeriodDate = date;
              });
            }
          },
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

  Widget _buildStepLastPeriodDateExperienced() {
    final startString = _lastPeriodStartDate != null
        ? '${_lastPeriodStartDate!.day}/${_lastPeriodStartDate!.month}/${_lastPeriodStartDate!.year}'
        : 'Pilih Tanggal Mulai';
    final endString = _lastPeriodEndDate != null
        ? '${_lastPeriodEndDate!.day}/${_lastPeriodEndDate!.month}/${_lastPeriodEndDate!.year}'
        : 'Pilih Tanggal Selesai';

    return Column(
      key: const ValueKey(2),
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Text(
          'Tanggal Haid Terakhirmu 🩸',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Color(0xFF581C87),
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          'Masukkan tanggal mulai dan tanggal selesai untuk haid yang paling baru.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            color: Colors.black54,
          ),
        ),
        const SizedBox(height: 40),

        // Start Date Selector
        const Text(
          'Hari Pertama (Mulai):',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black87),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () async {
            final date = await _selectCustomDate(context, _lastPeriodStartDate);
            if (date != null) {
              setState(() {
                _lastPeriodStartDate = date;
                final today = DateTime(TimeHelper.nowWIB().year, TimeHelper.nowWIB().month, TimeHelper.nowWIB().day);
                final start = DateTime(date.year, date.month, date.day);
                if (today.difference(start).inDays <= 7) {
                  _lastPeriodEndDate = start.add(const Duration(days: 4));
                }
              });
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.purple.withValues(alpha: 0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                )
              ],
              border: Border.all(
                color: _lastPeriodStartDate != null ? const Color(0xFFD946EF) : Colors.transparent,
                width: 1.5,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.calendar_today_rounded, color: Color(0xFFD946EF), size: 20),
                const SizedBox(width: 12),
                Text(
                  startString,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: _lastPeriodStartDate != null ? Colors.black87 : Colors.black38,
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 24),

        // End Date Selector
        const Text(
          'Hari Terakhir (Selesai):',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black87),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () async {
            final date = await _selectCustomDate(context, _lastPeriodEndDate);
            if (date != null) {
              setState(() {
                _lastPeriodEndDate = date;
              });
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.purple.withValues(alpha: 0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                )
              ],
              border: Border.all(
                color: _lastPeriodEndDate != null ? const Color(0xFFD946EF) : Colors.transparent,
                width: 1.5,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.event_available_rounded, color: Color(0xFFD946EF), size: 20),
                const SizedBox(width: 12),
                Text(
                  endString,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: _lastPeriodEndDate != null ? Colors.black87 : Colors.black38,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStepPeriodDurationFirstTime() {
    return Column(
      key: const ValueKey(3),
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Text(
          'Berapa hari haid pertamamu berlangsung? ⏳',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Color(0xFF581C87),
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          'Pilih perkiraan jumlah hari haid pertamamu berlangsung sampai benar-benar bersih.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            color: Colors.black54,
          ),
        ),
        const SizedBox(height: 48),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          alignment: WrapAlignment.center,
          children: List.generate(5, (index) {
            final days = index + 3; // 3 to 7 days
            final isSelected = _avgPeriodDuration == days;
            return GestureDetector(
              onTap: () {
                setState(() {
                  _avgPeriodDuration = days;
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFFD946EF) : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.purple.withValues(alpha: isSelected ? 0.1 : 0.03),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    )
                  ],
                  border: Border.all(
                    color: isSelected ? Colors.transparent : Colors.purple.shade100,
                    width: 1,
                  ),
                ),
                child: Text(
                  '$days Hari',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isSelected ? Colors.white : Colors.purple.shade900,
                  ),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildStepPrevPeriodDateExperienced() {
    final startString = _prevPeriodStartDate != null
        ? '${_prevPeriodStartDate!.day}/${_prevPeriodStartDate!.month}/${_prevPeriodStartDate!.year}'
        : 'Pilih Tanggal Mulai';
    final endString = _prevPeriodEndDate != null
        ? '${_prevPeriodEndDate!.day}/${_prevPeriodEndDate!.month}/${_prevPeriodEndDate!.year}'
        : 'Pilih Tanggal Selesai';

    return Column(
      key: const ValueKey(3),
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const Text(
          'Tanggal Haid Sebelum yang Terakhir 🔄',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Color(0xFF581C87),
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          'Masukkan tanggal mulai dan tanggal selesai untuk haid sebelum siklus terakhirmu.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            color: Colors.black54,
          ),
        ),
        const SizedBox(height: 40),

        // Start Date Selector
        const Text(
          'Hari Pertama (Mulai):',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black87),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () async {
            final date = await _selectCustomDate(context, _prevPeriodStartDate);
            if (date != null) {
              setState(() {
                _prevPeriodStartDate = date;
                _prevPeriodEndDate = date.add(const Duration(days: 4));
              });
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.purple.withValues(alpha: 0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                )
              ],
              border: Border.all(
                color: _prevPeriodStartDate != null ? const Color(0xFF8B5CF6) : Colors.transparent,
                width: 1.5,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.calendar_today_rounded, color: Color(0xFF8B5CF6), size: 20),
                const SizedBox(width: 12),
                Text(
                  startString,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: _prevPeriodStartDate != null ? Colors.black87 : Colors.black38,
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 24),

        // End Date Selector
        const Text(
          'Hari Terakhir (Selesai):',
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black87),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () async {
            final date = await _selectCustomDate(context, _prevPeriodEndDate);
            if (date != null) {
              setState(() {
                _prevPeriodEndDate = date;
              });
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.purple.withValues(alpha: 0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                )
              ],
              border: Border.all(
                color: _prevPeriodEndDate != null ? const Color(0xFF8B5CF6) : Colors.transparent,
                width: 1.5,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.event_available_rounded, color: Color(0xFF8B5CF6), size: 20),
                const SizedBox(width: 12),
                Text(
                  endString,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: _prevPeriodEndDate != null ? Colors.black87 : Colors.black38,
                  ),
                ),
              ],
            ),
          ),
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
