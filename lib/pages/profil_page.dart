import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../main.dart';
import '../utils/toast_helper.dart';
import 'onboarding_page.dart';

class ProfilPage extends StatelessWidget {
  const ProfilPage({super.key});

  // === Design System Colors ===
  static const Color primaryColor = Color(0xFF8B5CF6);
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
    if (!isSupabaseInitialized || Supabase.instance.client.auth.currentUser == null) {
      return const Scaffold(
        backgroundColor: backgroundColor,
        body: Center(
          child: Text(
            'Sesi tidak valid. Silakan login kembali.',
            style: TextStyle(color: textSecondary),
          ),
        ),
      );
    }

    final currentUser = Supabase.instance.client.auth.currentUser!;

    return SafeArea(
      child: StreamBuilder<Map<String, dynamic>>(
        stream: _profileStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: primaryColor));
          } else if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Text(
                  'Gagal memuat profil: ${snapshot.error}',
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            );
          }

          final data = snapshot.data ?? {};
          final fullName = data['full_name'] as String? ?? 'Pengguna';
          final email = currentUser.email ?? 'email@domain.com';
          final level = data['level'] as int? ?? 1;
          final totalXp = data['total_xp'] as int? ?? 0;
          final modulSelesai = data['modul_selesai'] as int? ?? 0;

          return Container(
            color: backgroundColor,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Profil
                  _buildProfileHeader(fullName, email),
                  const SizedBox(height: 24),

                  // Stats Grid
                  _buildStatsGrid(level, totalXp, modulSelesai),
                  const SizedBox(height: 24),

                  // Menu Pengaturan
                  _buildSectionTitle('Pengaturan Akun'),
                  const SizedBox(height: 12),
                  _buildSettingsMenu(context),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ─────────────────────────────────────────────
  //  HEADER PROFIL
  // ─────────────────────────────────────────────
  Widget _buildProfileHeader(String fullName, String email) {
    final initial = fullName.trim().isNotEmpty ? fullName.trim()[0].toUpperCase() : 'U';

    return Center(
      child: Column(
        children: [
          const SizedBox(height: 8),

          // Avatar besar
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: primaryColor, width: 3),
              boxShadow: [
                BoxShadow(
                  color: primaryColor.withValues(alpha: 0.2),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: CircleAvatar(
              radius: 45,
              backgroundColor: const Color(0xFFEDE9FE),
              child: Text(
                initial,
                style: const TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: primaryColor,
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),

          // Nama
          Text(
            fullName,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: textPrimary,
            ),
          ),
          const SizedBox(height: 4),

          // Email
          Text(
            email,
            style: const TextStyle(
              fontSize: 14,
              color: textSecondary,
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
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: textPrimary,
      ),
    );
  }

  // ─────────────────────────────────────────────
  //  STATS GRID (3 kolom)
  // ─────────────────────────────────────────────
  Widget _buildStatsGrid(int level, int totalXp, int modulSelesai) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            // Kolom 1: Level
            Expanded(
              child: _buildStatItem(
                value: level.toString(),
                label: 'Level',
                icon: Icons.star_rounded,
                iconColor: const Color(0xFFF59E0B),
                iconBg: const Color(0xFFFEF3C7),
              ),
            ),

            // Garis pembatas
            Container(
              width: 1,
              color: const Color(0xFFE2E8F0),
            ),

            // Kolom 2: Total XP
            Expanded(
              child: _buildStatItem(
                value: '$totalXp',
                label: 'Total XP',
                icon: Icons.bolt_rounded,
                iconColor: primaryColor,
                iconBg: const Color(0xFFEDE9FE),
              ),
            ),

            // Garis pembatas
            Container(
              width: 1,
              color: const Color(0xFFE2E8F0),
            ),

            // Kolom 3: Modul Selesai
            Expanded(
              child: _buildStatItem(
                value: modulSelesai.toString(),
                label: 'Modul Selesai',
                icon: Icons.menu_book_rounded,
                iconColor: const Color(0xFF10B981),
                iconBg: const Color(0xFFD1FAE5),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem({
    required String value,
    required String label,
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Ikon kecil
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: iconBg,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: iconColor, size: 20),
        ),
        const SizedBox(height: 10),

        // Angka
        Text(
          value,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: textPrimary,
          ),
        ),
        const SizedBox(height: 2),

        // Label
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: textSecondary,
          ),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────
  //  SETTINGS MENU
  // ─────────────────────────────────────────────
  Widget _buildSettingsMenu(BuildContext context) {
    final List<_MenuItemData> menuItems = [
      _MenuItemData(
        icon: Icons.bookmark_border_rounded,
        iconColor: primaryColor,
        title: 'Modul yang Disimpan',
        isDestructive: false,
      ),
      _MenuItemData(
        icon: Icons.lock_outline_rounded,
        iconColor: primaryColor,
        title: 'Ubah Kata Sandi',
        isDestructive: false,
      ),
      _MenuItemData(
        icon: Icons.notifications_none_rounded,
        iconColor: primaryColor,
        title: 'Notifikasi Pengingat',
        isDestructive: false,
      ),
      _MenuItemData(
        icon: Icons.logout_rounded,
        iconColor: Colors.red,
        title: 'Keluar Akun',
        isDestructive: true,
        onTap: () async {
          // Menampilkan loading indikator
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => const Center(child: CircularProgressIndicator()),
          );

          try {
            // Proses logout dari Supabase
            await Supabase.instance.client.auth.signOut();

            if (context.mounted) {
              // Tutup loading
              Navigator.of(context).pop();
              
              // Tampilkan toast sukses
              ToastHelper.showSuccess(context, 'Berhasil keluar akun.');
              
              // Tendang user kembali ke OnboardingPage
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const OnboardingPage()),
                (route) => false,
              );
            }
          } catch (e) {
            if (context.mounted) {
              Navigator.of(context).pop(); // Tutup loading
              ToastHelper.showError(context, 'Gagal keluar: ${e.toString()}');
            }
          }
        },
      ),
    ];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Column(
          children: List.generate(menuItems.length, (index) {
            final item = menuItems[index];
            return Column(
              children: [
                Material(
                  color: Colors.transparent,
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 4,
                    ),
                    leading: Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: item.isDestructive
                            ? const Color(0xFFFEE2E2)
                            : const Color(0xFFEDE9FE),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        item.icon,
                        color: item.iconColor,
                        size: 22,
                      ),
                    ),
                    title: Text(
                      item.title,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: item.isDestructive ? Colors.red : textPrimary,
                      ),
                    ),
                    trailing: Icon(
                      Icons.chevron_right,
                      color: item.isDestructive
                          ? Colors.red.withValues(alpha: 0.5)
                          : const Color(0xFFCBD5E1),
                      size: 24,
                    ),
                    onTap: item.onTap ?? () {},
                  ),
                ),
                // Divider kecuali item terakhir
                if (index < menuItems.length - 1)
                  const Divider(
                    height: 1,
                    indent: 72,
                    endIndent: 16,
                    color: Color(0xFFF1F5F9),
                  ),
              ],
            );
          }),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  Data class
// ─────────────────────────────────────────────
class _MenuItemData {
  final IconData icon;
  final Color iconColor;
  final String title;
  final bool isDestructive;
  final VoidCallback? onTap;

  _MenuItemData({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.isDestructive,
    this.onTap,
  });
}
