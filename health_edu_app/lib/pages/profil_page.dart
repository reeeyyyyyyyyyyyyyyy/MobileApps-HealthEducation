import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../theme/uticare_theme.dart';
import 'chat_bot_page.dart';
import 'login_page.dart';
import 'posttest_page.dart';
import 'edit_profil_page.dart';
import 'tracking_page.dart';

class ProfilPage extends StatefulWidget {
  const ProfilPage({super.key});

  @override
  State<ProfilPage> createState() => _ProfilPageState();
}

class _ProfilPageState extends State<ProfilPage> {
  Map<String, dynamic>? _profile;
  bool _isLoading = true;
  int _riskCheckCount = 0;
  int _daysUsed = 0;
  int _materialsRead = 0;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) return;

      final profile = await Supabase.instance.client
          .from('profiles')
          .select()
          .eq('id', user.id)
          .maybeSingle();

      // Count risk checks
      final riskCount = await Supabase.instance.client
          .from('risk_results')
          .select('id')
          .eq('user_id', user.id);

      // Count materials read
      final progressCount = await Supabase.instance.client
          .from('user_progress')
          .select('id')
          .eq('user_id', user.id);

      // Calculate days used
      int days = 0;
      if (profile != null && profile['created_at'] != null) {
        final createdAt = DateTime.tryParse(profile['created_at'].toString());
        if (createdAt != null) {
          days = DateTime.now().difference(createdAt).inDays + 1;
        }
      }

      if (mounted) {
        setState(() {
          _profile = profile;
          _riskCheckCount = (riskCount as List).length;
          _materialsRead = (progressCount as List).length;
          _daysUsed = days;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading profile: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  bool get _canDoPosttest {
    if (_profile == null) return false;
    if (_profile!['has_completed_posttest'] == true) return false;
    return _daysUsed >= 7;
  }

  Future<void> _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Keluar'),
        content: const Text('Yakin ingin keluar dari UtiCare?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Batal')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Keluar', style: TextStyle(color: UtiCareTheme.danger)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await Supabase.instance.client.auth.signOut();
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const LoginPage()),
          (route) => false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final name = _profile?['full_name'] ?? 'Pengguna';
    final school = _profile?['school'] ?? '';
    final email = Supabase.instance.client.auth.currentUser?.email ?? '';

    return Scaffold(
      backgroundColor: UtiCareTheme.background,
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator(color: UtiCareTheme.primary))
            : SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const SizedBox(height: 10),

                    // Profile header
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: UtiCareTheme.primaryGradient,
                        borderRadius: BorderRadius.circular(UtiCareTheme.radiusXl),
                        boxShadow: UtiCareTheme.elevatedShadow,
                      ),
                      child: Column(
                        children: [
                          // Avatar
                          Container(
                            width: 72,
                            height: 72,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withValues(alpha: 0.2),
                              border: Border.all(color: Colors.white.withValues(alpha: 0.5), width: 2),
                            ),
                            child: Center(
                              child: Text(
                                name.toString().isNotEmpty ? name.toString()[0].toUpperCase() : '?',
                                style: const TextStyle(
                                  fontSize: 30,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            name.toString(),
                            style: UtiCareTheme.heading2.copyWith(color: Colors.white),
                          ),
                          if (school.toString().isNotEmpty)
                            Text(
                              school.toString(),
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.white.withValues(alpha: 0.8),
                              ),
                            ),
                          const SizedBox(height: 16),

                          // Stats row
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _buildStat('$_daysUsed', 'Hari'),
                              Container(width: 1, height: 30, color: Colors.white.withValues(alpha: 0.3)),
                              _buildStat('$_riskCheckCount', 'Check Risk'),
                              Container(width: 1, height: 30, color: Colors.white.withValues(alpha: 0.3)),
                              _buildStat('$_materialsRead', 'Materi'),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Menu items
                    _buildMenuItem(
                      icon: Icons.person_rounded,
                      title: 'Data Pribadi',
                      subtitle: email,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => EditProfilPage(profileData: _profile)),
                        ).then((_) => _loadProfile());
                      },
                    ),

                    _buildMenuItem(
                      icon: Icons.track_changes_rounded,
                      title: 'Tracking Kebiasaan',
                      subtitle: 'Catat minum air & kebersihan harian',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const TrackingPage()),
                        );
                      },
                    ),

                    if (_canDoPosttest)
                      _buildMenuItem(
                        icon: Icons.assignment_turned_in_rounded,
                        title: 'Post-Test Kuesioner',
                        subtitle: 'Isi kuesioner akhir penelitian',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const PosttestPage()),
                          ).then((_) => _loadProfile());
                        },
                        highlight: true,
                      ),

                    if (_profile?['has_completed_posttest'] == true)
                      _buildMenuItem(
                        icon: Icons.check_circle_rounded,
                        title: 'Post-Test Selesai',
                        subtitle: 'Terima kasih atas partisipasimu!',
                        onTap: () {},
                        completed: true,
                      ),

                    _buildMenuItem(
                      icon: Icons.chat_rounded,
                      title: 'Konsultasi ISK',
                      subtitle: 'Tanya Suster Care (AI & WhatsApp)',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const ChatBotPage()),
                        );
                      },
                    ),

                    _buildMenuItem(
                      icon: Icons.privacy_tip_rounded,
                      title: 'Privasi & Keamanan',
                      subtitle: 'Data kamu aman dan terenkripsi',
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: const Text('Privasi & Keamanan Data'),
                            content: const Text(
                              'Data pribadi dan hasil evaluasi kamu disimpan secara aman. '
                              'Hanya digunakan untuk keperluan penelitian pencegahan ISK '
                              'dan tidak akan disebarluaskan.',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(ctx),
                                child: const Text('Mengerti'),
                              ),
                            ],
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 12),

                    // Logout
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: _logout,
                        icon: const Icon(Icons.logout_rounded, color: UtiCareTheme.danger),
                        label: const Text('Keluar', style: TextStyle(color: UtiCareTheme.danger)),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: UtiCareTheme.danger),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    const Text(
                      'UtiCare v1.0.0 (Health Belief Model)',
                      style: UtiCareTheme.caption,
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildStat(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Colors.white.withValues(alpha: 0.7),
          ),
        ),
      ],
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool highlight = false,
    bool completed = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: highlight
            ? UtiCareTheme.primarySubtle
            : completed
                ? UtiCareTheme.successLight
                : UtiCareTheme.surface,
        borderRadius: BorderRadius.circular(UtiCareTheme.radiusLg),
        border: Border.all(
          color: highlight
              ? UtiCareTheme.primary.withValues(alpha: 0.3)
              : completed
                  ? UtiCareTheme.success.withValues(alpha: 0.3)
                  : UtiCareTheme.border.withValues(alpha: 0.5),
        ),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: highlight
                ? UtiCareTheme.primary.withValues(alpha: 0.1)
                : completed
                    ? UtiCareTheme.success.withValues(alpha: 0.1)
                    : UtiCareTheme.surfaceAlt,
            borderRadius: BorderRadius.circular(UtiCareTheme.radiusMd),
          ),
          child: Icon(
            icon,
            color: highlight
                ? UtiCareTheme.primary
                : completed
                    ? UtiCareTheme.success
                    : UtiCareTheme.textSecondary,
            size: 22,
          ),
        ),
        title: Text(title, style: UtiCareTheme.bodyBold),
        subtitle: Text(subtitle, style: UtiCareTheme.caption),
        trailing: const Icon(Icons.chevron_right_rounded, color: UtiCareTheme.textTertiary),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(UtiCareTheme.radiusLg),
        ),
      ),
    );
  }
}
