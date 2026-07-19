import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'detail_modul_page.dart';

class BookmarksPage extends StatefulWidget {
  const BookmarksPage({super.key});

  @override
  State<BookmarksPage> createState() => _BookmarksPageState();
}

class _BookmarksPageState extends State<BookmarksPage> {
  static const Color primaryColor = Color(0xFF8B5CF6);
  static const Color backgroundColor = Color(0xFFF8FAFC);
  static const Color textPrimary = Color(0xFF1E293B);
  static const Color textSecondary = Color(0xFF64748B);

  List<Map<String, dynamic>>? _bookmarkedModules;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchBookmarkedModules();
  }

  Future<void> _fetchBookmarkedModules() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      setState(() => _isLoading = false);
      return;
    }

    try {
      final response = await Supabase.instance.client
          .from('user_bookmarks')
          .select('modules(*)')
          .eq('user_id', user.id)
          .order('created_at', ascending: false);

      setState(() {
        _bookmarkedModules = List<Map<String, dynamic>>.from(
          (response as List).map((r) => Map<String, dynamic>.from(r['modules'])),
        );
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error fetching bookmarks: $e');
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 1,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: textPrimary, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Modul yang Disimpan', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textPrimary)),
        shape: Border(bottom: BorderSide(color: Color(0xFFE2E8F0), width: 1)),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: primaryColor))
          : _bookmarkedModules == null || _bookmarkedModules!.isEmpty
              ? Center(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.bookmark_border_rounded, size: 64, color: Color(0xFFCBD5E1)),
                        SizedBox(height: 16),
                        Text('Belum ada modul yang disimpan', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textSecondary)),
                        SizedBox(height: 8),
                        Text('Simpan modul favoritmu dengan menekan ikon bookmark saat membaca modul.', textAlign: TextAlign.center, style: TextStyle(fontSize: 13, color: textSecondary)),
                      ],
                    ),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _fetchBookmarkedModules,
                  child: ListView.separated(
                    padding: EdgeInsets.all(16),
                    itemCount: _bookmarkedModules!.length,
                    separatorBuilder: (_, __) => SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final module = _bookmarkedModules![index];
                      return _buildModuleCard(module);
                    },
                  ),
                ),
    );
  }

  Widget _buildModuleCard(Map<String, dynamic> module) {
    final title = module['title'] as String? ?? '';
    final category = module['category'] as String? ?? '';
    final duration = module['duration'] as String? ?? '';
    final categoryColor = category.contains('Pengetahuan')
        ? Color(0xFF3B82F6)
        : category.contains('Sikap')
            ? Color(0xFFEC4899)
            : Color(0xFF10B981);

    return Dismissible(
      key: Key(module['id'] as String),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: Color(0xFFFEE2E2),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Icon(Icons.delete_outline_rounded, color: Color(0xFFDC2626), size: 28),
      ),
      onDismissed: (_) => _removeBookmark(module['id'] as String),
      child: InkWell(
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => DetailModulPage(module: module)));
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Color(0xFFE2E8F0), width: 1),
          ),
          child: Row(
            children: [
              Container(
                width: 48, height: 48,
                decoration: BoxDecoration(color: categoryColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
                child: Icon(Icons.menu_book_rounded, color: categoryColor, size: 24),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: textPrimary), maxLines: 2, overflow: TextOverflow.ellipsis),
                    SizedBox(height: 4),
                    Text('$duration · $category', style: TextStyle(fontSize: 11, color: textSecondary)),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: Color(0xFFCBD5E1), size: 24),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _removeBookmark(String moduleId) async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;
    try {
      await Supabase.instance.client
          .from('user_bookmarks')
          .delete()
          .eq('user_id', user.id)
          .eq('module_id', moduleId);
      await _fetchBookmarkedModules();
    } catch (e) {
      debugPrint('Error removing bookmark: $e');
    }
  }
}
