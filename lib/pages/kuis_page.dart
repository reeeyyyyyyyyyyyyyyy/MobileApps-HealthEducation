import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../main.dart';
import 'play_kuis_page.dart';

class KuisPage extends StatefulWidget {
  const KuisPage({super.key});

  @override
  State<KuisPage> createState() => _KuisPageState();
}

class _KuisPageState extends State<KuisPage> {
  // === Design System Colors ===
  static const Color primaryColor = Color(0xFF8B5CF6);
  static const Color primaryDark = Color(0xFF7C3AED);
  static const Color backgroundColor = Color(0xFFF8FAFC);
  static const Color textPrimary = Color(0xFF1E293B);
  static const Color textSecondary = Color(0xFF64748B);

  int _selectedTab = 0;
  final List<String> _tabLabels = ['Pengetahuan', 'Sikap', 'Perilaku'];

  late Future<List<Map<String, dynamic>>> _quizzesFuture;

  // Data badges
  final List<_BadgeData> _badges = [
    _BadgeData(
      icon: Icons.local_fire_department_rounded,
      label: '7 Hari Belajar',
      color: const Color(0xFFF59E0B),
      bgColor: const Color(0xFFFEF3C7),
      unlocked: true,
    ),
    _BadgeData(
      icon: Icons.emoji_events_rounded,
      label: 'Kuis Pemula',
      color: const Color(0xFF8B5CF6),
      bgColor: const Color(0xFFEDE9FE),
      unlocked: true,
    ),
    _BadgeData(
      icon: Icons.explore_rounded,
      label: 'Penjelajah',
      color: const Color(0xFF10B981),
      bgColor: const Color(0xFFD1FAE5),
      unlocked: true,
    ),
    _BadgeData(
      icon: Icons.auto_awesome_rounded,
      label: 'Bintang Kelas',
      color: const Color(0xFFEC4899),
      bgColor: const Color(0xFFFCE7F3),
      unlocked: false,
    ),
    _BadgeData(
      icon: Icons.school_rounded,
      label: 'Ahli Materi',
      color: const Color(0xFF3B82F6),
      bgColor: const Color(0xFFDBEAFE),
      unlocked: false,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _loadQuizzes();
  }

  void _loadQuizzes() {
    setState(() {
      _quizzesFuture = _fetchQuizzes();
    });
  }

  Future<List<Map<String, dynamic>>> _fetchQuizzes() async {
    if (!isSupabaseInitialized) {
      throw Exception("Supabase belum diinisialisasi.");
    }
    // Join query to fetch module details to get the category
    final response = await Supabase.instance.client
        .from('quizzes')
        .select('*, modules (category)');
    return List<Map<String, dynamic>>.from(response);
  }

  Stream<Map<String, dynamic>> _profileStream() {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return const Stream.empty();
    return Supabase.instance.client
        .from('profiles')
        .stream(primaryKey: ['id'])
        .eq('id', user.id)
        .map((list) => list.isNotEmpty ? list.first : {});
  }

  List<Map<String, dynamic>> _filterQuizzes(List<Map<String, dynamic>> allQuizzes) {
    final selectedLabel = _tabLabels[_selectedTab];
    return allQuizzes.where((quiz) {
      final module = quiz['modules'] as Map<String, dynamic>?;
      final category = (module?['category'] ?? '').toString().toLowerCase();
      return category.contains(selectedLabel.toLowerCase());
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        color: backgroundColor,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              _buildHeader(),
              const SizedBox(height: 16),

              // Filter Tabs
              _buildFilterTabs(),
              const SizedBox(height: 20),

              // Banner Ajakan
              _buildBannerAjakan(),
              const SizedBox(height: 20),

              // Level Kamu (Real-time Profile Data)
              _buildSectionTitle('Level Kamu'),
              const SizedBox(height: 10),
              _buildLevelCardStream(),
              const SizedBox(height: 24),

              // Daftar Kuis
              _buildSectionTitle('Kuis Tersedia'),
              const SizedBox(height: 10),
              _buildQuizzesList(),
              const SizedBox(height: 24),

              // Pencapaian (Badges)
              _buildSectionTitle('Pencapaian'),
              const SizedBox(height: 10),
              _buildBadgesRow(),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────
  //  HEADER
  // ─────────────────────────────────────────────
  Widget _buildHeader() {
    return const Text(
      'Kuis & Gamifikasi',
      style: TextStyle(
        fontSize: 26,
        fontWeight: FontWeight.bold,
        color: textPrimary,
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
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: textPrimary,
      ),
    );
  }

  // ─────────────────────────────────────────────
  //  FILTER TABS: Pengetahuan / Sikap / Perilaku
  // ─────────────────────────────────────────────
  Widget _buildFilterTabs() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFEDE9FE),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: List.generate(_tabLabels.length, (index) {
          final bool isSelected = _selectedTab == index;
          return Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedTab = index;
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected ? primaryColor : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: primaryColor.withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : [],
                ),
                child: Text(
                  _tabLabels[index],
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isSelected ? Colors.white : primaryColor,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  // ─────────────────────────────────────────────
  //  BANNER AJAKAN
  // ─────────────────────────────────────────────
  Widget _buildBannerAjakan() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [primaryColor, primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
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
          // Teks ajakan
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Yuk, uji\npemahamanmu!',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Jawab kuis, dapatkan poin,\ndan naik level!',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withValues(alpha: 0.85),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),

          // Ilustrasi ikon
          Expanded(
            flex: 2,
            child: Container(
              height: 100,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.quiz_rounded, size: 40, color: Colors.white),
                    SizedBox(height: 4),
                    Icon(Icons.edit_note_rounded, size: 24, color: Colors.white70),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  //  LEVEL CARD (STREAMBUILDER)
  // ─────────────────────────────────────────────
  Widget _buildLevelCardStream() {
    return StreamBuilder<Map<String, dynamic>>(
      stream: _profileStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: primaryColor));
        }

        final data = snapshot.data ?? {};
        final totalXp = data['total_xp'] as int? ?? 0;
        final level = data['level'] as int? ?? 1;

        // Level calculations
        final int xpInCurrentLevel = totalXp % 100;
        final double progressValue = xpInCurrentLevel / 100.0;
        final int xpRemaining = 100 - xpInCurrentLevel;

        return Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              // Baris atas: ikon + teks level + XP
              Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [primaryColor, primaryDark],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: primaryColor.withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.star_rounded,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 14),

                  // Teks level
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Level $level',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          'Pembelajar Hebat',
                          style: TextStyle(
                            fontSize: 14,
                            color: textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // XP
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEDE9FE),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '$totalXp XP',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: primaryColor,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Progress bar
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: progressValue,
                  minHeight: 10,
                  backgroundColor: const Color(0xFFEDE9FE),
                  valueColor: const AlwaysStoppedAnimation<Color>(primaryColor),
                ),
              ),

              const SizedBox(height: 8),

              // Label progress
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '$xpInCurrentLevel% selesai',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: primaryColor.withValues(alpha: 0.8),
                    ),
                  ),
                  Text(
                    '$xpRemaining XP lagi ke Level ${level + 1}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  // ─────────────────────────────────────────────
  //  DYNAMIC QUIZZES LIST
  // ─────────────────────────────────────────────
  Widget _buildQuizzesList() {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _quizzesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: primaryColor));
        } else if (snapshot.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Gagal memuat kuis: ${snapshot.error}',
                style: const TextStyle(color: Colors.red),
              ),
            ),
          );
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(
            child: Text(
              'Belum ada kuis yang tersedia.',
              style: TextStyle(color: textSecondary),
            ),
          );
        }

        final filteredQuizzes = _filterQuizzes(snapshot.data!);

        if (filteredQuizzes.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(24.0),
              child: Text(
                'Tidak ada kuis di kategori ini.',
                style: TextStyle(color: textSecondary),
              ),
            ),
          );
        }

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: filteredQuizzes.length,
          itemBuilder: (context, index) {
            final quiz = filteredQuizzes[index];
            final quizId = quiz['id'] ?? '';
            final title = quiz['title'] ?? 'Kuis';
            final xpReward = quiz['xp_reward'] as int? ?? 100;

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  // Ikon kalender / Kuis
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: const Color(0xFFEDE9FE),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.quiz_rounded,
                      color: primaryColor,
                      size: 26,
                    ),
                  ),
                  const SizedBox(width: 14),

                  // Teks
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '+$xpReward XP',
                          style: const TextStyle(
                            fontSize: 13,
                            color: textSecondary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Tombol Mulai
                  ElevatedButton(
                    onPressed: () async {
                      final bool? quizCompleted = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PlayKuisPage(
                            quizId: quizId,
                            quizTitle: title,
                            xpReward: xpReward,
                          ),
                        ),
                      );

                      if (quizCompleted == true) {
                        // Refresh the view if needed
                        _loadQuizzes();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 22,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text(
                      'Mulai',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // ─────────────────────────────────────────────
  //  BADGES ROW (horizontal scroll)
  // ─────────────────────────────────────────────
  Widget _buildBadgesRow() {
    return SizedBox(
      height: 110,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _badges.length,
        itemBuilder: (context, index) {
          final badge = _badges[index];
          return Container(
            width: 90,
            margin: EdgeInsets.only(
              right: index < _badges.length - 1 ? 12 : 0,
            ),
            child: Column(
              children: [
                // Ikon bulat
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: badge.unlocked
                        ? badge.bgColor
                        : const Color(0xFFE2E8F0),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: badge.unlocked
                          ? badge.color.withValues(alpha: 0.3)
                          : const Color(0xFFCBD5E1),
                      width: 2.5,
                    ),
                    boxShadow: badge.unlocked
                        ? [
                            BoxShadow(
                              color: badge.color.withValues(alpha: 0.2),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ]
                        : [],
                  ),
                  child: Icon(
                    badge.unlocked ? badge.icon : Icons.lock_rounded,
                    color: badge.unlocked
                        ? badge.color
                        : const Color(0xFF94A3B8),
                    size: 26,
                  ),
                ),
                const SizedBox(height: 8),

                // Label
                Text(
                  badge.label,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: badge.unlocked ? textPrimary : textSecondary,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  Data class
// ─────────────────────────────────────────────
class _BadgeData {
  final IconData icon;
  final String label;
  final Color color;
  final Color bgColor;
  final bool unlocked;

  _BadgeData({
    required this.icon,
    required this.label,
    required this.color,
    required this.bgColor,
    required this.unlocked,
  });
}
