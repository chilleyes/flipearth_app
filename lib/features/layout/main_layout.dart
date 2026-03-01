import 'package:flutter/material.dart';
import '../../core/widgets/glass_bottom_nav.dart';
import '../home/home_page.dart';
import '../planner/planner_page.dart';
import '../trips/trip_list_page.dart';
import '../profile/profile_page.dart';
import '../../core/theme/app_colors.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const HomePage(),
    const PlannerPage(),
    const TripListPage(),
    const ProfilePage(),
  ];

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool isWideScreen = MediaQuery.of(context).size.width > 600;

    return Scaffold(
      extendBody: true,
      body: isWideScreen
          ? Row(
              children: [
                NavigationRail(
                  selectedIndex: _currentIndex,
                  onDestinationSelected: _onTabTapped,
                  labelType: NavigationRailLabelType.all,
                  backgroundColor: context.colors.background,
                  selectedIconTheme: IconThemeData(color: context.colors.brandBlue),
                  unselectedIconTheme: IconThemeData(color: context.colors.textMuted),
                  destinations: const [
                    NavigationRailDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: Text('首页')),
                    NavigationRailDestination(icon: Icon(Icons.auto_awesome_outlined), selectedIcon: Icon(Icons.auto_awesome), label: Text('规划')),
                    NavigationRailDestination(icon: Icon(Icons.luggage_outlined), selectedIcon: Icon(Icons.luggage), label: Text('行程')),
                    NavigationRailDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: Text('我的')),
                  ],
                ),
                Expanded(
                  child: IndexedStack(
                    index: _currentIndex,
                    children: _pages,
                  ),
                ),
              ],
            )
          : IndexedStack(
              index: _currentIndex,
              children: _pages,
            ),
      bottomNavigationBar: isWideScreen
          ? null
          : GlassBottomNavBar(
              currentIndex: _currentIndex,
              onTabSelected: _onTabTapped,
            ),
    );
  }
}
