import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../main.dart';
import '../utils/toast_helper.dart';
import '../utils/badge_helper.dart';
import 'onboarding_page.dart';
import 'edit_profil_page.dart';
import 'emergency_page.dart';
import 'bookmarks_page.dart';

class ProfilPage extends StatefulWidget {
  const ProfilPage({super.key});

  @override
  State<ProfilPage> createState() => _ProfilPageState();
}

class _ProfilPageState extends State<ProfilPage> {
  // === Design System Colors ===
  static const Color primaryColor = Color(0xFF8B5CF6);
  static const Color backgroundColor = Color(0xFFF8FAFC);
  static const Color textPrimary = Color(0xFF1E293B);
  static const Color textSecondary = Color(0xFF64748B);

  // Default avatar URL fallback
  static const String defaultAvatarUrl =
      'https://api.dicebear.com/9.x/micah/png?seed=Default&backgroundColor=F5F3FF';

  late Stream<Map<String, dynamic>> _profileStream;

  @override
  void initState() {
    super.initState();
    _profileStream = _createProfileStream();
  }

  Stream<Map<String, dynamic>> _createProfileStream() {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return const Stream.empty();
    return Supabase.instance.client
        .from('profiles')
        .stream(primaryKey: ['id'])
        .eq('id', user.id)
        .map((list) => list.isNotEmpty ? list.first : {});
  }

  void _refreshProfile() {
    setState(() {
      _profileStream = _createProfileStream();
    });
  }

  Future<void> _navigateToEditProfil(Map<String, dynamic> profileData) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => EditProfilPage(profileData: profileData),
      ),
    );
    // Jika EditProfilPage mengembalikan true (berhasil simpan), refresh stream
    if (result == true) {
      _refreshProfile();
    }
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
        stream: _profileStream,
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
          final avatarUrl = data['avatar_url'] as String?;
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
                  _buildProfileHeader(context, fullName, email, avatarUrl, data),
                  const SizedBox(height: 24),

                  // Stats Grid
                  _buildStatsGrid(level, totalXp, modulSelesai),
                  const SizedBox(height: 24),

                  // Seksi Lencana
                  _buildSectionTitle('Lencana Saya'),
                  const SizedBox(height: 12),
                  _buildBadgesSection(),
                  const SizedBox(height: 24),

                  // Menu Pengaturan
                  _buildSectionTitle('Pengaturan Akun'),
                  const SizedBox(height: 12),
                  _buildSettingsMenu(context, data),
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
  //  HEADER PROFIL (dengan avatar dari database)
  // ─────────────────────────────────────────────
  Widget _buildProfileHeader(
    BuildContext context,
    String fullName,
    String email,
    String? avatarUrl,
    Map<String, dynamic> profileData,
  ) {
    final initial = fullName.trim().isNotEmpty ? fullName.trim()[0].toUpperCase() : 'U';
    final hasAvatar = avatarUrl != null && avatarUrl.isNotEmpty;

    return Center(
      child: Column(
        children: [
          const SizedBox(height: 8),

          // Avatar besar + tombol edit overlay
          GestureDetector(
            onTap: () {
              _navigateToEditProfil(profileData);
            },
            child: Stack(
              children: [
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
                    backgroundImage: hasAvatar
                        ? NetworkImage(avatarUrl)
                        : const NetworkImage(defaultAvatarUrl),
                    onBackgroundImageError: (_, _) {},
                    child: !hasAvatar
                        ? Text(
                            initial,
                            style: const TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                              color: primaryColor,
                            ),
                          )
                        : null,
                  ),
                ),
                // Ikon edit kecil di sudut kanan bawah avatar
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: primaryColor,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2.5),
                      boxShadow: [
                        BoxShadow(
                          color: primaryColor.withValues(alpha: 0.3),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.edit_rounded,
                      color: Colors.white,
                      size: 14,
                    ),
                  ),
                ),
              ],
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
  Widget _buildSettingsMenu(BuildContext context, Map<String, dynamic> profileData) {
    final List<_MenuItemData> menuItems = [
      _MenuItemData(
        icon: Icons.person_rounded,
        iconColor: primaryColor,
        title: 'Edit Profil',
        isDestructive: false,
        onTap: () {
          _navigateToEditProfil(profileData);
        },
      ),
      _MenuItemData(
        icon: Icons.bookmark_border_rounded,
        iconColor: primaryColor,
        title: 'Modul yang Disimpan',
        isDestructive: false,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const BookmarksPage()),
          );
        },
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
        icon: Icons.warning_amber_rounded,
        iconColor: const Color(0xFFEF4444),
        title: 'Kontak & Bantuan Darurat',
        isDestructive: false,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const EmergencyPage()),
          );
        },
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

  Widget _buildBadgesSection() {
    return FutureBuilder<List<String>>(
      future: BadgeHelper.fetchUserBadges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(
            height: 100,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const CircularProgressIndicator(color: primaryColor),
          );
        }
        
        final ownedBadgeIds = snapshot.data ?? [];
        final ownedBadges = BadgeHelper.allBadges.where((b) => ownedBadgeIds.contains(b.id)).toList();
        final lockedBadges = BadgeHelper.allBadges.where((b) => !ownedBadgeIds.contains(b.id)).toList();
        
        return Container(
          padding: const EdgeInsets.all(16),
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    'Lencana Terkumpul',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: textPrimary),
                  ),
                  Spacer(),
                  Text(
                    '${ownedBadges.length}/${BadgeHelper.allBadges.length}',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: textSecondary),
                  ),
                ],
              ),
              SizedBox(height: 8),
              Text(
                'Kumpulkan lencana dengan menyelesaikan kuis dan modul pembelajaran!',
                style: TextStyle(fontSize: 11, color: textSecondary),
              ),
              SizedBox(height: 16),
              if (ownedBadges.isEmpty)
                Container(
                  padding: EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Color(0xFFE2E8F0)),
                  ),
                  child: Column(
                    children: [
                      Icon(Icons.emoji_events_outlined, size: 40, color: Color(0xFFCBD5E1)),
                      SizedBox(height: 8),
                      Text('Belum ada lencana', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: textSecondary)),
                    ],
                  ),
                )
              else
                GridView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.8,
                  ),
                  itemCount: ownedBadges.length,
                  itemBuilder: (context, index) {
                    final badge = ownedBadges[index];
                    return GestureDetector(
                      onTap: () => _showBadgeDetailDialog(context, badge, true),
                      child: Container(
                        decoration: BoxDecoration(
                          color: badge.bgColor,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: badge.color.withValues(alpha: 0.3), width: 1.5),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 48, height: 48,
                              decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: [BoxShadow(color: badge.color.withValues(alpha: 0.2), blurRadius: 8, offset: Offset(0, 2))]),
                              child: Icon(badge.icon, color: badge.color, size: 26),
                            ),
                            SizedBox(height: 8),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 4),
                              child: Text(badge.name, textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: textPrimary)),
                            ),
                            SizedBox(height: 2),
                            Text('Terbuka', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w500, color: badge.color)),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              SizedBox(height: 12),
              // Lihat badge lainnya
              if (lockedBadges.isNotEmpty)
                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: () => _showAllBadgesModal(ownedBadgeIds),
                    style: TextButton.styleFrom(
                      backgroundColor: Color(0xFFF8FAFC),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Text(
                      'Lihat ${lockedBadges.length} lencana lainnya yang belum didapatkan →',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: primaryColor),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  void _showAllBadgesModal(List<String> ownedBadgeIds) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(24),
          constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.7),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Color(0xFFCBD5E1), borderRadius: BorderRadius.circular(2))),
              ),
              SizedBox(height: 20),
              Text('Semua Lencana', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textPrimary)),
              SizedBox(height: 4),
              Text('${ownedBadgeIds.length}/${BadgeHelper.allBadges.length} terkumpul', style: TextStyle(fontSize: 13, color: textSecondary)),
              SizedBox(height: 20),
              Expanded(
                child: GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.85,
                  ),
                  itemCount: BadgeHelper.allBadges.length,
                  itemBuilder: (context, index) {
                    final badge = BadgeHelper.allBadges[index];
                    final isOwned = ownedBadgeIds.contains(badge.id);
                    return GestureDetector(
                      onTap: () => _showBadgeDetailDialog(context, badge, isOwned),
                      child: Container(
                        decoration: BoxDecoration(
                          color: isOwned ? badge.bgColor : Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: isOwned ? badge.color.withValues(alpha: 0.3) : Color(0xFFE2E8F0), width: 1.5),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 44, height: 44,
                              decoration: BoxDecoration(color: isOwned ? Colors.white : Color(0xFFCBD5E1), shape: BoxShape.circle),
                              child: Icon(isOwned ? badge.icon : Icons.lock_outline_rounded, color: isOwned ? badge.color : Color(0xFF64748B), size: 24),
                            ),
                            SizedBox(height: 8),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 4),
                              child: Text(badge.name, textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: isOwned ? textPrimary : Color(0xFF94A3B8))),
                            ),
                            SizedBox(height: 2),
                            Text(isOwned ? '✓' : '${badge.description.length > 20 ? badge.description.substring(0, 18) + '...' : badge.description}', textAlign: TextAlign.center, style: TextStyle(fontSize: 8, color: isOwned ? badge.color : Color(0xFF94A3B8))),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              SizedBox(height: 12),
            ],
          ),
        );
      },
    );
  }

  void _showBadgeDetailDialog(BuildContext context, BadgeDefinition badge, bool isOwned) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: isOwned ? badge.bgColor : const Color(0xFFE2E8F0),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isOwned ? badge.icon : Icons.lock_outline_rounded,
                    color: isOwned ? badge.color : const Color(0xFF64748B),
                    size: 40,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  badge.name,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  badge.description,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 14,
                    color: textSecondary,
                  ),
                ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: isOwned ? const Color(0xFFD1FAE5) : const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Text(
                    isOwned ? '✓ Berhasil Didapatkan' : '🔒 Belum Terbuka',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: isOwned ? const Color(0xFF065F46) : const Color(0xFF475569),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text(
                      'Tutup',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
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
