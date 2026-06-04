import 'package:flutter/material.dart';
import 'home_tab.dart';
import 'track_tab.dart';
import 'progress_tab.dart';
import 'recipe_tab.dart';
import 'learn_tab.dart';
import 'profile_tab.dart';
import 'achievements_tab.dart';

class HomeScreen extends StatefulWidget {
  final Function(ThemeMode) onThemeChanged;
  const HomeScreen({
    super.key,
    required this.onThemeChanged,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();

    _pages = [
      const HomeTab(key: ValueKey('home')),
      const TrackTab(key: ValueKey('track')),
      const ProgressTab(key: ValueKey('progress')),
      const RecipeTab(key: ValueKey('recipe')),
      const AchievementsTab(key: ValueKey('achievements')),
      const LearnTab(key: ValueKey('learn')),
      ProfileTab(
        key: const ValueKey('profile'),
        onThemeChanged: widget.onThemeChanged,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        transitionBuilder: (child, animation) => FadeTransition(
          opacity: animation,
          child: child,
        ),
        child: _pages[_currentIndex],
      ),
      bottomNavigationBar: Container(
        margin: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(25),
          child: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.white,
            selectedItemColor: const Color(0xFF1B5E20),
            unselectedItemColor: Colors.grey,
            selectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home),
                label: "Home",
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.track_changes),
                label: "Track",
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.bar_chart),
                label: "Progress",
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.restaurant_menu),
                label: "Recipe",
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.emoji_events),
                label: "Achievements",
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.school),
                label: "Learn",
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person),
                label: "Profile",
              ),
            ],
          ),
        ),
      ),
    );
  }
}
