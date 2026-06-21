import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../main.dart';
import '../utils/toast_helper.dart';
import 'play_kuis_page.dart';

class KuisPage extends StatefulWidget {
  const KuisPage({super.key});

  @override
  State<KuisPage> createState() => _KuisPageState();
}

class _KuisPageState extends State<KuisPage> {
  // === Design System Colors ===
  static const Color primaryColor = Color(0xFF8B5CF6);
  static const Color primaryDark = Color(0xFF7C3AED);
  static const Color backgroundColor = Color(0xFFF8FAFC);
  static const Color textPrimary = Color(0xFF1E293B);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color correctGreen = Color(0xFF10B981);

  int _selectedTab = 0;
  final List<String> _tabLabels = ['Pengetahuan', 'Sikap', 'Perilaku'];

  bool _isLoading = true;
  String? _errorMessage;

  List<Map<String, dynamic>> _allQuizzes = [];
  Set<String> _passedQuizIds = {};
  Set<String> _readModuleIds = {};

  @override
  void initState() {
    super.initState();
    _loadAllData();
  }

  Future<void> _loadAllData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      if (!isSupabaseInitialized) {
        throw Exception("Supabase belum diinisialisasi.");
      }

      final user = Supabase.instance.client.auth.currentUser;

      // 1. Fetch all quizzes with module category
      final quizzesResponse = await Supabase.instance.client
          .from('quizzes')
          .select('*, modules (id, category)');
      _allQuizzes = List<Map<String, dynamic>>.from(quizzesResponse);

      // 2. Fetch passed quiz IDs from user_quizzes
      if (user != null) {
        final passedResponse = await Supabase.instance.client
            .from('user_quizzes')
            .select('quiz_id')
            .eq('user_id', user.id)
            .eq('status', 'passed');
        _passedQuizIds = Set<String>.from(
          (passedResponse as List).map((r) => r['quiz_id'] as String),
        );
      }

      // 3. Load read modules from SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final completedList = prefs.getStringList('completed_modules_list') ?? [];
      _readModuleIds = Set<String>.from(completedList);

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
      });
    }
  }

  // Filter quizzes by category tab
  List<Map<String, dynamic>> _filterByCategory(List<Map<String, dynamic>> quizzes) {
    final selectedLabel = _tabLabels[_selectedTab];
    return quizzes.where((quiz) {
      final module = quiz['modules'] as Map<String, dynamic>?;
      final category = (module?['category'] ?? '').toString().toLowerCase();
      return category.contains(selectedLabel.toLowerCase());
    }).toList();
  }

  // Classify quizzes
  _QuizGroups _classifyQuizzes() {
    final filtered = _filterByCategory(_allQuizzes);

    final available = <Map<String, dynamic>>[];
    final locked = <Map<String, dynamic>>[];
    final completed = <Map<String, dynamic>>[];

    for (final quiz in filtered) {
      final quizId = quiz['id'] as String? ?? '';
      final module = quiz['modules'] as Map<String, dynamic>?;
      final moduleId = module?['id'] as String? ?? '';

      if (_passedQuizIds.contains(quizId)) {
        completed.add(quiz);
      } else if (_readModuleIds.contains(moduleId)) {
        available.add(quiz);
      } else {
        locked.add(quiz);
      }
    }

    return _QuizGroups(available: available, locked: locked, completed: completed);
  }

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
    return SafeArea(
      child: Container(
        color: backgroundColor,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator(color: primaryColor))
            : _errorMessage != null
                ? _buildError()
                : _buildContent(),
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline_rounded, color: Colors.redAccent, size: 48),
            const SizedBox(height: 12),
            Text(
              'Gagal memuat data: $_errorMessage',
              textAlign: TextAlign.center,
              style: const TextStyle(color: textSecondary),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadAllData,
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Coba Lagi'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    final groups = _classifyQuizzes();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          _buildHeader(),
          const SizedBox(height: 16),

          // Filter Tabs
          _buildFilterTabs(),
          const SizedBox(height: 20),

          // Banner Ajakan
          _buildBannerAjakan(),
          const SizedBox(height: 20),

          // Level Kamu (Real-time Profile Data)
          _buildSectionTitle('Level Kamu'),
          const SizedBox(height: 10),
          _buildLevelCardStream(),
          const SizedBox(height: 24),

          // ── KUIS TERSEDIA ──
          if (groups.available.isNotEmpty) ...[
            _buildSectionTitle('Kuis Tersedia'),
            const SizedBox(height: 10),
            ...groups.available.map((quiz) => _buildAvailableQuizCard(quiz)),
            const SizedBox(height: 24),
          ],

          // ── KUIS TERKUNCI ──
          if (groups.locked.isNotEmpty) ...[
            _buildSectionTitle('Kuis Terkunci 🔒'),
            const SizedBox(height: 10),
            ...groups.locked.map((quiz) => _buildLockedQuizCard(quiz)),
            const SizedBox(height: 24),
          ],

          // ── KUIS SELESAI ──
          if (groups.completed.isNotEmpty) ...[
            _buildSectionTitle('Kuis Selesai ✅'),
            const SizedBox(height: 10),
            ...groups.completed.map((quiz) => _buildCompletedQuizCard(quiz)),
            const SizedBox(height: 24),
          ],

          // Empty state
          if (groups.available.isEmpty && groups.locked.isEmpty && groups.completed.isEmpty) ...[
            _buildSectionTitle('Kuis'),
            const SizedBox(height: 10),
            const Center(
              child: Padding(
                padding: EdgeInsets.all(24.0),
                child: Text(
                  'Tidak ada kuis di kategori ini.',
                  style: TextStyle(color: textSecondary),
                ),
              ),
            ),
          ],

          const SizedBox(height: 16),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  //  HEADER
  // ─────────────────────────────────────────────
  Widget _buildHeader() {
    return const Text(
      'Kuis & Gamifikasi',
      style: TextStyle(
        fontSize: 26,
        fontWeight: FontWeight.bold,
        color: textPrimary,
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
  //  FILTER TABS: Pengetahuan / Sikap / Perilaku
  // ─────────────────────────────────────────────
  Widget _buildFilterTabs() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFEDE9FE),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: List.generate(_tabLabels.length, (index) {
          final bool isSelected = _selectedTab == index;
          return Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedTab = index;
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected ? primaryColor : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: primaryColor.withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : [],
                ),
                child: Text(
                  _tabLabels[index],
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isSelected ? Colors.white : primaryColor,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  // ─────────────────────────────────────────────
  //  BANNER AJAKAN
  // ─────────────────────────────────────────────
  Widget _buildBannerAjakan() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [primaryColor, primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withValues(alpha: 0.3),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          // Teks ajakan
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Yuk, uji\npemahamanmu!',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Jawab kuis, dapatkan poin,\ndan naik level!',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withValues(alpha: 0.85),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),

          // Ilustrasi ikon
          Expanded(
            flex: 2,
            child: Container(
              height: 100,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.quiz_rounded, size: 40, color: Colors.white),
                    SizedBox(height: 4),
                    Icon(Icons.edit_note_rounded, size: 24, color: Colors.white70),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  //  LEVEL CARD (STREAMBUILDER)
  // ─────────────────────────────────────────────
  Widget _buildLevelCardStream() {
    return StreamBuilder<Map<String, dynamic>>(
      stream: _profileStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: primaryColor));
        }

        final data = snapshot.data ?? {};
        final totalXp = data['total_xp'] as int? ?? 0;
        final level = data['level'] as int? ?? 1;

        // Level calculations
        final int xpInCurrentLevel = totalXp % 100;
        final double progressValue = xpInCurrentLevel / 100.0;
        final int xpRemaining = 100 - xpInCurrentLevel;

        return Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              // Baris atas: ikon + teks level + XP
              Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [primaryColor, primaryDark],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: primaryColor.withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.star_rounded,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 14),

                  // Teks level
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Level $level',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          'Pembelajar Hebat',
                          style: TextStyle(
                            fontSize: 14,
                            color: textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // XP
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEDE9FE),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '$totalXp XP',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: primaryColor,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Progress bar
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: progressValue,
                  minHeight: 10,
                  backgroundColor: const Color(0xFFEDE9FE),
                  valueColor: const AlwaysStoppedAnimation<Color>(primaryColor),
                ),
              ),

              const SizedBox(height: 8),

              // Label progress
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '$xpInCurrentLevel% selesai',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: primaryColor.withValues(alpha: 0.8),
                    ),
                  ),
                  Text(
                    '$xpRemaining XP lagi ke Level ${level + 1}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  // ─────────────────────────────────────────────
  //  QUIZ CARD: AVAILABLE (Tersedia)
  // ─────────────────────────────────────────────
  Widget _buildAvailableQuizCard(Map<String, dynamic> quiz) {
    final quizId = quiz['id'] ?? '';
    final title = quiz['title'] ?? 'Kuis';
    final description = quiz['description'] ?? 'Asah kemampuanmu lewat kuis seru ini!';
    final xpReward = (quiz['xp_reward'] as num?)?.toInt() ?? 100;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () async {
            final bool? quizCompleted = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PlayKuisPage(
                  quizId: quizId,
                  quizTitle: title,
                  xpReward: xpReward,
                ),
              ),
            );

            if (quizCompleted == true) {
              _loadAllData(); // Refresh semua data
            }
          },
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Ikon Kuis
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: const Color(0xFFEDE9FE),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.quiz_rounded,
                        color: primaryColor,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 14),

                    // Title & XP Reward Badge
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: textPrimary,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFEF3C7),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: const Color(0xFFF59E0B).withValues(alpha: 0.2),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.bolt_rounded,
                                  color: Color(0xFFD97706),
                                  size: 14,
                                ),
                                const SizedBox(width: 2),
                                Text(
                                  '+$xpReward XP',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: Color(0xFFB45309),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Deskripsi Kuis
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 13,
                    color: textSecondary,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 14),
                // Action Footer
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      'Mulai Kuis',
                      style: TextStyle(
                        color: primaryColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.arrow_forward_rounded,
                      color: primaryColor,
                      size: 16,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────
  //  QUIZ CARD: LOCKED (Terkunci)
  // ─────────────────────────────────────────────
  Widget _buildLockedQuizCard(Map<String, dynamic> quiz) {
    final title = quiz['title'] ?? 'Kuis';
    final xpReward = (quiz['xp_reward'] as num?)?.toInt() ?? 100;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.5),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            ToastHelper.showInfo(
              context,
              'Baca modulnya dulu ya! 📖',
            );
          },
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Row(
              children: [
                // Lock icon
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE2E8F0),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.lock_rounded,
                    color: Color(0xFF94A3B8),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: textSecondary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '+$xpReward XP • Baca modul untuk membuka',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF94A3B8),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────
  //  QUIZ CARD: COMPLETED (Selesai)
  // ─────────────────────────────────────────────
  Widget _buildCompletedQuizCard(Map<String, dynamic> quiz) {
    final title = quiz['title'] ?? 'Kuis';
    final xpReward = (quiz['xp_reward'] as num?)?.toInt() ?? 100;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: correctGreen.withValues(alpha: 0.3),
          width: 1.5,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            // Check icon
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: const Color(0xFFD1FAE5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.check_circle_rounded,
                color: correctGreen,
                size: 24,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '+$xpReward XP diperoleh',
                    style: const TextStyle(
                      fontSize: 12,
                      color: correctGreen,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            // Badge Lulus
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFD1FAE5),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text(
                'Lulus',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: correctGreen,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  Data class
// ─────────────────────────────────────────────
class _QuizGroups {
  final List<Map<String, dynamic>> available;
  final List<Map<String, dynamic>> locked;
  final List<Map<String, dynamic>> completed;

  _QuizGroups({
    required this.available,
    required this.locked,
    required this.completed,
  });
}
