import 'dart:async';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/toast_helper.dart';

class DetailModulPage extends StatefulWidget {
  final Map<String, dynamic> module;

  const DetailModulPage({super.key, required this.module});

  @override
  State<DetailModulPage> createState() => _DetailModulPageState();
}

class _DetailModulPageState extends State<DetailModulPage> {
  static const Color textPrimary = Color(0xFF1E293B);
  static const Color textSecondary = Color(0xFF64748B);

  late ScrollController _scrollController;
  YoutubePlayerController? _youtubeController;
  
  // Subscriptions to stream events
  StreamSubscription<YoutubePlayerValue>? _youtubeValueSubscription;
  StreamSubscription<YoutubeVideoState>? _youtubeVideoStateSubscription;
  
  // Pelacakan Status & Progres
  double _progressPercentage = 0.0;
  bool _videoCompleted = false;
  bool _isAlreadyCompleted = false; // true jika modul ini sudah pernah 100% di sesi sebelumnya
  bool _isPlaying = false;
  bool _hasVideo = false;
  bool _showVideoReplay = false; // Untuk menonton ulang setelah selesai
  bool _justCompletedNow = false; // true jika modul baru saja selesai di sesi ini (pertama kali)
  
  // Status internal untuk mencegah spamming notifikasi
  bool _hasCompletedSessionNotification = false;

  // Pelacakan Durasi & Posisi Video
  double _videoDurationSeconds = 0.0;
  double _videoPositionSeconds = 0.0;
  String? _videoId;

  @override
  void initState() {
    super.initState();

    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);

    final videoUrl = widget.module['video_url'] as String?;
    if (videoUrl != null && videoUrl.isNotEmpty) {
      _videoId = YoutubePlayerController.convertUrlToId(videoUrl);
      if (_videoId != null) {
        _hasVideo = true;
        _youtubeController = YoutubePlayerController.fromVideoId(
          videoId: _videoId!,
          autoPlay: false,
          params: const YoutubePlayerParams(
            showControls: false, // Sembunyikan tombol bawaan YouTube agar tidak bisa diskip
            showFullscreenButton: false,
            showVideoAnnotations: false,
            loop: false,
          ),
        );

        // Listen to changes in the player state and metadata
        _youtubeValueSubscription = _youtubeController!.listen((value) {
          if (!mounted) return;
          setState(() {
            _isPlaying = value.playerState == PlayerState.playing;
          });

          _updateDuration();

          // Deteksi jika video telah selesai diputar
          if (value.playerState == PlayerState.ended) {
            if (!_videoCompleted) {
              _onVideoCompleted();
            }
          }
        });

        // Listen to position changes
        _youtubeVideoStateSubscription = _youtubeController!.videoStateStream.listen((state) {
          if (!mounted) return;
          final currentPos = state.position.inSeconds.toDouble();
          setState(() {
            _videoPositionSeconds = currentPos;
          });

          _updateDuration();

          // Pemicu alternatif jika position sudah mendekati durasi penuh
          if (_videoDurationSeconds > 0 && currentPos >= _videoDurationSeconds - 1.5) {
            if (!_videoCompleted) {
              _onVideoCompleted();
            }
          }
        });
      }
    }

    _checkAlreadyCompleted();
    _incrementViewCount();
  }

  // Increment view_count di Supabase setiap kali modul dibuka
  Future<void> _incrementViewCount() async {
    final moduleId = widget.module['id'] as String?;
    if (moduleId == null) return;
    try {
      await Supabase.instance.client.rpc(
        'increment_view_count',
        params: {'module_id': moduleId},
      );
    } catch (e) {
      debugPrint('Error incrementing view count: $e');
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _youtubeValueSubscription?.cancel();
    _youtubeVideoStateSubscription?.cancel();
    _youtubeController?.close();
    super.dispose();
  }

  // Ambil durasi video
  Future<void> _updateDuration() async {
    if (_youtubeController == null || !mounted) return;
    final metaDuration = _youtubeController!.value.metaData.duration.inSeconds.toDouble();
    if (metaDuration > 0) {
      if (mounted) {
        setState(() {
          _videoDurationSeconds = metaDuration;
        });
      }
    } else {
      try {
        final dur = await _youtubeController!.duration;
        if (dur > 0 && mounted) {
          setState(() {
            _videoDurationSeconds = dur;
          });
        }
      } catch (e) {
        debugPrint('Error fetching duration: $e');
      }
    }
  }

  // Cek apakah modul ini sudah pernah diselesaikan sebelumnya
  Future<void> _checkAlreadyCompleted() async {
    final moduleId = widget.module['id'] as String?;
    if (moduleId == null) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      final completedList = prefs.getStringList('completed_modules_list') ?? [];
      if (completedList.contains(moduleId)) {
        setState(() {
          _isAlreadyCompleted = true;
          _videoCompleted = true;
          // Membaca ulang langsung membuka materi dengan progres awal
          _progressPercentage = _hasVideo ? 50.0 : 0.0;
        });
      }
    } catch (e) {
      debugPrint('Error loading preferences: $e');
    }
  }

  // Ketika menonton video selesai 100%
  void _onVideoCompleted() {
    setState(() {
      _videoCompleted = true;
      _progressPercentage = 50.0;
    });
    
    if (mounted) {
      ToastHelper.showSuccess(
        context,
        'Video selesai ditonton! Materi artikel kini terbuka 🔓 (+50% progres)',
      );
    }
  }

  // Listener untuk perubahan posisi scroll
  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final position = _scrollController.position;
    
    double scrollRatio = 0.0;
    if (position.maxScrollExtent > 0) {
      scrollRatio = position.pixels / position.maxScrollExtent;
      if (scrollRatio < 0.0) scrollRatio = 0.0;
      if (scrollRatio > 1.0) scrollRatio = 1.0;
    } else {
      // Jika konten sangat pendek dan tidak perlu scroll, anggap rasio 1.0
      scrollRatio = 1.0;
    }

    setState(() {
      if (_hasVideo) {
        if (_videoCompleted) {
          _progressPercentage = 50.0 + (scrollRatio * 50.0);
        } else {
          _progressPercentage = 0.0;
        }
      } else {
        _progressPercentage = scrollRatio * 100.0;
      }
    });

    // Ketika mencapai 100% progres, berikan reward atau catat penyelesaian
    if (_progressPercentage >= 99.5) {
      _markAsCompleted();
    }
  }

  // Logika pemberian reward XP dan pencatatan status penyelesaian
  Future<void> _markAsCompleted() async {
    final moduleId = widget.module['id'] as String?;
    if (moduleId == null) return;

    // Cegah double-call jika sudah memberi notifikasi
    if (_hasCompletedSessionNotification) return;

    if (_isAlreadyCompleted) {
      // User membaca ulang modul yang sudah pernah diselesaikan sebelumnya
      if (_progressPercentage >= 99.5) {
        setState(() {
          _hasCompletedSessionNotification = true;
        });
        if (mounted) {
          ToastHelper.showSuccess(
            context,
            'Senang melihatmu membaca kembali modul ini! 📚',
          );
        }
      }
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final completedList = prefs.getStringList('completed_modules_list') ?? [];
    if (completedList.contains(moduleId)) {
      setState(() {
        _isAlreadyCompleted = true;
      });
      return;
    }

    // Catat ke SharedPreferences agar tidak mendapat XP berulang kali
    completedList.add(moduleId);
    await prefs.setStringList('completed_modules_list', completedList);

    setState(() {
      _isAlreadyCompleted = true;
      _justCompletedNow = true;
      _hasCompletedSessionNotification = true;
    });

    if (mounted) {
      ToastHelper.showSuccess(
        context,
        'Hebat! Kamu menyelesaikan modul ini (+50 XP) 🎉',
      );
    }

    // Update Supabase profiles: total_xp + 50 dan modul_selesai + 1
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) return;

      // Ambil data profil saat ini
      final profile = await Supabase.instance.client
          .from('profiles')
          .select('total_xp, modul_selesai')
          .eq('id', user.id)
          .maybeSingle();

      if (profile != null) {
        final currentXp = (profile['total_xp'] as int?) ?? 0;
        final currentModulSelesai = (profile['modul_selesai'] as int?) ?? 0;

        await Supabase.instance.client
            .from('profiles')
            .update({
              'total_xp': currentXp + 50,
              'modul_selesai': currentModulSelesai + 1,
            })
            .eq('id', user.id);
      }
    } catch (e) {
      debugPrint('Error updating XP: $e');
    }
  }

  // Menentukan warna tema berdasarkan kategori modul
  Map<String, Color> _getThemeColors(String category) {
    final cat = category.toLowerCase();
    if (cat.contains('pengetahuan')) {
      return {
        'bg': const Color(0xFFEDE9FE),
        'color': const Color(0xFF8B5CF6),
      };
    } else if (cat.contains('sikap')) {
      return {
        'bg': const Color(0xFFFCE7F3),
        'color': const Color(0xFFEC4899),
      };
    } else if (cat.contains('perilaku')) {
      return {
        'bg': const Color(0xFFD1FAE5),
        'color': const Color(0xFF10B981),
      };
    } else {
      return {
        'bg': const Color(0xFFDBEAFE),
        'color': const Color(0xFF3B82F6),
      };
    }
  }

  // Format durasi detik menjadi format mm:ss
  String _formatDuration(double seconds) {
    if (seconds.isNaN || seconds.isInfinite) return '00:00';
    final intMinutes = (seconds / 60).floor();
    final intSeconds = (seconds % 60).floor();
    return '${intMinutes.toString().padLeft(2, '0')}:${intSeconds.toString().padLeft(2, '0')}';
  }

  // Pembuat konten interaktif dengan diselingi quote / tip yang menarik
  List<Widget> _buildContentWidgets(String content) {
    final paragraphs = content.split('\n\n');
    final widgets = <Widget>[];

    for (int i = 0; i < paragraphs.length; i++) {
      final text = paragraphs[i].trim();
      if (text.isEmpty) continue;

      if (text.startsWith('•') || text.startsWith('-')) {
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('• ', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF8B5CF6))),
                Expanded(
                  child: Text(
                    text.replaceFirst(RegExp(r'^[•-]\s*'), ''),
                    style: const TextStyle(
                      fontSize: 15,
                      color: textPrimary,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      } else {
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 15,
                color: textPrimary,
                height: 1.6,
                letterSpacing: 0.1,
              ),
            ),
          ),
        );
      }

      // Sisipkan kartu penyemangat & tips belajar di paragraf tertentu
      if (i == 0 && paragraphs.length > 1) {
        widgets.add(_buildEncouragementCard());
      } else if (i == paragraphs.length - 2 && paragraphs.length > 2) {
        widgets.add(_buildTipsCard());
      }
    }

    return widgets;
  }

  Widget _buildEncouragementCard() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFEEF2F6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFCBD5E1)),
      ),
      child: const Row(
        children: [
          Text('💪', style: TextStyle(fontSize: 24)),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'Luar biasa! Kamu sudah memulai langkah sehat hari ini. Lanjutkan membaca untuk menguasai topik ini!',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Color(0xFF334155),
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTipsCard() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFF5F3FF), Color(0xFFEDE9FE)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFDDD6FE)),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.lightbulb_rounded, color: Color(0xFF8B5CF6), size: 24),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tips Belajar Sehat',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF5B21B6),
                    fontSize: 14,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Catat poin penting dari materi ini untuk mempermudah pengerjaan kuis nanti!',
                  style: TextStyle(
                    color: Color(0xFF6D28D9),
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final category = widget.module['category'] ?? 'Edukasi';
    final title = widget.module['title'] ?? 'Judul Modul';
    final duration = widget.module['duration'] ?? '5 menit';
    final content = widget.module['content'] ?? '';
    final theme = _getThemeColors(category);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          category,
          style: const TextStyle(
            color: textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          SafeArea(
            child: SingleChildScrollView(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Badge Kategori & Durasi
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: theme['bg'],
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          category,
                          style: TextStyle(
                            color: theme['color'],
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE2E8F0),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.access_time_rounded,
                              size: 14,
                              color: textSecondary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              duration,
                              style: const TextStyle(
                                color: textSecondary,
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Judul Artikel
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: textPrimary,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // ── SEKSI VIDEO (HANYA DITAMPILKAN JIKA ADA VIDEO & BELUM SELESAI / REPLAY ACTIVE) ──
                  if (_hasVideo && (!_videoCompleted || _showVideoReplay)) ...[
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          )
                        ],
                      ),
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // YouTube Video Player
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: YoutubePlayer(
                              controller: _youtubeController!,
                              aspectRatio: 16 / 9,
                            ),
                          ),
                          const SizedBox(height: 16),
                          
                          // Linear progress indicator (Non-interactive)
                          Column(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: LinearProgressIndicator(
                                  value: (_videoDurationSeconds > 0) 
                                      ? (_videoPositionSeconds / _videoDurationSeconds) 
                                      : 0.0,
                                  minHeight: 6,
                                  backgroundColor: const Color(0xFFF1F5F9),
                                  valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF8B5CF6)),
                                ),
                              ),
                              const SizedBox(height: 6),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    _formatDuration(_videoPositionSeconds),
                                    style: const TextStyle(fontSize: 11, color: textSecondary, fontWeight: FontWeight.w500),
                                  ),
                                  Text(
                                    _formatDuration(_videoDurationSeconds),
                                    style: const TextStyle(fontSize: 11, color: textSecondary, fontWeight: FontWeight.w500),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),

                          // Tombol Putar/Jeda Video Kustom
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ElevatedButton.icon(
                                onPressed: () {
                                  if (_isPlaying) {
                                    _youtubeController?.pauseVideo();
                                  } else {
                                    _youtubeController?.playVideo();
                                  }
                                },
                                icon: Icon(
                                  _isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                                  color: Colors.white,
                                ),
                                label: Text(
                                  _isPlaying ? 'Jeda Video' : 'Putar Video',
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF8B5CF6),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                  elevation: 2,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Informasi Kunci Video
                    if (!_videoCompleted) ...[
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF7ED),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFFFEDD5)),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.lock_rounded, color: Color(0xFFD97706), size: 18),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Tonton video di atas sampai habis untuk membuka materi bacaan.',
                                style: TextStyle(
                                  color: Color(0xFF9A3412),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ],

                  // Tombol Tonton Ulang Video jika Video sudah selesai ditonton
                  if (_hasVideo && _videoCompleted) ...[
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton.icon(
                        onPressed: () {
                          setState(() {
                            _showVideoReplay = !_showVideoReplay;
                          });
                        },
                        icon: Icon(
                          _showVideoReplay ? Icons.visibility_off_rounded : Icons.play_circle_filled_rounded,
                          color: const Color(0xFF8B5CF6),
                        ),
                        label: Text(
                          _showVideoReplay ? 'Sembunyikan Video' : 'Tonton Ulang Video',
                          style: const TextStyle(color: Color(0xFF8B5CF6), fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],

                  // Garis Pembatas
                  Container(
                    height: 1.5,
                    width: double.infinity,
                    color: const Color(0xFFE2E8F0),
                  ),
                  const SizedBox(height: 24),

                  // ── SEKSI TEKS MATERI (HANYA MUNCUL JIKA TIDAK ADA VIDEO ATAU VIDEO SUDAH SELESAI) ──
                  if (!_hasVideo || _videoCompleted) ...[
                    ..._buildContentWidgets(content),
                    const SizedBox(height: 24),
                  ] else ...[
                    // Tampilan Pengunci Materi
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 40.0),
                        child: Column(
                          children: [
                            const Icon(
                              Icons.menu_book_rounded,
                              size: 64,
                              color: Color(0xFFCBD5E1),
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'Materi Masih Terkunci',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: textSecondary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Selesaikan pemutaran video terlebih dahulu',
                              style: TextStyle(
                                fontSize: 13,
                                color: Color(0xFF94A3B8),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],

                  // Indikator status penyelesaian sukses
                  if (_hasCompletedSessionNotification && _progressPercentage >= 99.5)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: _justCompletedNow
                            ? const Color(0xFFD1FAE5) // Hijau untuk pertama kali selesai
                            : const Color(0xFFDBEAFE), // Biru untuk membaca ulang
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: _justCompletedNow
                              ? const Color(0xFF10B981).withValues(alpha: 0.3)
                              : const Color(0xFF3B82F6).withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            _justCompletedNow
                                ? Icons.check_circle_rounded
                                : Icons.replay_circle_filled_rounded,
                            color: _justCompletedNow
                                ? const Color(0xFF10B981)
                                : const Color(0xFF3B82F6),
                            size: 24,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              _justCompletedNow
                                  ? 'Modul selesai! +50 XP telah ditambahkan. 🎉'
                                  : 'Kamu telah membaca ulang modul ini hingga akhir! 📚',
                              style: TextStyle(
                                color: _justCompletedNow
                                    ? const Color(0xFF065F46)
                                    : const Color(0xFF1E3A5F),
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),

          // ── INDIKATOR PROGRES MELAYANG DI SAMPING KANAN ──
          Positioned(
            right: 16,
            bottom: 32,
            child: Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 46,
                    height: 46,
                    child: CircularProgressIndicator(
                      value: _progressPercentage / 100.0,
                      strokeWidth: 4,
                      backgroundColor: const Color(0xFFF1F5F9),
                      valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF8B5CF6)),
                    ),
                  ),
                  Text(
                    '${_progressPercentage.toInt()}%',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold, // FontWeight.bold is valid
                      color: Color(0xFF1E293B),
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
