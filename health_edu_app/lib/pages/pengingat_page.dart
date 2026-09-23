import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../theme/uticare_theme.dart';

class PengingatPage extends StatefulWidget {
  const PengingatPage({super.key});

  @override
  State<PengingatPage> createState() => _PengingatPageState();
}

class _PengingatPageState extends State<PengingatPage> {
  List<Map<String, dynamic>> _templates = [];
  Map<int, Map<String, dynamic>> _userReminders = {};
  bool _isLoading = true;
  String? _motivasiHarian;

  final List<String> _motivasiList = [
    'Kamu hebat! Sedikit lagi menuju versi terbaik dirimu.',
    'Kesehatan saluran kemihmu adalah investasi untuk masa depan.',
    'Setiap gelas air putih yang kamu minum adalah langkah pencegahan ISK.',
    'Kebiasaan kecil hari ini, dampak besar untuk kesehatanmu.',
    'Jaga kebersihanmu, jaga kesehatanmu. Kamu bisa!',
    'Tubuhmu berharga, rawat dengan penuh kasih sayang.',
    'Langkah kecil, perubahan besar. Tetap semangat!',
    'Mencegah lebih baik daripada mengobati. Kamu sudah di jalur yang benar!',
  ];

  final Map<String, IconData> _iconMap = {
    'water_drop': Icons.water_drop_rounded,
    'wc': Icons.wc_rounded,
    'clean_hands': Icons.clean_hands_rounded,
    'fitness_center': Icons.fitness_center_rounded,
    'local_drink': Icons.local_drink_rounded,
    'notifications': Icons.notifications_rounded,
    'favorite': Icons.favorite_rounded,
    'health_and_safety': Icons.health_and_safety_rounded,
  };

  @override
  void initState() {
    super.initState();
    _fetchTemplates();
    _setMotivasi();
  }

  void _setMotivasi() {
    final dayOfYear = DateTime.now().difference(DateTime(DateTime.now().year, 1, 1)).inDays;
    _motivasiHarian = _motivasiList[dayOfYear % _motivasiList.length];
  }

  Future<void> _fetchTemplates() async {
    try {
      final templates = await Supabase.instance.client
          .from('reminder_templates')
          .select()
          .eq('is_active', true)
          .order('sort_order', ascending: true);

      final userId = Supabase.instance.client.auth.currentUser?.id;
      Map<int, Map<String, dynamic>> userMap = {};

      if (userId != null) {
        final userReminders = await Supabase.instance.client
            .from('user_reminders')
            .select()
            .eq('user_id', userId);

        for (var ur in userReminders) {
          final templateId = ur['template_id'] as int;
          userMap[templateId] = Map<String, dynamic>.from(ur);
        }
      }

      if (mounted) {
        setState(() {
          _templates = List<Map<String, dynamic>>.from(templates);
          _userReminders = userMap;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error fetching reminders: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _toggleReminder(int templateId, bool enabled) async {
    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) return;

      if (_userReminders.containsKey(templateId)) {
        await Supabase.instance.client
            .from('user_reminders')
            .update({'is_enabled': enabled})
            .eq('user_id', userId)
            .eq('template_id', templateId);
        setState(() {
          _userReminders[templateId]!['is_enabled'] = enabled;
        });
      } else {
        final template = _templates.firstWhere((t) => t['id'] == templateId);
        final defaultTime = template['default_time'] ?? '08:00:00';

        final res = await Supabase.instance.client.from('user_reminders').insert({
          'user_id': userId,
          'template_id': templateId,
          'scheduled_time': defaultTime,
          'is_enabled': enabled,
        }).select().single();

        setState(() {
          _userReminders[templateId] = Map<String, dynamic>.from(res);
        });
      }
    } catch (e) {
      debugPrint('Error toggling reminder: $e');
    }
  }

  Future<void> _setReminderTime(int templateId) async {
    final currentTime = _userReminders[templateId]?['scheduled_time'] ?? '08:00:00';
    final parts = currentTime.toString().split(':');
    final initial = TimeOfDay(
      hour: int.tryParse(parts[0]) ?? 8,
      minute: int.tryParse(parts[1]) ?? 0,
    );

    final picked = await showTimePicker(
      context: context,
      initialTime: initial,
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: UtiCareTheme.primary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked == null) return;

    final timeStr = '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}:00';

    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) return;

      if (_userReminders.containsKey(templateId)) {
        await Supabase.instance.client
            .from('user_reminders')
            .update({'scheduled_time': timeStr})
            .eq('user_id', userId)
            .eq('template_id', templateId);
        setState(() {
          _userReminders[templateId]!['scheduled_time'] = timeStr;
        });
      }
    } catch (e) {
      debugPrint('Error setting reminder time: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: UtiCareTheme.background,
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator(color: UtiCareTheme.primary))
            : SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Pengingat', style: UtiCareTheme.heading1),
                    const SizedBox(height: 4),
                    Text(
                      'Bantu kamu konsisten dengan kebiasaan baik',
                      style: UtiCareTheme.body.copyWith(color: UtiCareTheme.textSecondary),
                    ),

                    const SizedBox(height: 20),

                    // Motivasi harian
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: UtiCareTheme.cardGradient,
                        borderRadius: BorderRadius.circular(UtiCareTheme.radiusLg),
                        border: Border.all(color: UtiCareTheme.primaryLight.withValues(alpha: 0.5)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: UtiCareTheme.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(UtiCareTheme.radiusMd),
                            ),
                            child: const Icon(Icons.auto_awesome_rounded, color: UtiCareTheme.primary, size: 22),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Motivasi Harian', style: UtiCareTheme.label),
                                const SizedBox(height: 4),
                                Text(
                                  _motivasiHarian ?? '',
                                  style: UtiCareTheme.body.copyWith(
                                    fontStyle: FontStyle.italic,
                                    color: UtiCareTheme.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    const Text('Pengingat Harian', style: UtiCareTheme.heading3),
                    const SizedBox(height: 12),

                    // Reminder list
                    ..._templates.map((template) {
                      final tId = template['id'] as int;
                      final userReminder = _userReminders[tId];
                      final isEnabled = userReminder?['is_enabled'] == true;
                      final scheduledTime = userReminder?['scheduled_time'] ?? template['default_time'] ?? '08:00:00';
                      final timeParts = scheduledTime.toString().split(':');
                      final displayTime = '${timeParts[0]}:${timeParts[1]}';
                      final iconName = template['icon_name'] ?? 'notifications';
                      final icon = _iconMap[iconName] ?? Icons.notifications_rounded;

                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: UtiCareTheme.surface,
                          borderRadius: BorderRadius.circular(UtiCareTheme.radiusLg),
                          border: Border.all(
                            color: isEnabled
                                ? UtiCareTheme.primary.withValues(alpha: 0.3)
                                : UtiCareTheme.border,
                          ),
                          boxShadow: isEnabled ? UtiCareTheme.cardShadow : null,
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: isEnabled
                                    ? UtiCareTheme.primarySubtle
                                    : UtiCareTheme.surfaceAlt,
                                borderRadius: BorderRadius.circular(UtiCareTheme.radiusMd),
                              ),
                              child: Icon(
                                icon,
                                color: isEnabled ? UtiCareTheme.primary : UtiCareTheme.textTertiary,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    template['title'] ?? '',
                                    style: UtiCareTheme.bodyBold.copyWith(
                                      color: isEnabled ? UtiCareTheme.textPrimary : UtiCareTheme.textTertiary,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  GestureDetector(
                                    onTap: isEnabled ? () => _setReminderTime(tId) : null,
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.schedule_rounded,
                                          size: 14,
                                          color: isEnabled ? UtiCareTheme.primary : UtiCareTheme.textTertiary,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          'Setiap $displayTime',
                                          style: UtiCareTheme.caption.copyWith(
                                            color: isEnabled ? UtiCareTheme.primary : UtiCareTheme.textTertiary,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        if (isEnabled)
                                          const Icon(Icons.edit_rounded, size: 12, color: UtiCareTheme.primary),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Switch(
                              value: isEnabled,
                              onChanged: (val) => _toggleReminder(tId, val),
                              activeThumbColor: UtiCareTheme.primary,
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),
      ),
    );
  }
}
