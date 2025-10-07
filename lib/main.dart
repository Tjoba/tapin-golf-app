import 'package:flutter/material.dart';
import 'pages/home_page.dart';
import 'pages/play_page.dart';
import 'pages/book_page.dart';
import 'pages/search_page.dart';
import 'pages/you_page.dart';

void main() {
  runApp(const TapinApp());
}

class TapinApp extends StatelessWidget {
  const TapinApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TAPIN.',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF3F768E), // Brand blue color
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: Colors.grey[100], // Light gray background
        useMaterial3: true,
        fontFamily: 'Inter',
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          selectedLabelStyle: TextStyle(
            fontFamily: 'Inter',
            fontWeight: FontWeight.w900,
            fontSize: 12,
            letterSpacing: -0.5,
          ),
          unselectedLabelStyle: TextStyle(
            fontFamily: 'Inter',
            fontWeight: FontWeight.w400,
            fontSize: 12,
            letterSpacing: -0.5,
          ),
        ),
        textTheme: const TextTheme(
          displayLarge: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w900),
          displayMedium: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w900),
          displaySmall: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w900),
          headlineLarge: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w900),
          headlineMedium: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w900),
          headlineSmall: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w900),
          titleLarge: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w900),
          titleMedium: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w900),
          titleSmall: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w900),
          bodyLarge: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w900),
          bodyMedium: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w900),
          bodySmall: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w900),
          labelLarge: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w900),
          labelMedium: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w900),
          labelSmall: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w900),
        ),
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

  static final List<Widget> _pages = <Widget>[
    const HomePage(),
    const PlayPage(),
    const BookPage(),
    const SearchPage(),
    const YouPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Widget _buildTabItem(int index, String label, IconData? icon) {
    final isSelected = _selectedIndex == index;
    
    return Expanded(
      child: GestureDetector(
        onTap: () => _onItemTapped(index),
        child: Container(
          height: 60,
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.grey[200],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(
                  icon,
                  size: 24,
                  color: isSelected
                      ? const Color(0xFF3F768E)
                      : Colors.grey,
                ),
                const SizedBox(height: 2),
              ],
              // Special handling for TAPIN./Home tab
              if (index == 0) ...[
                Text(
                  'TAPIN.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    letterSpacing: -0.5,
                    color: isSelected ? const Color(0xFF3F768E) : Colors.grey,
                  ),
                ),
                Text(
                  'Home',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w400,
                    fontSize: 12,
                    letterSpacing: -0.5,
                    color: isSelected ? const Color(0xFF3F768E) : Colors.grey,
                  ),
                ),
              ] else ...[
                Text(
                  label,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontWeight: FontWeight.w400,
                    fontSize: 12,
                    letterSpacing: -0.5,
                    color: isSelected ? const Color(0xFF3F768E) : Colors.grey,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
        ),
        child: Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: SizedBox(
            height: 60,
            child: Row(
              children: [
                _buildTabItem(0, 'TAPIN.\nHome', null),
                _buildTabItem(1, 'Play', Icons.sports_golf),
                _buildTabItem(2, 'Book', Icons.calendar_today),
                _buildTabItem(3, 'Search', Icons.search),
                _buildTabItem(4, 'You', Icons.person),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
