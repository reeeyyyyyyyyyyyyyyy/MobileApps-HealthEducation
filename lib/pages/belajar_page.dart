import 'package:flutter/material.dart';

class BelajarPage extends StatefulWidget {
  const BelajarPage({super.key});

  @override
  State<BelajarPage> createState() => _BelajarPageState();
}

class _BelajarPageState extends State<BelajarPage> {
  // === Design System Colors ===
  static const Color primaryColor = Color(0xFF8B5CF6);
  static const Color backgroundColor = Color(0xFFF8FAFC);
  static const Color textPrimary = Color(0xFF1E293B);
  static const Color textSecondary = Color(0xFF64748B);

  int _selectedChipIndex = 0;

  final List<String> _filterLabels = [
    'Semua',
    'Tubuhku',
    'Fakta Penting',
    'Kesehatan',
  ];

  // Data artikel contoh
  final List<_ArtikelData> _artikelList = [
    _ArtikelData(
      title: 'Mengenal Organ Reproduksi',
      subtitle: '5 menit • Artikel',
      icon: Icons.biotech_rounded,
      iconBgColor: const Color(0xFFEDE9FE),
      iconColor: const Color(0xFF8B5CF6),
    ),
    _ArtikelData(
      title: 'Siklus Menstruasi 101',
      subtitle: '7 menit • Video',
      icon: Icons.calendar_month_rounded,
      iconBgColor: const Color(0xFFFCE7F3),
      iconColor: const Color(0xFFEC4899),
    ),
    _ArtikelData(
      title: 'Cara Menjaga Kebersihan',
      subtitle: '4 menit • Artikel',
      icon: Icons.clean_hands_rounded,
      iconBgColor: const Color(0xFFD1FAE5),
      iconColor: const Color(0xFF10B981),
    ),
    _ArtikelData(
      title: 'Nutrisi Saat Menstruasi',
      subtitle: '6 menit • Artikel',
      icon: Icons.restaurant_rounded,
      iconBgColor: const Color(0xFFFEF3C7),
      iconColor: const Color(0xFFF59E0B),
    ),
    _ArtikelData(
      title: 'Olahraga yang Aman',
      subtitle: '5 menit • Video',
      icon: Icons.fitness_center_rounded,
      iconBgColor: const Color(0xFFDBEAFE),
      iconColor: const Color(0xFF3B82F6),
    ),
    _ArtikelData(
      title: 'Kapan Harus ke Dokter?',
      subtitle: '3 menit • Artikel',
      icon: Icons.local_hospital_rounded,
      iconBgColor: const Color(0xFFFEE2E2),
      iconColor: const Color(0xFFEF4444),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header: Judul + Ikon Pencarian ──
            _buildHeader(),

            // ── Filter Chips ──
            _buildFilterChips(),
            const SizedBox(height: 8),

            // ── Daftar Artikel ──
            Expanded(child: _buildArtikelList()),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────
  //  HEADER
  // ─────────────────────────────────────────────
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(
        children: [
          // Judul kategori
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Pengetahuan',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: textPrimary,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Pahami tubuhmu lebih dalam',
                  style: TextStyle(
                    fontSize: 14,
                    color: textSecondary,
                  ),
                ),
              ],
            ),
          ),

          // Ikon pencarian
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
                Icons.search_rounded,
                color: textPrimary,
                size: 26,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  //  FILTER CHIPS (scroll horizontal)
  // ─────────────────────────────────────────────
  Widget _buildFilterChips() {
    return SizedBox(
      height: 48,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _filterLabels.length,
        itemBuilder: (context, index) {
          final bool isSelected = _selectedChipIndex == index;
          return Padding(
            padding: const EdgeInsets.only(right: 10),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedChipIndex = index;
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? primaryColor : Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: isSelected
                        ? primaryColor
                        : const Color(0xFFE2E8F0),
                    width: 1.5,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: primaryColor.withValues(alpha: 0.25),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ]
                      : [],
                ),
                child: Text(
                  _filterLabels[index],
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isSelected ? Colors.white : textSecondary,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ─────────────────────────────────────────────
  //  DAFTAR ARTIKEL (ListView.builder)
  // ─────────────────────────────────────────────
  Widget _buildArtikelList() {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      itemCount: _artikelList.length,
      itemBuilder: (context, index) {
        final artikel = _artikelList[index];
        return _buildArtikelCard(artikel);
      },
    );
  }

  Widget _buildArtikelCard(_ArtikelData data) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          // Kiri: Ikon / Ilustrasi
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: data.iconBgColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              data.icon,
              color: data.iconColor,
              size: 28,
            ),
          ),
          const SizedBox(width: 14),

          // Tengah: Judul + Subtitle
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data.title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  data.subtitle,
                  style: const TextStyle(
                    fontSize: 13,
                    color: textSecondary,
                  ),
                ),
              ],
            ),
          ),

          // Kanan: Chevron
          const Icon(
            Icons.chevron_right,
            color: Colors.grey,
            size: 24,
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  Data class
// ─────────────────────────────────────────────
class _ArtikelData {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color iconBgColor;
  final Color iconColor;

  _ArtikelData({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.iconBgColor,
    required this.iconColor,
  });
}
