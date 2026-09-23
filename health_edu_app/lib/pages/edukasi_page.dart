import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme/uticare_theme.dart';

class EdukasiPage extends StatefulWidget {
  const EdukasiPage({super.key});

  @override
  State<EdukasiPage> createState() => _EdukasiPageState();
}

class _EdukasiPageState extends State<EdukasiPage> {
  List<Map<String, dynamic>> _materials = [];
  bool _isLoading = true;
  String _selectedCategory = 'semua';
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  final List<Map<String, String>> _categories = [
    {'key': 'semua', 'label': 'Semua'},
    {'key': 'pengetahuan_isk', 'label': 'Tentang ISK'},
    {'key': 'pencegahan', 'label': 'Pencegahan'},
    {'key': 'kebersihan', 'label': 'Kebersihan'},
    {'key': 'fakta_mitos', 'label': 'Fakta & Mitos'},
  ];

  @override
  void initState() {
    super.initState();
    _fetchMaterials();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchMaterials() async {
    try {
      var filterBuilder = Supabase.instance.client
          .from('education_materials')
          .select()
          .eq('published', 1);

      if (_selectedCategory != 'semua') {
        filterBuilder = filterBuilder.eq('category', _selectedCategory);
      }

      final data = await filterBuilder.order('sort_order', ascending: true);

      if (mounted) {
        setState(() {
          _materials = List<Map<String, dynamic>>.from(data);
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error fetching materials: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  List<Map<String, dynamic>> get _filteredMaterials {
    if (_searchQuery.isEmpty) return _materials;
    return _materials.where((m) {
      final title = (m['title'] ?? '').toString().toLowerCase();
      return title.contains(_searchQuery.toLowerCase());
    }).toList();
  }

  String _getHbmLabel(String? component) {
    switch (component) {
      case 'perceived_susceptibility':
        return 'Kerentanan';
      case 'perceived_severity':
        return 'Keparahan';
      case 'perceived_benefits':
        return 'Manfaat';
      case 'perceived_barriers':
        return 'Hambatan';
      case 'cues_to_action':
        return 'Pemicu';
      case 'self_efficacy':
        return 'Efikasi Diri';
      default:
        return 'Umum';
    }
  }

  Color _getHbmColor(String? component) {
    switch (component) {
      case 'perceived_susceptibility':
        return UtiCareTheme.danger;
      case 'perceived_severity':
        return UtiCareTheme.warning;
      case 'perceived_benefits':
        return UtiCareTheme.success;
      case 'perceived_barriers':
        return const Color(0xFF8B5CF6);
      case 'cues_to_action':
        return UtiCareTheme.accent;
      case 'self_efficacy':
        return const Color(0xFF06B6D4);
      default:
        return UtiCareTheme.textTertiary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: UtiCareTheme.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Edukasi ISK', style: UtiCareTheme.heading1),
                  const SizedBox(height: 4),
                  const Text(
                    'Pelajari cara mencegah ISK dengan materi interaktif',
                    style: UtiCareTheme.body,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Search bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: TextField(
                controller: _searchController,
                onChanged: (val) => setState(() => _searchQuery = val),
                decoration: InputDecoration(
                  hintText: 'Cari materi edukasi...',
                  prefixIcon: const Icon(Icons.search_rounded, color: UtiCareTheme.textTertiary),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.close_rounded, size: 20),
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _searchQuery = '');
                          },
                        )
                      : null,
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Category filter chips
            SizedBox(
              height: 40,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: _categories.length,
                itemBuilder: (context, index) {
                  final cat = _categories[index];
                  final isSelected = _selectedCategory == cat['key'];
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(cat['label']!),
                      selected: isSelected,
                      onSelected: (_) {
                        setState(() {
                          _selectedCategory = cat['key']!;
                          _isLoading = true;
                        });
                        _fetchMaterials();
                      },
                      backgroundColor: UtiCareTheme.surface,
                      selectedColor: UtiCareTheme.primaryLight,
                      labelStyle: TextStyle(
                        color: isSelected ? UtiCareTheme.primaryDark : UtiCareTheme.textSecondary,
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                        fontSize: 13,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(UtiCareTheme.radiusRound),
                        side: BorderSide(
                          color: isSelected ? UtiCareTheme.primary : UtiCareTheme.border,
                        ),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 16),

            // Material list
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator(color: UtiCareTheme.primary))
                  : _filteredMaterials.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.menu_book_rounded, size: 60, color: UtiCareTheme.primaryLight),
                              const SizedBox(height: 16),
                              const Text('Belum ada materi', style: UtiCareTheme.subtitle),
                              const SizedBox(height: 4),
                              const Text(
                                'Materi edukasi akan segera tersedia',
                                style: UtiCareTheme.body,
                              ),
                            ],
                          ),
                        )
                      : RefreshIndicator(
                          onRefresh: _fetchMaterials,
                          color: UtiCareTheme.primary,
                          child: ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            itemCount: _filteredMaterials.length,
                            itemBuilder: (context, index) {
                              final material = _filteredMaterials[index];
                              return _buildMaterialCard(material);
                            },
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMaterialCard(Map<String, dynamic> material) {
    final hbmComponent = material['hbm_component'] as String?;
    final hbmColor = _getHbmColor(hbmComponent);
    final hasVideo = material['video_url'] != null && (material['video_url'] as String).isNotEmpty;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: UtiCareTheme.surface,
        borderRadius: BorderRadius.circular(UtiCareTheme.radiusLg),
        border: Border.all(color: UtiCareTheme.border.withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(
            color: UtiCareTheme.primary.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(UtiCareTheme.radiusLg),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => DetailEdukasiPage(material: material),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: hbmColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(UtiCareTheme.radiusMd),
                  ),
                  child: Icon(
                    hasVideo ? Icons.play_circle_rounded : Icons.article_rounded,
                    color: hbmColor,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        material['title'] ?? '',
                        style: UtiCareTheme.bodyBold,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: hbmColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(UtiCareTheme.radiusRound),
                            ),
                            child: Text(
                              _getHbmLabel(hbmComponent),
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: hbmColor,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Icon(Icons.visibility_rounded, size: 14, color: UtiCareTheme.textTertiary),
                          const SizedBox(width: 4),
                          Text(
                            '${material['view_count'] ?? 0}',
                            style: UtiCareTheme.caption,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right_rounded, color: UtiCareTheme.textTertiary),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// === Detail Edukasi Page ===
class DetailEdukasiPage extends StatefulWidget {
  final Map<String, dynamic> material;

  const DetailEdukasiPage({super.key, required this.material});

  @override
  State<DetailEdukasiPage> createState() => _DetailEdukasiPageState();
}

class _DetailEdukasiPageState extends State<DetailEdukasiPage> {
  bool _isBookmarked = false;

  @override
  void initState() {
    super.initState();
    _incrementViewCount();
    _checkBookmark();
  }

  Future<void> _incrementViewCount() async {
    try {
      final id = widget.material['id'];
      final current = widget.material['view_count'] ?? 0;
      await Supabase.instance.client
          .from('education_materials')
          .update({'view_count': current + 1})
          .eq('id', id);
    } catch (_) {}
  }

  Future<void> _checkBookmark() async {
    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) return;
      final res = await Supabase.instance.client
          .from('user_bookmarks')
          .select('id')
          .eq('user_id', userId)
          .eq('material_id', widget.material['id'])
          .maybeSingle();
      if (mounted) setState(() => _isBookmarked = res != null);
    } catch (_) {}
  }

  Future<void> _toggleBookmark() async {
    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) return;
      final materialId = widget.material['id'];

      if (_isBookmarked) {
        await Supabase.instance.client
            .from('user_bookmarks')
            .delete()
            .eq('user_id', userId)
            .eq('material_id', materialId);
      } else {
        await Supabase.instance.client.from('user_bookmarks').insert({
          'user_id': userId,
          'material_id': materialId,
        });
      }
      if (mounted) setState(() => _isBookmarked = !_isBookmarked);
    } catch (_) {}
  }

  void _launchVideo(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final content = widget.material['content'] ?? '';
    final videoUrl = widget.material['video_url'] as String?;
    final hasVideo = videoUrl != null && videoUrl.isNotEmpty;

    return Scaffold(
      backgroundColor: UtiCareTheme.background,
      appBar: AppBar(
        title: const Text('Detail Materi'),
        actions: [
          IconButton(
            icon: Icon(
              _isBookmarked ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
              color: _isBookmarked ? UtiCareTheme.primary : UtiCareTheme.textSecondary,
            ),
            onPressed: _toggleBookmark,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.material['title'] ?? '',
              style: UtiCareTheme.heading2,
            ),
            const SizedBox(height: 16),

            if (hasVideo) ...[
              Container(
                decoration: BoxDecoration(
                  color: UtiCareTheme.surface,
                  borderRadius: BorderRadius.circular(UtiCareTheme.radiusLg),
                  border: Border.all(color: UtiCareTheme.border),
                ),
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    const Icon(Icons.play_circle_filled_rounded, color: UtiCareTheme.primary, size: 36),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Video Edukasi', style: UtiCareTheme.bodyBold),
                          SizedBox(height: 2),
                          Text('Tonton video penjelasan', style: UtiCareTheme.caption),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () => _launchVideo(videoUrl),
                      child: const Text('Tonton'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],

            // Content
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: UtiCareTheme.surface,
                borderRadius: BorderRadius.circular(UtiCareTheme.radiusLg),
                border: Border.all(color: UtiCareTheme.border.withValues(alpha: 0.5)),
              ),
              padding: const EdgeInsets.all(20),
              child: Text(
                content,
                style: UtiCareTheme.body.copyWith(
                  height: 1.7,
                  color: UtiCareTheme.textPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
