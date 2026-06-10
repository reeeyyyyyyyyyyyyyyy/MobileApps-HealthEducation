import 'package:flutter/material.dart';

void main() {
  runApp(const HealthEduApp());
}

class HealthEduApp extends StatelessWidget {
  const HealthEduApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Health Edu App',
      debugShowCheckedModeBanner: false, // Menghilangkan pita "DEBUG" di pojok
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF8B5CF6),
        ), // Warna ungu pastel ala desainmu
        useMaterial3: true,
      ),
      home: const MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  // Daftar halaman sementara
  static const List<Widget> _pages = <Widget>[
    Center(child: Text('Coming Soon', style: TextStyle(fontSize: 24))),
    Center(
      child: Text('Halaman Belajar (Modul)', style: TextStyle(fontSize: 24)),
    ),
    Center(child: Text('Halaman Kuis', style: TextStyle(fontSize: 24))),
    Center(child: Text('Halaman Komunitas', style: TextStyle(fontSize: 24))),
    Center(child: Text('Halaman Profil', style: TextStyle(fontSize: 24))),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Apps apa ini',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: _pages.elementAt(_selectedIndex),
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
        type: BottomNavigationBarType
            .fixed, // Agar semua menu tampil meski lebih dari 3
      ),
    );
  }
}
