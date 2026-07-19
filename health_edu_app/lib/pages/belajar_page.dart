import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../main.dart';
import 'detail_modul_page.dart';

class BelajarPage extends StatefulWidget {
  const BelajarPage({super.key});
  @override
  State<BelajarPage> createState() => _BelajarPageState();
}

class _BelajarPageState extends State<BelajarPage> {
  static const Color primaryColor = Color(0xFF8B5CF6);
  static const Color bg = Color(0xFFF8FAFC);
  static const Color textP = Color(0xFF1E293B);
  static const Color textS = Color(0xFF64748B);

  List<Map<String, dynamic>>? _paths, _pathModules;
  Map<String, Map<String, dynamic>> _mc = {};
  Set<String> _completedIds = {};
  int _currentPathIdx = 0, _selectedTab = 0;
  bool _loading = true;
  Set<String> _expanded = {};

  final _tabs = [
    _TabData('Learning Path', Icons.route_rounded),
    _TabData('Pengetahuan', Icons.psychology_rounded),
    _TabData('Perilaku Sehat', Icons.volunteer_activism_rounded),
    _TabData('Sikap Positif', Icons.favorite_rounded),
  ];

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final pr = await Supabase.instance.client.from('learning_paths').select().order('sort_order');
      _paths = List<Map<String, dynamic>>.from(pr);
      final pmr = await Supabase.instance.client.from('learning_path_modules').select().order('sort_order');
      _pathModules = List<Map<String, dynamic>>.from(pmr);
      final am = await Supabase.instance.client.from('modules').select().eq('published', 1);
      for (final m in am) _mc[m['id']] = Map<String, dynamic>.from(m);
      final prefs = await SharedPreferences.getInstance();
      _completedIds = (prefs.getStringList('completed_modules_list') ?? []).toSet();

      for (int i = 0; i < (_paths?.length ?? 0); i++) {
        final pm = _pathModules!.where((x) => x['path_id'] == _paths![i]['id']).toList();
        if (pm.any((x) => !_completedIds.contains(x['module_id']))) { _currentPathIdx = i; break; }
        _currentPathIdx = i;
      }
      _expanded = {_paths![_currentPathIdx]['id']};
    } catch (e) { debugPrint('$e'); }
    if (mounted) setState(() => _loading = false);
  }

  bool _isUnlocked(int idx) {
    for (int i = 0; i < idx; i++) {
      final pm = _pathModules!.where((x) => x['path_id'] == _paths![i]['id']).toList();
      if (pm.any((x) => !_completedIds.contains(x['module_id']))) return false;
    }
    return true;
  }

  IconData _icon(String? n) {
    switch (n) {
      case 'psychology_rounded': return Icons.psychology_rounded;
      case 'volunteer_activism_rounded': return Icons.volunteer_activism_rounded;
      case 'favorite_rounded': return Icons.favorite_rounded;
      case 'biotech_rounded': return Icons.biotech_rounded;
      case 'clean_hands_rounded': return Icons.clean_hands_rounded;
      case 'restaurant_rounded': return Icons.restaurant_rounded;
      case 'fitness_center_rounded': return Icons.fitness_center_rounded;
      case 'water_drop_rounded': return Icons.water_drop_rounded;
      default: return Icons.book_rounded;
    }
  }

  Color _cc(String? c) {
    switch (c) {
      case 'Pengetahuan': return const Color(0xFF3B82F6);
      case 'Sikap Positif': return const Color(0xFFEC4899);
      case 'Perilaku Sehat': return const Color(0xFF10B981);
      default: return primaryColor;
    }
  }

  String _desc() {
    switch (_selectedTab) {
      case 0: return 'Learning Path: ${_paths![_currentPathIdx]['title']}';
      case 1: return 'Modul Pengetahuan dari path aktif';
      case 2: return 'Modul Perilaku Sehat dari path aktif';
      case 3: return 'Modul Sikap Positif dari path aktif';
      default: return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: bg,
      child: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator(color: primaryColor))
            : RefreshIndicator(onRefresh: _load, child: ListView(padding: const EdgeInsets.all(16), children: [
                _buildHeader(),
                const SizedBox(height: 16),
                ..._selectedTab == 0 ? _buildPaths() : _buildFiltered(),
              ])),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 40, height: 40,
              decoration: BoxDecoration(color: primaryColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
              child: Icon(_tabs[_selectedTab].icon, color: primaryColor, size: 22),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Belajar', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: textP)),
                Text(_desc(), style: TextStyle(fontSize: 12, color: textS)),
              ],
            ),
          ],
        ),
        const SizedBox(height: 16),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: List.generate(_tabs.length, (i) {
              final s = _selectedTab == i;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  avatar: Icon(_tabs[i].icon, size: 16, color: s ? Colors.white : primaryColor),
                  label: Text(_tabs[i].name, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: s ? Colors.white : textS)),
                  selected: s,
                  selectedColor: primaryColor,
                  backgroundColor: const Color(0xFFF1F5F9),
                  onSelected: (_) => setState(() => _selectedTab = i),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  side: BorderSide.none,
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                ),
              );
            }),
          ),
        ),
      ],
    );
  }

  List<Widget> _buildPaths() {
    final r = <Widget>[];
    for (int pi = 0; pi < (_paths?.length ?? 0); pi++) {
      final path = _paths![pi];
      final pid = path['id'] as String;
      final unlocked = _isUnlocked(pi);
      final pms = _pathModules!.where((x) => x['path_id'] == pid).toList();
      final total = pms.length;
      final done = pms.where((x) => _completedIds.contains(x['module_id'])).length;
      final isCurrent = pi == _currentPathIdx;
      final isExpanded = _expanded.contains(pid);

      r.add(Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: done == total ? const Color(0xFFD1FAE5) : const Color(0xFFE2E8F0), width: 1.5),
        ),
        child: Column(
          children: [
            // Collapsible header
            InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () => setState(() {
                if (isExpanded) _expanded.remove(pid); else _expanded.add(pid);
              }),
              child: Container(
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    Container(
                      width: 40, height: 40,
                      decoration: BoxDecoration(
                        color: done == total ? const Color(0xFFD1FAE5) : unlocked ? primaryColor.withValues(alpha: 0.1) : const Color(0xFFE2E8F0),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        done == total ? Icons.check_circle_rounded : unlocked ? Icons.route_rounded : Icons.lock_outline_rounded,
                        color: done == total ? const Color(0xFF10B981) : unlocked ? primaryColor : const Color(0xFF94A3B8),
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(path['title'] ?? '', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: unlocked ? textP : const Color(0xFF94A3B8))),
                          Text(path['description'] ?? '', style: TextStyle(fontSize: 11, color: unlocked ? textS : const Color(0xFFCBD5E1)), maxLines: 1, overflow: TextOverflow.ellipsis),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(color: done == total ? const Color(0xFFD1FAE5) : const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(20)),
                      child: Text(done == total ? 'Selesai' : '$done/$total', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: done == total ? const Color(0xFF065F46) : textS)),
                    ),
                    const SizedBox(width: 4),
                    Icon(isExpanded ? Icons.expand_less : Icons.expand_more, color: textS, size: 20),
                  ],
                ),
              ),
            ),

            // Expanded modules
            if (isExpanded) ...[
              const Divider(height: 1, color: Color(0xFFF1F5F9)),
              ...pms.map((pm) {
                final mod = _mc[pm['module_id']];
                if (mod == null) return const SizedBox();
                final d = _completedIds.contains(mod['id']);
                return Container(
                  padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
                  decoration: BoxDecoration(color: d ? const Color(0xFFF0FDF4) : Colors.transparent),
                  child: InkWell(
                    onTap: unlocked ? () async {
                      await Navigator.push(context, MaterialPageRoute(builder: (_) => DetailModulPage(module: mod)));
                      _load();
                    } : null,
                    child: Row(
                      children: [
                        Container(
                          width: 36, height: 36,
                          decoration: BoxDecoration(color: _cc(mod['category']).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
                          child: Icon(_icon(mod['icon_name']), color: _cc(mod['category']), size: 18),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(mod['title'] ?? '', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: unlocked ? textP : const Color(0xFFCBD5E1))),
                              Row(
                                children: [
                                  Text('${mod['duration'] ?? ''}', style: TextStyle(fontSize: 10, color: textS)),
                                  const SizedBox(width: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                                    decoration: BoxDecoration(color: _cc(mod['category']).withValues(alpha: 0.08), borderRadius: BorderRadius.circular(3)),
                                    child: Text(mod['category'] ?? '', style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: _cc(mod['category']))),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        if (!unlocked) const Icon(Icons.lock_outline_rounded, color: Color(0xFFCBD5E1), size: 18)
                        else if (d) const Icon(Icons.check_circle_rounded, color: Color(0xFF10B981), size: 20)
                        else const Icon(Icons.chevron_right_rounded, color: Color(0xFFCBD5E1), size: 20),
                      ],
                    ),
                  ),
                );
              }),
            ],
          ],
        ),
      ));
    }
    return r;
  }

  List<Widget> _buildFiltered() {
    final cat = _tabs[_selectedTab].name;
    final r = <Widget>[];
    for (int pi = 0; pi < (_paths?.length ?? 0); pi++) {
      final unlocked = _isUnlocked(pi);
      final pms = _pathModules!.where((x) => x['path_id'] == _paths![pi]['id']).toList();
      for (final pm in pms) {
        final mod = _mc[pm['module_id']];
        if (mod == null || mod['category'] != cat) continue;
        final d = _completedIds.contains(mod['id']);
        r.add(Container(
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            color: d ? const Color(0xFFF0FDF4) : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: d ? const Color(0xFFD1FAE5) : const Color(0xFFE2E8F0)),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: unlocked ? () async {
              await Navigator.push(context, MaterialPageRoute(builder: (_) => DetailModulPage(module: mod)));
              _load();
            } : null,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Container(
                    width: 40, height: 40,
                    decoration: BoxDecoration(color: _cc(mod['category']).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
                    child: Icon(_icon(mod['icon_name']), color: _cc(mod['category']), size: 20),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(mod['title'] ?? '', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: unlocked ? textP : const Color(0xFFCBD5E1))),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Text('${mod['duration'] ?? ''}', style: TextStyle(fontSize: 10, color: textS)),
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                              decoration: BoxDecoration(color: primaryColor.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(3)),
                              child: Text(_paths![pi]['title'] ?? '', style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: primaryColor)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  if (!unlocked) const Icon(Icons.lock_outline_rounded, color: Color(0xFFCBD5E1), size: 18)
                  else if (d) const Icon(Icons.check_circle_rounded, color: Color(0xFF10B981), size: 20)
                  else const Icon(Icons.chevron_right_rounded, color: Color(0xFFCBD5E1), size: 20),
                ],
              ),
            ),
          ),
        ));
      }
    }
    if (r.isEmpty) r.add(const Padding(padding: EdgeInsets.all(40), child: Center(child: Text('Tidak ada modul untuk kategori ini', style: TextStyle(color: textS)))));
    return r;
  }
}

class _TabData {
  final String name;
  final IconData icon;
  const _TabData(this.name, this.icon);
}