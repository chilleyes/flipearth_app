import 'package:flutter/material.dart';
import '../../core/widgets/glass_bottom_nav.dart';
import '../planner/planner_page.dart';
import '../explore/explore_page.dart';
import '../trips/my_trips_page.dart';
import '../tickets/my_tickets_page.dart';
import '../profile/profile_page.dart';
import '../../core/theme/app_colors.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _currentIndex = 1; // Default to Planner

  // Dummy pages for now, later we will replace with actual feature pages
  final List<Widget> _pages = [
    const ExplorePage(), // <-- Explore Page hooked up
    const PlannerPage(), // <-- The new Hero Planner Page
    const MyTripsPage(), // <-- My Trips Page hooked up
    const MyTicketsPage(), // <-- My Tickets Page hooked up
    const ProfilePage(),  // <-- Profile Page hooked up
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
      extendBody: true, // This is crucial for the Glass Nav to overlap the content
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
                  NavigationRailDestination(icon: Icon(Icons.explore_outlined), selectedIcon: Icon(Icons.explore), label: Text('探索')),
                  NavigationRailDestination(icon: Icon(Icons.train_outlined), selectedIcon: Icon(Icons.train), label: Text('行程定')),
                  NavigationRailDestination(icon: Icon(Icons.map_outlined), selectedIcon: Icon(Icons.map), label: Text('我的行程')),
                  NavigationRailDestination(icon: Icon(Icons.receipt_long_outlined), selectedIcon: Icon(Icons.receipt_long), label: Text('我的车票')),
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
      bottomNavigationBar: isWideScreen ? null : GlassBottomNavBar(
        currentIndex: _currentIndex,
        onTabSelected: _onTabTapped,
      ),
    );
  }
}


