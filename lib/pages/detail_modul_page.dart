import 'package:flutter/material.dart';

class DetailModulPage extends StatelessWidget {
  final Map<String, dynamic> module;

  const DetailModulPage({super.key, required this.module});

  static const Color primaryColor = Color(0xFF8B5CF6);
  static const Color textPrimary = Color(0xFF1E293B);
  static const Color textSecondary = Color(0xFF64748B);

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
    final category = module['category'] ?? 'Edukasi';
    final title = module['title'] ?? 'Judul Modul';
    final duration = module['duration'] ?? '5 menit';
    final content = module['content'] ?? '';
    final theme = _getThemeColors(category);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          category,
          style: const TextStyle(
            color: textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Badge Kategori & Durasi
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: theme['bg'],
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      category,
                      style: TextStyle(
                        color: theme['color'],
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE2E8F0),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.access_time_rounded,
                          size: 14,
                          color: textSecondary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          duration,
                          style: const TextStyle(
                            color: textSecondary,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Judul Artikel
              Text(
                title,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: textPrimary,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 24),

              // Garis Pembatas
              Container(
                height: 1.5,
                width: double.infinity,
                color: const Color(0xFFE2E8F0),
              ),
              const SizedBox(height: 24),

              // Isi Artikel (Content)
              Text(
                content,
                style: const TextStyle(
                  fontSize: 16,
                  color: textPrimary,
                  height: 1.6,
                  letterSpacing: 0.2,
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
