import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../main.dart';
import '../utils/toast_helper.dart';
import '../utils/time_helper.dart';

import 'detail_modul_page.dart';
import 'tracker_detail_page.dart';
import 'chat_bot_page.dart';

class BerandaPage extends StatefulWidget {
  const BerandaPage({super.key});

  @override
  State<BerandaPage> createState() => _BerandaPageState();
}

class _BerandaPageState extends State<BerandaPage> {
  // === Design System Colors ===
  static const Color primaryColor = Color(0xFF8B5CF6);
  static const Color secondaryColor = Color(0xFFC4B5FD);
  static const Color backgroundColor = Color(0xFFF8FAFC);
  static const Color textPrimary = Color(0xFF1E293B);
  static const Color textSecondary = Color(0xFF64748B);

  late Future<List<Map<String, dynamic>>> _popularModulesFuture;
  String? _confirmedFinishedDate;
  Map<String, dynamic>? _profileData;
  bool _isProfileLoading = true;

  Future<void> _fetchProfile() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      if (mounted) {
        setState(() {
          _isProfileLoading = false;
        });
      }
      return;
    }
    try {
      final response = await Supabase.instance.client
          .from('profiles')
          .select()
          .eq('id', user.id)
          .maybeSingle();
      if (mounted) {
        setState(() {
          _profileData = response;
          _isProfileLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error fetching profile: $e');
      if (mounted) {
        setState(() {
          _isProfileLoading = false;
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _loadConfirmedFinishedDate();
    _loadPopularModules();
    _fetchProfile();
  }

  Future<void> _loadConfirmedFinishedDate() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        _confirmedFinishedDate = prefs.getString('confirmed_finished_date_${user.id}');
      });
    } catch (e) {
      debugPrint('Error loading confirmed finished date: $e');
    }
  }

  void _loadPopularModules() {
    _popularModulesFuture = _fetchPopularModules();
  }

  Future<List<Map<String, dynamic>>> _fetchPopularModules() async {
    if (!isSupabaseInitialized) {
      throw Exception("Supabase belum diinisialisasi.");
    }
    // Mengambil top 3 modul berdasarkan view_count tertinggi (paling banyak dibaca)
    // Hanya tampilkan modul yang view_count > 0
    final response = await Supabase.instance.client
        .from('modules')
        .select()
        .gt('view_count', 0)
        .order('view_count', ascending: false)
        .limit(3);
    return List<Map<String, dynamic>>.from(response);
  }

  // Increment view_count di Supabase saat user membuka modul
  Future<void> _incrementViewCount(String moduleId) async {
    try {
      await Supabase.instance.client.rpc(
        'increment_view_count',
        params: {'module_id': moduleId},
      );
    } catch (e) {
      debugPrint('Error incrementing view count: $e');
    }
  }

  IconData _getIconData(String? iconName) {
    switch (iconName) {
      case 'psychology_rounded':
        return Icons.psychology_rounded;
      case 'volunteer_activism_rounded':
        return Icons.volunteer_activism_rounded;
      case 'favorite_rounded':
        return Icons.favorite_rounded;
      case 'biotech_rounded':
        return Icons.biotech_rounded;
      case 'calendar_month_rounded':
        return Icons.calendar_month_rounded;
      case 'clean_hands_rounded':
        return Icons.clean_hands_rounded;
      case 'restaurant_rounded':
        return Icons.restaurant_rounded;
      case 'fitness_center_rounded':
        return Icons.fitness_center_rounded;
      case 'local_hospital_rounded':
        return Icons.local_hospital_rounded;
      default:
        return Icons.book_rounded;
    }
  }

  Map<String, dynamic> _getThemeColors(String category) {
    final cat = category.toLowerCase();
    if (cat.contains('pengetahuan')) {
      return {
        'gradient': [const Color(0xFFF5F3FF), const Color(0xFFEDE9FE)],
        'color': const Color(0xFF8B5CF6),
      };
    } else if (cat.contains('sikap')) {
      return {
        'gradient': [const Color(0xFFFFF1F2), const Color(0xFFFCE7F3)],
        'color': const Color(0xFFEC4899),
      };
    } else if (cat.contains('perilaku')) {
      return {
        'gradient': [const Color(0xFFECFDF5), const Color(0xFFD1FAE5)],
        'color': const Color(0xFF10B981),
      };
    } else {
      return {
        'gradient': [const Color(0xFFEFF6FF), const Color(0xFFDBEAFE)],
        'color': const Color(0xFF3B82F6),
      };
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: backgroundColor,
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1) Custom Header
              _buildHeader(),
              const SizedBox(height: 20),

            // Smart Tracker Widget
            _buildSmartTrackerWidget(context),
            const SizedBox(height: 20),

            // 2) Banner Promosi
            _buildPromoBanner(context),
            const SizedBox(height: 20),

            // AI Smart Banner
            _buildSmartAIBanner(context),
            const SizedBox(height: 24),

            // 3) Section "Mulai Dari Sini"
            _buildSectionTitle('Mulai dari sini'),
            const SizedBox(height: 12),
            _buildMenuGrid(context),
            const SizedBox(height: 24),

            // 4) Section "Topik Populer"
            _buildSectionTitle('Topik Populer'),
            const SizedBox(height: 12),
            _buildTopikPopuler(context),
            const SizedBox(height: 16),
          ],
        ),
      ),
     ),
    );
  }

  // ─────────────────────────────────────────────
  //  HEADER: Avatar + Sapaan + Notifikasi
  // ─────────────────────────────────────────────
  Widget _buildHeader() {
    final data = _profileData ?? {};
    final fullName = data['full_name'] as String? ?? 'Pengguna';
    final avatarUrl = data['avatar_url'] as String?;
    final initial = fullName.trim().isNotEmpty ? fullName.trim()[0].toUpperCase() : 'U';
    final hasAvatar = avatarUrl != null && avatarUrl.isNotEmpty;

    return Row(
      children: [
        // Avatar
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: secondaryColor, width: 2.5),
            boxShadow: [
              BoxShadow(
                color: primaryColor.withValues(alpha: 0.15),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: CircleAvatar(
            radius: 24,
            backgroundColor: const Color(0xFFEDE9FE),
            backgroundImage: hasAvatar ? NetworkImage(avatarUrl) : null,
            onBackgroundImageError: hasAvatar ? (_, _) {} : null,
            child: !hasAvatar
                ? Text(
                    initial,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                    ),
                  )
                : null,
          ),
        ),
        const SizedBox(width: 12),

        // Sapaan dua baris
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Halo, Selamat Datang, $fullName!',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              const Text(
                'Semangat belajar hari ini!',
                style: TextStyle(
                  fontSize: 14,
                  color: textSecondary,
                ),
              ),
            ],
          ),
        ),

        // Ikon Kalender Siklus
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: IconButton(
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const TrackerDetailPage()),
              );
              _fetchProfile();
            },
            icon: const Icon(
              Icons.calendar_month_rounded,
              color: Color(0xFFEC4899),
              size: 26,
            ),
          ),
        ),
        const SizedBox(width: 8),

        // Ikon notifikasi
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.notifications_none_outlined,
              color: textPrimary,
              size: 26,
            ),
          ),
        ),
      ],
    );
  }

  void _showFirstHaidDialog(BuildContext outerContext, String userId) {
    showDialog(
      context: outerContext,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: const Text(
            'Selamat Memasuki Fase Baru! 🌸',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFF581C87),
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.spa_rounded,
                color: Color(0xFFEC4899),
                size: 64,
              ),
              const SizedBox(height: 16),
              const Text(
                'Menstruasi pertama (menarche) adalah tanda sehat bahwa tubuhmu sedang tumbuh dewasa secara alami. Jangan khawatir, BloomFem akan mendampingimu untuk mencatat dan memahami siklus sehatmu!\n\nKami akan mengeset perkiraan awal haid selama 5 hari dengan siklus 28 hari. Kamu bisa menyesuaikannya kapan saja.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF1E293B),
                  height: 1.4,
                ),
              ),
            ],
          ),
          actions: [
            Center(
              child: ElevatedButton(
                onPressed: () async {
                  Navigator.pop(dialogContext); // Close dialog
                  try {
                    final today = TimeHelper.nowWIB();
                    final todayStr = today.toIso8601String().split('T')[0];
                    await Supabase.instance.client
                        .from('profiles')
                        .update({
                          'has_menstruated': true,
                          'last_period_date': todayStr,
                          'avg_period_duration': 5,
                          'avg_cycle_length': 28,
                        })
                        .eq('id', userId);

                    // Seed 5 days of period to daily_logs
                    final List<Map<String, dynamic>> logsToUpsert = [];
                    final start = DateTime(today.year, today.month, today.day);
                    for (int i = 0; i < 5; i++) {
                      final date = start.add(Duration(days: i));
                      logsToUpsert.add({
                        'user_id': userId,
                        'log_date': date.toIso8601String().split('T')[0],
                        'is_period_day': true,
                        'symptoms': ['Menstruasi (Haid)'],
                      });
                    }

                    await Supabase.instance.client
                        .from('daily_logs')
                        .upsert(logsToUpsert, onConflict: 'user_id,log_date');

                    if (outerContext.mounted) {
                      ToastHelper.showSuccess(outerContext, 'Selamat! Pelacakan siklus haid pertamamu telah aktif. 🌸');
                      _fetchProfile();
                    }
                  } catch (e) {
                    debugPrint('Failed to initialize first period: $e');
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF8B5CF6),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  'Mulai Pelacakan',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        );
      },
    );
  }


  void _showMenorrhagiaDialog(BuildContext outerContext) {
    showDialog(
      context: outerContext,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 28),
              SizedBox(width: 8),
              Text(
                'Catatan Medis Penting',
                style: TextStyle(color: Color(0xFF581C87), fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: const Text(
            'Menstruasi yang berlangsung lebih dari 7 hari (dikenal secara medis sebagai Menoragia) sangat umum dialami oleh remaja karena kadar hormon tubuh yang masih berkembang dan tidak stabil.\n\nNamun, jika haid terus berlanjut secara berlebihan, disertai rasa nyeri yang hebat, atau tubuh terasa lemas/pusing, disarankan untuk berdiskusi dengan orang tua dan berkonsultasi dengan dokter untuk memastikan kesehatanmu ya, Bloom! 🌸',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Color(0xFF1E293B), height: 1.4),
          ),
          actions: [
            Center(
              child: ElevatedButton(
                onPressed: () => Navigator.pop(dialogContext),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF8B5CF6),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: const Text('Paham', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _handleExtendPeriod(BuildContext context, String userId, int newDuration, DateTime today) async {
    try {
      // 1. Update avg_period_duration in profiles
      await Supabase.instance.client
          .from('profiles')
          .update({'avg_period_duration': newDuration})
          .eq('id', userId);

      // 2. Upsert daily log for today to check "Menstruasi (Haid)"
      final dateStr = today.toIso8601String().split('T')[0];
      
      final logResponse = await Supabase.instance.client
          .from('daily_logs')
          .select('symptoms, mood')
          .eq('user_id', userId)
          .eq('log_date', dateStr)
          .maybeSingle();

      List<String> symptoms = ['Menstruasi (Haid)'];
      String mood = 'Sensitif'; // default if none
      
      if (logResponse != null) {
        mood = logResponse['mood'] as String? ?? 'Sensitif';
        final existing = logResponse['symptoms'] as List<dynamic>?;
        if (existing != null) {
          symptoms = existing.map((e) => e.toString()).toList();
          if (!symptoms.contains('Menstruasi (Haid)')) {
            symptoms.add('Menstruasi (Haid)');
          }
        }
      }

      await Supabase.instance.client.from('daily_logs').upsert({
        'user_id': userId,
        'log_date': dateStr,
        'mood': mood,
        'symptoms': symptoms,
      }, onConflict: 'user_id,log_date');

      if (context.mounted) {
        ToastHelper.showSuccess(context, 'Masa haid berhasil diperpanjang! 🌸');
        _fetchProfile();
        
        // If duration > 7 days, show Menorrhagia warning dialog
        if (newDuration > 7) {
          _showMenorrhagiaDialog(context);
        }
      }
    } catch (e) {
      debugPrint('Failed to extend period: $e');
    }
  }

  Future<void> _showStartPeriodConfirmation(BuildContext outerContext, String userId, String todayStr, int avgPeriodDuration) async {
    final bool? confirm = await showDialog<bool>(
      context: outerContext,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: const Row(
            children: [
              Icon(Icons.water_drop_rounded, color: Color(0xFFEC4899), size: 28),
              SizedBox(width: 8),
              Text(
                'Konfirmasi Haid',
                style: TextStyle(
                  color: Color(0xFF581C87),
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ],
          ),
          content: const Text(
            'Apakah kamu yakin ingin mencatat bahwa menstruasi (haid) kamu dimulai hari ini?',
            style: TextStyle(fontSize: 14, color: Colors.black87),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text(
                'Batal',
                style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFEC4899),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
              child: const Text(
                'Ya, Yakin',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      try {
        await Supabase.instance.client
            .from('profiles')
            .update({'last_period_date': todayStr})
            .eq('id', userId);

        final today = TimeHelper.nowWIB();
        final start = DateTime(today.year, today.month, today.day);
        final List<Map<String, dynamic>> logsToUpsert = [];
        for (int i = 0; i < avgPeriodDuration; i++) {
          final date = start.add(Duration(days: i));
          logsToUpsert.add({
            'user_id': userId,
            'log_date': date.toIso8601String().split('T')[0],
            'is_period_day': true,
            'symptoms': ['Menstruasi (Haid)'],
          });
        }

        await Supabase.instance.client
            .from('daily_logs')
            .upsert(logsToUpsert, onConflict: 'user_id,log_date');

        if (outerContext.mounted) {
          ToastHelper.showSuccess(outerContext, 'Mulai haid berhasil dicatat! 🌸');
          _fetchProfile();
        }
      } catch (e) {
        debugPrint('Failed to start period early: $e');
        if (outerContext.mounted) {
          ToastHelper.showError(outerContext, 'Gagal mencatat haid. Coba lagi ya!');
        }
      }
    }
  }

  void _showShortPeriodAdviceDialog(BuildContext outerContext, int duration) {
    showDialog(
      context: outerContext,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: const Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 28),
              SizedBox(width: 8),
              Text(
                'Saran Kesehatan',
                style: TextStyle(
                  color: Color(0xFF581C87),
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ],
          ),
          content: Text(
            'Haidmu kali ini berlangsung kurang dari 3 hari ($duration hari). Durasi haid yang singkat bisa dipengaruhi oleh stres, perubahan berat badan, atau hormon.\n\nDisarankan untuk berkonsultasi dengan Asisten Cerdas BloomFem untuk analisis dan penjelasan lebih lanjut.',
            style: const TextStyle(fontSize: 14, color: Colors.black87),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text(
                'Tutup',
                style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext); // Close dialog
                Navigator.push(
                  outerContext,
                  MaterialPageRoute(
                    builder: (context) => ChatBotPage(
                      initialMessage: 'Halo BloomFem AI, durasi haidku kali ini sangat singkat, yaitu hanya $duration hari. Apakah hal ini normal untuk remaja perempuan, dan apa saja faktor penyebabnya?',
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF8B5CF6),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
              child: const Text(
                'Tanya Asisten AI',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSmartTrackerWidget(BuildContext context) {
    if (_isProfileLoading) {
      return const SizedBox(
        height: 120,
        child: Center(
          child: CircularProgressIndicator(color: primaryColor),
        ),
      );
    }

    if (_profileData == null || _profileData!.isEmpty) {
      return const SizedBox();
    }

    final data = _profileData!;
    final String userId = data['id'] as String;
    final bool? hasMenstruated = data['has_menstruated'] as bool?;
    
    if (hasMenstruated == null) {
      return const SizedBox();
    }

    String cardTitle = '';
    String cardSubtitle = '';
    String buttonText = 'Lihat Detail Kalender';
    
    final String? lastPeriodDateStr = data['last_period_date'] as String?;
    final int avgCycleLength = data['avg_cycle_length'] as int? ?? 28;
    final int avgPeriodDuration = data['avg_period_duration'] as int? ?? 5;
    
    DateTime? lastPeriodDate;
    int difference = 0;
    bool isCurrentlyInPeriod = false;
    int currentPeriodDay = 0;
    bool isConfirmationDay = false;
    
    final today = DateTime(TimeHelper.nowWIB().year, TimeHelper.nowWIB().month, TimeHelper.nowWIB().day);
    final todayStr = today.toIso8601String().split('T')[0];

    if (lastPeriodDateStr != null) {
      lastPeriodDate = DateTime.tryParse(lastPeriodDateStr);
      if (lastPeriodDate != null) {
        DateTime predictionDate = lastPeriodDate.add(Duration(days: avgCycleLength));
        
        // Fast-forward prediction date to the current/next cycle if it's completely in the past
        while (predictionDate.add(Duration(days: avgPeriodDuration)).isBefore(today)) {
          predictionDate = predictionDate.add(Duration(days: avgCycleLength));
        }

        final target = DateTime(predictionDate.year, predictionDate.month, predictionDate.day);
        difference = target.difference(today).inDays;

        final bool isAlreadyConfirmed = _confirmedFinishedDate == todayStr;

        // Check if today falls in the active period
        currentPeriodDay = today.difference(lastPeriodDate).inDays + 1;
        isCurrentlyInPeriod = (currentPeriodDay >= 1 && currentPeriodDay <= avgPeriodDuration) && !isAlreadyConfirmed;

        // Check if today is the day after the predicted period (confirmation phase)
        final predictedEnd = lastPeriodDate.add(Duration(days: avgPeriodDuration));
        isConfirmationDay = !isAlreadyConfirmed && 
            (today.isAtSameMomentAs(predictedEnd) || 
            (today.isAfter(predictedEnd) && today.isBefore(predictedEnd.add(const Duration(days: 2)))));
      }
    }

    Widget? customButton;

    if (hasMenstruated == false) {
      cardTitle = 'Fase Persiapan 🌸';
      cardSubtitle = 'Yuk catat mood dan gejalamu hari ini untuk mengenali tubuhmu!';
      customButton = ElevatedButton.icon(
        onPressed: () => _showFirstHaidDialog(context, userId),
        icon: const Icon(Icons.favorite_rounded, size: 16),
        label: const Text('Saya Mendapat Haid Pertama!'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white.withValues(alpha: 0.8),
          foregroundColor: const Color(0xFFEC4899),
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
        ),
      );
    } else if (isCurrentlyInPeriod) {
      cardTitle = 'Menstruasi: Hari ke-$currentPeriodDay 🌸';
      cardSubtitle = 'Tetap jaga kebersihan tubuh, minum cukup air, dan istirahat yang cukup ya!';
      customButton = ElevatedButton.icon(
        onPressed: () async {
          final bool? confirm = await showDialog<bool>(
            context: context,
            builder: (context) {
              return AlertDialog(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                title: const Row(
                  children: [
                    Icon(Icons.check_circle_rounded, color: Color(0xFFEC4899), size: 28),
                    SizedBox(width: 8),
                    Text(
                      'Selesai Haid',
                      style: TextStyle(
                        color: Color(0xFF581C87),
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
                content: const Text(
                  'Apakah kamu yakin menstruasi (haid) kamu sudah selesai hari ini?',
                  style: TextStyle(fontSize: 14, color: Colors.black87),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text(
                      'Batal',
                      style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context, true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFEC4899),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Ya, Sudah Bersih',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              );
            },
          );

          if (confirm != true) return;

          try {
            // If duration is >= 3 days, update avg_period_duration. If less, DO NOT update.
            if (currentPeriodDay >= 3) {
              await Supabase.instance.client
                  .from('profiles')
                  .update({'avg_period_duration': currentPeriodDay})
                  .eq('id', userId);
            }

            final prefs = await SharedPreferences.getInstance();
            await prefs.setString('confirmed_finished_date_$userId', todayStr);

            if (lastPeriodDate != null) {
              final endDateForCleanup = lastPeriodDate.add(const Duration(days: 14)).toIso8601String().split('T')[0];
              await Supabase.instance.client
                  .from('daily_logs')
                  .update({
                    'is_period_day': false,
                    'symptoms': [],
                  })
                  .eq('user_id', userId)
                  .gt('log_date', todayStr)
                  .lte('log_date', endDateForCleanup);
            }

            setState(() {
              _confirmedFinishedDate = todayStr;
            });

            if (context.mounted) {
              ToastHelper.showSuccess(context, 'Haid telah ditandai selesai! 🌸');
              _fetchProfile();
              if (currentPeriodDay < 3) {
                _showShortPeriodAdviceDialog(context, currentPeriodDay);
              }
            }
          } catch (e) {
            debugPrint('Failed to update period duration: $e');
          }
        },
        icon: const Icon(Icons.clean_hands_rounded, size: 16),
        label: const Text('Sudah Bersih? (Akhiri Sekarang)'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white.withValues(alpha: 0.8),
          foregroundColor: const Color(0xFFEC4899),
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
        ),
      );
    } else if (isConfirmationDay) {
      cardTitle = 'Konfirmasi Selesai Haid? 🌸';
      cardSubtitle = 'Berdasarkan prediksimu, haidmu seharusnya sudah selesai. Apakah haidmu masih berlangsung hari ini?';
      customButton = Row(
        children: [
          ElevatedButton.icon(
            onPressed: () => _handleExtendPeriod(context, userId, avgPeriodDuration + 1, today),
            icon: const Icon(Icons.favorite_rounded, size: 16),
            label: const Text('Masih Haid'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white.withValues(alpha: 0.8),
              foregroundColor: const Color(0xFFEC4899),
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton.icon(
            onPressed: () async {
              try {
                final prefs = await SharedPreferences.getInstance();
                await prefs.setString('confirmed_finished_date_$userId', todayStr);
                setState(() {
                  _confirmedFinishedDate = todayStr;
                });
                if (context.mounted) {
                  ToastHelper.showSuccess(context, 'Haid telah ditandai selesai! 🌸');
                  _fetchProfile();
                }
              } catch (e) {
                debugPrint('Failed to save confirmation: $e');
              }
            },
            icon: const Icon(Icons.check_circle_rounded, size: 16),
            label: const Text('Sudah Selesai'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white.withValues(alpha: 0.8),
              foregroundColor: const Color(0xFF10B981),
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      );
    } else {
      // Prediction/Late States
      if (lastPeriodDateStr != null) {
        if (difference > 0) {
          cardTitle = 'Prediksi Haid: H-$difference ⏳';
          cardSubtitle = 'Haid berikutnya diperkirakan akan mulai dalam $difference hari.';
          if (difference <= 7) {
            customButton = ElevatedButton.icon(
              onPressed: () => _showStartPeriodConfirmation(context, userId, todayStr, avgPeriodDuration),
              icon: const Icon(Icons.water_drop_rounded, size: 16),
              label: const Text('Mulai Haid Hari Ini?'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white.withValues(alpha: 0.8),
                foregroundColor: const Color(0xFFEC4899),
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              ),
            );
          }
        } else if (difference == 0) {
          cardTitle = 'Prediksi Haid: Hari Ini! 🌸';
          cardSubtitle = 'Haid diprediksi mulai hari ini. Bersiaplah dan tetap tenang!';
          customButton = ElevatedButton.icon(
            onPressed: () => _showStartPeriodConfirmation(context, userId, todayStr, avgPeriodDuration),
            icon: const Icon(Icons.water_drop_rounded, size: 16),
            label: const Text('Sudah Mulai Haid?'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white.withValues(alpha: 0.8),
              foregroundColor: const Color(0xFFEC4899),
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
          );
        } else {
          final lateDays = difference.abs();
          cardTitle = 'Terlambat $lateDays Hari ⚠️';
          cardSubtitle = 'Haid terlambat $lateDays hari. Jangan panik, tetap tenang!';
          customButton = ElevatedButton.icon(
            onPressed: () => _showStartPeriodConfirmation(context, userId, todayStr, avgPeriodDuration),
            icon: const Icon(Icons.water_drop_rounded, size: 16),
            label: const Text('Sudah Haid Hari Ini?'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white.withValues(alpha: 0.8),
              foregroundColor: const Color(0xFFEC4899),
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
          );
        }
      } else {
        cardTitle = 'Fase Persiapan 🌸';
        cardSubtitle = 'Yuk catat mood dan gejalamu hari ini untuk mengenali tubuhmu!';
      }
    }

    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFBCFE8), Color(0xFFE9D5FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFEC4899).withValues(alpha: 0.15),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const TrackerDetailPage()),
            );
            _fetchProfile();
          },
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        cardTitle,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF581C87),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        cardSubtitle,
                        style: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF6B21A8),
                          height: 1.4,
                        ),
                      ),
                      if (customButton != null) ...[
                        const SizedBox(height: 12),
                        customButton,
                      ],
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Text(
                            buttonText,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF9D178D),
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(
                            Icons.arrow_forward_rounded,
                            size: 14,
                            color: Color(0xFF9D178D),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.track_changes_rounded,
                    color: Color(0xFFD946EF),
                    size: 32,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────
  //  BANNER PROMOSI (Interaktif)

  // ─────────────────────────────────────────────
  Widget _buildPromoBanner(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          MainScreen.of(context)?.navigateToPage(1, categoryIndex: 0); // Pindah ke tab Belajar (Semua)
        },
        borderRadius: BorderRadius.circular(24),
        child: Ink(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF8B5CF6), Color(0xFF7C3AED)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: primaryColor.withValues(alpha: 0.3),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            children: [
              // Teks motivasi
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Yuk, tingkatkan',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      'Pengetahuan, Sikap,\ndan Perilaku Sehatmu!',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'Mulai Belajar →',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: primaryColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Ilustrasi
              Expanded(
                flex: 2,
                child: Container(
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.auto_stories_rounded, size: 48, color: Colors.white),
                        SizedBox(height: 6),
                        Icon(Icons.menu_book_outlined, size: 24, color: Colors.white70),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────
  //  SECTION TITLE
  // ─────────────────────────────────────────────
  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: textPrimary,
      ),
    );
  }

  // ─────────────────────────────────────────────
  //  SMART AI BANNER
  // ─────────────────────────────────────────────
  Widget _buildSmartAIBanner(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ChatBotPage()),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF8B5CF6), Color(0xFFD946EF)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFD946EF).withValues(alpha: 0.3),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.smart_toy_rounded, color: Color(0xFF8B5CF6), size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Asisten Cerdas BloomFem',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Punya pertanyaan privasi? Tanya dan curhat aman di sini!',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.9),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white, size: 16),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────
  //  GRID MENU "Mulai dari sini" — 3 Cards (Interaktif)
  // ─────────────────────────────────────────────
  Widget _buildMenuGrid(BuildContext context) {
    final List<_MenuCardData> menus = [
      _MenuCardData(
        icon: Icons.psychology_rounded,
        title: 'Pengetahuan',
        subtitle: 'Pahami tubuhmu',
        bgColor: const Color(0xFFEDE9FE), // ungu pastel
        iconColor: const Color(0xFF8B5CF6),
        categoryIndex: 1, // Kategori filter Pengetahuan
      ),
      _MenuCardData(
        icon: Icons.favorite_rounded,
        title: 'Sikap Positif',
        subtitle: 'Jaga pikiranmu',
        bgColor: const Color(0xFFFCE7F3), // pink pastel
        iconColor: const Color(0xFFEC4899),
        categoryIndex: 2, // Kategori filter Sikap
      ),
      _MenuCardData(
        icon: Icons.volunteer_activism_rounded,
        title: 'Perilaku Sehat',
        subtitle: 'Hidup lebih baik',
        bgColor: const Color(0xFFD1FAE5), // hijau pastel
        iconColor: const Color(0xFF10B981),
        categoryIndex: 3, // Kategori filter Perilaku
      ),
    ];

    return Row(
      children: menus.map((menu) {
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(
              left: menus.indexOf(menu) == 0 ? 0 : 6,
              right: menus.indexOf(menu) == menus.length - 1 ? 0 : 6,
            ),
            child: _buildMenuCard(context, menu),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildMenuCard(BuildContext context, _MenuCardData data) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          MainScreen.of(context)?.navigateToPage(1, categoryIndex: data.categoryIndex);
        },
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
          decoration: BoxDecoration(
            color: data.bgColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: data.iconColor.withValues(alpha: 0.12),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Ikon dalam lingkaran
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.7),
                  shape: BoxShape.circle,
                ),
                child: Icon(data.icon, color: data.iconColor, size: 26),
              ),
              const SizedBox(height: 10),
              Text(
                data.title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                data.subtitle,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 11,
                  color: textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────
  //  TOPIK POPULER — Horizontal ListView (Dinamis dari Supabase)
  // ─────────────────────────────────────────────
  Widget _buildTopikPopuler(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _popularModulesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(
            height: 190,
            child: Center(
              child: CircularProgressIndicator(color: primaryColor),
            ),
          );
        } else if (snapshot.hasError) {
          return SizedBox(
            height: 190,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Gagal memuat topik populer: ${snapshot.error.toString().replaceAll('Exception: ', '')}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.redAccent, fontSize: 13),
                ),
              ),
            ),
          );
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return SizedBox(
            height: 190,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.trending_up_rounded,
                    size: 48,
                    color: Colors.grey.shade300,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Belum ada topik populer saat ini',
                    style: TextStyle(
                      color: textSecondary,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Mulai baca modul untuk melihat topik populer!',
                    style: TextStyle(
                      color: Color(0xFF94A3B8),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        final modules = snapshot.data!;

        return SizedBox(
          height: 190,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: modules.length,
            itemBuilder: (context, index) {
              final module = modules[index];
              final String title = module['title'] ?? '';
              final String category = module['category'] ?? 'Edukasi';
              final String duration = module['duration'] ?? '5 menit';
              final String iconName = module['icon_name'] ?? '';

              final themeColors = _getThemeColors(category);
              final iconData = _getIconData(iconName);

              return GestureDetector(
                onTap: () {
                  final modId = module['id'] as String?;
                  if (modId != null) {
                    _incrementViewCount(modId);
                  }
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DetailModulPage(module: module),
                    ),
                  );
                },
                child: Container(
                  width: 180,
                  margin: EdgeInsets.only(right: index < modules.length - 1 ? 12 : 0),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: themeColors['gradient']!,
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Ikon ilustrasi
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.8),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Icon(iconData, color: themeColors['color'], size: 24),
                        ),
                        const SizedBox(height: 14),

                        // Judul
                        Text(
                          title,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: textPrimary,
                            height: 1.3,
                          ),
                        ),
                        const Spacer(),

                        // Durasi + tipe konten
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.7),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  '$duration • Artikel',
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: themeColors['color'],
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6),
                              Icon(
                                Icons.visibility_rounded,
                                size: 12,
                                color: themeColors['color']!.withValues(alpha: 0.6),
                              ),
                              const SizedBox(width: 2),
                              Text(
                                '${module['view_count'] ?? 0}',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: themeColors['color']!.withValues(alpha: 0.6),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────
//  Data class
// ─────────────────────────────────────────────
class _MenuCardData {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color bgColor;
  final Color iconColor;
  final int categoryIndex;

  _MenuCardData({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.bgColor,
    required this.iconColor,
    required this.categoryIndex,
  });
}
