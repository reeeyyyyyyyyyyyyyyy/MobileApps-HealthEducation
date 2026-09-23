import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../theme/uticare_theme.dart';

class CheckRiskPage extends StatefulWidget {
  const CheckRiskPage({super.key});

  @override
  State<CheckRiskPage> createState() => _CheckRiskPageState();
}

class _CheckRiskPageState extends State<CheckRiskPage> {
  List<Map<String, dynamic>> _questions = [];
  Map<int, List<Map<String, dynamic>>> _optionsMap = {};
  Map<int, int> _selectedAnswers = {}; // questionId -> optionId
  bool _isLoading = true;
  bool _isSubmitting = false;
  bool _showResult = false;
  int _totalScore = 0;
  int _maxScore = 0;
  String _riskLevel = '';
  List<Map<String, dynamic>> _history = [];

  @override
  void initState() {
    super.initState();
    _fetchQuestions();
    _fetchHistory();
  }

  Future<void> _fetchQuestions() async {
    try {
      final questions = await Supabase.instance.client
          .from('risk_questions')
          .select()
          .eq('is_active', true)
          .order('question_order', ascending: true);

      final allOptions = await Supabase.instance.client
          .from('risk_options')
          .select()
          .order('option_order', ascending: true);

      final Map<int, List<Map<String, dynamic>>> optMap = {};
      for (var opt in allOptions) {
        final qId = opt['question_id'] as int;
        optMap.putIfAbsent(qId, () => []);
        optMap[qId]!.add(Map<String, dynamic>.from(opt));
      }

      if (mounted) {
        setState(() {
          _questions = List<Map<String, dynamic>>.from(questions);
          _optionsMap = optMap;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error fetching risk questions: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _fetchHistory() async {
    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) return;
      final data = await Supabase.instance.client
          .from('risk_results')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false)
          .limit(5);
      if (mounted) {
        setState(() => _history = List<Map<String, dynamic>>.from(data));
      }
    } catch (_) {}
  }

  Future<void> _submitCheckRisk() async {
    if (_selectedAnswers.length < _questions.length) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Jawab semua pertanyaan terlebih dahulu')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      int total = 0;
      int maxPossible = 0;

      for (var q in _questions) {
        final qId = q['id'] as int;
        final opts = _optionsMap[qId] ?? [];
        final selectedOptId = _selectedAnswers[qId];

        // Find selected option's score
        for (var opt in opts) {
          if (opt['id'] == selectedOptId) {
            total += (opt['score'] as int? ?? 0);
          }
        }

        // Find max score for this question
        int maxQ = 0;
        for (var opt in opts) {
          final s = opt['score'] as int? ?? 0;
          if (s > maxQ) maxQ = s;
        }
        maxPossible += maxQ;
      }

      final level = UtiCareTheme.getRiskLabel(total, maxPossible > 0 ? maxPossible : 1);

      // Save result
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId != null) {
        final answersJson = <String, dynamic>{};
        _selectedAnswers.forEach((qId, optId) {
          answersJson[qId.toString()] = optId;
        });

        await Supabase.instance.client.from('risk_results').insert({
          'user_id': userId,
          'total_score': total,
          'risk_level': level.toLowerCase(),
          'answers': answersJson,
        });
      }

      if (mounted) {
        setState(() {
          _totalScore = total;
          _maxScore = maxPossible;
          _riskLevel = level;
          _showResult = true;
          _isSubmitting = false;
        });
        _fetchHistory();
      }
    } catch (e) {
      debugPrint('Error submitting check risk: $e');
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _resetQuiz() {
    setState(() {
      _selectedAnswers = {};
      _showResult = false;
      _totalScore = 0;
      _maxScore = 0;
      _riskLevel = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: UtiCareTheme.background,
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator(color: UtiCareTheme.primary))
            : _showResult
                ? _buildResultView()
                : _buildQuestionView(),
      ),
    );
  }

  Widget _buildQuestionView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Check Risk', style: UtiCareTheme.heading1),
              const SizedBox(height: 4),
              Text(
                'Yuk, cek risikomu! Jawab beberapa pertanyaan di bawah ini',
                style: UtiCareTheme.body.copyWith(color: UtiCareTheme.textSecondary),
              ),
            ],
          ),
        ),

        const SizedBox(height: 8),

        // Progress
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              Text(
                '${_selectedAnswers.length}/${_questions.length} dijawab',
                style: UtiCareTheme.caption.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(UtiCareTheme.radiusRound),
                  child: LinearProgressIndicator(
                    value: _questions.isEmpty ? 0 : _selectedAnswers.length / _questions.length,
                    backgroundColor: UtiCareTheme.borderLight,
                    valueColor: const AlwaysStoppedAnimation(UtiCareTheme.primary),
                    minHeight: 6,
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Questions
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: _questions.length,
            itemBuilder: (context, index) {
              final q = _questions[index];
              final qId = q['id'] as int;
              final opts = _optionsMap[qId] ?? [];

              return Container(
                margin: const EdgeInsets.only(bottom: 16),
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
                    const SizedBox(height: 12),
                    ...opts.map((opt) {
                      final isSelected = _selectedAnswers[qId] == opt['id'];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(UtiCareTheme.radiusMd),
                          onTap: () {
                            setState(() => _selectedAnswers[qId] = opt['id'] as int);
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                            decoration: BoxDecoration(
                              color: isSelected ? UtiCareTheme.primarySubtle : UtiCareTheme.surfaceAlt,
                              borderRadius: BorderRadius.circular(UtiCareTheme.radiusMd),
                              border: Border.all(
                                color: isSelected ? UtiCareTheme.primary : UtiCareTheme.border,
                                width: isSelected ? 2 : 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 22,
                                  height: 22,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: isSelected ? UtiCareTheme.primary : Colors.transparent,
                                    border: Border.all(
                                      color: isSelected ? UtiCareTheme.primary : UtiCareTheme.textTertiary,
                                      width: 2,
                                    ),
                                  ),
                                  child: isSelected
                                      ? const Icon(Icons.check_rounded, size: 14, color: Colors.white)
                                      : null,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    opt['option_text'] ?? '',
                                    style: TextStyle(
                                      fontSize: 14,
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

        // Submit button
        Padding(
          padding: const EdgeInsets.all(20),
          child: SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: _isSubmitting ? null : _submitCheckRisk,
              child: _isSubmitting
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Text('Selanjutnya'),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildResultView() {
    final riskColor = UtiCareTheme.getRiskColor(_riskLevel.toLowerCase());
    final riskBg = UtiCareTheme.getRiskBgColor(_riskLevel.toLowerCase());

    String recommendation;
    switch (_riskLevel) {
      case 'RENDAH':
        recommendation = 'Kamu sedang dalam kondisi baik! Pertahankan kebiasaan sehatmu.';
        break;
      case 'SEDANG':
        recommendation = 'Perlu perhatian lebih. Tingkatkan konsumsi air putih dan kebersihan area genital.';
        break;
      case 'TINGGI':
        recommendation = 'Segera konsultasikan ke tenaga kesehatan. Perbaiki kebiasaan harian untuk menurunkan risiko ISK.';
        break;
      default:
        recommendation = 'Terus pantau kesehatanmu.';
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const SizedBox(height: 20),

          // Risk level card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: UtiCareTheme.primaryGradient,
              borderRadius: BorderRadius.circular(UtiCareTheme.radiusXl),
              boxShadow: UtiCareTheme.elevatedShadow,
            ),
            child: Column(
              children: [
                Text(
                  'Risiko ISK-mu',
                  style: UtiCareTheme.subtitle.copyWith(color: Colors.white.withValues(alpha: 0.8)),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                  decoration: BoxDecoration(
                    color: riskBg,
                    borderRadius: BorderRadius.circular(UtiCareTheme.radiusRound),
                  ),
                  child: Text(
                    _riskLevel,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: riskColor,
                      letterSpacing: 2,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Skor: $_totalScore / $_maxScore',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Recommendation
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: riskBg,
              borderRadius: BorderRadius.circular(UtiCareTheme.radiusLg),
              border: Border.all(color: riskColor.withValues(alpha: 0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.lightbulb_rounded, color: riskColor, size: 20),
                    const SizedBox(width: 8),
                    Text('Rekomendasi', style: UtiCareTheme.bodyBold),
                  ],
                ),
                const SizedBox(height: 8),
                Text(recommendation, style: UtiCareTheme.body.copyWith(height: 1.5)),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Action buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _resetQuiz,
                  child: const Text('Cek Ulang'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Lihat Detail'),
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // History
          if (_history.isNotEmpty) ...[
            Align(
              alignment: Alignment.centerLeft,
              child: Text('Riwayat Check Risk', style: UtiCareTheme.heading3),
            ),
            const SizedBox(height: 12),
            ..._history.map((h) {
              final level = (h['risk_level'] ?? '').toString();
              final score = h['total_score'] ?? 0;
              final createdAt = h['created_at'] ?? '';
              final dateStr = createdAt.toString().substring(0, 10);
              final color = UtiCareTheme.getRiskColor(level);

              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: UtiCareTheme.surface,
                  borderRadius: BorderRadius.circular(UtiCareTheme.radiusMd),
                  border: Border.all(color: UtiCareTheme.border),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(UtiCareTheme.radiusRound),
                      ),
                      child: Text(
                        level.toUpperCase(),
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: color),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text('Skor: $score', style: UtiCareTheme.bodyBold),
                    const Spacer(),
                    Text(dateStr, style: UtiCareTheme.caption),
                  ],
                ),
              );
            }),
          ],
        ],
      ),
    );
  }
}
