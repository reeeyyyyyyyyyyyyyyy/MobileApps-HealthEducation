import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../main.dart';
import 'detail_modul_page.dart';

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
    'Pengetahuan',
    'Sikap',
    'Perilaku',
  ];

  late Future<List<Map<String, dynamic>>> _modulesFuture;

  @override
  void initState() {
    super.initState();
    _loadModules();
  }

  void _loadModules() {
    setState(() {
      _modulesFuture = _fetchModules();
    });
  }

  Future<List<Map<String, dynamic>>> _fetchModules() async {
    if (!isSupabaseInitialized) {
      throw Exception("Supabase belum diinisialisasi.");
    }
    final response = await Supabase.instance.client
        .from('modules')
        .select()
        .order('created_at', ascending: false);
    return List<Map<String, dynamic>>.from(response);
  }

  List<Map<String, dynamic>> _filterModules(List<Map<String, dynamic>> allModules) {
    final selectedCategory = _filterLabels[_selectedChipIndex];
    if (selectedCategory == 'Semua') {
      return allModules;
    }
    return allModules.where((module) {
      final category = (module['category'] ?? '').toString().toLowerCase();
      return category.contains(selectedCategory.toLowerCase());
    }).toList();
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

  Map<String, Color> _getThemeColors(String category) {
    final cat = category.toLowerCase();
    if (cat.contains('pengetahuan')) {
      return {
        'bg': const Color(0xFFEDE9FE),
        'color': const Color(0xFF8B5CF6),
      };
    } else if (cat.contains('sikap')) {
      return {
        'bg': const Color(0xFFFCE7F3),
        'color': const Color(0xFFEC4899),
      };
    } else if (cat.contains('perilaku')) {
      return {
        'bg': const Color(0xFFD1FAE5),
        'color': const Color(0xFF10B981),
      };
    } else {
      return {
        'bg': const Color(0xFFDBEAFE),
        'color': const Color(0xFF3B82F6),
      };
    }
  }

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
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _modulesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: primaryColor),
          );
        } else if (snapshot.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.wifi_off_rounded,
                    color: Colors.redAccent,
                    size: 60,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Koneksi Gagal',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tidak dapat memuat modul. ${snapshot.error.toString().replaceAll('Exception: ', '')}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: textSecondary),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: _loadModules,
                    icon: const Icon(Icons.refresh_rounded),
                    label: const Text('Coba Lagi'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(
            child: Text(
              'Belum ada modul yang tersedia.',
              style: TextStyle(color: textSecondary),
            ),
          );
        }

        final filteredList = _filterModules(snapshot.data!);

        if (filteredList.isEmpty) {
          return const Center(
            child: Text(
              'Tidak ada modul dalam kategori ini.',
              style: TextStyle(color: textSecondary),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          itemCount: filteredList.length,
          itemBuilder: (context, index) {
            final module = filteredList[index];
            return _buildArtikelCard(module);
          },
        );
      },
    );
  }

  Widget _buildArtikelCard(Map<String, dynamic> module) {
    final title = module['title'] ?? '';
    final category = module['category'] ?? '';
    final duration = module['duration'] ?? '';
    final iconName = module['icon_name'] ?? '';
    final theme = _getThemeColors(category);

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DetailModulPage(module: module),
          ),
        );
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
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
                color: theme['bg'],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                _getIconData(iconName),
                color: theme['color'],
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
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: textPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '$duration • $category',
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
      ),
    );
  }
}
