import 'package:flutter/material.dart';

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

  // Data postingan contoh
  final List<_PostData> _posts = [
    _PostData(
      avatarColor: const Color(0xFFC4B5FD),
      avatarIcon: Icons.person_rounded,
      username: 'Anonim',
      timeAgo: '2 jam yang lalu',
      content:
          'Apakah normal kalau siklus menstruasi maju jadi 21 hari? Kakak-kakak ada yang pernah ngalamin?',
      likes: 12,
      comments: 5,
      isLiked: false,
    ),
    _PostData(
      avatarColor: const Color(0xFFFBCFE8),
      avatarIcon: Icons.lock_person_rounded,
      username: 'Anonim',
      timeAgo: '5 jam yang lalu',
      content:
          'Aku mau cerita, aku baru pertama kali menstruasi dan bingung harus pakai apa. Ada yang bisa bantu kasih saran?',
      likes: 24,
      comments: 11,
      isLiked: true,
    ),
    _PostData(
      avatarColor: const Color(0xFFA7F3D0),
      avatarIcon: Icons.person_rounded,
      username: 'Anonim',
      timeAgo: '1 hari yang lalu',
      content:
          'Tips dari aku: kalau lagi kram perut saat haid, coba kompres hangat di bagian perut bawah. Biasanya lumayan membantu!',
      likes: 38,
      comments: 7,
      isLiked: false,
    ),
    _PostData(
      avatarColor: const Color(0xFFBFDBFE),
      avatarIcon: Icons.lock_person_rounded,
      username: 'Anonim',
      timeAgo: '2 hari yang lalu',
      content:
          'Kenapa ya setiap mau haid mood aku jadi berantakan? Teman-teman juga merasakan hal yang sama?',
      likes: 19,
      comments: 14,
      isLiked: false,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        color: backgroundColor,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              _buildHeader(),
              const SizedBox(height: 16),

              // Banner Komunitas
              _buildBannerKomunitas(),
              const SizedBox(height: 16),

              // Input postingan baru
              _buildNewPostInput(),
              const SizedBox(height: 20),

              // Judul feed
              _buildSectionTitle('Diskusi Terbaru'),
              const SizedBox(height: 12),

              // Feed postingan
              _buildPostFeed(),
            ],
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────
  //  HEADER
  // ─────────────────────────────────────────────
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
  //  BANNER KOMUNITAS
  // ─────────────────────────────────────────────
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
          // Teks
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
                  onPressed: () {},
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
                    'Gabung Komunitas',
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

          // Ilustrasi
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

  // ─────────────────────────────────────────────
  //  INPUT POSTINGAN BARU
  // ─────────────────────────────────────────────
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
          // Ikon avatar
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

          // Teks hint
          const Expanded(
            child: Text(
              'Tanyakan sesuatu secara anonim di sini...',
              style: TextStyle(
                fontSize: 14,
                color: textSecondary,
              ),
            ),
          ),

          // Ikon edit
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

  // ─────────────────────────────────────────────
  //  FEED POSTINGAN
  // ─────────────────────────────────────────────
  Widget _buildPostFeed() {
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: _posts.length,
      itemBuilder: (context, index) {
        return _buildPostCard(_posts[index]);
      },
    );
  }

  Widget _buildPostCard(_PostData post) {
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
          // ── Baris Atas: Avatar + Username + Time + Report ──
          Row(
            children: [
              // Avatar samaran
              CircleAvatar(
                radius: 18,
                backgroundColor: post.avatarColor,
                child: Icon(
                  post.avatarIcon,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),

              // Username + waktu
              Expanded(
                child: RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: post.username,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: textPrimary,
                        ),
                      ),
                      TextSpan(
                        text: '  •  ${post.timeAgo}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Ikon report
              GestureDetector(
                onTap: () {},
                child: const Icon(
                  Icons.flag_outlined,
                  color: textSecondary,
                  size: 20,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // ── Konten Teks ──
          Text(
            post.content,
            style: const TextStyle(
              fontSize: 14,
              color: textPrimary,
              height: 1.4,
            ),
          ),

          const SizedBox(height: 14),

          // ── Baris Bawah: Like + Komentar ──
          Row(
            children: [
              // Tombol Like
              _buildInteractionButton(
                icon: post.isLiked
                    ? Icons.favorite_rounded
                    : Icons.favorite_border_rounded,
                label: '${post.likes}',
                color: post.isLiked
                    ? const Color(0xFFEC4899)
                    : textSecondary,
                bgColor: post.isLiked
                    ? const Color(0xFFFCE7F3)
                    : const Color(0xFFF1F5F9),
              ),
              const SizedBox(width: 10),

              // Tombol Komentar
              _buildInteractionButton(
                icon: Icons.chat_bubble_outline_rounded,
                label: '${post.comments}',
                color: textSecondary,
                bgColor: const Color(0xFFF1F5F9),
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

// ─────────────────────────────────────────────
//  Data class
// ─────────────────────────────────────────────
class _PostData {
  final Color avatarColor;
  final IconData avatarIcon;
  final String username;
  final String timeAgo;
  final String content;
  final int likes;
  final int comments;
  final bool isLiked;

  _PostData({
    required this.avatarColor,
    required this.avatarIcon,
    required this.username,
    required this.timeAgo,
    required this.content,
    required this.likes,
    required this.comments,
    required this.isLiked,
  });
}
