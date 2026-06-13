import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'pages/beranda_page.dart';
import 'pages/belajar_page.dart';
import 'pages/kuis_page.dart';
import 'pages/komunitas_page.dart';
import 'pages/profil_page.dart';
import 'pages/splash_page.dart';

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

class HealthEduApp extends StatelessWidget {
  const HealthEduApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
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
  int _belajarCategoryIndex = 0;

  void navigateToPage(int index, {int categoryIndex = 0}) {
    setState(() {
      _selectedIndex = index;
      if (index == 1) {
        _belajarCategoryIndex = categoryIndex;
      }
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      if (index == 1) {
        _belajarCategoryIndex = 0; // Reset ke "Semua" jika ditekan manual dari tab bar
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = <Widget>[
      const BerandaPage(),
      BelajarPage(initialCategoryIndex: _belajarCategoryIndex),
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
