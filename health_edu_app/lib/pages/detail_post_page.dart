import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../utils/toast_helper.dart';

class DetailPostPage extends StatefulWidget {
  final Map<String, dynamic> post;

  const DetailPostPage({super.key, required this.post});

  @override
  State<DetailPostPage> createState() => _DetailPostPageState();
}

class _DetailPostPageState extends State<DetailPostPage> {
  // === Design System Colors ===
  static const Color primaryColor = Color(0xFF8B5CF6);
  static const Color backgroundColor = Color(0xFFF8FAFC);
  static const Color textPrimary = Color(0xFF1E293B);
  static const Color textSecondary = Color(0xFF64748B);

  bool _isLoading = true;
  List<Map<String, dynamic>> _commentsList = [];
  final TextEditingController _commentController = TextEditingController();
  bool _isCommentAnonymous = false;
  bool _isSendingComment = false;

  @override
  void initState() {
    super.initState();
    _fetchComments();
  }

  Future<void> _fetchComments() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
    });
    try {
      final response = await Supabase.instance.client
          .from('comments')
          .select('*, profiles:user_id(full_name, avatar_url)')
          .eq('post_id', widget.post['id'])
          .order('created_at', ascending: true);

      if (mounted) {
        setState(() {
          _commentsList = List<Map<String, dynamic>>.from(response);
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Gagal mengambil komentar: $e");
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

  Future<void> _sendComment() async {
    final text = _commentController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _isSendingComment = true;
    });

    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user != null) {
        await Supabase.instance.client.from('comments').insert({
          'post_id': widget.post['id'],
          'user_id': user.id,
          'content': text,
          'is_anonymous': _isCommentAnonymous,
        });

        _commentController.clear();
        setState(() {
          _isCommentAnonymous = false;
        });
        
        // Refresh list komentar
        await _fetchComments();

        if (mounted) {
          ToastHelper.showSuccess(context, 'Komentar terkirim! 💬');
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal mengirim komentar: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSendingComment = false;
        });
      }
    }
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
                    isExpanded: true,
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
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        Navigator.pop(context, true); // Kembalikan true untuk memicu refresh data di feed
      },
      child: Scaffold(
        backgroundColor: backgroundColor,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: textPrimary),
            onPressed: () => Navigator.pop(context, true),
          ),
          title: const Text(
            'Detail Postingan',
            style: TextStyle(
              color: textPrimary,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          centerTitle: true,
        ),
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: RefreshIndicator(
                  onRefresh: _fetchComments,
                  color: primaryColor,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16.0),
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemCount: _commentsList.length + 1,
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        return _buildPostHeader();
                      }
                      final comment = _commentsList[index - 1];
                      return _buildCommentCard(comment);
                    },
                  ),
                ),
              ),
              _buildStickyCommentInput(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPostHeader() {
    final post = widget.post;
    final isAnon = post['is_anonymous'] == true;
    final profile = post['profiles'] as Map<String, dynamic>?;
    final authorName = isAnon ? 'Pengguna Rahasia' : (profile?['full_name'] ?? 'Pengguna');
    final avatarUrl = profile?['avatar_url'] as String?;
    final content = post['content'] ?? '';
    final timeAgo = _formatTimeAgo(post['created_at']);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
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
                          width: 38,
                          height: 38,
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
                          radius: 19,
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
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          authorName,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          timeAgo,
                          style: const TextStyle(
                            fontSize: 11,
                            color: textSecondary,
                          ),
                        ),
                      ],
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
              const SizedBox(height: 16),
              Text(
                content,
                style: const TextStyle(
                  fontSize: 15,
                  color: textPrimary,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            const Icon(Icons.chat_bubble_outline_rounded, size: 18, color: textPrimary),
            const SizedBox(width: 8),
            Text(
              'Komentar (${_commentsList.length})',
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (_commentsList.isEmpty && !_isLoading)
          const Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 32.0),
              child: Text(
                'Belum ada komentar. Tulis komentar pertamamu!',
                style: TextStyle(color: textSecondary, fontSize: 13),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildCommentCard(Map<String, dynamic> comment) {
    final isAnon = comment['is_anonymous'] == true;
    final profile = comment['profiles'] as Map<String, dynamic>?;
    final authorName = isAnon ? 'Pengguna Rahasia' : (profile?['full_name'] ?? 'Pengguna');
    final avatarUrl = profile?['avatar_url'] as String?;
    final content = comment['content'] ?? '';
    final timeAgo = _formatTimeAgo(comment['created_at']);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF1F5F9), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              isAnon
                  ? Container(
                      width: 32,
                      height: 32,
                      decoration: const BoxDecoration(
                        color: Color(0xFFCBD5E1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.lock_person_rounded,
                        color: Color(0xFF64748B),
                        size: 16,
                      ),
                    )
                  : CircleAvatar(
                      radius: 16,
                      backgroundColor: const Color(0xFFEDE9FE),
                      backgroundImage: avatarUrl != null && avatarUrl.isNotEmpty
                          ? NetworkImage(avatarUrl)
                          : null,
                      child: avatarUrl == null || avatarUrl.isEmpty
                          ? Text(
                              authorName.isNotEmpty ? authorName[0].toUpperCase() : 'U',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: primaryColor,
                              ),
                            )
                          : null,
                    ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      authorName,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: textPrimary,
                      ),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      timeAgo,
                      style: const TextStyle(
                        fontSize: 10,
                        color: textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                icon: const Icon(
                  Icons.more_vert_rounded,
                  color: textSecondary,
                  size: 18,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                onSelected: (value) {
                  if (value == 'report') {
                    _showReportDialog(context, commentId: comment['id']);
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem<String>(
                    value: 'report',
                    child: Row(
                      children: [
                        Icon(Icons.flag_outlined, color: Colors.red, size: 16),
                        SizedBox(width: 8),
                        Text('Laporkan Komentar', style: TextStyle(fontSize: 12, color: Colors.red)),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.only(left: 4.0),
            child: Text(
              content,
              style: const TextStyle(
                fontSize: 13.5,
                color: textPrimary,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStickyCommentInput() {
    return Container(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 10,
        bottom: 10 + MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              // Checkbox Anonim
              GestureDetector(
                onTap: () {
                  setState(() {
                    _isCommentAnonymous = !_isCommentAnonymous;
                  });
                },
                child: Row(
                  children: [
                    Icon(
                      _isCommentAnonymous ? Icons.lock_person_rounded : Icons.lock_open_rounded,
                      color: _isCommentAnonymous ? primaryColor : textSecondary,
                      size: 18,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _isCommentAnonymous ? 'Anonim' : 'Nama Asli',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: _isCommentAnonymous ? primaryColor : textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: TextField(
                    controller: _commentController,
                    maxLines: 4,
                    minLines: 1,
                    style: const TextStyle(fontSize: 13.5, color: textPrimary),
                    decoration: const InputDecoration(
                      hintText: 'Tulis tanggapanmu...',
                      hintStyle: TextStyle(color: textSecondary),
                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              _isSendingComment
                  ? const SizedBox(
                      width: 40,
                      height: 40,
                      child: Padding(
                        padding: EdgeInsets.all(10.0),
                        child: CircularProgressIndicator(strokeWidth: 2, color: primaryColor),
                      ),
                    )
                  : CircleAvatar(
                      radius: 20,
                      backgroundColor: primaryColor,
                      child: IconButton(
                        icon: const Icon(Icons.send_rounded, color: Colors.white, size: 18),
                        onPressed: _sendComment,
                      ),
                    ),
            ],
          ),
        ],
      ),
    );
  }
}
