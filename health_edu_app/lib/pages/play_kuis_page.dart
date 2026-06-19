import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../main.dart';

class PlayKuisPage extends StatefulWidget {
  final String quizId;
  final String quizTitle;
  final int xpReward;

  const PlayKuisPage({
    super.key,
    required this.quizId,
    required this.quizTitle,
    required this.xpReward,
  });

  @override
  State<PlayKuisPage> createState() => _PlayKuisPageState();
}

class _PlayKuisPageState extends State<PlayKuisPage> {
  // === Design System Colors ===
  static const Color primaryColor = Color(0xFF8B5CF6);
  static const Color textPrimary = Color(0xFF1E293B);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color correctGreen = Color(0xFF10B981);
  static const Color incorrectRed = Color(0xFFEF4444);

  late Future<List<Map<String, dynamic>>> _questionsFuture;
  List<Map<String, dynamic>> _questions = [];
  int _currentQuestionIndex = 0;
  int? _selectedOptionIndex;
  bool _showFeedback = false;
  int _correctAnswersCount = 0;
  bool _isFinished = false;
  bool _isUpdatingProfile = false;

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  void _loadQuestions() {
    setState(() {
      _questionsFuture = _fetchQuestions();
    });
  }

  Future<List<Map<String, dynamic>>> _fetchQuestions() async {
    if (!isSupabaseInitialized) {
      throw Exception("Supabase belum diinisialisasi.");
    }
    final response = await Supabase.instance.client
        .from('questions')
        .select()
        .eq('quiz_id', widget.quizId);

    final list = List<Map<String, dynamic>>.from(response);
    _questions = list;
    return list;
  }

  void _handleOptionSelected(int optionIndex) {
    if (_showFeedback) return; // Prevent double clicking or changing answer

    final correctIndex = (_questions[_currentQuestionIndex]['correct_index'] as num?)?.toInt() ?? 0;
    final isCorrect = optionIndex == correctIndex;

    setState(() {
      _selectedOptionIndex = optionIndex;
      _showFeedback = true;
      if (isCorrect) {
        _correctAnswersCount++;
      }
    });
  }

  void _handleNextQuestion() {
    if (_currentQuestionIndex < _questions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
        _selectedOptionIndex = null;
        _showFeedback = false;
      });
    } else {
      // Quiz finished
      _finishQuiz();
    }
  }

  Future<void> _finishQuiz() async {
    setState(() {
      _isFinished = true;
      _isUpdatingProfile = true;
    });

    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user != null) {
        // Fetch current profile stats to increment
        final profile = await Supabase.instance.client
            .from('profiles')
            .select()
            .eq('id', user.id)
            .single();

        final currentXp = profile['total_xp'] ?? 0;
        final currentModulSelesai = profile['modul_selesai'] ?? 0;

        final newXp = currentXp + widget.xpReward;
        final newModulSelesai = currentModulSelesai + 1;
        // Simple level logic: Level 1 starts at 0 XP, goes up every 100 XP
        final newLevel = (newXp / 100).floor() + 1;

        await Supabase.instance.client.from('profiles').update({
          'total_xp': newXp,
          'modul_selesai': newModulSelesai,
          'level': newLevel,
        }).eq('id', user.id);
      }
    } catch (e) {
      debugPrint("Gagal memperbarui profil: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Gagal menyimpan skor: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUpdatingProfile = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded, color: textPrimary),
          onPressed: () => _showExitConfirmation(),
        ),
        title: Text(
          widget.quizTitle,
          style: const TextStyle(
            color: textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: _questionsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(color: primaryColor),
              );
            } else if (snapshot.hasError) {
              return _buildErrorState(snapshot.error.toString());
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(
                child: Padding(
                  padding: EdgeInsets.all(24.0),
                  child: Text(
                    'Kuis ini belum memiliki pertanyaan.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: textSecondary),
                  ),
                ),
              );
            }

            if (_isFinished) {
              return _buildFinishedState();
            }

            return _buildQuizPlayState();
          },
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────
  //  QUIZ PLAY VIEW
  // ─────────────────────────────────────────────
  Widget _buildQuizPlayState() {
    final currentQuestion = _questions[_currentQuestionIndex];
    final questionText = currentQuestion['question_text'] ?? '';
    final options = List<String>.from(currentQuestion['options'] ?? []);
    final correctIndex = (currentQuestion['correct_index'] as num?)?.toInt() ?? 0;
    final explanation = currentQuestion['explanation'] ?? '';

    final progress = (_currentQuestionIndex + 1) / _questions.length;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Baris Progress
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Pertanyaan ${_currentQuestionIndex + 1} dari ${_questions.length}',
                style: const TextStyle(
                  color: textSecondary,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFEDE9FE),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '+${widget.xpReward} XP',
                  style: const TextStyle(
                    color: primaryColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Progress Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: const Color(0xFFE2E8F0),
              valueColor: const AlwaysStoppedAnimation<Color>(primaryColor),
            ),
          ),
          const SizedBox(height: 28),

          // Pertanyaan Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Text(
              questionText,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: textPrimary,
                height: 1.4,
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Opsi Pilihan Ganda
          ...List.generate(options.length, (index) {
            final optionText = options[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildOptionButton(index, optionText, correctIndex),
            );
          }),

          // Feedback & Penjelasan
          if (_showFeedback) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _selectedOptionIndex == correctIndex
                    ? const Color(0xFFD1FAE5)
                    : const Color(0xFFFEE2E2),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: _selectedOptionIndex == correctIndex
                      ? const Color(0xFF10B981).withValues(alpha: 0.3)
                      : const Color(0xFFEF4444).withValues(alpha: 0.3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        _selectedOptionIndex == correctIndex
                            ? Icons.check_circle_rounded
                            : Icons.cancel_rounded,
                        color: _selectedOptionIndex == correctIndex
                            ? correctGreen
                            : incorrectRed,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _selectedOptionIndex == correctIndex
                            ? 'Jawaban Kamu Benar!'
                            : 'Jawaban Kurang Tepat',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: _selectedOptionIndex == correctIndex
                              ? const Color(0xFF065F46)
                              : const Color(0xFF991B1B),
                        ),
                      ),
                    ],
                  ),
                  if (explanation.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      explanation,
                      style: TextStyle(
                        fontSize: 14,
                        color: _selectedOptionIndex == correctIndex
                            ? const Color(0xFF065F46).withValues(alpha: 0.85)
                            : const Color(0xFF991B1B).withValues(alpha: 0.85),
                        height: 1.4,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _handleNextQuestion,
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 2,
                shadowColor: primaryColor.withValues(alpha: 0.4),
              ),
              child: Text(
                _currentQuestionIndex == _questions.length - 1
                    ? 'Lihat Hasil'
                    : 'Pertanyaan Berikutnya',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildOptionButton(int index, String text, int correctIndex) {
    final bool isSelected = _selectedOptionIndex == index;
    final bool isCorrect = index == correctIndex;

    Color borderColors = const Color(0xFFE2E8F0);
    Color bgColors = Colors.white;
    Color textColors = textPrimary;

    if (_showFeedback) {
      if (isCorrect) {
        borderColors = correctGreen;
        bgColors = const Color(0xFFD1FAE5);
        textColors = const Color(0xFF065F46);
      } else if (isSelected) {
        borderColors = incorrectRed;
        bgColors = const Color(0xFFFEE2E2);
        textColors = const Color(0xFF991B1B);
      } else {
        borderColors = const Color(0xFFE2E8F0).withValues(alpha: 0.5);
        textColors = textSecondary.withValues(alpha: 0.5);
      }
    } else {
      if (isSelected) {
        borderColors = primaryColor;
        bgColors = const Color(0xFFEDE9FE);
        textColors = primaryColor;
      }
    }

    return InkWell(
      onTap: _showFeedback ? null : () => _handleOptionSelected(index),
      borderRadius: BorderRadius.circular(14),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        decoration: BoxDecoration(
          color: bgColors,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: borderColors, width: 2),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: textColors,
                ),
              ),
            ),
            if (_showFeedback) ...[
              if (isCorrect)
                const Icon(Icons.check_circle_rounded, color: correctGreen)
              else if (isSelected)
                const Icon(Icons.cancel_rounded, color: incorrectRed),
            ],
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────
  //  FINISHED STATE VIEW
  // ─────────────────────────────────────────────
  Widget _buildFinishedState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: const BoxDecoration(
                color: Color(0xFFEDE9FE),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.emoji_events_rounded,
                color: primaryColor,
                size: 56,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Kuis Selesai!',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Kamu berhasil menjawab $_correctAnswersCount dari ${_questions.length} pertanyaan dengan benar.',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 15, color: textSecondary, height: 1.4),
            ),
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF3C7),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFF59E0B).withValues(alpha: 0.3)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.bolt_rounded, color: Color(0xFFF59E0B), size: 28),
                  const SizedBox(width: 8),
                  Text(
                    '+${widget.xpReward} XP diperoleh',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF92400E),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 48),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isUpdatingProfile
                    ? null
                    : () {
                        Navigator.pop(context, true); // Pop back and indicate completion
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: _isUpdatingProfile
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : const Text(
                        'Selesai & Kembali',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────
  //  ERROR STATE VIEW
  // ─────────────────────────────────────────────
  Widget _buildErrorState(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.wifi_off_rounded, color: Colors.redAccent, size: 60),
            const SizedBox(height: 16),
            const Text(
              'Gagal Memuat Kuis',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textPrimary),
            ),
            const SizedBox(height: 8),
            Text(
              error.replaceAll('Exception: ', ''),
              textAlign: TextAlign.center,
              style: const TextStyle(color: textSecondary),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _loadQuestions,
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Coba Lagi'),
            ),
          ],
        ),
      ),
    );
  }

  void _showExitConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Keluar dari Kuis?'),
        content: const Text('Kemajuan kuis kamu saat ini tidak akan disimpan jika kamu keluar sekarang.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal', style: TextStyle(color: textSecondary)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Tutup dialog
              Navigator.pop(context); // Keluar dari kuis
            },
            child: const Text('Keluar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
