import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class BerandaPage extends StatelessWidget {
  const BerandaPage({super.key});

  // === Design System Colors ===
  static const Color primaryColor = Color(0xFF8B5CF6);
  static const Color secondaryColor = Color(0xFFC4B5FD);
  static const Color backgroundColor = Color(0xFFF8FAFC);
  static const Color textPrimary = Color(0xFF1E293B);
  static const Color textSecondary = Color(0xFF64748B);

  Stream<Map<String, dynamic>> _profileStream() {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return const Stream.empty();
    return Supabase.instance.client
        .from('profiles')
        .stream(primaryKey: ['id'])
        .eq('id', user.id)
        .map((list) => list.isNotEmpty ? list.first : {});
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: backgroundColor,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1) Custom Header
            _buildHeader(),
            const SizedBox(height: 20),

            // 2) Banner Promosi
            _buildPromoBanner(),
            const SizedBox(height: 24),

            // 3) Section "Mulai Dari Sini"
            _buildSectionTitle('Mulai dari sini'),
            const SizedBox(height: 12),
            _buildMenuGrid(),
            const SizedBox(height: 24),

            // 4) Section "Topik Populer"
            _buildSectionTitle('Topik Populer'),
            const SizedBox(height: 12),
            _buildTopikPopuler(),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────
  //  HEADER: Avatar + Sapaan + Notifikasi
  // ─────────────────────────────────────────────
  Widget _buildHeader() {
    return StreamBuilder<Map<String, dynamic>>(
      stream: _profileStream(),
      builder: (context, snapshot) {
        final data = snapshot.data ?? {};
        final fullName = data['full_name'] as String? ?? 'Pengguna';
        final initial = fullName.trim().isNotEmpty ? fullName.trim()[0].toUpperCase() : 'U';

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
                child: Text(
                  initial,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: primaryColor,
                  ),
                ),
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
      },
    );
  }

  // ─────────────────────────────────────────────
  //  BANNER PROMOSI
  // ─────────────────────────────────────────────
  Widget _buildPromoBanner() {
    return Container(
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

          // Ilustrasi placeholder (karakter membaca buku)
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
  //  GRID MENU "Mulai dari sini" — 3 Cards
  // ─────────────────────────────────────────────
  Widget _buildMenuGrid() {
    final List<_MenuCardData> menus = [
      _MenuCardData(
        icon: Icons.psychology_rounded,
        title: 'Pengetahuan',
        subtitle: 'Pahami tubuhmu',
        bgColor: const Color(0xFFEDE9FE), // ungu pastel
        iconColor: const Color(0xFF8B5CF6),
      ),
      _MenuCardData(
        icon: Icons.favorite_rounded,
        title: 'Sikap Positif',
        subtitle: 'Jaga pikiranmu',
        bgColor: const Color(0xFFFCE7F3), // pink pastel
        iconColor: const Color(0xFFEC4899),
      ),
      _MenuCardData(
        icon: Icons.volunteer_activism_rounded,
        title: 'Perilaku Sehat',
        subtitle: 'Hidup lebih baik',
        bgColor: const Color(0xFFD1FAE5), // hijau pastel
        iconColor: const Color(0xFF10B981),
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
            child: _buildMenuCard(menu),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildMenuCard(_MenuCardData data) {
    return Container(
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
    );
  }

  // ─────────────────────────────────────────────
  //  TOPIK POPULER — Horizontal ListView
  // ─────────────────────────────────────────────
  Widget _buildTopikPopuler() {
    final List<_TopikData> topikList = [
      _TopikData(
        title: 'Apa itu Menstruasi?',
        subtitle: '5 menit • Artikel',
        gradientColors: [const Color(0xFFF5F3FF), const Color(0xFFEDE9FE)],
        icon: Icons.library_books_rounded,
        iconColor: const Color(0xFF8B5CF6),
      ),
      _TopikData(
        title: 'Kelola Nyeri\nSaat Haid',
        subtitle: '7 menit • Video',
        gradientColors: [const Color(0xFFFFF1F2), const Color(0xFFFCE7F3)],
        icon: Icons.play_circle_rounded,
        iconColor: const Color(0xFFEC4899),
      ),
      _TopikData(
        title: 'Mitos vs Fakta\nSeputar Haid',
        subtitle: '4 menit • Artikel',
        gradientColors: [const Color(0xFFECFDF5), const Color(0xFFD1FAE5)],
        icon: Icons.fact_check_rounded,
        iconColor: const Color(0xFF10B981),
      ),
    ];

    return SizedBox(
      height: 190,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: topikList.length,
        itemBuilder: (context, index) {
          final topik = topikList[index];
          return Container(
            width: 180,
            margin: EdgeInsets.only(right: index < topikList.length - 1 ? 12 : 0),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: topik.gradientColors,
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
                    child: Icon(topik.icon, color: topik.iconColor, size: 24),
                  ),
                  const SizedBox(height: 14),

                  // Judul
                  Text(
                    topik.title,
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
                    child: Text(
                      topik.subtitle,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: topik.iconColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  Data classes
// ─────────────────────────────────────────────
class _MenuCardData {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color bgColor;
  final Color iconColor;

  _MenuCardData({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.bgColor,
    required this.iconColor,
  });
}

class _TopikData {
  final String title;
  final String subtitle;
  final List<Color> gradientColors;
  final IconData icon;
  final Color iconColor;

  _TopikData({
    required this.title,
    required this.subtitle,
    required this.gradientColors,
    required this.icon,
    required this.iconColor,
  });
}
