import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../theme/uticare_theme.dart';
import '../main.dart';
import 'tracking_page.dart';

class BerandaPage extends StatefulWidget {
  const BerandaPage({super.key});

  @override
  State<BerandaPage> createState() => _BerandaPageState();
}

class _BerandaPageState extends State<BerandaPage> {
  Map<String, dynamic>? _profileData;
  Map<String, dynamic>? _latestRisk;
  Map<String, dynamic>? _todayHabits;
  Map<String, dynamic>? _dailyTip;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAll();
  }

  Future<void> _loadAll() async {
    await Future.wait([
      _fetchProfile(),
      _fetchLatestRisk(),
      _fetchTodayHabits(),
      _fetchDailyTip(),
    ]);
    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _fetchProfile() async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) return;
      final data = await Supabase.instance.client
          .from('profiles')
          .select()
          .eq('id', user.id)
          .maybeSingle();
      if (mounted) setState(() => _profileData = data);
    } catch (_) {}
  }

  Future<void> _fetchLatestRisk() async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) return;
      final data = await Supabase.instance.client
          .from('risk_results')
          .select()
          .eq('user_id', user.id)
          .order('created_at', ascending: false)
          .limit(1)
          .maybeSingle();
      if (mounted) setState(() => _latestRisk = data);
    } catch (_) {}
  }

  Future<void> _fetchTodayHabits() async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) return;
      final today = DateTime.now().toIso8601String().substring(0, 10);
      final data = await Supabase.instance.client
          .from('daily_habits')
          .select()
          .eq('user_id', user.id)
          .eq('log_date', today)
          .maybeSingle();
      if (mounted) setState(() => _todayHabits = data);
    } catch (_) {}
  }

  Future<void> _fetchDailyTip() async {
    try {
      final data = await Supabase.instance.client
          .from('daily_tips')
          .select()
          .eq('is_active', true)
          .limit(15);
      if (data.isNotEmpty && mounted) {
        final dayOfYear = DateTime.now().difference(DateTime(DateTime.now().year, 1, 1)).inDays;
        setState(() => _dailyTip = data[dayOfYear % data.length]);
      }
    } catch (_) {}
  }

  void _openTrackingPage() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const TrackingPage()),
    ).then((_) => _fetchTodayHabits());
  }

  @override
  Widget build(BuildContext context) {
    final name = _profileData?['full_name'] ?? 'Kamu';
    final firstName = name.toString().split(' ').first;

    return Scaffold(
      backgroundColor: UtiCareTheme.background,
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator(color: UtiCareTheme.primary))
            : RefreshIndicator(
                onRefresh: () async {
                  setState(() => _isLoading = true);
                  await _loadAll();
                },
                color: UtiCareTheme.primary,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header greeting
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Hai, $firstName!',
                                style: UtiCareTheme.heading1,
                              ),
                              const SizedBox(height: 2),
                              const Text(
                                'Yuk, jaga kesehatan saluran kemihmu setiap hari!',
                                style: UtiCareTheme.body,
                              ),
                            ],
                          ),
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: UtiCareTheme.primarySubtle,
                              borderRadius: BorderRadius.circular(UtiCareTheme.radiusMd),
                              border: Border.all(color: UtiCareTheme.border),
                            ),
                            child: const Icon(Icons.notifications_outlined, color: UtiCareTheme.primary, size: 22),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // Risk Level Card
                      _buildRiskCard(),

                      const SizedBox(height: 20),

                      // Today's Tracking Header with Button
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Hari Ini', style: UtiCareTheme.heading3),
                          TextButton.icon(
                            onPressed: _openTrackingPage,
                            icon: const Icon(Icons.edit_note_rounded, size: 18),
                            label: const Text('Catat'),
                            style: TextButton.styleFrom(
                              foregroundColor: UtiCareTheme.primary,
                              visualDensity: VisualDensity.compact,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      _buildTodayTracking(),

                      const SizedBox(height: 20),

                      // CTA Ayo Belajar
                      _buildLearnCTA(),

                      const SizedBox(height: 20),

                      // Daily Tip
                      if (_dailyTip != null) _buildDailyTip(),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildRiskCard() {
    final riskLevel = _latestRisk?['risk_level'] ?? 'belum cek';
    final displayLevel = riskLevel.toString().toUpperCase();
    final color = UtiCareTheme.getRiskColor(riskLevel);
    final bgColor = UtiCareTheme.getRiskBgColor(riskLevel);
    final hasRisk = _latestRisk != null;

    String message;
    if (!hasRisk) {
      message = 'Belum pernah cek risiko. Yuk, mulai sekarang!';
    } else {
      switch (riskLevel) {
        case 'rendah':
          message = 'Kamu sedang dalam kondisi baik! Pertahankan kebiasaan sehatmu.';
          break;
        case 'sedang':
          message = 'Perlu perhatian lebih. Tingkatkan kebiasaan sehatmu.';
          break;
        case 'tinggi':
          message = 'Segera konsultasikan ke tenaga kesehatan.';
          break;
        default:
          message = 'Cek risikomu secara berkala.';
      }
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: UtiCareTheme.primaryGradient,
        borderRadius: BorderRadius.circular(UtiCareTheme.radiusXl),
        boxShadow: UtiCareTheme.elevatedShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Risiko ISK-mu',
                style: UtiCareTheme.subtitle.copyWith(color: Colors.white.withValues(alpha: 0.85)),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: hasRisk ? bgColor : Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(UtiCareTheme.radiusRound),
                ),
                child: Text(
                  hasRisk ? displayLevel : 'BELUM CEK',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: hasRisk ? color : Colors.white,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            message,
            style: TextStyle(
              fontSize: 13,
              color: Colors.white.withValues(alpha: 0.9),
              height: 1.4,
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () {
                MainScreen.of(context)?.navigateToPage(2);
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white,
                side: BorderSide(color: Colors.white.withValues(alpha: 0.5)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(UtiCareTheme.radiusMd),
                ),
              ),
              child: const Text('Lihat Detail & Cek Risiko'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTodayTracking() {
    final waterIntake = _todayHabits?['water_intake'] ?? 0;
    final noHoldUrine = _todayHabits?['no_hold_urine'] == true;
    final hygiene = _todayHabits?['genital_hygiene'] ?? '-';
    final activity = _todayHabits?['physical_activity'] ?? 0;

    final items = [
      {
        'icon': Icons.water_drop_rounded,
        'label': 'Minum Air',
        'value': '$waterIntake / 8 gelas',
        'color': const Color(0xFF3B82F6),
      },
      {
        'icon': Icons.wc_rounded,
        'label': 'Tidak Menahan\nBAK',
        'value': noHoldUrine ? 'Baik' : '-',
        'color': const Color(0xFF8B5CF6),
      },
      {
        'icon': Icons.clean_hands_rounded,
        'label': 'Kebersihan\nArea Genital',
        'value': hygiene.toString() == '-' ? '-' : 'Baik',
        'color': const Color(0xFFEC4899),
      },
      {
        'icon': Icons.fitness_center_rounded,
        'label': 'Aktivitas\nFisik',
        'value': '$activity menit',
        'color': const Color(0xFF10B981),
      },
    ];

    return InkWell(
      onTap: _openTrackingPage,
      borderRadius: BorderRadius.circular(UtiCareTheme.radiusLg),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.6,
        ),
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          final color = item['color'] as Color;

          return Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: UtiCareTheme.surface,
              borderRadius: BorderRadius.circular(UtiCareTheme.radiusLg),
              border: Border.all(color: UtiCareTheme.border.withValues(alpha: 0.5)),
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.06),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(item['icon'] as IconData, color: color, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        item['label'] as String,
                        style: UtiCareTheme.caption.copyWith(fontWeight: FontWeight.w600),
                        maxLines: 2,
                      ),
                    ),
                  ],
                ),
                Text(
                  item['value'] as String,
                  style: UtiCareTheme.bodyBold.copyWith(color: color),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildLearnCTA() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: UtiCareTheme.cardGradient,
        borderRadius: BorderRadius.circular(UtiCareTheme.radiusXl),
        border: Border.all(color: UtiCareTheme.primaryLight.withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Ayo Belajar!', style: UtiCareTheme.heading3),
                const SizedBox(height: 4),
                const Text(
                  'Pelajari cara sederhana cegah ISK',
                  style: UtiCareTheme.body,
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () {
                    MainScreen.of(context)?.navigateToPage(1);
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  ),
                  child: const Text('Mulai Belajar'),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: UtiCareTheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(UtiCareTheme.radiusLg),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(UtiCareTheme.radiusLg),
              child: Image.asset(
                'assets/images/uticare_character.jpg',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => const Icon(
                  Icons.menu_book_rounded,
                  size: 36,
                  color: UtiCareTheme.primary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDailyTip() {
    return Container(
      width: double.infinity,
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
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: UtiCareTheme.warningLight,
                  borderRadius: BorderRadius.circular(UtiCareTheme.radiusSm),
                ),
                child: const Icon(Icons.tips_and_updates_rounded, color: UtiCareTheme.warning, size: 18),
              ),
              const SizedBox(width: 10),
              const Text('Tips Hari Ini', style: UtiCareTheme.bodyBold),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            _dailyTip!['title'] ?? '',
            style: UtiCareTheme.subtitle,
          ),
          const SizedBox(height: 4),
          Text(
            _dailyTip!['content'] ?? '',
            style: UtiCareTheme.body.copyWith(height: 1.5),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
