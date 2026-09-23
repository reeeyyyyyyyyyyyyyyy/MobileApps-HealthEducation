import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../theme/uticare_theme.dart';
import '../utils/toast_helper.dart';

class TrackingPage extends StatefulWidget {
  const TrackingPage({super.key});

  @override
  State<TrackingPage> createState() => _TrackingPageState();
}

class _TrackingPageState extends State<TrackingPage> {
  int _waterGlasses = 0;
  bool _noHoldUrine = true;
  String _genitalHygiene = 'baik';
  int _activityMinutes = 0;
  bool _isLoading = true;
  bool _isSaving = false;
  List<Map<String, dynamic>> _pastHabits = [];

  final String _today = DateTime.now().toIso8601String().substring(0, 10);

  @override
  void initState() {
    super.initState();
    _fetchTodayHabits();
    _fetchPastHabits();
  }

  Future<void> _fetchTodayHabits() async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) return;

      final data = await Supabase.instance.client
          .from('daily_habits')
          .select()
          .eq('user_id', user.id)
          .eq('log_date', _today)
          .maybeSingle();

      if (data != null && mounted) {
        setState(() {
          _waterGlasses = data['water_intake'] ?? 0;
          _noHoldUrine = data['no_hold_urine'] ?? true;
          _genitalHygiene = data['genital_hygiene'] ?? 'baik';
          _activityMinutes = data['physical_activity'] ?? 0;
        });
      }
    } catch (e) {
      debugPrint('Error fetching today habits: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _fetchPastHabits() async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) return;

      final data = await Supabase.instance.client
          .from('daily_habits')
          .select()
          .eq('user_id', user.id)
          .order('log_date', ascending: false)
          .limit(7);

      if (mounted) {
        setState(() => _pastHabits = List<Map<String, dynamic>>.from(data));
      }
    } catch (_) {}
  }

  int _calculateScore() {
    int score = 0;
    // Water: up to 35 points (8 glasses = 35)
    if (_waterGlasses >= 8) {
      score += 35;
    } else {
      score += ((_waterGlasses / 8) * 35).round();
    }

    // No hold urine: 25 points
    if (_noHoldUrine) score += 25;

    // Genital hygiene: up to 25 points
    if (_genitalHygiene == 'baik') {
      score += 25;
    } else if (_genitalHygiene == 'cukup') {
      score += 15;
    } else {
      score += 5;
    }

    // Physical activity: up to 15 points (30 min = 15)
    if (_activityMinutes >= 30) {
      score += 15;
    } else {
      score += ((_activityMinutes / 30) * 15).round();
    }

    return score.clamp(0, 100);
  }

  Future<void> _saveHabits() async {
    setState(() => _isSaving = true);

    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) return;

      final score = _calculateScore();

      await Supabase.instance.client.from('daily_habits').upsert({
        'user_id': user.id,
        'log_date': _today,
        'water_intake': _waterGlasses,
        'no_hold_urine': _noHoldUrine,
        'genital_hygiene': _genitalHygiene,
        'physical_activity': _activityMinutes,
        'habit_score': score,
      }, onConflict: 'user_id,log_date');

      if (mounted) {
        ToastHelper.showSuccess(context, 'Catatan kebiasaan hari ini berhasil disimpan!');
        _fetchPastHabits();
      }
    } catch (e) {
      debugPrint('Error saving habits: $e');
      if (mounted) {
        ToastHelper.showError(context, 'Gagal menyimpan catatan.');
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final score = _calculateScore();

    return Scaffold(
      backgroundColor: UtiCareTheme.background,
      appBar: AppBar(
        title: const Text('Tracking Kebiasaan'),
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator(color: UtiCareTheme.primary))
            : SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Score overview card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: UtiCareTheme.primaryGradient,
                        borderRadius: BorderRadius.circular(UtiCareTheme.radiusXl),
                        boxShadow: UtiCareTheme.elevatedShadow,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Skor Kebiasaan Hari Ini',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white.withValues(alpha: 0.85),
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  '$score / 100',
                                  style: const TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  score >= 80
                                      ? 'Luar biasa! Pertahankan kebiasaan baikmu.'
                                      : score >= 50
                                          ? 'Cukup baik, yuk tingkatkan lagi!'
                                          : 'Ayo mulai perbaiki kebiasaan hari ini.',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.white.withValues(alpha: 0.9),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.star_rounded,
                              color: Colors.amberAccent,
                              size: 36,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    const Text('Input Kebiasaan Hari Ini', style: UtiCareTheme.heading3),
                    const SizedBox(height: 14),

                    // 1. Minum Air
                    _buildHabitCard(
                      icon: Icons.water_drop_rounded,
                      iconColor: const Color(0xFF3B82F6),
                      title: 'Konsumsi Air Putih',
                      subtitle: 'Target: 8 gelas per hari',
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton.filled(
                            onPressed: _waterGlasses > 0
                                ? () => setState(() => _waterGlasses--)
                                : null,
                            icon: const Icon(Icons.remove_rounded),
                            style: IconButton.styleFrom(backgroundColor: UtiCareTheme.primarySubtle),
                          ),
                          const SizedBox(width: 20),
                          Column(
                            children: [
                              Text(
                                '$_waterGlasses',
                                style: const TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.w800,
                                  color: UtiCareTheme.textPrimary,
                                ),
                              ),
                              const Text('gelas', style: UtiCareTheme.caption),
                            ],
                          ),
                          const SizedBox(width: 20),
                          IconButton.filled(
                            onPressed: () => setState(() => _waterGlasses++),
                            icon: const Icon(Icons.add_rounded),
                            style: IconButton.styleFrom(backgroundColor: UtiCareTheme.primary),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 12),

                    // 2. Tidak Menahan BAK
                    _buildHabitCard(
                      icon: Icons.wc_rounded,
                      iconColor: UtiCareTheme.primary,
                      title: 'Tidak Menahan Buang Air Kecil',
                      subtitle: 'Segera ke toilet saat terasa ingin BAK',
                      child: SwitchListTile(
                        value: _noHoldUrine,
                        onChanged: (val) => setState(() => _noHoldUrine = val),
                        title: Text(
                          _noHoldUrine ? 'Tidak menahan BAK (Baik)' : 'Sering menahan BAK',
                          style: UtiCareTheme.bodyBold,
                        ),
                        activeThumbColor: UtiCareTheme.primary,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),

                    const SizedBox(height: 12),

                    // 3. Kebersihan Area Genital
                    _buildHabitCard(
                      icon: Icons.clean_hands_rounded,
                      iconColor: const Color(0xFFEC4899),
                      title: 'Kebersihan Area Genital',
                      subtitle: 'Bersihkan dari depan ke belakang dengan air bersih',
                      child: Row(
                        children: ['baik', 'cukup', 'kurang'].map((val) {
                          final isSelected = _genitalHygiene == val;
                          return Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 4),
                              child: ChoiceChip(
                                label: Center(
                                  child: Text(
                                    val[0].toUpperCase() + val.substring(1),
                                    style: TextStyle(
                                      color: isSelected ? Colors.white : UtiCareTheme.textSecondary,
                                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                                selected: isSelected,
                                selectedColor: UtiCareTheme.primary,
                                onSelected: (_) => setState(() => _genitalHygiene = val),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // 4. Aktivitas Fisik
                    _buildHabitCard(
                      icon: Icons.fitness_center_rounded,
                      iconColor: UtiCareTheme.success,
                      title: 'Aktivitas Fisik / Olahraga',
                      subtitle: 'Target: minimal 30 menit per hari',
                      child: Slider(
                        value: _activityMinutes.toDouble(),
                        min: 0,
                        max: 90,
                        divisions: 9,
                        label: '$_activityMinutes menit',
                        activeColor: UtiCareTheme.success,
                        onChanged: (val) => setState(() => _activityMinutes = val.round()),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Save Button
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: _isSaving ? null : _saveHabits,
                        child: _isSaving
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                              )
                            : const Text('Simpan Catatan Hari Ini'),
                      ),
                    ),

                    const SizedBox(height: 32),

                    // History Section
                    if (_pastHabits.isNotEmpty) ...[
                      const Text('Riwayat 7 Hari Terakhir', style: UtiCareTheme.heading3),
                      const SizedBox(height: 12),
                      ..._pastHabits.map((h) {
                        final dateStr = (h['log_date'] ?? '').toString();
                        final hScore = h['habit_score'] ?? 0;
                        final water = h['water_intake'] ?? 0;

                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: UtiCareTheme.surface,
                            borderRadius: BorderRadius.circular(UtiCareTheme.radiusMd),
                            border: Border.all(color: UtiCareTheme.border),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: hScore >= 70
                                      ? UtiCareTheme.successLight
                                      : UtiCareTheme.warningLight,
                                  borderRadius: BorderRadius.circular(UtiCareTheme.radiusRound),
                                ),
                                child: Text(
                                  'Skor $hScore',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800,
                                    color: hScore >= 70
                                        ? UtiCareTheme.success
                                        : UtiCareTheme.warning,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text('$water gelas air', style: UtiCareTheme.body),
                              const Spacer(),
                              Text(dateStr, style: UtiCareTheme.caption),
                            ],
                          ),
                        );
                      }),
                    ],
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildHabitCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: UtiCareTheme.surface,
        borderRadius: BorderRadius.circular(UtiCareTheme.radiusLg),
        border: Border.all(color: UtiCareTheme.border.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(UtiCareTheme.radiusSm),
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: UtiCareTheme.bodyBold),
                    Text(subtitle, style: UtiCareTheme.caption),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}
