import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../utils/toast_helper.dart';

class TrackerDetailPage extends StatefulWidget {
  const TrackerDetailPage({super.key});

  @override
  State<TrackerDetailPage> createState() => _TrackerDetailPageState();
}

class _TrackerDetailPageState extends State<TrackerDetailPage> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  Set<DateTime> _loggedDates = {};
  Set<DateTime> _manualPeriodDates = {};

  DateTime? _lastPeriodDate;
  int _avgPeriodDuration = 5;
  int _avgCycleLength = 28;

  final SupabaseClient _supabase = Supabase.instance.client;

  @override
  void initState() {
    super.initState();
    _selectedDay = DateTime.now();
    _fetchUserProfile().then((_) {
      _fetchLoggedDates();
    });
  }

  Future<void> _fetchUserProfile() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;

    try {
      final response = await _supabase
          .from('profiles')
          .select('last_period_date, avg_period_duration, avg_cycle_length')
          .eq('id', user.id)
          .maybeSingle();

      if (response != null && mounted) {
        setState(() {
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
          .select('log_date, symptoms')
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
          
          final symptomsRaw = row['symptoms'] as List<dynamic>?;
          if (symptomsRaw != null && symptomsRaw.contains('Menstruasi (Haid)')) {
            manualPeriods.add(normalized);
          }
        }
      }

      setState(() {
        _loggedDates = dates;
        _manualPeriodDates = manualPeriods;
      });
    } catch (e) {
      debugPrint('Error fetching logged dates: $e');
    }
  }

  bool _isPeriodDay(DateTime date) {
    final checkDate = DateTime(date.year, date.month, date.day);
    // 1. Manually logged period
    if (_manualPeriodDates.contains(checkDate)) return true;

    // 2. Calculated period days starting at _lastPeriodDate
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
    if (_lastPeriodDate == null) return false;
    final checkDate = DateTime(date.year, date.month, date.day);
    if (_isPeriodDay(checkDate)) return false;

    final startOfLatest = DateTime(_lastPeriodDate!.year, _lastPeriodDate!.month, _lastPeriodDate!.day);

    // Predict for 3 future cycles
    for (int i = 1; i <= 3; i++) {
      final predStart = startOfLatest.add(Duration(days: i * _avgCycleLength));
      final predEnd = predStart.add(Duration(days: _avgPeriodDuration - 1));
      if ((checkDate.isAfter(predStart) || checkDate.isAtSameMomentAs(predStart)) &&
          (checkDate.isBefore(predEnd) || checkDate.isAtSameMomentAs(predEnd))) {
        return true;
      }
    }
    return false;
  }

  void _showDailyLogBottomSheet() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return;

    final selectedDate = _selectedDay ?? DateTime.now();
    final dateStr = selectedDate.toIso8601String().split('T')[0];
    
    // Fetch existing log for selected day if any
    String? existingMood;
    List<String> existingSymptoms = [];
    
    try {
      final logResponse = await _supabase
          .from('daily_logs')
          .select('mood, symptoms')
          .eq('user_id', user.id)
          .eq('log_date', dateStr)
          .maybeSingle();

      if (logResponse != null) {
        existingMood = logResponse['mood'] as String?;
        final symptomsRaw = logResponse['symptoms'] as List<dynamic>?;
        if (symptomsRaw != null) {
          existingSymptoms = symptomsRaw.map((e) => e.toString()).toList();
        }
      }
    } catch (e) {
      debugPrint('Error fetching log: $e');
    }

    if (!mounted) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return _DailyLogForm(
          initialMood: existingMood,
          initialSymptoms: existingSymptoms,
          onSave: (mood, symptoms) async {
            try {
              await _supabase.from('daily_logs').upsert({
                'user_id': user.id,
                'log_date': dateStr,
                'mood': mood,
                'symptoms': symptoms,
              }, onConflict: 'user_id,log_date');

              // If "Menstruasi (Haid)" is selected, potentially update last_period_date
              if (symptoms.contains('Menstruasi (Haid)')) {
                bool shouldUpdateProfile = false;
                if (_lastPeriodDate == null) {
                  shouldUpdateProfile = true;
                } else {
                  final diff = selectedDate.difference(_lastPeriodDate!).inDays.abs();
                  // If it's at least avg_period_duration days away from the last period start date, update it
                  if (diff >= _avgPeriodDuration) {
                    shouldUpdateProfile = true;
                  }
                }

                if (shouldUpdateProfile) {
                  await _supabase.from('profiles').update({
                    'last_period_date': dateStr,
                  }).eq('id', user.id);
                  await _fetchUserProfile();
                }
              } else {
                // If it was manually checked before but now unchecked, and is the last_period_date,
                // we might want to revert last_period_date. But for simplicity, we don't force a reset
                // unless required. Just removing manualPeriodDate handles the calendar rendering override.
              }
              
              await _fetchLoggedDates();
              
              if (context.mounted) {
                ToastHelper.showSuccess(context, 'Catatan harian berhasil disimpan! 🌸');
                Navigator.pop(context);
              }
            } catch (e) {
              debugPrint('Error saving daily log: $e');
              if (context.mounted) {
                ToastHelper.showError(context, 'Gagal menyimpan catatan: $e');
              }
            }
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final selectedDate = _selectedDay ?? DateTime.now();
    final isTodaySelected = isSameDay(selectedDate, DateTime.now());

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          'Kalender Siklus',
          style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF581C87)),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF581C87)),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Calendar Card
          Container(
            margin: const EdgeInsets.all(16.0),
            padding: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: TableCalendar(
              firstDay: DateTime.now().subtract(const Duration(days: 365)),
              lastDay: DateTime.now().add(const Duration(days: 365)),
              focusedDay: _focusedDay,
              calendarFormat: _calendarFormat,
              selectedDayPredicate: (day) {
                return isSameDay(_selectedDay, day);
              },
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });
              },
              onFormatChanged: (format) {
                setState(() {
                  _calendarFormat = format;
                });
              },
              onPageChanged: (focusedDay) {
                _focusedDay = focusedDay;
              },
              calendarStyle: const CalendarStyle(
                todayDecoration: BoxDecoration(
                  color: Color(0xFFC4B5FD),
                  shape: BoxShape.circle,
                ),
                selectedDecoration: BoxDecoration(
                  color: Color(0xFF8B5CF6),
                  shape: BoxShape.circle,
                ),
                markerSize: 6,
                markersMaxCount: 1,
              ),
              calendarBuilders: CalendarBuilders(
                prioritizedBuilder: (context, day, focusedDay) {
                  final isSelected = isSameDay(_selectedDay, day);
                  final isToday = isSameDay(DateTime.now(), day);
                  final isPeriod = _isPeriodDay(day);
                  final isPrediction = _isPredictionDay(day);
                  final isOutside = day.month != focusedDay.month;

                  TextStyle textStyle = TextStyle(
                    color: isOutside ? Colors.grey.shade400 : const Color(0xFF1E293B),
                    fontWeight: FontWeight.normal,
                  );

                  BoxDecoration? decoration;

                  if (isPeriod) {
                    decoration = BoxDecoration(
                      color: const Color(0xFFEC4899), // Solid pink for menstruation
                      shape: BoxShape.circle,
                      border: isSelected
                          ? Border.all(color: const Color(0xFF8B5CF6), width: 2)
                          : null,
                    );
                    textStyle = const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    );
                  } else if (isPrediction) {
                    decoration = BoxDecoration(
                      color: const Color(0xFFFCE7F3), // Light pink fill
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFFF472B6), // Light pink outline
                        width: 1.5,
                      ),
                    );
                    textStyle = const TextStyle(
                      color: Color(0xFFEC4899), // Pink text
                      fontWeight: FontWeight.bold,
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
                    );
                  } else if (isToday) {
                    decoration = const BoxDecoration(
                      color: Color(0xFFC4B5FD),
                      shape: BoxShape.circle,
                    );
                    textStyle = const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    );
                  }

                  if (decoration != null) {
                    return Container(
                      margin: const EdgeInsets.all(4.0),
                      alignment: Alignment.center,
                      decoration: decoration,
                      child: Text(
                        '${day.day}',
                        style: textStyle,
                      ),
                    );
                  }

                  return null;
                },
                markerBuilder: (context, date, events) {
                  final normalizedDate = DateTime(date.year, date.month, date.day);
                  if (_loggedDates.contains(normalizedDate) && !_isPeriodDay(date) && !_isPredictionDay(date)) {
                    return Positioned(
                      bottom: 4,
                      child: Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          color: Color(0xFFD946EF),
                          shape: BoxShape.circle,
                        ),
                      ),
                    );
                  }
                  return null;
                },
              ),
              headerStyle: const HeaderStyle(
                formatButtonVisible: false,
                titleCentered: true,
                titleTextStyle: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF581C87),
                ),
              ),
            ),
          ),

          // Log Helper Panel
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.favorite_outline_rounded,
                    size: 64,
                    color: _isPeriodDay(selectedDate)
                        ? const Color(0xFFEC4899)
                        : const Color(0xFFD946EF),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    isTodaySelected
                        ? 'Bagaimana kondisimu hari ini?'
                        : 'Catatan Tanggal ${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF581C87),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    isTodaySelected
                        ? 'Ketuk tombol di bawah untuk mencatat mood dan gejala fisikmu hari ini.'
                        : 'Ketuk tombol di bawah untuk menambahkan atau mengubah catatan mood dan gejalanya.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: _showDailyLogBottomSheet,
                    icon: const Icon(Icons.edit_note_rounded),
                    label: Text(isTodaySelected ? 'Catat Mood & Gejala' : 'Ubah Catatan Harian'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF8B5CF6),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
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

class _DailyLogForm extends StatefulWidget {
  final String? initialMood;
  final List<String> initialSymptoms;
  final Function(String mood, List<String> symptoms) onSave;

  const _DailyLogForm({
    this.initialMood,
    required this.initialSymptoms,
    required this.onSave,
  });

  @override
  State<_DailyLogForm> createState() => _DailyLogFormState();
}

class _DailyLogFormState extends State<_DailyLogForm> {
  String? _selectedMood;
  List<String> _selectedSymptoms = [];
  bool _isSaving = false;

  final List<Map<String, String>> _moods = [
    {'name': 'Senang', 'emoji': '😊'},
    {'name': 'Sedih', 'emoji': '😢'},
    {'name': 'Sensitif', 'emoji': '🥺'},
    {'name': 'Marah', 'emoji': '😡'},
  ];

  final List<String> _symptoms = [
    'Menstruasi (Haid)',
    'Kram perut',
    'Jerawat',
    'Payudara Nyeri',
  ];

  @override
  void initState() {
    super.initState();
    _selectedMood = widget.initialMood;
    _selectedSymptoms = List.from(widget.initialSymptoms);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(28),
          topRight: Radius.circular(28),
        ),
      ),
      padding: EdgeInsets.only(
        top: 24,
        left: 24,
        right: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Top Notch
            Center(
              child: Container(
                width: 40,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Catatan Hari Ini 📝',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF581C87),
              ),
            ),
            const SizedBox(height: 20),

            // Mood Selector
            const Text(
              'Bagaimana mood kamu?',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _moods.map((mood) {
                final isSelected = _selectedMood == mood['name'];
                return ChoiceChip(
                  label: Text('${mood['emoji']} ${mood['name']}'),
                  selected: isSelected,
                  selectedColor: const Color(0xFFEDE9FE),
                  checkmarkColor: const Color(0xFF8B5CF6),
                  labelStyle: TextStyle(
                    color: isSelected ? const Color(0xFF8B5CF6) : Colors.black87,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                  onSelected: (selected) {
                    setState(() {
                      _selectedMood = selected ? mood['name'] : null;
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            // Symptoms Selector
            const Text(
              'Apakah ada gejala fisik?',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _symptoms.map((symptom) {
                final isSelected = _selectedSymptoms.contains(symptom);
                return FilterChip(
                  label: Text(symptom),
                  selected: isSelected,
                  selectedColor: const Color(0xFFFDF4FF),
                  checkmarkColor: const Color(0xFFD946EF),
                  labelStyle: TextStyle(
                    color: isSelected ? const Color(0xFFD946EF) : Colors.black87,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _selectedSymptoms.add(symptom);
                      } else {
                        _selectedSymptoms.remove(symptom);
                      }
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 32),

            // Save Button
            ElevatedButton(
              onPressed: _isSaving || _selectedMood == null
                  ? null
                  : () async {
                      setState(() {
                        _isSaving = true;
                      });
                      await widget.onSave(_selectedMood!, _selectedSymptoms);
                      if (mounted) {
                        setState(() {
                          _isSaving = false;
                        });
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF8B5CF6),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: _isSaving
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Text(
                      'Simpan Catatan',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
