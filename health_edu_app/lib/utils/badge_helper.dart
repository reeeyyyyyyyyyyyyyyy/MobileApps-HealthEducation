import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Definisi 5 lencana sesuai spesifikasi BLMF-005.
/// Seluruh pengecekan dilakukan di sisi Dart, bukan di SQL/trigger Supabase.
class BadgeHelper {
  // Daftar badge definitions
  static const List<BadgeDefinition> allBadges = [
    BadgeDefinition(
      id: 'langkah_pertama',
      name: 'Langkah Pertama',
      description: 'Lulus 1 kuis perdana',
      icon: Icons.emoji_events_rounded,
      color: Color(0xFFF59E0B),
      bgColor: Color(0xFFFEF3C7),
    ),
    BadgeDefinition(
      id: 'si_paling_paham',
      name: 'Si Paling Paham',
      description: 'Lulus kuis dengan nilai sempurna (100)',
      icon: Icons.workspace_premium_rounded,
      color: Color(0xFFEC4899),
      bgColor: Color(0xFFFCE7F3),
    ),
    BadgeDefinition(
      id: 'kutu_buku',
      name: 'Kutu Buku',
      description: 'Telah membaca 5 modul',
      icon: Icons.menu_book_rounded,
      color: Color(0xFF10B981),
      bgColor: Color(0xFFD1FAE5),
    ),
    BadgeDefinition(
      id: 'kolektor_xp',
      name: 'Kolektor XP',
      description: 'Mencapai total 1000 XP',
      icon: Icons.bolt_rounded,
      color: Color(0xFF8B5CF6),
      bgColor: Color(0xFFEDE9FE),
    ),
    BadgeDefinition(
      id: 'pejuang_tangguh',
      name: 'Pejuang Tangguh',
      description: 'Lulus kuis setelah pernah gagal di kuis yang sama',
      icon: Icons.shield_rounded,
      color: Color(0xFF3B82F6),
      bgColor: Color(0xFFDBEAFE),
    ),
  ];

  /// Periksa dan berikan lencana setelah user lulus kuis.
  ///
  /// [quizId]       — ID kuis yang baru saja dilalui
  /// [score]        — skor yang diperoleh (0–100)
  /// [newTotalXp]   — total XP user setelah update
  /// [hadFailedBefore] — apakah user pernah gagal di kuis ini sebelumnya
  ///
  /// Returns list of badge names yang baru saja di-unlock.
  static Future<List<String>> checkAndAwardBadges({
    required String quizId,
    required int score,
    required int newTotalXp,
    required bool hadFailedBefore,
  }) async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return [];

    final List<String> newlyUnlocked = [];

    try {
      // 1. Fetch existing badges milik user
      final existingBadgesResponse = await Supabase.instance.client
          .from('user_badges')
          .select('badge_name')
          .eq('user_id', user.id);
      final existingBadgeNames = Set<String>.from(
        (existingBadgesResponse as List).map((r) => r['badge_name'] as String),
      );

      // 2. Fetch jumlah kuis yang pernah di-pass oleh user
      final passedQuizzesResponse = await Supabase.instance.client
          .from('user_quizzes')
          .select('quiz_id')
          .eq('user_id', user.id)
          .eq('status', 'passed');
      final passedCount = (passedQuizzesResponse as List).length;

      // 3. Baca jumlah modul yang sudah dibaca dari SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final readModules = prefs.getStringList('completed_modules_list') ?? [];
      final readModulesCount = readModules.length;

      // ═══ PENGECEKAN SETIAP LENCANA ═══

      // 1. Langkah Pertama — Lulus 1 kuis perdana
      if (!existingBadgeNames.contains('langkah_pertama') && passedCount >= 1) {
        await _insertBadge(user.id, 'langkah_pertama');
        newlyUnlocked.add('Langkah Pertama');
      }

      // 2. Si Paling Paham — Lulus kuis dengan nilai 100
      if (!existingBadgeNames.contains('si_paling_paham') && score == 100) {
        await _insertBadge(user.id, 'si_paling_paham');
        newlyUnlocked.add('Si Paling Paham');
      }

      // 3. Kutu Buku — Telah membaca 5 modul
      if (!existingBadgeNames.contains('kutu_buku') && readModulesCount >= 5) {
        await _insertBadge(user.id, 'kutu_buku');
        newlyUnlocked.add('Kutu Buku');
      }

      // 4. Kolektor XP — Mencapai total 1000 XP
      if (!existingBadgeNames.contains('kolektor_xp') && newTotalXp >= 1000) {
        await _insertBadge(user.id, 'kolektor_xp');
        newlyUnlocked.add('Kolektor XP');
      }

      // 5. Pejuang Tangguh — Lulus kuis setelah pernah gagal di kuis yang sama
      if (!existingBadgeNames.contains('pejuang_tangguh') && hadFailedBefore) {
        await _insertBadge(user.id, 'pejuang_tangguh');
        newlyUnlocked.add('Pejuang Tangguh');
      }
    } catch (e) {
      debugPrint('Error checking badges: $e');
    }

    return newlyUnlocked;
  }

  static Future<void> _insertBadge(String userId, String badgeName) async {
    await Supabase.instance.client.from('user_badges').insert({
      'user_id': userId,
      'badge_name': badgeName,
      'icon_name': badgeName, // Gunakan badgeName sebagai icon_name agar tidak NULL
    });
  }

  /// Fetch lencana yang dimiliki user, return list of badge_name.
  static Future<List<String>> fetchUserBadges() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return [];

    try {
      final response = await Supabase.instance.client
          .from('user_badges')
          .select('badge_name')
          .eq('user_id', user.id);
      return List<String>.from(
        (response as List).map((r) => r['badge_name'] as String),
      );
    } catch (e) {
      debugPrint('Error fetching user badges: $e');
      return [];
    }
  }

  /// Cari definisi badge berdasarkan badge_name (id).
  static BadgeDefinition? getDefinition(String badgeName) {
    try {
      return allBadges.firstWhere((b) => b.id == badgeName);
    } catch (_) {
      return null;
    }
  }
}

/// Data class untuk definisi lencana.
class BadgeDefinition {
  final String id;
  final String name;
  final String description;
  final IconData icon;
  final Color color;
  final Color bgColor;

  const BadgeDefinition({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.color,
    required this.bgColor,
  });
}
