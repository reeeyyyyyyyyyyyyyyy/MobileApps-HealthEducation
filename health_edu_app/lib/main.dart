import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';
import 'pages/beranda_page.dart';
import 'pages/belajar_page.dart';
import 'pages/kuis_page.dart';
import 'pages/komunitas_page.dart';
import 'pages/profil_page.dart';
import 'pages/splash_page.dart';
import 'utils/toast_helper.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

// Helper to check if Supabase is successfully initialized
bool get isSupabaseInitialized {
  try {
    Supabase.instance;
    return true;
  } catch (_) {
    return false;
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    debugPrint('Failed to load env: $e');
  }
  
  try {
    // Attempt initialization with config credentials
    await Supabase.initialize(
      url: 'https://yxlupfucivdogmqvhzho.supabase.co',
      publishableKey: 'sb_publishable_rJjtSnKe_ZhiDm8jtjHzmQ_EFRMHkP9',
    );
  } catch (e) {
    debugPrint('Supabase initialization failed: $e');
  }

  runApp(const HealthEduApp());
}

final GlobalKey<NavigatorState> appNavigatorKey = GlobalKey<NavigatorState>();

class HealthEduApp extends StatelessWidget {
  const HealthEduApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: appNavigatorKey,
      title: 'BloomFem',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF8B5CF6),
        ),
        useMaterial3: true,
      ),
      home: const SplashPage(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => MainScreenState();

  static MainScreenState? of(BuildContext context) {
    return context.findAncestorStateOfType<MainScreenState>();
  }
}

class MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  Timer? _modulePollTimer;
  RealtimeChannel? _moduleRealtimeChannel;

  @override
  void initState() {
    super.initState();
    _startModulePolling();
    _subscribeRealtime();
  }

  @override
  void dispose() {
    _modulePollTimer?.cancel();
    if (_moduleRealtimeChannel != null) {
      Supabase.instance.client.removeChannel(_moduleRealtimeChannel!);
    }
    super.dispose();
  }

  void _subscribeRealtime() {
    try {
      _moduleRealtimeChannel = Supabase.instance.client.channel('public:modules');
      _moduleRealtimeChannel?.onPostgresChanges(
        event: PostgresChangeEvent.all,
        schema: 'public',
        table: 'modules',
        callback: (payload) {
          _checkNewModule();
        },
      ).subscribe();
    } catch (e) {
      debugPrint('Realtime channel error: $e');
    }
  }

  void _startModulePolling() {
    _modulePollTimer?.cancel();
    // Check immediately and poll every 15 seconds for new scheduled/published modules
    _checkNewModule();
    _modulePollTimer = Timer.periodic(const Duration(seconds: 15), (_) {
      _checkNewModule();
    });
  }

  Future<void> _checkNewModule() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      final res = await Supabase.instance.client
          .from('modules')
          .select('id, title')
          .eq('published', 1)
          .order('created_at', ascending: false)
          .limit(1)
          .maybeSingle();
      if (res == null) return;
      final seenKey = 'notif_module_${res['id']}';
      if (prefs.getBool(seenKey) == true) return;
      await prefs.setBool(seenKey, true);

      String pathName = 'Modul Mandiri';
      try {
        final pm = await Supabase.instance.client
            .from('learning_path_modules').select('path_id').eq('module_id', res['id']).maybeSingle();
        if (pm != null) {
          final p = await Supabase.instance.client
              .from('learning_paths').select('title').eq('id', pm['path_id']).maybeSingle();
          if (p != null) pathName = p['title'];
        }
      } catch (_) {}

      final navContext = appNavigatorKey.currentContext ?? context;
      if (navContext.mounted) {
        ToastHelper.showSuccess(navContext, 'Modul Baru!\n${res['title']} pada learning path "$pathName" telah tersedia!');
      }
    } catch (_) {}
  }

  void navigateToPage(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = <Widget>[
      const BerandaPage(),
      const BelajarPage(),
      const KuisPage(),
      const KomunitasPage(),
      const ProfilPage(),
    ];

    return Scaffold(
      body: pages.elementAt(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Beranda'),
          BottomNavigationBarItem(icon: Icon(Icons.book), label: 'Belajar'),
          BottomNavigationBarItem(icon: Icon(Icons.quiz), label: 'Kuis'),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Komunitas'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: const Color(0xFF8B5CF6),
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed, // Agar semua menu tampil meski lebih dari 3
      ),
    );
  }
}
