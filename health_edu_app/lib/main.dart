import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'theme/uticare_theme.dart';
import 'pages/beranda_page.dart';
import 'pages/edukasi_page.dart';
import 'pages/check_risk_page.dart';
import 'pages/pengingat_page.dart';
import 'pages/profil_page.dart';
import 'pages/splash_page.dart';
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
    await Supabase.initialize(
      url: dotenv.env['SUPABASE_URL'] ?? 'https://lvvftnvgdwdkoyxjskkj.supabase.co',
      publishableKey: dotenv.env['SUPABASE_ANON_KEY'] ?? '',
    );
  } catch (e) {
    debugPrint('Supabase initialization failed: $e');
  }

  runApp(const UtiCareApp());
}

final GlobalKey<NavigatorState> appNavigatorKey = GlobalKey<NavigatorState>();

class UtiCareApp extends StatelessWidget {
  const UtiCareApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: appNavigatorKey,
      title: 'UtiCare',
      debugShowCheckedModeBanner: false,
      theme: UtiCareTheme.themeData,
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
      const EdukasiPage(),
      const CheckRiskPage(),
      const PengingatPage(),
      const ProfilPage(),
    ];

    return Scaffold(
      body: pages.elementAt(_selectedIndex),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: UtiCareTheme.surface,
          boxShadow: [
            BoxShadow(
              color: UtiCareTheme.primary.withValues(alpha: 0.08),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.home_rounded),
              activeIcon: Icon(Icons.home_rounded),
              label: 'Beranda',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.menu_book_rounded),
              activeIcon: Icon(Icons.menu_book_rounded),
              label: 'Edukasi',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.fact_check_rounded),
              activeIcon: Icon(Icons.fact_check_rounded),
              label: 'Check Risk',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.notifications_rounded),
              activeIcon: Icon(Icons.notifications_rounded),
              label: 'Pengingat',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_rounded),
              activeIcon: Icon(Icons.person_rounded),
              label: 'Profil',
            ),
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: UtiCareTheme.primary,
          unselectedItemColor: UtiCareTheme.textTertiary,
          onTap: _onItemTapped,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.transparent,
          elevation: 0,
          selectedFontSize: 11,
          unselectedFontSize: 11,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w700),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500),
        ),
      ),
    );
  }
}
