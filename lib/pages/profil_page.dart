import 'package:flutter/material.dart';

class ProfilPage extends StatelessWidget {
  const ProfilPage({super.key});

  // === Design System Colors ===
  static const Color primaryColor = Color(0xFF8B5CF6);
  static const Color backgroundColor = Color(0xFFF8FAFC);
  static const Color textPrimary = Color(0xFF1E293B);
  static const Color textSecondary = Color(0xFF64748B);

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
              // Header Profil
              _buildProfileHeader(),
              const SizedBox(height: 24),

              // Stats Grid
              _buildStatsGrid(),
              const SizedBox(height: 24),

              // Menu Pengaturan
              _buildSectionTitle('Pengaturan Akun'),
              const SizedBox(height: 12),
              _buildSettingsMenu(),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────
  //  HEADER PROFIL
  // ─────────────────────────────────────────────
  Widget _buildProfileHeader() {
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
            child: const CircleAvatar(
              radius: 45,
              backgroundColor: Color(0xFFEDE9FE),
              child: Text(
                'S',
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: primaryColor,
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),

          // Nama
          const Text(
            'Sara',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: textPrimary,
            ),
          ),
          const SizedBox(height: 4),

          // Email
          const Text(
            'sara@email.com',
            style: TextStyle(
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
  Widget _buildStatsGrid() {
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
                value: '4',
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
                value: '320',
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
                value: '5',
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
  Widget _buildSettingsMenu() {
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
                ListTile(
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
                  onTap: () {},
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

  _MenuItemData({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.isDestructive,
  });
}
