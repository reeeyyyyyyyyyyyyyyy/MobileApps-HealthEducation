import 'package:flutter/material.dart';

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

              // Level Kamu
              _buildSectionTitle('Level Kamu'),
              const SizedBox(height: 10),
              _buildLevelCard(),
              const SizedBox(height: 20),

              // Kuis Harian
              _buildSectionTitle('Kuis Harian'),
              const SizedBox(height: 10),
              _buildKuisHarianCard(),
              const SizedBox(height: 20),

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
                  'Jawab kuis, dapatkan poin,\ndan naik level! 🚀',
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
                    Text('📝✨', style: TextStyle(fontSize: 22)),
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
  //  LEVEL CARD
  // ─────────────────────────────────────────────
  Widget _buildLevelCard() {
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
              // Ikon bintang dalam lingkaran ungu
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
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Level 4',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: textPrimary,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
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
                child: const Text(
                  '320 / 500 XP',
                  style: TextStyle(
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
              value: 0.64,
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
                '64% selesai',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: primaryColor.withValues(alpha: 0.8),
                ),
              ),
              const Text(
                '180 XP lagi ke Level 5',
                style: TextStyle(
                  fontSize: 12,
                  color: textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  //  KUIS HARIAN CARD
  // ─────────────────────────────────────────────
  Widget _buildKuisHarianCard() {
    return Container(
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
          // Ikon kalender
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: const Color(0xFFFEF3C7),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.calendar_today_rounded,
              color: Color(0xFFF59E0B),
              size: 26,
            ),
          ),
          const SizedBox(width: 14),

          // Teks
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Kuis Hari Ini',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: textPrimary,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  '10 soal • 5 menit',
                  style: TextStyle(
                    fontSize: 13,
                    color: textSecondary,
                  ),
                ),
              ],
            ),
          ),

          // Tombol Mulai
          ElevatedButton(
            onPressed: () {},
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
