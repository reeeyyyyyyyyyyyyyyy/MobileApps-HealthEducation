import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../utils/toast_helper.dart';
import '../utils/time_helper.dart';
import '../utils/ai_service.dart';

class TrackerDetailPage extends StatefulWidget {
  const TrackerDetailPage({super.key});

  @override
  State<TrackerDetailPage> createState() => _TrackerDetailPageState();
}

class _TrackerDetailPageState extends State<TrackerDetailPage> {
  DateTime _focusedDay = TimeHelper.nowWIB();
  DateTime? _selectedDay;
  Set<DateTime> _loggedDates = {};
  Set<DateTime> _manualPeriodDates = {};

  // Edit mode state
  bool _isEditing = false;
  Set<DateTime> _editingPeriodDays = {};
  DateTime? _editingMonth; // Scoped month being edited
  bool _isSaving = false;

  bool? _hasMenstruated = true;
  DateTime? _lastPeriodDate;
  int _avgPeriodDuration = 5;
  int _avgCycleLength = 28;

  final SupabaseClient _supabase = Supabase.instance.client;

  late List<DateTime> _months;
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    final now = TimeHelper.nowWIB();
    _selectedDay = DateTime(now.year, now.month, now.day);
    _focusedDay = DateTime(now.year, now.month, 1);
    
    // Generate months from 12 months ago to 12 months in the future
    _months = List.generate(25, (index) {
      return DateTime(now.year, now.month - 12 + index, 1);
    });
    
    _scrollController = ScrollController();
    _scrollController.addListener(() {
      if (!_isEditing) {
        // Approximate height of a month card
        final index = (_scrollController.offset / 380.0).round();
        if (index >= 0 && index < _months.length) {
          final month = _months[index];
          if (_focusedDay.year != month.year || _focusedDay.month != month.month) {
            // Kita bisa setState di sini kalau butuh _focusedDay untuk efek lain di luar edit mode,
            // tapi karena ListView.builder render bulan secara independen, kita bisa pakai ini
            // hanya untuk mendeteksi bulan yang sedang aktif.
            _focusedDay = DateTime(month.year, month.month, 1);
          }
        }
      }
    });

    _fetchUserProfile().then((_) {
      _fetchLoggedDates();
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        // Start at current month (index 12)
        _scrollController.jumpTo(12 * 395.0);
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  bool _isSameDay(DateTime? a, DateTime? b) {
    if (a == null || b == null) return false;
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  Future<void> _fetchUserProfile() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;

    try {
      final response = await _supabase
          .from('profiles')
          .select('last_period_date, avg_period_duration, avg_cycle_length, has_menstruated')
          .eq('id', user.id)
          .maybeSingle();

      if (response != null && mounted) {
        setState(() {
          _hasMenstruated = response['has_menstruated'] as bool?;
          if (response['last_period_date'] != null) {
            _lastPeriodDate = DateTime.tryParse(response['last_period_date'] as String);
          } else {
            _lastPeriodDate = null;
          }
          _avgPeriodDuration = response['avg_period_duration'] as int? ?? 5;
          _avgCycleLength = response['avg_cycle_length'] as int? ?? 28;
        });
      }
    } catch (e) {
      debugPrint('Error fetching profile in tracker detail: $e');
    }
  }

  Future<void> _fetchLoggedDates() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;

    try {
      final response = await _supabase
          .from('daily_logs')
          .select('log_date, symptoms, is_period_day')
          .eq('user_id', user.id);

      final List<dynamic> data = response;
      final Set<DateTime> dates = {};
      final Set<DateTime> manualPeriods = {};
      
      for (var row in data) {
        final dateStr = row['log_date'] as String?;
        if (dateStr != null) {
          final parsedDate = DateTime.parse(dateStr);
          final normalized = DateTime(parsedDate.year, parsedDate.month, parsedDate.day);
          dates.add(normalized);
          
          final isPeriodDay = row['is_period_day'] as bool? ?? false;
          if (isPeriodDay) {
            manualPeriods.add(normalized);
          }
        }
      }

      if (mounted) {
        setState(() {
          _loggedDates = dates;
          _manualPeriodDates = manualPeriods;
        });
      }
    } catch (e) {
      debugPrint('Error fetching logged dates: $e');
    }
  }

  Future<void> _recalculateCycle() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;

    try {
      final ninetyDaysAgo = TimeHelper.nowWIB().subtract(const Duration(days: 90));
      final ninetyDaysAgoStr = ninetyDaysAgo.toIso8601String().split('T')[0];

      final response = await _supabase
          .from('daily_logs')
          .select('log_date')
          .eq('user_id', user.id)
          .eq('is_period_day', true)
          .gte('log_date', ninetyDaysAgoStr);

      final List<dynamic> data = response;
      if (data.isEmpty) return;

      List<DateTime> periodDates = data.map((row) {
        final parsed = DateTime.parse(row['log_date'] as String);
        return DateTime(parsed.year, parsed.month, parsed.day);
      }).toList();

      periodDates.sort((a, b) => a.compareTo(b));

      // Group into period blocks
      List<List<DateTime>> blocks = [];
      if (periodDates.isNotEmpty) {
        List<DateTime> currentBlock = [periodDates.first];
        for (int i = 1; i < periodDates.length; i++) {
          final prevDate = periodDates[i - 1];
          final currDate = periodDates[i];
          if (currDate.difference(prevDate).inDays <= 3) {
            currentBlock.add(currDate);
          } else {
            blocks.add(currentBlock);
            currentBlock = [currDate];
          }
        }
        blocks.add(currentBlock);
      }

      if (blocks.isEmpty) return;

      final lastBlock = blocks.last;
      final resolvedLastPeriodDate = lastBlock.first;
      final lastPeriodDateStr = resolvedLastPeriodDate.toIso8601String().split('T')[0];

      double totalDuration = 0;
      for (var block in blocks) {
        totalDuration += (block.last.difference(block.first).inDays + 1);
      }
      final avgDuration = (totalDuration / blocks.length).round();

      int avgCycle = _avgCycleLength;
      if (blocks.length >= 2) {
        double totalCycleDays = 0;
        int cycleCount = 0;
        for (int i = 1; i < blocks.length; i++) {
          final diff = blocks[i].first.difference(blocks[i - 1].first).inDays;
          if (diff >= 15 && diff <= 45) {
            totalCycleDays += diff;
            cycleCount++;
          }
        }
        if (cycleCount > 0) {
          avgCycle = (totalCycleDays / cycleCount).round();
        }
      }

      await _supabase.from('profiles').update({
        'has_menstruated': true,
        'last_period_date': lastPeriodDateStr,
        'avg_period_duration': avgDuration,
        'avg_cycle_length': avgCycle,
      }).eq('id', user.id);

      await _fetchUserProfile();
    } catch (e) {
      debugPrint('Error recalculating cycle: $e');
    }
  }

  bool _isPeriodDay(DateTime date) {
    if (_hasMenstruated == false) return false;
    final checkDate = DateTime(date.year, date.month, date.day);

    if (_isEditing) {
      if (date.year == _editingMonth?.year && date.month == _editingMonth?.month) {
        return _editingPeriodDays.contains(checkDate);
      }
      // For other months in edit mode, fall through to normal period display so they don't disappear!
    }

    if (_manualPeriodDates.contains(checkDate)) return true;

    if (_lastPeriodDate != null) {
      final start = DateTime(_lastPeriodDate!.year, _lastPeriodDate!.month, _lastPeriodDate!.day);
      final end = start.add(Duration(days: _avgPeriodDuration - 1));
      if ((checkDate.isAfter(start) || checkDate.isAtSameMomentAs(start)) &&
          (checkDate.isBefore(end) || checkDate.isAtSameMomentAs(end))) {
        return true;
      }
    }
    return false;
  }

  bool _isPredictionDay(DateTime date) {
    if (_hasMenstruated == false || _lastPeriodDate == null) return false;
    if (_isEditing && date.year == _editingMonth?.year && date.month == _editingMonth?.month) return false;
    final checkDate = DateTime(date.year, date.month, date.day);
    if (_isPeriodDay(checkDate)) return false;

    DateTime cycleStart = DateTime(_lastPeriodDate!.year, _lastPeriodDate!.month, _lastPeriodDate!.day);
    int diffDays = checkDate.difference(cycleStart).inDays;
    if (diffDays < 0) return false;

    int cyclesPassed = diffDays ~/ _avgCycleLength;
    if (cyclesPassed == 0) return false;

    DateTime predStart = cycleStart.add(Duration(days: cyclesPassed * _avgCycleLength));
    DateTime predEnd = predStart.add(Duration(days: _avgPeriodDuration - 1));

    if ((checkDate.isAfter(predStart) || checkDate.isAtSameMomentAs(predStart)) &&
        (checkDate.isBefore(predEnd) || checkDate.isAtSameMomentAs(predEnd))) {
      return true;
    }

    DateTime nextPredStart = cycleStart.add(Duration(days: (cyclesPassed + 1) * _avgCycleLength));
    DateTime nextPredEnd = nextPredStart.add(Duration(days: _avgPeriodDuration - 1));
    if ((checkDate.isAfter(nextPredStart) || checkDate.isAtSameMomentAs(nextPredStart)) &&
        (checkDate.isBefore(nextPredEnd) || checkDate.isAtSameMomentAs(nextPredEnd))) {
      return true;
    }

    return false;
  }

  bool _isFertileDay(DateTime date) {
    if (_hasMenstruated == false || _lastPeriodDate == null) return false;
    if (_isEditing && date.year == _editingMonth?.year && date.month == _editingMonth?.month) return false;
    final checkDate = DateTime(date.year, date.month, date.day);
    if (_isPeriodDay(checkDate) || _isPredictionDay(checkDate)) return false;

    DateTime cycleStart = DateTime(_lastPeriodDate!.year, _lastPeriodDate!.month, _lastPeriodDate!.day);
    int diffDays = checkDate.difference(cycleStart).inDays;
    if (diffDays < 0) return false;

    int cyclesPassed = diffDays ~/ _avgCycleLength;

    int ovulationOffset = _avgCycleLength - 14;
    if (ovulationOffset < 7) ovulationOffset = 7;

    DateTime currentCycleStart = cycleStart.add(Duration(days: cyclesPassed * _avgCycleLength));
    DateTime fertileStart = currentCycleStart.add(Duration(days: ovulationOffset - 4));
    DateTime fertileEnd = currentCycleStart.add(Duration(days: ovulationOffset + 1));

    if ((checkDate.isAfter(fertileStart) || checkDate.isAtSameMomentAs(fertileStart)) &&
        (checkDate.isBefore(fertileEnd) || checkDate.isAtSameMomentAs(fertileEnd))) {
      return true;
    }

    DateTime nextCycleStart = cycleStart.add(Duration(days: (cyclesPassed + 1) * _avgCycleLength));
    DateTime nextFertileStart = nextCycleStart.add(Duration(days: ovulationOffset - 4));
    DateTime nextFertileEnd = nextCycleStart.add(Duration(days: ovulationOffset + 1));

    if ((checkDate.isAfter(nextFertileStart) || checkDate.isAtSameMomentAs(nextFertileStart)) &&
        (checkDate.isBefore(nextFertileEnd) || checkDate.isAtSameMomentAs(nextFertileEnd))) {
      return true;
    }

    return false;
  }

  void _enterEditMode() {
    _editingMonth = DateTime(_focusedDay.year, _focusedDay.month, 1);
    
    final Set<DateTime> initialSet = {};
    for (final d in _manualPeriodDates) {
      if (d.year == _editingMonth!.year && d.month == _editingMonth!.month) {
        initialSet.add(d);
      }
    }

    if (_lastPeriodDate != null && _hasMenstruated != false) {
      final start = DateTime(_lastPeriodDate!.year, _lastPeriodDate!.month, _lastPeriodDate!.day);
      for (int i = 0; i < _avgPeriodDuration; i++) {
        final d = start.add(Duration(days: i));
        if (d.year == _editingMonth!.year && d.month == _editingMonth!.month) {
          initialSet.add(d);
        }
      }
    }

    setState(() {
      _isEditing = true;
      _editingPeriodDays = initialSet;
    });
  }

  void _cancelEditMode() {
    setState(() {
      _isEditing = false;
      _editingPeriodDays = {};
      _editingMonth = null;
    });
  }

  Future<void> _saveAndAnalyze() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;

    setState(() {
      _isSaving = true;
    });

    try {
      final monthToSave = _editingMonth ?? DateTime(_focusedDay.year, _focusedDay.month, 1);
      
      for (final date in _editingPeriodDays) {
        if (date.year == monthToSave.year && date.month == monthToSave.month) {
          final dateStr = date.toIso8601String().split('T')[0];
          await _supabase.from('daily_logs').upsert({
            'user_id': user.id,
            'log_date': dateStr,
            'is_period_day': true,
            'symptoms': ['Menstruasi (Haid)'],
          }, onConflict: 'user_id,log_date');
        }
      }

      final existingPeriodDates = Set<DateTime>.from(_manualPeriodDates);
      if (_lastPeriodDate != null) {
        final start = DateTime(_lastPeriodDate!.year, _lastPeriodDate!.month, _lastPeriodDate!.day);
        for (int i = 0; i < _avgPeriodDuration; i++) {
          existingPeriodDates.add(start.add(Duration(days: i)));
        }
      }

      for (final date in existingPeriodDates) {
        if (date.year == monthToSave.year && date.month == monthToSave.month) {
          if (!_editingPeriodDays.contains(date)) {
            final dateStr = date.toIso8601String().split('T')[0];
            await _supabase.from('daily_logs').upsert({
              'user_id': user.id,
              'log_date': dateStr,
              'is_period_day': false,
              'symptoms': [],
            }, onConflict: 'user_id,log_date');
          }
        }
      }

      await _recalculateCycle();

      final duration = _editingPeriodDays
          .where((d) => d.year == monthToSave.year && d.month == monthToSave.month)
          .length;

      List<String> symptoms = [];
      if (duration > 0) {
        final sortedDates = _editingPeriodDays
            .where((d) => d.year == monthToSave.year && d.month == monthToSave.month)
            .toList()
          ..sort();
        final startStr = sortedDates.first.toIso8601String().split('T')[0];
        final endStr = sortedDates.last.toIso8601String().split('T')[0];
        try {
          final logsResponse = await _supabase
              .from('daily_logs')
              .select('symptoms')
              .eq('user_id', user.id)
              .gte('log_date', startStr)
              .lte('log_date', endStr);

          for (var row in logsResponse) {
            final list = row['symptoms'] as List<dynamic>?;
            if (list != null) {
              for (var sym in list) {
                final s = sym.toString();
                if (s != 'Menstruasi (Haid)' && !symptoms.contains(s)) {
                  symptoms.add(s);
                }
              }
            }
          }
        } catch (e) {
          debugPrint('Error fetching symptoms for AI: $e');
        }
      }

      String aiAnalysis = '';
      if (duration > 0) {
        aiAnalysis = await AIService.analyzePeriod(duration, symptoms);
      }

      await _fetchLoggedDates();

      if (mounted) {
        setState(() {
          _isEditing = false;
          _editingPeriodDays = {};
          _isSaving = false;
        });

        if (duration > 0) {
          _showAnalysisDialog(duration, aiAnalysis);
        } else {
          ToastHelper.showSuccess(context, 'Data haid berhasil diperbarui! 🌸');
        }
      }
    } catch (e) {
      debugPrint('Error saving period data: $e');
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
        ToastHelper.showError(context, 'Gagal menyimpan data: $e');
      }
    }
  }

  void _showAnalysisDialog(int duration, String aiAnalysis) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.check_circle_rounded, color: Color(0xFF10B981), size: 28),
              SizedBox(width: 8),
              Text(
                'Haid Tersimpan!',
                style: TextStyle(
                  color: Color(0xFF581C87),
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFCE7F3), Color(0xFFFDF4FF)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.water_drop_rounded, color: Color(0xFFEC4899), size: 32),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Durasi Haid',
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFF9D178D),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            '$duration hari',
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF581C87),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0FDF4),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFBBF7D0)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.auto_awesome, color: Color(0xFF8B5CF6), size: 18),
                        SizedBox(width: 6),
                        Text(
                          'Analisis AI BloomFem',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF581C87),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      aiAnalysis,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF1E293B),
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            Center(
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF8B5CF6),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: const Text('Tutup', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showFirstHaidDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: const Text(
            'Selamat Memasuki Fase Baru! 🌸',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFF581C87),
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.spa_rounded,
                color: Color(0xFFEC4899),
                size: 64,
              ),
              const SizedBox(height: 16),
              const Text(
                'Menstruasi pertama (menarche) adalah tanda sehat bahwa tubuhmu sedang tumbuh dewasa secara alami. Jangan khawatir, BloomFem akan mendampingimu untuk mencatat dan memahami siklus sehatmu!\n\nKami akan mengeset perkiraan awal haid selama 5 hari dengan siklus 28 hari. Kamu bisa menyesuaikannya kapan saja.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF1E293B),
                  height: 1.4,
                ),
              ),
            ],
          ),
          actions: [
            Center(
              child: ElevatedButton(
                onPressed: () async {
                  Navigator.pop(context);
                  final user = _supabase.auth.currentUser;
                  if (user == null) return;
                  try {
                    final todayStr = TimeHelper.nowWIB().toIso8601String().split('T')[0];
                    await _supabase
                        .from('profiles')
                        .update({
                          'has_menstruated': true,
                          'last_period_date': todayStr,
                          'avg_period_duration': 5,
                          'avg_cycle_length': 28,
                        })
                        .eq('id', user.id);
                        
                    await _supabase.from('daily_logs').upsert({
                      'user_id': user.id,
                      'log_date': todayStr,
                      'is_period_day': true,
                      'symptoms': ['Menstruasi (Haid)'],
                    }, onConflict: 'user_id,log_date');

                    await _fetchUserProfile();
                    await _fetchLoggedDates();
                    if (context.mounted) {
                      ToastHelper.showSuccess(context, 'Selamat! Pelacakan siklus haid pertamamu telah aktif. 🌸');
                    }
                  } catch (e) {
                    debugPrint('Failed to initialize first period: $e');
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF8B5CF6),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  'Mulai Pelacakan',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildLegendItem(Color color, String label, {bool isOutline = false}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            color: isOutline ? color.withValues(alpha: 0.15) : color,
            shape: BoxShape.circle,
            border: isOutline ? Border.all(color: color, width: 1.5) : null,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildMonthView(DateTime month) {
    final title = '${['Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni', 'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'][month.month - 1]} ${month.year}';
    final firstDayWeekday = DateTime(month.year, month.month, 1).weekday;
    final totalDays = DateTime(month.year, month.month + 1, 0).day;
    final offsetCells = firstDayWeekday - 1; 

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.purple.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 8.0, bottom: 16),
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF581C87),
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: ['S', 'S', 'R', 'K', 'J', 'S', 'M'].map((day) {
              return SizedBox(
                width: 36,
                child: Text(
                  day,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade400,
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
            ),
            itemCount: offsetCells + totalDays,
            itemBuilder: (context, index) {
              if (index < offsetCells) {
                return const SizedBox();
              }
              
              final dayNum = index - offsetCells + 1;
              final day = DateTime(month.year, month.month, dayNum);
              final normalized = DateTime(day.year, day.month, day.day);
              
              final isSelected = !_isEditing && _isSameDay(_selectedDay, day);
              final isToday = _isSameDay(TimeHelper.nowWIB(), day);
              final isPeriod = _isPeriodDay(day);
              final isPrediction = _isPredictionDay(day);
              final isFertile = _isFertileDay(day);
              final isEditingSelected = _isEditing && _editingPeriodDays.contains(normalized);

              BoxDecoration? decoration;
              TextStyle textStyle = const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Color(0xFF1E293B),
              );

              if (isEditingSelected || isPeriod) {
                decoration = const BoxDecoration(
                  color: Color(0xFFEC4899),
                  shape: BoxShape.circle,
                );
                textStyle = const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                );
                if (isSelected) {
                  decoration = BoxDecoration(
                    color: const Color(0xFFEC4899),
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFF8B5CF6), width: 2.5),
                  );
                }
              } else if (isPrediction) {
                decoration = BoxDecoration(
                  color: const Color(0xFFFCE7F3),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFFF472B6),
                    width: 1.5,
                  ),
                );
                textStyle = const TextStyle(
                  color: Color(0xFFEC4899),
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                );
                if (isSelected) {
                  decoration = decoration.copyWith(
                    border: Border.all(color: const Color(0xFF8B5CF6), width: 2.5),
                  );
                }
              } else if (isFertile) {
                decoration = BoxDecoration(
                  color: const Color(0xFFEDE9FE),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFFA78BFA),
                    width: 1.5,
                  ),
                );
                textStyle = const TextStyle(
                  color: Color(0xFF7C3AED),
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                );
                if (isSelected) {
                  decoration = decoration.copyWith(
                    border: Border.all(color: const Color(0xFF8B5CF6), width: 2.5),
                  );
                }
              } else if (isSelected) {
                decoration = const BoxDecoration(
                  color: Color(0xFF8B5CF6),
                  shape: BoxShape.circle,
                );
                textStyle = const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                );
              } else if (isToday) {
                decoration = const BoxDecoration(
                  color: Color(0xFFC4B5FD),
                  shape: BoxShape.circle,
                );
                textStyle = const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                );
              }

              return GestureDetector(
                onTap: () {
                  if (_isEditing) {
                    if (day.year != _editingMonth?.year || day.month != _editingMonth?.month) {
                      ToastHelper.showInfo(context, 'Hanya bisa mengedit tanggal di bulan ${_editingMonth?.month}/${_editingMonth?.year}');
                      return;
                    }
                    setState(() {
                      if (_editingPeriodDays.contains(normalized)) {
                        _editingPeriodDays.remove(normalized);
                      } else {
                        _editingPeriodDays.add(normalized);
                      }
                    });
                  } else {
                    setState(() {
                      _selectedDay = normalized;
                    });
                  }
                },
                child: Container(
                  alignment: Alignment.center,
                  decoration: decoration,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Text(
                        '$dayNum',
                        style: textStyle,
                      ),
                      if (!_isEditing &&
                          _loggedDates.contains(normalized) &&
                          !isPeriod &&
                          !isPrediction &&
                          !isFertile)
                        Positioned(
                          bottom: 4,
                          child: Container(
                            width: 5,
                            height: 5,
                            decoration: const BoxDecoration(
                              color: Color(0xFFD946EF),
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSelectedDayInfo() {
    if (_selectedDay == null) return const SizedBox();
    
    final day = _selectedDay!;
    final isPeriod = _isPeriodDay(day);
    final isPrediction = _isPredictionDay(day);
    final isFertile = _isFertileDay(day);
    
    String title = '';
    String description = '';
    IconData icon = Icons.calendar_today_rounded;
    Color iconColor = Colors.grey;
    Color bgColor = Colors.grey.shade50;
    Color borderColor = Colors.grey.shade200;

    final dateStr = '${day.day}/${day.month}/${day.year}';

    if (isPeriod) {
      icon = Icons.water_drop_rounded;
      iconColor = const Color(0xFFEC4899);
      bgColor = const Color(0xFFFFF1F2);
      borderColor = const Color(0xFFFECDD3);
      
      int dayNumber = 1;
      DateTime start = DateTime(day.year, day.month, day.day);
      while (_isPeriodDay(start.subtract(const Duration(days: 1)))) {
        start = start.subtract(const Duration(days: 1));
      }
      dayNumber = day.difference(start).inDays + 1;
      title = 'Haid Hari ke-$dayNumber';
      
      final tips = [
        'Istirahat yang cukup dan minum air putih hangat ya! 🍵',
        'Gunakan kompres hangat jika perutmu terasa kram. 🌸',
        'Jaga kebersihan diri dan ganti pembalut secara teratur. ✨',
        'Konsumsi makanan kaya zat besi seperti sayuran hijau. 🥦',
        'Lakukan peregangan ringan untuk membantu meredakan nyeri. 🧘‍♀️',
        'Tubuhmu sedang bekerja keras, manjakan dirimu hari ini! 💕',
        'Haid hampir selesai. Tetap jaga kesehatan ya! 🌟'
      ];
      description = tips[(dayNumber - 1) % tips.length];
    } else if (isPrediction) {
      icon = Icons.auto_awesome_rounded;
      iconColor = const Color(0xFFD946EF);
      bgColor = const Color(0xFFFDF4FF);
      borderColor = const Color(0xFFFBCFE8);
      title = 'Prediksi Haid';
      description = 'Diperkirakan haid akan mulai. Siapkan pembalut di tasmu untuk berjaga-jaga! 🎒';
    } else if (isFertile) {
      icon = Icons.favorite_rounded;
      iconColor = const Color(0xFF8B5CF6);
      bgColor = const Color(0xFFF5F3FF);
      borderColor = const Color(0xFFDDD6FE);
      title = 'Masa Subur';
      description = 'Peluang kesuburan lebih tinggi. Tubuhmu sedang dalam kondisi prima! ✨';
    } else {
      icon = Icons.event_note_rounded;
      iconColor = const Color(0xFF64748B);
      bgColor = const Color(0xFFF8FAFC);
      borderColor = const Color(0xFFE2E8F0);
      title = 'Hari Biasa';
      description = 'Tidak ada catatan atau prediksi menstruasi pada hari ini. 📅';
    }

    final isToday = _isSameDay(TimeHelper.nowWIB(), day);
    final dayLabel = isToday ? 'Hari Ini' : dateStr;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor, width: 1.5),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: iconColor,
                      ),
                    ),
                    Text(
                      dayLabel,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.black87,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomPanel() {
    if (_hasMenstruated == false && !_isEditing) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.spa_rounded,
            size: 48,
            color: Color(0xFFEC4899),
          ),
          const SizedBox(height: 12),
          const Text(
            'Fase Persiapan 🌸',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF581C87),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Kamu berada dalam fase persiapan. Klik tombol di bawah jika kamu mendapatkan haid pertamamu untuk mulai melacak siklus sehatmu!',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _showFirstHaidDialog(context),
              icon: const Icon(Icons.favorite_rounded),
              label: const Text('Saya Mendapat Haid Pertama!'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFEC4899),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
        ],
      );
    }

    if (_isEditing) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '${_editingPeriodDays.length} hari dipilih pada bulan ${_editingMonth?.month}/${_editingMonth?.year}',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFFEC4899),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Ketuk tanggal di kalender untuk menambah atau menghapus hari haid pada bulan ini.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: Colors.black54,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                flex: 1,
                child: OutlinedButton(
                  onPressed: _cancelEditMode,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.grey.shade700,
                    side: BorderSide(color: Colors.grey.shade300),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text('Batal', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: ElevatedButton.icon(
                  onPressed: _isSaving ? null : _saveAndAnalyze,
                  icon: _isSaving
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Icon(Icons.auto_awesome_rounded),
                  label: Text(_isSaving ? 'Menyimpan...' : 'Simpan & Analisis'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFEC4899),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    textStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildSelectedDayInfo(),
        const SizedBox(height: 16),
        ElevatedButton.icon(
          onPressed: _enterEditMode,
          icon: const Icon(Icons.edit_calendar_rounded),
          label: const Text('Catat / Edit Tanggal Haid'),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF8B5CF6),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          'Kalender Haid',
          style: TextStyle(color: Color(0xFF581C87), fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF581C87)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          Column(
            children: [
              if (!_isEditing)
                Container(
                  color: Colors.white,
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  child: Wrap(
                    spacing: 16,
                    runSpacing: 8,
                    alignment: WrapAlignment.center,
                    children: [
                      _buildLegendItem(const Color(0xFFEC4899), 'Haid'),
                      _buildLegendItem(const Color(0xFFF472B6), 'Prediksi', isOutline: true),
                      _buildLegendItem(const Color(0xFFA78BFA), 'Masa Subur', isOutline: true),
                    ],
                  ),
                ),
                
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  itemCount: _months.length,
                  itemBuilder: (context, index) {
                    return _buildMonthView(_months[index]);
                  },
                ),
              ),

              Container(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 20,
                      offset: const Offset(0, -5),
                    )
                  ],
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
                ),
                child: _buildBottomPanel(),
              ),
            ],
          ),
          
          if (_isSaving)
            Container(
              color: Colors.black.withValues(alpha: 0.3),
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF8B5CF6)),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Menganalisis siklusmu dengan AI...',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
