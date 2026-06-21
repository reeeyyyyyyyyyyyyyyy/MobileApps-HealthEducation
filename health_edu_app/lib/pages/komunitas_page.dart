import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../main.dart';
import '../utils/toast_helper.dart';
import 'detail_post_page.dart';

class KomunitasPage extends StatefulWidget {
  const KomunitasPage({super.key});

  @override
  State<KomunitasPage> createState() => _KomunitasPageState();
}

class _KomunitasPageState extends State<KomunitasPage> {
  // === Design System Colors ===
  static const Color primaryColor = Color(0xFF8B5CF6);
  static const Color backgroundColor = Color(0xFFF8FAFC);
  static const Color textPrimary = Color(0xFF1E293B);
  static const Color textSecondary = Color(0xFF64748B);

  bool _isLoading = true;
  List<Map<String, dynamic>> _postsList = [];

  @override
  void initState() {
    super.initState();
    _fetchPosts();
  }

  Future<void> _fetchPosts() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
    });
    try {
      if (!isSupabaseInitialized) {
        throw Exception("Supabase belum diinisialisasi.");
      }
      final response = await Supabase.instance.client
          .from('posts')
          .select('*, profiles:user_id(full_name, avatar_url), comments(id)')
          .order('created_at', ascending: false);
      
      if (mounted) {
        setState(() {
          _postsList = List<Map<String, dynamic>>.from(response);
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Gagal mengambil postingan: $e");
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  String _formatTimeAgo(String? createdAtStr) {
    if (createdAtStr == null) return '';
    try {
      final dateTime = DateTime.parse(createdAtStr).toLocal();
      final difference = DateTime.now().difference(dateTime);

      if (difference.inDays > 365) {
        return '${(difference.inDays / 365).floor()} tahun lalu';
      } else if (difference.inDays > 30) {
        return '${(difference.inDays / 30).floor()} bulan lalu';
      } else if (difference.inDays > 7) {
        return '${(difference.inDays / 7).floor()} minggu lalu';
      } else if (difference.inDays > 0) {
        return '${difference.inDays} hari lalu';
      } else if (difference.inHours > 0) {
        return '${difference.inHours} jam lalu';
      } else if (difference.inMinutes > 0) {
        return '${difference.inMinutes} menit lalu';
      } else {
        return 'Baru saja';
      }
    } catch (e) {
      return '';
    }
  }

  void _showNewPostSheet() {
    final textController = TextEditingController();
    bool isAnon = false;
    bool isSending = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 20,
                right: 20,
                top: 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Bagikan Ceritamu',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: textPrimary,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const Divider(color: Color(0xFFF1F5F9)),
                  const SizedBox(height: 12),
                  TextField(
                    controller: textController,
                    maxLines: 5,
                    minLines: 3,
                    autofocus: true,
                    style: const TextStyle(fontSize: 14, color: textPrimary),
                    decoration: const InputDecoration(
                      hintText: 'Tulis pertanyaan atau ceritamu di sini...',
                      hintStyle: TextStyle(color: textSecondary),
                      border: InputBorder.none,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SwitchListTile(
                    title: const Text(
                      'Posting sebagai Anonim',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: textPrimary,
                      ),
                    ),
                    subtitle: const Text(
                      'Nama asli dan avatar kamu tidak akan terlihat oleh publik.',
                      style: TextStyle(fontSize: 11, color: textSecondary),
                    ),
                    value: isAnon,
                    activeThumbColor: primaryColor,
                    contentPadding: EdgeInsets.zero,
                    onChanged: (val) {
                      setSheetState(() {
                        isAnon = val;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: isSending
                          ? null
                          : () async {
                              final text = textController.text.trim();
                              if (text.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Konten postingan tidak boleh kosong')),
                                );
                                return;
                              }

                              setSheetState(() {
                                isSending = true;
                              });

                              try {
                                final user = Supabase.instance.client.auth.currentUser;
                                if (user != null) {
                                  await Supabase.instance.client.from('posts').insert({
                                    'user_id': user.id,
                                    'content': text,
                                    'is_anonymous': isAnon,
                                  });
                                }
                                if (context.mounted) {
                                  Navigator.pop(context); // Tutup bottom sheet
                                  ToastHelper.showSuccess(
                                    context,
                                    'Postingan berhasil dipublikasikan! 🎉',
                                  );
                                  _fetchPosts(); // Refresh list postingan
                                }
                              } catch (e) {
                                setSheetState(() {
                                  isSending = false;
                                });
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Gagal membuat postingan: $e'),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                }
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 0,
                      ),
                      child: isSending
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              'Kirim Postingan',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showReportDialog(BuildContext context, {String? postId, String? commentId}) {
    String? selectedReason;
    final List<String> reasons = [
      'Mengandung ujaran kebencian / Harassment',
      'Spam / Iklan tidak layak',
      'SARA / Konten tidak pantas',
      'Informasi medis yang menyesatkan',
      'Lainnya',
    ];
    final textController = TextEditingController();
    bool showTextInput = false;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: const Row(
                children: [
                  Icon(Icons.report_problem_rounded, color: Colors.amber),
                  SizedBox(width: 8),
                  Text(
                    'Laporkan Konten',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Mengapa Anda melaporkan konten ini?',
                    style: TextStyle(color: textSecondary, fontSize: 13),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                      ),
                    ),
                    hint: const Text('Pilih alasan...'),
                    initialValue: selectedReason,
                    items: reasons.map((reason) {
                      return DropdownMenuItem<String>(
                        value: reason,
                        child: Text(reason, style: const TextStyle(fontSize: 13)),
                      );
                    }).toList(),
                    onChanged: (val) {
                      setDialogState(() {
                        selectedReason = val;
                        showTextInput = val == 'Lainnya';
                      });
                    },
                  ),
                  if (showTextInput) ...[
                    const SizedBox(height: 12),
                    TextField(
                      controller: textController,
                      maxLines: 3,
                      style: const TextStyle(fontSize: 13),
                      decoration: InputDecoration(
                        hintText: 'Tuliskan alasan Anda secara detail...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Batal', style: TextStyle(color: textSecondary)),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final reasonText = selectedReason == 'Lainnya' ? textController.text.trim() : selectedReason;
                    if (reasonText == null || reasonText.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Pilih atau tuliskan alasan laporan Anda')),
                      );
                      return;
                    }

                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (c) => const Center(child: CircularProgressIndicator()),
                    );

                    try {
                      final user = Supabase.instance.client.auth.currentUser;
                      if (user != null) {
                        await Supabase.instance.client.from('reports').insert({
                          'reporter_id': user.id,
                          'post_id': postId,
                          'comment_id': commentId,
                          'reason': reasonText,
                        });
                      }
                      
                      if (context.mounted) {
                        Navigator.pop(context); // Tutup loading
                        Navigator.pop(context); // Tutup dialog
                        
                        ToastHelper.showSuccess(
                          context,
                          'Terima kasih, laporan Anda akan ditinjau oleh Admin.',
                        );
                      }
                    } catch (e) {
                      if (context.mounted) {
                        Navigator.pop(context); // Tutup loading
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Gagal mengirim laporan: $e'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Kirim Laporan'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      floatingActionButton: FloatingActionButton(
        onPressed: _showNewPostSheet,
        backgroundColor: primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _fetchPosts,
          color: primaryColor,
          child: _isLoading && _postsList.isEmpty
              ? const Center(child: CircularProgressIndicator(color: primaryColor))
              : SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(),
                      const SizedBox(height: 16),
                      _buildBannerKomunitas(),
                      const SizedBox(height: 16),
                      GestureDetector(
                        onTap: _showNewPostSheet,
                        child: _buildNewPostInput(),
                      ),
                      const SizedBox(height: 20),
                      _buildSectionTitle('Diskusi Terbaru'),
                      const SizedBox(height: 12),
                      _buildPostFeed(),
                    ],
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Ruang Aman',
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: textPrimary,
          ),
        ),
        SizedBox(height: 4),
        Text(
          'Tanya dan berbagi cerita tanpa rasa malu',
          style: TextStyle(
            fontSize: 14,
            color: textSecondary,
          ),
        ),
      ],
    );
  }

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

  Widget _buildBannerKomunitas() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFF5F3FF), Color(0xFFFCE7F3)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFEDE9FE),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Kamu Tidak Sendiri!',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Gabung dengan komunitas remaja putri yang saling mendukung.',
                  style: TextStyle(
                    fontSize: 13,
                    color: textSecondary,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 14),
                ElevatedButton(
                  onPressed: _showNewPostSheet,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    'Tulis Postingan',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 1,
            child: Container(
              height: 80,
              decoration: BoxDecoration(
                color: const Color(0xFFEDE9FE),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Center(
                child: Icon(Icons.handshake_rounded, size: 36, color: Color(0xFF8B5CF6)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNewPostInput() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: const BoxDecoration(
              color: Color(0xFFEDE9FE),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.person_rounded,
              color: primaryColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Tanyakan sesuatu secara anonim di sini...',
              style: TextStyle(
                fontSize: 14,
                color: textSecondary,
              ),
            ),
          ),
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.edit_rounded,
              color: primaryColor,
              size: 18,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPostFeed() {
    if (_postsList.isEmpty && !_isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 40.0),
          child: Text(
            'Belum ada postingan. Jadilah yang pertama berbagi!',
            style: TextStyle(color: textSecondary),
          ),
        ),
      );
    }
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: _postsList.length,
      itemBuilder: (context, index) {
        return _buildPostCard(_postsList[index]);
      },
    );
  }

  Widget _buildPostCard(Map<String, dynamic> post) {
    final isAnon = post['is_anonymous'] == true;
    final profile = post['profiles'] as Map<String, dynamic>?;
    final authorName = isAnon ? 'Pengguna Rahasia' : (profile?['full_name'] ?? 'Pengguna');
    final avatarUrl = profile?['avatar_url'] as String?;
    final content = post['content'] ?? '';
    final timeAgo = _formatTimeAgo(post['created_at']);
    final commentCount = (post['comments'] as List?)?.length ?? 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              isAnon
                  ? Container(
                      width: 36,
                      height: 36,
                      decoration: const BoxDecoration(
                        color: Color(0xFFCBD5E1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.lock_person_rounded,
                        color: Color(0xFF64748B),
                        size: 20,
                      ),
                    )
                  : CircleAvatar(
                      radius: 18,
                      backgroundColor: const Color(0xFFEDE9FE),
                      backgroundImage: avatarUrl != null && avatarUrl.isNotEmpty
                          ? NetworkImage(avatarUrl)
                          : null,
                      child: avatarUrl == null || avatarUrl.isEmpty
                          ? Text(
                              authorName.isNotEmpty ? authorName[0].toUpperCase() : 'U',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: primaryColor,
                              ),
                            )
                          : null,
                    ),
              const SizedBox(width: 10),
              Expanded(
                child: RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: authorName,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: textPrimary,
                        ),
                      ),
                      TextSpan(
                        text: '  •  $timeAgo',
                        style: const TextStyle(
                          fontSize: 12,
                          color: textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              PopupMenuButton<String>(
                icon: const Icon(
                  Icons.more_vert_rounded,
                  color: textSecondary,
                  size: 20,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                onSelected: (value) {
                  if (value == 'report') {
                    _showReportDialog(context, postId: post['id']);
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem<String>(
                    value: 'report',
                    child: Row(
                      children: [
                        Icon(Icons.flag_outlined, color: Colors.red, size: 18),
                        SizedBox(width: 8),
                        Text('Laporkan Konten', style: TextStyle(fontSize: 13, color: Colors.red)),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DetailPostPage(post: post),
                ),
              );
              if (result == true) {
                _fetchPosts();
              }
            },
            child: Text(
              content,
              style: const TextStyle(
                fontSize: 14,
                color: textPrimary,
                height: 1.4,
              ),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              GestureDetector(
                onTap: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DetailPostPage(post: post),
                    ),
                  );
                  if (result == true) {
                    _fetchPosts();
                  }
                },
                child: _buildInteractionButton(
                  icon: Icons.chat_bubble_outline_rounded,
                  label: '$commentCount',
                  color: textSecondary,
                  bgColor: const Color(0xFFF1F5F9),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInteractionButton({
    required IconData icon,
    required String label,
    required Color color,
    required Color bgColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
