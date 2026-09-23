import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../theme/uticare_theme.dart';
import '../main.dart';

class PretestPage extends StatefulWidget {
  const PretestPage({super.key});

  @override
  State<PretestPage> createState() => _PretestPageState();
}

class _PretestPageState extends State<PretestPage> {
  List<Map<String, dynamic>> _instruments = [];
  Map<int, List<Map<String, dynamic>>> _optionsMap = {};
  final Map<int, int> _selectedAnswers = {};
  bool _isLoading = true;
  bool _isSubmitting = false;
  int _currentSection = 0; // 0=pengetahuan, 1=sikap, 2=perilaku

  final List<Map<String, String>> _sections = [
    {'key': 'pengetahuan', 'label': 'Pengetahuan', 'desc': 'Tentang Infeksi Saluran Kemih'},
    {'key': 'sikap', 'label': 'Sikap', 'desc': 'Terhadap pencegahan ISK'},
    {'key': 'perilaku', 'label': 'Perilaku', 'desc': 'Kebiasaan harian pencegahan ISK'},
  ];

  @override
  void initState() {
    super.initState();
    _fetchInstruments();
  }

  Future<void> _fetchInstruments() async {
    try {
      final instruments = await Supabase.instance.client
          .from('survey_instruments')
          .select()
          .eq('type', 'pretest')
          .eq('is_active', true)
          .order('question_order', ascending: true);

      final allOptions = await Supabase.instance.client
          .from('survey_options')
          .select()
          .order('option_order', ascending: true);

      final Map<int, List<Map<String, dynamic>>> optMap = {};
      for (var opt in allOptions) {
        final iId = opt['instrument_id'] as int;
        optMap.putIfAbsent(iId, () => []);
        optMap[iId]!.add(Map<String, dynamic>.from(opt));
      }

      if (mounted) {
        setState(() {
          _instruments = List<Map<String, dynamic>>.from(instruments);
          _optionsMap = optMap;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error fetching pretest: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  List<Map<String, dynamic>> get _currentQuestions {
    final sectionKey = _sections[_currentSection]['key']!;
    return _instruments.where((i) => i['variable'] == sectionKey).toList();
  }

  bool get _isCurrentSectionComplete {
    final questions = _currentQuestions;
    return questions.every((q) => _selectedAnswers.containsKey(q['id']));
  }

  bool get _isAllComplete {
    return _instruments.every((q) => _selectedAnswers.containsKey(q['id']));
  }

  int get _totalAnswered {
    return _selectedAnswers.length;
  }

  void _nextSection() {
    if (!_isCurrentSectionComplete) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Jawab semua pertanyaan di bagian ini')),
      );
      return;
    }

    if (_currentSection < 2) {
      setState(() => _currentSection++);
    } else {
      _submitPretest();
    }
  }

  void _prevSection() {
    if (_currentSection > 0) {
      setState(() => _currentSection--);
    }
  }

  Future<void> _submitPretest() async {
    if (!_isAllComplete) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Jawab semua pertanyaan terlebih dahulu')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final userId = Supabase.instance.client.auth.currentUser!.id;

      final List<Map<String, dynamic>> responses = [];
      _selectedAnswers.forEach((instrumentId, optionId) {
        responses.add({
          'user_id': userId,
          'instrument_id': instrumentId,
          'selected_option_id': optionId,
          'type': 'pretest',
        });
      });

      await Supabase.instance.client.from('survey_responses').insert(responses);

      await Supabase.instance.client.from('profiles').update({
        'has_completed_pretest': true,
        'pretest_completed_at': DateTime.now().toUtc().toIso8601String(),
      }).eq('id', userId);

      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const MainScreen()),
        );
      }
    } catch (e) {
      debugPrint('Error submitting pretest: $e');
      if (mounted) {
        setState(() => _isSubmitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Gagal menyimpan. Coba lagi.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: UtiCareTheme.background,
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator(color: UtiCareTheme.primary))
            : Column(
                children: [
                  // Header
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Pre-Test Kuesioner',
                          style: UtiCareTheme.heading2,
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Sebelum menggunakan aplikasi, mohon jawab pertanyaan berikut.',
                          style: UtiCareTheme.body,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Section tabs
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: List.generate(3, (index) {
                        final section = _sections[index];
                        final isActive = _currentSection == index;
                        final sectionQuestions = _instruments.where((i) => i['variable'] == section['key']).toList();
                        final sectionAnswered = sectionQuestions.where((q) => _selectedAnswers.containsKey(q['id'])).length;
                        final isComplete = sectionQuestions.isNotEmpty && sectionAnswered == sectionQuestions.length;

                        return Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => _currentSection = index),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                color: isActive ? UtiCareTheme.primary : Colors.transparent,
                                borderRadius: BorderRadius.circular(UtiCareTheme.radiusMd),
                              ),
                              child: Column(
                                children: [
                                  Text(
                                    section['label']!,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: isActive ? Colors.white : UtiCareTheme.textSecondary,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '$sectionAnswered/${sectionQuestions.length}',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                      color: isActive
                                          ? Colors.white.withValues(alpha: 0.8)
                                          : isComplete
                                              ? UtiCareTheme.success
                                              : UtiCareTheme.textTertiary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Overall progress
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(UtiCareTheme.radiusRound),
                      child: LinearProgressIndicator(
                        value: _instruments.isEmpty ? 0 : _totalAnswered / _instruments.length,
                        backgroundColor: UtiCareTheme.borderLight,
                        valueColor: const AlwaysStoppedAnimation(UtiCareTheme.primary),
                        minHeight: 4,
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Questions
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: _currentQuestions.length,
                      itemBuilder: (context, index) {
                        final q = _currentQuestions[index];
                        final qId = q['id'] as int;
                        final opts = _optionsMap[qId] ?? [];

                        return Container(
                          margin: const EdgeInsets.only(bottom: 14),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: UtiCareTheme.surface,
                            borderRadius: BorderRadius.circular(UtiCareTheme.radiusLg),
                            border: Border.all(
                              color: _selectedAnswers.containsKey(qId)
                                  ? UtiCareTheme.success.withValues(alpha: 0.5)
                                  : UtiCareTheme.border,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${index + 1}. ${q['question_text']}',
                                style: UtiCareTheme.bodyBold,
                              ),
                              const SizedBox(height: 10),
                              ...opts.map((opt) {
                                final isSelected = _selectedAnswers[qId] == opt['id'];
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 6),
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(UtiCareTheme.radiusSm),
                                    onTap: () {
                                      setState(() => _selectedAnswers[qId] = opt['id'] as int);
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                      decoration: BoxDecoration(
                                        color: isSelected ? UtiCareTheme.primarySubtle : UtiCareTheme.surfaceAlt,
                                        borderRadius: BorderRadius.circular(UtiCareTheme.radiusSm),
                                        border: Border.all(
                                          color: isSelected ? UtiCareTheme.primary : UtiCareTheme.border,
                                          width: isSelected ? 2 : 1,
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          Container(
                                            width: 20,
                                            height: 20,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: isSelected ? UtiCareTheme.primary : Colors.transparent,
                                              border: Border.all(
                                                color: isSelected ? UtiCareTheme.primary : UtiCareTheme.textTertiary,
                                                width: 2,
                                              ),
                                            ),
                                            child: isSelected
                                                ? const Icon(Icons.check_rounded, size: 12, color: Colors.white)
                                                : null,
                                          ),
                                          const SizedBox(width: 10),
                                          Expanded(
                                            child: Text(
                                              opt['option_text'] ?? '',
                                              style: TextStyle(
                                                fontSize: 13,
                                                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                                                color: isSelected ? UtiCareTheme.primaryDark : UtiCareTheme.textPrimary,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              }),
                            ],
                          ),
                        );
                      },
                    ),
                  ),

                  // Navigation buttons
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        if (_currentSection > 0)
                          Expanded(
                            child: OutlinedButton(
                              onPressed: _prevSection,
                              child: const Text('Sebelumnya'),
                            ),
                          ),
                        if (_currentSection > 0) const SizedBox(width: 12),
                        Expanded(
                          flex: 2,
                          child: SizedBox(
                            height: 50,
                            child: ElevatedButton(
                              onPressed: _isSubmitting ? null : _nextSection,
                              child: _isSubmitting
                                  ? const SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                    )
                                  : Text(_currentSection < 2 ? 'Selanjutnya' : 'Kirim & Mulai'),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
