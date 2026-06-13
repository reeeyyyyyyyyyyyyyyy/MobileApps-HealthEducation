import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../main.dart';
import 'detail_modul_page.dart';

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
  void initState() {
    super.initState();
    _loadPopularModules();
  }

  void _loadPopularModules() {
    _popularModulesFuture = _fetchPopularModules();
  }

  Future<List<Map<String, dynamic>>> _fetchPopularModules() async {
    if (!isSupabaseInitialized) {
      throw Exception("Supabase belum diinisialisasi.");
    }
    // Mengambil modul-modul secara dinamis dari database terurut dari buatan terbaru (created_at desc)
    // agar list selalu terintegrasi secara real-time dengan database.
    final response = await Supabase.instance.client
        .from('modules')
        .select()
        .order('created_at', ascending: false);
    return List<Map<String, dynamic>>.from(response);
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
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1) Custom Header
            _buildHeader(),
            const SizedBox(height: 20),

            // 2) Banner Promosi
            _buildPromoBanner(context),
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
          return const SizedBox(
            height: 190,
            child: Center(
              child: Text(
                'Tidak ada topik populer.',
                style: TextStyle(color: textSecondary, fontSize: 13),
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
                          child: Text(
                            '$duration • Artikel',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: themeColors['color'],
                            ),
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
